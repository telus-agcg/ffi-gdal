# frozen_string_literal: true

require 'gdal/data_type'

RSpec.describe GDAL::DataType do
  describe '.size_in_bits' do
    context 'with valid data type' do
      it 'returns the size' do
        expect(described_class.size_in_bits(:GDT_Byte)).to eq 8
      end
    end

    context 'with invalid data type' do
      it 'raises an ArgumentError' do
        expect { described_class.size_in_bits(:Bob) }.to raise_exception(ArgumentError)
      end
    end
  end

  describe '.size_in_bytes' do
    context 'with valid data type' do
      it 'returns the size' do
        expect(described_class.size_in_bytes(:GDT_Byte)).to eq 1
      end
    end

    context 'with invalid data type' do
      it 'raises an ArgumentError' do
        expect { described_class.size_in_bytes(:Bob) }.to raise_exception(ArgumentError)
      end
    end
  end

  describe '.complex?' do
    context 'with valid, complex data type' do
      it 'returns true' do
        expect(described_class.complex?(:GDT_CFloat64)).to eq true
      end
    end

    context 'with valid, simple data type' do
      it 'returns true' do
        expect(described_class.complex?(:GDT_Float64)).to eq false
      end
    end

    context 'with invalid data type' do
      it 'raises an ArgumentError' do
        expect { described_class.complex?(:Bob) }.to raise_exception(ArgumentError)
      end
    end
  end

  describe '.name' do
    context 'with valid data type' do
      it 'returns the name' do
        expect(described_class.name(:GDT_Byte)).to eq 'Byte'
      end
    end

    context 'with invalid data type' do
      it 'raises an ArgumentError' do
        expect { described_class.name(:Bob) }.to raise_exception(ArgumentError)
      end
    end
  end

  describe '.by_name' do
    context 'with valid data type name' do
      it 'returns the data type' do
        expect(described_class.by_name('Byte')).to eq :GDT_Byte
      end
    end

    context 'with invalid data type name' do
      it 'returns :GDT_Unknown' do
        expect(described_class.by_name('Bob')).to eq :GDT_Unknown
      end
    end
  end
end
