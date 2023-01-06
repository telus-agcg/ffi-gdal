# frozen_string_literal: true

require 'ogr/extensions/geometry/ewkb_io_extensions'

RSpec.describe OGR::Geometry do
  let(:ewkb_point_no_srid) do
    ['0101000000000000000000f03f0000000000000040'].pack('H*')
  end

  let(:ewkb_point_with_srid) do
    ['0101000020110F0000000000000000F03F0000000000000040'].pack('H*')
  end

  let(:ewkb_point25d_no_srid) do
    ['0101000080000000000000f03f00000000000000400000000000000840'].pack('H*')
  end

  let(:ewkb_point25d_with_srid) do
    ['01010000a0110f0000000000000000f03f00000000000000400000000000000840'].pack('H*')
  end

  describe '.create_from_ewkb' do
    context 'point, no SRID' do
      subject { described_class.create_from_ewkb(ewkb_point_no_srid) }

      it 'creates a OGR::Point with the right point data' do
        expect(subject).to be_a OGR::Point
        expect(subject.point).to eq [1, 2]
      end

      it 'does not have a OGR::SpatialReference' do
        expect(subject.spatial_reference).to be_nil
      end
    end

    context 'point, with SRID' do
      subject { described_class.create_from_ewkb(ewkb_point_with_srid) }

      it 'creates a OGR::Point with the right point data' do
        expect(subject).to be_a OGR::Point
        expect(subject.point).to eq [1, 2]
      end

      it 'has a OGR::SpatialReference with the right authority_code' do
        expect(subject.spatial_reference).to be_a OGR::SpatialReference
        expect(subject.spatial_reference.authority_code).to eq '3857'
      end
    end

    context 'point25d, no SRID' do
      subject { described_class.create_from_ewkb(ewkb_point25d_no_srid) }

      it 'creates a OGR::Point25D with the right point data' do
        expect(subject).to be_a OGR::Point25D
        expect(subject.point).to eq [1, 2, 3]
      end

      it 'does not have a OGR::SpatialReference' do
        expect(subject.spatial_reference).to be_nil
      end
    end

    context 'point25D, with SRID' do
      subject { described_class.create_from_ewkb(ewkb_point25d_with_srid) }

      it 'creates a OGR::Point25D with the right point data' do
        expect(subject).to be_a OGR::Point25D
        expect(subject.point).to eq [1, 2, 3]
      end

      it 'has a OGR::SpatialReference with the right authority_code' do
        expect(subject.spatial_reference).to be_a OGR::SpatialReference
        expect(subject.spatial_reference.authority_code).to eq '3857'
      end
    end
  end
end
