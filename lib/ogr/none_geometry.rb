# frozen_string_literal: true

require_relative 'geometry/geometry_methods'

module OGR
  class NoneGeometry
    include OGR::Geometry::GeometryMethods

    GEOMETRY_TYPE = :wkbNone

    attr_reader :c_pointer

    def initialize(c_pointer)
      @c_pointer = c_pointer
    end
  end
end
