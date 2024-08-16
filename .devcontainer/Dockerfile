FROM mcr.microsoft.com/devcontainers/ruby:1-3.3-bookworm

RUN ( \
  export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get -y install --no-install-recommends \
        libgdal-dev \
        librttopo-dev \
  )
