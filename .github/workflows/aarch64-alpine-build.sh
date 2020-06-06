#!/bin/ash
set -e

if [ "$(id -u)" -eq 0 ]; then
  #echo "::group::Install dependencies"
  apk add build-base gc-dev llvm-dev libevent-dev pcre-dev zlib-dev libxml2-dev yaml-dev openssl-dev gmp-dev zlib-dev
  #echo "::endgroup::"

  #echo "::group::Switch to user"
  adduser -D crystal
  chown -R crystal .
  chgrp -R crystal .
  exec su crystal "$0" -- "$@"
fi

# echo "::endgroup::"

#echo "::group::Build deps"
make deps
#echo "::endgroup::"

#echo "::group::Link cross compiled compiler"
mkdir -p .build
cc crystal.o -o .build/crystal  -rdynamic src/llvm/ext/llvm_ext.o `/usr/bin/llvm-config --libs --system-libs --ldflags 2> /dev/null` -lstdc++ -lpcre -lm -lgc -lpthread src/ext/libcrystal.a -levent -lrt
#echo "::endgroup::"

#echo "::group::Rebuild Crystal"
touch src/compiler/crystal.cr
make release=1
#echo "::endgroup::"

#echo "::group::Run stdlib specs"
make std_spec verbose=1
#echo "::endgroup::"

#echo "::group::Run compiler specs"
make compiler_spec verbose=1
#echo "::endgroup::"