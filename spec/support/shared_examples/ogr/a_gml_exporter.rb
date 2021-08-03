# frozen_string_literal: true

RSpec.shared_examples 'a GML exporter' do
  describe '#to_gml' do
    it 'returns some String data' do
      gml = subject.to_gml
      expect(gml).to be_a String
      expect(gml).to_not be_empty
    end
  end

  describe '#to_gml_ex' do
    it 'returns some String data' do
      gml = subject.to_gml_ex
      expect(gml).to be_a String
      expect(gml).to_not be_empty
    end
  end
end
