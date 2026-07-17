# frozen_string_literal: true

require "gdal"

RSpec.describe FFI::CPL::VSI do
  if GDAL.version_num >= "3060000"
    describe "VSI PathSpecificOptions" do
      around do |example|
        described_class.VSIClearPathSpecificOptions(nil)
        example.run
        described_class.VSIClearPathSpecificOptions(nil)
      end

      describe "VSIClearPathSpecificOptions" do
        it "properly clears credentials" do
          described_class.VSISetPathSpecificOption("/vsis3/test", "Key1234", "Value1234")
          expect(described_class.VSIGetPathSpecificOption("/vsis3/test", "Key1234", nil)).to eq("Value1234")

          described_class.VSIClearPathSpecificOptions(nil)
          expect(described_class.VSIGetPathSpecificOption("/vsis3/test", "Key1234", nil)).to be_nil
        end
      end

      describe "VSISetPathSpecificOption" do
        it "properly sets credential" do
          expect(described_class.VSIGetPathSpecificOption("/vsis3/test", "Key1234", nil)).to be_nil

          described_class.VSISetPathSpecificOption("/vsis3/test", "Key1234", "Value1234")
          expect(described_class.VSIGetPathSpecificOption("/vsis3/test", "Key1234", nil)).to eq("Value1234")
        end
      end

      describe "VSIGetPathSpecificOption" do
        it "properly get credential" do
          expect(described_class.VSIGetPathSpecificOption("/vsis3/test", "Key1234", nil)).to be_nil
          expect(
            described_class.VSIGetPathSpecificOption("/vsis3/test", "Key1234", "DefaultValue1234")
          ).to eq("DefaultValue1234")

          described_class.VSISetPathSpecificOption("/vsis3/test", "Key1234", "Value1234")

          expect(described_class.VSIGetPathSpecificOption("/vsis3/test", "Key1234", nil)).to eq("Value1234")
          expect(
            described_class.VSIGetPathSpecificOption("/vsis3/test", "Key1234", "DefaultValue1234")
          ).to eq("Value1234")
        end
      end
    end
  end

  if GDAL.version_num >= "3050000"
    describe "VSI Credential" do
      around do |example|
        described_class.VSIClearCredentials(nil)
        example.run
        described_class.VSIClearCredentials(nil)
      end

      describe "VSIClearCredentials" do
        it "properly clears credentials" do
          described_class.VSISetCredential("/vsis3/test", "Key1234", "Value1234")
          expect(described_class.VSIGetCredential("/vsis3/test", "Key1234", nil)).to eq("Value1234")

          described_class.VSIClearCredentials(nil)
          expect(described_class.VSIGetCredential("/vsis3/test", "Key1234", nil)).to be_nil
        end
      end

      describe "VSISetCredential" do
        it "properly sets credential" do
          expect(described_class.VSIGetCredential("/vsis3/test", "Key1234", nil)).to be_nil

          described_class.VSISetCredential("/vsis3/test", "Key1234", "Value1234")
          expect(described_class.VSIGetCredential("/vsis3/test", "Key1234", nil)).to eq("Value1234")
        end
      end

      describe "VSIGetCredential" do
        it "properly get credential" do
          expect(described_class.VSIGetCredential("/vsis3/test", "Key1234", nil)).to be_nil
          expect(described_class.VSIGetCredential("/vsis3/test", "Key1234",
                                                  "DefaultValue1234")).to eq("DefaultValue1234")

          described_class.VSISetCredential("/vsis3/test", "Key1234", "Value1234")

          expect(described_class.VSIGetCredential("/vsis3/test", "Key1234", nil)).to eq("Value1234")
          expect(described_class.VSIGetCredential("/vsis3/test", "Key1234", "DefaultValue1234")).to eq("Value1234")
        end
      end
    end
  end
end
