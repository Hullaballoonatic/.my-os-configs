
# Using manage

`manage` is a script for bootstrapping, applying, and updating the configurations

`manage` with no arguments performs `manage upgrade`

`manage upgrade`
  ├── performs update
  └── performs bootstrap

`manage update`
  └── nix flake update

`manage bootstrap`
  ├── install platform packages
  ├── install/update Nix
  ├── install Nix profile
  └── apply configurations
