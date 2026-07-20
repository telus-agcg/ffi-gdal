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
  spec.required_ruby_version = ">= 3.4"

  spec.add_dependency "bindata", "~> 2.0"
  spec.add_dependency "ffi"
  spec.add_dependency "log_switch", ">= 1.0", "< 1.2"
  # `logger` was removed from Ruby's default gems in 4.0; log_switch
  # requires it, so declare it explicitly rather than relying on it
  # being bundled with the interpreter.
  spec.add_dependency "logger"
  spec.add_dependency "multi_xml"
  spec.add_dependency "narray", "~> 0.6.0"
  spec.add_dependency "numo-narray"
  # `multi_xml` (used by GDAL::Driver/GDAL::MajorObject) needs a real XML
  # parser backend (Nokogiri/LibXML/Ox/REXML); we don't otherwise depend on
  # one, so declare rexml explicitly rather than relying on it happening to
  # be installed as some other gem's transitive dependency.
  spec.add_dependency "rexml"
end
