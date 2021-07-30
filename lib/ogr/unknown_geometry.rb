# frozen_string_literal: true

module OGR
  class UnknownGeometry < OGR::Geometry
    GEOMETRY_TYPE = :wkbUnknown

    def initialize(c_pointer)
      super(c_pointer, nil)
    end
  end
end
