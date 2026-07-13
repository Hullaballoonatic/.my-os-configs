{ inputs, ... }:

{
	imports = [
		inputs.nixvim.homeModules.nixvim

		./core.nix
		./modules/udiskie/home.nix
		./modules/ghostty/home.nix
		./modules/nixvim/home.nix
	];

  home.username = "casey";
	home.homeDirectory = "/home/casey";
	home.stateVersion = "26.05";
}

