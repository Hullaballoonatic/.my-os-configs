{
	programs.starship = {
		enable = true;

		enableNushellIntegration = true;

  	settings = fromTOML (builtins.readFile ./starship.toml);
	};
}
