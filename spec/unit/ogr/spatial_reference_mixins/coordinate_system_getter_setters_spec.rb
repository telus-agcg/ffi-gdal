# frozen_string_literal: true

require 'ogr/spatial_reference'

RSpec.describe OGR::SpatialReference do
  describe '#set_local_cs' do
    it 'sets the LOCAL_CS' do
      expect do
        subject.set_local_cs('darrel')
      end.to change { subject.to_wkt }.from('').to(start_with('LOCAL_CS["darrel"'))
    end
  end

  describe '#set_proj_cs' do
    it 'sets the PROJCS' do
      expect do
        subject.set_proj_cs('darrel')
      end.to change { subject.to_wkt }.from('').to(start_with('PROJCS["darrel"'))
    end
  end

  describe '#set_geoc_cs' do
    it 'sets the GEOCCS' do
      expect do
        subject.set_geoc_cs('darrel')
      end.to change { subject.to_wkt }.from('').to(start_with('GEOCCS["darrel"'))
    end
  end

  describe '#set_from_user_input' do
    context 'valid input' do
      it 'sets the GEOCCS' do
        expect do
          subject.set_from_user_input('EPSG:900913')
        end.to change { subject.to_wkt }.from('').to(start_with('PROJCS["Google Maps Global Mercator'))
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
end
