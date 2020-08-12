# frozen_string_literal: true

require 'gdal/color_entry'

RSpec.describe GDAL::ColorEntry do
  describe '#c_pointer' do
    it 'returns a FFI::Pointer' do
      expect(subject.c_pointer).to be_a FFI::Pointer
    end
  end

  describe '#color1' do
    context 'default' do
      it 'returns 0' do
        expect(subject.color1).to eq 0
      end
    end
  end

  describe '#color1=' do
    it 'sets the color1 attribute' do
      subject.color1 = 20
      expect(subject.color1).to eq 20
    end
  end

  describe '#color2' do
    context 'default' do
      it 'returns 0' do
        expect(subject.color2).to eq 0
      end
    end
  end

  describe '#color2=' do
    it 'sets the color2 attribute' do
      subject.color2 = 30
      expect(subject.color2).to eq 30
    end
  end

  describe '#color3' do
    context 'default' do
      it 'returns 0' do
        expect(subject.color3).to eq 0
      end
    end
  end

  describe '#color3=' do
    it 'sets the color3 attribute' do
      subject.color3 = 40
      expect(subject.color3).to eq 40
    end
  end

  describe '#color4' do
    context 'default' do
      it 'returns 0' do
        expect(subject.color4).to eq 0
      end
    end
  end

  describe '#color4=' do
    it 'sets the color3 attribute' do
      subject.color4 = 50
      expect(subject.color4).to eq 50
    end
  end
end
