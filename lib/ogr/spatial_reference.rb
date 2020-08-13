# frozen_string_literal: true

require_relative '../ogr'
require_relative '../gdal'
require_relative 'spatial_reference_mixins/coordinate_system_getter_setters'
require_relative 'spatial_reference_mixins/exporters'
require_relative 'spatial_reference_mixins/importers'
require_relative 'spatial_reference_mixins/morphers'
require_relative 'spatial_reference_mixins/parameter_getter_setters'
require_relative 'spatial_reference_mixins/type_checks'

module OGR
  # Represents a geographic coordinate system.  There are two primary types:
  #   1. "geographic", where positions are measured in long/lat.
  #   2. "projected", where positions are measure in meters or feet.
  class SpatialReference
    include GDAL::Logger
    include SpatialReferenceMixins::CoordinateSystemGetterSetters
    include SpatialReferenceMixins::Exporters
    include SpatialReferenceMixins::Importers
    include SpatialReferenceMixins::Morphers
    include SpatialReferenceMixins::ParameterGetterSetters
    include SpatialReferenceMixins::TypeChecks

    # class_eval FFI::OGR::SRSAPI::SRS_UL.to_ruby
    FFI::OGR::SRSAPI::SRS_UL.constants.each do |_name, obj|
      const_set(obj.ruby_name, obj.value)
    end

    METER_TO_METER = 1.0

    FFI::OGR::SRSAPI::SRS_UA.constants.each do |_name, obj|
      const_set(obj.ruby_name, obj.value)
    end

    RADIAN_TO_RADIAN = 1.0

    if GDAL.major_version < 3
      # @return [Array<String>]
      def self.projection_methods(strip_underscores: false)
        methods_ptr_ptr = FFI::OGR::SRSAPI.OPTGetProjectionMethods
        count = FFI::CPL::String.CSLCount(methods_ptr_ptr)

        # For some reason #get_array_of_string leaves off the first 6.
        pointer_array = methods_ptr_ptr.get_array_of_pointer(0, count)

        list = pointer_array.map(&:read_string).sort

        strip_underscores ? list.map! { |l| l.tr('_', ' ') } : list
      end
    end

    # @param projection_method [String] One of
    #   OGR::SpatialReference.projection_methods.
    # @return [Hash{parameter => Array<String>, user_visible_name => String}]
    def self.parameter_list(projection_method)
      name_ptr_ptr = GDAL._pointer_pointer(:string)
      params_ptr_ptr = FFI::OGR::SRSAPI.OPTGetParameterList(projection_method, name_ptr_ptr)
      count = FFI::CPL::String.CSLCount(params_ptr_ptr)

      # For some reason #get_array_of_string leaves off the first 6.
      pointer_array = params_ptr_ptr.get_array_of_pointer(0, count)
      name = GDAL._read_pointer_pointer_safely(name_ptr_ptr, :string)

      {
        parameters: pointer_array.map(&:read_string).sort,
        user_visible_name: name
      }
    end

    # Fetch info about a single parameter of a projection method.
    #
    # @param projection_method [String]
    # @param parameter_name [String]
    def self.parameter_info(projection_method, parameter_name)
      name_ptr_ptr = GDAL._pointer_pointer(:string)
      type_ptr_ptr = GDAL._pointer_pointer(:string)
      default_value_ptr = FFI::MemoryPointer.new(:double)

      result = FFI::OGR::SRSAPI.OPTGetParameterInfo(projection_method, parameter_name,
                                                    name_ptr_ptr, type_ptr_ptr, default_value_ptr)

      return {} unless result

      name = GDAL._read_pointer_pointer_safely(name_ptr_ptr, :string)
      type = GDAL._read_pointer_pointer_safely(name_ptr_ptr, :string)

      {
        type: type,
        default_value: default_value_ptr.read_double,
        user_visible_name: name
      }
    end

    # @param orientation [FFI::OGR::SRSAPI::AxisOrientation]
    # @return [String]
    def self.axis_enum_to_name(orientation)
      FFI::OGR::SRSAPI::AxisEnumToName(orientation)
    end

    # Cleans up cached SRS-related memory.
    def self.cleanup
      FFI::OGR::SRSAPI.OSRCleanup
    end

    # @param pointer [FFI::Pointer]
    def self.release(pointer)
      FFI::OGR::SRSAPI.OSRRelease(pointer) if pointer && !pointer.null?
    end

    # @return [FFI::Pointer] C pointer to the C Spatial Reference.
    attr_reader :c_pointer

    # Builds a spatial reference object using either the passed-in WKT string,
    # OGR::SpatialReference object, or a pointer to an in-memory
    # SpatialReference object.  If nothing is passed in, an empty
    # SpatialReference object is created, in which case you'll need to populate
    # relevant attributes.
    #
    # @param spatial_reference_or_wkt [OGR::SpatialReference, FFI::Pointer,
    #   String]
    def initialize(spatial_reference_or_wkt = nil)
      pointer =
        case spatial_reference_or_wkt.class.name
        when 'OGR::SpatialReference'
          spatial_reference_or_wkt.c_pointer
        when 'String', 'NilClass'
          FFI::OGR::SRSAPI.OSRNewSpatialReference(spatial_reference_or_wkt)
        when 'FFI::Pointer', 'FFI::MemoryPointer'
          spatial_reference_or_wkt
        else
          log "Dunno what to do with #{spatial_reference_or_wkt}"
        end

      raise OGR::CreateFailure, 'Unable to create SpatialReference.' if pointer.nil? || pointer.null?

      @c_pointer = FFI::AutoPointer.new(pointer, SpatialReference.method(:release))
      # @c_pointer = pointer
    end

    def destroy!
      SpatialReference.release(@c_pointer)
      @c_pointer = nil
    end

    # Uses the C-API to clone this spatial reference object.
    #
    # @return [OGR::SpatialReference]
    def clone
      new_spatial_ref_ptr = FFI::OGR::SRSAPI.OSRClone(@c_pointer)

      self.class.new(new_spatial_ref_ptr)
    end

    # Makes a duplicate of the GEOGCS node of this spatial reference.
    #
    # @return [OGR::SpatialReference]
    def clone_geog_cs
      new_spatial_ref_ptr = FFI::OGR::SRSAPI.OSRCloneGeogCS(@c_pointer)

      self.class.new(new_spatial_ref_ptr)
    end

    # @param other_spatial_ref [OGR::SpatialReference] The SpatialReference to
    #   copy GeocCS info from.
    # @return [Boolean]
    def copy_geog_cs_from(other_spatial_ref)
      other_spatial_ref_ptr = GDAL._pointer(OGR::SpatialReference, other_spatial_ref)
      raise OGR::InvalidSpatialReference if other_spatial_ref_ptr.nil? || other_spatial_ref_ptr.null?

      ogr_err = FFI::OGR::SRSAPI.OSRCopyGeogCSFrom(@c_pointer, other_spatial_ref_ptr)

      ogr_err.handle_result
    end

    # @return +true+ if successful, otherwise raises an OGR exception.
    def validate
      ogr_err = FFI::OGR::SRSAPI.OSRValidate(@c_pointer)

      ogr_err.handle_result
    end

    # @return +true+ if successful, otherwise raises an OGR exception.
    def fixup_ordering!
      ogr_err = FFI::OGR::SRSAPI.OSRFixupOrdering(@c_pointer)

      ogr_err.handle_result
    end

    if GDAL.major_version < 3
      # @return +true+ if successful, otherwise raises an OGR exception.
      def fixup!
        ogr_err = FFI::OGR::SRSAPI.OSRFixup(@c_pointer)

        ogr_err.handle_result
      end

      # Strips all OGC coordinate transformation parameters.
      #
      # @return +true+ if successful, otherwise raises an OGR exception.
      def strip_ct_parameters!
        ogr_err = FFI::OGR::SRSAPI.OSRStripCTParms(@c_pointer)

        ogr_err.handle_result
      end
    end

    # Sets the EPSG authority info if possible.
    #
    # @return +true+ if successful, otherwise raises an OGR exception.
    def auto_identify_epsg!
      ogr_err = FFI::OGR::SRSAPI.OSRAutoIdentifyEPSG(@c_pointer)

      ogr_err.handle_result 'Unable to determine SRS from EPSG'
    end

    # @return [Boolean] +true+ if this coordinate system should be treated as
    #   having lat/long coordinate ordering.
    def epsg_treats_as_lat_long?
      FFI::OGR::SRSAPI.OSREPSGTreatsAsLatLong(@c_pointer)
    end

    # @return [Boolean] +true+ if this coordinate system should be treated as
    #   having northing/easting coordinate ordering.
    def epsg_treats_as_northing_easting?
      FFI::OGR::SRSAPI.OSREPSGTreatsAsNorthingEasting(@c_pointer)
    end

    # @return [OGR::SpatialReference, FFI::Pointer] Pointer to an OGR::SpatialReference.
    def create_coordinate_transformation(destination_spatial_ref)
      OGR::CoordinateTransformation.new(@c_pointer, destination_spatial_ref)
    end
  end
end
