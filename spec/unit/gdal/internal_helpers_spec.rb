require 'spec_helper'
require 'gdal/internal_helpers'
require 'ogr/spatial_reference'
require 'gdal/dataset'

RSpec.describe GDAL::InternalHelpers do
  subject(:tester) do
    module Tester
      include GDAL::InternalHelpers
    end
  end

  describe '._pointer' do
    context 'variable is a kind of the klass that was passed in' do
      let(:variable) { OGR::SpatialReference.new }

      it "returns the variable's pointer with autorelease = true" do
        expect(variable.c_pointer).to receive(:autorelease=).with(true)
        expect(subject._pointer(OGR::SpatialReference, variable)).to eq variable.c_pointer
      end
    end

    context 'variable is an FFI::Pointer' do
      let(:variable) { FFI::MemoryPointer.new(:pointer) }

      it 'returns the pointer with autorelease = true' do
        expect(variable).to receive(:autorelease=).with(true)
        expect(subject._pointer(GDAL::Dataset, variable)).to eq variable
      end
    end

    context 'variable is nil' do
      it 'returns nil' do
        expect(subject._pointer(GDAL::Dataset, nil, false)).to be_nil
      end
    end
  end

  describe '._string_array_to_pointer' do
    context 'an array' do
      let(:array) { ['one', 2, 3.0, :four] }

      it 'returns a pointer that contains the array values as strings' do
        pointer = subject._string_array_to_pointer(array)
        expect(pointer).to be_an FFI::MemoryPointer
        expect(pointer.get_array_of_string(0)).to eq %w[one 2 3.0 four]
      end
    end

    context 'not an array' do
      it 'raises an error about no responding to #map' do
        expect do
          subject._string_array_to_pointer('blarg')
        end.to raise_exception NoMethodError
      end
    end
  end

  describe '._gdal_data_type_to_ffi' do
    context 'data type is :GDT_Byte' do
      subject { tester._gdal_data_type_to_ffi(:GDT_Byte) }
      it { is_expected.to eq :uchar }
    end

    context 'data type is :GDT_UInt16' do
      subject { tester._gdal_data_type_to_ffi(:GDT_UInt16) }
      it { is_expected.to eq :uint16 }
    end

    context 'data type is :GDT_Int16' do
      subject { tester._gdal_data_type_to_ffi(:GDT_Int16) }
      it { is_expected.to eq :int16 }
    end

    context 'data type is :GDT_UInt32' do
      subject { tester._gdal_data_type_to_ffi(:GDT_UInt32) }
      it { is_expected.to eq :uint32 }
    end

    context 'data type is :GDT_Int32' do
      subject { tester._gdal_data_type_to_ffi(:GDT_Int32) }
      it { is_expected.to eq :int32 }
    end

    context 'data type is :GDT_Float32' do
      subject { tester._gdal_data_type_to_ffi(:GDT_Float32) }
      it { is_expected.to eq :float }
    end

    context 'data type is :GDT_Float64' do
      subject { tester._gdal_data_type_to_ffi(:GDT_Float64) }
      it { is_expected.to eq :double }
    end

    context 'data type is not one listed' do
      subject { tester._gdal_data_type_to_ffi(:blargh) }
      it { is_expected.to eq :float }
    end
  end

  describe '._supported?' do
    context 'function is supported' do
      subject { tester._supported?(:GDALAllRegister) }
      it { is_expected.to eq true }
    end

    context 'function is not supported' do
      subject { tester._supported?(:darrells) }
      it { is_expected.to eq false }
    end
  end
end
