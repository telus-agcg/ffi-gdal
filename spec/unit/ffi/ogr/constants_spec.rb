# frozen_string_literal: true

require "ffi/gdal"
require "ogr/layer"
require "ogr/spatial_reference"

RSpec.describe "Validate hardcoded OGR constants against GDAL" do
  # Helper to dynamically load constants from GDAL headers
  def load_dynamic_constants(name, &block)
    generator = FFI::ConstGenerator.new(name, &block)
    generator.calculate
    generator
  end

  describe "OGR::Layer ALTER constants" do
    let(:dynamic_constants) do
      load_dynamic_constants("OGR_ALTER") do |gen|
        gen.include FFI::GDAL._file_with_constants("ogr_core.h")
        gen.const :ALTER_NAME_FLAG,            "%x", nil, :ALTER_NAME_FLAG
        gen.const :ALTER_TYPE_FLAG,            "%x", nil, :ALTER_TYPE_FLAG
        gen.const :ALTER_WIDTH_PRECISION_FLAG, "%x", nil, :ALTER_WIDTH_PRECISION_FLAG
      end
    end

    it "hardcoded constants match dynamically loaded values" do
      dynamic_constants.constants.each_value do |const|
        ruby_const_name = const.ruby_name
        hardcoded_value = OGR::Layer.const_get(ruby_const_name)
        # Convert hex string to integer for comparison
        expected_value = const.value.to_i(16)

        expect(hardcoded_value).to(
          eq(expected_value),
          "#{ruby_const_name}: expected #{expected_value}, got #{hardcoded_value}"
        )
      end
    end

    it "has all required constants defined" do
      dynamic_constants.constants.each_value do |const|
        ruby_const_name = const.ruby_name
        expect(OGR::Layer.const_defined?(ruby_const_name)).to(
          be(true),
          "Missing constant: OGR::Layer::#{ruby_const_name}"
        )
      end
    end

    it "computed ALTER_UNION_NAME_TYPE_WIDTH_PRECISION_FLAG equals bitwise OR of component flags" do
      expected = OGR::Layer::ALTER_NAME_FLAG | OGR::Layer::ALTER_TYPE_FLAG | OGR::Layer::ALTER_WIDTH_PRECISION_FLAG
      expect(OGR::Layer::ALTER_UNION_NAME_TYPE_WIDTH_PRECISION_FLAG).to eq(expected)
    end
  end

  describe "OGR::SpatialReference SRS_UL constants" do
    let(:dynamic_constants) do
      load_dynamic_constants("SRS_UL") do |gen|
        gen.include FFI::GDAL._file_with_constants("ogr_srs_api.h")
        gen.const :SRS_UL_METER,              "%s", nil, :METER_LABEL, &:inspect
        gen.const :SRS_UL_FOOT,               "%s", nil, :FOOT_LABEL, &:inspect
        gen.const :SRS_UL_FOOT_CONV,          "%s", nil, :METER_TO_FOOT, &:to_f
        gen.const :SRS_UL_NAUTICAL_MILE,      "%s", nil, :NAUTICAL_MILE_LABEL, &:inspect
        gen.const :SRS_UL_NAUTICAL_MILE_CONV, "%s", nil, :METER_TO_NAUTICAL_MILE, &:to_f
        gen.const :SRS_UL_LINK,               "%s", nil, :LINK_LABEL, &:inspect
        gen.const :SRS_UL_LINK_CONV,          "%s", nil, :METER_TO_LINK, &:to_f
        gen.const :SRS_UL_CHAIN,              "%s", nil, :CHAIN_LABEL, &:inspect
        gen.const :SRS_UL_CHAIN_CONV,         "%s", nil, :METER_TO_CHAIN, &:to_f
        gen.const :SRS_UL_ROD,                "%s", nil, :ROD_LABEL, &:inspect
        gen.const :SRS_UL_ROD_CONV,           "%s", nil, :METER_TO_ROD, &:to_f
        gen.const :SRS_UL_LINK_Clarke,        "%s", nil, :LINK_CLARKE_LABEL, &:inspect
        gen.const :SRS_UL_LINK_Clarke_CONV,   "%s", nil, :METER_TO_LINK_CLARKE, &:to_f
        gen.const :SRS_UL_KILOMETER,          "%s", nil, :KILOMETER_LABEL, &:inspect
        gen.const :SRS_UL_KILOMETER_CONV,     "%s", nil, :METER_TO_KILOMETER, &:to_f
        gen.const :SRS_UL_DECIMETER,          "%s", nil, :DECIMETER_LABEL, &:inspect
        gen.const :SRS_UL_DECIMETER_CONV,     "%s", nil, :METER_TO_DECIMETER, &:to_f
        gen.const :SRS_UL_CENTIMETER,         "%s", nil, :CENTIMETER_LABEL, &:inspect
        gen.const :SRS_UL_CENTIMETER_CONV,    "%s", nil, :METER_TO_CENTIMETER, &:to_f
        gen.const :SRS_UL_MILLIMETER,         "%s", nil, :MILLIMETER_LABEL, &:inspect
        gen.const :SRS_UL_MILLIMETER_CONV,    "%s", nil, :METER_TO_MILLIMETER, &:to_f
        gen.const :SRS_UL_INTL_NAUT_MILE,     "%s", nil, :INTL_NAUTICAL_MILE_LABEL, &:inspect
        gen.const :SRS_UL_INTL_NAUT_MILE_CONV, "%s", nil, :METER_TO_INTL_NAUTICAL_MILE, &:to_f
        gen.const :SRS_UL_INTL_INCH,          "%s", nil, :INTL_INCH_LABEL, &:inspect
        gen.const :SRS_UL_INTL_INCH_CONV,     "%s", nil, :METER_TO_INTL_INCH, &:to_f
        gen.const :SRS_UL_INTL_FOOT,          "%s", nil, :INTL_FOOT_LABEL, &:inspect
        gen.const :SRS_UL_INTL_FOOT_CONV,     "%s", nil, :METER_TO_INTL_FOOT, &:to_f
        gen.const :SRS_UL_INTL_YARD,          "%s", nil, :INTL_YARD_LABEL, &:inspect
        gen.const :SRS_UL_INTL_YARD_CONV,     "%s", nil, :METER_TO_INTL_YARD, &:to_f
        gen.const :SRS_UL_INTL_STAT_MILE,     "%s", nil, :INTL_STATUTE_MILE_LABEL, &:inspect
        gen.const :SRS_UL_INTL_STAT_MILE_CONV, "%s", nil, :METER_TO_INTL_STATUTE_MILE, &:to_f
        gen.const :SRS_UL_INTL_FATHOM,        "%s", nil, :INTL_FATHOM_LABEL, &:inspect
        gen.const :SRS_UL_INTL_FATHOM_CONV,   "%s", nil, :METER_TO_INTL_FATHOM, &:to_f
        gen.const :SRS_UL_INTL_CHAIN,         "%s", nil, :INTL_CHAIN_LABEL, &:inspect
        gen.const :SRS_UL_INTL_CHAIN_CONV,    "%s", nil, :METER_TO_INTL_CHAIN, &:to_f
        gen.const :SRS_UL_INTL_LINK,          "%s", nil, :INTL_LINK_LABEL, &:inspect
        gen.const :SRS_UL_INTL_LINK_CONV,     "%s", nil, :METER_TO_INTL_LINK, &:to_f
        gen.const :SRS_UL_US_INCH,            "%s", nil, :US_INCH_LABEL, &:inspect
        gen.const :SRS_UL_US_INCH_CONV,       "%s", nil, :METER_TO_US_INCH, &:to_f
        gen.const :SRS_UL_US_FOOT,            "%s", nil, :US_FOOT_LABEL, &:inspect
        gen.const :SRS_UL_US_FOOT_CONV,       "%s", nil, :METER_TO_US_FOOT, &:to_f
        gen.const :SRS_UL_US_YARD,            "%s", nil, :US_YARD_LABEL, &:inspect
        gen.const :SRS_UL_US_YARD_CONV,       "%s", nil, :METER_TO_US_YARD, &:to_f
        gen.const :SRS_UL_US_CHAIN,           "%s", nil, :US_CHAIN_LABEL, &:inspect
        gen.const :SRS_UL_US_CHAIN_CONV,      "%s", nil, :METER_TO_US_CHAIN, &:to_f
        gen.const :SRS_UL_US_STAT_MILE,       "%s", nil, :US_STATUTE_MILE_LABEL, &:inspect
        gen.const :SRS_UL_US_STAT_MILE_CONV,  "%s", nil, :METER_TO_US_STATUTE_MILE, &:to_f
        gen.const :SRS_UL_INDIAN_YARD,        "%s", nil, :INDIAN_YARD_LABEL, &:inspect
        gen.const :SRS_UL_INDIAN_YARD_CONV,   "%s", nil, :METER_TO_INDIAN_YARD, &:to_f
        gen.const :SRS_UL_INDIAN_FOOT,        "%s", nil, :INDIAN_FOOT_LABEL, &:inspect
        gen.const :SRS_UL_INDIAN_FOOT_CONV,   "%s", nil, :METER_TO_INDIAN_FOOT, &:to_f
        gen.const :SRS_UL_INDIAN_CHAIN,       "%s", nil, :INDIAN_CHAIN_LABEL, &:inspect
        gen.const :SRS_UL_INDIAN_CHAIN_CONV,  "%s", nil, :METER_TO_INDIAN_CHAIN, &:to_f
      end
    end

    it "hardcoded constants match dynamically loaded values" do
      dynamic_constants.constants.each_value do |const|
        ruby_const_name = const.ruby_name
        hardcoded_value = OGR::SpatialReference.const_get(ruby_const_name)
        # Convert string to number if hardcoded value is numeric
        expected_value = hardcoded_value.is_a?(Numeric) ? const.value.to_f : const.value

        expect(hardcoded_value).to(
          eq(expected_value),
          "#{ruby_const_name}: expected #{expected_value.inspect}, got #{hardcoded_value.inspect}"
        )
      end
    end

    it "has all required constants defined" do
      dynamic_constants.constants.each_value do |const|
        ruby_const_name = const.ruby_name
        message = "Missing constant: OGR::SpatialReference::#{ruby_const_name}"
        expect(OGR::SpatialReference.const_defined?(ruby_const_name)).to be(true), message
      end
    end
  end

  describe "OGR::SpatialReference SRS_UA constants" do
    let(:dynamic_constants) do
      load_dynamic_constants("SRS_UA") do |gen|
        gen.include FFI::GDAL._file_with_constants("ogr_srs_api.h")
        gen.const :SRS_UA_DEGREE,       "%s", nil, :DEGREE_LABEL, &:inspect
        gen.const :SRS_UA_DEGREE_CONV,  "%s", nil, :RADIAN_TO_DEGREE, &:to_f
        gen.const :SRS_UA_RADIAN,       "%s", nil, :RADIAN_LABEL, &:inspect
      end
    end

    it "hardcoded constants match dynamically loaded values" do
      dynamic_constants.constants.each_value do |const|
        ruby_const_name = const.ruby_name
        hardcoded_value = OGR::SpatialReference.const_get(ruby_const_name)
        # Convert string to number if hardcoded value is numeric
        expected_value = hardcoded_value.is_a?(Numeric) ? const.value.to_f : const.value

        expect(hardcoded_value).to(
          eq(expected_value),
          "#{ruby_const_name}: expected #{expected_value.inspect}, got #{hardcoded_value.inspect}"
        )
      end
    end

    it "has all required constants defined" do
      dynamic_constants.constants.each_value do |const|
        ruby_const_name = const.ruby_name
        expect(OGR::SpatialReference.const_defined?(ruby_const_name)).to(
          be(true),
          "Missing constant: OGR::SpatialReference::#{ruby_const_name}"
        )
      end
    end
  end
end
