# frozen_string_literal: true

require 'ogr/spatial_reference'

module OGR
  class SpatialReference
    module Extensions
      # @param unit_label [Symbol, String] Must match one of the known angular
      #   unit types from FFI::GDAL::SRS_UA.  Since there are only two, pick either
      #   :radian or :degree.
      # @raise [NameError] If the +unit_label+ isn't of a known type.
      def angular_units=(unit_label)
        unit_name = unit_label.to_s.upcase
        unit_label = self.class.const_get("#{unit_name}_LABEL".to_sym)
        unit_value = self.class.const_get("RADIAN_TO_#{unit_name}".to_sym)

        set_angular_units(unit_label, unit_value)
      rescue NameError
        raise NameError, "Param must be a known angular unit type: #{unit_label}"
      end

      # @param unit_label [Symbol, String] Must match one of the known linear
      #   unit types from FFI::GDAL::SRS_UL.  I.e. :us_foot.
      # @raise [NameError] If the +unit_label+ isn't of a known type.
      def linear_units=(unit_label)
        unit_name = unit_label.to_s.upcase
        unit_label = self.class.const_get("#{unit_name}_LABEL".to_sym)
        unit_value = self.class.const_get("METER_TO_#{unit_name}".to_sym)

        set_linear_units(unit_label, unit_value)
      rescue NameError
        raise NameError, "Param must be a known linear unit type: #{unit_label}"
      end
    end
  end
end

OGR::SpatialReference.include(OGR::SpatialReference::Extensions)
