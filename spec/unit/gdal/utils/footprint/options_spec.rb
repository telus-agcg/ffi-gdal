# frozen_string_literal: true

require "spec_helper"
require "gdal"

RSpec.describe GDAL::Utils::Rasterize::Options do
  context "when no options are provided" do
    it "returns a new instance of Options" do
      subject { described_class.new }

      expect(subject).to be_a(described_class)
      expect(subject.c_pointer).to be_a(described_class::AutoPointer)
      expect(subject.c_pointer).not_to be_null
    end
  end

  context "when options are provided" do
    subject { described_class.new(options: options) }

    let(:options) { ["-of", "GTiff", "-ts", "10", "10"] }

    it "returns a new instance of Options with options" do
      expect(subject).to be_a(described_class)
      expect(subject.c_pointer).to be_a(described_class::AutoPointer)
      expect(subject.c_pointer).not_to be_null
    end
  end

  context "when incorrect options are provided" do
    subject { described_class.new(options: options) }

    let(:options) { ["-unknown123"] }

    it "raises exception" do
      expect { subject }.to raise_exception(
        GDAL::UnsupportedOperation, "Unknown option name '-unknown123'"
      )
    end
  end
end
