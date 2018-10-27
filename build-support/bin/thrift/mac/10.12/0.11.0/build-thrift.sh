#!/bin/bash

source "$(git rev-parse --show-toplevel)/utils.v1.bash"

set_strict_mode

function build_bison {
  local -r extracted_dirname="bison-${BISON_VERSION}"
  local -r archive_filename="${extracted_dirname}.tar.gz"
  local -r release_url="http://ftp.gnu.org/gnu/bison/${archive_filename}"

  local -r downloaded_archive="$(curl_file_with_fail "$release_url" "$archive_filename")"
  local -r source_extracted_abs="$(extract_for "$downloaded_archive" "$extracted_dirname")"

  with_pushd >&2 "$source_extracted_abs" sh ./configure --prefix="$source_extracted_abs/$INSTALL_PREFIX"
  with_pushd >&2 "$source_extracted_abs" make install

  export PATH="$source_extracted_abs/$INSTALL_PREFIX/bin:$PATH"
}

function build_byacc {
  local -r extracted_dirname="byacc-${BYACC_VERSION}"
  local -r archive_filename="${extracted_dirname}.tgz"
  local -r release_url="https://www.mirrorservice.org/sites/lynx.invisible-island.net/byacc/${archive_filename}"

  local -r downloaded_archive="$(curl_file_with_fail "$release_url" "$archive_filename")"
  local -r source_extracted_abs="$(extract_for "$downloaded_archive" "$extracted_dirname")"

  with_pushd >&2 "$source_extracted_abs" sh ./configure --prefix="$source_extracted_abs/$INSTALL_PREFIX"
  with_pushd >&2 "$source_extracted_abs" make install

  export PATH="$source_extracted_abs/$INSTALL_PREFIX/bin:$PATH"
}

function build_thrift {
  local -r extracted_dirname="thrift-${THRIFT_VERSION}"
  local -r archive_filename="${extracted_dirname}.tar.gz"
  local -r release_url="http://archive.apache.org/dist/thrift/${THRIFT_VERSION}/${archive_filename}"

  local -r downloaded_archive="$(curl_file_with_fail "$release_url" "$archive_filename")"
  local -r source_extracted_abs="$(extract_for "$downloaded_archive" "$extracted_dirname")"

  # NB: The configure --without-* flags just disable building any runtime libs
  # for the generated code.  We only want the codegen side of things.
  with_pushd >&2 "$source_extracted_abs" \
    sh ./configure \
      --disable-shared \
      --without-cpp \
      --without-c_glib \
      --without-csharp \
      --without-erlang \
      --without-java \
      --without-erlang \
      --without-lua \
      --without-python \
      --without-perl \
      --without-php \
      --without-php_extension \
      --without-qt4 \
      --without-qt5 \
      --without-dart \
      --without-ruby \
      --without-haskell \
      --without-go \
      --without-nodejs \
      --without-rs \
      --without-haxe \
      --without-dotnetcore \
      --without-d
  with_pushd >&2 "$source_extracted_abs" make clean
  with_pushd >&2 "$source_extracted_abs" make LDFLAGS="-all-static"

  echo "$source_extracted_abs/compiler/cpp/thrift"
}

## Interpret arguments and execute build.

readonly THRIFT_VERSION="$1"
readonly BISON_VERSION="$2"
readonly BYACC_VERSION="$3"
readonly INSTALL_PREFIX=install_dir

case "$(uname)" in
  Darwin)
    with_pushd "$(mkdirp_absolute_path "bison-${BISON_VERSION}-osx")" build_bison
    with_pushd "$(mkdirp_absolute_path "byacc-${BYACC_VERSION}-osx")" build_byacc
    with_pushd "$(mkdirp_absolute_path "thrift-${THRIFT_VERSION}-osx")" build_thrift
    ;;
  Linux)
    with_pushd "$(mkdirp_absolute_path "bison-${BISON_VERSION}-linux")" build_bison
    with_pushd "$(mkdirp_absolute_path "byacc-${BYACC_VERSION}-linux")" build_byacc
    with_pushd "$(mkdirp_absolute_path "thrift-${THRIFT_VERSION}-linux")" build_thrift
    ;;
  *)
    die "make does not support building for '$(uname)'"
    ;;
esac
