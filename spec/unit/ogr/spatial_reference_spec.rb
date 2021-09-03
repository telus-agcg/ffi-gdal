# frozen_string_literal: true

require 'ogr/spatial_reference'

RSpec.describe OGR::SpatialReference do
  subject { described_class.create.import_from_epsg(3819) }
  let(:other_srs) { OGR::SpatialReference.create.import_from_epsg(4326) }

  describe '#clone' do
    specify do
      other = subject.clone
      expect(other.authority_code).to eq subject.authority_code
    end
  end

  describe '#clone_geog_cs' do
    specify do
      other = subject.clone_geog_cs
      expect(other.geog_cs_is_same?(subject)).to eq true
    end
  end

  describe '#copy_geog_cs_from' do
    specify do
      subject.copy_geog_cs_from(other_srs)
      expect(subject.geog_cs_is_same?(other_srs)).to eq true
    end
  end

  describe '#validate' do
    context 'known good' do
      it 'does not raise' do
        subject.validate
      end
    end

    context 'bad WKT subject' do
      let(:wkt) do
        # "GEOG" here should be "GEOGCS"
        <<~WKT
          GEOG["WGS 84",DATUM["WGS_1984",SPHEROID["WGS 84",6378137,298.257223563,
          AUTHORITY["EPSG","7030"]],AUTHORITY["EPSG","6326"]],
          PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],
          UNIT["degree",0.0174532925199433,AUTHORITY["EPSG","9122"]],
          AUTHORITY["EPSG","4326"]]
        WKT
      end

      subject { described_class.create(wkt) }

      it 'raises' do
        expect { subject.validate }
          .to raise_exception OGR::CorruptData, 'Unable to validate'
      end
    end
  end

  describe '#auto_identify_epsg!' do
    it 'does not crash' do
      subject.auto_identify_epsg!
    end
  end

  describe '#epsg_treats_as_lat_long?' do
    it 'does not crash' do
      subject.epsg_treats_as_lat_long?
    end
  end

  describe '#epsg_treats_as_northing_easting?' do
    it 'does not crash' do
      subject.epsg_treats_as_northing_easting?
    end
  end
end
