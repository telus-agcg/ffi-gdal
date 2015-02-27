require 'spec_helper'

RSpec.describe FFI::GDAL do
  describe '._files_with_constants' do
    it 'returns a non-empty Array' do
      expect(described_class._files_with_constants).to be_an Array
      expect(described_class._files_with_constants).to_not be_empty
    end
  end

  describe '_file_with_constants' do
    context 'valid file' do
      it 'returns the path to that file' do
        expect(described_class._file_with_constants('gdal.h')).to match '.+gdal\.h\z'
      end
    end

    context 'invalid file' do
      it 'returns nil' do
        expect(described_class._file_with_constants('derp')).to be_nil
      end
    end
  end
end
