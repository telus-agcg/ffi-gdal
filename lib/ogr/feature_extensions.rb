require 'json'

module OGR
  module FeatureExtensions
    # @return [Array] Uses each FieldDefinition to determine the field type at
    #   each index and returns maps the field as that value type.
    def fields
      0.upto(field_count - 1).map do |i|
        case field_definition(i).type
        when :OFTInteger        then field_as_integer(i)
        when :OFTIntegerList    then field_as_integer_list(i)
        when :OFTReal           then field_as_double(i)
        when :OFTRealList       then field_as_double_list(i)
        when :OFTString         then field_as_string(i)
        when :OFTStringList     then field_as_string_list(i)
        when :OFTWideString     then field_as_string(i)
        when :OFTWideStringList then field_as_string_list(i)
        when :OFTBinary         then field_as_binary(i)
        when :OFTDate, :OFTTime, :OFTDateTime then field_as_date_time(i)
        when :OFTInteger64      then field_as_integer(i)
        when :OFTInteger64List  then field_as_integer_lsit(i)
        when :OFTMaxType        then field_as_date_time(i)
        else fail "not sure about field type: #{fd.type}"
        end
      end
    end

    # @return [Array<OGR::Geometry>]
    def geometry_fields
      0.upto(geometry_field_count - 1).map do |i|
        geometry_field(i)
      end
    end

    # TODO: this seems really wonky...
    def valid_raw_field?(index, raw_field)
      field_def = field_definition(index)

      case field_def.type
      when :OFTInteger then !raw_field[:integer].nil?
      when :OFTIntegerList then !raw_field[:integer_list].nil?
      when :OFTInteger64 then !raw_field[:integer64].nil?
      when :OFTInteger64List then !raw_field[:integer64_list].nil?
      when :OFTReal then !raw_field[:real].nil?
      when :OFTRealList then !raw_field[:real_list].nil?
      when :OFTString then !raw_field[:string].nil?
      when :OFTStringList then !raw_field[:string_list].nil?
      when :OFTBinary then !raw_field[:binary].nil?
      when :OFTDate then !raw_field[:date].nil?
      else
        fail OGR::Failure, "Not sure how to set raw type: #{field_def.type}"
      end
    end

    # @return [Hash]
    def as_json(options = nil)
      fields_with_nested_json = fields.map do |f|
        {
          field_definition: f[:field_definition].as_json(options),
          value_as_string: f[:value_as_string]
        }
      end

      {
        definition: definition.as_json(options),
        fid: fid,
        field_count: field_count,
        fields: fields_with_nested_json,
        geometry: geometry ? geometry.as_json(options) : nil,
        geometry_field_count: geometry_field_count,
        geometry_field_definitions: geometry_field_definitions.map(&:as_json),
        style_string: style_string,
        style_table: style_table ? style_table.as_json(options) : nil
      }
    end

    # @return [String]
    def to_json(options = nil)
      as_json(options).to_json
    end
  end
end
