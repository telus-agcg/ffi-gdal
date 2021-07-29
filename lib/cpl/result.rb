module CPL
  class Result
    # Maps `error_number` to a Ruby exception.
    #
    # @param error_number [Symbol] One of
    def self.to_exception(error_number, message)
      case error_number
      # when :CPLE_None then nil
      when :CPLE_AppDefined then ::GDAL::Error.new(message)
      when :CPLE_OutOfMemory then ::NoMemoryError.new(message)
      when :CPLE_FileIO then ::IOError.new(message)
      when :CPLE_OpenFailed then ::GDAL::OpenFailure.new(message)
      when :CPLE_IllegalArg then ::ArgumentError.new(message)
      when :CPLE_NotSupported then ::GDAL::UnsupportedOperation.new(message)
      when :CPLE_AssertionFailed then ::RuntimeError.new(message)
      when :CPLE_NoWriteAccess then ::GDAL::NoWriteAccess.new(message)
      when :CPLE_UserInterrupt then ::Interrupt.new(message)
      when :CPLE_ObjectNull then ::GDAL::NullObject.new(message)
      else ::GDAL::Error.new(message)
      end
    end

    attr_reader :error_number, :message

    def initialize(error_number, message)
      @error_number = error_number
      @message = message
    end

    def ok?
      @error_number == :CPLE_None
    end

    def error?
      !ok?
    end

    def to_exception
      raise "Unknown failure for error number #{@error_number}" if ok?

      CPL::Result.to_exception(@error_number, @message)
    end
  end
end
