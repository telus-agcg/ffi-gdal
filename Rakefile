require 'bundler/gem_tasks'

desc 'Download files for running integration tests against'
task :get_tifs do
  require 'net/ftp'
  require 'fileutils'

  base_dest_dir = 'spec/support/images/osgeo/geotiff'

  Net::FTP.open('downloads.osgeo.org') do |ftp|
    ftp.login
    ftp.binary = true

    base_dir = 'geotiff/samples'
    _, dirs = files_and_dirs(base_dir, ftp)

    dirs.each do |dir_name|
      path = "#{base_dir}/#{dir_name}"
      files, dirs = files_and_dirs(path, ftp)
      dest_dir = "#{base_dest_dir}/#{dir_name}"

      FileUtils.mkdir_p(dest_dir) unless Dir.exist?(dest_dir)

      files.each do |file|
        src_file = "#{path}/#{file}"
        dest_file = "#{dest_dir}/#{file}"

        puts "Getting file '#{src_file}' to '#{dest_file}'..."
        ftp.get("#{src_file}", "#{dest_file}")
      end
    end
  end
end

# @return [Array{files => Array, dirs => Array}]
def files_and_dirs(in_dir, ftp)
  dirs = []
  files = []

  puts "Getting stuff from #{in_dir}..."

  ftp.list("#{in_dir}/*") do |item|
    item_name = item.split(' ').last

    if item.start_with? 'd'
      dirs << item_name
    else
      files << item_name
    end
  end

  [files, dirs]
end

