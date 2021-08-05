# frozen_string_literal: true

RSpec.shared_examples 'a KML exporter' do
  describe '#to_kml' do
    it 'returns some String data' do
      kml = subject.to_kml
      expect(kml).to be_a String
      expect(kml).to_not be_empty
    end
  end
end
