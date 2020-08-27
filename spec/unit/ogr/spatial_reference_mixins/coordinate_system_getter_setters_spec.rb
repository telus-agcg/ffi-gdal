# frozen_string_literal: true

require 'ogr/spatial_reference'

RSpec.describe OGR::SpatialReference do
  describe '#set_local_cs' do
    it 'sets the LOCAL_CS' do
      expect do
        subject.set_local_cs('darrel')
      end.to change { subject.to_wkt }.from('').to('LOCAL_CS["darrel"]')
    end
  end

  describe '#set_proj_cs' do
    it 'sets the PROJCS' do
      expect do
        subject.set_proj_cs('darrel')
      end.to change { subject.to_wkt }.from('').to('PROJCS["darrel"]')
    end
  end

  describe '#set_geoc_cs' do
    it 'sets the GEOCCS' do
      expect do
        subject.set_geoc_cs('darrel')
      end.to change { subject.to_wkt }.from('').to('GEOCCS["darrel"]')
    end
  end

  describe '#set_from_user_input' do
    context 'valid input' do
      it 'sets the GEOCCS' do
        expect do
          subject.set_from_user_input('GEOCCS["darrel"]')
        end.to change { subject.to_wkt }.from('').to('GEOCCS["darrel"]')
      end
    end

    context 'invalid input' do
      it 'sets the GEOCCS' do
        expect do
          subject.set_from_user_input('darrel')
        end.to raise_exception OGR::CorruptData
      end
    end
  end

  describe '#set_towgs84 + #towgs84' do
    subject do
      s = OGR::SpatialReference.new_from_epsg(4326)
      s.set_towgs84(x_distance: 10, y_distance: 10, x_rotation: 1235.4, scaling_factor: 3)
      s
    end

    it 'returns an Array of 7 floats' do
      expect(subject.towgs84).to eq [10.0, 10.0, 0.0, 1235.4, 0.0, 0.0, 3.0]
    end
  end

  describe '#authority_code' do
    it 'returns the authority code' do
      expect(subject.authority_code).to eq '4326'
    end
  end

  describe '#authority_name' do
    it 'returns the authority name' do
      expect(subject.authority_name).to eq 'EPSG'
    end
  end
end
