module OGR
  class Geometry
    def initialize(ogr_geometry_pointer: nil)
      @ogr_geometry_pointer = if ogr_geometry_pointer
        ogr_geometry_pointer
      else
      end
    end

    def c_pointer
      @ogr_geometry_pointer
    end
  end
end
