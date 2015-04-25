require 'log_switch'

module GDAL
  module Logger
    include LogSwitch
  end

  # @private
  module InternalHelpers
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Internal factory method for returning a pointer from +variable+, which could
      # be either of +klass+ class or a type of FFI::Pointer.
      def _pointer(klass, variable, warn_on_nil = true)
        if variable.is_a?(klass)
          variable.c_pointer.autorelease = true
          variable.c_pointer
        elsif variable.is_a? FFI::Pointer
          variable.autorelease = true
          variable
        else
          if warn_on_nil && Logger.logging_enabled
            Logger.logger.debug "<#{name}._pointer> #{variable.inspect} is not a valid #{klass} or FFI::Pointer."
            Logger.logger.debug "<#{name}._pointer> Called at:"
            caller(1, 2).each { |line| Logger.logger.debug "<#{name}._pointer>\t#{line}" }
          end

          nil
        end
      end

      # @param data_type [FFI::GDAL::DataType]
      # @return [Symbol] The FFI Symbol that represents a data type.
      def _pointer_from_data_type(data_type, size = nil)
        pointer_type = _gdal_data_type_to_ffi(data_type)

        if size
          FFI::MemoryPointer.new(pointer_type, size)
        else
          FFI::MemoryPointer.new(pointer_type)
        end
      end

      # Takes an array of strings (or things that should be converted to
      # strings) and creates a char**.
      #
      # @param strings [Array<String>]
      # @return [FFI::MemoryPointer]
      def _string_array_to_pointer(strings)
        string_pointers = strings.map do |string|
          FFI::MemoryPointer.from_string(string.to_s)
        end

        string_pointers << nil
        array_pointer = FFI::MemoryPointer.new(:pointer, strings.size + 1)

        string_pointers.each_with_index do |ptr, i|
          array_pointer[i].put_pointer(0, ptr)
        end

        array_pointer
      end

      # Maps GDAL DataTypes to FFI types.
      #
      # @param data_type [FFI::GDAL::DataType]
      def _gdal_data_type_to_ffi(data_type)
        case data_type
        when :GDT_Byte then :uchar
        when :GDT_UInt16 then :uint16
        when :GDT_Int16 then :int16
        when :GDT_UInt32 then :uint32
        when :GDT_Int32 then :int32
        when :GDT_Float32 then :float
        when :GDT_Float64 then :double
        else
          :float
        end
      end

      # Check to see if the function is supported in the version of GDAL that we're
      # using.
      #
      # @param function_name [Symbol]
      # @return [Boolean]
      def _supported?(function_name)
        !FFI::GDAL.unsupported_gdal_functions.include?(function_name) &&
          FFI::GDAL.respond_to?(function_name)
      end

      # @param char [String] 'r' or 'w'
      # @return [Symbol] :GF_Read if 'r' or :GF_Write if 'w'.
      # @raise [GDAL::InvalidAccessFlag] If +char+ is not 'r' or 'w'.
      def _gdal_access_flag(char)
        case char
        when 'r' then :GF_Read
        when 'w' then :GF_Write
        else fail GDAL::InvalidAccessFlag, "Invalid access flag: #{char}"
        end
      end
    end
  end
end
