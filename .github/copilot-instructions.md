# Copilot instructions for this repository

## Build, test, and lint commands

There is no wrapper script (the former `manage` script has been retired —
everything is applied directly via Nix/nix-darwin/Home Manager per host).

- macOS (`macbook`): `sudo darwin-rebuild switch --flake ./nix#macbook`
- NixOS (`desktop`): `nixos-rebuild switch --flake ./nix#desktop --sudo`
- NixOS (`pi`), from `desktop`: `nixos-rebuild switch --flake ./nix#pi --sudo --target-host casey@pi.local`
- NixOS (`pi`), from `pi` itself: `nixos-rebuild switch --flake ./nix#pi --sudo --build-host casey@desktop.local`
- Update dependencies on any host: `nix flake update --flake ./nix`

Automated tests and lint-only pipelines are not defined in this repo. There is no single-test command available today.

## High-level architecture

This repo is a Nix flake-driven dotfiles/system config monorepo with two composition layers:

1. `nix/flake.nix`: declares inputs and builds outputs:
   - `nixosConfigurations` for `desktop` and `pi`
   - `darwinConfigurations.macbook` for the macOS host (nix-darwin + Home Manager + nix-homebrew)
   - shared package/template outputs
2. Nix modules and host composition:
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
- Apply configuration directly via `darwin-rebuild`/`nixos-rebuild` per host (see commands above) rather than introducing ad-hoc apply/update scripts.
