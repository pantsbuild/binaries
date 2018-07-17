CACHE_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}/pantsbuild-binaries"

VIRTUALENV_VERSION="16.0.0"

function ensure_venv_installed() {
  local -r version="${VIRTUALENV_VERSION}"

  local -r venv_cache_dir="${CACHE_ROOT}/virtualenv"
  local -r venv_dir="${venv_cache_dir}/virtualenv-${version}"
  if [[ ! -d "${venv_dir}" ]]; then
    (
      mkdir -p "${venv_cache_dir}"
      cd "${venv_cache_dir}"
      curl -LO https://pypi.python.org/packages/source/v/virtualenv/virtualenv-${version}.tar.gz >&2
      tar -xvzf "virtualenv-${version}.tar.gz" >&2
    )
  fi
  echo "${venv_dir}"
}

function activate_venv() {
  local -r dir="$1"

  local -r activate="${dir}/bin/activate"
  if [[ ! -f "${activate}" ]]; then
    mkdir -p "$(dirname "${dir}")"
    (
      cd "$(ensure_venv_installed)"
      python2.7 virtualenv.py "${dir}"
    )
  fi 
  source "${activate}"
}

PEX_VERSION="1.4.4"

function run_pex() {
  local -r version="${PEX_VERSION}"

  local -r pex_dir="${CACHE_ROOT}/pex/${version}"
  activate_venv "${pex_dir}"
  if [[ ! -x "${pex_dir}/bin/pex" ]]; then
    pip install "pex==${version}" requests
  fi
  pex "$@"
}

