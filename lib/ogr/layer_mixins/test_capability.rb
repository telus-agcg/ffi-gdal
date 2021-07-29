# frozen_string_literal: true

module OGR
  module LayerMixins
    module TestCapability
      # Tests if this layer supports the given capability.  Must be in the list
      # of available capabilities.  See http://www.gdal.org/ogr__api_8h.html#a480adc8b839b04597f49583371d366fd.
      #
      # @param capability [String]
      # @return [Boolean]
      # @see http://www.gdal.org/ogr__api_8h.html#a480adc8b839b04597f49583371d366fd
      def test_capability(capability)
        FFI::OGR::API.OGR_L_TestCapability(@c_pointer, capability.to_s)
      end
    end
  end
end
