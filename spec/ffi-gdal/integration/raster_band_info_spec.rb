require 'spec_helper'
require 'support/integration_help'
require 'ffi-gdal'


TIF_FILES.each do |file|
  dataset = GDAL::Dataset.open(file, 'r')
  dataset.each_band do |band_under_test|

    describe "Raster Band Info" do
      after :suite do
        dataset.close
      end

      # TODO: Test against each raster band
      subject do
        GDAL::RasterBand.new(dataset.c_pointer, raster_band_pointer: band_under_test.c_pointer)
      end

      it_behaves_like 'a major object'

      describe '#x_size' do
        it 'is a non-zero Integer' do
          expect(subject.x_size).to be_a Fixnum
          expect(subject.x_size).to be > 0
        end
      end

      describe '#y_size' do
        it 'is a non-zero Integer' do
          expect(subject.y_size).to be_a Fixnum
          expect(subject.y_size).to be > 0
        end
      end

      describe '#access_flag' do
        specify { expect(subject.access_flag).to eq :GA_ReadOnly }
      end

      describe '#band_number' do
        it 'is a non-zero Integer' do
          expect(subject.band_number).to be_a Fixnum
          expect(subject.band_number).to be > 0
        end
      end

      describe '#color_interpretation' do
        it 'is a Symbol; one of FFI::GDAL::GDALColorInterp' do
          expect(subject.color_interpretation).to be_a Symbol
          expect(FFI::GDAL::GDALColorInterp.symbols).to include subject.color_interpretation
        end
      end

      describe '#color_table' do
        it 'is a GDAL::ColorTable' do
          if subject.color_table
            expect(subject.color_table).to be_a GDAL::ColorTable
          end
        end
      end

      describe '#data_type' do
        it 'is a Symbol; one of FFI::GDAL::GDALDataType' do
          expect(subject.data_type).to be_a Symbol
          expect(FFI::GDAL::GDALDataType.symbols).to include subject.data_type
        end
      end

      describe '#block_size' do
        it 'is a Hash with x and y keys that are >= 1' do
          expect(subject.block_size).to be_a Hash
          expect(subject.block_size[:x]).to be >= 1
          expect(subject.block_size[:y]).to be >= 1
        end
      end

      describe '#category_names' do
        it 'is an Array of Strings' do
          expect(subject.category_names).to be_an Array

          subject.category_names.each do |category_name|
            expect(category_name).to be_a String
            expect(category_name).to_not be_empty
          end
        end
      end

      describe '#category_names=' do
        around do |example|
          category_names = subject.category_names
          example.run
          subject.category_names = category_names
        end

        it 'sets the category names' do
          expect(subject.category_names).to be_empty

          subject.category_names = %w[one two three]

          expect(subject.category_names).to eq %w[one two three]
        end
      end

      describe '#no_data_value' do
        it 'is a Hash with :value and :is_associated keys' do
          expect(subject.no_data_value).to be_an Hash

          expect(subject.no_data_value[:value]).to be_a Float
          expect(subject.no_data_value[:is_associated]).to_not be_nil
        end
      end

      describe '#overview_count' do
        it 'is a Fixnum' do
          expect(subject.overview_count).to be_a Fixnum
        end
      end

      describe '#arbitrary_overviews?' do
        it 'is true or false' do
          expect([true, false]).to include subject.arbitrary_overviews?
        end
      end

      describe '#overview' do
        it 'returns a GDAL::RasterBand if the overview exists' do
          overview = subject.overview(0)
          expect(overview).to be_a GDAL::RasterBand if overview
        end
      end

      describe '#raster_sample_overview' do
        it 'returns a GDAL::RasterBand if the overview exists' do
          overview = subject.raster_sample_overview
          expect(overview).to be_a GDAL::RasterBand
        end
      end

      describe '#mask_band' do
        it 'returns a GDAL::RasterBand if the mask_band exists' do
          overview = subject.mask_band
          expect(overview).to be_a GDAL::RasterBand
        end
      end

      describe '#mask_flags' do
        it 'returns an Array of Symbols' do
          expect(subject.mask_flags).to eq [:GMF_ALL_VALID]
        end
      end

      describe '#statistics' do
        it 'returns a Hash with populated values' do
          expect(subject.statistics).to be_a Hash
          expect(%i[minimum maximum mean standard_deviation]).
            to eq subject.statistics.keys
        end

        it 'has a :minimum that ranges between 0.0/-32768.0 and 255.0' do
          min = subject.statistics[:minimum]
          unless min == -32768.0
            expect(subject.statistics[:minimum]).to((be >= 0.0) || (eq -32768.0))
            expect(subject.statistics[:minimum]).to be <= 255.0
          end
        end
      end

      describe '#scale' do
        it 'returns a Hash with populated values' do
          expect(subject.statistics).to be_a Hash
          expect(%i[value is_meaningful]).to eq subject.scale.keys
        end

        it 'has a :value that is a Float' do
          expect(subject.scale[:value]).to be_a Float
        end

        it 'has a :is_meaningful that is false (since the examples are geotiffs)' do
          expect(subject.scale[:is_meaningful]).to eq false
        end
      end

      describe '#scale=' do
        around do |example|
          scale = subject.scale[:value]
          example.run
          subject.scale = scale
        end

        it 'does nothing (because the file formats dont support it)' do
          subject.scale = 0.1
          expect(subject.scale[:value]).to eq 0.1
        end
      end

      describe '#offset' do
        it 'returns a Hash with populated values' do
          expect(subject.offset).to be_a Hash
          expect(%i[value is_meaningful]).to eq subject.offset.keys
        end

        it 'has a :value that is a Float' do
          expect(subject.offset[:value]).to be_a Float
        end

        it 'has a :is_meaningful that is false (since the examples are geotiffs)' do
          expect(subject.offset[:is_meaningful]).to eq false
        end
      end

      describe '#offset=' do
        around do |example|
          offset = subject.offset[:value]
          example.run
          subject.offset = offset
        end

        it 'does nothing (because the file formats dont support it)' do
          subject.offset = 0.1
          expect(subject.offset[:value]).to eq 0.1
        end
      end

      describe '#unit_type' do
        it 'returns a String' do
          expect(subject.unit_type).to be_a String
        end
      end

      describe '#unit_type=' do
        around do |example|
          unit_type = subject.unit_type
          example.run
          subject.unit_type = unit_type
        end

        it 'does nothing (because the file formats dont support it)' do
          skip unless defined? FFI::GDAL::GDALSetRasterUnitType

          subject.unit_type = 'ft'
          expect(subject.unit_type).to eq 'ft'
        end
      end

      describe '#default_histogram' do
        let!(:histogram) { subject.default_histogram }

        it 'returns a Hash with :mininum, :maximum, :buckets, and :totals' do
          if histogram
            expect(histogram).to be_a Hash
            expect(histogram.keys).to eq %i[minimum maximum buckets totals]
          end
        end

        it 'has :mimimum as a Float' do
          expect(histogram[:minimum]).to be_a Float if histogram
        end

        it 'has :maximum as a Float' do
          expect(histogram[:maximum]).to be_a Float if histogram
        end

        it 'has :buckets as a Fixnum' do
          expect(histogram[:buckets]).to be_a Fixnum if histogram
        end

        it 'has :totals as an Array of 256 Fixnums' do
          if histogram
            expect(histogram[:totals]).to be_an Array
            expect(histogram[:totals].size).to eq 256
            expect(histogram[:totals].all? { |t| t.class == Fixnum}).to eq true
          end
        end
      end

      describe '#default_raster_attribute_table' do
        it 'returns a GDAL::RasterAttributeTable' do
          rat = subject.default_raster_attribute_table

          if rat
            expect(rat).to be_a GDAL::RasterAttributeTable
          end
        end
      end

      describe '#compute_min_max' do
        it 'returns a 2-element Array of Floats' do
          expect(subject.compute_min_max).to be_a Array
          expect(subject.compute_min_max.size).to eq 2
          expect(subject.compute_min_max.first).to be_a Float
          expect(subject.compute_min_max.last).to be_a Float
        end

        it 'has a min that is < its max' do
          min, max = subject.compute_min_max
          expect(min).to be < max
        end

        it 'has a min that == statistics[:minimum]' do
          min, _ = subject.compute_min_max
          expect(min).to eq subject.statistics[:minimum]
        end

        it 'has a min that == minimum_value[:value]' do
          min, _ = subject.compute_min_max
          expect(min).to eq subject.minimum_value[:value]
        end
      end

      describe '#minimum_value' do
        it 'returns a Hash with populated values' do
          expect(subject.minimum_value).to be_a Hash
          expect(%i[value is_tight]).to eq subject.minimum_value.keys
        end

        it 'has a :value that is a Float' do
          expect(subject.minimum_value[:value]).to be_a Float
        end

        it 'has a :is_tight that is nil (since the examples are geotiffs)' do
          #expect(subject.minimum_value[:is_tight]).to eq nil
        end
      end

      describe '#maximum_value' do
        it 'returns a Hash with populated values' do
          expect(subject.maximum_value).to be_a Hash
          expect(%i[value is_tight]).to eq subject.maximum_value.keys
        end

        it 'has a :value that is a Float' do
          expect(subject.maximum_value[:value]).to be_a Float
        end

        it 'has a :is_tight that is nil (since the examples are geotiffs)' do
          #expect(subject.maximum_value[:is_tight]).to eq nil
        end
      end
    end
  end
end
