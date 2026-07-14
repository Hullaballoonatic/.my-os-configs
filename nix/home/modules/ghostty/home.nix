{ pkgs, ... }:

{
	programs.ghostty = {
		enable = true;

		settings = {
      command = "${pkgs.tmux}/bin/tmux new-session -A -s Default";

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
