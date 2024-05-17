# frozen_string_literal: true

module FFI
  module GDAL
    module InternalHelpers
      # Version information for GDAL.
      class GDALVersion
        # @return [String] GDAL Version.
        def self.version
          ::FFI::GDAL.GDALVersionInfo("VERSION_NUM")
        end
      end
    end
  end
end
