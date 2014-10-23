require 'bundler/setup'
require 'pry'
require 'ffi-gdal'

include GDAL::Logger
GDAL::Logger.logging_enabled = true


# https://trac.osgeo.org/gdal/ticket/1599

#floyd_path = '/Users/sloveless/Development/projects/ffi-gdal/spec/support/images/Floyd/Floyd_1058_20140612_NRGB.tif'
#floyd = GDAL::Dataset.open(floyd_path, 'r')
#floyd_wkt = 'MULTIPOLYGON(((-87.5530099868775 31.16710573359053,-87.65300998687 31.167105000001, -87.5530099868775 31.165600160261103,-87.55384683609009 31.16710573359053,-87.5530099868775 31.16710573359053)))'
spatial_ref = OGR::SpatialReference.new_from_epsg(4326)
#floyd_geometry = OGR::Geometry.create_from_wkt(floyd_wkt, spatial_ref)
#floyd_geometry.transform_to!(floyd.spatial_reference)

harper_wkt = "MULTIPOLYGON (((-87.5639814967 31.18677438740807, -87.56095596493151 31.186756030714633, -87.56127783001327 31.185048842709264, -87.56022640407895 31.184259487308854, -87.55996891201355 31.183800556723995, -87.56037660778345 31.183470125325623, -87.55999036968537 31.182295248791167, -87.55936809719456 31.181891381615166, -87.55887457073558 31.18031261157701, -87.55968996227632 31.180018884013712, -87.55872436703105 31.17799948235227, -87.55769439876855 31.177852615097343, -87.55664297283512 31.177283502330614, -87.5565464133106 31.175998396405248, -87.56492563427345 31.176016755184154, -87.56496854961708 31.177154992523167, -87.5639814967 31.177669030707264, -87.56415315807725 31.178752173461035, -87.56501146496161 31.179908735942732, -87.56496854961708 31.18462663017465, -87.56400295437183 31.184810201073287, -87.5639814967 31.18677438740807)))"
harper_path = '/Users/sloveless/Development/projects/ffi-gdal/spec/support/images/Harper/Harper_1058_20140612_NRGB.tif'
harper = GDAL::Dataset.open(harper_path, 'r')
harper_geometry = OGR::Geometry.create_from_wkt(harper_wkt, spatial_ref)
harper_geometry.transform_to!(harper.spatial_reference)

#epsg4326_geom = floyd.to_geometry

#floyd.close
harper.close


#puts floyd.contains_geometry?(floyd_wkt)

#`gdalwarp -wo "INIT_DEST=255,0,255" -wo "#{floyd_geometry.to_wkt}" #{floyd_path} cut-out.tif`
#`gdalwarp  -wo "CUTLINE=#{floyd_geometry.to_wkt}" #{floyd_path} cut-out.tif`
#`gdalwarp -dstnodata -1 -cutline "#{floyd_geometry.to_wkt}" #{floyd_path} cut-out.tif`
#cmd = %{gdalwarp -dstnodata -1 -cutline "#{floyd_geometry.to_wkt}" -crop_to_cutline #{floyd_path} cut-out.tif}
#cmd = %{gdalwarp -dstnodata -1 -cutline "#{floyd_geometry.to_wkt}" -crop_to_cutline #{floyd_path} cut-out.tif}

# Result: No file
# cmd = %{gdalwarp -cutline "#{floyd_geometry.to_wkt}" -crop_to_cutline #{floyd_path} cut-out.tif}

#cmd = %{gdalwarp -wo "INIT_DEST=NO_DATA" -wo "CUTLINE=#{floyd_geometry.to_wkt}" -crop_to_cutline #{floyd_path} cut-out.tif}
#cmd = %{gdalwarp -wo "CUTLINE_ALL_TOUCHED=TRUE" -wo "INIT_DEST=NO_DATA" -wo "CUTLINE=#{floyd_geometry.to_wkt}" -crop_to_cutline #{floyd_path} cut-out.tif}
#cmd = %{gdalwarp -wo "CUTLINE_ALL_TOUCHED=TRUE" -wo "CUTLINE=#{floyd_geometry.to_wkt}" -wo "SAMPLE_GRID=YES" #{floyd_path} cut-out.tif}
#cmd = %{gdalwarp -wo "ALL_TOUCHED=TRUE" -wo "CUTLINE=#{floyd_geometry.to_wkt}" #{floyd_path} cut-out.tif}
#cmd = %{gdal_grid -clipsrc "#{floyd_geometry.to_wkt}" #{floyd_path} cut-out.tif}

require 'fileutils'
FileUtils.rm_rf 'stuff'
FileUtils.rm_rf 'stuff.shp'
FileUtils.rm_rf 'stuff.*'
FileUtils.rm_rf 'geometry.json'
FileUtils.rm_rf 'cut-out.tif'

#File.write('geometry.json', harper_geometry.to_geo_json)
#File.write('geometry.json', epsg4326_geom.to_geo_json)
#ogr_cmd = %{ogr2ogr -f "ESRI Shapefile" stuff.shp geometry.json OGRGeoJSON}
#p ogr_cmd

#{}`#{ogr_cmd}`

def make_shapefile(geo_json)
  geo_json_file = Tempfile.new(%w[geo_json .json])
  geo_json_file.write(geo_json)
  geo_json_file.close

  shape_dir = Dir.mktmpdir('shapes')
  shapefile_name = 'clip_shape.shp'
  shapefile_path = File.join(shape_dir, shapefile_name)

  ogr_command = %{ogr2ogr -f "ESRI Shapefile" #{shapefile_path} #{geo_json_file.path} OGRGeoJSON}
  logger.debug "Running command to make shapefile: #{ogr_command}"

  `#{ogr_command}`

  FileUtils.rm("#{shape_dir}/clip_shape.prj")

  shape_dir
end

# Result: Empty file
#cmd = %{gdalwarp -wo "CUTLINE=#{floyd_wkt}" -s_srs "EPSG:32616" #{floyd_path} cut-out.tif}
#prj_file = File.expand_path('stuff.prj', __dir__)
#p prj_file
#FileUtils.rm  prj_file
binding.pry

#cmd = %{gdalwarp -dstnodata -1 -s_srs EPSG:32616 -t_srs EPSG:26916 -crop_to_cutline -cutline stuff.shp #{floyd_path} cut-out.tif}
cmd = %{gdalwarp -dstnodata -1 -s_srs EPSG:32616 -t_srs EPSG:26916 -crop_to_cutline -cutline stuff.shp #{harper_path} cut-out.tif}

p cmd
`#{cmd}`
