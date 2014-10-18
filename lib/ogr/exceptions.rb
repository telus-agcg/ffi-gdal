module OGR
  class OpenFailure < RuntimeError
    def initialize(file, msg=nil)
      message = msg || "Unable to open file '#{file}'. Perhaps an unsupported file format?"
      super(message)
    end
  end

  class InvalidLayer < RuntimeError
  end

  class NotEnoughData < RuntimeError
  end

  class NotEnoughMemory < RuntimeError
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
end
