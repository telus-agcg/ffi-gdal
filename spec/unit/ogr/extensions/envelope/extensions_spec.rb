# frozen_string_literal: true

require "ogr/extensions/envelope/extensions"
require "gdal/geo_transform"

RSpec.describe OGR::Envelope::Extensions do
  subject(:envelope) { OGR::Envelope.new }

  describe "#world_to_pixels" do
    let(:geo_transform) do
      GDAL::GeoTransform.from_world_file("spec/support/worldfiles/SR_50M/SR_50M", ".tfw")
    end

    before do
      subject.x_min = 10
      subject.x_max = 20
      subject.y_min = -10
      subject.y_max = 0
    end

    context "as integers" do
      it "returns a Hash of translated values" do
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

  describe "#==" do
    before do
      envelope.x_min = 10
      envelope.y_min = -100
      envelope.x_max = 50
      envelope.y_max = -50
    end

    context "envelopes are equal" do
      let(:other_envelope) do
        envelope = OGR::Envelope.new
        envelope.x_min = 10
        envelope.y_min = -100
        envelope.x_max = 50
        envelope.y_max = -50

        envelope
      end

      it "returns true" do
        expect(subject == other_envelope).to eq true
      end
    end

    context "envelopes not equal" do
      let(:other_envelope) do
        envelope = OGR::Envelope.new
        envelope.x_min = 0
        envelope.y_min = -100
        envelope.x_max = 50
        envelope.y_max = -50

        envelope
      end

      it "returns false" do
        expect(subject == other_envelope).to eq false
      end
    end
  end

  describe "#merge" do
    before do
      envelope.x_min = 10
      envelope.y_min = -100
      envelope.x_max = 50
      envelope.y_max = -50
    end

    let(:other_envelope) do
      envelope = OGR::Envelope.new
      envelope.x_min = 0
      envelope.y_min = 0
      envelope.x_max = 500
      envelope.y_max = 250

      envelope
    end

    it "returns a new OGR::Envelope" do
      expect(subject.merge(other_envelope)).to be_a OGR::Envelope
    end

    it "has an x_min that equals the most minimum value between the two envelopes" do
      expect(subject.merge(other_envelope).x_min).to eq 0
    end

    it "has an y_min that equals the most minimum value between the two envelopes" do
      expect(subject.merge(other_envelope).y_min).to eq(-100)
    end

    it "has an x_max that equals the most maximum value between the two envelopes" do
      expect(subject.merge(other_envelope).x_max).to eq 500
    end

    it "has an y_max that equals the most maximum value between the two envelopes" do
      expect(subject.merge(other_envelope).y_max).to eq 250
    end
  end

  describe "#intersects?" do
    before do
      envelope.x_min = 0
      envelope.x_max = 1
      envelope.y_min = 0
      envelope.y_max = 1
    end

    context "envelopes intersect" do
      let(:other_envelope) do
        envelope = OGR::Envelope.new
        envelope.x_min = 0
        envelope.x_max = 1
        envelope.y_min = 0
        envelope.y_max = 1

        envelope
      end

      it "returns true" do
        expect(subject.intersects?(other_envelope)).to eq true
      end
    end

    context "envelopes do not intersect" do
      let(:other_envelope) do
        envelope = OGR::Envelope.new
        envelope.x_min = 500
        envelope.y_min = 500
        envelope.x_max = 1000
        envelope.y_max = 1000

        envelope
      end

      it "returns false" do
        expect(subject.intersects?(other_envelope)).to eq false
      end
    end
  end

  describe "#contains?" do
    before do
      envelope.x_min = 0
      envelope.x_max = 10
      envelope.y_min = 0
      envelope.y_max = 10
    end

    context "subject contains other envelope" do
      let(:other_envelope) do
        envelope = OGR::Envelope.new
        envelope.x_min = 1
        envelope.x_max = 9
        envelope.y_min = 1
        envelope.y_max = 9

        envelope
      end

      it "returns true" do
        expect(subject.contains?(other_envelope)).to eq true
      end
    end

    context "subject does not contain other envelope" do
      let(:other_envelope) do
        envelope = OGR::Envelope.new
        envelope.x_min = 500
        envelope.y_min = 500
        envelope.x_max = 1000
        envelope.y_max = 1000

        envelope
      end

      it "returns false" do
        expect(subject.contains?(other_envelope)).to eq false
      end
    end
  end
end
