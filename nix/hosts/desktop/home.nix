{ inputs, ... }:

{
	imports = [
		../../home/casey.nix
	];

	_module.args = {
		inherit inputs;
	};
}

