# frozen_string_literal: true

require 'gdal/extensions/gridder'
require 'ogr/data_source'

RSpec.describe 'GDAL::Gridder', type: :integration do
  let(:shapefile_path) { File.expand_path('../../../spec/support/shapefiles/states_21basic', __dir__) }
  let(:source_data_source) { OGR::DataSource.open(shapefile_path, 'r') }
  let(:source_layer) { source_data_source.layer(0) }
  let(:dataset) { GDAL::Dataset.open(output_file_name, 'w', shared: true) }

  after do
    source_data_source.close if source_data_source.c_pointer
    dataset.close if File.exist?(output_file_name)

    Dir.glob("#{output_file_name}*").each do |file|
      FileUtils.rm_f(file)
    end
  end

  describe 'Inverse Distance to a Power' do
    let(:gridder_options) do
      gridder_options = GDAL::GridderOptions.new(:inverse_distance_to_a_power)

      gridder_options.algorithm_options[:angle] = 10
      gridder_options.algorithm_options[:max_points] = 5
      gridder_options.algorithm_options[:min_points] = 1
      gridder_options.algorithm_options[:no_data_value] = -9999
      gridder_options.algorithm_options[:power] = 2
      gridder_options.algorithm_options[:radius1] = 20
      gridder_options.algorithm_options[:radius2] = 15
      gridder_options.algorithm_options[:smoothing] = 5

      gridder_options.input_field_name = 'STATE_FIPS'
      gridder_options.output_size = { width: 300, height: 200 }
      gridder_options.output_data_type = :GDT_UInt16

      gridder_options
    end

    let(:output_file_name) { File.expand_path('../../../tmp/gridder_spec-idtap.tif', __dir__) }

    it 'results in a raster with relevant data to the grid algorithm' do
      gridder = GDAL::Gridder.new(source_layer, output_file_name, gridder_options)
      gridder.grid!

      expect(dataset.spatial_reference.authority_code.to_i).to eq 4269
      expect(dataset.raster_band(1)).to be_a GDAL::RasterBand
      expect(dataset.raster_band(1).no_data_value[:value]).to eq(-9999)
      expect(dataset.raster_band(1).x_size).to eq 300
      expect(dataset.raster_band(1).y_size).to eq 200
      expect(dataset.raster_band(1).data_type).to eq :GDT_UInt16

      stats = dataset.raster_band(1).statistics
      expect(stats[:minimum]).to eq 0.0
      expect(stats[:maximum]).to eq 55.0
      expect(stats[:mean]).to be_within(0.001).of 25.549
      expect(stats[:standard_deviation]).to be_within(0.0001).of 19.1278
    end
  end

  describe 'Nearest Neighbor' do
    let(:gridder_options) do
      gridder_options = GDAL::GridderOptions.new(:nearest_neighbor)

      gridder_options.algorithm_options[:angle] = 3
      gridder_options.algorithm_options[:no_data_value] = -9999
      gridder_options.algorithm_options[:radius1] = 2
      gridder_options.algorithm_options[:radius2] = 1

      gridder_options.input_field_name = 'STATE_FIPS'
      gridder_options.output_size = { width: 10, height: 15 }
      gridder_options.output_data_type = :GDT_Int16

      gridder_options
    end

    let(:output_file_name) { File.expand_path('../../../tmp/gridder_spec-nearest_neighbor.tif', __dir__) }

    it 'results in a raster with relevant data to the grid algorithm' do
      gridder = GDAL::Gridder.new(source_layer, output_file_name, gridder_options)
      gridder.grid!

      expect(dataset.spatial_reference.authority_code.to_i).to eq 4269
      expect(dataset.raster_band(1)).to be_a GDAL::RasterBand
      expect(dataset.raster_band(1).no_data_value[:value]).to eq(-9999)
      expect(dataset.raster_band(1).x_size).to eq 10
      expect(dataset.raster_band(1).y_size).to eq 15
      expect(dataset.raster_band(1).data_type).to eq :GDT_Int16

      stats = dataset.raster_band(1).statistics
      expect(stats[:minimum]).to eq 2.0
      expect(stats[:maximum]).to eq 56.0
      expect(stats[:mean]).to be_within(0.00000000001).of 16.972222222222
      expect(stats[:standard_deviation]).to be_within(0.00000000001).of 16.308631169331
    end
  end

  describe 'Metric Average Distance' do
    let(:gridder_options) do
      gridder_options = GDAL::GridderOptions.new(:metric_average_distance)

      gridder_options.algorithm_options[:angle] = 30
      gridder_options.algorithm_options[:no_data_value] = -9999
      gridder_options.algorithm_options[:radius1] = 20
      gridder_options.algorithm_options[:radius2] = 15
      gridder_options.algorithm_options[:min_points] = 1000

      gridder_options.input_field_name = 'STATE_FIPS'
      gridder_options.output_size = { width: 100, height: 150 }
      gridder_options.output_data_type = :GDT_UInt32

      gridder_options
    end

    let(:output_file_name) { File.expand_path('../../../tmp/gridder_spec-metric_average_distance.tif', __dir__) }

    it 'results in a raster with relevant data to the grid algorithm' do
      gridder = GDAL::Gridder.new(source_layer, output_file_name, gridder_options)
      gridder.grid!

      expect(dataset.spatial_reference.authority_code.to_i).to eq 4269
      expect(dataset.raster_band(1)).to be_a GDAL::RasterBand
      expect(dataset.raster_band(1).no_data_value[:value]).to eq(-9999)
      expect(dataset.raster_band(1).x_size).to eq 100
      expect(dataset.raster_band(1).y_size).to eq 150
      expect(dataset.raster_band(1).data_type).to eq :GDT_UInt32

      stats = dataset.raster_band(1).statistics
      expect(stats[:minimum]).to eq 0.0
      expect(stats[:maximum]).to eq 17.0
      expect(stats[:mean]).to be_within(0.000000000001).of 6.211
      expect(stats[:standard_deviation]).to be_within(0.000000000001).of 5.9461944973235
    end
  end

  describe 'Metric Average Distance Between Points' do
    let(:gridder_options) do
      gridder_options = GDAL::GridderOptions.new(:metric_average_distance_pts)

      gridder_options.algorithm_options[:angle] = 0.1
      gridder_options.algorithm_options[:no_data_value] = -9999
      gridder_options.algorithm_options[:radius1] = 0.2
      gridder_options.algorithm_options[:radius2] = 0.3
      gridder_options.algorithm_options[:min_points] = 1

      gridder_options.input_field_name = 'STATE_FIPS'
      gridder_options.output_size = { width: 50, height: 250 }
      gridder_options.output_data_type = :GDT_Float32

      gridder_options
    end

    let(:output_file_name) { File.expand_path('../../../tmp/gridder_spec-metric_average_distance_pts.tif', __dir__) }

    it 'results in a raster with relevant data to the grid algorithm' do
      gridder = GDAL::Gridder.new(source_layer, output_file_name, gridder_options)
      gridder.grid!

      expect(dataset.spatial_reference.authority_code.to_i).to eq 4269
      expect(dataset.raster_band(1)).to be_a GDAL::RasterBand
      expect(dataset.raster_band(1).no_data_value[:value]).to eq(-9999)
      expect(dataset.raster_band(1).x_size).to eq 50
      expect(dataset.raster_band(1).y_size).to eq 250
      expect(dataset.raster_band(1).data_type).to eq :GDT_Float32

      stats = dataset.raster_band(1).statistics
      expect(stats[:minimum]).to eq 0.0
      expect(stats[:maximum]).to be_within(0.000000000001).of 0.43194779753685
      expect(stats[:mean]).to be_within(0.000000000001).of 0.11661225064791
      expect(stats[:standard_deviation]).to be_within(0.000000000001).of 0.081518691345895
    end
  end

  describe 'Metric Count' do
    let(:gridder_options) do
      gridder_options = GDAL::GridderOptions.new(:metric_count)

      gridder_options.algorithm_options[:angle] = 0.5
      gridder_options.algorithm_options[:no_data_value] = -9999
      gridder_options.algorithm_options[:radius1] = 0.1
      gridder_options.algorithm_options[:radius2] = 0.2
      gridder_options.algorithm_options[:min_points] = 1

      gridder_options.input_field_name = 'STATE_FIPS'
      gridder_options.output_size = { width: 50, height: 50 }
      gridder_options.output_data_type = :GDT_Int32

      gridder_options
    end

    let(:output_file_name) { File.expand_path('../../../tmp/gridder_spec-metric_count.tif', __dir__) }

    it 'results in a raster with relevant data to the grid algorithm' do
      gridder = GDAL::Gridder.new(source_layer, output_file_name, gridder_options)
      gridder.grid!

      expect(dataset.spatial_reference.authority_code.to_i).to eq 4269
      expect(dataset.raster_band(1)).to be_a GDAL::RasterBand
      expect(dataset.raster_band(1).no_data_value[:value]).to eq(-9999)
      expect(dataset.raster_band(1).x_size).to eq 50
      expect(dataset.raster_band(1).y_size).to eq 50
      expect(dataset.raster_band(1).data_type).to eq :GDT_Int32

      stats = dataset.raster_band(1).statistics
      expect(stats[:minimum]).to eq 1.0
      expect(stats[:maximum]).to eq 18.0
      expect(stats[:mean]).to be_within(0.000000000001).of 3.9318181818182
      expect(stats[:standard_deviation]).to be_within(0.000000000001).of 3.7135974182892
    end
  end

  describe 'Metric Maximum' do
    let(:gridder_options) do
      gridder_options = GDAL::GridderOptions.new(:metric_maximum)

      gridder_options.algorithm_options[:angle] = 30
      gridder_options.algorithm_options[:no_data_value] = -9999
      gridder_options.algorithm_options[:radius1] = 90
      gridder_options.algorithm_options[:radius2] = 0.1
      gridder_options.algorithm_options[:min_points] = 1

      gridder_options.input_field_name = 'STATE_FIPS'
      gridder_options.output_size = { width: 50, height: 50 }
      gridder_options.output_data_type = :GDT_Byte

      gridder_options
    end

    let(:output_file_name) { File.expand_path('../../../tmp/gridder_spec-metric_maximum.tif', __dir__) }

    it 'results in a raster with relevant data to the grid algorithm' do
      skip 'AGDEV-13650 figure out why this test causes a crash'
      gridder = GDAL::Gridder.new(source_layer, output_file_name, gridder_options)
      gridder.grid!

      expect(dataset.spatial_reference.authority_code.to_i).to eq 4269
      expect(dataset.raster_band(1)).to be_a GDAL::RasterBand
      expect(dataset.raster_band(1).no_data_value[:value]).to eq(-9999)
      expect(dataset.raster_band(1).x_size).to eq 50
      expect(dataset.raster_band(1).y_size).to eq 50
      expect(dataset.raster_band(1).data_type).to eq :GDT_Byte

      stats = dataset.raster_band(1).statistics
      expect(stats[:minimum]).to eq 0.0
      expect(stats[:maximum]).to eq 56.0
      expect(stats[:mean]).to be_within(0.000000000001).of 26.3916
      expect(stats[:standard_deviation]).to be_within(0.000000000001).of 24.779859754244
    end
  end

  describe 'Metric Minimum' do
    let(:gridder_options) do
      gridder_options = GDAL::GridderOptions.new(:metric_minimum)

      gridder_options.algorithm_options[:angle] = 30
      gridder_options.algorithm_options[:no_data_value] = -9999
      gridder_options.algorithm_options[:radius1] = 90
      gridder_options.algorithm_options[:radius2] = 0.1
      gridder_options.algorithm_options[:min_points] = 1

      gridder_options.input_field_name = 'STATE_FIPS'
      gridder_options.output_size = { width: 50, height: 50 }
      gridder_options.output_data_type = :GDT_CInt16

      gridder_options
    end

    let(:output_file_name) { File.expand_path('../../../tmp/gridder_spec-metric_minimum.tif', __dir__) }

    it 'results in a raster with relevant data to the grid algorithm' do
      skip 'AGDEV-13650 figure out why this test causes a crash'
      gridder = GDAL::Gridder.new(source_layer, output_file_name, gridder_options)
      gridder.grid!

      expect(dataset.spatial_reference.authority_code.to_i).to eq 4269
      expect(dataset.raster_band(1)).to be_a GDAL::RasterBand
      expect(dataset.raster_band(1).no_data_value[:value]).to eq(-9999)
      expect(dataset.raster_band(1).x_size).to eq 50
      expect(dataset.raster_band(1).y_size).to eq 50
      expect(dataset.raster_band(1).data_type).to eq :GDT_CInt16

      stats = dataset.raster_band(1).statistics
      expect(stats[:minimum]).to eq 1.0
      expect(stats[:maximum]).to eq 53.0
      expect(stats[:mean]).to be_within(0.000000000001).of 9.1150793650794
      expect(stats[:standard_deviation]).to be_within(0.000000000001).of 12.575393694871
    end
  end

  # TODO: This test seems particularly prone to ruby malloc errors.
  describe 'Metric Range' do
    let(:gridder_options) do
      gridder_options = GDAL::GridderOptions.new(:metric_range)

      gridder_options.algorithm_options[:angle] = 10
      gridder_options.algorithm_options[:no_data_value] = -9999
      gridder_options.algorithm_options[:radius1] = 40
      gridder_options.algorithm_options[:radius2] = 10
      gridder_options.algorithm_options[:min_points] = 1

      gridder_options.input_field_name = 'STATE_FIPS'
      gridder_options.output_size = { width: 50, height: 50 }
      gridder_options.output_data_type = :GDT_CFloat64

      gridder_options
    end

    let(:output_file_name) { File.expand_path('../../../tmp/gridder_spec-metric_range.tif', __dir__) }

    it 'results in a raster with relevant data to the grid algorithm' do
      skip 'AGDEV-13650 figure out why this test causes a crash'
      gridder = GDAL::Gridder.new(source_layer, output_file_name, gridder_options)
      gridder.grid!

      expect(dataset.spatial_reference.authority_code.to_i).to eq 4269
      expect(dataset.raster_band(1)).to be_a GDAL::RasterBand
      expect(dataset.raster_band(1).no_data_value[:value]).to eq(-9999)
      expect(dataset.raster_band(1).x_size).to eq 50
      expect(dataset.raster_band(1).y_size).to eq 50
      expect(dataset.raster_band(1).data_type).to eq :GDT_CFloat64

      stats = dataset.raster_band(1).statistics
      expect(stats[:minimum]).to eq 0.0
      expect(stats[:maximum]).to eq 55.0
      expect(stats[:mean]).to be_within(0.000000000001).of 28.216176470588234
      expect(stats[:standard_deviation]).to be_within(0.000000000001).of 24.681864682477947
    end
  end
end
