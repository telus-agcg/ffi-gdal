require 'json'

module OGR
  module SpatialReferenceExtensions

    # @return [Hash]
    def as_json
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
    def to_json
      as_json.to_json
    end
  end
end
