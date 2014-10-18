require 'bundler/setup'
require 'pry'
require 'ffi-gdal'

include GDAL::Logger
GDAL::Logger.logging_enabled = true


floyd_path = '/Users/sloveless/Development/projects/ffi-gdal/spec/support/images/Floyd/Floyd_1058_20140612_NRGB.tif'
floyd = GDAL::Dataset.open(floyd_path, 'r')
floyd_wkt = 'MULTIPOLYGON (((-87.5530099868775 31.16710573359053,-87.5530099868775 31.165600160261103,-87.55384683609009 31.16710573359053,-87.5530099868775 31.16710573359053)))'

# http://pcjericks.github.io/py-gdalogr-cookbook/vector_layers.html#convert-vector-layer-to-array
pixel_size = 25
no_data_value = -1

# Get the extent of the geometry
spatial_reference = OGR::SpatialReference.new_from_epsg(4326)
geometry = OGR::Geometry.create_from_wkt(floyd_wkt, spatial_reference)
geometry.transform_to!(floyd.spatial_reference)
source_srs = geometry.spatial_reference
polygon = geometry.geometry_at 0
ring = polygon.geometry_at 0

extent = geometry.envelope
x_min = extent.x_min
x_max = extent.x_max
y_min = extent.y_min
y_max = extent.y_max

log "x_min: #{x_min}"
log "y_min: #{y_min}"
log "y_max: #{y_max}"
log "x_max: #{x_max}"

# extent = geometry.envelope.world_to_pixel(floyd.geo_transform)
# x_min = extent[:x_origin]
# x_max = extent[:x_max]
# y_min = extent[:y_origin]
# y_max = extent[:y_max]
# log "x_min: #{x_min}"
# log "y_min: #{y_min}"
# log "y_max: #{y_max}"
# log "x_max: #{x_max}"


# Create the destination data source
x_res = ((x_max - x_min) / pixel_size).to_i
y_res = ((y_max - y_min) / pixel_size).to_i
log "x_res: #{x_res}"
log "y_res: #{y_res}"

#target_ds = GDAL::Driver.by_name('MEM').create_dataset('', x_res, y_res, data_type: :GDT_Float32)
target_ds = GDAL::Driver.by_name('GTiff').create_dataset('grr.tif', x_res, y_res, data_type: :GDT_Float32)

geo_transform = floyd.geo_transform
geo_transform.x_origin = x_min
geo_transform.pixel_width = pixel_size
geo_transform.y_origin = y_max
geo_transform.pixel_width = -pixel_size
target_ds.geo_transform = geo_transform
target_ds.projection = floyd.projection

band = target_ds.raster_band(1)
band.no_data_value = no_data_value
band.fill(100)

#target_ds.rasterize_geometries!(1, geometry, 1, all_touched: 'TRUE')
target_ds.rasterize_geometries!(1, ring, 1, all_touched: 'TRUE')

band.to_na


binding.pry

target_ds.close
