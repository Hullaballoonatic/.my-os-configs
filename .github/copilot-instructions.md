# Copilot instructions for this repository

## Build, test, and lint commands

Use the repo `manage` script as the primary entrypoint.

- `./manage` or `./manage upgrade` — full update + apply flow (default command).
- `./manage build` — apply configuration for the current OS:
  - macOS: runs Homebrew update/cask install and Home Manager switch for `nix#CaseyStratton`
  - Linux: runs `nixos-rebuild switch --flake ./nix#<target-host>` using host-aware routing logic in `manage`
- `./manage update` — updates dependencies (`nix flake update --flake ./nix` on Linux, `topgrade` on macOS).

Automated tests and lint-only pipelines are not defined in this repo. There is no single-test command available today.

## High-level architecture

This repo is a Nix flake-driven dotfiles/system config monorepo with one orchestration script (`manage`) and three composition layers:

1. `manage` (repo root): operational entrypoint for update/apply flows and cross-host deployment behavior.
2. `nix/flake.nix`: declares inputs and builds outputs:
   - `nixosConfigurations` for `desktop` and `pi`
   - `homeConfigurations."CaseyStratton"` for macOS Home Manager
   - shared package/template outputs
3. Nix modules and host composition:
   - `nix/hosts/<host>/configuration.nix`: system-level NixOS config per host
   - `nix/hosts/<host>/home.nix`: host-specific Home Manager imports
   - `nix/home/core.nix`: shared user tooling baseline (CLI tools + common modules)
   - `nix/home/linux.nix` and `nix/home/darwin.nix`: OS overlays on top of `core.nix`
   - `nix/home/modules/*/home.nix`: feature/tool modules (nixvim, git, hypr, stylix, etc.)
   - `nix/modules/nix.nix`: shared Nix cache/substituter settings used by hosts

## Key conventions

- Prefer module composition over large inline edits: add/adjust behavior in `nix/home/modules/<name>/home.nix` (or `nix/modules/*.nix`) and wire imports in OS/host files.
- Keep host concerns separated:
  - host-specific system settings live in `nix/hosts/<host>/configuration.nix`
  - user-space app/tooling mostly lives in shared home modules plus `nix/hosts/<host>/home.nix` overrides
- Preserve existing username/hostname conventions passed via flake `specialArgs`/`extraSpecialArgs` (`casey` on Linux hosts, `CaseyStratton` on macOS home config).
- Use `manage` flows instead of introducing ad-hoc apply/update scripts; it already handles OS branching, remote rebuild paths, and Home Manager fallback behavior.
