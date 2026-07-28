{
  config,
  inputs,
  pkgs,
  ...
}: let
  herdrPkg = inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default;
in

{
	programs.ghostty = {
		enable = true;

		settings = {
      command = "${herdrPkg}/bin/herdr";
      env = "PATH=${config.home.homeDirectory}/.nix-profile/bin:/etc/profiles/per-user/${config.home.username}/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin";

			confirm-close-surface = false;

			window-padding-x = 8;
			window-padding-y = 8;

			background-opacity = 0.95;

			font-size = 8;

			app-notifications = "no-clipboard-copy";

			macos-window-buttons = "hidden";
		};
	};
}
