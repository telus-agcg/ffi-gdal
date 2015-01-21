require 'spec_helper'

RSpec.describe OGR::Geometry do
  describe '.create_from_wkt' do
    subject { OGR::Geometry.create_from_wkt(wkt) }

    context 'a 2D Point' do
      let(:wkt) { 'POINT(1 32)' }
      it { is_expected.to be_a OGR::Point }
    end

    context 'a 2.5D Point' do
      let(:wkt) { 'POINT(1 32 100)' }
      it { is_expected.to be_a OGR::Point }
    end

    context 'a 2D LineString' do
      let(:wkt) { 'LINESTRING(3 19,12 20)' }
      it { is_expected.to be_a OGR::LineString }
    end

    context 'a 2.5D LineString' do
      let(:wkt) { 'LINESTRING(3 4 19,12 23 20)' }
      it { is_expected.to be_a OGR::LineString }
    end

    context 'a 2D Polygon' do
      let(:wkt) { 'POLYGON((1 1,2 2,3 3))' }
      it { is_expected.to be_a OGR::Polygon }
    end

    context 'a 2.5D Polygon' do
      let(:wkt) { 'POLYGON((1 1 1,2 2 2,3 3 3))' }
      it { is_expected.to be_a OGR::Polygon }
    end

    context 'a 2D MultiPoint' do
      let(:wkt) { 'MULTIPOINT((1 1),(2 2))' }
      it { is_expected.to be_a OGR::MultiPoint }
    end

    context 'a 2D MultiPoint' do
      let(:wkt) { 'MULTIPOINT((1 1 1),(2 2 2))' }
      it { is_expected.to be_a OGR::MultiPoint }
    end

    context 'a 2D MultiLineString' do
      let(:wkt) { 'MULTILINESTRING((3 4),(100 200))' }
      it { is_expected.to be_a OGR::MultiLineString }
    end

    context 'a 2.5D MultiLineString' do
      let(:wkt) { 'MULTILINESTRING((3 4 19),(100 200 400))' }
      it { is_expected.to be_a OGR::MultiLineString }
    end

    context 'a 2D MultiPolygon' do
      let(:wkt) do
        'MULTIPOLYGON(((1 1,2 2,3 3)),((100 100, 200 200, 300 300)))'
      end

      it { is_expected.to be_a OGR::MultiPolygon }
    end

    context 'a 2.5D MultiPolygon' do
      let(:wkt) do
        'MULTIPOLYGON(((1 1 1,2 2 2,3 3 3)),((100 100 100, 200 200 200, 300 300 300)))'
      end

      it { is_expected.to be_a OGR::MultiPolygon }
    end
  end

  describe '.create_from_json' do
    subject { OGR::Geometry.create_from_json(json) }

    context 'a 2D Point' do
      let(:json) do
        { type: :Point, coordinates: [1.0, 7.0] }.to_json
      end

      it { is_expected.to be_a OGR::Point }
    end

    context 'a 2.5D Point' do
      let(:json) do
        { type: :Point, coordinates: [1.0, 2.0, 3.0] }.to_json
      end

      it { is_expected.to be_a OGR::Point }
    end

    context 'a 2D LineString' do
      let(:json) do
        {
          type: :LineString,
          coordinates: [
            [3.0, 4.0], [20.0, 30.0]
          ]
        }.to_json
      end

      it { is_expected.to be_a OGR::LineString }
    end

    context 'a 2.5D LineString' do
      let(:json) do
        {
          type: :LineString,
          coordinates: [
            [3.0, 4.0, 19.0], [20.0, 30.0, 45.0]
          ]
        }.to_json
      end

      it { is_expected.to be_a OGR::LineString }
    end

    context 'a 2D Polygon' do
      let(:json) do
        {
          type: :Polygon,
          coordinates: [
            [
              [1.0, 1.0], [5.0, 1.0], [5.0, 5.0], [1.0, 5.0], [1.0, 1.0]
            ]
          ]
        }.to_json 
      end

      it { is_expected.to be_a OGR::Polygon }
    end

    context 'a 2.5D Polygon' do
      let(:json) do
        {
          type: :Polygon,
          coordinates: [
            [
              [1.0, 1.0, 1.0], [5.0, 1.0, 1.0], [5.0, 5.0, 1.0], [1.0, 5.0, 1.0], [1.0, 1.0]
            ]
          ]
        }.to_json 
      end

      it { is_expected.to be_a OGR::Polygon }
    end

    context 'a 2D MultiPoint' do
      let(:json) do
        {
          type: :MultiPoint,
          coordinates: [
            [1.0, 1.0], [2.0, 2.0], [2.0, 1.0], [1.0, 1.0]
          ]
        }.to_json
      end

      it { is_expected.to be_a OGR::MultiPoint }
    end

    context 'a 2.5D MultiPoint' do
      let(:json) do
        {
          type: :MultiPoint,
          coordinates: [
            [1.0, 1.0, 1.0], [2.0, 2.0, 2.0], [2.0, 1.0, 2.0], [1.0, 1.0, 1.0]
          ]
        }.to_json
      end

      it { is_expected.to be_a OGR::MultiPoint }
    end

    context 'a 2D MultiLineString' do
      let(:json) do
        {
          type: :MultiLineString,
          coordinates: [
            [
              [3.0, 4.0], [21.0, 27.0], [2.0, 5.0]
            ], [
              [100.0, 200.0], [982.0, 6.0]
            ]
          ]
        }.to_json
      end

      it { is_expected.to be_a OGR::MultiLineString }
    end

    context 'a 2.5D MultiLineString' do
      let(:json) do
        {
          type: :MultiLineString,
          coordinates: [
            [
              [3.0, 4.0, 19.0], [21.0, 27.0, 30.0]
            ], [
              [100.0, 200.0, 400.0], [982.0, 6.0, 47.1]
            ]
          ]
        }.to_json
      end

      it { is_expected.to be_a OGR::MultiLineString }
    end

    context 'a 2D MultiPolygon' do
      let(:json) do
        {
          type: :MultiPolygon,
          coordinates: [
            [
              [
                [1.0, 1.0], [2.0, 2.0], [3.0, 3.0]
              ], [
                [11.0, 11.0], [10.0, 10.0], [9.0, 9.0]
              ]
            ], [
              [
                [100.0, 100.0], [200.0, 200.0], [300.0, 300.0]
              ], [
                [10.0, 10.0], [20.0, 20.0], [30.0, 30.0]
              ]
            ]
          ]
        }.to_json 
      end

      it { is_expected.to be_a OGR::MultiPolygon }
    end

    context 'a 2.5D MultiPolygon' do
      let(:json) do
        {
          type: :MultiPolygon,
          coordinates: [
            [
              [
                [1.0, 1.0, 1.0], [2.0, 2.0, 2.0], [3.0, 3.0, 3.0]
              ], [
                [11.0, 11.0, 11.0], [10.0, 10.0, 10.0], [9.0, 9.0, 9.0]
              ]
            ], [
              [
                [100.0, 100.0, 100.0], [200.0, 200.0, 200.0], [300.0, 300.0, 300.0]
              ], [
                [10.0, 10.0, 10.0], [20.0, 20.0, 20.0], [30.0, 30.0, 30.0]
              ]
            ]
          ]
        }.to_json 
      end

      it { is_expected.to be_a OGR::MultiPolygon }
    end
  end
    
  describe '.create_from_gml' do
    subject { OGR::Geometry.create_from_gml(gml) }

    context 'a 2D Point' do
      let(:gml) do
        '<gml:Point><gml:coordinates>1,7</gml:coordinates></gml:Point>'
      end

      it { is_expected.to be_a OGR::Point }
    end

    context 'a 2.5D Point' do
      let(:gml) do
        '<gml:Point><gml:coordinates>1,7,25</gml:coordinates></gml:Point>'
      end

      it { is_expected.to be_a OGR::Point }
    end

    context 'a 2D LineString' do
      let(:gml) do
        '<gml:LineString><gml:coordinates>3,4</gml:coordinates></gml:LineString>'
      end

      it { is_expected.to be_a OGR::LineString }
    end

    context 'a 2.5D LineString' do
      let(:gml) do
        '<gml:LineString><gml:coordinates>3,4,19</gml:coordinates></gml:LineString>'
      end

      it { is_expected.to be_a OGR::LineString }
    end

    context 'a 2D Polygon' do
      let(:gml) do
        <<-GML
  <gml:Polygon>
    <gml:outerBoundaryIs>
      <gml:LinearRing>
        <gml:coordinates>1,1 5,1 5,5 1,5 1,1</gml:coordinates>
      </gml:LinearRing>
    </gml:outerBoundaryIs>
  </gml:Polygon>
        GML
      end

      it { is_expected.to be_a OGR::Polygon }
    end

    context 'a 2.5D Polygon' do
      let(:gml) do
        <<-GML
  <gml:Polygon>
    <gml:outerBoundaryIs>
      <gml:LinearRing>
        <gml:coordinates>1,1,3 5,1,3 5,5,3 1,5,3 1,1,3</gml:coordinates>
      </gml:LinearRing>
    </gml:outerBoundaryIs>
  </gml:Polygon>
        GML
      end

      it { is_expected.to be_a OGR::Polygon }
    end

    context 'a 2D MultiPoint' do
      let(:gml) do
        <<-GML
  <gml:MultiPoint>
    <gml:pointMember>
      <gml:Point>
         <gml:coordinates>1,1</gml:coordinates>
      </gml:Point>
    </gml:pointMember>
    <gml:pointMember>
      <gml:Point>
        <gml:coordinates>2,2</gml:coordinates>
      </gml:Point>
    </gml:pointMember>
    <gml:pointMember>
      <gml:Point>
        <gml:coordinates>2,1</gml:coordinates>
      </gml:Point>
    </gml:pointMember>
    <gml:pointMember>
      <gml:Point>
        <gml:coordinates>1,1</gml:coordinates>
      </gml:Point>
    </gml:pointMember>
  </gml:MultiPoint>
        GML
      end

      it { is_expected.to be_a OGR::MultiPoint }
    end

    context 'a 2.5D MultiPoint' do
      let(:gml) do
        <<-GML
  <gml:MultiPoint>
    <gml:pointMember>
      <gml:Point>
         <gml:coordinates>1,1,3</gml:coordinates>
      </gml:Point>
    </gml:pointMember>
    <gml:pointMember>
      <gml:Point>
        <gml:coordinates>2,2,3</gml:coordinates>
      </gml:Point>
    </gml:pointMember>
    <gml:pointMember>
      <gml:Point>
        <gml:coordinates>2,1,3</gml:coordinates>
      </gml:Point>
    </gml:pointMember>
    <gml:pointMember>
      <gml:Point>
        <gml:coordinates>1,1,3</gml:coordinates>
      </gml:Point>
    </gml:pointMember>
  </gml:MultiPoint>
        GML
      end

      it { is_expected.to be_a OGR::MultiPoint }
    end

    context 'a 2D MultiLineString' do
      let(:gml) do
        <<-GML
  <gml:MultiLineString>
    <gml:lineStringMember>
      <gml:LineString>
        <gml:coordinates>3,4</gml:coordinates>
      </gml:LineString>
    </gml:lineStringMember>
    <gml:lineStringMember>
      <gml:LineString>
        <gml:coordinates>100,200</gml:coordinates>
      </gml:LineString>
    </gml:lineStringMember>
  </gml:MultiLineString>
        GML
      end

      it { is_expected.to be_a OGR::MultiLineString }
    end

    context 'a 2.5D MultiLineString' do
      let(:gml) do
        <<-GML
  <gml:MultiLineString>
    <gml:lineStringMember>
      <gml:LineString>
        <gml:coordinates>3,4,19</gml:coordinates>
      </gml:LineString>
    </gml:lineStringMember>
    <gml:lineStringMember>
      <gml:LineString>
        <gml:coordinates>100,200,400</gml:coordinates>
      </gml:LineString>
    </gml:lineStringMember>
  </gml:MultiLineString>
        GML
      end

      it { is_expected.to be_a OGR::MultiLineString }
    end

    context 'a 2D MultiPolygon' do
      let(:gml) do
        <<-GML
  <gml:MultiPolygon>
    <gml:polygonMember>
      <gml:Polygon>
        <gml:outerBoundaryIs>
          <gml:LinearRing>
            <gml:coordinates>1,1 2,2 3,3</gml:coordinates>
          </gml:LinearRing>
        </gml:outerBoundaryIs>
      </gml:Polygon>
    </gml:polygonMember>
    <gml:polygonMember>
      <gml:Polygon>
        <gml:outerBoundaryIs>
          <gml:LinearRing>
            <gml:coordinates>100,100 200,200 300,300</gml:coordinates>
          </gml:LinearRing>
        </gml:outerBoundaryIs>
      </gml:Polygon>
    </gml:polygonMember>
  </gml:MultiPolygon>
        GML
      end

      it { is_expected.to be_a OGR::MultiPolygon }
    end

    context 'a 2.5D MultiPolygon' do
      let(:gml) do
        <<-GML
  <gml:MultiPolygon>
    <gml:polygonMember>
      <gml:Polygon>
        <gml:outerBoundaryIs>
          <gml:LinearRing>
            <gml:coordinates>1,1,9 2,2,9 3,3,9</gml:coordinates>
          </gml:LinearRing>
        </gml:outerBoundaryIs>
      </gml:Polygon>
    </gml:polygonMember>
    <gml:polygonMember>
      <gml:Polygon>
        <gml:outerBoundaryIs>
          <gml:LinearRing>
            <gml:coordinates>100,100,9 200,200,9 300,300,9</gml:coordinates>
          </gml:LinearRing>
        </gml:outerBoundaryIs>
      </gml:Polygon>
    </gml:polygonMember>
  </gml:MultiPolygon>
        GML
      end

      it { is_expected.to be_a OGR::MultiPolygon }
    end
  end

  describe '.type_to_name' do
    context 'wkbUnknown' do
      subject { described_class.type_to_name(:wkbUnknown) }
      it { is_expected.to eq 'Unknown (any)' }
    end

    context 'wkbPoint' do
      subject { described_class.type_to_name(:wkbPoint) }
      it { is_expected.to eq 'Point' }
    end

    context 'wkbLineString' do
      subject { described_class.type_to_name(:wkbLineString) }
      it { is_expected.to eq 'Line String' }
    end

    context 'wkbPolygon' do
      subject { described_class.type_to_name(:wkbPolygon) }
      it { is_expected.to eq 'Polygon' }
    end

    context 'wkbMultiPoint' do
      subject { described_class.type_to_name(:wkbMultiPoint) }
      it { is_expected.to eq 'Multi Point' }
    end

    context 'wkbMultiLineString' do
      subject { described_class.type_to_name(:wkbMultiLineString) }
      it { is_expected.to eq 'Multi Line String' }
    end

    context 'wkbMultiPolygon' do
      subject { described_class.type_to_name(:wkbMultiPolygon) }
      it { is_expected.to eq 'Multi Polygon' }
    end

    context 'wkbGeometryCollection' do
      subject { described_class.type_to_name(:wkbGeometryCollection) }
      it { is_expected.to eq 'Geometry Collection' }
    end
    
    context 'wkbNone' do
      subject { described_class.type_to_name(:wkbNone) }
      it { is_expected.to eq 'None' }
    end
    
    context 'wkbLinearRing' do
      subject { described_class.type_to_name(:wkbLinearRing) }
      it { is_expected.to eq 'Unrecognised: 101' }
    end
  end
end