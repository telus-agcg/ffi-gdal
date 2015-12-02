module OGR
  module GeometryMixins
    module ContainerMixins
      include Enumerable

      def each
        return enum_for(:each) unless block_given?

        geometry_count.times do |i|
          yield geometry_at(i)
        end
      end
    end
  end
end
