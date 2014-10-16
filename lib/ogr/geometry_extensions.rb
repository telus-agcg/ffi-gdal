require 'json'

module OGR
  module GeometryExtensions

    # @return [Hash]
    def as_json
      json = {
        coordinate_dimension: coordinate_dimension,
        count: count,
        dimension: dimension,
        is_empty: empty?,
        is_ring: ring?,
        is_simple: simple?,
        is_valid: valid?,
        name: name,
        point_count: point_count,
        spatial_reference: spatial_reference.as_json,
        type: type_to_name,
        wkb_size: wkb_size
      }

      json.merge!(area: area) if respond_to? :area
      json.merge!(length: length) if respond_to? :length
      json.merge!(points: points) if respond_to? :points

      json
    end

    # @return [String]
    def to_json
      as_json.to_json
    end

    def collection?
      false
    end

    def to_vector(file_name, driver, layer_name: 'vectorized_geometry', spatial_reference: nil)
      driver = OGR::Driver.by_name(driver)

      data_source = driver.create_data_source(file_name)
      log "Creating layer #{layer_name}, type: #{type}"
      layer = data_source.create_layer(layer_name, geometry_type: type,
      spatial_reference: spatial_reference)

      # field = Field.create('Name', :OFTString)
      # field.width = 32

      unless layer
        raise OGR::InvalidLayer, "Unable to create layer '#{layer_name}'."
      end

      feature = layer.create_feature(layer_name)
      feature.geometry = self

      data_source
    end
  end
end
