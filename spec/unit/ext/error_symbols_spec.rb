# frozen_string_literal: true

require 'spec_helper'
require 'ext/error_symbols'

RSpec.describe Symbol do
  describe '#handle_result' do
    context ':OGRERR_NONE' do
      subject { :OGRERR_NONE.handle_result }
      it { is_expected.to eq true }
    end

    context ':OGRERR_NOT_ENOUGH_DATA' do
      it 'raises an OGR::NotEnoughData exception' do
        expect { :OGRERR_NOT_ENOUGH_DATA.handle_result }.
          to raise_exception OGR::NotEnoughData
      end
    end

    context ':OGRERR_NOT_ENOUGH_MEMORY' do
      it 'raises an NoMemoryError exception' do
        expect { :OGRERR_NOT_ENOUGH_MEMORY.handle_result }.
          to raise_exception NoMemoryError
      end
    end

    context ':OGRERR_UNSUPPORTED_GEOMETRY_TYPE' do
      it 'raises an OGR::UnsupportedGeometryType exception' do
        expect { :OGRERR_UNSUPPORTED_GEOMETRY_TYPE.handle_result }.
          to raise_exception OGR::UnsupportedGeometryType
      end
    end

    context ':OGRERR_UNSUPPORTED_OPERATION' do
      it 'raises an OGR::UnsupportedOperation exception' do
        expect { :OGRERR_UNSUPPORTED_OPERATION.handle_result }.
          to raise_exception OGR::UnsupportedOperation
      end
    end

    context ':OGRERR_CORRUPT_DATA' do
      it 'raises an OGR::CorruptData exception' do
        expect { :OGRERR_CORRUPT_DATA.handle_result }.
          to raise_exception OGR::CorruptData
      end
    end

    context ':OGRERR_FAILURE' do
      it 'raises an OGR::Failure exception' do
        expect { :OGRERR_FAILURE.handle_result }.
          to raise_exception OGR::Failure
      end
    end

    context ':OGRERR_UNSUPPORTED_SRS' do
      it 'raises an OGR::UnsupportedSRS exception' do
        expect { :OGRERR_UNSUPPORTED_SRS.handle_result }.
          to raise_exception OGR::UnsupportedSRS
      end
    end

    context ':OGRERR_INVALID_HANDLE' do
      it 'raises an OGR::InvalidHandle exception' do
        expect { :OGRERR_INVALID_HANDLE.handle_result }.
          to raise_exception OGR::InvalidHandle
      end
    end
  end
end
