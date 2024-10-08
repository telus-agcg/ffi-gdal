# frozen_string_literal: true

RSpec.shared_context "A .tif Dataset" do
  let(:file_path) do
    File.expand_path("images/osgeo/geotiff/GeogToWGS84GeoKey/GeogToWGS84GeoKey5.tif", __dir__)
  end

  subject do
    GDAL::Dataset.open(file_path, "r", shared: false)
  end
end

RSpec.shared_context "OGR::Layer, spatial_reference" do
  require "ogr/driver"
  require "ogr/spatial_reference"

  let(:driver) { OGR::Driver.by_name "Memory" }
  let(:data_source) { driver.create_data_source "spec data source" }

  subject(:layer) do
    data_source.create_layer "spec layer",
                             geometry_type: :wkbMultiPoint,
                             spatial_reference: OGR::SpatialReference.new.import_from_epsg(4326)
  end
end

RSpec.shared_context "OGR::Layer, no spatial_reference" do
  require "ogr/driver"
  require "ogr/spatial_reference"

  let(:driver) { OGR::Driver.by_name "Memory" }
  let(:data_source) { driver.create_data_source "spec data source" }

  subject(:layer) do
    data_source.create_layer "spec layer",
                             geometry_type: :wkbMultiPoint
  end
end
