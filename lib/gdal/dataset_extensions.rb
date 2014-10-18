require 'json'

module GDAL
  # Methods not originally supplied with GDAL, but enhance it.
  module DatasetExtensions

    # Computes NDVI from the red and near-infrared bands in the dataset.  Raises
    # a GDAL::RequiredBandNotFound if one of those band types isn't found.
    #
    # @param destination [String] Path to output the new dataset to.
    # @param driver_name [String] The type of dataset to create.
    # @param band_order [Array<String>] The list of band types, i.e. ['red',
    #   'green', 'blue'].
    def extract_ndvi(destination, driver_name: 'GTiff', band_order: nil, data_type: :GDT_Float32)
      original_bands = if band_order
        bands_with_labels(band_order)
      else
        {
          red: red_band,
          green: green_band,
          blue: blue_band,
          nir: undefined_band
        }
      end

      red = original_bands[:red]
      nir = original_bands[:nir]

      if red.nil?
        fail RequiredBandNotFound, 'Red band not found.'
      elsif nir.nil?
        fail RequiredBandNotFound, 'Near-infrared'
      end

      the_array = calculate_ndvi(red.to_na(:GDT_Float32), nir.to_na(:GDT_Float32), 0.0)

      driver = GDAL::Driver.by_name(driver_name)
      dataset = driver.create_dataset(destination, raster_x_size, raster_y_size, data_type: data_type) do |ndvi_dataset|
        ndvi_dataset.geo_transform = geo_transform
        ndvi_dataset.projection = projection

        ndvi_band = ndvi_dataset.raster_band(1)
        ndvi_band.write_array(the_array, data_type: data_type)
        ndvi_band.no_data_value = -9999.0
      end
    end

    # Computes GNDVI from the green and near-infrared bands in the dataset.
    # Raises a GDAL::RequiredBandNotFound if one of those band types isn't
    # found.
    #
    # @param destination [String] Path to output the new dataset to.
    # @param driver_name [String] The type of dataset to create.
    # @param band_order [Array<String>] The list of band types, i.e. ['red',
    #   'green', 'blue'].
    def extract_gndvi(destination, driver_name: 'GTiff', band_order: nil, data_type: :GDT_Float32)
      original_bands = if band_order
        bands_with_labels(band_order)
      else
        {
          red: red_band,
          green: green_band,
          blue: blue_band,
          nir: undefined_band
        }
      end

      green = original_bands[:green]
      nir = original_bands[:nir]

      if green.nil?
        fail RequiredBandNotFound, 'Green band not found.'
      elsif nir.nil?
        fail RequiredBandNotFound, 'Near-infrared'
      end

      the_array = calculate_ndvi(green.to_na(:GDT_Float32), nir.to_na(:GDT_Float32), 0.0)

      driver = GDAL::Driver.by_name(driver_name)
      driver.create_dataset(destination, raster_x_size, raster_y_size, data_type: data_type) do |gndvi_dataset|
        gndvi_dataset.geo_transform = geo_transform
        gndvi_dataset.projection = projection

        gndvi_band = gndvi_dataset.raster_band(1)
        gndvi_band.write_array(the_array, data_type: data_type)
        gndvi_band.no_data_value = -9999.0
      end
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
    # @return [GDAL::Dataset]
    def extract_nir(destination, band_number, driver_name: 'GTiff', data_type: :GDT_Byte)
      driver = GDAL::Driver.by_name(driver_name)
      nir = raster_band(band_number)

      driver.create_dataset(destination, raster_x_size, raster_y_size, data_type: data_type) do |nir_dataset|
        nir_dataset.geo_transform = geo_transform
        nir_dataset.projection = projection

        nir_band = nir_dataset.raster_band(1)
        nir_band.write_array(nir.readlines)
      end
    end

    # Extracts the RGB bands and writes to a new file.  NOTE: be sure to close
    # the dataset object that gets returned or your data will not get written
    # to the file.
    #
    # @param destination [String] The destination file path.
    # @param driver_name [String] the GDAL::Driver short name to use for the
    #   new dataset.
    # @param band_order [Array<String>] The list of band types, i.e. ['red',
    #   'green', 'blue'].
    # @return [GDAL::Dataset]
    def extract_natural_color(destination, driver_name: 'GTiff', band_order: nil)
      rows = raster_y_size
      columns = raster_x_size
      driver = GDAL::Driver.by_name(driver_name)

      original_bands = if band_order
        bands_with_labels(band_order)
      else
        {
          red: red_band,
          green: green_band,
          blue: blue_band
        }
      end

      driver.create_dataset(destination, columns, rows, bands: 3) do |new_dataset|
        new_dataset.geo_transform = geo_transform
        new_dataset.projection = projection

        new_red_band = new_dataset.raster_band(1)
        new_red_band.write_array(original_bands[:red].readlines)

        new_green_band = new_dataset.raster_band(2)
        new_green_band.write_array(original_bands[:green].readlines)

        new_blue_band = new_dataset.raster_band(3)
        new_blue_band.write_array(original_bands[:blue].readlines)
      end
    end

    # @param red_band_array [NArray]
    # @param nir_band_array [NArray]
    # @param remove_negatives [Fixnum] Value to replace negative values with.
    # @return [NArray]
    def calculate_ndvi(red_band_array, nir_band_array, remove_negatives=nil)
      #ndvi = 1.0 * (nir_band_array - red_band_array) / (nir_band_array + red_band_array)
      ndvi = (nir_band_array - red_band_array) / (nir_band_array + red_band_array)

      # Remove NaNs
      0.upto(ndvi.size - 1) do |i|
        ndvi[i] = 0 if ndvi[i].is_a?(Float) && ndvi[i].nan?
      end

      return ndvi unless remove_negatives

      # Zero out
      0.upto(ndvi.size - 1) do |i|
        ndvi[i] = remove_negatives if ndvi[i] < 0
      end

      ndvi
    end

    # Map raster bands to a label, as a hash.  Useful for when bands don't match
    # the color_interpretation that's returned from GDAL.  This simply maps the
    # list of labels you pass in to the raster bands.
    #
    # Valid labels:
    #   * Near-infrared: 'N', :nir
    #   * Red: 'R', :red
    #   * Green: 'G', :green
    #   * Blue: 'B', :blue
    #   * Alpha: 'A', :alpha
    #
    # @param order [Array<Object>]
    # @return [Hash{<Object> => GDAL::RasterBand}]
    def bands_with_labels(order)
      order.each_with_object({}).each_with_index do |(band_label, obj), i|
        label = case band_label.to_s
        when 'N', 'nir' then :nir
        when 'R', 'red' then :red
        when 'G', 'green' then :green
        when 'B', 'blue' then :blue
        else
          band_label
        end

        obj[label] = raster_band(i + 1)
      end
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
        layer = data_source.create_layer(layer_name, geometry_type: geometry_type,
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
    # @return [OGR::Geometry] A convex hull geometry.
    def to_geometry
      raster_data_source = to_vector('memory', 'Memory', geometry_type: :wkbLinearRing)

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

      @raster_geometry.contains? source_geometry
    end

    def image_warp(destination_file, driver, band_numbers, **warp_options)
      raise NotImplementedError, '#image_warp not yet implemented.'

      options_ptr = GDAL::Options.pointer(warp_options)
      driver = GDAL::Driver.by_name(driver)
      destination_dataset = driver.create_dataset(destination_file, raster_x_size, raster_y_size)

      band_numbers = band_numbers.is_a?(Array) ? band_numbers : [band_numbers]
      log "band numbers: #{band_numbers}"

      bands_ptr = FFI::MemoryPointer.new(:pointer, band_numbers.size)
      bands_ptr.write_array_of_int(band_numbers)
      log "band numbers ptr null? #{bands_ptr.null?}"

      warp_options_struct = FFI::GDAL::GDALWarpOptions.new

      warp_options.each do |k, _|
        warp_options_struct[k] = warp_options[k]
      end

      warp_options[:source_dataset] = c_pointer
      warp_options[:destination_dataset] = destination_dataset.c_pointer
      warp_options[:band_count] = band_numbers.size
      warp_options[:source_bands] = bands_ptr
      warp_options[:transformer] = transformer
      warp_options[:transformer_arg] = transformer_arg

      log "transformer: #{transformer}"
      error_threshold = 0.0
      order = 0

      transformer_ptr = FFI::GDAL.GDALCreateGenImgProjTransformer(@dataset_pointer,
        projection,
        destination_dataset.c_pointer,
        destination.projection,
        false,
        error_threshold,
        order)

      warp_operation = GDAL::WarpOperation.new(warp_options)
      warp_operation.chunk_and_warp_image(0, 0, raster_x_size, raster_y_size)
      transformer.destroy!
      warp_operation.destroy!

      destination = GDAL::Dataset.new(destination_dataset_ptr)
      destination.close

      destination
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
