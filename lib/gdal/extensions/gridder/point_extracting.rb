# frozen_string_literal: true

module GDAL
  class Gridder
    # Methods used for extracting points from a OGR::Layer. Only used when
    # points are not passed in on initialize.
    module PointExtracting
      # Gathers all points from the associated layer. If GridderOptions#input_clipping_geometry
      # is set, it filters out any points that fall within that geometry. This is
      # really just indented for internal use, but is being left public just in
      # case it serves some benefit for debugging.
      #
      # @return [Array<Array>]
      def points
        return @points if @points

        ensure_z_values

        @points =
          if @options.input_field_name
            points_with_field_attributes(@source_layer, @options.input_field_name, @options.input_clipping_geometry)
          else
            points_no_field_attributes(@source_layer, @options.input_clipping_geometry)
          end
      end

      #--------------------------------------------------------------------------
      # PRIVATES
      #--------------------------------------------------------------------------

      private

      # Checks to make sure that a) if an input_field_name option was given, that
      # the layer actually has that field, or b) that the layer has Z values set.
      # Without one of these two things, there's no values to pass along to
      # interpolate.
      #
      # @raise [OGR::InvalidFieldName] if the layer doesn't have fields with the
      #   name given in GridderOptions#input_field_name.
      # @raise [GDAL::NoValuesToGrid] if GridderOptions#input_field_name is not
      #   set and the layer has no Z values.
      def ensure_z_values
        if layer_missing_specified_field?
          raise OGR::InvalidFieldName, "Field name not found in layer: '#{@options.input_field_name}'"
        end

        return unless !@options.input_field_name && !@source_layer.any_geometries_with_z?

        raise GDAL::NoValuesToGrid,
              "No input_field_name option given and source layer #{@source_layer.name} has no Z values."
      end

      # @param layer [OGR::Layer] The layer from which to extract point values.
      # @param clipping_geometry [OGR::Geometry] Optional geometry to use for
      #   filtering out points in the layer.
      # @return [Array<Array<Number>>]
      def points_no_field_attributes(layer, clipping_geometry = nil)
        if clipping_geometry
          layer.point_values do |feature_geom|
            feature_geom.within?(clipping_geometry)
          end
        else
          layer.point_values
        end
      end

      # @param layer [OGR::Layer] The layer from which to extract point values.
      # @param input_field_name [String] Name of the OGR::FieldDefinition for
      #   which to extract values from.
      # @param clipping_geometry [OGR::Geometry] Optional geometry to use for
      #   filtering out points in the layer.
      # @return [Array<Array<Number>>]
      def points_with_field_attributes(layer, input_field_name, clipping_geometry = nil)
        if clipping_geometry
          layer.point_values(input_field_name => :double) do |feature_geom|
            feature_geom.within?(clipping_geometry)
          end
        else
          layer.point_values(input_field_name => :double)
        end
      end

      # Checks if the user specified to use a field name for Z values, then if so,
      # makes sure the layer has a field by that name.
      #
      # @return [Boolean]
      def layer_missing_specified_field?
        !@options.input_field_name.nil? && !@source_layer.find_field_index(@options.input_field_name)
      end
    end
  end
end
