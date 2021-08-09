# vim: filetype=ruby
# frozen_string_literal: true

target :lib do
  signature 'sig', 'sig-gems'

  check 'lib/ffi/ogr/api/'

  check 'lib/ogr/circular_string*.rb'
  check 'lib/ogr/compound_curve*.rb'
  check 'lib/ogr/coordinate_transformation.rb'
  check 'lib/ogr/curve*.rb'
  check 'lib/ogr/field_definition.rb'
  check 'lib/ogr/geometry/'
  check 'lib/ogr/geometry.rb'
  check 'lib/ogr/geometry_collection*.rb'
  check 'lib/ogr/geometry_field_definition.rb'
  check 'lib/ogr/line_string*.rb'
  check 'lib/ogr/linear_ring.rb'
  check 'lib/ogr/multi_curve*.rb'
  check 'lib/ogr/multi_line_string*.rb'
  check 'lib/ogr/multi_point*.rb'
  check 'lib/ogr/multi_polygon*.rb'
  check 'lib/ogr/multi_surface*.rb'
  check 'lib/ogr/none_geometry.rb'
  check 'lib/ogr/point*.rb'
  check 'lib/ogr/polygon*.rb'
  check 'lib/ogr/unknown_geometry.rb'

  # check "Gemfile"                   # File name
  # ignore "lib/templates/*.rb"

  # library "pathname", "set"       # Standard libraries
  library 'logger', 'monitor'
  # library "strong_json"           # Gems
end

# target :spec do
#   signature "sig", "sig-private"
#
#   check "spec"
#
#   # library "pathname", "set"       # Standard libraries
#   # library "rspec"
# end
