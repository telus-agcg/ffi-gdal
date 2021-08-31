# frozen_string_literal: true

require_relative 'geometry/simple_curve'

module OGR
  class StyleManager
    class AutoPointer < ::FFI::AutoPointer
      # @param pointer [FFI::Pointer]
      def self.release(pointer)
        return unless pointer && !pointer.null?

        FFI::OGR::API.OGR_SM_Destroy(pointer)
      end
    end

    # @param style_table [OGR::StyleTable, nil]
    def self.create(style_table = nil)
      pointer = if style_table
                  FFI::OGR::API.OGR_SM_Create(style_table.c_pointer)
                else
                  FFI::OGR::API.OGR_SM_Create(nil)
                end

      raise OGR::CreateFailure, "Unable to create StyleManager using class #{style_table}" if !pointer || pointer.null?

      new(OGR::StyleManager::AutoPointer.new(pointer))
    end

    # @return [FFI::Pointer] C pointer to the C style tool.
    attr_reader :c_pointer

    # @param pointer [FFI::Pointer]
    def initialize(pointer)
      @c_pointer = pointer
    end

    # @param feature [OGR::Feature] The new feature from which to read the style.
    # @return [String] The style string read from the feature.
    def init_from_feature(feature)
      FFI::OGR::API.OGR_SM_InitFromFeature(@c_pointer, feature.c_pointer).freeze
    end

    # @param style_string [String, nil] (Can be nil for unsetting the style).
    # @raise [OGR::Failure]
    def init_style_string(style_string)
      return if FFI::OGR::API.OGR_SM_InitStyleString(@c_pointer, style_string)

      raise OGR::Failure, "Unable to initialize StyleManager from style string '#{style_string}'"
    end

    # @param style_tool [OGR::StyleTool] The StyleTool defining the part to add.
    # @raise [OGR::Failure]
    def add_part(style_tool)
      return if FFI::OGR::API.OGR_SM_AddPart(@c_pointer, style_tool.c_pointer)

      raise OGR::Failure, 'Unable to add part from StyleTool'
    end

    # @param style_name [String]
    # @param style_string [String, nil] The style string on which to operate. If nil, then the
    #   current style string stored in self is used.
    # @raise [OGR::Failure]
    def add_style(style_name, style_string)
      return if FFI::OGR::API.OGR_SM_AddStyle(@c_pointer, style_name, style_string)

      raise OGR::Failure, "Unable to add style '#{style_name}' using string '#{style_string}'"
    end

    # @param style_string [String, nil] The style string on which to operate. If nil, then the
    #   current style string stored in self is used.
    # @return [Integer]
    # @raise [FFI::GDAL::InvalidPointer] In the case of an error (i.e. if passing
    #   in a `style_string` that is invalid).
    def part_count(style_string = nil)
      style_string_pointer = if style_string
                               FFI::MemoryPointer.from_string(style_string)
                             else
                               FFI::Pointer::NULL
                             end

      FFI::OGR::API.OGR_SM_GetPartCount(@c_pointer, style_string_pointer)
    end

    # @param part_id [Integer] The part number (0-based index)
    # @param [String, nil] The style string on which to operate. If nil, then the
    #   current style string stored in self is used.
    # @return [OGR::StyleTool]
    # @raise [FFI::GDAL::InvalidPointer] In the case of an error (i.e. if passing
    #   in a `style_string` that is invalid).
    def part(part_id, style_string = nil)
      style_string_pointer = if style_string
                               FFI::MemoryPointer.from_string(style_string)
                             else
                               FFI::Pointer::NULL
                             end

      OGR::StyleTool.new_borrowed(FFI::OGR::API.OGR_SM_GetPart(@c_pointer, part_id, style_string_pointer))
    end
  end
end
