# frozen_string_literal: true

require 'ogr/extensions/geometry_types/curve/extensions'

RSpec.describe OGR::GeometryTypes::Curve::Extensions do
  let(:open_line_string) do
    OGR::LineString.new.tap do |g|
      g.add_point(0, 0)
      g.add_point(0, 10)
      g.add_point(10, 10)
    end
  end

  let(:closed_line_string) do
    OGR::LineString.new.tap do |g|
      g.add_point(0, 0)
      g.add_point(0, 10)
      g.add_point(10, 10)
      g.add_point(10, 0)
      g.add_point(0, 0)
    end
  end

  describe '#closed?' do
    context 'geometry is closed' do
      subject { closed_line_string }
      it { is_expected.to be_closed }
    end

    context 'geometry is not closed' do
      subject { open_line_string }
      it { is_expected.to_not be_closed }
    end
  end
end
