#!/usr/bin/env bash
set -euo pipefail

# Update flake.lock and keep vendor/nixpkgs aligned to the same nixpkgs revision.
#
# Usage:
#   ./scripts/update-nixpkgs.sh                # update only nixpkgs input (recommended)
#   ./scripts/update-nixpkgs.sh --all          # update all flake inputs
#   ./scripts/update-nixpkgs.sh --commit       # also create a git commit
#   ./scripts/update-nixpkgs.sh --all --commit
#
# Assumptions:
# - Run from inside the repo (e.g. ~/nixos-config)
# - flake.lock contains node "nixpkgs"
# - vendor/nixpkgs is either a git clone or a git submodule
#
# Requirements:
# - nix
# - jq
# - git

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENDOR_NIXPKGS="${ROOT_DIR}/vendor/nixpkgs"
LOCK_FILE="${ROOT_DIR}/flake.lock"

UPDATE_ALL=false
DO_COMMIT=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all) UPDATE_ALL=true; shift ;;
    --commit) DO_COMMIT=true; shift ;;
    -h|--help)
      sed -n '1,60p' "$0"
      exit 0
      ;;
    *)
      echo "Unknown arg: $1"
      exit 2
      ;;
  esac
done

cd "$ROOT_DIR"

if [[ ! -f "$LOCK_FILE" ]]; then
  echo "ERROR: flake.lock not found at: $LOCK_FILE"
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required (used to read nixpkgs rev from flake.lock)."
  echo "Install it e.g.: nix shell nixpkgs#jq"
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "ERROR: git is required."
  exit 1
fi

if ! command -v nix >/dev/null 2>&1; then
  echo "ERROR: nix is required."
  exit 1
fi

echo "==> Repo: $ROOT_DIR"

# Ensure vendor/nixpkgs exists (clone if missing)
if [[ ! -d "$VENDOR_NIXPKGS/.git" ]]; then
  if [[ -d "$VENDOR_NIXPKGS" ]]; then
    echo "ERROR: $VENDOR_NIXPKGS exists but is not a git repo (.git missing)."
    echo "Either remove it or initialize it as a git clone/submodule."
    exit 1
  fi
  echo "==> vendor/nixpkgs not present. Cloning..."
  mkdir -p "$(dirname "$VENDOR_NIXPKGS")"
  git clone https://github.com/NixOS/nixpkgs "$VENDOR_NIXPKGS"
fi

# If it's a submodule, make sure it's initialized
if git -C "$ROOT_DIR" submodule status -- "$VENDOR_NIXPKGS" >/dev/null 2>&1; then
  echo "==> Detected vendor/nixpkgs as submodule. Initializing/updating..."
  git submodule update --init --recursive -- "$VENDOR_NIXPKGS"
fi

OLD_REV="$(jq -r '.nodes.nixpkgs.locked.rev // empty' "$LOCK_FILE")"
if [[ -z "$OLD_REV" ]]; then
  echo "ERROR: Could not read .nodes.nixpkgs.locked.rev from flake.lock"
  exit 1
fi
echo "==> Current flake.lock nixpkgs rev: $OLD_REV"

# Backup lock for safety (small, cheap)
cp -a "$LOCK_FILE" "${LOCK_FILE}.bak.$(date +%Y%m%d-%H%M%S)"

echo "==> Updating flake.lock..."
if [[ "$UPDATE_ALL" == "true" ]]; then
  nix flake update
else
  nix flake lock --update-input nixpkgs
fi

NEW_REV="$(jq -r '.nodes.nixpkgs.locked.rev // empty' "$LOCK_FILE")"
if [[ -z "$NEW_REV" ]]; then
  echo "ERROR: Could not read updated .nodes.nixpkgs.locked.rev from flake.lock"
  exit 1
fi
echo "==> Updated flake.lock nixpkgs rev: $NEW_REV"

if [[ "$NEW_REV" == "$OLD_REV" ]]; then
  echo "==> nixpkgs rev unchanged (already up-to-date)."
else
  echo "==> Aligning vendor/nixpkgs to: $NEW_REV"
fi

# Align vendor/nixpkgs to the exact revision pinned in flake.lock
echo "==> Fetching vendor/nixpkgs..."
git -C "$VENDOR_NIXPKGS" fetch --all --tags

# Verify commit exists (fetch should have brought it)
if ! git -C "$VENDOR_NIXPKGS" cat-file -e "${NEW_REV}^{commit}" 2>/dev/null; then
  echo "ERROR: Commit $NEW_REV not found in vendor/nixpkgs even after fetch."
  echo "Try again, or check network/connectivity."
  exit 1
fi

# Checkout detached HEAD at that commit (exact alignment)
git -C "$VENDOR_NIXPKGS" checkout --detach "$NEW_REV" >/dev/null

ACTUAL_VENDOR_REV="$(git -C "$VENDOR_NIXPKGS" rev-parse HEAD)"
echo "==> vendor/nixpkgs HEAD: $ACTUAL_VENDOR_REV"

if [[ "$ACTUAL_VENDOR_REV" != "$NEW_REV" ]]; then
  echo "ERROR: vendor/nixpkgs not aligned (expected $NEW_REV)."
  exit 1
fi

echo "==> OK: flake.lock and vendor/nixpkgs are aligned."

# Optional git commit
if [[ "$DO_COMMIT" == "true" ]]; then
  echo "==> Committing changes..."
  git add flake.lock || true

  # If submodule, record the submodule pointer change
  if git -C "$ROOT_DIR" submodule status -- "$VENDOR_NIXPKGS" >/dev/null 2>&1; then
    git add vendor/nixpkgs
  fi

  # If it's a plain clone, we don't add vendor/nixpkgs unless you want it versioned.
  # (Usually you DON'T want to commit a full clone.)
  #
  # We will still commit flake.lock changes; and for clone case, no vendor change is staged.

  if git diff --cached --quiet; then
    echo "==> Nothing to commit."
  else
    git commit -m "Update nixpkgs and align vendor/nixpkgs to flake.lock"
    echo "==> Commit created."
  fi
fi

echo "==> Done."

