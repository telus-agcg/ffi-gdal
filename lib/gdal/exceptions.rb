module GDAL
  class OpenFailure < StandardError
    def initialize(file, msg = nil)
      message = msg || "Unable to open file '#{file}'. Perhaps an unsupported file format?"
      super(message)
    end
  end

  class CPLErrFailure < StandardError
  end

  class CreateFail < StandardError
  end

  class RequiredBandNotFound < StandardError
  end

  class InvalidBandNumber < StandardError
  end

  class UnsupportedOperation < StandardError
  end

  class NoWriteAccess < StandardError
  end

  class NullObject < TypeError
  end

  class UnknownGridAlgorithm < StandardError
    def initialize(algorithm, msg = nil)
      message = msg || "Unknown Grid algorithm type '#{algorithm}'."
      super(message)
    end
  end
end
