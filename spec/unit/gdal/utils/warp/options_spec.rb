# frozen_string_literal: true

require "spec_helper"
require "gdal"

RSpec.describe GDAL::Utils::Warp::Options do
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

    let(:options) { ["-multi", "-wo", "CUTLINE_ALL_TOUCHED=TRUE"] }

    it "returns a new instance of Options with options" do
      expect(subject).to be_a(described_class)
      expect(subject.c_pointer).to be_a(described_class::AutoPointer)
      expect(subject.c_pointer).not_to be_null
    end
  end

  context "when incorrect options are provided" do
    subject { described_class.new(options: options) }

    let(:options) { ["-multi123"] }

    it "raises exception" do
      expect { subject }.to raise_exception(
        GDAL::UnsupportedOperation, "Unknown option name '-multi123'"
      )
    end
  end
end
