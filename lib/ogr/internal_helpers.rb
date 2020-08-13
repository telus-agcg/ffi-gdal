# frozen_string_literal: true

require 'time'

module OGR
  module InternalHelpers
    def self.included(base)
      base.extend(ClassMethods)
    end

    # @private
    module ClassMethods
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

      def _open_flag(access_flag, shared_mode: false)
        driver_kind_flag = FFI::GDAL::GDAL::GDAL_OF_VECTOR

        access_mode_flag = case access_flag
                           when 'w' then FFI::GDAL::GDAL::GDAL_OF_UPDATE
                           when 'r' then FFI::GDAL::GDAL::GDAL_OF_READONLY
                           else raise "Invalid access_flag '#{flag}'.  Use 'r' or 'w'."
                           end

        shared_mode_flag = shared_mode ? FFI::GDAL::GDAL::GDAL_OF_SHARED : 0

        verbose_error_flag = FFI::GDAL::GDAL::GDAL_OF_VERBOSE_ERROR

        driver_kind_flag & access_mode_flag & shared_mode_flag & verbose_error_flag
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
      # @param time_zone [String]
      def _format_time_zone_for_ogr(time_zone)
        if time_zone =~ /(00:00|GMT)\z/
          100
        elsif time_zone
          1
        else
          0
        end
      end
    end
  end
end
