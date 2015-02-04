require 'spec_helper'

RSpec.describe OGR::Layer do
  let(:driver) { OGR::Driver.by_name 'Memory' }
  let(:data_source) { driver.create_data_source 'spec data source' }

  subject(:layer) do
    data_source.create_layer 'spec layer',
                              geometry_type: :wkbMultiPoint,
                              spatial_reference: OGR::SpatialReference.new_from_epsg(4326)
  end

  describe '#name' do
    it 'returns the name given to it' do
      expect(subject.name).to eq 'spec layer'
    end
  end

  describe '#geometry_type' do
    it 'returns the type it was created with' do
      expect(subject.geometry_type).to eq :wkbMultiPoint
    end
  end

  describe '#next_feature_index=' do
    context 'no features' do
      it 'raises an OGR::Failure' do
        expect { subject.next_feature_index = 123 }.
          to raise_exception OGR::Failure
      end
    end

    context 'features exist' do
      let!(:feature1) do
        subject.create_feature
      end

      let!(:feature2) do
        subject.create_feature
      end

      it 'sets to the given feature' do
        subject.next_feature_index = 1
        expect(subject.next_feature).to_not be_nil
      end
    end
  end

  describe '#spatial_filter' do
    context 'default' do
      subject { layer.spatial_filter }
      it { is_expected.to be_nil }
    end
  end

  describe '#spatial_filter= + #spatial_filter' do
    it 'assigns the spatial_filter to the new geometry' do
      geometry = OGR::Geometry.create_from_wkt('POINT (1 1)')
      subject.spatial_filter = geometry
      expect(subject.spatial_filter).to eq geometry
    end
  end

  describe '#set_spatial_filter_ex' do
    it 'does not die' do
      geometry = OGR::Geometry.create_from_wkt('POINT (1 1)')
      expect { subject.set_spatial_filter_ex(0, geometry) }.to_not raise_exception
    end
  end

  describe '#set_spatial_filter_rectangle' do
    it 'does not die' do
      expect { subject.set_spatial_filter_rectangle(0, 0, 1000, 1000) }.
        to_not raise_exception
    end
  end

  describe '#set_spatial_filter_rectangle_ex' do
    it 'does not die' do
      expect { subject.set_spatial_filter_rectangle_ex(0, 0, 0, 1000, 1000) }.
        to_not raise_exception
    end
  end

  describe '#symmetrical_difference' do
    let(:other_layer) do
      data_source.create_layer 'other layer',
                               geometry_type: :wkbMultiPoint,
                               spatial_reference: OGR::SpatialReference.new_from_epsg(4326)
    end

    it 'does not die' do
      skip 'Figuring out how to init a result pointer'
      # expect { subject.symmetrical_difference(other_layer) }.
      #   to_not raise_exception
    end
  end

  describe '#sync_to_disk' do
    it 'does not die' do
      expect { subject.sync_to_disk }.to_not raise_exception
    end
  end

  describe '#test_capability' do
    context 'some supported capabilities to check' do
      let(:capabilities) do
        %w[OLCRandomRead OLCCreateField OLCCurveGeometries]
      end

      # I don't get why these return false...
      it 'returns false' do
        capabilities.each do |capability|
          expect(subject.test_capability(capability)).to eq false
        end
      end
    end

    context 'unsupported capabilities to check' do
      it 'returns false' do
        expect(subject.test_capability('meow')).to eq false
      end
    end
  end
end
