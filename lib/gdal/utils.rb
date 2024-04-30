# frozen_string_literal: true

module GDAL
  # Wrappers for the GDAL utilities.
  #
  # @see https://gdal.org/programs/index.html GDAL Utils documentation (gdalwarp, gdal_translate, ...).
  # @see https://gdal.org/api/gdal_utils.html GDAL Utils C API.
  module Utils
    # Internal helpers
    autoload :Helpers, File.expand_path("utils/helpers", __dir__)

    # GDAL Utils
    autoload :Rasterize, File.expand_path("utils/rasterize", __dir__)
    autoload :Info, File.expand_path("utils/info", __dir__)
    autoload :Translate, File.expand_path("utils/translate", __dir__)
    autoload :VectorTranslate, File.expand_path("utils/vector_translate", __dir__)
    autoload :Warp, File.expand_path("utils/warp", __dir__)
  end
end
