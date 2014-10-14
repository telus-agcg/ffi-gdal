require 'json'

module GDAL
  # Methods not originally supplied with GDAL, but enhance it.
  module DatasetExtensions

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
      band = find_band do |band|
        band.color_interpretation == :GCI_RedBand
      end

      band.is_a?(GDAL::RasterBand) ? band : nil
    end

    # @return [GDAL::RasterBand]
    def green_band
      band = find_band do |band|
        band.color_interpretation == :GCI_GreenBand
      end

      band.is_a?(GDAL::RasterBand) ? band : nil
    end

    # @return [GDAL::RasterBand]
    def blue_band
      band = find_band do |band|
        band.color_interpretation == :GCI_BlueBand
      end

      band.is_a?(GDAL::RasterBand) ? band : nil
    end

    # @return [GDAL::RasterBand]
    def undefined_band
      band = find_band do |band|
        band.color_interpretation == :GCI_Undefined
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
    def to_vector(file_name, vector_driver_name, geometry_type: :wkbPolygon,
      layer_name_prefix: 'band_number', band_numbers: [1],
      field_name_prefix: 'field')
      band_numbers = band_numbers.is_a?(Array) ? band_numbers : [band_numbers]

      ogr_driver = OGR::Driver.by_name(vector_driver_name)
      spatial_ref = OGR::SpatialReference.new(projection)
      spatial_ref.auto_identify_epsg!

      data_source = ogr_driver.create_data_source(file_name)
      band_numbers.each_with_index do |band_number, i|
        log "Starting to polygonize raster band #{band_number}..."

        layer_name = "#{layer_name_prefix}-#{band_number}"
        layer = data_source.create_layer(layer_name,
        type: geometry_type,
        spatial_reference: spatial_ref)

        unless layer
          raise OGR::InvalidLayer, "Unable to create layer '#{layer_name}'."
        end

        field_name = "#{field_name_prefix}#{i}"
        layer.create_field(field_name, :OFTInteger)

        band = raster_band(band_number)
        band.no_data_value = -9999

        unless band
          raise GDAL::InvalidBandNumber, "Unknown band number: #{band_number}"
        end

        pixel_value_field = layer.feature_definition.field_index(field_name)
        band.polygonize(layer, pixel_value_field: pixel_value_field)
      end

      if block_given?
        yield data_source
        data_source.close
      end

      data_source
    end

    # Converts the dataset to an in-memory vector, then creates a OGR::Geometry
    # from its extent (i.e. from the boundary of the image).
    #
    # @param from_type [FFI::GDAL::OGRwkbGeometryType] The geometry type to use
    #   for vectorizing the raster.
    # @return [OGR::Geometry] A convex hull geometry.
    def to_geometry
      raster_data_source = to_vector('memory', 'Memory', geometry_type: :wkbLineString)

      raster_data_source.layer(0).geometry_from_extent
    end

    # @param wkt_geometry_string [String]
    # @param wkt_srid [Fixnum]
    # @return [Boolean]
    def contains_geometry?(wkt_geometry_string, wkt_srid=4326)
      source_srs = OGR::SpatialReference.new_from_epsg(wkt_srid)
      source_geometry = OGR::Geometry.create_from_wkt(wkt_geometry_string, source_srs)
      @raster_geometry ||= to_geometry

      coordinate_transformation = OGR::CoordinateTransformation.create(source_srs,
        @raster_geometry.spatial_reference)
      source_geometry.transform!(coordinate_transformation)

      log "raster touches wkt? #{@raster_geometry.touches?(source_geometry)}"
      log "raster contains wkt? #{@raster_geometry.contains?(source_geometry)}"
      log "raster within wkt? #{@raster_geometry.within?(source_geometry)}"
      log "raster crosses wkt? #{@raster_geometry.crosses?(source_geometry)}"
      log "raster overlaps wkt? #{@raster_geometry.overlaps?(source_geometry)}"
      log "raster disjoint wkt? #{@raster_geometry.disjoint?(source_geometry)}"

      @raster_geometry.contains? source_geometry
    end

    # Retrieves pixels from each raster band and converts this to an array of
    # points per pixel.  For example:
    #
    #   # If the arrays for each band look like:
    #   red_band_array = [0, 0, 0]
    #   green_band_array = [10, 10, 10]
    #   blue_band_array = [99, 99, 99]
    #   alpha_band_array = [250, 250, 250]
    #
    #   # This array would look like:
    #   [[0, 10, 99, 250], [0, 10, 99, 250], [0, 10, 99, 250]]
    # @return NArray
    def to_na
      na = NArray.to_na(raster_bands.map { |raster_band| raster_band.to_na })

      na.rot90(3)
    end

    def as_json
      {
        dataset: {
          driver: driver.long_name,
          file_list: file_list,
          gcp_count: gcp_count,
          gcp_projection: gcp_projection,
          geo_transform: geo_transform.as_json,
          projection: projection,
          raster_count: raster_count,
          raster_bands: raster_bands.map(&:as_json),
          spatial_reference: spatial_reference.as_json
        },
        metadata: all_metadata
      }
    end

    def to_json
      as_json.to_json
    end
  end
end
