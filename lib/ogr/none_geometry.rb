# frozen_string_literal: true

module OGR
  class NoneGeometry < OGR::Geometry
    GEOMETRY_TYPE = :wkbNone

    def initialize(c_pointer)
      super(c_pointer, nil)
    end
  end
end
