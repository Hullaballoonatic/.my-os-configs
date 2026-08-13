{ inputs, ... }:

{
	imports = [
		inputs.nixvim.homeModules.nixvim

		./core.nix
		./modules/nixvim/home.nix
		./modules/obsidian/home.nix
	];

  home.username = "CaseyStratton";
	home.homeDirectory = "/Users/CaseyStratton";
	home.stateVersion = "26.05";
}
