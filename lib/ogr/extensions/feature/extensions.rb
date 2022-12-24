# frozen_string_literal: true

require 'ogr/feature'

module OGR
  class Feature
    module Extensions
      # Retrieves the value for each field and yields it.
      #
      # @return [Enumerator]
      # @yieldparam [Number, String, Array]
      def each_field
        return enum_for(:each_field) unless block_given?

        field_count.times do |i|
          yield field(i)
        end
      end

      # @return [Array] Uses each FieldDefinition to determine the field type at
      #   each index and returns maps the field as that value type.
      def fields
        each_field.to_a
      end

      # Retrieves a field using +index+, but uses its type from the associated
      # {OGR::FieldDefinition} to determine it's core type to return as. This
      # saves from having to find out the type then call the associated
      # +field_as_[type]+ method if you just want the data in it's originally
      # intended form.
      #
      # @param index [Integer] Index of the field to retrieve the data for.
      # @return [Number, String, Array]
      # @raise [OGR::UnsupportedFieldType] if the associated FieldDefinition's
      #   type has not yet been mapped here (to know how to return the value).
      def field(index)
        field_type = field_definition(index).type

        case field_type
        when :OFTInteger, :OFTInteger64 then                    field_as_integer(index)
        when :OFTIntegerList, :OFTInteger64List then            field_as_integer_list(index)
        when :OFTReal then                                      field_as_double(index)
        when :OFTRealList then                                  field_as_double_list(index)
        when :OFTString, :OFTWideString then                    field_as_string(index)
        when :OFTStringList, :OFTWideStringList then            field_as_string_list(index)
        when :OFTBinary then                                    field_as_binary(index)
        when :OFTDate, :OFTTime, :OFTDateTime, :OFTMaxType then field_as_date_time(index)
        else
          raise OGR::UnsupportedFieldType,
                "Don't know how to fetch field for field type: #{field_type}"
        end
      end

      # @return [Enumerator]
      # @yieldparam [OGR::GeometryFieldDefinition]
      def each_geometry_field_definition
        return enum_for(:each_geometry_field_definition) unless block_given?

        geometry_field_count.times do |i|
          yield geometry_field_definition(i)
        end
      end

      # @return [Array<OGR::GeometryFieldDefinition>]
      def geometry_field_definitions
        each_geometry_field_definition.to_a
      end

      # @return [Enumerator]
      # @yieldparam [OGR::Geometry]
      def each_geometry_field
        return enum_for(:each_geometry_field) unless block_given?

        geometry_field_count.times do |i|
          yield geometry_field(i)
        end
      end

      # @return [Array<OGR::Geometry>]
      def geometry_fields
        each_geometry_field.to_a
      end
    end
  end
end

OGR::Feature.include(OGR::Feature::Extensions)
