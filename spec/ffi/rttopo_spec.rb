# frozen_string_literal: true

require 'spec_helper'
require 'ffi/extensions/rttopo'

RSpec.describe FFI::Rttopo do
  describe '.rttopo_library_path' do
    context 'valid lib' do
      it 'returns a String containing the path to the library' do
        expect(described_class.rttopo_library_path).to match(/rttopo/)
      end
    end
  end
end
