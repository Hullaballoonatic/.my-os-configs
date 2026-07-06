{ config, ... }:

{
	imports = [
		./core.nix
	];

  home.username = "CaseyStratton";
	home.homeDirectory = "/Users/CaseyStratton";
	home.stateVersion = "26.05";

	xdg = {
		enable = true;
		configHome = "${config.home.homeDirectory}/.config";
	};
}
