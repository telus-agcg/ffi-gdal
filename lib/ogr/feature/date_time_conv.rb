# frozen_string_literal: true

require 'date'
require_relative '../../ogr'

module OGR
  class Feature
    module DateTimeConv
      Pointers = Struct.new(:year, :month, :day, :hour, :minute, :time_zone) do
        def initialize
          super

          self.year = FFI::MemoryPointer.new(:int)
          self.month = FFI::MemoryPointer.new(:int)
          self.day = FFI::MemoryPointer.new(:int)
          self.hour = FFI::MemoryPointer.new(:int)
          self.minute = FFI::MemoryPointer.new(:int)
          self.time_zone = FFI::MemoryPointer.new(:int)
        end
      end

      Values = Struct.new(:year, :month, :day, :hour, :minute, :time_zone) do
        def from_pointers(pointers)
          self.year = pointers.year.read_int
          self.month = pointers.month.read_int
          self.day = pointers.day.read_int
          self.hour = pointers.hour.read_int
          self.minute = pointers.minute.read_int
          self.time_zone = pointers.time_zone.read_int

          self
        end

        def to_date_time(seconds)
          formatted_tz = OGR._format_time_zone_for_ruby(time_zone)

          if formatted_tz
            DateTime.new(
              year,
              month,
              day,
              hour,
              minute,
              seconds,
              formatted_tz
            )
          else
            DateTime.new(
              year,
              month,
              day,
              hour,
              minute,
              seconds
            )
          end
        end
      end
    end
  end
end
