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

      # @param data_type [FFI::GDAL::GDAL::DataType]
      # @param size [Fixnum] Size of the pointer to allocate.
      # @return [FFI::MemoryPointer]
      def _pointer_from_data_type(data_type, size = nil)
        pointer_type = _gdal_data_type_to_ffi(data_type)

        if size
          FFI::MemoryPointer.new(pointer_type, size)
        else
          FFI::MemoryPointer.new(pointer_type)
        end
      end

      # @param data_type [FFI::GDAL::GDAL::DataType]
      # @param size [Fixnum] Size of the pointer to allocate.
      # @return [FFI::Buffer]
      def _buffer_from_data_type(data_type, size = nil)
        pointer_type = _gdal_data_type_to_ffi(data_type)

        if size
          FFI::Buffer.alloc_inout(pointer_type, size)
        else
          FFI::Buffer.alloc_inout(pointer_type)
        end
      end

      # @param data_type [FFI::GDAL::GDAL::DataType]
      # @param narray_args Args to pass to the NArray initializer.
      # @return [NArray]
      def _narray_from_data_type(data_type, *narray_args)
        init_meth = _gdal_data_type_to_narray(data_type)
        narray_args = 0 if narray_args.empty?

        NArray.send(init_meth, *narray_args)
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
      # @param data_type [FFI::GDAL::GDAL::DataType]
      # @return [Symbol]
      def _gdal_data_type_to_ffi(data_type)
        case data_type
        when :GDT_Byte                    then :uchar
        when :GDT_UInt16                  then :uint16
        when :GDT_Int16, :GDT_CInt16      then :int16
        when :GDT_UInt32                  then :uint32
        when :GDT_Int32, :GDT_CInt32      then :int32
        when :GDT_Float32, :GDT_CFloat32  then :float
        when :GDT_Float64, :GDT_CFloat64  then :double
        else
          fail GDAL::InvalidDataType, "Unknown data type: #{data_type}"
        end
      end

      # Maps GDAL DataTypes to NArray types.
      #
      # @param data_type [FFI::GDAL::GDAL::DataType]
      # @return [Symbol]
      def _gdal_data_type_to_narray(data_type)
        case data_type
        when :GDT_Byte                                then :byte
        when :GDT_Int16                               then :sint
        when :GDT_UInt16, :GDT_Int32, :GDT_UInt32     then :int
        when :GDT_Float32                             then :float
        when :GDT_Float64                             then :dfloat
        when :GDT_CInt16, :GDT_CInt32                 then :scomplex
        when :GDT_CFloat32                            then :complex
        when :GDT_CFloat64                            then :dcomplex
        else
          fail GDAL::InvalidDataType, "Unknown data type: #{data_type}"
        end
      end

      # Helper method for reading an FFI pointer based on the GDAL DataType of
      # the pointer.
      #
      # @param pointer [FFI::Pointer] The pointer to read from.
      # @param data_type [FFI::GDAL::GDAL::DataType] The GDAL data type that
      #   determines what FFI type to use when reading.
      # @param length [Fixnum] The amount of data to read from the pointer. If
      #   > 1, the "read_array_of_" method will be called.
      # @return [Number, Array<Number>]
      def _read_pointer(pointer, data_type, length = 1)
        if length == 1
          pointer.send("read_#{_gdal_data_type_to_ffi(data_type)}")
        else
          pointer.send("read_array_of_#{_gdal_data_type_to_ffi(data_type)}", length)
        end
      end

      # Helper method for writing data to an FFI pointer based on the GDAL
      # DataType of the pointer.
      #
      # @param pointer [FFI::Pointer] The pointer to write to.
      # @param data_type [FFI::GDAL::GDAL::DataType] The GDAL data type that
      #   determines what FFI type to use when writing.
      # @param data [Fixnum] The data to write to the pointer. If it's an Array
      #   with size > 1, the "write_array_of_" method will be called.
      def _write_pointer(pointer, data_type, data)
        if data.is_a?(Array) && data.size > 1
          pointer.send("write_array_of_#{_gdal_data_type_to_ffi(data_type)}", data)
        else
          data = data.first if data.is_a?(Array)
          pointer.send("write_#{_gdal_data_type_to_ffi(data_type)}", data)
        end
      end

      # Check to see if the function is supported in the version of GDAL that we're
      # using.
      #
      # @param function_name [Symbol]
      # @return [Boolean]
      # TODO: Should the #respond_to? check all FFI::GDAL::* classes? What about
      #   OGR?
      def _supported?(function_name)
        !FFI::GDAL.unsupported_gdal_functions.include?(function_name) &&
          FFI::GDAL::GDAL.respond_to?(function_name)
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
