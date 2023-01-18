# frozen_string_literal: true

namespace :docker do
  namespace :gdal2 do
    desc "Run specs in the gdal2 docker container"
    task :spec do
      sh "docker-compose run --rm gdal2 bundle exec rake spec"
    end
  end
end
