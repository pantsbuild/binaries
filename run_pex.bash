CACHE_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}/pantsbuild-binaries"

PEX_VERSION="1.4.4"

function run_pex() {
  local -r pex="${CACHE_ROOT}/pex/${PEX_VERSION}/pex.pex"
  if [[ ! -x "${pex}" ]]; then
    mkdir -p "$(dirname "${pex}")"
    curl -L https://github.com/pantsbuild/pex/releases/download/v${PEX_VERSION}/pex27 > "${pex}"
    chmod +x "${pex}"
  fi
  "${pex}" "$@"
}

