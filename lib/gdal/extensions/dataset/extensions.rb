# frozen_string_literal: true

require 'narray'
require 'ffi-gdal'
require 'gdal/dataset'
require 'gdal/raster_band'
require 'gdal/warp_operation'
require 'ogr/driver'
require 'ogr/layer'
require 'ogr/spatial_reference'
require 'ogr/coordinate_transformation'

module GDAL
  class Dataset
    # Methods not originally supplied with GDAL, but enhance it.
    module Extensions
      # @return [Array<GDAL::RasterBand>]
      def raster_bands
        1.upto(raster_count).map do |i|
          raster_band(i)
        end
      end

      # Iterates raster bands from 1 to #raster_count and yields them to the given
      # block.
      def each_band
        1.upto(raster_count) do |i|
          yield(raster_band(i))
        end
      end

      # Returns the first raster band for which the block returns true.
      #
      # @example
      #
      #   dataset.find_band do |band|
      #     band.color_interpretation == :GCI_RedBand
      #   end
      #
      # @return [GDAL::RasterBand]
      def find_band
        each_band do |band|
          result = yield(band)
          return band if result
        end
      end

      # @return [GDAL::RasterBand, nil]
      def red_band
        band = find_band do |b|
          b.color_interpretation == :GCI_RedBand
        end

        band.is_a?(GDAL::RasterBand) ? band : nil
      end

      # @return [GDAL::RasterBand, nil]
      def green_band
        band = find_band do |b|
          b.color_interpretation == :GCI_GreenBand
        end

        band.is_a?(GDAL::RasterBand) ? band : nil
      end

      # @return [GDAL::RasterBand, nil]
      def blue_band
        band = find_band do |b|
          b.color_interpretation == :GCI_BlueBand
        end

        band.is_a?(GDAL::RasterBand) ? band : nil
      end

      # @return [GDAL::RasterBand, nil]
      def undefined_band
        band = find_band do |b|
          b.color_interpretation == :GCI_Undefined
        end

        band.is_a?(GDAL::RasterBand) ? band : nil
      end

      # Converts raster band number +band_number+ to the vector format
      # +vector_driver_name+.  Similar to gdal_polygonize.py.  If block format is
      # used, the new DataSource will be closed/flushed when the block returns. If
      # the non-block format is used, you need to call #close on the DataSource.
      #
      # @param file_name [String] Path to write the vector file to.
      # @param vector_driver_name [String] One of OGR::Driver.names.
      # @param geometry_type [FFI::GDAL::OGRwkbGeometryType] The type of geometry
      #   to use when turning the raster into a vector image.
      # @param layer_name_prefix [String] Prefix of the name to give the new
      #   vector layer.
      # @param band_numbers [Array<Integer>,Integer] Number of the raster band or
      #   bands from this dataset to vectorize.  Can be a single Integer or array
      #   of Integers.
      # @return [OGR::DataSource]
      def to_vector(file_name, vector_driver_name, geometry_type: :wkbUnknown,
        layer_name_prefix: 'band_number', band_numbers: [1],
        field_name_prefix: 'field', use_band_masks: true)
        band_numbers = [band_numbers] unless band_numbers.is_a?(Array)
        ogr_driver = OGR::Driver.by_name(vector_driver_name)

        if projection.empty?
          spatial_ref = nil
        else
          spatial_ref = OGR::SpatialReference.new(projection)
          begin
            spatial_ref.auto_identify_epsg!
          rescue StandardError
            OGR::UnsupportedSRS
          end
        end

        data_source = ogr_driver.create_data_source(file_name)

        # TODO: fasterer: each_with_index is slower than loop
        band_numbers.each_with_index do |band_number, i|
          log "Starting to polygonize raster band #{band_number}..."
          layer_name = "#{layer_name_prefix}-#{band_number}"
          layer = data_source.create_layer(layer_name, geometry_type: geometry_type,
                                                       spatial_reference: spatial_ref)

          field_name = "#{field_name_prefix}#{i}"
          layer.create_field(OGR::FieldDefinition.new(field_name, :OFTInteger))
          band = raster_band(band_number)

          raise GDAL::InvalidBandNumber, "Unknown band number: #{band_number}" unless band

          pixel_value_field = layer.feature_definition.field_index(field_name)
          options = { pixel_value_field: pixel_value_field }
          options[:mask_band] = band.mask_band if use_band_masks
          band.polygonize(layer, **options)
        end

        if block_given?
          yield data_source
          data_source.close
        end

        data_source
      end

      # Gets the OGR::Geometry that represents the extent of the dataset.
      #
      # @return [OGR::Polygon]
      # TODO: This should return an OGR::Envelope.
      def extent
        ul = geo_transform.apply_geo_transform(0, 0)
        ur = geo_transform.apply_geo_transform(raster_x_size, 0)
        lr = geo_transform.apply_geo_transform(raster_x_size, raster_y_size)
        ll = geo_transform.apply_geo_transform(0, raster_y_size)

        ring = OGR::LinearRing.new
        ring.point_count = 5
        ring.set_point(0, ul[:x_geo], ul[:y_geo])
        ring.set_point(1, ur[:x_geo], ur[:y_geo])
        ring.set_point(2, lr[:x_geo], lr[:y_geo])
        ring.set_point(3, ll[:x_geo], ll[:y_geo])
        ring.set_point(4, ul[:x_geo], ul[:y_geo])

        polygon = OGR::Polygon.new
        polygon.add_geometry(ring)
        polygon.spatial_reference = spatial_reference

        polygon
      end

      # @param wkt_geometry_string [String]
      # @param wkt_srid [Integer]
      # @return [Boolean]
      def contains_geometry?(wkt_geometry_string, wkt_srid = 4326)
        source_srs = OGR::SpatialReference.new_from_epsg(wkt_srid)
        source_geometry = OGR::Geometry.create_from_wkt(wkt_geometry_string, source_srs)
        @raster_geometry ||= extent

        coordinate_transformation = OGR::CoordinateTransformation.new(source_srs,
                                                                      @raster_geometry.spatial_reference)
        source_geometry.transform!(coordinate_transformation)

        @raster_geometry.contains? source_geometry
      end

      # Retrieves pixels from each raster band and converts this to an array of
      # points per pixel.  For example:
      #
      #   # If the arrays for each band look like:
      #   red_band_array = [0, 0, 0]
      #   green_band_array = [10, 10, 10]
      #   blue_band_array = [99, 99, 99]
      #   alpha_band_array = [250, 150, 2]
      #
      #   # This array would look like:
      #   [[0, 10, 99, 2], [0, 10, 99, 150], [0, 10, 99, 250]]
      # @return NArray
      def to_na(to_data_type = nil)
        na = NMatrix.to_na(raster_bands.map { |r| r.to_na(to_data_type) })

        NArray[*na.transpose]
      end
    end
  end
end
GDAL::Dataset.include(GDAL::Dataset::Extensions)
