# frozen_string_literal: true

RSpec.shared_examples 'a GeoJSON exporter' do
  describe '#to_geo_json' do
    it 'returns some String data' do
      geo_json = subject.to_geo_json
      expect(geo_json).to be_a String
      expect(geo_json).to_not be_empty
    end
  end

  describe '#to_geo_json_ex' do
    it 'returns some String data' do
      geo_json = subject.to_geo_json_ex
      expect(geo_json).to be_a String
      expect(geo_json).to_not be_empty
    end
  end
end
