#!/bin/sh

set -e

RBS_TEST_LOGLEVEL=error \
  RBS_TEST_TARGET='GDAL::*' \
  RBS_TEST_OPT='-rdate -I sig' \
  RBS_TEST_RAISE=true \
  RUBYOPT='-rbundler/setup -rrbs/test/setup' \
  bundle exec rspec spec/unit/gdal
