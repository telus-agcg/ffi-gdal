# frozen_string_literal: true

require 'bundler/setup'
require 'ffi-gdal'
require 'gdal/gridder'
require 'ogr/data_source'
require 'ogr/spatial_reference'

GDAL::Logger.logging_enabled = true

module Examples
  module Gridding
    class << self
      # IDW Test
      def make_idtap_options
        gridder_options = GDAL::GridderOptions.new(:inverse_distance_to_a_power)

        gridder_options.algorithm_options[:angle] = 10
        gridder_options.algorithm_options[:max_points] = 5
        gridder_options.algorithm_options[:min_points] = 1
        gridder_options.algorithm_options[:no_data_value] = -9999
        gridder_options.algorithm_options[:power] = 2
        gridder_options.algorithm_options[:radius1] = 20
        gridder_options.algorithm_options[:radius2] = 15
        gridder_options.algorithm_options[:smoothing] = 5

        [gridder_options, 'gridded-idtap.tif']
      end

      def make_moving_average_options
        gridder_options = GDAL::GridderOptions.new(:moving_average)

        gridder_options.algorithm_options[:angle] = 20
        gridder_options.algorithm_options[:min_points] = 2
        gridder_options.algorithm_options[:no_data_value] = -9999
        gridder_options.algorithm_options[:radius1] = 20
        gridder_options.algorithm_options[:radius2] = 51

        [gridder_options, 'gridded-ma.tif']
      end

      def make_nearest_neighbor_options
        gridder_options = GDAL::GridderOptions.new(:nearest_neighbor)

        gridder_options.algorithm_options[:angle] = 30
        gridder_options.algorithm_options[:no_data_value] = -9999
        gridder_options.algorithm_options[:radius1] = 20
        gridder_options.algorithm_options[:radius2] = 15

        [gridder_options, 'gridded-nn.tif']
      end

      def make_metric_range_options
        gridder_options = GDAL::GridderOptions.new(:metric_range)

        gridder_options.algorithm_options[:angle] = 30
        gridder_options.algorithm_options[:no_data_value] = -9999
        gridder_options.algorithm_options[:radius1] = 20
        gridder_options.algorithm_options[:radius2] = 15

        [gridder_options, 'gridded-metric-range.tif']
      end

      def make_file(source_layer, file_name, gridder_options)
        start = Time.now

        output_formatter = lambda do |d, _, _|
          print "Duration: #{(Time.now - start).to_i}s\t| #{(d * 100).round(2)}%\r"
          true
        end

        gridder_options.input_field_name = 'STATE_FIPS'
        gridder_options.progress_formatter = output_formatter
        gridder_options.output_size = { width: 1600, height: 1480 }

        gridder = GDAL::Gridder.new(source_layer, file_name, gridder_options)
        gridder.grid!

        puts ''
        puts "Duration for #{file_name}: #{Time.now - start}"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  shp_path = './spec/support/shapefiles/states_21basic'
  ds = OGR::DataSource.open(shp_path, 'r')

  # Inverse Distance To A Power
  gridder_options, output_file_name = Examples::Gridding.make_idtap_options
  puts ''
  Examples::Gridding.make_file(ds.layer(0), output_file_name, gridder_options)

  # Moving Average
  gridder_options, output_file_name = Examples::Gridding.make_moving_average_options
  puts ''
  Examples::Gridding.make_file(ds.layer(0), output_file_name, gridder_options)

  # Nearest Neighbor
  gridder_options, output_file_name = Examples::Gridding.make_nearest_neighbor_options
  puts ''
  Examples::Gridding.make_file(ds.layer(0), output_file_name, gridder_options)

  # Metric Range
  gridder_options, output_file_name = Examples::Gridding.make_metric_range_options
  puts ''
  Examples::Gridding.make_file(ds.layer(0), output_file_name, gridder_options)
end
