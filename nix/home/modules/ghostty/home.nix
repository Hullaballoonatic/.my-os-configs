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

      theme = "noctalia";
		  
			macos-window-buttons = "hidden";
		};

		themes = {
      noctalia = {
				background = "#1a1b26";
				foreground = "#c0caf5";
				cursor-color = "#c0caf5";
				cursor-text = "#1a1b26";
				selection-background = "#283457";
				selection-foreground = "#c0caf5";
				palette = [
					"0=#15161e"
					"1=#f7768e"
					"2=#9ece6a"
					"3=#e0af68"
					"4=#7aa2f7"
					"5=#bb9af7"
					"6=#7dcfff"
					"7=#a9b1d6"
					"8=#414868"
					"9=#f7768e"
					"10=#9ece6a"
					"11=#e0af68"
					"12=#7aa2f7"
					"13=#bb9af7"
					"14=#7dcfff"
					"15=#c0caf5"
				];	
			};
		};
	};
}
