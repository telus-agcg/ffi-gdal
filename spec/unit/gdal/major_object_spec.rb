require 'spec_helper'
require 'gdal/major_object'

RSpec.describe GDAL::MajorObject do
  subject { Object.new.extend(described_class) }
end
