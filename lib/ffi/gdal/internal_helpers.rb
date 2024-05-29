# frozen_string_literal: true

module FFI
  module GDAL
    module InternalHelpers
      autoload :GDALVersion, File.expand_path("internal_helpers/gdal_version", __dir__)
      autoload :LayoutVersion, File.expand_path("internal_helpers/layout_version", __dir__)
      autoload :LayoutVersionResolver, File.expand_path("internal_helpers/layout_version_resolver", __dir__)
    end
  end
end
