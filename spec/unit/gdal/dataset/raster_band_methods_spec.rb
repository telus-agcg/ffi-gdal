# frozen_string_literal: true

require "fileutils"
require "tmpdir"
require "gdal"

RSpec.describe GDAL::Dataset::RasterBandMethods do
  include_context "A .tif Dataset"

  describe ".valid_min_buffer_size" do
    it "returns the number of bytes for the GDT type * x buffer size * y buffer size" do
      expect(described_class.valid_min_buffer_size(:GDT_Float32, 3, 4)).to eq 48
    end
  end

  describe ".parse_mask_flag_symbols" do
    context "empty params" do
      it "returns 0" do
        expect(described_class.parse_mask_flag_symbols(nil)).to eq 0
      end
    end

    context ":GMF_ALL_VALID" do
      it "returns 1" do
        expect(described_class.parse_mask_flag_symbols(:GMF_ALL_VALID)).to eq 1
      end
    end

    context ":GMF_ALL_VALID, :GMF_NODATA" do
      it "returns 9 (the flag bits ORed together)" do
        expect(described_class.parse_mask_flag_symbols(:GMF_ALL_VALID, :GMF_NODATA)).to eq 9
      end
    end

    context ":GMF_PER_ALPHA" do
      it "returns 4" do
        expect(described_class.parse_mask_flag_symbols(:GMF_PER_ALPHA)).to eq 4
      end
    end

    context ":GMF_ALPHA" do
      it "returns 4 (GDAL's own name for the GMF_PER_ALPHA bit)" do
        expect(described_class.parse_mask_flag_symbols(:GMF_ALPHA)).to eq 4
      end
    end
  end

  describe "#raster_x_size" do
    it "returns an Integer" do
      expect(subject.raster_x_size).to eq 101
    end
  end

  describe "#raster_y_size" do
    it "returns an Integer" do
      expect(subject.raster_y_size).to eq 101
    end
  end

  describe "#raster_count" do
    it "returns an Integer" do
      expect(subject.raster_count).to eq 1
    end
  end

  describe "#raster_band" do
    it "returns a GDAL::RasterBand" do
      expect(subject.raster_band(1)).to be_a GDAL::RasterBand
    end
  end

  describe "#add_band" do
    it "raises a GDAL::UnsupportedOperation" do
      expect { subject.add_band(:GDT_Byte) }.to raise_exception(GDAL::UnsupportedOperation)
    end
  end

  describe "#create_mask_band" do
    # GDAL 3.9 changed the GDAL_TIFF_INTERNAL_MASK default from NO to YES, so
    # the config option is set explicitly here to get the same behaviour on
    # every GDAL version.
    context "no flags given, GDAL_TIFF_INTERNAL_MASK=NO" do
      around do |example|
        previous_value = FFI::CPL::Conv.CPLGetConfigOption("GDAL_TIFF_INTERNAL_MASK", nil).first.dup
        FFI::CPL::Conv.CPLSetConfigOption("GDAL_TIFF_INTERNAL_MASK", "NO")
        example.run
        FFI::CPL::Conv.CPLSetConfigOption("GDAL_TIFF_INTERNAL_MASK", previous_value)
      end

      # Use a temp copy: the external mask is written next to the opened file,
      # and the fixture directory has a committed .msk sidecar to preserve.
      it "creates an external mask band" do
        Dir.mktmpdir do |tmp_dir|
          tmp_tiff = File.join(tmp_dir, "raster_band_methods.tif")
          FileUtils.cp(file_path, tmp_tiff)

          GDAL::Dataset.open(tmp_tiff, "r", shared: false) do |dataset|
            expect(dataset.create_mask_band).to be_nil
          end

          expect(File).to exist("#{tmp_tiff}.msk")
        end
      end
    end

    context "no flags given, GDAL_TIFF_INTERNAL_MASK=YES" do
      around do |example|
        previous_value = FFI::CPL::Conv.CPLGetConfigOption("GDAL_TIFF_INTERNAL_MASK", nil).first.dup
        FFI::CPL::Conv.CPLSetConfigOption("GDAL_TIFF_INTERNAL_MASK", "YES")
        example.run
        FFI::CPL::Conv.CPLSetConfigOption("GDAL_TIFF_INTERNAL_MASK", previous_value)
      end

      it "raises a GDAL::Error (internal mask supports only GMF_PER_DATASET)" do
        expect { subject.create_mask_band }.to raise_exception(
          GDAL::Error, /The only flag value supported for internal mask is GMF_PER_DATASET/
        )
      end
    end
  end
end
