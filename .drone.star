def pipeline(name, arch):
  return {
    "kind": "pipeline",
    "type": "docker",
    "name": name,
    "platform": {
      "os": "linux",
      "arch": arch,
    },
    "steps": [
      {
        "name": "test",
        "image": "ruby:2.5-stretch",
        "commands": [
          "uname -m",
          "apt-get -yq update",
          "apt-get -yq install software-properties-common",
          "apt-get -yq install bison sudo",
          # workaround ipv6 localhost
          """ruby -e "hosts = File.read('/etc/hosts').sub(/^::1\s*localhost.*$/, ''); File.write('/etc/hosts', hosts)" """,
          # create user
          "useradd --shell /bin/bash --create-home test && chown -R test:test .",
          # configure
          "/usr/bin/sudo -H -u test -- bash -c 'autoconf && ./configure --disable-install-doc --prefix=/tmp/ruby-prefix'",
          # make all install
          "/usr/bin/sudo -H -u test -- make -j$(nproc) all install",
          # make test
          "/usr/bin/sudo -H -u test -- make test",
          # make test-spec
          "/usr/bin/sudo -H -u test -- make test-spec",
          # make test-all
          "/usr/bin/sudo -H -u test -- make test-all"
        ]
      }
    ],
    "trigger": {
      "branch": [
        "master"
      ]
    }
  }

def main(ctx):
  return [
    pipeline("arm64", "arm64"),
    pipeline("arm32", "arm")
  ]
