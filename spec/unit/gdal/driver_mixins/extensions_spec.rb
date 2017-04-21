# frozen_string_literal: true

require 'spec_helper'
require 'gdal/driver'

RSpec.describe GDAL::Driver do
  describe '.short_names' do
    subject { described_class.short_names }

    it 'is an Array of Strings' do
      expect(subject).to be_an Array
      expect(subject.first).to be_a String
    end
  end

  describe '.long_names' do
    subject { described_class.long_names }

    it 'is an Array of Strings' do
      expect(subject).to be_an Array
      expect(subject.first).to be_a String
    end
  end
end
