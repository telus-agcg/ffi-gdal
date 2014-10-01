require_relative 'dataset'

module GDAL
  class Utils
    class << self
    # Computes NDVI from the red and near-infrared bands in the dataset.  Raises
    # a GDAL::RequiredBandNotFound if one of those band types isn't found.
      #
      # @param source [String] Path to the dataset that contains the red and NIR
      #   bands.
      # @param destination [String] Path to output the new dataset to.
      # @param driver_name [String] The type of dataset to create.
      def extract_ndvi(source, destination, driver_name: 'GTiff',
        band_order: nil, clip_to_wkt: nil)
        extract_8bit(source, destination, driver_name, bands: 1, type: :GDT_Byte) do |original, ndvi_dataset|
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

          if original_bands[:red].nil?
            fail RequiredBandNotFound, 'Red band not found.'
          elsif original_bands[:nir].nil?
            fail RequiredBandNotFound, 'Near-infrared'
          end

          if clip_to_wkt
            clip(clip_to_wkt, ndvi_dataset.geo_transform,
              original_bands[:red].to_a, original_bands[:nir].to_a)
          end

          ndvi_array = calculate_ndvi(original_bands[:red].to_a,
            original_bands[:nir].to_a, true)

          ndvi_band = ndvi_dataset.raster_band(1)
          ndvi_band.write_array(ndvi_array)
        end
      end

      def clip(wkt, geo_transform, red_array, nir_array)
        geometry = OGR::Geometry.create_from_wkt(wkt)

        ulx, uly = world_to_pixel(geo_transform, geometry.envelope.min_x,
          geometry.envelope.max_y)
        lrx, lry = world_to_pixel(geo_transform, geometry.envelope.max_x,
          geometry.envelope.min_y)
        puts "min x: #{geometry.envelope.min_x}"
        puts "min y: #{geometry.envelope.min_y}"
        puts "max x: #{geometry.envelope.max_x}"
        puts "max y: #{geometry.envelope.max_y}"
        puts "ulx: #{ulx}"
        puts "uly: #{uly}"
        puts "lrx: #{lrx}"
        puts "lry: #{lry}"

        pixel_width = (lrx - ulx).to_i
        pixel_height = (lry - uly).to_i

        puts "pixel width: #{pixel_width}"
        puts "pixel height: #{pixel_height}"
        # clipped_array = NArray.int(pixel_height, pixel_width)
        # red_clipped = red_array[uly..lry, ulx..lrx]
        # nir_clipped = nir_array[uly..lry, ulx..lrx]

        puts "geo_transform x origin was: #{geo_transform.x_origin}"
        puts "geo_transform y origin was: #{geo_transform.y_origin}"
        geo_transform.x_origin = geometry.envelope.min_x
        geo_transform.y_origin = geometry.envelope.min_y
        puts "geo_transform x origin is now: #{geo_transform.x_origin}"
        puts "geo_transform y origin is now: #{geo_transform.y_origin}"

        points = geometry.points_array
        puts "points: #{points}"
        pixels = points.map do |x, y|
          world_to_pixel(geo_transform, x, y)
        end
        puts "pixels: #{pixels}"
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

          the_array = calculate_ndvi(green.to_a, nir.to_a, true)

          gndvi_band = gndvi_dataset.raster_band(1)
          gndvi_band.write_array(the_array)

          red_band = gndvi_dataset.raster_band(2)
          #red_band.write_array(red)
          red_band.write_array(original.raster_band(2).to_a)

          green_band = gndvi_dataset.raster_band(3)
          #green_band.write_array(green)
          green_band.write_array(original.raster_band(3).to_a)

          blue_band = gndvi_dataset.raster_band(4)
          #blue_band.write_array(blue)
          blue_band.write_array(original.raster_band(4).to_a)
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
          new_red_band.write_array(original_bands[:red].to_a)
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
          new_red_band.write_array(original_bands[:green].to_a)

          new_green_band = new_dataset.raster_band(2)
          new_green_band.write_array(original_bands[:blue].to_a)

          new_blue_band = new_dataset.raster_band(3)
          new_blue_band.write_array(original_bands[:nir].to_a)
        end
      end

      # @param red_band_array [NArray]
      # @param nir_band_array [NArray]
      # @return [NArray]
      def calculate_ndvi(red_band_array, nir_band_array, remove_negatives=false)
        ndvi = (nir_band_array - red_band_array) / (nir_band_array + red_band_array)

        return ndvi unless remove_negatives

        # Zero out
        i = 0
        ndvi.each do |_|
          ndvi[i] = 0 if ndvi[i] < 0
          i += i
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
      # TODO: Maybe this should belong to GDAL::GeoTransform?
      def world_to_pixel(geo_transform, x, y)
        pixel = ((x - geo_transform.x_origin) / geo_transform.pixel_width)
        line = ((geo_transform.y_origin - y) / geo_transform.pixel_height)

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
