# frozen_string_literal: true

require 'ogr/extensions/geometry/ewkb_record'

RSpec.describe OGR::Geometry::EWKBRecord do
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

  describe '.read' do
    context 'point, no srid' do
      subject { described_class.read(ewkb_point_no_srid) }

      it 'successfully parses into a EWKBRecord' do
        expect(subject).to be_a described_class
        expect(subject.endianness.value).to eq 1

        expect(subject.wkb_type.value).to eq 1
        expect(subject.has_z?).to eq false
        expect(subject.has_m?).to eq false
        expect(subject.has_srid?).to eq false

        expect(subject.srid.value).to eq 0
        expect(subject.geometry.value).to be_a String
      end
    end

    context 'point, SRID' do
      subject { described_class.read(ewkb_point_with_srid) }

      it 'successfully parses into a EWKBRecord' do
        expect(subject).to be_a described_class
        expect(subject.endianness.value).to eq 1

        expect(subject.wkb_type.value).to eq(0x2000_0000 | subject.geometry_type)
        expect(subject.geometry_type).to eq 1
        expect(subject.has_z?).to eq false
        expect(subject.has_m?).to eq false
        expect(subject.has_srid?).to eq true

        expect(subject.srid.value).to eq 3857

        expect(subject.geometry.value).to be_a String
      end
    end

    context 'point25d, no srid' do
      subject { described_class.read(ewkb_point25d_no_srid) }

      it 'successfully parses into a EWKBRecord' do
        expect(subject).to be_a described_class
        expect(subject.endianness.value).to eq 1

        expect(subject.wkb_type.value).to eq(0x8000_0000 | subject.geometry_type)
        expect(subject.has_z?).to eq true
        expect(subject.has_m?).to eq false
        expect(subject.has_srid?).to eq false

        expect(subject.srid.value).to eq 0
        expect(subject.geometry.value).to be_a String
      end
    end

    context 'point25d, SRID' do
      subject { described_class.read(ewkb_point25d_with_srid) }

      it 'successfully parses into a EWKBRecord' do
        expect(subject).to be_a described_class
        expect(subject.endianness.value).to eq 1

        expect(subject.wkb_type.value).to eq(0x8000_0000 | 0x2000_0000 | subject.geometry_type)
        expect(subject.geometry_type).to eq(subject.wkb_type.value ^ 0x2000_0000)
        expect(subject.has_z?).to eq true
        expect(subject.has_m?).to eq false
        expect(subject.has_srid?).to eq true

        expect(subject.srid.value).to eq 3857

        expect(subject.geometry.value).to be_a String
      end
    end
  end

  describe '#to_wkb' do
    shared_examples 'a WKB string' do
      it 'turns it into a binary string' do
        expect(subject).to be_a String
        expect(subject[0]).to eq "\x01"
      end
    end

    context 'point, no srid' do
      subject { described_class.read(ewkb_point_no_srid).to_wkb }
      it_behaves_like 'a WKB string'
    end

    context 'point, SRID' do
      subject { described_class.read(ewkb_point_with_srid).to_wkb }
      it_behaves_like 'a WKB string'
    end

    context 'point25d, no srid' do
      subject { described_class.read(ewkb_point25d_no_srid).to_wkb }
      it_behaves_like 'a WKB string'
    end

    context 'point25d, SRID' do
      subject { described_class.read(ewkb_point25d_with_srid).to_wkb }
      it_behaves_like 'a WKB string'
    end
  end

  describe '#to_wkb_record' do
    shared_examples 'a WKBRecord' do
      subject { ewkb_record.to_wkb_record }

      it 'turns it into a WKBRecord' do
        expect(subject).to be_a OGR::Geometry::WKBRecord
        expect(subject.endianness).to eq ewkb_record.endianness
        expect(subject.geometry_type).to eq ewkb_record.geometry_type
        expect(subject.geometry).to eq ewkb_record.geometry
      end
    end

    context 'point, no srid' do
      let(:ewkb_record) { described_class.read(ewkb_point_no_srid) }
      it_behaves_like 'a WKBRecord'
    end

    context 'point, SRID' do
      let(:ewkb_record) { described_class.read(ewkb_point_with_srid) }
      it_behaves_like 'a WKBRecord'
    end

    context 'point25d, no srid' do
      let(:ewkb_record) { described_class.read(ewkb_point25d_no_srid) }
      it_behaves_like 'a WKBRecord'
    end

    context 'point25d, SRID' do
      let(:ewkb_record) { described_class.read(ewkb_point25d_with_srid) }
      it_behaves_like 'a WKBRecord'
    end
  end
end
