# frozen_string_literal: true

RSpec.shared_examples 'a curve geometry' do
  describe '#length' do
    it 'has some value' do
      expect(subject.length).to be > 0.0
    end
  end
end
