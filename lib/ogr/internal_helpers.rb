# frozen_string_literal: true

require 'time'

module OGR
  # @private
  module InternalHelpers
    # Makes the interface consistent with the access flags for GDAL.
    #
    # @param flag [String] 'w' for writing, 'r' for reading.
    def _boolean_access_flag(flag)
      case flag
      when 'w' then return true
      when 'r' then return false
      end

      raise "Invalid access_flag '#{flag}'.  Use 'r' or 'w'."
    end

    # OGR's time zone rules:
    #   * 0 = unknown
    #   * 1 = local time
    #   * 100 = GMT
    #
    # This converts the OGR integer into something usable by Ruby's DateTime.
    #
    # @param time_zone [Integer]
    def _format_time_zone_for_ruby(time_zone)
      if time_zone.zero? then nil
      elsif time_zone == 1 then (Time.now.getlocal.utc_offset / 3600).to_s
      elsif time_zone == 100 then '+0'
      else
        raise "Unable to process time zone: #{time_zone}"
      end
    end

    # OGR's time zone rules:
    #   * 0 = unknown
    #   * 1 = local time
    #   * 100 = GMT
    #
    # This converts Ruby's DateTime time zone info into OGR's integer.
    #
    # @param time_zone [String]
    def _format_time_zone_for_ogr(time_zone)
      if /(00:00|GMT)\z/.match?(time_zone) then 100
      elsif time_zone then 1
      else
        0
      end
    end
  end
end
