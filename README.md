# Applying configurations

This repo is applied directly via Nix/nix-darwin/Home Manager per host —
there is no wrapper script.

## macOS (`macbook`)

```sh
sudo darwin-rebuild switch --flake ~/.my-os-configs/nix#macbook
```

Update dependencies first with:

```sh
nix flake update --flake ~/.my-os-configs/nix
```

## NixOS (`desktop`)

```sh
nixos-rebuild switch --flake ~/.my-os-configs/nix#desktop --sudo
```

## NixOS (`pi`)

Build/deploy from `desktop`:

```sh
nixos-rebuild switch --flake ~/.my-os-configs/nix#pi --sudo --target-host casey@pi.local
```

Or, from `pi` itself, using `desktop` as the build host:

```sh
nixos-rebuild switch --flake ~/.my-os-configs/nix#pi --sudo --build-host casey@desktop.local
```

Update dependencies first with `nix flake update --flake ~/.my-os-configs/nix`
on either host.
