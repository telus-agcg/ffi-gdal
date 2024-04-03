# frozen_string_literal: true

require "spec_helper"
require "gdal"

RSpec.describe GDAL::Utils::Helpers::StringList do
  context "when no strings are provided" do
    subject { described_class.new }

    it "returns a new instance of StringList" do
      expect(subject).to be_a(described_class)
      expect(subject.c_pointer).to be_a(described_class::AutoPointer)
      expect(subject.c_pointer).to be_null
    end
  end

  context "when strings are provided" do
    subject { described_class.new(strings: strings) }

    let(:strings) { ["-option1", "-option2"] }

    it "returns a new instance of StringList with options" do
      expect(subject).to be_a(described_class)
      expect(subject.c_pointer).to be_a(described_class::AutoPointer)
      expect(subject.c_pointer).not_to be_null
    end
  end
end
