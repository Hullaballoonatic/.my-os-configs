{ inputs, ... }:

{
	imports = [
		inputs.noctalia.homeModules.default
		../../home/linux.nix
		../../home/modules/hypr/home.nix
		../../home/modules/noctalia/home.nix
	];

	_module.args = {
		inherit inputs;
	};
}

