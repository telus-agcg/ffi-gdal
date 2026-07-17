# frozen_string_literal: true

require "ogr/geometry"

RSpec.describe OGR::LinearRing do
  subject { linear_ring }

  let(:linear_ring) do
    g = described_class.new
    g.add_point(0, 0)
    g.add_point(0, 10)
    g.add_point(10, 10)
    g.add_point(10, 0)
    g.add_point(0, 0)

    g
  end

  it_behaves_like "a geometry" do
    let(:geometry) { linear_ring }
  end

  it_behaves_like "a line string" do
    let(:geometry) { linear_ring }
  end

  describe "#name" do
    subject { linear_ring.name }

    it { is_expected.to eq "LINEARRING" }
  end

  describe "#point_count" do
    subject { linear_ring.point_count }

    it { is_expected.to eq 5 }
  end

  describe "#intersects?" do
    context "other geometry is a point" do
      context "inside the ring" do
        subject { linear_ring.intersects?(other_geometry) }

        let(:other_geometry) do
          OGR::Geometry.create_from_wkt("POINT (0 1)")
        end

        it { is_expected.to be false }
      end

      context "on a vertex of the ring" do
        subject { linear_ring.intersects?(other_geometry) }

        let(:other_geometry) do
          OGR::Geometry.create_from_wkt("POINT (0 0)")
        end

        it { is_expected.to be false }
      end
    end

    context "other geometry is a line string" do
      context "outside the ring" do
        subject { linear_ring.intersects?(other_geometry) }

        let(:other_geometry) do
          OGR::Geometry.create_from_wkt("LINESTRING (100 100, 20 20)")
        end

        it { is_expected.to be false }
      end

      context "ends on a vertex" do
        subject { linear_ring.intersects?(other_geometry) }

        let(:other_geometry) do
          OGR::Geometry.create_from_wkt("LINESTRING (50 50, 0 0)")
        end

        it { is_expected.to be false }
      end

      context "passes across the boundary" do
        subject { linear_ring.intersects?(other_geometry) }

        let(:other_geometry) do
          OGR::Geometry.create_from_wkt("LINESTRING (15 5, 5 5)")
        end

        it { is_expected.to be false }
      end
    end
  end
end
