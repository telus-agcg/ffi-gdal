# frozen_string_literal: true

module GDAL
  module Utils
    # Internal helpers for GDAL Utils.
    module Helpers
      autoload :DatasetList, File.expand_path("helpers/dataset_list", __dir__)
      autoload :StringList, File.expand_path("helpers/string_list", __dir__)
    end
  end
end
