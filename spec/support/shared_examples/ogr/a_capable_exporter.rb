# frozen_string_literal: true

# Requirements:
#   * :geometry - one that the described class can
RSpec.shared_examples 'a capable exporter' do
  describe '#to_gml' do
    it 'returns some String data' do
      expect(geometry.to_gml).to be_a String
      expect(geometry.to_gml).to_not be_empty
    end
  end

  describe '#to_kml' do
    it 'returns some String data' do
      expect(geometry.to_kml).to be_a String
      expect(geometry.to_kml).to_not be_empty
    end
  end

  describe '#to_geo_json' do
    it 'returns some String data' do
      expect(geometry.to_geo_json).to be_a String
      expect(geometry.to_geo_json).to_not be_empty
    end
  end
end
