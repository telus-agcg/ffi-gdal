require_relative 'driver'

module GDAL
  # NOT YET WORKING!
  #
  # Port from gdal_merge.py, this lets you programmatically merge datasets.
  class Merger
    # @param [String] output_driver_name
    # @param [String] output_file_name
    # @param [Symbol] output_data_type
    # @param [Array<GDAL::Dataset>] datasets
    # @param [Hash] creation_options
    def initialize(output_driver_name, output_file_name, output_data_type, datasets, **creation_options)
      @output_driver = Driver.by_name(output_driver_name)
      @output_file_name = output_file_name
      @output_data_type = output_data_type
      @datasets = datasets
      @creation_options = creation_options
    end

    # @return [GDAL::Dataset]
    def merge(target_align_pixels: false)
      dest_geo_transform = build_geo_transform(target_align_pixels)
      dest_dataset = build_empty_dataset(dest_geo_transform)
      calculate_dimensions(dest_dataset)
    end

    private

    def calculate_dimensions(dest_dataset)
      @datasets.map.with_index do |d, _i|
        dest_ulx = [dest_dataset.geo_transform.x_origin, d.geo_transform.x_origin].max
        dest_lrx = [dest_dataset.lower_right_x, d.lower_right_x].min

        uly_candidates = [dest_dataset.geo_transform.y_origin, d.geo_transform.y_origin]
        lry_candidates = [dest_dataset.lower_right_y, d.lower_right_y]

        if dest_dataset.geo_transform.y_origin < 0
          dest_uly = uly_candidates.min
          dest_lry = lry_candidates.max
        else
          dest_uly = uly_candidates.max
          dest_lry = lry_candidates.min
        end

        dest_offsets = dest_dataset.geo_transform.world_to_pixel(dest_ulx, dest_uly, 0.1)
        dest_sizes = dest_dataset.geo_transform.world_to_pixel(dest_lrx, dest_lry, 0.5)
        dest_x_size = dest_sizes[:pixel] - dest_offsets[:pixel]
        dest_y_size = dest_sizes[:line] - dest_offsets[:line]

        src_offsets = d.geo_transform.world_to_pixel(dest_ulx, dest_uly)
        src_sizes = d.geo_transform.world_to_pixel(dest_lrx, dest_lry, 0.5)
        src_x_size = src_sizes[:pixel] - src_offsets[:pixel]
        src_y_size = src_sizes[:line] - src_offsets[:line]

        {
          dest_x_offset: dest_offsets[:pixel],
          dest_y_offset: dest_offsets[:line],
          dest_x_size: dest_x_size,
          dest_y_size: dest_y_size,
          src_x_offset: src_offsets[:pixel],
          src_y_offset: src_offsets[:line],
          src_x_size: src_x_size,
          src_y_size: src_y_size
        }
      end
    end

    # @return [GDAL::GeoTransform]
    def build_geo_transform(target_align_pixels)
      gt = GDAL::GeoTransform.new

      gt.x_origin = overall_x_origin
      gt.y_origin = overall_y_origin

      first_transform = @datasets.first.geo_transform
      gt.pixel_width = first_transform.pixel_width    # psize_x
      gt.pixel_height = first_transform.pixel_height  # psize_y
      gt.x_rotation = first_transform.x_rotation
      gt.y_rotation = first_transform.y_rotation

      gt.align! if target_align_pixels

      gt
    end

    # @param [GDAL::GeoTransform] geo_transform
    def build_empty_dataset(geo_transform)
      x_size = x_size(geo_transform, overall_lower_x)
      y_size = x_size(geo_transform, overall_lower_y)
      data_type = @output_data_type

      dataset = @output_driver.create_dataset(@output_file_name, x_size, y_size, data_type: data_type)
      dataset.geo_transform = geo_transform
      dataset.projection = @datasets.first.projection
      dataset
      # new_band = dataset.raster_band(1)
      # new_band.write_xy_narray(raster_band.to_na)

      # @datasets.each do |d|
      #   dataset.raster_band(1).copy_whole_raster(new_band)
      #   new_band.write_xy_narray(dataset.raster_band(1).to_na)
      # end
    end

    def overall_x_origin
      @datasets.map { |dataset| dataset.geo_transform.x_origin }.min
    end

    def overall_y_origin
      @datasets.map { |dataset| dataset.geo_transform.y_origin }.max
    end

    def overall_lower_x
      @datasets.map(&:lower_right_x).max
    end

    def overall_lower_y
      @datasets.map(&:lower_right_y).min
    end

    def x_size(geo_transform, lower_right_x)
      ((lower_right_x - geo_transform.x_origin) / geo_transform.pixel_width + 0.5).to_i
    end

    def y_size(geo_transform, lower_right_y)
      ((lower_right_y - geo_transform.y_origin) / geo_transform.pixel_height + 0.5).to_i
    end
  end
end
