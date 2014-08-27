module GDAL
  class UnsupportedFileFormat < StandardError
    def initialize(file, msg=nil)
      message = msg || "'#{file}' not recognised as a supported file format"
      super(message)
    end
  end
end
