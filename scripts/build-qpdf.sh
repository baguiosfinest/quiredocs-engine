#!/usr/bin/env bash
# Build static libjpeg-turbo + qpdf (native crypto) for one target.
# usage: build-qpdf.sh <stage-dir> <cmake args selecting the target toolchain...>
# env:   JPEG_EXTRA  extra cmake args for libjpeg-turbo only
# Result: <stage>/lib/{libqpdf.a,libjpeg.a}, <stage>/include/qpdf/*
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
stage=$(mkdir -p "$1" && cd "$1" && pwd); shift
. "$root/pdf-deps.lock"
export CMAKE_GENERATOR=${CMAKE_GENERATOR:-Ninja}
work=$(mktemp -d); deps=$work/deps; mkdir -p "$deps"

fetch() { # url sha256 dir
  curl -fsSL "$1" -o "$work/src.tgz"
  echo "$2  $work/src.tgz" | shasum -a 256 -c -
  mkdir -p "$3" && tar xzf "$work/src.tgz" -C "$3" --strip-components=1
}

fetch "$JPEG_URL" "$JPEG_SHA256" "$work/jpeg"
cmake -S "$work/jpeg" -B "$work/jpeg-b" "$@" ${JPEG_EXTRA:-} \
  -DCMAKE_BUILD_TYPE=Release -DENABLE_SHARED=OFF -DENABLE_STATIC=ON \
  -DWITH_TURBOJPEG=OFF -DWITH_JAVA=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_INSTALL_PREFIX="$deps"
cmake --build "$work/jpeg-b" && cmake --install "$work/jpeg-b"

fetch "$QPDF_URL" "$QPDF_SHA256" "$work/qpdf"
# qpdf finds libjpeg through pkg-config; confine it to our target build so host libs are never picked up.
export PKG_CONFIG_LIBDIR="$deps/lib/pkgconfig" PKG_CONFIG_PATH=
cmake -S "$work/qpdf" -B "$work/qpdf-b" "$@" \
  -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON \
  -DUSE_IMPLICIT_CRYPTO=OFF -DREQUIRE_CRYPTO_NATIVE=ON -DSTATIC_JPEG=ON \
  -DBUILD_DOC=OFF -DINSTALL_EXAMPLES=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DCMAKE_FIND_ROOT_PATH="$deps"
cmake --build "$work/qpdf-b" --target libqpdf

mkdir -p "$stage/lib" "$stage/include/qpdf"
cp "$work/qpdf-b/libqpdf/libqpdf.a" "$deps/lib/libjpeg.a" "$stage/lib/"
cp "$work"/qpdf/include/qpdf/*.h "$work"/qpdf/include/qpdf/*.hh "$work/qpdf-b/libqpdf/qpdf/qpdf-config.h" "$stage/include/qpdf/"
mkdir -p "$stage/licenses/qpdf" "$stage/licenses/libjpeg-turbo"
cp "$work"/qpdf/LICENSE.txt "$work"/qpdf/NOTICE* "$stage/licenses/qpdf/"
cp "$work"/jpeg/LICENSE.md "$work"/jpeg/README.ijg "$stage/licenses/libjpeg-turbo/"
rm -rf "$work"
