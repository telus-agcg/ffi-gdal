require 'json'

module GDAL
  class ColorEntry
    def initialize(color_entry=nil)
      @color_entry_struct = color_entry || FFI::GDAL::GDALColorEntry.new
    end

    def c_pointer
      @color_entry_struct
    end

    def color1
      @color_entry_struct[:c1]
    end

    def color1=(new_color)
      @color_entry_struct[:c1] = new_color
    end

    def color2
      @color_entry_struct[:c2]
    end

    def color2=(new_color)
      @color_entry_struct[:c2] = new_color
    end

    def color3
      @color_entry_struct[:c3]
    end

    def color3=(new_color)
      @color_entry_struct[:c3] = new_color
    end

    def color4
      @color_entry_struct[:c4]
    end

    def color4=(new_color)
      @color_entry_struct[:c4] = new_color
    end

    # @param include_fourth [Boolean] Turn off in case you don't want the fourth
    #   color in the array.
    # @return [Array]
    def to_a(include_fourth=true)
      if include_fourth
        [color1, color2, color3, color4]
      else
        [color1, color2, color3]
      end
    end

    def as_json
      {
        color1: color1,
        color2: color2,
        color3: color3,
        color4: color4
      }
    end

    def to_json
      as_json.to_json
    end
  end
end
