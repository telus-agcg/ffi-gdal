# vim: filetype=ruby
# frozen_string_literal: true

target :lib do
  signature 'sig', 'sig-gems'

  check 'lib/ffi/ogr/api/',
        'lib/ogr/circular_string*.rb',
        'lib/ogr/compound_curve*.rb',
        'lib/ogr/coordinate_transformation.rb',
        'lib/ogr/curve.rb',
        'lib/ogr/curve_polygon.rb',
        'lib/ogr/field_definition.rb',
        'lib/ogr/geometry/',
        'lib/ogr/geometry.rb',
        'lib/ogr/geometry_collection.rb',
        'lib/ogr/geometry_collection_25d.rb',
        'lib/ogr/geometry_field_definition.rb',
        'lib/ogr/line_string.rb',
        'lib/ogr/line_string_25d.rb',
        'lib/ogr/linear_ring.rb',
        'lib/ogr/multi_curve.rb',
        'lib/ogr/multi_curve_25d.rb',
        'lib/ogr/multi_line_string.rb',
        'lib/ogr/multi_line_string_25d.rb',
        'lib/ogr/multi_point.rb',
        'lib/ogr/multi_point_25d.rb',
        'lib/ogr/multi_polygon.rb',
        'lib/ogr/multi_polygon_25d.rb',
        'lib/ogr/multi_surface.rb',
        'lib/ogr/multi_surface_25d.rb',
        'lib/ogr/none_geometry.rb',
        'lib/ogr/point.rb',
        'lib/ogr/point_25d.rb',
        'lib/ogr/polygon.rb',
        'lib/ogr/polygon_25d.rb',
        'lib/ogr/unknown_geometry.rb'

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
