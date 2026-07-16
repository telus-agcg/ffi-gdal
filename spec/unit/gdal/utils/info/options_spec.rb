# frozen_string_literal: true

require "spec_helper"
require "gdal"

RSpec.describe GDAL::Utils::Info::Options do
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

    let(:options) { ["-json", "-mdd", "all"] }

    it "returns a new instance of Options with options" do
      expect(subject).to be_a(described_class)
      expect(subject.c_pointer).to be_a(described_class::AutoPointer)
      expect(subject.c_pointer).not_to be_null
    end
  end

  context "when incorrect options are provided" do
    subject { described_class.new(options: options) }

    let(:options) { ["-json123"] }

    it "raises exception" do
      expected_errors = [
        [GDAL::Error, "Unknown argument: -json123"], # GDAL 3.9+
        [GDAL::UnsupportedOperation, "Unknown option name '-json123'"] # GDAL < 3.9
      ]

      expect { subject }.to raise_exception(StandardError) do |error|
        expect(expected_errors).to include([error.class, error.message])
      end
    end
  end
end
