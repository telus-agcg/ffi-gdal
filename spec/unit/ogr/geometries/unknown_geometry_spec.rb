require 'spec_helper'

RSpec.describe OGR::UnknownGeometry do
  it_behaves_like 'a geometry' do
    let(:geometry) { described_class.new }
  end
end
