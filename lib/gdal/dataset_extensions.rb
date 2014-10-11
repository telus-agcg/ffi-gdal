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

        pixel_value_field = layer.definition.field_index(field_name)
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
    def to_geometry(from_type: :wkbMultiLineString)
      raster_data_source = to_vector('memory', 'Memory', geometry_type: from_type)

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

      log "raster within wkt? #{@raster_geometry.within?(source_geometry)}"
      log "raster contains wkt? #{@raster_geometry.contains?(source_geometry)}"
      log "raster touches wkt? #{@raster_geometry.touches?(source_geometry)}"
      log "raster crosses wkt? #{@raster_geometry.crosses?(source_geometry)}"
      log "raster overlaps wkt? #{@raster_geometry.overlaps?(source_geometry)}"
      log "wkt within raster? #{source_geometry.within?(@raster_geometry)}"
      log "wkt contains raster? #{source_geometry.contains?(@raster_geometry)}"
      log "wkt touches raster? #{source_geometry.touches?(@raster_geometry)}"
      log "wkt crosses raster? #{source_geometry.crosses?(@raster_geometry)}"
      log "wkt overlaps raster? #{source_geometry.overlaps?(@raster_geometry)}"

      @raster_geometry.contains? source_geometry
    end
  end
end
