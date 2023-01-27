# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ffi/gdal/version"

Gem::Specification.new do |spec|
  spec.name          = "ffi-gdal"
  spec.version       = FFI::GDAL::VERSION
  spec.authors       = ["Steve Loveless"]
  spec.email         = %w[steve.loveless@telusagcg.com]
  spec.summary       = "FFI wrapper for GDAL/OGR."
  spec.homepage      = "https://github.com/telus-agcg/ffi-gdal"
  spec.license       = "MIT"

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.metadata["rubygems_mfa_required"] = "true"
  spec.require_paths = %w[lib]
  spec.required_ruby_version = ">= 2.6"

  spec.add_dependency "bindata", "~> 2.0"
  spec.add_dependency "ffi"
  spec.add_dependency "log_switch", "~> 1.0.0"
  spec.add_dependency "multi_xml"
  spec.add_dependency "narray", "~> 0.6.0"
  spec.add_dependency "numo-narray"
end
