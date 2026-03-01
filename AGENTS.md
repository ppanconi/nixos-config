# AGENTS.md — NixOS configuration assistant

## What this repo is
NixOS config using flakes.
Edit `configuration.nix` and `flake.nix`. Avoid generated/backup files.

## Do NOT touch
- `hardware-configuration.nix` unless explicitly asked
- `configuration.nix.backup*` never

## Always read first
- `flake.nix`
- `configuration.nix`
- `docs/*`

## Workflow
When proposing changes:
1) Explain briefly what will change and why.
2) Provide a minimal diff/patch.
3) Provide verification commands **before** switch:
   - `nix flake check`

## Documentation strategy
When suggesting configuration changes:

1. First try local tools
   scripts/nix-ref.sh option <option.path>
   scripts/nix-ref.sh search <package>

2. If needed consult:
   docs/*
   https://search.nixos.org/options
   https://search.nixos.org/packages
   https://wiki.nixos.org

3. If present read source code:
   vendor/nixpkgs

## Quality bar
- keep diffs small and incremental
- don’t introduce new modules/structure unless needed
- add rollback tips for risky changes

## Verify options exist

Before proposing a configuration option verify it exists using:

scripts/nix-ref.sh option <option.path>

## Local reference tools

Use the helper script in this repository to query NixOS information.

scripts/nix-ref.sh

Examples:

Get NixOS option documentation
scripts/nix-ref.sh option services.openssh.enable

Search packages
scripts/nix-ref.sh search firefox

Inspect package metadata
scripts/nix-ref.sh meta firefox

Always prefer this script instead of calling nixos-option or nix search directly.
