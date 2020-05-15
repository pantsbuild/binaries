#!/bin/bash

source "$(git rev-parse --show-toplevel)/utils.v1.bash"

set_strict_mode

RUSTUP_URL='https://sh.rustup.rs'
CACHE_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}/pants"
RUST_COMPONENTS=(
  "rustfmt-preview"
  "rust-src"
  "clippy-preview"
)
rust_toolchain_root="${CACHE_ROOT}/rust"
export CARGO_HOME="${rust_toolchain_root}/cargo"
export RUSTUP_HOME="${rust_toolchain_root}/rustup"
RUSTUP="${CARGO_HOME}/bin/rustup"

function rustup_init {
  curl --fail "$RUSTUP_URL" -sS \
    | sh -s -- -y --no-modify-path --default-toolchain none \
         >&2
}

function install_toolchain {
  local -r toolchain="$1"
  "$RUSTUP" self update
  "$RUSTUP" toolchain install "$toolchain"
  "$RUSTUP" component add --toolchain "$toolchain" "${RUST_COMPONENTS[@]}" \
            >&2
  "$RUSTUP" default "$toolchain"
}

function install_cargo_ensure_installed {
  local -r package_version="$1"
  local -r cargo="${CARGO_HOME}/bin/cargo"
  "${cargo}" install cargo-ensure-installed
  "${cargo}" ensure-installed --package cargo-ensure-installed --version "$package_version"
}

function create_package {
  with_pushd "$rust_toolchain_root" \
             create_gz_package 'cargo'
}

## Interpret arguments and execute build.

readonly TOOLCHAIN_VERSION="$1"
readonly CARGO_ENSURE_INSTALLED_VERSION="$2"

rustup_init >&2

install_toolchain "$TOOLCHAIN_VERSION" >&2

install_cargo_ensure_installed "$CARGO_ENSURE_INSTALLED_VERSION" >&2

create_package
