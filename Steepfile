# frozen_string_literal: true

# vim: filetype=ruby

# D = Steep::Diagnostic

target :lib do
  signature 'sig', 'sig-gems'

  check 'lib/ffi/ogr/api/',
        'lib/ogr/circular_string*.rb',
        'lib/ogr/compound_curve*.rb',
        'lib/ogr/coordinate_transformation.rb',
        'lib/ogr/curve*.rb',
        'lib/ogr/feature*.rb',
        'lib/ogr/field_definition.rb',
        'lib/ogr/geometry/',
        'lib/ogr/geometry.rb',
        'lib/ogr/geometry_collection*.rb',
        'lib/ogr/geometry_field_definition.rb',
        # 'lib/ogr/layer.rb',
        # 'lib/ogr/layer_mixins/*.rb',
        'lib/ogr/line_string*.rb',
        'lib/ogr/linear_ring.rb',
        'lib/ogr/multi_*.rb',
        'lib/ogr/none_geometry.rb',
        'lib/ogr/point*.rb',
        'lib/ogr/polygon.rb',
        'lib/ogr/polygon*.rb',
        'lib/ogr/style_*.rb',
        'lib/ogr/unknown_geometry.rb'

  # check "Gemfile"                   # File name
  # ignore "lib/templates/*.rb"

  # library "pathname", "set"       # Standard libraries
  library 'logger', 'monitor'
  # library "strong_json"           # Gems
  #
  #   # configure_code_diagnostics(D::Ruby.strict)       # `strict` diagnostics setting
  #   # configure_code_diagnostics(D::Ruby.lenient)      # `lenient` diagnostics setting
  #   # configure_code_diagnostics do |hash|             # You can setup everything yourself
  #   #   hash[D::Ruby::NoMethod] = :information
  #   # end
end

# target :test do
#   signature "sig", "sig-private"
#
#   check "test"
#
#   # library "pathname", "set"       # Standard libraries
# end
