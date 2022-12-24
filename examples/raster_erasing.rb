# frozen_string_literal: true

require 'bundler/setup'
require 'thor'
require 'fileutils'
require 'gdal/dataset'
require 'gdal/raster_band'
require 'gdal/raster_band/algorithm_extensions'

GDAL::Logger.logging_enabled = true

module Examples
  class RasterErasing < ::Thor
    desc 'erase SOURCE DEST', 'Erase (clip) pixels from the center of the first raster band in SOURCE to DEST'
    def erase(source_path, dest_path)
      FileUtils.cp(source_path, dest_path)
      dest_dataset = GDAL::Dataset.open(dest_path, 'w')
      geo_transform = dest_dataset.geo_transform

      raster_band = dest_dataset.raster_band(1)
      extent_polygon = buffer_extent(dest_dataset.extent)

      if extent_polygon.empty?
        raise 'Poorly buffered extent--you should play with these values to get this demo to work.'
      end

      raster_point = OGR::Point.new
      start = Time.now

      raster_band.simple_erase! do |x, y|
        coords = geo_transform.apply_geo_transform(x, y)
        raster_point.set_point(0, coords[:x_geo], coords[:y_geo])
        !raster_point.within? extent_polygon
      end

      dest_dataset.close

      puts "Erased dataset in #{Time.now - start}s. Output at '#{dest_path}'"
    end

    private

    def buffer_extent(extent_polygon)
      buffer_size = if extent_polygon.area > 1
                      extent_polygon.area / -5000
                    else
                      extent_polygon.area / -0.5
                    end

      extent_polygon.buffer(buffer_size)
    end
  end
end

Examples::RasterErasing.start(ARGV)
