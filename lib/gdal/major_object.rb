require_relative '../ffi/gdal'


module GDAL
  module MajorObject
    include FFI::GDAL

    # @return [Array<String>]
    def metadata_domain_list
      list_pointer = GDALGetMetadataDomainList(c_pointer)

      read_array_of_strings(list_pointer)
    end

    def metadata(domain=nil)
      GDALGetMetadata(c_pointer, domain).read_string
    end

    def metadata_item(name, domain='')
      GDALGetMetadataItem(c_pointer, name, domain)
    end

    # @return [String]
    def description
      GDALGetDescription(c_pointer)
    end

    # @param new_description [String]
    def description=(new_description)
      GDALSetDescription(c_pointer, new_description.to_s)
    end

    def null?
      c_pointer.null?
    end
  end
end
