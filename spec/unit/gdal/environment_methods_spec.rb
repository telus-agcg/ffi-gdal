# frozen_string_literal: true

require 'gdal/environment_methods'

RSpec.describe GDAL::EnvironmentMethods do
  subject { Object.new.extend(described_class) }

  describe '#cache_max' do
    it 'returns an Integer' do
      expect(subject.cache_max).to be_an Integer
    end
  end

  describe '#cache_max=' do
    it 'accepts an Integer' do
      subject.cache_max = 1
      expect(subject.cache_max).to be 1
    end
  end

  describe '#cache_max64' do
    it 'returns an Integer' do
      expect(subject.cache_max64).to be_an Integer
    end
  end

  describe '#cache_max64=' do
    it 'accepts an Integer' do
      subject.cache_max64 = 1
      expect(subject.cache_max64).to be 1
    end
  end

  describe '#cache_used' do
    it 'returns an Integer' do
      expect(subject.cache_used).to be_an Integer
    end
  end

  describe '#cache_used64' do
    it 'returns an Integer' do
      expect(subject.cache_used64).to be_an Integer
    end
  end

  describe '#flush_cache_block' do
    it 'returns nil' do
      expect(subject.flush_cache_block).to be_nil
    end
  end

  describe '#dump_open_datasets' do
    it 'takes a String' do
      expect(subject.dump_open_datasets('open-datasets-dump')).to be_nil
    end
  end
end
