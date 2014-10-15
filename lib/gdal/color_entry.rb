require_relative 'color_entry_extensions'

module GDAL
  class ColorEntry
    include ColorEntryExtensions
    
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
  end
end
