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
    context 'no options' do
      it 'returns some String data' do
        gml = subject.to_gml_ex
        expect(gml).to be_a String
        expect(gml).to_not be_empty
      end
    end

    context 'with format=GML2, namespace_decl=YES' do
      it 'returns some String data' do
        gml = subject.to_gml_ex(format: 'GML2', namespace_decl: 'YES')
        expect(gml).to include 'http://www.opengis.net/gml'
      end
    end

    context 'with format=GML2, namespace_decl=NO' do
      it 'returns some String data' do
        gml = subject.to_gml_ex(format: 'GML2', namespace_decl: 'NO')
        expect(gml).to_not include 'http://www.opengis.net/gml'
      end
    end

    context 'with format=GML3, gml3_linestring_element="curve", gml3_longsrs=YES, srsdimension_loc="GEOMETRY"' do
      it 'returns some String data' do
        # TODO: This doesn't work for MultiLineString25D and LinearRing.
        unless [OGR::MultiLineString25D, OGR::LinearRing].include?(described_class)
          gml = subject.to_gml_ex(format: 'GML3', gml3_linestring_element: 'curve',
                                  srsdimension_loc: 'GEOMETRY', srsname_format: 'OGC_URL')
          expect(gml).to include 'http://www.opengis.net'
        end
      end
    end

    context 'with format=GML32, gmlid="something"' do
      it 'returns some String data' do
        unless [OGR::LinearRing].include?(described_class)
          gml = subject.to_gml_ex(format: 'GML32', gmlid: 'something')
          expect(gml).to include 'something'
        end
      end
    end
  end
end
