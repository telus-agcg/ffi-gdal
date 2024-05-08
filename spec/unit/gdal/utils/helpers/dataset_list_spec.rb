# frozen_string_literal: true

require "spec_helper"
require "gdal"

RSpec.describe GDAL::Utils::Helpers::DatasetList do
  context "when no datasets are provided" do
    subject { described_class.new }

    it "returns a new instance of DatasetList" do
      expect(subject).to be_a(described_class)
      expect(subject.datasets).to eq([])
      expect(subject.c_pointer).to be_a(FFI::MemoryPointer)
    end
  end

  context "when datasets are provided" do
    subject { described_class.new(datasets: datasets) }

    let(:driver) { GDAL::Driver.by_name("GTiff") }

    let(:datasets) do
      [
        driver.create_dataset("/vsimem/example1.tif", 10, 10),
        driver.create_dataset("/vsimem/example2.tif", 10, 10)
      ]
    end

    after { datasets.each(&:close) }

    it "returns a new instance of DatasetList with options" do
      expect(subject).to be_a(described_class)
      expect(subject.datasets).to eq(datasets)
      expect(subject.c_pointer).to be_a(FFI::MemoryPointer)
    end
  end
end
