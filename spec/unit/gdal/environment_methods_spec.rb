# frozen_string_literal: true

require "gdal/environment_methods"

RSpec.describe GDAL::EnvironmentMethods do
  subject { Object.new.extend(described_class) }

  it "is extendable onto an object" do
    expect(subject).to be_a(described_class)
  end
end
