{
  inputs,
  pkgs,
  ...
}: let
  herdrPkg = inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default;

  tomlFormat = pkgs.formats.toml {};
in

{
	home.packages = [
		herdrPkg
	];

	xdg.configFile."herdr/config.toml".source = tomlFormat.generate "herdr-config.toml" {
		general.onboarding = false;

		theme.name = "Vicinae";

		terminal = {
			# An absolute Nix store path so herdr can find `nu` regardless of
			# what minimal PATH the launching terminal emulator handed us; see
			# ../ghostty/home.nix for the other half of this.
			default_shell = "${pkgs.nushell}/bin/nu";
		};

		keys = {
			prefix = "ctrl+space";

			split_vertical = "prefix+plus";

			focus_pane_left = "control+h";
			focus_pane_up = "control+j";
			focus_pane_down = "control+k";
			focus_pane_right = "control+l";
		};
	};
}
