# frozen_string_literal: true

require_relative '../ogr'

module OGR
  class Envelope
    # @return [FFI::OGR::Envelope] The C struct that this object wraps.
    attr_reader :c_struct

    # @param envelope_struct [FFI::OGR::Envelope]
    def initialize(envelope_struct = nil)
      @c_struct = envelope_struct || FFI::OGR::Envelope.new
    end

    # @return [FFI::Pointer] Pointer to the C struct.
    def c_pointer
      @c_struct.to_ptr
    end

    # @return [Float]
    def x_min
      @c_struct[:min_x]
    end

    # @param new_x_min [Float]
    def x_min=(new_x_min)
      @c_struct[:min_x] = new_x_min
    end

    # @return [Float]
    def x_max
      @c_struct[:max_x]
    end

    # @param new_x_max [Float]
    def x_max=(new_x_max)
      @c_struct[:max_x] = new_x_max
    end

    # @return [Float]
    def y_min
      @c_struct[:min_y]
    end

    # @param new_y_min [Float]
    def y_min=(new_y_min)
      @c_struct[:min_y] = new_y_min
    end

    # @return [Float]
    def y_max
      @c_struct[:max_y]
    end

    # @param new_y_max [Float]
    def y_max=(new_y_max)
      @c_struct[:max_y] = new_y_max
    end
  end
end
