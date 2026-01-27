# frozen_string_literal: true

require_relative "../ogr"
require_relative "../gdal"
require_relative "spatial_reference_mixins/coordinate_system_getter_setters"
require_relative "spatial_reference_mixins/exporters"
require_relative "spatial_reference_mixins/importers"
require_relative "spatial_reference_mixins/morphers"
require_relative "spatial_reference_mixins/parameter_getter_setters"
require_relative "spatial_reference_mixins/type_checks"

module OGR
  # Represents a geographic coordinate system.  There are two primary types:
  #   1. "geographic", where positions are measured in long/lat.
  #   2. "projected", where positions are measure in meters or feet.
  class SpatialReference
    Version = Struct.new(:major, :minor, :patch)

    include GDAL::Logger
    include SpatialReferenceMixins::CoordinateSystemGetterSetters
    include SpatialReferenceMixins::Exporters
    include SpatialReferenceMixins::Importers
    include SpatialReferenceMixins::Morphers
    include SpatialReferenceMixins::ParameterGetterSetters
    include SpatialReferenceMixins::TypeChecks

    # Linear unit constants from ogr_srs_api.h (SRS_UL_*)
    METER_LABEL = "Meter"                                    # SRS_UL_METER
    METER_TO_METER = 1.0
    FOOT_LABEL = "Foot (International)"                      # SRS_UL_FOOT
    METER_TO_FOOT = 0.3048                                   # SRS_UL_FOOT_CONV
    NAUTICAL_MILE_LABEL = "Nautical Mile"                    # SRS_UL_NAUTICAL_MILE
    METER_TO_NAUTICAL_MILE = 1852.0                          # SRS_UL_NAUTICAL_MILE_CONV
    LINK_LABEL = "Link"                                      # SRS_UL_LINK
    METER_TO_LINK = 0.20116684023368047                      # SRS_UL_LINK_CONV
    CHAIN_LABEL = "Chain"                                    # SRS_UL_CHAIN
    METER_TO_CHAIN = 20.116684023368047                      # SRS_UL_CHAIN_CONV
    ROD_LABEL = "Rod"                                        # SRS_UL_ROD
    METER_TO_ROD = 5.02921005842012                          # SRS_UL_ROD_CONV
    LINK_CLARKE_LABEL = "Link_Clarke"                        # SRS_UL_LINK_Clarke
    METER_TO_LINK_CLARKE = 0.2011661949                      # SRS_UL_LINK_Clarke_CONV
    KILOMETER_LABEL = "Kilometer"                            # SRS_UL_KILOMETER
    METER_TO_KILOMETER = 1000.0                              # SRS_UL_KILOMETER_CONV
    DECIMETER_LABEL = "Decimeter"                            # SRS_UL_DECIMETER
    METER_TO_DECIMETER = 0.1                                 # SRS_UL_DECIMETER_CONV
    CENTIMETER_LABEL = "Centimeter"                          # SRS_UL_CENTIMETER
    METER_TO_CENTIMETER = 0.01                               # SRS_UL_CENTIMETER_CONV
    MILLIMETER_LABEL = "Millimeter"                          # SRS_UL_MILLIMETER
    METER_TO_MILLIMETER = 0.001                              # SRS_UL_MILLIMETER_CONV
    INTL_NAUTICAL_MILE_LABEL = "Nautical_Mile_International" # SRS_UL_INTL_NAUT_MILE
    METER_TO_INTL_NAUTICAL_MILE = 1852.0                     # SRS_UL_INTL_NAUT_MILE_CONV
    INTL_INCH_LABEL = "Inch_International"                   # SRS_UL_INTL_INCH
    METER_TO_INTL_INCH = 0.0254                              # SRS_UL_INTL_INCH_CONV
    INTL_FOOT_LABEL = "Foot_International"                   # SRS_UL_INTL_FOOT
    METER_TO_INTL_FOOT = 0.3048                              # SRS_UL_INTL_FOOT_CONV
    INTL_YARD_LABEL = "Yard_International"                   # SRS_UL_INTL_YARD
    METER_TO_INTL_YARD = 0.9144                              # SRS_UL_INTL_YARD_CONV
    INTL_STATUTE_MILE_LABEL = "Statute_Mile_International"   # SRS_UL_INTL_STAT_MILE
    METER_TO_INTL_STATUTE_MILE = 1609.344                    # SRS_UL_INTL_STAT_MILE_CONV
    INTL_FATHOM_LABEL = "Fathom_International"               # SRS_UL_INTL_FATHOM
    METER_TO_INTL_FATHOM = 1.8288                            # SRS_UL_INTL_FATHOM_CONV
    INTL_CHAIN_LABEL = "Chain_International"                 # SRS_UL_INTL_CHAIN
    METER_TO_INTL_CHAIN = 20.1168                            # SRS_UL_INTL_CHAIN_CONV
    INTL_LINK_LABEL = "Link_International"                   # SRS_UL_INTL_LINK
    METER_TO_INTL_LINK = 0.201168                            # SRS_UL_INTL_LINK_CONV
    US_INCH_LABEL = "Inch_US_Surveyor"                       # SRS_UL_US_INCH
    METER_TO_US_INCH = 0.025400050800101603                  # SRS_UL_US_INCH_CONV
    US_FOOT_LABEL = "Foot_US"                                # SRS_UL_US_FOOT
    METER_TO_US_FOOT = 0.3048006096012192                    # SRS_UL_US_FOOT_CONV
    US_YARD_LABEL = "Yard_US_Surveyor"                       # SRS_UL_US_YARD
    METER_TO_US_YARD = 0.914401828803658                     # SRS_UL_US_YARD_CONV
    US_CHAIN_LABEL = "Chain_US_Surveyor"                     # SRS_UL_US_CHAIN
    METER_TO_US_CHAIN = 20.11684023368047                    # SRS_UL_US_CHAIN_CONV
    US_STATUTE_MILE_LABEL = "Statute_Mile_US_Surveyor"       # SRS_UL_US_STAT_MILE
    METER_TO_US_STATUTE_MILE = 1609.347218694437             # SRS_UL_US_STAT_MILE_CONV
    INDIAN_YARD_LABEL = "Yard_Indian"                        # SRS_UL_INDIAN_YARD
    METER_TO_INDIAN_YARD = 0.91439523                        # SRS_UL_INDIAN_YARD_CONV
    INDIAN_FOOT_LABEL = "Foot_Indian"                        # SRS_UL_INDIAN_FOOT
    METER_TO_INDIAN_FOOT = 0.30479841                        # SRS_UL_INDIAN_FOOT_CONV
    INDIAN_CHAIN_LABEL = "Chain_Indian"                      # SRS_UL_INDIAN_CHAIN
    METER_TO_INDIAN_CHAIN = 20.11669506                      # SRS_UL_INDIAN_CHAIN_CONV

    # Angular unit constants from ogr_srs_api.h (SRS_UA_*)
    DEGREE_LABEL = "degree"                                  # SRS_UA_DEGREE
    RADIAN_TO_DEGREE = 0.0174532925199433                    # SRS_UA_DEGREE_CONV
    RADIAN_LABEL = "radian"                                  # SRS_UA_RADIAN
    RADIAN_TO_RADIAN = 1.0

    # @deprecated This was removed in GDAL 3.0.
    # @return [Array<String>]
    def self.projection_methods(strip_underscores: false)
      methods_ptr_ptr = FFI::OGR::SRSAPI.OPTGetProjectionMethods
      count = FFI::CPL::String.CSLCount(methods_ptr_ptr)

      # For some reason #get_array_of_string leaves off the first 6.
      pointer_array = methods_ptr_ptr.get_array_of_pointer(0, count)

      list = pointer_array.map(&:read_string).sort

      strip_underscores ? list.map! { |l| l.tr("_", " ") } : list
    end

    # @deprecated This was removed in GDAL 3.0.
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
    # @deprecated This was removed in GDAL 3.0.
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

    # This static method will destroy a OGRSpatialReference. It is equivalent
    # to calling delete on the object, but it ensures that the deallocation is
    # properly executed within the OGR libraries heap on platforms where this
    # can matter (win32).
    #
    # @param pointer [FFI::Pointer]
    def self.destroy(pointer)
      return unless pointer && !pointer.null?

      FFI::OGR::SRSAPI.OSRDestroySpatialReference(pointer)
    end

    # Decrements the reference count by one, and destroy if zero.
    #
    # @param pointer [FFI::Pointer]
    def self.release(pointer)
      return unless pointer && !pointer.null?

      FFI::OGR::SRSAPI.OSRRelease(pointer)
    end

    def self.proj_version
      major_ptr = FFI::MemoryPointer.new(:int)
      major_ptr.autorelease = false
      minor_ptr = FFI::MemoryPointer.new(:int)
      minor_ptr.autorelease = false
      patch_ptr = FFI::MemoryPointer.new(:int)
      patch_ptr.autorelease = false

      FFI::OGR::SRSAPI.OSRGetPROJVersion(major_ptr, minor_ptr, patch_ptr)

      Version.new(major_ptr.read_int, minor_ptr.read_int, patch_ptr.read_int)
    end

    # @return [FFI::Pointer] C pointer to the C Spatial Reference.
    attr_reader :c_pointer

    # Builds a spatial reference object using either the passed-in WKT string,
    # OGR::SpatialReference object, or a pointer to an in-memory
    # SpatialReference object. If nothing is passed in, an empty
    # SpatialReference object is created, in which case you'll need to populate
    # relevant attributes.
    #
    # If a OGR::SpatialReference is given, this clones that object so it can
    # have it's own object (relevant for cleaning up when garbage collecting).
    #
    # @param spatial_reference_or_wkt [OGR::SpatialReference, FFI::Pointer, String]
    def initialize(spatial_reference_or_wkt = nil)
      pointer =
        case spatial_reference_or_wkt.class.name
        when "OGR::SpatialReference"
          # This is basically getting a reference to the SpatialReference that
          # was passed in, thus when this SpatialReference gets garbage-collected,
          # it shouldn't release anything.
          ptr = spatial_reference_or_wkt.c_pointer
          ptr.autorelease = false
        when "String", "NilClass"
          # FWIW, the docs say:
          # Note that newly created objects are given a reference count of one.
          #
          # ...which implies that we should use Release here instead of Destroy.
          ptr = FFI::OGR::SRSAPI.OSRNewSpatialReference(spatial_reference_or_wkt)
          ptr.autorelease = false

          # We're instantiating a new SR, so we can use .destroy.
          FFI::AutoPointer.new(ptr, SpatialReference.method(:release))
        when "FFI::AutoPointer", "FFI::Pointer", "FFI::MemoryPointer"
          # If we got a pointer, we don't know who owns the data, so don't
          # touch anything about autorelease/AutoPointer.
          spatial_reference_or_wkt
        else
          log "Dunno what to do with #{spatial_reference_or_wkt.inspect}"
        end

      raise OGR::CreateFailure, "Unable to create SpatialReference." if pointer.nil? || pointer.null?

      @c_pointer = pointer
    end

    def destroy!
      SpatialReference.destroy(@c_pointer)

      @c_pointer = nil
    end

    # Uses the C-API to clone this spatial reference object.
    #
    # @return [OGR::SpatialReference]
    def clone
      new_spatial_ref_ptr = FFI::OGR::SRSAPI.OSRClone(@c_pointer)

      SpatialReference.new(new_spatial_ref_ptr)
    end

    # Makes a duplicate of the GEOGCS node of this spatial reference.
    #
    # @return [OGR::SpatialReference]
    def clone_geog_cs
      new_spatial_ref_ptr = FFI::OGR::SRSAPI.OSRCloneGeogCS(@c_pointer)

      SpatialReference.new(new_spatial_ref_ptr)
    end

    # @param other_spatial_ref [OGR::SpatialReference] The SpatialReference to
    #   copy GeocCS info from.
    # @raise [OGR::Failure]
    def copy_geog_cs_from(other_spatial_ref)
      other_spatial_ref_ptr = GDAL._pointer(OGR::SpatialReference, other_spatial_ref)
      raise OGR::InvalidSpatialReference if other_spatial_ref_ptr.nil? || other_spatial_ref_ptr.null?

      OGR::ErrorHandling.handle_ogr_err("Unable to copy GEOGCS") do
        FFI::OGR::SRSAPI.OSRCopyGeogCSFrom(@c_pointer, other_spatial_ref_ptr)
      end
    end

    # @raise [OGR::Failure]
    def validate
      OGR::ErrorHandling.handle_ogr_err("Unable to validate") do
        FFI::OGR::SRSAPI.OSRValidate(@c_pointer)
      end
    end

    # @raise [OGR::Failure]
    def fixup_ordering!
      OGR::ErrorHandling.handle_ogr_err("Unable to fixup ordering") do
        FFI::OGR::SRSAPI.OSRFixupOrdering(@c_pointer)
      end
    end

    # @raise [OGR::Failure]
    def fixup!
      OGR::ErrorHandling.handle_ogr_err("Unable to fixup") do
        FFI::OGR::SRSAPI.OSRFixup(@c_pointer)
      end
    end

    # Strips all OGC coordinate transformation parameters.
    #
    # @raise [OGR::Failure]
    def strip_ct_parameters!
      OGR::ErrorHandling.handle_ogr_err("Unable to strip coordinate transformation parameters") do
        FFI::OGR::SRSAPI.OSRStripCTParms(@c_pointer)
      end
    end

    # Sets the EPSG authority info if possible.
    #
    # @raise [OGR::Failure]
    def auto_identify_epsg!
      OGR::ErrorHandling.handle_ogr_err("Unable to determine SRS from EPSG") do
        FFI::OGR::SRSAPI.OSRAutoIdentifyEPSG(@c_pointer)
      end
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

    # @return [nil] Sets the axis mapping strategy for this spatial reference.
    def axis_mapping_strategy=(strategy)
      FFI::OGR::SRSAPI.OSRSetAxisMappingStrategy(@c_pointer, strategy)
    end

    # @return [FFI::OGR::SRSAPI::AxisMappingStrategy] The axis mapping strategy.
    def axis_mapping_strategy
      FFI::OGR::SRSAPI.OSRGetAxisMappingStrategy(@c_pointer)
    end
  end
end
