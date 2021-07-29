module GDAL
  module WrapsPointer
    def self.included(base)
      base.extend(ClassMethods)
    end

    # @param pointer [FFI::Pointer]
    attr_reader :c_pointer

    module ClassMethods
      # @param pointer [FFI::Pointer]
      def release(pointer)
        return unless pointer && !pointer.null?

        impl_release(pointer)
      end

      def get_owned_pointer(variable)
        case variable
        when self
          raise 'uh oh' if variable.c_pointer.nil?

          variable.c_pointer
        when FFI::Pointer
          variable
        else
          raise
        end
      end

      def get_borrowed_pointer(variable)
        case variable
        when self
          raise 'uh oh' if variable.c_pointer.nil?

          variable.c_pointer.autorelease = false
          variable.c_pointer
        when FFI::Pointer
          variable.autorelease = false
          variable
        else
          raise "uh oh: #{variable.class}; #{name}"
        end
      end

      private

      # @param pointer [FFI::Pointer]
      def impl_release(_pointer)
        raise 'Implement me!'
      end
    end
  end
end
