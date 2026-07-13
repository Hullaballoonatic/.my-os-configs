# Using manage

`manage` is a script for bootstrapping, applying, and updating the configurations

`manage` with no arguments performs `manage upgrade`

`manage upgrade`</br>
  ├── performs update</br>
  └── performs bootstrap

`manage update`</br>
  └── nix flake update

`manage bootstrap`</br>
  ├── install platform packages</br>
  ├── install/update Nix</br>
  ├── install Nix profile</br>
  └── apply configurations
