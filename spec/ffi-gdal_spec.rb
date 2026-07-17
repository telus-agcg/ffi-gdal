# frozen_string_literal: true

require "ffi-gdal"

RSpec.describe FFI do
  describe "autoload CPL" do
    it "can call CPL functions" do
      expect { FFI::CPL }.not_to raise_exception
    end
  end

  describe "autoload GDAL" do
    it "can call GDAL functions" do
      expect { FFI::GDAL }.not_to raise_exception
    end
  end

  describe "autoload OGR" do
    it "can call OGR functions" do
      expect { FFI::OGR }.not_to raise_exception
    end
  end
end
