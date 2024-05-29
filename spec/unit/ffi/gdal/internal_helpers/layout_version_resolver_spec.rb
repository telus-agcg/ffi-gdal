# frozen_string_literal: true

require "ffi/gdal"

RSpec.describe FFI::GDAL::InternalHelpers::LayoutVersionResolver do
  describe "#resolve" do
    subject(:layout) { described_class.resolve(versions: versions) }

    let(:versions) do
      [
        FFI::GDAL::InternalHelpers::LayoutVersion.new(
          version: "0000000",
          layout: %i[radius1 double]
        ),
        FFI::GDAL::InternalHelpers::LayoutVersion.new(
          version: "3060000",
          layout: %i[radius2 double]
        ),
        FFI::GDAL::InternalHelpers::LayoutVersion.new(
          version: "3080000",
          layout: %i[radius3 double]
        )
      ]
    end

    context "when GDAL is version 3.2.0" do
      it "returns layout for old versions (0000000)" do
        allow(FFI::GDAL::InternalHelpers::GDALVersion).to receive(:version).and_return("3020000")

        expect(layout).to eq(%i[radius1 double])

        expect(FFI::GDAL::InternalHelpers::GDALVersion).to have_received(:version)
      end
    end

    context "when GDAL is version 3.6.0" do
      it "returns layout for version 3060000" do
        allow(FFI::GDAL::InternalHelpers::GDALVersion).to receive(:version).and_return("3060000")

        expect(layout).to eq(%i[radius2 double])

        expect(FFI::GDAL::InternalHelpers::GDALVersion).to have_received(:version)
      end
    end

    context "when GDAL is version 3.6.1" do
      it "returns layout for version 3060000" do
        allow(FFI::GDAL::InternalHelpers::GDALVersion).to receive(:version).and_return("3060100")

        expect(layout).to eq(%i[radius2 double])

        expect(FFI::GDAL::InternalHelpers::GDALVersion).to have_received(:version)
      end
    end

    context "when GDAL is version 3.9.0" do
      it "returns layout for version 3080000" do
        allow(FFI::GDAL::InternalHelpers::GDALVersion).to receive(:version).and_return("3080000")

        expect(layout).to eq(%i[radius3 double])

        expect(FFI::GDAL::InternalHelpers::GDALVersion).to have_received(:version)
      end
    end
  end
end
