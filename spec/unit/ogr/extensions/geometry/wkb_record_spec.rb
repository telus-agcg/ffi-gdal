# frozen_string_literal: true

require 'ogr/extensions/geometry/wkb_record'

RSpec.describe OGR::Geometry::WKBRecord do
  let(:ewkb_point_with_srid) { ['0101000020110F0000000000000000F03F0000000000000040'].pack('H*') }
  let(:wkb_point) { ['0101000000000000000000f03f0000000000000040'].pack('H*') }
  let(:wkb_point25d) { ['01e9030000000000000000f03f00000000000000400000000000000840'].pack('H*') }

  describe '.read' do
    context 'Point from good WKB' do
      subject { described_class.read(wkb_point) }

      it 'successfully parses into a WKBRecord' do
        expect(subject).to be_a described_class
        expect(subject.endianness.value).to eq FFI::OGR::Core::WKBByteOrder[:wkbNDR]
        expect(subject.wkb_type.value).to eq FFI::OGR::Core::WKBGeometryType[:wkbPoint]
        expect(subject.has_z?).to eq false
        expect(subject.geometry.value).to be_a String
      end
    end

    context 'Point25D from good WKB' do
      subject { described_class.read(wkb_point25d) }

      it 'successfully parses into a WKBRecord' do
        expect(subject).to be_a described_class
        expect(subject.endianness.value).to eq FFI::OGR::Core::WKBByteOrder[:wkbNDR]
        expect(subject.wkb_type.value).to eq 1001
        expect(subject.geometry_type).to eq(described_class::WKB_Z | FFI::OGR::Core::WKBGeometryType[:wkbPoint])
        expect(subject.has_z?).to eq true
        expect(subject.geometry.value).to be_a String
      end
    end

    context 'Point from good EWKB (with SRID)' do
      subject { described_class.read(ewkb_point_with_srid) }

      it 'raises a BinData::ValidityError' do
        expect { described_class.read(ewkb_point_with_srid) }
          .to raise_exception BinData::ValidityError
      end
    end
  end
end
