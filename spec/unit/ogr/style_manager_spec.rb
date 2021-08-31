# frozen_string_literal: true

require 'ogr/style_manager'
require 'ogr/style_table'
require 'ogr/style_tool'

RSpec.describe OGR::StyleManager do
  subject { described_class.create }

  let(:style_table) do
    OGR::StyleTable.create.tap do |st|
      st.add_style('pretty mode', 'LABEL(f:17)')
    end
  end

  let(:style_tool) do
    OGR::StyleTool.create(:OGRSTCLabel).tap do |st|
      st.set_param_as_integer(0, 42)
    end
  end

  describe '.create' do
    context 'no StyleTable given' do
      it 'instantiates a StyleManager' do
        expect(described_class.create).to be_a described_class
      end
    end

    context 'StyleTable given' do
      it 'instantiates a StyleManager' do
        expect(described_class.create(style_table)).to be_a described_class
      end
    end
  end

  describe '#init_from_feature' do
    let(:feature) do
      field_def = OGR::FieldDefinition.create('test integer field', :OFTInteger)
      feature_def = OGR::FeatureDefinition.create('test FD')
      feature_def.add_field_definition(field_def)

      OGR::Feature.create(feature_def).tap do |f|
        f.style_string = 'LABEL(f:12345)'
      end
    end

    it 'does not crash' do
      subject.init_from_feature(feature)
    end
  end

  describe '#init_style_string' do
    it 'does not crash' do
      subject.init_style_string('LABEL(f:12345)')
    end
  end

  describe '#part_count' do
    context 'style_string not given, not inited from StyleTable' do
      it 'does not crash' do
        subject.part_count
      end
    end

    context 'style_string not given, inited from StyleTable' do
      subject { described_class.create(style_table) }

      it 'does not crash' do
        subject.part_count
      end
    end

    context 'style_string given' do
      it 'does not crash' do
        subject.part_count('LABEL(f:12345)')
      end
    end
  end

  describe '#add_part, #part' do
    context 'no parts added, no style_string given' do
      it 'raises' do
        expect { subject.part(0) }.to raise_exception FFI::GDAL::InvalidPointer
      end
    end

    context 'no parts added, style_string given' do
      it 'returns a pointer to a new StyleTool' do
        result = subject.part(0, 'LABEL(f:12345)')
        expect(result).to be_a OGR::StyleTool
        expect(result.style_string).to eq 'LABEL(f:12345)'
      end
    end

    context 'one part added, no style_string given' do
      before { subject.add_part(style_tool) }

      it 'returns a pointer to the same style tool' do
        expect(subject.part(0)).to be_a OGR::StyleTool
        expect(subject.part(0).style_string).to eq 'LABEL(f:42)'
      end
    end

    context 'one part added, style_string given' do
      before { subject.add_part(style_tool) }
      it 'returns a pointer to a new StyleTool' do
        result = subject.part(0, 'LABEL(f:99)')

        expect(result).to be_a OGR::StyleTool
        expect(result.style_string).to eq('LABEL(f:99)')
      end
    end
  end

  describe '#add_part, #part_count' do
    context 'no parts added, no style_string given' do
      specify { expect(subject.part_count).to be_zero }
    end

    context 'no parts added, style_string given' do
      specify { expect(subject.part_count('LABEL(f:12345)')).to eq 1 }
    end

    context 'one part added, no style_string given' do
      before { subject.add_part(style_tool) }
      specify { expect(subject.part_count).to eq 1 }
    end

    context 'one part added, style_string given' do
      before { subject.add_part(style_tool) }
      specify { expect(subject.part_count('LABEL(f:12345)')).to eq 1 }
    end
  end

  describe '#add_style' do
    it 'does not crash' do
      subject.add_style('happy', 'LABEL(f:432)')
    end
  end
end
