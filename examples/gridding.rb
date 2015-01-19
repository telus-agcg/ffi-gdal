require 'bundler/setup'
require 'pry'
require 'ffi-gdal'


GDAL::Logger.logging_enabled = true

test_points_file = File.expand_path('points.txt', __dir__)
test_points = File.read(test_points_file).split.map { |point_group| point_group.split(',').map(&:to_f) }

output_formatter = lambda do |d, _, _|
  print "#{Time.now}: #{(d * 100).round(2)}%\r"
  true
end

# IDW Test
def idtap(test_points)
  grid = GDAL::Grid.new(:inverse_distance_to_a_power, data_type: :GDT_Float32)
  grid.points = NArray[*test_points]

  grid.options[:angle] = 10
  # grid.options[:max_points] = 5
  # grid.options[:min_points] = 1
  grid.options[:no_data_value] = -9999
  grid.options[:power] = 2
  grid.options[:radius1] = 20
  grid.options[:radius2] = 15
  grid.options[:smoothing] = 5

  [grid, 'gridded-idtap.tif']
end

def moving_average(test_points)
  grid = GDAL::Grid.new(:moving_average, data_type: :GDT_Float32)
  grid.points = NArray[*test_points]

  grid.options[:angle] = 20
  grid.options[:min_points] = 2
  grid.options[:no_data_value] = -9999
  grid.options[:radius1] = 20
  grid.options[:radius2] = 51

  [grid, 'gridded-ma.tif']
end

def nearest_neighbor(test_points)
  grid = GDAL::Grid.new(:nearest_neighbor, data_type: :GDT_Float32)
  grid.points = NArray[*test_points]

  grid.options[:angle] = 30
  grid.options[:no_data_value] = -9999
  grid.options[:radius1] = 20
  grid.options[:radius2] = 15

  [grid, 'gridded-nn.tif']
end

def metric_range(test_points)
  grid = GDAL::Grid.new(:metric_range, data_type: :GDT_Float32)
  grid.points = NArray[*test_points]

  grid.options[:angle] = 30
  # grid.options[:no_data_value] = -9999
  grid.options[:radius1] = 20
  grid.options[:radius2] = 15
  [grid, 'gridded-metric-range.tif']
end

def make_file(file_name, grid, data)
  driver = GDAL::Driver.by_name('GTiff')
  dataset = driver.create_dataset(
    file_name,
    grid.x_size.round.to_i,
    grid.y_size.round.to_i,
    data_type: grid.data_type
  )

  dataset.geo_transform = grid.geo_transform
  dataset.projection = OGR::SpatialReference.new_from_epsg(32632).to_wkt

  dataset.raster_io('w', data, data_type: grid.data_type)
  if grid.options[:no_data_value]
    dataset.raster_band(1).no_data_value = grid.options[:no_data_value]
  end
  dataset.close
  puts "\nDone writing #{file_name}"
end

grid, output_file_name = idtap(test_points)
output = grid.create(&output_formatter)
puts ''
make_file(output_file_name, grid, output)

grid, output_file_name = moving_average(test_points)
output = grid.create(&output_formatter)
puts ''
make_file(output_file_name, grid, output)

grid, output_file_name = nearest_neighbor(test_points)
output = grid.create(&output_formatter)
puts ''
make_file(output_file_name, grid, output)

grid, output_file_name = metric_range(test_points)
output = grid.create(&output_formatter)
puts ''
make_file(output_file_name, grid, output)
