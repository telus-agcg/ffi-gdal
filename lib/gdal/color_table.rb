require_relative '../gdal'
require_relative 'color_table_mixins/extensions'
require_relative 'color_entry'

module GDAL
  module ColorTableTypes
    autoload :CMYK,
      File.expand_path('color_table_types/cmyk', __dir__)
    autoload :Gray,
      File.expand_path('color_table_types/gray', __dir__)
    autoload :HLS,
      File.expand_path('color_table_types/hls', __dir__)
    autoload :RGB,
      File.expand_path('color_table_types/rgb', __dir__)
  end

  class ColorTable
    include ColorTableMixins::Extensions

    # @return [FFI::Pointer] C pointer to the C color table.
    attr_reader :c_pointer

    # @param palette_interp_or_pointer [FFI::GDAL::PaletteInterp,
    #   FFI::Pointer]
    # @raise [GDAL::InvalidColorTable] If unable to create the color table.
    def initialize(palette_interp_or_pointer)
      @c_pointer =
        if FFI::GDAL::GDAL::PaletteInterp[palette_interp_or_pointer]
          FFI::GDAL::GDAL.GDALCreateColorTable(palette_interp_or_pointer)
        else
          palette_interp_or_pointer
        end

      if !@c_pointer.is_a?(FFI::Pointer) || @c_pointer.null?
        raise GDAL::InvalidColorTable,
          "Unable to create #{self.class.name} from #{palette_interp_or_pointer}"
      end

      @color_entries = []

      case palette_interpretation
      when :GPI_Gray then extend GDAL::ColorTableTypes::Gray
      when :GPI_RGB then extend GDAL::ColorTableTypes::RGB
      when :GPI_CMYK then extend GDAL::ColorTableTypes::CMYK
      when :GPI_HLS then extend GDAL::ColorTableTypes::HLS
      else
        raise "Unknown PaletteInterpretation: #{palette_interpretation}"
      end
    end

    def destroy!
      return unless @c_pointer

      FFI::GDAL::GDAL.GDALDestroyColorTable(@c_pointer)
      @c_pointer = nil
    end

    # Clones the ColorTable using the C API.
    #
    # @return [GDAL::ColorTable]
    def clone
      ct_ptr = FFI::GDAL::GDAL.GDALCloneColorTable(@c_pointer)
      return nil if ct_ptr.null?

      GDAL::ColorTable.new(ct_ptr)
    end

    # Usually :GPI_RGB.
    #
    # @return [Symbol] One of FFI::GDAL::GDAL::PaletteInterp.
    def palette_interpretation
      FFI::GDAL::GDAL.GDALGetPaletteInterpretation(@c_pointer)
    end

    # @return [Fixnum]
    def color_entry_count
      FFI::GDAL::GDAL.GDALGetColorEntryCount(@c_pointer)
    end

    # @param index [Fixnum]
    # @return [GDAL::ColorEntry]
    def color_entry(index)
      @color_entries.fetch(index) do
        color_entry = FFI::GDAL::GDAL.GDALGetColorEntry(@c_pointer, index)
        return nil if color_entry.null?

        GDAL::ColorEntry.new(color_entry)
      end
    end

    # @param index [Fixnum]
    # @return [GDAL::ColorEntry]
    def color_entry_as_rgb(index)
      entry = color_entry(index)
      return unless entry

      FFI::GDAL::GDAL.GDALGetColorEntryAsRGB(@c_pointer, index, entry.c_pointer)
      return nil if entry.c_pointer.null?

      entry
    end

    # Add a new ColorEntry to the ColorTable.  Valid values depend on the image
    # type you're working with (i.e. for Tiff, values can be between 0 and
    # 65535).  Values must also be relevant to the PaletteInterp type you're
    # working with.
    #
    # @param index [Fixnum] The index of the color table's color entry to set.
    #   Must be between 0 and color_entry_count - 1.
    # @param one [Fixnum] The `c1` value of the GDAL::ColorEntry struct
    #   to set.
    # @param two [Fixnum] The `c2` value of the GDAL::ColorEntry struct
    #   to set.
    # @param three [Fixnum] The `c3` value of the GDAL::ColorEntry
    #   struct to set.
    # @param four [Fixnum] The `c4` value of the GDAL::ColorEntry
    #   struct to set.
    # @return [GDAL::ColorEntry]
    def add_color_entry(index, one = nil, two = nil, three = nil, four = nil)
      entry = GDAL::ColorEntry.new
      entry.color1 = one if one
      entry.color2 = two if two
      entry.color3 = three if three
      entry.color4 = four if four

      FFI::GDAL::GDAL.GDALSetColorEntry(@c_pointer, index, entry.c_struct)
      @color_entries.insert(index, entry)

      entry
    end

    # Automatically creates a color ramp from one color entry to another.  It
    # can be called several times to create multiple ramps in the same color
    # table.
    #
    # @param start_index [Fixnum] Index to start the ramp on (0..255)
    # @param start_color [GDAL::ColorEntry] Value to start the ramp.
    # @param end_index [Fixnum] Index to end the ramp on (0..255)
    # @param end_color [GDAL::ColorEntry] Value to end the ramp.
    # @return [Fixnum] The total number of entries.  nil or -1 on error.
    def create_color_ramp!(start_index, start_color, end_index, end_color)
      start_color_ptr = start_color.c_struct
      end_color_ptr = end_color.c_struct

      FFI::GDAL::GDAL.GDALCreateColorRamp(@c_pointer, start_index,
        start_color_ptr,
        end_index,
        end_color_ptr)
    end
  end
end
