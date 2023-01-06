# frozen_string_literal: true

require 'ogr/extensions/style_table/extensions'

RSpec.describe OGR::StyleTable::Extensions do
  describe '#styles' do
    subject do
      st = OGR::StyleTable.new
      st.add_style('style1', '12345')
      st.add_style('style2', '67890')
      st
    end

    it 'returns the styles as a Hash' do
      expect(subject.styles).to eq('style1' => '12345', 'style2' => '67890')
    end
  end
end
