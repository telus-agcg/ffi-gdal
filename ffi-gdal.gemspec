# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ffi/gdal/version'

Gem::Specification.new do |spec|
  spec.name          = 'ffi-gdal'
  spec.version       = FFI::GDAL::VERSION
  spec.authors       = ['Steve Loveless']
  spec.email         = %w[steve@agrian.com]
  spec.summary       = 'FFI wrapper for GDAL/OGR.'
  spec.homepage      = 'http://github.com/agrian-inc/ffi-gdal'
  spec.license       = 'MIT'

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.require_paths = %w[lib]
  spec.required_ruby_version = '>= 3.0'

  spec.add_dependency 'ffi'
  spec.add_dependency 'log_switch', '~> 1.0.0'
  spec.add_dependency 'multi_xml'
  spec.add_dependency 'narray', '~> 0.6.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'fakefs'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '>= 1.0'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'simplecov', '~> 0.9'
  spec.add_development_dependency 'steep'
end
