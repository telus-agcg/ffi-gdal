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

    # @param orientation [FFI::OGR::SRSAPI::AxisOrientation]
    # @return [String]
    def self.axis_enum_to_name(orientation)
      FFI::OGR::SRSAPI.OSRAxisEnumToName(orientation)
    end

    # Cleans up cached SRS-related memory.
    def self.cleanup
      FFI::OGR::SRSAPI.OSRCleanup
    end

    # Use for instantiating an SpatialReference from a borrowed pointer (one
    # that shouldn't be freed).
    #
    # @param c_pointer [FFI::Pointer]
    # @return [OGR::Point, OGR::Curve, OGR::Surface, OGR::GeometryCollection]
    # @raise [FFI::GDAL::InvalidPointer] if +c_pointer+ is null.
    def self.new_borrowed(c_pointer)
      raise FFI::GDAL::InvalidPointer, "Can't instantiate SRS from null pointer" if c_pointer.null?

      c_pointer.autorelease = false

      new(c_pointer).freeze
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
        when 'OGR::SpatialReference'
          # This is basically getting a reference to the SpatialReference that
          # was passed in, thus when this SpatialReference gets garbage-collected,
          # it shouldn't release anything.
          ptr = spatial_reference_or_wkt.c_pointer
          ptr.autorelease = false
        when 'String', 'NilClass'
          # FWIW, the docs say:
          # Note that newly created objects are given a reference count of one.
          #
          # ...which implies that we should use Release here instead of Destroy.
          ptr = FFI::OGR::SRSAPI.OSRNewSpatialReference(spatial_reference_or_wkt)
          ptr.autorelease = false

          # We're instantiating a new SR, so we can use .destroy.
          FFI::AutoPointer.new(ptr, SpatialReference.method(:release))
        when 'FFI::AutoPointer', 'FFI::Pointer', 'FFI::MemoryPointer'
          # If we got a pointer, we don't know who owns the data, so don't
          # touch anything about autorelease/AutoPointer.
          spatial_reference_or_wkt
        else
          log "Dunno what to do with #{spatial_reference_or_wkt.inspect}"
        end

      raise OGR::CreateFailure, 'Unable to create SpatialReference.' if pointer.nil? || pointer.null?

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
    # @raise [FFI::GDAL::InvalidPointer]
    # @raise [OGR::Failure]
    def copy_geog_cs_from(other_spatial_ref)
      other_spatial_ref_ptr = GDAL._pointer(other_spatial_ref)

      OGR::ErrorHandling.handle_ogr_err('Unable to copy GEOGCS') do
        FFI::OGR::SRSAPI.OSRCopyGeogCSFrom(@c_pointer, other_spatial_ref_ptr)
      end
    end

    # @raise [OGR::Failure]
    def validate
      OGR::ErrorHandling.handle_ogr_err('Unable to validate') do
        FFI::OGR::SRSAPI.OSRValidate(@c_pointer)
      end
    end

    # Sets the EPSG authority info if possible.
    #
    # @raise [OGR::Failure]
    def auto_identify_epsg!
      OGR::ErrorHandling.handle_ogr_err('Unable to determine SRS from EPSG') do
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
  end
end
