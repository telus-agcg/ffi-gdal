require 'spec_helper'

RSpec.describe OGR::Layer do
  include_context 'OGR::Layer, spatial_reference'

  describe '#create_field + #find_field_index' do
    it 'can create an OFTInteger' do
      subject.create_field('test field', :OFTInteger)
      expect(subject.find_field_index('test field')).to be_zero
    end

    it 'can create an OFTIntegerList' do
      subject.create_field('test field', :OFTIntegerList)
      expect(subject.find_field_index('test field')).to be_zero
    end

    it 'can create an OFTReal' do
      subject.create_field('test field', :OFTReal)
      expect(subject.find_field_index('test field')).to be_zero
    end

    it 'can create an OFTRealList' do
      subject.create_field('test field', :OFTRealList)
      expect(subject.find_field_index('test field')).to be_zero
    end

    it 'can create an OFTString' do
      subject.create_field('test field', :OFTString)
      expect(subject.find_field_index('test field')).to be_zero
    end

    it 'can create an OFTStringList' do
      subject.create_field('test field', :OFTStringList)
      expect(subject.find_field_index('test field')).to be_zero
    end

    it 'can create an OFTWideString' do
      subject.create_field('test field', :OFTWideString)
      expect(subject.find_field_index('test field')).to be_zero
    end

    it 'can create an OFTWideStringList' do
      subject.create_field('test field', :OFTWideStringList)
      expect(subject.find_field_index('test field')).to be_zero
    end

    it 'can create an OFTBinary' do
      subject.create_field('test field', :OFTBinary)
      expect(subject.find_field_index('test field')).to be_zero
    end

    it 'can create an OFTDate' do
      subject.create_field('test field', :OFTDate)
      expect(subject.find_field_index('test field')).to be_zero
    end

    it 'can create an OFTTime' do
      subject.create_field('test field', :OFTTime)
      expect(subject.find_field_index('test field')).to be_zero
    end

    it 'can create an OFTDateTime' do
      subject.create_field('test field', :OFTDateTime)
      expect(subject.find_field_index('test field')).to be_zero
    end
  end

  describe '#delete_field + #create_field' do
    context 'field exists at index' do
      before do
        subject.create_field('test field', :OFTInteger)
      end

      it 'can delete the field' do
        expect(subject.delete_field(0)).to eq true
      end
    end

    context 'field does not exist at index' do
      it 'raises a GDAL::UnsupportedOperation' do
        expect { subject.delete_field(1) }.to raise_exception GDAL::UnsupportedOperation
      end
    end
  end

  describe '#reorder_fields + #create_field' do
    context 'field does not exist at one of the given indexes' do
      it do
        expect(subject.feature_definition.find_field(0)).to be_nil
        expect(subject.reorder_fields(1, 0)).to eq false
      end
    end

    context 'fields exist' do
      before do
        subject.create_field('field0', :OFTInteger)
        subject.create_field('field1', :OFTString)
      end

      it 'returns true and reorders the fields' do
        expect(subject.find_field_index('field0')).to eq 0
        expect(subject.find_field_index('field1')).to eq 1

        expect(subject.reorder_fields(1, 0)).to eq true

        expect(subject.find_field_index('field0')).to eq 1
        expect(subject.find_field_index('field1')).to eq 0
      end
    end
  end
end
