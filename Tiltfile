# ╭─────────────────────────────────────────────────────────╮
# │ Enforce a minimum Tilt version, so labels are supported │
# │ https://docs.tilt.dev/api.html#api.version_settings     │
# ╰─────────────────────────────────────────────────────────╯
version_settings(constraint='>=0.22.1')

docker_build(
  "ffi-gdal_gdal2",
  context='.',
  dockerfile='./Dockerfile.gdal2',
  build_args={"GDAL_VERSION": "2.4.4"},
  ignore=[
    "tmp/*",
    "coverage/",
    "spec/examples.txt",
    "Gemfile.lock"
  ],
  live_update=[
    sync('.', '/usr/src/ffi-gdal'),
    run('bundle install', trigger='ffi-gdal.gemspec'), restart_container()
  ]
)

docker_build(
  "ffi-gdal_gdal3",
  context='.',
  dockerfile='./Dockerfile.gdal3',
  ignore=[
    "tmp/*",
    "coverage/",
    "spec/examples.txt",
    "Gemfile.lock"
  ],
  live_update=[
    sync('.', '/usr/src/ffi-gdal'),
    run('bundle install', trigger='ffi-gdal.gemspec'), restart_container()
  ]
)

# ╓────────────╖
# ║ UI Buttons ║
# ╙────────────╜
load('ext://uibutton', 'cmd_button')

# ╭──────────────────────────────────────────────────────╮
# │ Make the same buttons for gdal2 and gdal3 containers │
# ╰──────────────────────────────────────────────────────╯
for gdal_version in ['gdal2', 'gdal3']:
  cmd_button(gdal_version + ":bundle install",
             argv=['docker', 'compose', 'run', gdal_version, 'bin/bundle', 'install'],
             resource=gdal_version,
             icon_name='install_desktop',
             text='bundle install'
             )
  cmd_button(gdal_version + ":bundle update",
             argv=['docker', 'compose', 'run', gdal_version, 'bin/bundle', 'update'],
             resource=gdal_version,
             icon_name='refresh',
             text='bundle update'
             )
  cmd_button(gdal_version + ":rake spec",
             argv=['docker', 'compose', 'run', gdal_version, 'bin/rake', 'spec'],
             resource=gdal_version,
             icon_name='bolt',
             text='rake spec'
             )
  cmd_button(gdal_version + ":rubocop",
             argv=['docker', 'compose', 'run', gdal_version, 'bin/rubocop'],
             resource=gdal_version,
             icon_name='search_check',
             text='rubocop'
             )
  cmd_button(gdal_version + ":rubocop fix (safe)",
             argv=['docker', 'compose', 'run', gdal_version, 'bin/rubocop', '-a'],
             resource=gdal_version,
             icon_name='done_outline',
             text='rubocop -a'
             )
  cmd_button(gdal_version + ":rubocop fix (all)",
             argv=['docker', 'compose', 'run', gdal_version, 'bin/rubocop', '-A'],
             resource=gdal_version,
             icon_name='done_all',
             text='rubocop -A'
             )

docker_compose("docker-compose.yml")

dc_resource('gdal2')
dc_resource('gdal3')

# vim:ft=Tiltfile syntax=python
