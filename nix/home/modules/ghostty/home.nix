{
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
      # herdr's `default_shell` is now set to an absolute Nix store path for
      # `nu` (see ../herdr/home.nix), so herdr never needs to resolve `nu` by
      # name via PATH, and this launcher no longer needs to set PATH at all.
      command = "${herdrPkg}/bin/herdr";

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
