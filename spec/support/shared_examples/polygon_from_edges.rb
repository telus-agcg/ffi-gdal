RSpec.shared_examples 'a polygon from edges' do
  describe '#polygon_from_edges' do
    context 'auto_close is false' do
      subject do
        gc = described_class.new
        gc.add_geometry(line_string1)
        gc.add_geometry(line_string2)
        gc.polygon_from_edges(10, auto_close: false)
      end

      context 'points are not within tolerance' do
        let(:line_string1) do
          OGR::Geometry.create_from_wkt('LINESTRING (0 0,0 1,0 2)')
        end

        let(:line_string2) do
          OGR::Geometry.create_from_wkt('LINESTRING (100 100,100 200,100 300)')
        end

        it 'raises a OGR::Failure error' do
          expect { subject }.to raise_exception OGR::Failure
        end
      end

      context 'points are within tolerance, not closed' do
        let(:line_string1) do
          OGR::Geometry.create_from_wkt('LINESTRING (0 0,0 1,0 2)')
        end

        let(:line_string2) do
          OGR::Geometry.create_from_wkt('LINESTRING (1 1,1 2,1 3)')
        end

        it 'returns a Polygon' do
          expect(subject).to be_a OGR::Polygon
        end

        it 'returns WKT with the merged strings' do
          expect(subject.to_wkt).to eq 'POLYGON ((0 0,0 1,0 2,1 1,1 2,1 3))'
        end
      end

      context 'points are within tolerance and closed' do
        let(:line_string1) do
          OGR::Geometry.create_from_wkt('LINESTRING (0 0,0 1,0 2)')
        end

        let(:line_string2) do
          OGR::Geometry.create_from_wkt('LINESTRING (0 2,1 4,0 0)')
        end

        it 'returns a Polygon' do
          expect(subject).to be_a OGR::Polygon
        end

        it 'returns WKT with the merged strings' do
          expect(subject.to_wkt).to eq 'POLYGON ((0 0,0 1,0 2,1 4,0 0))'
        end
      end
    end

    context 'auto_close is true' do
      subject do
        gc = described_class.new
        gc.add_geometry(line_string1)
        gc.add_geometry(line_string2)
        gc.polygon_from_edges(10, auto_close: true)
      end

      context 'points are not within tolerance' do
        let(:line_string1) do
          OGR::Geometry.create_from_wkt('LINESTRING (0 0,0 1,0 2)')
        end

        let(:line_string2) do
          OGR::Geometry.create_from_wkt('LINESTRING (100 100,100 200,0 2)')
        end

        it 'raises a OGR::Failure' do
          expect { subject }.to raise_exception OGR::Failure
        end
      end

      context 'points are within tolerance, not closed' do
        let(:line_string1) do
          OGR::Geometry.create_from_wkt('LINESTRING (0 0,0 1,0 2)')
        end

        let(:line_string2) do
          OGR::Geometry.create_from_wkt('LINESTRING (1 1,1 2,1 3)')
        end

        it 'returns a Polygon' do
          expect(subject).to be_a OGR::Polygon
        end

        it 'returns WKT with the merged strings' do
          expect(subject.to_wkt).
            to eq 'POLYGON ((0 0 0,0 1 0,0 2 0,1 1 0,1 2 0,1 3 0,0 0 0))'
        end
      end

      context 'points are within tolerance and already closed' do
        let(:line_string1) do
          OGR::Geometry.create_from_wkt('LINESTRING (0 0,0 1,0 2)')
        end

        let(:line_string2) do
          OGR::Geometry.create_from_wkt('LINESTRING (0 2,1 4,0 0)')
        end

        it 'returns a Polygon' do
          expect(subject).to be_a OGR::Polygon
        end

        it 'returns WKT with the merged strings' do
          expect(subject.to_wkt).to eq 'POLYGON ((0 0,0 1,0 2,1 4,0 0))'
        end
      end

      context 'unsupported geometries' do
        let(:line_string) { 'LINESTRING(3 19,12 20)' }

        subject do
          gc = described_class.new
          gc.add_geometry(line_string)
          gc
        end

        it 'raises an OGR::UnsupportedOperation' do
          expect do
            subject.polygon_from_edges(100, auto_close: false)
          end.to raise_exception OGR::UnsupportedOperation
        end
      end
    end
  end
end