{ inputs, ... }:

{
	imports = [
  	./modules/tmux.nix
	];

	_module.args = {
		inherit inputs;
	};
}

