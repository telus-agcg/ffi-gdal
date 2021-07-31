# frozen_string_literal: true

require 'ogr/geometry'

RSpec.describe OGR::Curve do
  it_behaves_like 'a geometry' do
    let(:geometry) { described_class.new }
  end
end
