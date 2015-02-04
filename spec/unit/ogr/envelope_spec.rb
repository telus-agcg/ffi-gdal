require 'spec_helper'

RSpec.describe OGR::Envelope do
  describe '#x_min' do
    context 'default value' do
      subject { described_class.new.x_min }
      it { is_expected.to eq(0.0) }
    end
  end

  describe '#x_min= + #x_min' do
    it 'sets the x_min value' do
      subject.x_min = 123
      expect(subject.x_min).to eq 123.0
    end
  end

  describe '#x_max' do
    context 'default value' do
      subject { described_class.new.x_max }
      it { is_expected.to eq(0.0) }
    end
  end

  describe '#x_max= + #x_max' do
    it 'sets the x_max value' do
      subject.x_max = 123
      expect(subject.x_max).to eq 123.0
    end
  end

  describe '#y_min' do
    context 'default value' do
      subject { described_class.new.y_min }
      it { is_expected.to eq(0.0) }
    end
  end

  describe '#y_min= + #y_min' do
    it 'sets the y_min value' do
      subject.y_min = 123
      expect(subject.y_min).to eq 123.0
    end
  end

  describe '#y_max' do
    context 'default value' do
      subject { described_class.new.y_max }
      it { is_expected.to eq(0.0) }
    end
  end

  describe '#y_max= + #y_max' do
    it 'sets the y_max value' do
      subject.y_max = 123
      expect(subject.y_max).to eq 123.0
    end
  end

  context '2d' do
    describe '#z_min' do
      context 'default value' do
        subject { described_class.new.z_min }
        it { is_expected.to be_nil }
      end
    end

    describe '#z_min= + #z_min' do
      it 'sets the z_min value' do
        subject.z_min = 123
        expect(subject.z_min).to be_nil
      end
    end

    describe '#z_max' do
      context 'default value' do
        subject { described_class.new.z_max }
        it { is_expected.to be_nil }
      end
    end

    describe '#z_max= + #z_max' do
      it 'sets the z_max value' do
        subject.z_max = 123
        expect(subject.z_max).to be_nil
      end
    end
  end

  context '3d' do
    subject { described_class.new(three_d: true) }

    describe '#z_min' do
      context 'default value' do
        subject { described_class.new.z_min }
        it { is_expected.to be_nil }
      end
    end

    describe '#z_min= + #z_min' do
      it 'sets the z_min value' do
        subject.z_min = 123
        expect(subject.z_min).to eq 123.0
      end
    end

    describe '#z_max' do
      context 'default value' do
        subject { described_class.new.z_max }
        it { is_expected.to be_nil }
      end
    end

    describe '#z_max= + #z_max' do
      it 'sets the z_max value' do
        subject.z_max = 123
        expect(subject.z_max).to eq 123.0
      end
    end
  end

  describe '#world_to_pixels' do
    let(:geo_transform) do
      GDAL::GeoTransform.from_world_file('spec/support/worldfiles/SR_50M/SR_50M', '.tfw')
    end

    before do
      subject.x_min = 10
      subject.x_max = 20
      subject.y_min = -10
      subject.y_max = 0
    end

    context 'as integers' do
      it 'returns a Hash of translated values' do
        result = subject.world_to_pixels(geo_transform)
        expect(result).to eq(
          x_min: 5700,
          y_min: -2700,
          x_max: 6000,
          y_max: -3000
        )
      end
    end
  end

  describe '#==' do
    subject do
      envelope = described_class.new
      envelope.x_min = 10
      envelope.y_min = -100
      envelope.x_max = 50
      envelope.y_max = -50

      envelope
    end

    context 'envelopes are equal' do
      let(:other_envelope) do
        envelope = described_class.new
        envelope.x_min = 10
        envelope.y_min = -100
        envelope.x_max = 50
        envelope.y_max = -50

        envelope
      end

      it 'returns true' do
        expect(subject == other_envelope).to eq true
      end
    end

    context 'envelopes not equal' do
      let(:other_envelope) do
        envelope = described_class.new
        envelope.x_min = 0
        envelope.y_min = -100
        envelope.x_max = 50
        envelope.y_max = -50

        envelope
      end

      it 'returns false' do
        expect(subject == other_envelope).to eq false
      end
    end
  end

  describe '#merge' do
    subject do
      envelope = described_class.new
      envelope.x_min = 10
      envelope.y_min = -100
      envelope.x_max = 50
      envelope.y_max = -50

      envelope
    end

    let(:other_envelope) do
      envelope = described_class.new
      envelope.x_min = 0
      envelope.y_min = 0
      envelope.x_max = 500
      envelope.y_max = 250

      envelope
    end

    it 'returns a new OGR::Envelope' do
      expect(subject.merge(other_envelope)).to be_a OGR::Envelope
    end

    it 'has an x_min that equals the most minimum value between the two envelopes' do
      expect(subject.merge(other_envelope).x_min).to eq 0
    end

    it 'has an y_min that equals the most minimum value between the two envelopes' do
      expect(subject.merge(other_envelope).y_min).to eq(-100)
    end

    it 'has an x_max that equals the most maximum value between the two envelopes' do
      expect(subject.merge(other_envelope).x_max).to eq 500
    end

    it 'has an y_max that equals the most maximum value between the two envelopes' do
      expect(subject.merge(other_envelope).y_max).to eq 250
    end
  end

  describe '#intersects?' do
    subject do
      envelope = described_class.new
      envelope.x_min = 0
      envelope.x_max = 1
      envelope.y_min = 0
      envelope.y_max = 1

      envelope
    end

    context 'envelopes intersect' do
      let(:other_envelope) do
        envelope = described_class.new
        envelope.x_min = 0
        envelope.x_max = 1
        envelope.y_min = 0
        envelope.y_max = 1

        envelope
      end

      it 'returns true' do
        expect(subject.intersects?(other_envelope)).to eq true
      end
    end

    context 'envelopes do not intersect' do
      let(:other_envelope) do
        envelope = described_class.new
        envelope.x_min = 500
        envelope.y_min = 500
        envelope.x_max = 1000
        envelope.y_max = 1000

        envelope
      end

      it 'returns false' do
        expect(subject.intersects?(other_envelope)).to eq false
      end
    end
  end

  describe '#contains?' do
    subject do
      envelope = described_class.new
      envelope.x_min = 0
      envelope.x_max = 10
      envelope.y_min = 0
      envelope.y_max = 10

      envelope
    end

    context 'subject contains other envelope' do
      let(:other_envelope) do
        envelope = described_class.new
        envelope.x_min = 1
        envelope.x_max = 9
        envelope.y_min = 1
        envelope.y_max = 9

        envelope
      end

      it 'returns true' do
        expect(subject.contains?(other_envelope)).to eq true
      end
    end

    context 'subject does not contain other envelope' do
      let(:other_envelope) do
        envelope = described_class.new
        envelope.x_min = 500
        envelope.y_min = 500
        envelope.x_max = 1000
        envelope.y_max = 1000

        envelope
      end

      it 'returns false' do
        expect(subject.contains?(other_envelope)).to eq false
      end
    end
  end
end
