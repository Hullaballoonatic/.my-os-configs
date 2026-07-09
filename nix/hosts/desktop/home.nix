{ inputs, pkgs, ... }:

{
	imports = [
		../../home/linux.nix
		../../home/modules/codex/home.nix
		../../home/modules/gcc/home.nix
		../../home/modules/hypr/home.nix
		../../home/modules/hyprshot/home.nix
		../../home/modules/kde-connect/home.nix
		../../home/modules/noctalia/home.nix
		../../home/modules/satty/home.nix
		../../home/modules/vesktop/home.nix
	];

	home.packages = with pkgs; [
		# clipboard and screenshot utilities
    grim
    slurp
    wl-clipboard
		
		# gui apps
    protonup-qt
    scrcpy # control android phone 
    keymapp # keyboard editing

    # flakes
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
	];
}

