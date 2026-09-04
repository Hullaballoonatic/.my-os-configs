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

	# Ghostty isn't buildable via Nix on aarch64-darwin (Linux-only in
	# nixpkgs); the macOS app is installed via Homebrew instead. Setting
	# package = null skips requiring/building it while still generating
	# and linking the config file.
	package = if pkgs.stdenv.hostPlatform.isDarwin then null else pkgs.ghostty;

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
