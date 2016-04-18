require 'date'

module GDAL
  module VersionInfo
    # Version in the form "1170".
    #
    # @return [String]
    def version_num
      FFI::GDAL.GDALVersionInfo('VERSION_NUM'.freeze)
    end

    # @return [Date]
    def release_date
      Date.parse(FFI::GDAL.GDALVersionInfo('RELEASE_DATE'.freeze))
    end

    # Version in the form "1.1.7".
    #
    # @return [String]
    def release_name
      FFI::GDAL.GDALVersionInfo('RELEASE_NAME'.freeze)
    end

    # The long licensing info.
    #
    # @return [String]
    def license
      FFI::GDAL.GDALVersionInfo('LICENSE'.freeze)
    end

    # Options used when building GDAL.
    #
    # @return [Hash{String => String}]
    def build_info
      key_value_pairs = FFI::GDAL.GDALVersionInfo('BUILD_INFO'.freeze)
      key_value_pairs.split.each_with_object({}) do |kv, obj|
        key, value = kv.split('=', 2)
        obj[key] = value
      end
    end

    # @return [String]
    def long_version
      FFI::GDAL.GDALVersionInfo('--version'.freeze)
    end

    # @param major [Fixnum]
    # @param minor [Fixnum]
    # @return [Boolean] +true+ if the runtime GDAL library matches the given
    #   version params.
    def check_version(major, minor)
      FFI::GDAL.GDALCheckVersion(major, minor, 'FFI::GDAL'.freeze)
    end
  end
end
