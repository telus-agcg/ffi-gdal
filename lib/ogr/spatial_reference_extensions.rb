require 'json'

module OGR
  module SpatialReferenceExtensions
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

    # @return [Hash]
    def as_json(_options = nil)
      {
        angular_units: angular_units,
        epsg_treats_as_lat_long: epsg_treats_as_lat_long?,
        epsg_treats_as_northing_easting: epsg_treats_as_northing_easting?,
        is_compound: compound?,
        is_geocentric: geocentric?,
        is_geographic: geographic?,
        is_local: local?,
        is_projected: projected?,
        is_vertical: vertical?,
        linear_units: linear_units,
        prime_meridian: prime_meridian,
        semi_major: semi_major,
        semi_minor: semi_minor,
        spheroid_inverse_flattening: spheroid_inverse_flattening,
        utm_zone: utm_zone
      }
    end

    # @return [String]
    def to_json(options = nil)
      as_json(options).to_json
    end
  end
end
