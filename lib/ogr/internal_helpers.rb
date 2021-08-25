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
      when 'w' then true
      when 'r' then false
      else raise "Invalid access_flag '#{flag}'.  Use 'r' or 'w'."
      end
    end

    # OGR's time zone rules:
    #   * 0 = unknown
    #   * 1 = local time
    #   * 100 = GMT
    #
    # This converts the OGR integer into something usable by Ruby's DateTime.
    #
    # @param time_zone [0, 1, 100]
    # @return [String, nil]
    # @raise [RuntimeError] if +time_zone+ is not 0, 1, or 100.
    def _format_time_zone_for_ruby(time_zone)
      case time_zone
      when 0 then nil
      when 1 then (Time.now.getlocal.utc_offset / 3600).to_s
      when 100 then '+0'
      else raise "Unable to process time zone: #{time_zone}"
      end
    end

    # OGR's time zone rules:
    #   * 0 = unknown
    #   * 1 = local time
    #   * 100 = GMT
    #
    # This converts Ruby's DateTime time zone info into OGR's integer.
    #
    # @param time_zone [String, nil]
    # @return [0, 1, 100]
    def _format_time_zone_for_ogr(time_zone)
      if /(00:00|GMT)\z/.match?(time_zone)
        100
      elsif time_zone
        1
      else
        0
      end
    end
  end
end
