{ inputs, ... }:

{
  imports = [
		inputs.noctalia.homeModules.default
	];

	programs.noctalia = {
		enable = true;

		settings = ./noctalia-config.toml; 
	};
}
