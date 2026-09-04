{ config, ... }:

{
	imports = [
		./core.nix
		./modules/udiskie/home.nix
	];

  home.username = "casey";
	home.homeDirectory = "/home/casey";
	home.stateVersion = "26.05";

	# Single source of truth for PATH additions NixOS needs. Consumed directly
	# by ./modules/nushell/home.nix since nushell doesn't source the POSIX
	# hm-session-vars.sh Home Manager normally generates from this option.
	home.sessionPath = [
		"${config.home.homeDirectory}/.nix-profile/bin"
		"/etc/profiles/per-user/${config.home.username}/bin"
		"/nix/var/nix/profiles/default/bin"
		"/run/wrappers/bin"
		"/run/current-system/sw/bin"
	];
}

