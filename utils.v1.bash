# Not an executable. Can be sourced by other scripts in this repo for some free
# error checking for common operations. Uses bash-specific features including
# `local`.

# see bash(1)
function set_strict_mode {
  set -euxo pipefail
}

# Display a message to stderr.
function warn {
  echo >&2 "$@"
}

# Display a message to stderr, then exit with failure.
function die {
  warn "$@"
  exit 1
}

# Display a message read from stdin to stderr, then exit with failure. This can
# be used with heredocs (<<EOF and friends).
function die_here {
  cat >&2
  exit 1
}

# Check for the existence of a command, and fail if it's not there. If a command
# has variations in functionality between Linux and OSX, additional checks may
# be required.
function check_cmd_or_err {
  local -r cmd_name="$1"
  if ! hash "$cmd_name"; then
    die_here <<EOF
The command '${cmd_name}' is required to run this script. You may have to
install it using your operating system's package manager.
EOF
  fi
}

# Verify that a path exists, and echo the absolute path (not canonical or
# normalized!).
function get_existing_absolute_path {
  local -r path_arg="$1"
  # -f is an "illegal option" for OSX readlink, so this may have e.g. `/../`
  # within it.
  local -r abs_path="$(pwd)/${path_arg}"

  if [[ ! -e "$abs_path" ]]; then
    die "File at path '${path_arg}' (relative to pwd '$(pwd)') was expected to exist, but does not."
  fi

  echo "$abs_path"
}

# Download a file from a given URL, with verbose output, and exiting with
# failure on server errors. --fail should probably be on by default, so probably
# keep that if you add any other curl wrappers.
function curl_file_with_fail {
  local -r url="$1" expected_outfile="$2"
  curl >&2 -L --fail -O "$url"
  get_existing_absolute_path "$expected_outfile"
}

# Make a new directory (that may already exist) and echo the absolute path.
function mkdirp_absolute_path {
  local -r dir_relpath="$1"
  mkdir -p "$dir_relpath"
  get_existing_absolute_path "$dir_relpath"
}

# TODO: note that expected_output can be any of the extracted entries in the
# archive, not just a "root dir" or whatever
function do_extract {
  local -r archive_path="$1"

  case "$archive_path" in
    *.tar.xz)
      check_cmd_or_err 'xz'
      tar xf "$archive_path"
      ;;
    *.tar.gz)
      tar zxf "$archive_path"
      ;;
    *.tgz)
      tar zxf "$archive_path"
      ;;
    *)
      die "Unrecognized file extension for compressed archive at '${archive_path}'."
      ;;
  esac
}

function extract_for {
  local -r archive_path="$1"
  local -a result_path_candidates=("${@:2}")

  do_extract "$archive_path"

  for result_path in "${result_path_candidates[@]}"; do
    if [[ -e "$result_path" ]]; then
      get_existing_absolute_path "$result_path"
      return 0
    else
      warn "note: candidate '${result_path}' was not found"
    fi
  done

  die "Could not locate the result of extracting '${archive_path}'."
}

function create_gz_package {
  local -r pkg_name="$1"
  local -a from_paths=("${@:2}")

  local -r pkg_archive_name="${pkg_name}.tar.gz"

  rm -f "$pkg_archive_name"

  if [[ "${#from_paths[@]}" -eq 0 ]]; then
    tar -czf "$pkg_archive_name" *
  else
    tar -czf "$pkg_archive_name" "${from_paths[@]}"
  fi

  get_existing_absolute_path "$pkg_archive_name"
}

function with_pushd {
  local -r dest="$1"
  local -a cmd_line=("${@:2}")

  pushd >&2 "$dest"
  "${cmd_line[@]}"
  popd >&2
}
