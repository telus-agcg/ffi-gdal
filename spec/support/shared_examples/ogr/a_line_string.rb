# frozen_string_literal: true

RSpec.shared_examples 'a line string' do
  describe '#dimension' do
    specify { expect(subject.dimension).to eq 1 }
  end

  describe '#type' do
    specify { expect(subject.type).to eq :wkbLineString }
  end

  describe '#type_to_name' do
    specify { expect(subject.type_to_name).to eq 'Line String' }
  end
end
