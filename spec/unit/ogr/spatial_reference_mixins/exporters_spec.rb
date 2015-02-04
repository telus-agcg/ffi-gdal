require 'spec_helper'

RSpec.describe OGR::SpatialReference do
  describe '#to_erm' do
    context 'known projection' do
      subject { described_class.new_from_epsg(4322) }

      it 'returns a Hash' do
        expect(subject.to_erm).to eq(projection_name: 'GEODETIC', datum_name: 'WGS72DOD', units: 'METERS')
      end
    end

    context 'empty SRS' do
      it 'raises an OGR::NotEnoughData' do
        expect { subject.to_erm }.to raise_exception OGR::NotEnoughData
      end
    end
  end

  describe '#to_mapinfo' do
    context 'known projection' do
      subject { described_class.new_from_epsg(4322) }

      it 'returns a populated array' do
        pending 'Understanding how to make it work'
        expect(subject.to_mapinfo).to be_an Array
        expect(subject.to_mapinfo).to_not be_empty
      end
    end

    context 'empty SRS' do
      it 'raises an OGR::NotEnoughData' do
        pending 'Understanding how to make it work'

        expect { subject.to_mapinfo }.to raise_exception OGR::NotEnoughData
      end
    end
  end

  describe '#to_pci' do
    context 'known projection' do
      subject { described_class.new_from_epsg(4322) }

      it 'returns a Hash' do
        expect(subject.to_pci).to eq(
          projection: 'LONG/LAT    D001',
          units: 'DEGREE',
          projection_parameters: [])
      end
    end

    context 'empty SRS' do
      it 'returns default values' do
        expect(subject.to_pci).to eq(
          projection: 'LONG/LAT    E012',
          units: 'DEGREE',
          projection_parameters: [])
      end
    end
  end

  describe '#to_proj4' do
    context 'known projection' do
      subject { described_class.new_from_epsg(4322) }

      it 'returns a PROJ4 String' do
        expect(subject.to_proj4).to eq('+proj=longlat +ellps=WGS72 +towgs84=0,0,4.5,0,0,0.554,0.2263 +no_defs ')
      end
    end

    context 'empty SRS' do
      it 'raises a GDAL::UnsupportedOperation' do
        expect { subject.to_proj4 }.to raise_exception GDAL::UnsupportedOperation
      end
    end
  end

  describe '#to_wkt' do
    context 'known projection' do
      subject { described_class.new_from_epsg(4322) }

      it 'returns a well-known text String' do
        expect(subject.to_wkt).to eq('GEOGCS["WGS 72",DATUM["WGS_1972",SPHEROID["WGS 72",6378135,298.26,AUTHORITY["EPSG","7043"]],TOWGS84[0,0,4.5,0,0,0.554,0.2263],AUTHORITY["EPSG","6322"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.0174532925199433,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4322"]]')
      end
    end

    context 'empty SRS' do
      it 'returns an empty String' do
        expect(subject.to_wkt).to eq ''
      end
    end
  end

  describe '#to_pretty_wkt' do
    context 'known projection' do
      subject { described_class.new_from_epsg(4322) }

      it 'returns a well-known text String' do
        expect(subject.to_pretty_wkt).to eq <<-WKT.strip
GEOGCS["WGS 72",
    DATUM["WGS_1972",
        SPHEROID["WGS 72",6378135,298.26,
            AUTHORITY["EPSG","7043"]],
        TOWGS84[0,0,4.5,0,0,0.554,0.2263],
        AUTHORITY["EPSG","6322"]],
    PRIMEM["Greenwich",0,
        AUTHORITY["EPSG","8901"]],
    UNIT["degree",0.0174532925199433,
        AUTHORITY["EPSG","9122"]],
    AUTHORITY["EPSG","4322"]]
                                        WKT
      end
    end

    context 'empty SRS' do
      it 'returns an empty String' do
        expect(subject.to_pretty_wkt).to eq ''
      end
    end
  end

  describe '#to_xml' do
    context 'known projection' do
      subject { described_class.new_from_epsg(4322) }

      it 'returns an XML string' do
        pending 'Understanding how to make it work'
        expect(subject.to_xml).to eq 'something'
      end
    end

    context 'empty SRS' do
      it 'raises an OGR::UnsupportedSRS' do
        expect { subject.to_xml }.to raise_exception OGR::UnsupportedSRS
      end
    end
  end
end
