require 'spec_helper'
require 'ext/cpl_error_symbols'

describe Symbol do
  describe '#to_ruby' do
    context ':CE_None' do
      subject { :CE_None }

      it 'returns true' do
        expect(subject.to_ruby).to eq true
      end

      context 'with an explicit value' do
        it 'returns what the given param is' do
          expect(subject.to_ruby(none: :pants)).to eq :pants
        end
      end

      context 'with a block' do
        it 'returns what the block returns' do
          expect(subject.to_ruby { :pants }).to eq :pants
        end
      end
    end

    context ':CE_Debug' do
      subject { :CE_Debug }

      it 'returns true' do
        expect(subject.to_ruby).to eq true
      end

      context 'with an explicit value' do
        it 'returns what the given param is' do
          expect(subject.to_ruby(debug: :pants)).to eq :pants
        end
      end

      context 'with a block' do
        it 'returns what the block returns' do
          expect(subject.to_ruby { :pants }).to eq :pants
        end
      end
    end

    context ':CE_Warning' do
      subject { :CE_Warning }

      it 'returns true' do
        expect(subject.to_ruby).to eq false
      end

      context 'with an explicit value' do
        it 'returns what the given param is' do
          expect(subject.to_ruby(warning: :pants)).to eq :pants
        end
      end

      context 'with a block' do
        it 'returns what the block returns' do
          expect(subject.to_ruby { :pants }).to eq :pants
        end
      end
    end
  end
end
