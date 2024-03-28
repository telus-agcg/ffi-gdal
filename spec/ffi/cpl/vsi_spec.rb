# frozen_string_literal: true

require "gdal"

RSpec.describe FFI::CPL::VSI do
  if GDAL.version_num >= "3060000"
    describe "VSI PathSpecificOptions" do
      around do |example|
        FFI::CPL::VSI.VSIClearPathSpecificOptions(nil)
        example.run
        FFI::CPL::VSI.VSIClearPathSpecificOptions(nil)
      end

      describe "VSIClearPathSpecificOptions" do
        it "properly clears credentials" do
          FFI::CPL::VSI.VSISetPathSpecificOption("/vsis3/test", "Key1234", "Value1234")
          expect(FFI::CPL::VSI.VSIGetPathSpecificOption("/vsis3/test", "Key1234", nil)).to eq("Value1234")

          FFI::CPL::VSI.VSIClearPathSpecificOptions(nil)
          expect(FFI::CPL::VSI.VSIGetPathSpecificOption("/vsis3/test", "Key1234", nil)).to be(nil)
        end
      end

      describe "VSISetPathSpecificOption" do
        it "properly sets credential" do
          expect(FFI::CPL::VSI.VSIGetPathSpecificOption("/vsis3/test", "Key1234", nil)).to be(nil)

          FFI::CPL::VSI.VSISetPathSpecificOption("/vsis3/test", "Key1234", "Value1234")
          expect(FFI::CPL::VSI.VSIGetPathSpecificOption("/vsis3/test", "Key1234", nil)).to eq("Value1234")
        end
      end

      describe "VSIGetPathSpecificOption" do
        it "properly get credential" do
          expect(FFI::CPL::VSI.VSIGetPathSpecificOption("/vsis3/test", "Key1234", nil)).to be(nil)
          expect(FFI::CPL::VSI.VSIGetPathSpecificOption("/vsis3/test", "Key1234", "DefaultValue1234")).to eq("DefaultValue1234")

          FFI::CPL::VSI.VSISetPathSpecificOption("/vsis3/test", "Key1234", "Value1234")

          expect(FFI::CPL::VSI.VSIGetPathSpecificOption("/vsis3/test", "Key1234", nil)).to eq("Value1234")
          expect(FFI::CPL::VSI.VSIGetPathSpecificOption("/vsis3/test", "Key1234", "DefaultValue1234")).to eq("Value1234")
        end
      end
    end
  end

  if GDAL.version_num >= "3050000"
    describe "VSI Credential" do
      around do |example|
        FFI::CPL::VSI.VSIClearCredentials(nil)
        example.run
        FFI::CPL::VSI.VSIClearCredentials(nil)
      end

      describe "VSIClearCredentials" do
        it "properly clears credentials" do
          FFI::CPL::VSI.VSISetCredential("/vsis3/test", "Key1234", "Value1234")
          expect(FFI::CPL::VSI.VSIGetCredential("/vsis3/test", "Key1234", nil)).to eq("Value1234")

          FFI::CPL::VSI.VSIClearCredentials(nil)
          expect(FFI::CPL::VSI.VSIGetCredential("/vsis3/test", "Key1234", nil)).to be(nil)
        end
      end

      describe "VSISetCredential" do
        it "properly sets credential" do
          expect(FFI::CPL::VSI.VSIGetCredential("/vsis3/test", "Key1234", nil)).to be(nil)

          FFI::CPL::VSI.VSISetCredential("/vsis3/test", "Key1234", "Value1234")
          expect(FFI::CPL::VSI.VSIGetCredential("/vsis3/test", "Key1234", nil)).to eq("Value1234")
        end
      end

      describe "VSIGetCredential" do
        it "properly get credential" do
          expect(FFI::CPL::VSI.VSIGetCredential("/vsis3/test", "Key1234", nil)).to be(nil)
          expect(FFI::CPL::VSI.VSIGetCredential("/vsis3/test", "Key1234", "DefaultValue1234")).to eq("DefaultValue1234")

          FFI::CPL::VSI.VSISetCredential("/vsis3/test", "Key1234", "Value1234")

          expect(FFI::CPL::VSI.VSIGetCredential("/vsis3/test", "Key1234", nil)).to eq("Value1234")
          expect(FFI::CPL::VSI.VSIGetCredential("/vsis3/test", "Key1234", "DefaultValue1234")).to eq("Value1234")
        end
      end
    end
  end
end
