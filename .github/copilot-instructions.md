# Copilot instructions for this repository

## Build, test, and lint commands

This repo is primarily infra/configuration, so there is no conventional unit-test suite.

- **Primary workflow entrypoint**
  - `./manage bootstrap` — install platform deps + Nix profile, then apply dotfiles
  - `./manage apply` — re-stow dotfiles into `$HOME`
  - `./manage update` — update system (`nix flake update` + rebuild on Linux, `topgrade` elsewhere)

- **NixOS host targeting (single target)**
  - `./manage bootstrap pi` (from desktop to pi path supported by `manage`)
  - `sudo nixos-rebuild switch --flake ./nix#desktop` (desktop host)
  - `sudo nixos-rebuild switch --flake ./nix#pi` (pi host)

- **Flake checks/formatting**
  - `nix flake check ./nix`
  - `nix fmt ./nix`

- **Config-specific formatting used in repo**
  - `stylua stow/common/dot-config/nvim`
  - `markdownlint-cli2 "**/*.md"`

## High-level architecture

Configuration is split into two layers:

1. **Nix layer (`nix/`)**: system/package definitions
   - `nix/flake.nix` is the composition root:
     - Declares external flake inputs
     - Defines host map (`desktop`, `pi`) and wires `nixosConfigurations`
     - Exposes package environments from `nix/packages/*.nix` via `buildEnv`
     - Exposes dev templates in `nix/templates/*`
   - `nix/hosts/<host>/configuration.nix` contains full host behavior (services, firewall, users, packages).
   - `nix/packages/core.nix` is the shared package baseline; `darwin.nix` and `linux.nix` extend it.

2. **Dotfile layer (`stow/`)**: user-level config materialized into `$HOME`
   - `stow/common` = shared dotfiles
   - `stow/linux` and `stow/darwin` = OS-specific overlays
   - `manage apply` handles symlink conflict cleanup, then runs GNU Stow with `--dotfiles --adopt`.

`manage` is the operational interface that ties both layers together (bootstrap/apply/update/rebuild behavior).

## Key conventions

- **Use `manage` rather than ad-hoc commands** for routine operations; repo docs assume this flow.
- **Dotfile naming convention**: paths under `stow/` use `dot-` prefixes (for example, `dot-config`) that are translated to hidden paths (`.config`) during apply.
- **Layering convention**: keep shared config in `stow/common`, place only deltas in `stow/linux` or `stow/darwin`.
- **Nix package composition**: add shared tools to `nix/packages/core.nix`; reserve OS-only additions for `nix/packages/linux.nix` or `nix/packages/darwin.nix`.
- **Host-specific behavior lives in host modules** (`nix/hosts/desktop/configuration.nix`, `nix/hosts/pi/configuration.nix`), not in `flake.nix`.
- **Ghostty config on macOS is bracketed** by `config.before.ghostty` and `config.after.ghostty`; keep shared settings in `stow/common/dot-config/ghostty/config.ghostty`.
- **Hyprland supports local override** via `~/.config/hypr/hyprland.local.lua`; prefer local overrides for machine-specific tweaks you do not want committed.
