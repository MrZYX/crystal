#!/bin/ash
set -xe

cd /crystal

# Install dependencies, then switch to user
if [ "$(id -u)" -eq 0 ]; then
  apk add build-base unzip curl jq git gc-dev llvm-dev libevent-dev pcre-dev zlib-dev libxml2-dev yaml-dev openssl-dev gmp-dev zlib-dev

  adduser -D crystal
  chown -R crystal .
  chgrp -R crystal .
  exec su crystal "$0" -- "$@"
fi

# Download cross compiled compiler
archive_url="$(curl "https://api.github.com/repos/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID/artifacts" \
  -H "Authorization: token $GITHUB_TOKEN" | jq -r '.artifacts[0].archive_download_url')"
download_url=$(curl -LIs -o /dev/null -w '%{url_effective}' "$archive_url" \
  -H "Authorization: token $GITHUB_TOKEN")
curl  $download_url -o crystal.zip
unzip crystal.zip

# Link cross compiled compiler
make deps
mkdir -p .build
cc crystal.o -o .build/crystal  -rdynamic src/llvm/ext/llvm_ext.o `/usr/bin/llvm-config --libs --system-libs --ldflags 2> /dev/null` -lstdc++ -lpcre -lm -lgc -lpthread src/ext/libcrystal.a -levent -lrt

# Rebuild compiler and run specs
touch src/compiler/crystal.cr
make

make std_spec verbose=1
make compiler_spec verbose=1
