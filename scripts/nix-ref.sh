#!/usr/bin/env bash
set -euo pipefail

cmd="${1:-}"
shift || true

case "$cmd" in
  option)
    # Usage: ./scripts/nix-ref.sh option services.openssh.enable
    nixos-option "$@"
    ;;
  search)
    # Usage: ./scripts/nix-ref.sh search firefox
    nix search nixpkgs "$@"
    ;;
  meta)
    # Usage: ./scripts/nix-ref.sh meta firefox
    nix eval "nixpkgs#${1}.meta" --json | sed 's/\\u001b\[[0-9;]*m//g' || true
    ;;
  help)
    echo "Usage:"
    echo "  $0 option <option.path>"
    echo "  $0 search <term>"
    echo "  $0 meta <pkg>"
    ;;
  *)
    echo "Unknown command: $cmd"
    "$0" help
    exit 2
    ;;
esac
