require 'json'
require 'narray'
require_relative '../../ffi-gdal'
require_relative '../raster_band'
require_relative '../warp_operation'
require_relative '../../ogr/driver'
require_relative '../../ogr/layer'
require_relative '../../ogr/spatial_reference'
require_relative '../../ogr/coordinate_transformation'

module GDAL
  module DatasetMixins
    # Methods not originally supplied with GDAL, but enhance it.
    module Extensions
      # Computes NDVI from the red and near-infrared bands in the dataset.
      # Raises a GDAL::RequiredBandNotFound if one of those band types isn't
      # found. Also, it closes the dataset to ensure all data and metadata have
      # been flushed to disk. To work with the file, you'll need to reopen it.
      #
      # @param destination [String] Path to output the new dataset to.
      # @param red_band_number [Fixnum] Number of the band in the dataset that
      #   contains red data. Note that you can pass in band numbers of other
      #   types to perform NDVI using that type (ex. GNDVI).
      # @param nir_band_number [Fixnum] Number of the band in the dataset that
      #   contains near-infrared data data.
      # @param driver_name [String] The driver name to use for creating the
      #   dataset. Defaults to "GTiff".
      # @param output_data_type [FFI::GDAL::DataType] Resulting dataset will be
      #   in this data type. Defaults to use the current data type.
      # @param remove_negatives [Boolean] Remove negative values after
      #   calculating NDVI. Defaults to +false+.
      # @param no_data_value [Float] Value to set the band's NODATA value to.
      #   Defaults to -9999.0.
      # @param options [Hash] Options that get used for creating the new NDVI
      #   dataset. See docs for GDAL::Driver#create_dataset.
      # @return [GDAL::Dataset] The new NDVI dataset. *Be sure to call #close on
      #   this object or the data may not persist!*
      def extract_ndvi(destination, red_band_number, nir_band_number, driver_name: 'GTiff',
        output_data_type: nil, remove_negatives: false, no_data_value: -9999.0, **options)
        red = raster_band(red_band_number)
        nir = raster_band(nir_band_number)
        raise RequiredBandNotFound, 'Red band not found.' if red.nil?
        raise RequiredBandNotFound, 'Near-infrared' if nir.nil?

        output_data_type ||= red.data_type
        the_array = calculate_ndvi(red.to_na, nir.to_na, no_data_value, remove_negatives, output_data_type)
        driver = GDAL::Driver.by_name(driver_name)

        ndvi = driver.create_dataset(destination, raster_x_size, raster_y_size,
          data_type: output_data_type, **options) do |ndvi_dataset|
          ndvi_dataset.geo_transform = geo_transform
          ndvi_dataset.projection = projection

          ndvi_band = ndvi_dataset.raster_band(1)
          ndvi_band.write_xy_narray(the_array)
          ndvi_band.no_data_value = no_data_value
        end

        ndvi.close

        ndvi
      end

      # Extracts the NIR band and writes to a new file.  NOTE: be sure to close
      # the dataset object that gets returned or your data will not get written
      # to the file.
      #
      # @param destination [String] The destination file path.
      # @param band_number [Fixnum] The number of the band that is the NIR band.
      #   Remember that raster bands are 1-indexed, not 0-indexed.
      # @param driver_name [String] the GDAL::Driver short name to use for the
      #   new dataset.
      # @param output_data_type [FFI::GDAL::DataType] Resulting dataset will be
      #   in this data type. Defaults to use the current data type.
      # @param options [Hash] Options that get used for creating the new NDVI
      #   dataset. See docs for GDAL::Driver#create_dataset.
      # @return [GDAL::Dataset] The new NIR dataset. *Be sure to call #close on
      #   this object or the data may not persist!*
      def extract_nir(destination, band_number, driver_name: 'GTiff', output_data_type: nil, **options)
        original_nir_band = raster_band(band_number)
        raise InvalidBandNumber, "Band #{band_number} found but was nil." if original_nir_band.nil?

        output_data_type ||= original_nir_band.data_type
        driver = GDAL::Driver.by_name(driver_name)

        nir = driver.create_dataset(destination, raster_x_size, raster_y_size,
          data_type: output_data_type, **options) do |nir_dataset|
          nir_dataset.geo_transform = geo_transform
          nir_dataset.projection = projection

          nir_band = nir_dataset.raster_band(1)
          original_nir_band.copy_whole_raster(nir_band)
        end

        nir.close

        nir
      end

      # Extracts the RGB bands and writes to a new file.  NOTE: this closes the
      # dataset to ensure all data and metadata have  been flushed to disk. To
      # work with the file, you'll need to reopen it.
      #
      # @param destination [String] The destination file path.
      # @param red_band_number [Fixnum]
      # @param green_band_number [Fixnum]
      # @param blue_band_number [Fixnum]
      # @param driver_name [String] the GDAL::Driver short name to use for the
      #   new dataset.
      # @param output_data_type [FFI::GDAL::DataType] Resulting dataset will be
      #   in this data type. Defaults to use the current data type.
      # @param options [Hash] Options that get used for creating the new NDVI
      #   dataset. See docs for GDAL::Driver#create_dataset.
      # @return [GDAL::Dataset]
      def extract_natural_color(destination, red_band_number, green_band_number, blue_band_number,
        driver_name: 'GTiff', output_data_type: nil, **options)
        original_bands = {
          red: raster_band(red_band_number),
          green: raster_band(green_band_number),
          blue: raster_band(blue_band_number)
        }

        output_data_type ||= raster_band(1).data_type
        driver = GDAL::Driver.by_name(driver_name)

        natural_color = driver.create_dataset(destination, raster_x_size, raster_y_size,
          band_count: 3, data_type: output_data_type, **options) do |new_dataset|
          new_dataset.geo_transform = geo_transform
          new_dataset.projection = projection

          new_red_band = new_dataset.raster_band(1)
          original_bands[:red].copy_whole_raster(new_red_band)

          new_green_band = new_dataset.raster_band(2)
          original_bands[:green].copy_whole_raster(new_green_band)

          new_blue_band = new_dataset.raster_band(3)
          original_bands[:blue].copy_whole_raster(new_blue_band)
        end

        natural_color.close

        natural_color
      end

      # @param red_band_array [NArray]
      # @param nir_band_array [NArray]
      # @param no_data_value [Number] Value to represent NODATA.
      # @return [NArray]
      def calculate_ndvi(red_band_array, nir_band_array, no_data_value,
        remove_negatives = false, output_data_type = nil)

        # convert to float32 for calculating
        nir_band_array = nir_band_array.to_type(NArray::DFLOAT)
        red_band_array = red_band_array.to_type(NArray::DFLOAT)

        numerator = nir_band_array - red_band_array
        denominator = nir_band_array + red_band_array
        ndvi = numerator / denominator
        mask = nir_band_array.and(red_band_array).not
        ndvi[mask] = no_data_value

        # Convert to output data type
        final_array = case output_data_type
                      when :GDT_Byte then calculate_ndvi_byte(ndvi)
                      when :GDT_UInt16 then calculate_ndvi_uint16(ndvi)
                      else ndvi # Already in Float32
                      end

        remove_negatives ? remove_negatives_from(final_array, no_data_value) : final_array
      end

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

      # Returns the first raster band for which the block returns true.  Ex.
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

      # @return [GDAL::RasterBand]
      def red_band
        band = find_band do |b|
          b.color_interpretation == :GCI_RedBand
        end

        band.is_a?(GDAL::RasterBand) ? band : nil
      end

      # @return [GDAL::RasterBand]
      def green_band
        band = find_band do |b|
          b.color_interpretation == :GCI_GreenBand
        end

        band.is_a?(GDAL::RasterBand) ? band : nil
      end

      # @return [GDAL::RasterBand]
      def blue_band
        band = find_band do |b|
          b.color_interpretation == :GCI_BlueBand
        end

        band.is_a?(GDAL::RasterBand) ? band : nil
      end

      # @return [GDAL::RasterBand]
      def undefined_band
        band = find_band do |b|
          b.color_interpretation == :GCI_Undefined
        end

        band.is_a?(GDAL::RasterBand) ? band : nil
      end

      # Creates a OGR::SpatialReference object from the dataset's projection.
      #
      # @return [OGR::SpatialReference]
      def spatial_reference
        return @spatial_reference if @spatial_reference

        return nil if projection.empty?

        @spatial_reference = OGR::SpatialReference.new(projection)
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
      # @param band_numbers [Array<Fixnum>,Fixnum] Number of the raster band or
      #   bands from this dataset to vectorize.  Can be a single Fixnum or array
      #   of Fixnums.
      # @return [OGR::DataSource]
      def to_vector(file_name, vector_driver_name, geometry_type: :wkbUnknown,
        layer_name_prefix: 'band_number', band_numbers: [1],
        field_name_prefix: 'field', use_band_masks: true)
        band_numbers = band_numbers.is_a?(Array) ? band_numbers : [band_numbers]
        ogr_driver = OGR::Driver.by_name(vector_driver_name)

        if projection.empty?
          spatial_ref = nil
        else
          spatial_ref = OGR::SpatialReference.new(projection)
          begin
            spatial_ref.auto_identify_epsg!
          rescue
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

          unless band
            raise GDAL::InvalidBandNumber, "Unknown band number: #{band_number}"
          end

          pixel_value_field = layer.feature_definition.field_index(field_name)
          options = { pixel_value_field: pixel_value_field }
          options[:mask_band] = band.mask_band if use_band_masks
          band.polygonize(layer, options)
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
      # @param wkt_srid [Fixnum]
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

      # @return [Hash]
      def as_json(options = nil)
        {
          dataset: {
            driver: driver.long_name,
            file_list: file_list,
            gcp_count: gcp_count,
            gcp_projection: gcp_projection,
            geo_transform: geo_transform.as_json(options),
            projection: projection,
            raster_count: raster_count,
            raster_bands: raster_bands.map(&:as_json),
            spatial_reference: spatial_reference.as_json(options)
          },
          metadata: all_metadata
        }
      end

      # @return [String]
      def to_json(options = nil)
        as_json(options).to_json
      end

      private

      # @param ndvi [NArray]
      # @return [NArray]
      def calculate_ndvi_byte(ndvi)
        ((ndvi + 1) * (255.0 / 2)).to_type(NArray::BYTE)
      end

      # @param ndvi [NArray]
      # @return [NArray]
      def calculate_ndvi_uint16(ndvi)
        ((ndvi + 1) * (65_535.0 / 2)).to_type(NArray::INT)
      end

      # Sets any negative values in the NArray to +replace_with+.
      #
      # @param narray [NArray]
      # @param replace_with [Number] Replace negative values with this. Useful
      #   for setting to a NODATA value.
      # @return [NArray]
      def remove_negatives_from(narray, replace_with)
        narray[narray.lt(0)] = replace_with

        narray
      end
    end
  end
end
