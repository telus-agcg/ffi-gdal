# frozen_string_literal: true

require "ogr/driver"
require "ogr/extensions/driver/capability_methods"

RSpec.describe OGR::Driver do
  context "Memory driver" do
    subject(:driver) { described_class.by_name("Memory") }

    describe "#can_create_data_source?" do
      subject { driver.can_create_data_source? }

      it { is_expected.to be true }
    end

    describe "#can_delete_data_source?" do
      subject { driver.can_delete_data_source? }

      # GDAL 3.11 aliased the Memory driver to the MEM driver, which
      # advertises DeleteDataSource support.
      it { is_expected.to eq(GDAL.version_num >= "3110000") }
    end
  end
end
