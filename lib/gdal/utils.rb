require_relative 'dataset'
require_relative '../ogr/coordinate_transformation'

module GDAL
  class Utils
    class << self
      include GDAL::Logger

      # Computes NDVI from the red and near-infrared bands in the dataset.  Raises
      # a GDAL::RequiredBandNotFound if one of those band types isn't found.
      #
      # @param source [String] Path to the dataset that contains the red and NIR
      #   bands.
      # @param destination [String] Path to output the new dataset to.
      # @param driver_name [String] The type of dataset to create.
      def extract_ndvi(source, destination, driver_name: 'GTiff', band_order: nil, clip_to_wkt: nil)
        driver = GDAL::Driver.by_name(driver_name)
        source_dataset = GDAL::Dataset.open(source, 'r')

        # Try to get bands by order
        original_bands = if band_order
          bands_by_order(band_order, source_dataset)
        else
          {
            red: source_dataset.red_band,
            green: source_dataset.green_band,
            blue: source_dataset.blue_band,
            nir: source_dataset.undefined_band
          }
        end

        if original_bands[:red].nil?
          fail RequiredBandNotFound, 'Red band not found.'
        elsif original_bands[:nir].nil?
          fail RequiredBandNotFound, 'Near-infrared'
        end

        red_array = original_bands[:red].to_na
        nir_array = original_bands[:nir].to_na

        if clip_to_wkt
          # create geometry from the wkt_geometry
          wkt_spatial_ref = OGR::SpatialReference.new
          wkt_spatial_ref.from_epsg(4326)

          destination_geometry = OGR::Geometry.create_from_wkt(clip_to_wkt, wkt_spatial_ref)
          GDAL.log "geometry spatial reference: #{destination_geometry.spatial_reference.to_wkt}"

          # reproject new dataset to use projection from original dataset
          target_spatial_ref = OGR::SpatialReference.new(source_dataset.projection)
          coordinate_transformation = OGR::CoordinateTransformation.create(wkt_spatial_ref,
            target_spatial_ref)

          destination_geometry.transform(coordinate_transformation)

          # Get geometry extent
          destination_boundary = destination_geometry.boundary.to_line_string
          #destination_points = NArray[destination_boundary.points_array]
          x_min = destination_boundary.envelope.x_min
          x_max = destination_boundary.envelope.x_max
          y_min = destination_boundary.envelope.y_min
          y_max = destination_boundary.envelope.y_max
          GDAL.log "min x: #{x_min}"
          GDAL.log "min y: #{y_min}"
          GDAL.log "max x: #{x_max}"
          GDAL.log "max y: #{y_max}"

          # Specify offset and rows and columns to read
          x_offset = ((x_min - source_dataset.geo_transform.x_origin) / source_dataset.geo_transform.pixel_width).to_i
          y_offset = ((source_dataset.geo_transform.y_origin - y_max) / source_dataset.geo_transform.pixel_width).to_i
          # x_offset, y_offset = world_to_pixel(source_dataset.geo_transform,
          #   x_min, y_max)
          x_count = ((x_max - x_min) / source_dataset.geo_transform.pixel_width).to_i + 1
          y_count = ((y_max - y_min) / source_dataset.geo_transform.pixel_width).to_i + 1
          # x_count, y_count = world_to_pixel(source_dataset.geo_transform,
          #   x_max, y_min)
          GDAL.log "x_offset: #{x_offset}"
          GDAL.log "y_offset: #{y_offset}"
          GDAL.log "x_count: #{x_count}"
          GDAL.log "y_count: #{y_count}"
          # Adding these to handle the case where the WKT geometry extends
          # outside of the bounds of the source image.
          width = x_offset + x_count
          height = y_offset + y_count
          GDAL.log "width #{width}"
          GDAL.log "height #{height}"
          GDAL.log "geometry envelope x: #{destination_boundary.envelope.x_min}"
          GDAL.log "geometry envelope y: #{destination_boundary.envelope.y_min}"

          binding.pry

          driver.create_dataset(destination, width, height, bands: 1, type: :GDT_Byte) do |ndvi_dataset|
            GDAL.log "x_offset2: #{ndvi_dataset.geo_transform.apply_geo_transform(x_min, y_max)}"
            ndvi_dataset.projection = source_dataset.projection
            ndvi_dataset.geo_transform = source_dataset.geo_transform
            # ndvi_dataset.geo_transform = GDAL::GeoTransform.new(ndvi_dataset)
            ndvi_dataset.geo_transform.x_origin = x_offset
            ndvi_dataset.geo_transform.y_origin = y_offset
            # ndvi_dataset.geo_transform.pixel_width = source_dataset.geo_transform.pixel_width
            # ndvi_dataset.geo_transform.pixel_height = source_dataset.geo_transform.pixel_height
            # ndvi_dataset.geo_transform.x_rotation = source_dataset.geo_transform.x_rotation
            # ndvi_dataset.geo_transform.y_rotation = source_dataset.geo_transform.y_rotation

            GDAL.log "geo_transform x origin is now: #{ndvi_dataset.geo_transform.x_origin}"
            GDAL.log "geo_transform y origin is now: #{ndvi_dataset.geo_transform.y_origin}"
            GDAL.log "geo_transform pixel width is now: #{ndvi_dataset.geo_transform.pixel_width}"
            GDAL.log "geo_transform pixel height is now: #{ndvi_dataset.geo_transform.pixel_height}"
            GDAL.log "geo_transform x rotation is now: #{ndvi_dataset.geo_transform.x_rotation}"
            GDAL.log "geo_transform y rotation is now: #{ndvi_dataset.geo_transform.y_rotation}"

            source_dataset_spatial_ref = OGR::SpatialReference.new(source_dataset.projection)
            ndvi_dataset.projection = source_dataset_spatial_ref.to_wkt
            ndvi_band = ndvi_dataset.raster_band(1)

            # raster zone polygon to raster
            #ndvi_dataset.rasterize_geometries(1, destination_geometry, 350, all_touched: 'TRUE')

            # Create blank image of the correct size
            base_array = NArray.float(width, height)
            # clipped_array = NArray.int(pixel_height, pixel_width)
            red_clipped = red_array[y_offset...height, x_offset...width]
            nir_clipped = nir_array[y_offset...height, x_offset...width]
            ndvi_array = calculate_ndvi(red_clipped, nir_clipped, true)
            GDAL.log "ndvi x size: #{ndvi_array.shape.first}"
            GDAL.log "ndvi y size: #{ndvi_array.shape.last}"

            #points = destination_boundary.points_array
            # pixels = points.map do |x, y|
            #   x_pixel, y_pixel = world_to_pixel(ndvi_dataset.geo_transform, x, y)
            #   puts "x_pixel: #{x_pixel}"
            #   x_pixel
            # end

            #ndvi_band.write_array(ndvi_array)
            ndvi_band.write_array(clipped_ndvi_array)
            #ndvi_band.write_array(base_array)
            #ndvi_band.write_array(NArray.int(width, height).random(5000))
            pixels = 650
            ndvi_dataset.rasterize_geometries(1, destination_geometry, pixels)
            #ndvi_band.no_data_value = 500
          end
        else
          driver.create_dataset(destination, source_dataset.raster_x_size,
            source_dataset.raster_y_size, bands: 1, type: :GDT_Byte) do |ndvi_dataset|

            new_dataset.geo_transform = geo_transform
            new_dataset.projection = projection

            ndvi_band = ndvi_dataset.raster_band(1)
            #ndvi_band.no_data_value = -9999
            ndvi_band.write_array(ndvi_array)
          end
        end
      end

      def extract_gndvi(source, destination, driver_name: 'GTiff')
        extract_8bit(source, destination, driver_name) do |original, gndvi_dataset|
          green = original.green_band
          nir = original.undefined_band

          if green.nil?
            fail RequiredBandNotFound, 'Green band not found.'
          elsif nir.nil?
            fail RequiredBandNotFound, 'Near-infrared'
          end

          the_array = calculate_ndvi(green.to_na, nir.to_na, true)

          gndvi_band = gndvi_dataset.raster_band(1)
          gndvi_band.write_array(the_array)

          red_band = gndvi_dataset.raster_band(2)
          #red_band.write_array(red)
          red_band.write_array(original.raster_band(2).to_na)

          green_band = gndvi_dataset.raster_band(3)
          #green_band.write_array(green)
          green_band.write_array(original.raster_band(3).to_na)

          blue_band = gndvi_dataset.raster_band(4)
          #blue_band.write_array(blue)
          blue_band.write_array(original.raster_band(4).to_na)
        end
      end

      def extract_nir(source, destination,
        driver_name: 'GTiff',
        band_order: %i[nir red green blue])
        extract_8bit(source, destination, driver_name, bands: 1) do |original, nir_dataset|
          nir = original.undefined_band
          fail RequiredBandNotFound, 'Near-infrared' if nir.nil?

          original_bands = bands_by_order(band_order, original)

          new_red_band = nir_dataset.raster_band(1)
          new_red_band.write_array(original_bands[:red].to_na)
        end
      end

      # @param source [String] The file path of the source dataset to extract
      #   from.
      # @param destination [String] The destination file path to write the new
      #   dataset to.
      # @param driver_name [String] The name of the GDAL driver to use for
      #   creating the new dataset.
      # @param band_order [Array<Symbol>] The order of the bands in the source
      #   dataset.
      # @return [GDAL::Dataset] The newly created dataset.
      def extract_natural_color(source, destination,
        driver_name: 'GTiff',
        band_order: nil)
        original = GDAL::Dataset.open(source, 'r')
        geo_transform = original.geo_transform
        projection = original.projection

        rows = original.raster_y_size
        columns = original.raster_x_size

        driver = GDAL::Driver.by_name(driver_name)

        driver.create_dataset(destination, columns, rows, bands: 3,
        type: :GDT_Float32, photometric: 'RGB') do |new_dataset|
          new_dataset.geo_transform = geo_transform
          new_dataset.projection = projection

          original_bands = if band_order
            bands_by_order(band_order, original)
          else
            {
              red: original.red_band,
              green: original.green_band,
              blue: original.blue_band,
              nir: original.undefined_band
            }
          end

          new_red_band = new_dataset.raster_band(1)
          new_red_band.write_array(original_bands[:green].to_na)

          new_green_band = new_dataset.raster_band(2)
          new_green_band.write_array(original_bands[:blue].to_na)

          new_blue_band = new_dataset.raster_band(3)
          new_blue_band.write_array(original_bands[:nir].to_na)
        end
      end

      # @param red_band_array [NArray]
      # @param nir_band_array [NArray]
      # @return [NArray]
      def calculate_ndvi(red_band_array, nir_band_array, remove_negatives=false)
        ndvi = (nir_band_array - red_band_array) / (nir_band_array + red_band_array)

        return ndvi unless remove_negatives

        # Zero out
        0.upto(ndvi.size - 1) do |i|
          ndvi[i] = 0 if ndvi[i] < 0
        end

        ndvi
      end

      # Adapted from "Advanced Geospatial Python Modeling".  Calculates the
      # pixel location of a geospatial coordinate.
      #
      # @param geo_transform [GDAL::GeoTransform]
      # @param x [Fixnum]
      # @param y [Fixnum]
      # @return [Array<Fixnum, Fixnum>] [pixel, line]
      # TODO: Use GDAL::GeoTransform#apply_geotransform
      def world_to_pixel(geo_transform, x, y)
        pixel = ((x - geo_transform.x_origin) / geo_transform.pixel_width).to_i
        line = ((geo_transform.y_origin - y) / geo_transform.pixel_width).to_i

        [pixel, line]
      end

      #---------------------------------------------------------------------------
      # Privates
      #---------------------------------------------------------------------------

      def bands_by_order(band_color_list, dataset)
        band_color_list.each_with_object({}).each_with_index do |(band_color_interp, obj), i|
          obj[band_color_interp] = dataset.raster_band(i + 1)
        end
      end

      def extract_8bit(source, destination, driver_name, bands: 1, type: :GDT_Float32, **options)
        dataset = GDAL::Dataset.open(source, 'r')
        geo_transform = dataset.geo_transform
        projection = dataset.projection
        rows = dataset.raster_y_size
        columns = dataset.raster_x_size

        driver = GDAL::Driver.by_name(driver_name)
        driver.create_dataset(destination, columns, rows, bands: bands, type: type, **options) do |new_dataset|
          new_dataset.geo_transform = geo_transform
          new_dataset.projection = projection

          yield dataset, new_dataset
        end
      end
    end
  end
end
