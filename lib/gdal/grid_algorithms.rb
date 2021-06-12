# frozen_string_literal: true

require_relative '../ffi-gdal'

module GDAL
  module GridAlgorithms
    extend FFI::InternalHelpers

    autoload :InverseDistanceToAPower,  autoload_path('grid_algorithms/inverse_distance_to_a_power')
    autoload :MetricAverageDistance,    autoload_path('grid_algorithms/metric_average_distance')
    autoload :MetricAverageDistancePts, autoload_path('grid_algorithms/metric_average_distance_pts')
    autoload :MetricCount,              autoload_path('grid_algorithms/metric_count')
    autoload :MetricMaximum,            autoload_path('grid_algorithms/metric_maximum')
    autoload :MetricMinimum,            autoload_path('grid_algorithms/metric_minimum')
    autoload :MetricRange,              autoload_path('grid_algorithms/metric_range')
    autoload :MovingAverage,            autoload_path('grid_algorithms/moving_average')
    autoload :NearestNeighbor,          autoload_path('grid_algorithms/nearest_neighbor')
  end
end
