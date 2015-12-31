require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

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

task(:spec) { RSpec::Core::RakeTask.new }
task default: :spec
