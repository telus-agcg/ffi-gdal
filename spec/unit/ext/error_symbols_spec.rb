require 'spec_helper'
require 'ext/error_symbols'

describe Symbol do
  describe '#to_ruby' do
    context ':CE_None' do
      subject { :CE_None }

      it 'returns :none' do
        expect(subject.to_ruby).to eq :none
      end

      context 'with an explicit value' do
        it 'returns what the given param is' do
          expect(subject.to_ruby(none: :pants)).to eq :pants
        end
      end
    end

    context ':CE_Debug' do
      subject { :CE_Debug }

      it 'returns :debug' do
        expect(subject.to_ruby).to eq :debug
      end

      context 'with an explicit value' do
        it 'returns what the given param is' do
          expect(subject.to_ruby(debug: :pants)).to eq :pants
        end
      end
    end

    context ':CE_Warning' do
      subject { :CE_Warning }

      it 'returns :warning' do
        expect(subject.to_ruby).to eq :warning
      end

      context 'with an explicit value' do
        it 'returns what the given param is' do
          expect(subject.to_ruby(warning: :pants)).to eq :pants
        end
      end
    end
  end

  describe '#to_bool' do
    context ':CE_None' do
      subject { :CE_None.to_bool }
      it { is_expected.to eq true }
    end

    context ':CE_Debug' do
      subject { :CE_Debug.to_bool }
      it { is_expected.to eq true }
    end

    context ':CE_Warning' do
      subject { :CE_Warning.to_bool }
      it { is_expected.to eq false }
    end

    context ':CE_Failure' do
      subject { :CE_Failure }
      it 'raises a CPLErrFailure' do
        expect { subject.to_bool }.to raise_error GDAL::CPLErrFailure
      end
    end

    context ':CE_Fatal' do
      subject { :CE_Fatal }
      it 'raises a CPLErrFailure' do
        expect { subject.to_bool }.to raise_error GDAL::CPLErrFailure
      end
    end
  end
end
