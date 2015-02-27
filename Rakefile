require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

desc 'Download files for running integration tests against'
task :get_tiffs do
  require 'net/ftp'
  require 'fileutils'

  base_dest_dir = 'spec/support/images/osgeo/geotiff'

  if Dir.exist? base_dest_dir
    puts 'Tiff dir already exists.  Exiting.'
    exit
  end

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


namespace :spec do
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern = 'spec/unit/**/*_spec.rb'
  end

  RSpec::Core::RakeTask.new(:integration) do |t|
    t.pattern = 'spec/integration/**/*_spec.rb'
  end

  desc 'Run specs with valgrind'
  task :valgrind do
    valgrind_options = %w[
      --num-callers=50
      --error-limit=no
      --partial-loads-ok=yes
      --undef-value-errors=no
      --show-leak-kinds=all
      --trace-children=yes
      --log-file=valgrind_output.log
    ].join(' ')

    cmd = %[valgrind #{valgrind_options} bundle exec rake spec SPEC_OPTS="--format documentation"]
    puts cmd
    system(cmd)
  end
end

task spec: 'spec:unit'
task default: 'spec:unit'
