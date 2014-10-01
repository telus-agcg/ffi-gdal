module GDAL
  class OpenFailure < StandardError
    def initialize(file, msg=nil)
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
end
