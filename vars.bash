# Not an executable. Describes some common configuration for the targets we
# build for, and some useful common environment variables.

readonly BUILD_SUPPORT_BINARIES_DIR='build-support/bin'

readonly LINUX_SUPPORTED_ARCHS=(
  x86_64
)

readonly OSX_SUPPORTED_VERSIONS=(
  10.7
  10.8
  10.9
  10.10
  10.11
  10.12
  10.13
)

function get_create_linux_supportdirs_stdout {
  local -r pkg_name="$1" pkg_ver="$2"
  for linux_arch in "${LINUX_SUPPORTED_ARCHS[@]}"; do
    local -r linux_arch_dir="${BUILD_SUPPORT_BINARIES_DIR}/${pkg_name}/linux/${linux_arch}/${pkg_ver}"
    echo "$linux_arch_dir"
  done
}

function get_create_osx_supportdirs_stdout {
  local -r pkg_name="$1" pkg_ver="$2"
  for osx_ver in "${OSX_SUPPORTED_VERSIONS[@]}"; do
    echo "${BUILD_SUPPORT_BINARIES_DIR}/${pkg_name}/mac/${osx_ver}/${pkg_ver}"
  done
}
