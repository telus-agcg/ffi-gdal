# frozen_string_literal: true

require 'ogr/envelope'
require 'gdal/geo_transform'

RSpec.describe OGR::Envelope do
  describe '#x_min' do
    context 'default value' do
      subject { described_class.new.x_min }
      it { is_expected.to eq(0.0) }
    end
  end

  describe '#x_min= + #x_min' do
    it 'sets the x_min value' do
      subject.x_min = 123
      expect(subject.x_min).to eq 123.0
    end
  end

  describe '#x_max' do
    context 'default value' do
      subject { described_class.new.x_max }
      it { is_expected.to eq(0.0) }
    end
  end

  describe '#x_max= + #x_max' do
    it 'sets the x_max value' do
      subject.x_max = 123
      expect(subject.x_max).to eq 123.0
    end
  end

  describe '#y_min' do
    context 'default value' do
      subject { described_class.new.y_min }
      it { is_expected.to eq(0.0) }
    end
  end

  describe '#y_min= + #y_min' do
    it 'sets the y_min value' do
      subject.y_min = 123
      expect(subject.y_min).to eq 123.0
    end
  end

  describe '#y_max' do
    context 'default value' do
      subject { described_class.new.y_max }
      it { is_expected.to eq(0.0) }
    end
  end

  describe '#y_max= + #y_max' do
    it 'sets the y_max value' do
      subject.y_max = 123
      expect(subject.y_max).to eq 123.0
    end
  end
end
