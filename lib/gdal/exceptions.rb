module GDAL
  class CreateFail < StandardError
  end

  class Error < ::RuntimeError
  end

  class OpenFailure < StandardError
    def initialize(file, msg = nil)
      message = msg || "Unable to open file '#{file}'. Perhaps an unsupported file format?"
      super(message)
    end
  end

  class InvalidBandNumber < StandardError
  end

  class InvalidColorTable < StandardError
  end

  class InvalidRasterBand < StandardError
  end

  class NoWriteAccess < RuntimeError
  end

  class NullObject < TypeError
  end

  class RequiredBandNotFound < StandardError
  end

  class UnknownGridAlgorithm < StandardError
    def initialize(algorithm, msg = nil)
      message = msg || "Unknown Grid algorithm type '#{algorithm}'."
      super(message)
    end
  end

  class UnsupportedOperation < StandardError
  end
end
