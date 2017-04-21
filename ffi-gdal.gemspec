# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ffi/gdal/version'

Gem::Specification.new do |spec|
  spec.name          = 'ffi-gdal'
  spec.version       = FFI::GDAL::VERSION
  spec.authors       = ['Steve Loveless']
  spec.email         = %w[steve@agrian.com]
  spec.summary       = 'FFI wrapper for GDAL/OGR.'
  spec.homepage      = 'http://bitbucket.org/agrian/ffi-gdal'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w[lib]

  spec.add_dependency 'ffi'
  spec.add_dependency 'log_switch', '~> 1.0.0'
  spec.add_dependency 'multi_xml'
  spec.add_dependency 'narray', '~> 0.6.0'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'fakefs'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-checkstyle_formatter'
  spec.add_development_dependency 'simplecov', '~> 0.9.0'
end
