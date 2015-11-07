require 'spec_helper'
require 'gdal/gridder'
require 'ogr/data_source'

RSpec.describe GDAL::Gridder do
  let(:shapefile_path) { './spec/support/shapefiles/states_21basic' }
  let(:source_layer) do
    ds = OGR::DataSource.open(shapefile_path, 'r')
    ds.layer(0)
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

    let(:output_file_name) { './tmp/gridder_spec-idtap.tif' }

    it 'results in a raster with relevant data to the grid algorithm' do
      gridder = GDAL::Gridder.new(source_layer, output_file_name, gridder_options)
      gridder.grid!

      dataset = GDAL::Dataset.open(output_file_name, 'r')
      expect(dataset.spatial_reference.authority_code.to_i).to eq 4269

      expect(dataset.raster_band(1)).to be_a GDAL::RasterBand
      expect(dataset.raster_band(1).no_data_value[:value]).to eq(-9999)
      expect(dataset.raster_band(1).x_size).to eq 200
      expect(dataset.raster_band(1).y_size).to eq 300
      expect(dataset.raster_band(1).data_type).to eq :GDT_UInt16
      expect(dataset.raster_band(1).statistics).to eq(
        minimum: 0.0,
        maximum: 56.0,
        mean: 24.73145,
        standard_deviation: 19.30731288650754
      )
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

    let(:output_file_name) { './tmp/gridder_spec-nearest_neighbor.tif' }

    it 'results in a raster with relevant data to the grid algorithm' do
      gridder = GDAL::Gridder.new(source_layer, output_file_name, gridder_options)
      gridder.grid!

      dataset = GDAL::Dataset.open(output_file_name, 'r')
      expect(dataset.spatial_reference.authority_code.to_i).to eq 4269

      expect(dataset.raster_band(1)).to be_a GDAL::RasterBand
      expect(dataset.raster_band(1).no_data_value[:value]).to eq(-9999)
      expect(dataset.raster_band(1).x_size).to eq 15
      expect(dataset.raster_band(1).y_size).to eq 10
      expect(dataset.raster_band(1).data_type).to eq :GDT_Int16
      expect(dataset.raster_band(1).statistics).to eq(
        minimum: 2.0,
        maximum: 56.0,
        mean: 16.97222222222222,
        standard_deviation: 16.30863116933129
      )
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

    let(:output_file_name) { './tmp/gridder_spec-metric_average_distance.tif' }

    it 'results in a raster with relevant data to the grid algorithm' do
      gridder = GDAL::Gridder.new(source_layer, output_file_name, gridder_options)
      gridder.grid!

      dataset = GDAL::Dataset.open(output_file_name, 'r')
      expect(dataset.spatial_reference.authority_code.to_i).to eq 4269

      expect(dataset.raster_band(1)).to be_a GDAL::RasterBand
      expect(dataset.raster_band(1).no_data_value[:value]).to eq(-9999)
      expect(dataset.raster_band(1).x_size).to eq 150
      expect(dataset.raster_band(1).y_size).to eq 100
      expect(dataset.raster_band(1).data_type).to eq :GDT_UInt32
      expect(dataset.raster_band(1).statistics).to eq(
        minimum: 0.0,
        maximum: 17.0,
        mean: 6.1753846153846155,
        standard_deviation: 5.940906365346503
      )
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

    let(:output_file_name) { './tmp/gridder_spec-metric_average_distance_pts.tif' }

    it 'results in a raster with relevant data to the grid algorithm' do
      gridder = GDAL::Gridder.new(source_layer, output_file_name, gridder_options)
      gridder.grid!

      dataset = GDAL::Dataset.open(output_file_name, 'r')
      expect(dataset.spatial_reference.authority_code.to_i).to eq 4269

      expect(dataset.raster_band(1)).to be_a GDAL::RasterBand
      expect(dataset.raster_band(1).no_data_value[:value]).to eq(-9999)
      expect(dataset.raster_band(1).x_size).to eq 250
      expect(dataset.raster_band(1).y_size).to eq 50
      expect(dataset.raster_band(1).data_type).to eq :GDT_Float32
      expect(dataset.raster_band(1).statistics).to eq(
        minimum: 0.0,
        maximum: 0.43194779753685,
        mean: 0.11661225064790674,
        standard_deviation: 0.08151869134589483
      )
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

    let(:output_file_name) { './tmp/gridder_spec-metric_count.tif' }

    it 'results in a raster with relevant data to the grid algorithm' do
      gridder = GDAL::Gridder.new(source_layer, output_file_name, gridder_options)
      gridder.grid!

      dataset = GDAL::Dataset.open(output_file_name, 'r')
      expect(dataset.spatial_reference.authority_code.to_i).to eq 4269

      expect(dataset.raster_band(1)).to be_a GDAL::RasterBand
      expect(dataset.raster_band(1).no_data_value[:value]).to eq(-9999)
      expect(dataset.raster_band(1).x_size).to eq 50
      expect(dataset.raster_band(1).y_size).to eq 50
      expect(dataset.raster_band(1).data_type).to eq :GDT_Int32
      expect(dataset.raster_band(1).statistics).to eq(
        minimum: 1.0,
        maximum: 18.0,
        mean: 3.9318181818181817,
        standard_deviation: 3.7135974182891673
      )
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

    let(:output_file_name) { './tmp/gridder_spec-metric_maximum.tif' }

    it 'results in a raster with relevant data to the grid algorithm' do
      gridder = GDAL::Gridder.new(source_layer, output_file_name, gridder_options)
      gridder.grid!

      dataset = GDAL::Dataset.open(output_file_name, 'r')
      expect(dataset.spatial_reference.authority_code.to_i).to eq 4269

      expect(dataset.raster_band(1)).to be_a GDAL::RasterBand
      expect(dataset.raster_band(1).no_data_value[:value]).to eq(-9999)
      expect(dataset.raster_band(1).x_size).to eq 50
      expect(dataset.raster_band(1).y_size).to eq 50
      expect(dataset.raster_band(1).data_type).to eq :GDT_Byte
      expect(dataset.raster_band(1).statistics).to eq(
        minimum: 0.0,
        maximum: 56.0,
        mean: 26.3916,
        standard_deviation: 24.77985975424397
      )
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

    let(:output_file_name) { './tmp/gridder_spec-metric_minimum.tif' }

    it 'results in a raster with relevant data to the grid algorithm' do
      gridder = GDAL::Gridder.new(source_layer, output_file_name, gridder_options)
      gridder.grid!

      dataset = GDAL::Dataset.open(output_file_name, 'r')
      expect(dataset.spatial_reference.authority_code.to_i).to eq 4269

      expect(dataset.raster_band(1)).to be_a GDAL::RasterBand
      expect(dataset.raster_band(1).no_data_value[:value]).to eq(-9999)
      expect(dataset.raster_band(1).x_size).to eq 50
      expect(dataset.raster_band(1).y_size).to eq 50
      expect(dataset.raster_band(1).data_type).to eq :GDT_CInt16
      expect(dataset.raster_band(1).statistics).to eq(
        minimum: 1.0,
        maximum: 53.0,
        mean: 9.115079365079366,
        standard_deviation: 12.575393694871057
      )
    end
  end

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

    let(:output_file_name) { './tmp/gridder_spec-metric_range.tif' }

    it 'results in a raster with relevant data to the grid algorithm' do
      gridder = GDAL::Gridder.new(source_layer, output_file_name, gridder_options)
      gridder.grid!

      dataset = GDAL::Dataset.open(output_file_name, 'r')
      expect(dataset.spatial_reference.authority_code.to_i).to eq 4269

      expect(dataset.raster_band(1)).to be_a GDAL::RasterBand
      expect(dataset.raster_band(1).no_data_value[:value]).to eq(-9999)
      expect(dataset.raster_band(1).x_size).to eq 50
      expect(dataset.raster_band(1).y_size).to eq 50
      expect(dataset.raster_band(1).data_type).to eq :GDT_CFloat64
      expect(dataset.raster_band(1).statistics).to eq(
        minimum: 0.0,
        maximum: 55.0,
        mean: 28.216176470588234,
        standard_deviation: 24.681864682477947
      )
    end
  end
end
