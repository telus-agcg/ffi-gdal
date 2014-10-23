require 'spec_helper'

describe GDAL::DataType do
  describe '.size' do
    context 'with valid data type' do
      it 'returns the size' do
        expect(described_class.size(:GDT_Byte)).to eq 8
      end
    end

    context 'with invalid data type' do
      it 'raises an ArgumentError' do
        expect {
          described_class.size(:Bob)
        }.to raise_exception(ArgumentError)
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
        expect {
          described_class.complex?(:Bob)
        }.to raise_exception(ArgumentError)
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
        skip 'Figure out why this causes a segfault'

        expect {
          described_class.name(:Bob)
        }.to raise_exception(ArgumentError)
      end
    end
  end

  describe '.by_name' do
    context 'with valid data type name' do
      it 'returns the data type' do
        skip 'Figure out why this causes a segfault'

        expect(described_class.by_name('Byte')).to eq :GDT_Byte
      end
    end

    context 'with invalid data type name' do
      it 'raises an ArgumentError' do
        skip 'Figure out why this causes a segfault'

        expect {
          described_class.by_name('Bob')
        }.to raise_exception(ArgumentError)
      end
    end
  end
end
