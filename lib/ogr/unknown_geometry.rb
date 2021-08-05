# frozen_string_literal: true

require_relative 'geometry/geometry_methods'

module OGR
  class UnknownGeometry
    include OGR::Geometry::GeometryMethods

    GEOMETRY_TYPE = :wkbUnknown

    attr_reader :c_pointer

    def initialize(c_pointer)
      @c_pointer = c_pointer
    end
  end
end
