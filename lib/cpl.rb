# frozen_string_literal: true

require_relative 'ffi-gdal'

module CPL
  def self.cpl_require(path)
    File.expand_path(path, __dir__ || '.')
  end

  autoload :Error, cpl_require('cpl/error')
end
