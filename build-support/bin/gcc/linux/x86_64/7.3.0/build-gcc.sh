#!/bin/bash

source "$(git rev-parse --show-toplevel)/utils.v1.bash"

set_strict_mode

function fetch_extract_gcc_source_release {
  local -r extracted_dirname="gcc-${GCC_VERSION}"
  local -r archive_filename="${extracted_dirname}.tar.gz"
  local -r release_url="https://ftpmirror.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/${archive_filename}"

  local -r downloaded_archive="$(curl_file_with_fail "$release_url" "$archive_filename")"
  extract_for "$downloaded_archive" "$extracted_dirname"
}

function build_gcc_with_configure {
  local -a configure_cmd_line=("$@")

  "${configure_cmd_line[@]}"

  make "-j${MAKE_JOBS}"

  make install
}

function build_gcc_out_of_tree {
  local -a configure_args=("$@")

  local -r source_extracted_abs="$(fetch_extract_gcc_source_release)"

  # This script is a great tool, it saves a ton of time downloading and
  # configuring gmp, mpc, isl, and mpfr per-platform.
  check_cmd_or_err 'wget'
  # Redirect to stderr because we "return" a path to our .tar.gz by stdout.
  with_pushd >&2 "$source_extracted_abs" \
                 ./contrib/download_prerequisites

  local -r build_dir_abs="$(mkdirp_absolute_path 'gcc-build')"
  local -r install_dir_abs="$(mkdirp_absolute_path 'gcc-install')"

  with_pushd >&2 "$build_dir_abs" \
             build_gcc_with_configure  \
             "${source_extracted_abs}/configure" \
             --prefix="$install_dir_abs" \
             "${configure_args[@]}"

  with_pushd "$install_dir_abs" \
             create_gz_package 'gcc'
}

function build_osx {
  local -r release_numeric="$1"
  local -r target_desc="x86_64-apple-darwin${release_numeric}"
  build_gcc_out_of_tree \
    --host="$target_desc" \
    --target="$target_desc" \
    "${CONFIGURE_BASE_ARGS[@]}"
}

function build_linux {
  build_gcc_out_of_tree \
    "${CONFIGURE_BASE_ARGS[@]}"
}

## Interpret arguments and execute build.

readonly TARGET_PLATFORM="$1" GCC_VERSION="$2"

readonly SUPPORTED_LANGS='c,c++'

readonly -a CONFIGURE_BASE_ARGS=(
  --disable-multilib
  --without-gstabs
  --enable-languages="${SUPPORTED_LANGS}"
  --with-pkgversion="pants-packaged"
  --with-bugurl='https://github.com/pantsbuild/pants/issues'
)

case "$TARGET_PLATFORM" in
  osx)
    if [[ "$(uname)" != 'Darwin' ]]; then
      die "This script only supports building gcc for OSX within an OSX environment."
    fi
    # Since we can't do this in a VM, ensure we're (probably) using the tools
    # provided by Apple -- accidentally using e.g. homebrew tools instead will
    # cause weird errors.
    export PATH="/bin:/usr/bin:${PATH}"
    # There are race conditions with parallel make, or at least, I have found
    # weird errors occur whenever I try to use make with parallelism. This might
    # be worth investigating at some point. This may be related to this comment
    # on the homebrew formula for gcc 7.3.0: https://github.com/Homebrew/homebrew-core/blob/a58c7b32c9ab679bc5f1afecc45f315710676ba1/Formula/gcc.rb#L56
    readonly MAKE_JOBS=1
    # I haven't been able to get this to build without appending $(uname -r) to
    # the --host and --target specs -- this is again what is done in homebrew. I
    # don't know if this will cause subtle or non-subtle incompatibilities with
    # earlier versions of OSX. Tested on High Sierra, where
    # $(uname -r)=='17.4.0'
    with_pushd "$(mkdirp_absolute_path "gcc-${GCC_VERSION}-osx")" \
               build_osx "$(uname -r)"
    ;;
  linux)
    # Default to 2 parallel jobs if unspecified.
    readonly MAKE_JOBS="${MAKE_JOBS:-2}"
    with_pushd "$(mkdirp_absolute_path "gcc-${GCC_VERSION}-linux")" \
               build_linux
    ;;
  *)
    die "gcc does not support building for '${TARGET_PLATFORM}'"
    ;;
esac
