# frozen_string_literal: true

require 'gdal/options'

RSpec.describe GDAL::Options do
  describe '.to_hash' do
    context 'options are set' do
      let(:hash) do
        {
          one: 'ONE',
          two: 'TWO'
        }
      end

      it 'returns the Ruby Hash' do
        pointer = described_class.pointer(hash)

        expect(described_class.to_hash(pointer)).to(eq(hash))
      end
    end

    context 'pointer is null' do
      it 'returns an empty Hash' do
        pointer = FFI::MemoryPointer.new(:pointer)

        expect(described_class.to_hash(pointer)).to(eq({}))
      end
    end
  end
end
