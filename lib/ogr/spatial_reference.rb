# frozen_string_literal: true

require_relative '../ogr'
require_relative '../gdal'
require_relative 'new_borrowed'

module OGR
  # Represents a geographic coordinate system.  There are two primary types:
  #   1. "geographic", where positions are measured in long/lat.
  #   2. "projected", where positions are measure in meters or feet.
  class SpatialReference
    autoload :CoordinateSystemGetterSetters,
             File.expand_path('spatial_reference/coordinate_system_getter_setters', __dir__ || '')
    autoload :Exporters,
             File.expand_path('spatial_reference/exporters', __dir__ || '')
    autoload :Importers,
             File.expand_path('spatial_reference/importers', __dir__ || '')
    autoload :Morphers,
             File.expand_path('spatial_reference/morphers', __dir__ || '')
    autoload :ParameterGetterSetters,
             File.expand_path('spatial_reference/parameter_getter_setters', __dir__ || '')
    autoload :TypeChecks,
             File.expand_path('spatial_reference/type_checks', __dir__ || '')

    class AutoPointer < ::FFI::AutoPointer
      # @param pointer [FFI::Pointer]
      def self.release(pointer)
        return unless pointer && !pointer.null?

        FFI::OGR::SRSAPI.OSRRelease(pointer)
      end
    end

    # @param srs_wkt [String, nil] An optional string argument which if passed
    #   should be a WKT representation of an SRS. Passing this is equivalent to
    #   not passing it, and then calling #import_from_wkt with the WKT string.
    # @return [OGR::SpatialReference]
    def self.create(srs_wkt = nil)
      wkt_pointer = if srs_wkt
                      FFI::MemoryPointer.from_string(srs_wkt)
                    else
                      FFI::Pointer::NULL
                    end

      pointer = FFI::OGR::SRSAPI.OSRNewSpatialReference(wkt_pointer)

      raise OGR::CreateFailure, 'Unable to create SpatialReference' if pointer.null?

      new(OGR::SpatialReference::AutoPointer.new(pointer))
    end

    # @param pointer [FFI::Pointer]
    def self.new_owned(pointer)
      new(OGR::SpatialReference::AutoPointer.new(pointer))
    end

    # @param orientation [FFI::OGR::SRSAPI::AxisOrientation]
    # @return [String]
    def self.axis_enum_to_name(orientation)
      FFI::OGR::SRSAPI.OSRAxisEnumToName(orientation).freeze
    end

    # This will attempt to cleanup any cache spatial reference related
    # information, such as cached tables of coordinate systems.
    def self.cleanup
      FFI::OGR::SRSAPI.OSRCleanup
    end

    extend OGR::NewBorrowed
    include GDAL::Logger
    include SpatialReference::CoordinateSystemGetterSetters
    include SpatialReference::Exporters
    include SpatialReference::Importers
    include SpatialReference::Morphers
    include SpatialReference::ParameterGetterSetters
    include SpatialReference::TypeChecks

    # class_eval FFI::OGR::SRSAPI::SRS_UL.to_ruby
    FFI::OGR::SRSAPI::SRS_UL.constants.each do |_name, obj|
      const_set(obj.ruby_name, obj.value)
    end

    FFI::OGR::SRSAPI::SRS_UA.constants.each do |_name, obj|
      const_set(obj.ruby_name, obj.value)
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
    # @param pointer [OGR::SpatialReference::AutoPointer, FFI::Pointer]
    def initialize(pointer)
      @c_pointer = pointer
    end

    # Uses the C-API to clone this spatial reference object.
    #
    # @return [OGR::SpatialReference]
    def clone
      SpatialReference.new_owned(FFI::OGR::SRSAPI.OSRClone(@c_pointer))
    end

    # Makes a duplicate of the GEOGCS node of this spatial reference.
    #
    # @return [OGR::SpatialReference]
    def clone_geog_cs
      SpatialReference.new_owned(FFI::OGR::SRSAPI.OSRCloneGeogCS(@c_pointer))
    end

    # @param other_spatial_ref [OGR::SpatialReference] The SpatialReference to
    #   copy GeocCS info from.
    # @raise [FFI::GDAL::InvalidPointer]
    # @raise [OGR::Failure]
    def copy_geog_cs_from(other_spatial_ref)
      OGR::ErrorHandling.handle_ogr_err('Unable to copy GEOGCS') do
        FFI::OGR::SRSAPI.OSRCopyGeogCSFrom(@c_pointer, other_spatial_ref.c_pointer)
      end
    end

    # Validate CRS imported with #import_from_wkt or when modified with
    # direct-node manipulations. Otherwise the CRS should be always valid. This
    # method attempts to verify that the spatial reference system is well-formed,
    # and consists of known tokens. The validation is not comprehensive.
    #
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
  end
end
