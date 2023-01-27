# frozen_string_literal: true

require "gdal"

RSpec.describe GDAL::Dataset do
  include_context "A .tif Dataset"

  describe ".open" do
    context "not a dataset" do
      it "raises an GDAL::OpenFailure" do
        expect do
          described_class.open("blarg", "r")
        end.to raise_exception GDAL::OpenFailure
      end
    end

    context "block given" do
      let(:dataset) { instance_double "GDAL::Dataset" }

      it "yields then closes the opened DataSource" do
        allow(described_class).to receive(:new).and_return dataset

        expect(dataset).to receive(:close)
        expect { |b| described_class.open("blarg", "r", &b) }
          .to yield_with_args(dataset)
      end
    end
  end

  describe ".copy_whole_raster" do
    it "doesn't blow up" do
      destination = GDAL::Driver
                    .by_name("MEM")
                    .create_dataset("testy", subject.raster_x_size, subject.raster_y_size,
                                    band_count: subject.raster_count, data_type: subject.raster_band(1).data_type)
      described_class.copy_whole_raster(subject, destination)
    end
  end
end
