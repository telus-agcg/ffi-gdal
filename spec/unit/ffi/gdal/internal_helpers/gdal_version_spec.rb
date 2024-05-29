# frozen_string_literal: true

require "ffi/gdal"

RSpec.describe FFI::GDAL::InternalHelpers::GDALVersion do
  describe "#version" do
    subject(:version) { described_class.version }

    it "returns string from FFI::GDAL::GDALVersionInfo" do
      allow(FFI::GDAL).to receive(:GDALVersionInfo).with("VERSION_NUM").and_return("3020123")

      expect(version).to eq("3020123")

      expect(FFI::GDAL).to have_received(:GDALVersionInfo).with("VERSION_NUM")
    end

    it "returns string of current GDAL version" do
      expect(version).to be_a(String)
    end
  end
end
