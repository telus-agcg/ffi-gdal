$:.unshift File.expand_path('../lib', __FILE__)
$:.unshift File.expand_path('../spec', __FILE__)

Dir['./spec/support/shared_examples/**/*.rb'].sort.each { |f| require f}

RSpec.configure do |config|

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end
