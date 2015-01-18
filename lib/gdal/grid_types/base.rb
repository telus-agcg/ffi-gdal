module GDAL
  module GridTypes
    class Base
      @@options ||= []

      def self.attr_option(option)
        define_method(:options) do
          @options
        end

        define_method(option) do
          @options[option]
        end

        define_method("#{option}=") do |value|
          @options[option] = value.to_s
        end
      end

      attr_option :angle
      attr_option :nodata
      attr_option :radius1
      attr_option :radius2

      def initialize
        @options = {}
      end

      def algorithm
        fail 'Must define in child class!'
      end
    end
  end
end
