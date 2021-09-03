# frozen_string_literal: true

require 'ffi'
require_relative '../../ext/ffi_library_function_checks'
require_relative '../gdal'
require_relative 'srs_api/spatial_reference'
require_relative 'srs_api/coordinate_transformation'

module FFI
  module OGR
    module SRSAPI
      extend ::FFI::Library
      @ffi_libs = FFI::GDAL.loaded_ffi_libs

      # -----------------------------------------------------------------------
      # Enums
      # -----------------------------------------------------------------------
      AxisOrientation = enum %i[OAO_Other
                                OAO_North
                                OAO_South
                                OAO_East
                                OAO_West
                                OAO_Up
                                OAO_Down]

      # -----------------------------------------------------------------------
      # Constants
      # -----------------------------------------------------------------------
      SRS_UL = FFI::ConstGenerator.new('SRS_UL') do |gen|
        gen.include FFI::GDAL._file_with_constants('ogr_srs_api.h')
        gen.const :SRS_UL_METER,              '%s', nil, :METER_LABEL, &:inspect
        gen.const :SRS_UL_FOOT,               '%s', nil, :FOOT_LABEL, &:inspect
        gen.const :SRS_UL_FOOT_CONV,          '%s', nil, :METER_TO_FOOT, &:to_f
        gen.const :SRS_UL_NAUTICAL_MILE,      '%s', nil, :NAUTICAL_MILE_LABEL, &:inspect
        gen.const :SRS_UL_NAUTICAL_MILE_CONV, '%s', nil, :METER_TO_NAUTICAL_MILE, &:to_f
        gen.const :SRS_UL_LINK,               '%s', nil, :LINK_LABEL, &:inspect
        gen.const :SRS_UL_LINK_CONV,          '%s', nil, :METER_TO_LINK, &:to_f
        gen.const :SRS_UL_CHAIN,              '%s', nil, :CHAIN_LABEL, &:inspect
        gen.const :SRS_UL_CHAIN_CONV,         '%s', nil, :METER_TO_CHAIN, &:to_f
        gen.const :SRS_UL_ROD,                '%s', nil, :ROD_LABEL, &:inspect
        gen.const :SRS_UL_ROD_CONV,           '%s', nil, :METER_TO_ROD, &:to_f
        gen.const :SRS_UL_LINK_Clarke,        '%s', nil, :LINK_CLARKE_LABEL, &:inspect
        gen.const :SRS_UL_LINK_Clarke_CONV,   '%s', nil, :METER_TO_LINK_CLARKE, &:to_f
        gen.const :SRS_UL_KILOMETER,          '%s', nil, :KILOMETER_LABEL, &:inspect
        gen.const :SRS_UL_KILOMETER_CONV,     '%s', nil, :METER_TO_KILOMETER, &:to_f
        gen.const :SRS_UL_DECIMETER,          '%s', nil, :DECIMETER_LABEL, &:inspect
        gen.const :SRS_UL_DECIMETER_CONV,     '%s', nil, :METER_TO_DECIMETER, &:to_f
        gen.const :SRS_UL_CENTIMETER,         '%s', nil, :CENTIMETER_LABEL, &:inspect
        gen.const :SRS_UL_CENTIMETER_CONV,    '%s', nil, :METER_TO_CENTIMETER, &:to_f
        gen.const :SRS_UL_MILLIMETER,         '%s', nil, :MILLIMETER_LABEL, &:inspect
        gen.const :SRS_UL_MILLIMETER_CONV,    '%s', nil, :METER_TO_MILLIMETER, &:to_f
        gen.const :SRS_UL_INTL_NAUT_MILE,     '%s', nil, :INTL_NAUTICAL_MILE_LABEL, &:inspect
        gen.const :SRS_UL_INTL_NAUT_MILE_CONV, '%s', nil, :METER_TO_INTL_NAUTICAL_MILE, &:to_f
        gen.const :SRS_UL_INTL_INCH,          '%s', nil, :INTL_INCH_LABEL, &:inspect
        gen.const :SRS_UL_INTL_INCH_CONV,     '%s', nil, :METER_TO_INTL_INCH, &:to_f
        gen.const :SRS_UL_INTL_FOOT,          '%s', nil, :INTL_FOOT_LABEL, &:inspect
        gen.const :SRS_UL_INTL_FOOT_CONV,     '%s', nil, :METER_TO_INTL_FOOT, &:to_f
        gen.const :SRS_UL_INTL_YARD,          '%s', nil, :INTL_YARD_LABEL, &:inspect
        gen.const :SRS_UL_INTL_YARD_CONV,     '%s', nil, :METER_TO_INTL_YARD, &:to_f
        gen.const :SRS_UL_INTL_STAT_MILE,     '%s', nil, :INTL_STATUTE_MILE_LABEL, &:inspect
        gen.const :SRS_UL_INTL_STAT_MILE_CONV, '%s', nil, :METER_TO_INTL_STATUTE_MILE, &:to_f
        gen.const :SRS_UL_INTL_FATHOM,        '%s', nil, :INTL_FATHOM_LABEL, &:inspect
        gen.const :SRS_UL_INTL_FATHOM_CONV,   '%s', nil, :METER_TO_INTL_FATHOM, &:to_f
        gen.const :SRS_UL_INTL_CHAIN,         '%s', nil, :INTL_CHAIN_LABEL, &:inspect
        gen.const :SRS_UL_INTL_CHAIN_CONV,    '%s', nil, :METER_TO_INTL_CHAIN, &:to_f
        gen.const :SRS_UL_INTL_LINK,          '%s', nil, :INTL_LINK_LABEL, &:inspect
        gen.const :SRS_UL_INTL_LINK_CONV,     '%s', nil, :METER_TO_INTL_LINK, &:to_f
        gen.const :SRS_UL_US_INCH,            '%s', nil, :US_INCH_LABEL, &:inspect
        gen.const :SRS_UL_US_INCH_CONV,       '%s', nil, :METER_TO_US_INCH, &:to_f
        gen.const :SRS_UL_US_FOOT,            '%s', nil, :US_FOOT_LABEL, &:inspect
        gen.const :SRS_UL_US_FOOT_CONV,       '%s', nil, :METER_TO_US_FOOT, &:to_f
        gen.const :SRS_UL_US_YARD,            '%s', nil, :US_YARD_LABEL, &:inspect
        gen.const :SRS_UL_US_YARD_CONV,       '%s', nil, :METER_TO_US_YARD, &:to_f
        gen.const :SRS_UL_US_CHAIN,           '%s', nil, :US_CHAIN_LABEL, &:inspect
        gen.const :SRS_UL_US_CHAIN_CONV,      '%s', nil, :METER_TO_US_CHAIN, &:to_f
        gen.const :SRS_UL_US_STAT_MILE,       '%s', nil, :US_STATUTE_MILE_LABEL, &:inspect
        gen.const :SRS_UL_US_STAT_MILE_CONV,  '%s', nil, :METER_TO_US_STATUTE_MILE, &:to_f
        gen.const :SRS_UL_INDIAN_YARD,        '%s', nil, :INDIAN_YARD_LABEL, &:inspect
        gen.const :SRS_UL_INDIAN_YARD_CONV,   '%s', nil, :METER_TO_INDIAN_YARD, &:to_f
        gen.const :SRS_UL_INDIAN_FOOT,        '%s', nil, :INDIAN_FOOT_LABEL, &:inspect
        gen.const :SRS_UL_INDIAN_FOOT_CONV,   '%s', nil, :METER_TO_INDIAN_FOOT, &:to_f
        gen.const :SRS_UL_INDIAN_CHAIN,       '%s', nil, :INDIAN_CHAIN_LABEL, &:inspect
        gen.const :SRS_UL_INDIAN_CHAIN_CONV,  '%s', nil, :METER_TO_INDIAN_CHAIN, &:to_f
      end

      SRS_UL.calculate

      SRS_UA = FFI::ConstGenerator.new('SRS_UL') do |gen|
        gen.include FFI::GDAL._file_with_constants('ogr_srs_api.h')
        gen.const :SRS_UA_DEGREE,       '%s', nil, :DEGREE_LABEL, &:inspect
        gen.const :SRS_UA_DEGREE_CONV,  '%s', nil, :RADIAN_TO_DEGREE, &:to_f
        gen.const :SRS_UA_RADIAN,       '%s', nil, :RADIAN_LABEL, &:inspect
      end
      SRS_UA.calculate

      # -----------------------------------------------------------------------
      # Functions
      # -----------------------------------------------------------------------
      # ~~~~~~~~~~~~~
      # AxisOrientations
      # ~~~~~~~~~~~~~
      attach_function :OSRAxisEnumToName, [AxisOrientation], :string
    end
  end
end
