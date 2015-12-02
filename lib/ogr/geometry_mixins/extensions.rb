require 'json'
require_relative '../spatial_reference'

module OGR
  module GeometryMixins
    module Extensions
      # @return [Fixnum] The number of the UTM zone this geometry belongs to.
      def utm_zone
        return unless spatial_reference

        if spatial_reference.authority_code == '4326'
          self_as_4326 = self
        else
          self_as_4326 = dup
          self_as_4326.transform_to!(OGR::SpatialReference.new_from_epsg(4326))
        end

        return unless self_as_4326.point_on_surface.x

        ((self_as_4326.point_on_surface.x + 180) / 6.to_f).floor + 1
      end

      # @return [Boolean]
      def container?
        self.class.ancestors.include? OGR::GeometryTypes::Container
      end

      # @return [Boolean]
      def curve?
        self.class.ancestors.include? OGR::GeometryTypes::Curve
      end

      # @return [Boolean]
      def surface?
        self.class.ancestors.include? OGR::GeometryTypes::Surface
      end

      def !=(other)
        !equals?(other)
      end

      def is_2d?
        coordinate_dimension == 2
      end

      def is_3d?
        coordinate_dimension == 3
      end

      # @return [Hash]
      def as_json(options = nil)
        json = {
          coordinate_dimension: coordinate_dimension,
          geometry_count: geometry_count,
          dimension: dimension,
          is_empty: empty?,
          is_ring: ring?,
          is_simple: simple?,
          is_valid: valid?,
          name: name,
          point_count: point_count,
          spatial_reference: spatial_reference.nil? ? nil : spatial_reference.as_json(options),
          type: type_to_name,
          wkb_size: wkb_size
        }

        json.merge!(area: area) if respond_to? :area
        json.merge!(length: length) if respond_to? :length
        json.merge!(points: points) if respond_to? :points

        json
      end

      # @return [String]
      def to_json(options = nil)
        as_json(options).to_json
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

        # field = FieldDefinition.new('Name', :OFTString)
        # field.width = 32

        unless layer
          fail OGR::InvalidLayer, "Unable to create layer '#{layer_name}'."
        end

        feature = layer.create_feature(layer_name)
        feature.geometry = self

        data_source
      end
    end
  end
end
