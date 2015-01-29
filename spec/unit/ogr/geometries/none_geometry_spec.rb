require 'spec_helper'

RSpec.describe OGR::NoneGeometry do
  it_behaves_like 'a geometry' do
    let(:geometry) { described_class.new }
  end
end
