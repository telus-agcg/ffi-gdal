# frozen_string_literal: true

require 'ogr/extensions/geometry/rttopo_extensions'

# NOTE: Results from calling different versions of rttopo differ, depending on
# versions of it and its dependencies you're using--hence the differing expected
# results in tests here.
#
RSpec.describe OGR::Geometry do
  subject { OGR::Geometry.create_from_wkt(wkt) }

  shared_context 'shared point, no crossing' do
    let(:wkt) do
      %[POLYGON((0 0,0 10,5 5,10 10,10 0,5 5,5 0,0 0))]
    end
  end

  shared_context 'crossing lines' do
    let(:wkt) do
      %[POLYGON((0 0,0 10,10 0,5 0,5 10,0 0))]
    end
  end

  describe '#make_valid' do
    context 'shared point, no crossing' do
      include_context 'shared point, no crossing'

      it 'makes a valid MULTIPOLYGON' do
        ci_expected_wkt = 'MULTIPOLYGON (((0 10,5 5,5 0,0 0,0 10)),((10 10,10 0,5 5,10 10)))'
        local_expected_wkt = 'MULTIPOLYGON (((0 0,0 10,5 5,5 0,0 0)),((5 5,10 10,10 0,5 5)))'
        expect(subject.make_valid.to_wkt).to eq(ci_expected_wkt).or(local_expected_wkt)
      end
    end

    context 'crossing lines' do
      include_context 'crossing lines'

      it 'makes a valid MULTIPOLYGON' do
        ci_expected_wkt = 'MULTIPOLYGON (((0 0,0 10,3.33333333333333 6.66666666666667,0 0)),' \
                          '((3.33333333333333 6.66666666666667,5 10,5 5,3.33333333333333 6.66666666666667)),' \
                          '((10 0,5 0,5 5,10 0)))'

        local_expected_wkt = 'MULTIPOLYGON (((0 0,0 10,3.33333333333333 6.66666666666667,0 0)),' \
                             '((5 5,10 0,5 0,5 5)),' \
                             '((5 5,3.33333333333333 6.66666666666667,5 10,5 5)))'

        expect(subject.make_valid.to_wkt).to eq(ci_expected_wkt).or(local_expected_wkt)
      end
    end
  end
end
