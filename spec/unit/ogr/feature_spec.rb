# frozen_string_literal: true

require 'date'
require 'ogr/feature'
require 'ogr/field'

RSpec.describe OGR::Feature do
  let(:integer_field_def) { OGR::FieldDefinition.create('test integer field', :OFTInteger) }
  let(:integer_list_field_def) { OGR::FieldDefinition.create('test integer list field', :OFTIntegerList) }
  let(:real_field_def) { OGR::FieldDefinition.create('test real field', :OFTReal) }
  let(:real_list_field_def) { OGR::FieldDefinition.create('test real list field', :OFTRealList) }
  let(:string_field_def) { OGR::FieldDefinition.create('test string field', :OFTString) }
  let(:string_list_field_def) { OGR::FieldDefinition.create('test string list field', :OFTStringList) }
  let(:binary_field_def) { OGR::FieldDefinition.create('test binary field', :OFTBinary) }
  let(:date_field_def) { OGR::FieldDefinition.create('test date field', :OFTDate) }
  let(:integer64_field_def) { OGR::FieldDefinition.create('test integer64 field', :OFTInteger64) }
  let(:integer64_list_field_def) { OGR::FieldDefinition.create('test integer64 list field', :OFTInteger64List) }

  let(:feature_definition) do
    fd = OGR::FeatureDefinition.create('test FD')

    fd.add_field_definition(integer_field_def)        # 0
    fd.add_field_definition(integer_list_field_def)   # 1
    fd.add_field_definition(real_field_def)           # 2
    fd.add_field_definition(real_list_field_def)      # 3
    fd.add_field_definition(string_field_def)         # 4
    fd.add_field_definition(string_list_field_def)    # 5
    fd.add_field_definition(binary_field_def)         # 6
    fd.add_field_definition(date_field_def)           # 7
    fd.add_field_definition(integer64_field_def)      # 8
    fd.add_field_definition(integer64_list_field_def) # 9

    gfd = fd.geometry_field_definition(0)
    gfd.type = :wkbPoint
    gfd.name = 'test point'

    fd
  end
  let(:integer_field_number) { 0 }
  let(:integer_list_field_number) { 1 }
  let(:real_field_number) { 2 }
  let(:real_list_field_number) { 3 }
  let(:string_field_number) { 4 }
  let(:string_list_field_number) { 5 }
  let(:binary_field_number) { 6 }
  let(:date_field_number) { 7 }
  let(:integer64_field_number) { 8 }
  let(:integer64_list_field_number) { 9 }

  let(:empty_feature_definition) do
    OGR::FeatureDefinition.create('empty test FD')
  end

  describe '.create' do
    context 'param is not a FeatureDefinition or pointer to a FeatureDefinition' do
      it 'raises an OGR::InvalidFeature' do
        expect { described_class.create('not a pointer') }.to raise_exception NoMethodError
      end
    end
  end

  subject(:feature) { described_class.create(feature_definition) }

  describe '#clone' do
    it 'returns a new Feature' do
      expect(subject.clone).to be_a OGR::Feature
    end
  end

  describe '#field_count' do
    context 'no fields' do
      subject { empty_feature_definition.field_count }
      it { is_expected.to be_zero }
    end

    context 'with fields' do
      it 'returns the number of fields that have been added' do
        expect(subject.field_count).to eq 10
      end
    end
  end

  describe '#set_field_integer + #field_as_integer' do
    context 'to a valid index' do
      it 'adds the field' do
        subject.set_field_integer(integer_field_number, 123)
        expect(subject.field_as_integer(integer_field_number)).to eq 123
      end
    end

    context 'to an invalid valid index' do
      it 'adds the field' do
        expect do
          subject.set_field_integer(100, 123)
        end.to raise_exception GDAL::Error
      end
    end

    context 'value is not an integer' do
      it 'raises a TypeError' do
        expect do
          subject.set_field_integer(integer_field_number, 'meow')
        end.to raise_exception TypeError
      end
    end
  end

  describe '#set_field_integer64 + #field_as_integer64' do
    context 'to a valid index' do
      it 'adds the field' do
        subject.set_field_integer64(integer64_field_number, 123)
        expect(subject.field_as_integer64(integer64_field_number)).to eq 123
      end
    end

    context 'to an invalid valid index' do
      it 'adds the field' do
        expect do
          subject.set_field_integer64(100, 123)
        end.to raise_exception GDAL::Error
      end
    end

    context 'value is not an integer64' do
      it 'raises a TypeError' do
        expect do
          subject.set_field_integer64(integer64_field_number, 'meow')
        end.to raise_exception TypeError
      end
    end
  end

  describe '#set_field_integer_list + #field_as_integer_list' do
    context 'to a valid index' do
      it 'adds the integer list' do
        subject.set_field_integer_list(integer_list_field_number, [1, 2, 3])
        expect(subject.field_as_integer_list(integer_list_field_number)).to eq [1, 2, 3]
      end
    end

    context 'to an invalid valid index' do
      it 'adds the field' do
        expect do
          subject.set_field_integer_list(100, [1, 2, 3])
        end.to raise_exception GDAL::Error
      end
    end

    context 'value is not an array of integers' do
      it 'raises a TypeError' do
        expect do
          subject.set_field_integer_list(integer_list_field_number, ['meow'])
        end.to raise_exception TypeError
      end
    end
  end

  describe '#set_field_integer64_list + #field_as_integer64_list' do
    context 'to a valid index' do
      it 'adds the integer list' do
        subject.set_field_integer64_list(integer64_list_field_number, [1, 2, 3])
        expect(subject.field_as_integer64_list(integer64_list_field_number)).to eq [1, 2, 3]
      end
    end

    context 'to an invalid valid index' do
      it 'adds the field' do
        expect do
          subject.set_field_integer64_list(100, [1, 2, 3])
        end.to raise_exception GDAL::Error
      end
    end

    context 'value is not an array of integers' do
      it 'raises a TypeError' do
        expect do
          subject.set_field_integer64_list(integer64_list_field_number, ['meow'])
        end.to raise_exception TypeError
      end
    end
  end

  describe '#set_field_double + #field_as_double' do
    context 'to a valid index' do
      it 'adds the field' do
        subject.set_field_double(real_field_number, 123.123)
        expect(subject.field_as_double(real_field_number)).to eq 123.123
      end
    end

    context 'to an invalid valid index' do
      it 'adds the field' do
        expect do
          subject.set_field_double(100, 123.123)
        end.to raise_exception GDAL::Error
      end
    end

    context 'value is not a float' do
      it 'raises a TypeError' do
        expect do
          subject.set_field_double(real_field_number, 'meow')
        end.to raise_exception TypeError
      end
    end
  end

  describe '#set_field_double_list + #field_as_double_list' do
    context 'to a valid index' do
      it 'adds the double list' do
        subject.set_field_double_list(real_list_field_number, [1.1, 2.1, 3.1])
        expect(subject.field_as_double_list(real_list_field_number)).to eq [1.1, 2.1, 3.1]
      end
    end

    context 'to an invalid valid index' do
      it 'adds the field' do
        expect do
          subject.set_field_double_list(100, [1.1, 2.1, 3.1])
        end.to raise_exception GDAL::Error
      end
    end

    context 'value is not an array of doubles' do
      it 'raises a TypeError' do
        expect do
          subject.set_field_double_list(real_list_field_number, ['meow'])
        end.to raise_exception TypeError
      end
    end
  end

  describe '#set_field_string + #field_as_string' do
    context 'to a valid index' do
      it 'adds the field' do
        subject.set_field_string(string_field_number, 'test string')
        expect(subject.field_as_string(string_field_number)).to eq 'test string'
      end
    end

    context 'to an invalid valid index' do
      it 'raises a GDAL::Error' do
        expect do
          subject.set_field_string(100, 'test string')
        end.to raise_exception GDAL::Error
      end
    end

    context 'value is not a string' do
      it 'raises a TypeError' do
        expect do
          subject.set_field_string(string_field_number, 123)
        end.to raise_exception TypeError
      end
    end
  end

  describe '#set_field_string_list' do
    context 'to a valid index' do
      it 'adds the string list' do
        subject.set_field_string_list(string_list_field_number, %w[one two three])
        expect(subject.field_as_string_list(string_list_field_number)).to eq %w[one two three]
      end
    end

    context 'to an invalid valid index' do
      it 'raises a GDAL::Error' do
        expect do
          subject.set_field_string_list(100, [1, 2, 3])
        end.to raise_exception GDAL::Error, 'Invalid index : 100'
      end
    end

    context 'value is an array of numbers' do
      it 'converts the elements to strings' do
        subject.set_field_string_list(string_list_field_number, [4, 5.6, 6.78])
        expect(subject.field_as_string_list(string_list_field_number)).to eq %w[4 5.6 6.78]
      end
    end
  end

  describe '#set_field_raw + #field_as_raw' do
    let(:integer_field) do
      f = OGR::Field.new
      f.integer = 1

      f
    end

    let(:integer_list_field) do
      f = OGR::Field.new
      f.integer_list = [1, 2, 3]

      f
    end

    context 'to a valid index' do
      it 'adds the field' do
        subject.set_field_raw(integer_field_number, integer_field)
        expect(subject.field_as_integer(integer_field_number)).to eq 1
      end
    end

    context 'to an invalid valid index' do
      it 'adds the field' do
        expect do
          subject.set_field_raw(100, integer_field)
        end.to raise_exception GDAL::Error
      end
    end
  end

  describe '#set_field_binary + #field_as_binary' do
    context 'to a valid index' do
      it 'adds the field' do
        subject.set_field_binary(binary_field_number, [65, 66, 67, 68, 69].pack('C*'))
        expect(subject.field_as_binary(binary_field_number)).to eq [65, 66, 67, 68, 69]
      end
    end

    context 'to an invalid valid index' do
      it 'adds the field' do
        expect do
          subject.set_field_binary(100, 123)
        end.to raise_exception TypeError
      end
    end

    context 'value is not binary' do
      it 'raises a TypeError' do
        expect do
          subject.set_field_binary(binary_field_number, 123)
        end.to raise_exception TypeError
      end
    end
  end

  describe '#set_field_date_time + #field_as_date_time' do
    let(:date_time) { DateTime.now }

    context 'to a valid index' do
      it 'adds the field' do
        subject.set_field_date_time(date_field_number, date_time)
        expect(subject.field_as_date_time(7).httpdate).to eq date_time.httpdate
      end
    end

    context 'to an invalid valid index' do
      it 'adds the field' do
        expect do
          subject.set_field_binary(100, 123)
        end.to raise_exception TypeError
      end
    end

    context 'value is not binary' do
      it 'raises a TypeError' do
        expect do
          subject.set_field_binary(date_field_number, 123)
        end.to raise_exception TypeError
      end
    end
  end

  describe '#set_field_date_time_ex + #field_as_date_time_ex' do
    let(:date_time) { DateTime.now }

    context 'to a valid index' do
      it 'adds the field' do
        subject.set_field_date_time_ex(date_field_number, date_time)
        expect(subject.field_as_date_time(date_field_number).httpdate).to eq date_time.httpdate
      end
    end

    context 'to an invalid valid index' do
      it 'adds the field' do
        expect do
          subject.set_field_binary(100, 123)
        end.to raise_exception TypeError
      end
    end

    context 'value is not binary' do
      it 'raises a TypeError' do
        expect do
          subject.set_field_binary(date_field_number, 123)
        end.to raise_exception TypeError
      end
    end
  end

  describe '#field_definition' do
    context 'field exists at the given index' do
      it 'returns the FieldDefinition' do
        expect(subject.field_definition(0)).to be_a OGR::FieldDefinition
      end
    end

    context 'field does not exist at the given index' do
      it 'raises a GDAL::Error' do
        expect { subject.field_definition(123) }.to raise_exception GDAL::Error
      end
    end
  end

  describe 'field_index' do
    context 'field exists with the given name' do
      it "returns the FieldDefinition's index" do
        expect(subject.field_index('test binary field')).to eq binary_field_number
      end
    end

    context 'field does not exist with the given name' do
      it 'returns nil' do
        expect(subject.field_index('asdfadsasd')).to be_nil
      end
    end
  end

  describe '#field_set?' do
    context 'field at the given index is not set' do
      it 'returns false' do
        expect(subject.field_set?(integer_field_number)).to eq false
      end
    end

    context 'field at the given index is set' do
      before { subject.set_field_string(string_field_number, 'Pants') }

      it 'returns true' do
        expect(subject.field_set?(string_field_number)).to eq true
      end
    end
  end

  describe '#unset_field + #field_set?' do
    context 'field is set' do
      it 'removes the field' do
        subject.unset_field(integer_field_number)
        expect(subject.field_set?(integer_field_number)).to eq false
      end
    end

    context 'field is not set' do
      it 'raises a GDAL::Error' do
        expect { subject.unset_field(100) }.to raise_exception GDAL::Error
      end
    end
  end

  describe '#field_null? + #set_field_null + #field_set_and_not_null?' do
    context 'field at the given index is not null' do
      it 'field_null? returns false; field_set_and_not_null? returns true' do
        expect(subject.field_null?(integer_field_number)).to eq false
        expect(subject.field_set_and_not_null?(integer_field_number)).to eq false

        subject.set_field_integer(integer_field_number, 42)
        expect(subject.field_set_and_not_null?(integer_field_number)).to eq true
      end
    end

    context 'field at the given index is set to null' do
      before { subject.set_field_null(string_field_number) }

      it 'field_null? returns true' do
        expect(subject.field_null?(string_field_number)).to eq true
        expect(subject.field_set_and_not_null?(string_field_number)).to eq false

        subject.set_field_string(string_field_number, '42')
        expect(subject.field_set_and_not_null?(string_field_number)).to eq true
      end
    end
  end

  describe '#validate' do
    it 'does not crash' do
      expect(subject.validate(:OGR_F_VAL_ALL)).to eq true
      expect(subject.validate(:OGR_F_VAL_ALL, emit_error: false)).to eq true
    end
  end

  describe '#set_from_with_map!' do
    specify do
      fd = OGR::FeatureDefinition.create('test FD')
      fd.add_field_definition(date_field_def)
      source = OGR::Feature.create(fd)
      subject.set_from_with_map!(source, [0, 2])
    end
  end

  describe '#native_data + #native_data=' do
    context 'native data not set' do
      it 'returns nil' do
        expect(subject.native_data).to be_nil
      end
    end

    context 'native data is set' do
      it 'returns the native data' do
        subject.native_data = 'This is some sweet data'
        expect(subject.native_data).to eq 'This is some sweet data'
      end
    end
  end

  describe '#native_media_type + #native_media_type=' do
    context 'native media type not set' do
      it 'returns nil' do
        expect(subject.native_media_type).to be_nil
      end
    end

    context 'native media type is set' do
      it 'returns the native media_type' do
        subject.native_media_type = 'application/json'
        expect(subject.native_media_type).to eq 'application/json'
      end
    end
  end

  describe '#fill_unset_with_default' do
    context 'non_nullable_only = false' do
      it 'does not crash' do
        subject.fill_unset_with_default
      end
    end

    context 'non_nullable_only = true' do
      it 'does not crash' do
        subject.fill_unset_with_default non_nullable_only: true
      end
    end
  end
end
