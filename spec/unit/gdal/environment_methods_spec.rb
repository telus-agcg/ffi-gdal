require 'spec_helper'
require 'gdal/environment_methods'

RSpec.describe GDAL::EnvironmentMethods do
  subject { Object.new.extend(described_class) }
end
