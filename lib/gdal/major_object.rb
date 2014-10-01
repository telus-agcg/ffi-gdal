require_relative '../ffi/gdal'


module GDAL
  module MajorObject
    include FFI::GDAL

    # @return [Array<String>]
    def metadata_domain_list
      unless defined? FFI::GDAL::GDALGetMetadataDomainList
        warn "GDALGetMetadataDomainList is't defined. GDAL::MajorObject#metadata_domain_list disabled."
        return []
      end

      # I don't quite get it, but if #GDALGetMetadataDomainList isn't called
      # twice, the last domain in the list sometimes doesn't get read.
      GDALGetMetadataDomainList(c_pointer)
      list_pointer = GDALGetMetadataDomainList(c_pointer)
      return [] if list_pointer.null?

      strings = list_pointer.get_array_of_string(0)

      strings.compact.delete_if(&:empty?)
    end

    # @param domain [String] Name of the domain to get metadata for.
    # @return [Hash]
    def metadata_for_domain(domain='')
      m = GDALGetMetadata(c_pointer, domain)
      return {} if m.null?

      data_array = m.get_array_of_string(0)

      data_array.each_with_object({}) do |key_value_pair, obj|
        key, value = key_value_pair.split('=', 2)

        begin
          obj[key] = MultiXml.parse(value)
        rescue MultiXml::ParseError
          obj[key] = value
        end
      end
    end

    # @param name [String]
    # @param domain [String]
    # @return [String]
    def metadata_item(name, domain='')
      GDALGetMetadataItem(c_pointer, name, domain)
    end

    # @return [Hash{domain => Array<String>}]
    def all_metadata
      sub_metadata = metadata_domain_list.each_with_object({}) do |subdomain, obj|
        metadata_array = metadata_for_domain(subdomain)
        obj[subdomain] = metadata_array
      end

      { DEFAULT: metadata_for_domain }.merge(sub_metadata)
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
