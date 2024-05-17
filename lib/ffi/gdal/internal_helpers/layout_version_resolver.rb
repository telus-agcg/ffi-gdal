# frozen_string_literal: true

module FFI
  module GDAL
    module InternalHelpers
      # Resolve the layout version based on the GDAL version.
      class LayoutVersionResolver
        # Resolve the layout version based on the GDAL version.
        # @param versions [Array<InternalHelpers::LayoutVersion>] The versions to resolve.
        # @return [Array<Symbol, Integer>] The resolved layout.
        def self.resolve(versions: [])
          gdal_version = GDALVersion.version

          versions
            .sort_by(&:version)
            .reverse_each
            .find { |layout_version| gdal_version >= layout_version.version }
            .layout
            .freeze
        end
      end
    end
  end
end
