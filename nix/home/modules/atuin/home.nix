{ lib, ... }:

{
	programs.atuin = {
		enable = true;

		enableNushellIntegration = true;

		settings = {
			enter_accept = true;

			tmux.enabled = true;
		};
	};

	# Atuin may eagerly create this file before Home Manager links it.
	xdg.configFile."atuin/config.toml".force = lib.mkForce true;
}
