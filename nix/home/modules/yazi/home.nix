{
	programs.yazi = {
		enable = true;

		enableNushellIntegration = true;

    flavors = {
			noctalia = ./flavors/noctalia.yazi;
		};

    theme = fromTOML (builtins.readFile ./theme.toml);
	};
}
