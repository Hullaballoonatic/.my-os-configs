{ inputs, ... }:

{
  imports = [
		inputs.noctalia.homeModules.default
	];

	programs.noctalia = {
		enable = true;

		settings = fromTOML (builtins.readFile ./noctalia-config.toml); 
	};
}
