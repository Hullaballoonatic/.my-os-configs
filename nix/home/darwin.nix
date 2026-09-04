{ inputs, config, ... }:

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

	# Single source of truth for PATH additions Nix/nix-darwin/Homebrew need on
	# macOS. Consumed directly by ./modules/nushell/home.nix since nushell
	# doesn't source the POSIX hm-session-vars.sh Home Manager normally
	# generates from this option.
	home.sessionPath = [
		"${config.home.homeDirectory}/.nix-profile/bin"
		"/etc/profiles/per-user/${config.home.username}/bin"
		"/nix/var/nix/profiles/default/bin"
		"/run/current-system/sw/bin"
		"/opt/homebrew/bin"
	];
}
