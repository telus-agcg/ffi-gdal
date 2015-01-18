module GDAL
  module GridTypes
    autoload :InverseDistanceToAPower,
      File.expand_path('grid_types/inverse_distance_to_a_power', __dir__)
    autoload :MovingAverage,
      File.expand_path('grid_types/moving_average', __dir__)
    autoload :NearestNeighbor,
      File.expand_path('grid_types/nearest_neighbor', __dir__)
  end
end
