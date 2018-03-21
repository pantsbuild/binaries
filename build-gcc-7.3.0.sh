#!/bin/bash

set -euxo pipefail

# Our directory and file names.
GCC_VERSION='7.3.0'
GCC_TMP_DIR='gcc-tmp'
GCC_BUILD_DIR='gcc-build'
GCC_INSTALL_DIR='gcc-install'
GCC_PKG_TARBALL='gcc.tar.gz'

# Configuration for this repository.
GCC_SUPPORTDIR='build-support/bin/gcc'

# Shared configuration across supported platforms.
GCC_SUPPORTED_LANGS='c,c++,objc,obj-c++,fortran'

# Name of the resulting directory when we extract the tarball.
GCC_SRC_DIRNAME="gcc-${GCC_VERSION}"
GCC_RELEASE_ARCHIVE_FILE="${GCC_SRC_DIRNAME}.tar.gz"
GCC_RELEASE_URL="https://ftpmirror.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/${GCC_RELEASE_ARCHIVE_FILE}"

CONFIGURE_BASE_ARGS=(
  --disable-multilib
  --enable-languages="${GCC_SUPPORTED_LANGS}"
  --enable-checking='release'
  --with-pkgversion="Pants-packaged GCC (${GCC_VERSION})"
  --with-bugurl='https://github.com/pantsbuild/pants/issues'
)

LINUX_SUPPORTED_ARCHS=(
  x86_64
)

OSX_SUPPORTED_VERSIONS=(
  10.7
  10.8
  10.9
  10.10
  10.11
  10.12
  10.13
)

# Default to -j2
MAKE_JOBS="${MAKE_JOBS:-2}"

## Set any computed and/or platform-specific variables.

configure_args_for_current_platform=("${CONFIGURE_BASE_ARGS[@]}")

build_support_directories_for_current_platform=()

_host_uname="$(uname)"

function die {
  echo >&2 "$@"
  exit 1
}

case "$_host_uname" in
  Darwin)
    # Parallel builds fail on High Sierra. Homebrew has a patch for it:
    # https://github.com/Homebrew/homebrew-core/blob/622c201de21eb84677143822044dc8955c01dc3a/Formula/gcc.rb#L56
    # but I haven't reviewed that patch or the corresponding gcc bug:
    # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=81797
    # enough to blindly use the Homebrew patch.
    MAKE_JOBS=1

    unset LD
    unset LDSHARED
    PATH='/usr/bin:/bin'

    _osx_uname_release="$(uname -r)"
    configure_args_for_current_platform+=(
      --build="x86_64-apple-darwin${_osx_uname_release}"
      --host="x86_64-apple-darwin${_osx_uname_release}"
      --target="x86_64-apple-darwin${_osx_uname_release}"
      --with-system-zlib
    )

    for ver in "${OSX_SUPPORTED_VERSIONS[@]}"; do
      build_support_directories_for_current_platform+=(
        "${GCC_SUPPORTDIR}/mac/${ver}/${GCC_VERSION}"
      )
    done
    ;;
  Linux)
    for arch in "${LINUX_SUPPORTED_ARCHS}"; do
      build_support_directories_for_current_platform+=(
        "${GCC_SUPPORTDIR}/linux/${arch}/${GCC_VERSION}"
      )
    done
    ;;
  *)
    die "unsupported platform: '${_host_uname}'"
    ;;
esac


## Some functions, despite bash making it unnecessarily hard to use them.

# Check if a directory exists, and error out or return its absolute
# path. Passing -f allows testing a file as well.
function absolutely {
  local -r path_arg="$1" test_flag="${2:--d}" # default to checking if dir

  if ! test "$test_flag" "$path_arg"; then
    die "'${path_arg}' did not pass the '${test_flag}' test. Exiting."
  fi

  # -f is an "illegal option" for OSX readlink, so this
  echo "$(pwd)/${path_arg}"
}

# Make a new directory and get its absolute path in one fell swoop.
function new_dir_abs_path {
  local -r dir_relpath="$1"
  mkdir -p "$dir_relpath"
  absolutely "$dir_relpath"
}


## Download and extract the source.
# Make a temporary directory to hold our work, and move inside.
tmp_root_dir_abs="$(new_dir_abs_path "$GCC_TMP_DIR")"

pushd "$tmp_root_dir_abs"       # root -> $tmp_root_dir_abs

# Download and extract the gcc release tarball.
# FIXME: verify contents of this file somehow. there's a .sig file at the same
# location, and one of the gpg keys mentioned on
# https://gcc.gnu.org/mirrors.html can be used to perform the verification.
curl -L -v -O "$GCC_RELEASE_URL"
tar zxf "$GCC_RELEASE_ARCHIVE_FILE"
# This is the directory created by extracting the release tarball.
src_dir_abs="$(absolutely "$GCC_SRC_DIRNAME")"

# These are two new directories we just made -- gcc doesn't like "in-tree"
# builds, so we make a new directory to run make in, and then install it into
# our other new directory right beside.
build_dir_abs="$(new_dir_abs_path "$GCC_BUILD_DIR")"
install_dir_abs="$(new_dir_abs_path "$GCC_INSTALL_DIR")"

pushd "$build_dir_abs"          # $tmp_root_dir_abs -> $build_dir_abs

# The --prefix argument determines where the products of `make install` go.
"${src_dir_abs}/configure" \
  "--prefix=${install_dir_abs}" \
  "${configure_args_for_current_platform[@]}"

make "-j${MAKE_JOBS}"

# Copies some compilers, libraries, and headers over to the install directory we
# specified with --prefix.
make install

popd                            # $tmp_root_dir_abs <- $build_dir_abs

pushd "$install_dir_abs"        # $tmp_root_dir_abs -> $install_dir_abs

# Extract what we need into gcc.tar.gz.
tar czf "$GCC_PKG_TARBALL" bin include lib lib64 libexec
# This is an absolute path to the packaged archive we want to provide.
gcc_packaged_abs="$(absolutely "$GCC_PKG_TARBALL" -f)"

popd                            # $tmp_root_dir_abs <- $install_dir_abs

popd                            # root <- $tmp_root_dir_abs

# Copy over gcc.tar.gz to e.g.
# build-support/bin/gcc/linux/x86_64/7.3.0/gcc.tar.gz for Linux hosts.
for supportdir in "${build_support_directories_for_current_platform[@]}"; do
  cp "$gcc_packaged_abs" "${supportdir}/${GCC_PKG_TARBALL}"
done
