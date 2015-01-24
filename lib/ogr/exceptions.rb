module OGR
  class OpenFailure < RuntimeError
    def initialize(file, msg = nil)
      message = msg || "Unable to open file '#{file}'. Perhaps an unsupported file format?"
      super(message)
    end
  end

  class CreateFailure < StandardError
  end

  class InvalidLayer < RuntimeError
  end

  class InvalidDataSource < RuntimeError
  end

  class NotEnoughData < RuntimeError
  end

  class UnsupportedGeometryType < RuntimeError
  end

  class UnsupportedOperation < RuntimeError
  end

  class CorruptData < RuntimeError
  end

  class Failure < RuntimeError
  end

  class UnsupportedSRS < RuntimeError
  end

  class InvalidHandle < RuntimeError
  end

  class DriverNotFound < RuntimeError
    def initialize(driver, msg = nil)
      message =
        if msg
          msg
        elsif driver.is_a? String
          "Driver not found with name '#{driver}'."
        elsif driver.is_a? Fixnum
          "Driver at index #{driver} not found."
        end

      super(message)
    end
  end
end
