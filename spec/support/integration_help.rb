TIF_FILES = Dir.glob('spec/support/images/osgeo/**/*.tif')
warn 'No Tiff files for integration specs!' if TIF_FILES.empty?
