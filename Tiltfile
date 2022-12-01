# ╭─────────────────────────────────────────────────────────╮
# │ Enforce a minimum Tilt version, so labels are supported │
# │ https://docs.tilt.dev/api.html#api.version_settings     │
# ╰─────────────────────────────────────────────────────────╯
version_settings(constraint='>=0.22.1')

registry_name = 'ttl.sh'
registry_org_name = 'ffi-gdal-12345'

default_registry(registry_name)

def image_name(gdal_version_uuid):
  return '/'.join([registry_name, registry_org_name, gdal_version_uuid])

gdal2_image_uuid = '5d7df36c-2e4d-42dd-a744-fc5959dffb7f'

docker_build(
  image_name(gdal2_image_uuid),
  context='.',
  dockerfile='./Dockerfile.gdal2',
  build_args={"GDAL_VERSION": "2.4.4"},
  ignore=[
    "tmp/*",
    "coverage/",
    "spec/examples.txt",
    "Gemfile.lock"
  ]
)

gdal3_image_uuid = 'ff64f94d-84fb-4762-a1f2-ce223da180b1'

docker_build(
  image_name(gdal3_image_uuid),
  context='.',
  dockerfile='./Dockerfile.gdal3',
  ignore=[
    "tmp/*",
    "coverage/",
    "spec/examples.txt",
    "Gemfile.lock"
  ]
)

docker_prune_settings(num_builds = 5)

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
  cmd_button(gdal_version + ":rake spec",
             argv=['docker', 'compose', 'run', gdal_version, 'bin/rake', 'spec'],
             resource=gdal_version,
             icon_name='bolt',
             text='rake spec'
  )

k8s_yaml('tilt/gdal2.yml')
k8s_yaml('tilt/gdal3.yml')
k8s_resource('gdal2')
k8s_resource('gdal3')

# vim:syntax=python
