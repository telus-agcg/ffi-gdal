require_relative '../ffi/ogr'

module OGR
  class StyleTool
    # @param style_tool_class [FFI::OGR::Core::STClassId] Must be one of :OGRSTCPen,
    #   :OGRSTCBrush, :OGRSTCSymbol, :OGRSTCLabel.
    def initialize(style_tool_class)
      @style_tool_pointer = FFI::OGR::API.OGR_ST_Create(style_tool_class)

      if @style_tool_pointer.null?
        fail OGR::CreateFailure, "Unable to create StyleTool using class #{style_tool_class}"
      end
    end

    def c_pointer
      @style_tool_pointer
    end

    # @return [String, nil]
    def style_string
      FFI::OGR::API.OGR_ST_GetStyleString(@style_tool_pointer)
    end

    # @return [FFI::OGR::Core::STClassId]
    def type
      FFI::OGR::API.OGR_ST_GetType(@style_tool_pointer)
    end

    # @return [FFI::OGR::Core::STUnitId]
    def unit
      FFI::OGR::API.OGR_ST_GetUnit(@style_tool_pointer)
    end

    # @param new_unit [FFI::OGR::Core::STUnitId]
    # @param ground_to_paper_scale [Float]
    def set_unit(new_unit, ground_to_paper_scale)
      FFI::OGR::API.OGR_ST_SetUnit(@style_tool_pointer, new_unit, ground_to_paper_scale)
    end

    # @param param_number [Fixnum]
    # @return [Float, nil]
    def param_as_double(param_number)
      value_is_null_ptr = FFI::MemoryPointer.new(:int)
      value = FFI::OGR::API.OGR_ST_GetParamDbl(@style_tool_pointer, param_number, value_is_null_ptr)

      value_is_null_ptr.read_int.to_bool ? nil : value
    end
    alias_method :param_as_float, :param_as_double

    # @param param_number [Fixnum]
    # @param value [Float]
    def set_param_as_double(param_number, value)
      FFI::OGR::API.OGR_ST_SetParamDbl(@style_tool_pointer, param_number, value)
    end
    alias_method :set_param_as_float, :set_param_as_double

    # @param param_number [Fixnum]
    # @return [Fixnum, nil]
    def param_as_number(param_number)
      value_is_null_ptr = FFI::MemoryPointer.new(:int)
      value = FFI::OGR::API.OGR_ST_GetParamNum(@style_tool_pointer, param_number, value_is_null_ptr)

      value_is_null_ptr.read_int.to_bool ? nil : value
    end
    alias_method :param_as_integer, :param_as_number

    # @param param_number [Fixnum]
    # @param value [Fixnum]
    def set_param_as_number(param_number, value)
      FFI::OGR::API.OGR_ST_SetParamNum(@style_tool_pointer, param_number, value)
    end
    alias_method :set_param_as_integer, :set_param_as_number

    # @param param_number [Fixnum]
    # @return [String, nil]
    def param_as_string(param_number)
      value_is_null_ptr = FFI::MemoryPointer.new(:int)
      value = FFI::OGR::API.OGR_ST_GetParamStr(@style_tool_pointer, param_number, value_is_null_ptr)

      value_is_null_ptr.read_int.to_bool ? nil : value
    end

    # @param param_number [Fixnum]
    # @param value [String]
    def set_param_as_string(param_number, value)
      FFI::OGR::API.OGR_ST_SetParamStr(@style_tool_pointer, param_number, value)
    end

    # Returns the R, G, B, A components of a #RRGGBB[AA] formatted string.
    #
    # @param color_string [String]
    # @return [Hash{red => Fixnum, green => Fixnum, blue => Fixnum, alpha => Fixnum}]
    def rgb_from_string(color_string)
      red_ptr = FFI::MemoryPointer.new(:int)
      green_ptr = FFI::MemoryPointer.new(:int)
      blue_ptr = FFI::MemoryPointer.new(:int)
      alpha_ptr = FFI::MemoryPointer.new(:int)

      boolean_result = FFI::OGR::API.OGR_ST_GetRGBFromString(
        @style_tool_pointer,
        color_string,
        red_ptr,
        green_ptr,
        blue_ptr,
        alpha_ptr
      )

      if boolean_result
        {
          red: red_ptr.read_int,
          green: green_ptr.read_int,
          blue: blue_ptr.read_int,
          alpha: alpha_ptr.read_int
        }
      else
        { red: nil, green: nil, blue: nil, alpha: nil }
      end
    end
  end
end
