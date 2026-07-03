{ pkgs, ... }:

{
	home.packages = with pkgs; [
		sesh
		fzf
		fd
		nushell
	];

	programs.tmux = {
    enable = true;

		terminal = "tmux-256color";
		prefix = "C-Space";
		keyMode = "vi";
		escapeTime = 0;
		historyLimit = 50000;

	  plugins = with pkgs.tmuxPlugins; [
			sensible
			yank
			vim-tmux-navigator
		];

		extraConfig = ''
			set -g renumber-windows on

		  bind -n C-Left  select-pane -L
		  bind -n C-Down  select-pane -D
		  bind -n C-Up    select-pane -U
		  bind -n C-Right select-pane -R

			bind -n C-h select-pane -L
		  bind -n C-j select-pane -D
		  bind -n C-k select-pane -U
		  bind -n C-l select-pane -R

			bind-key -T copy-mode-vi v   send-keys -X begin-selection
			bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
			bind-key -T copy-mode-vi y   send-keys -X copy-selection-and-cancel

			bind-key "S" run-shell "sesh connect \"$(
				sesh list --icons | fzf-tmux -p 80%,70% \
					--no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
					--header '  ^a all ^t tmux ^x zoxide ^d tmux kill ^f find' \
					--bind 'tab:down,btab:up' \
					--bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
					--bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
					--bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
					--bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
					--bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
					--preview-window 'right:55%' \
					--preview 'sesh preview {}'
			)\""

			# Status Bar (pill look; requires a font with Powerline/Nerd glyphs)
			set -g @pill-inner-right '🭐'
			set -g @pill-inner-left '🭖'
			set -g @pill-outer-left ''
			set -g @pill-outer-right ''

			set -g status on
			set -g status-position top
			set -g status-interval 5
			set -g status-justify centre
			set -g window-status-separator '''

			# Bar background uses Catppuccin Mocha surface0; terminal base is #1e1e2e
			set -g status-style 'bg=#313244,fg=#cdd6f4'

			# Hide default window list entirely
			set -g window-status-format '''
			set -g window-status-current-format '''

			# Keep it visually light / thin by not cramming data
			set -g status-left-length 60
			set -g status-right-length 120

			set -g status-left '#[fg=#89b4fa,bg=#1e1e2e]#{@pill-outer-left}#[fg=#1e1e2e,bg=#89b4fa]#I#[fg=#89b4fa,bg=#313244]#{@pill-inner-right}#[fg=#cba6f7,bg=#313244]#{@pill-inner-left}#[fg=#1e1e2e,bg=#cba6f7,bold]#S#[fg=#cba6f7,bg=#313244,nobold]#{@pill-outer-right}'

			set -g @prefix_enabled '#[fg=#a6e3a1,bg=#313244]#[fg=#1e1e2e,bg=#a6e3a1,bold]✔#[fg=#a6e3a1,bg=#313244,nobold]🭐#[fg=#89b4fa,bg=#313244]🭖'

			set -g @prefix_disabled '#[fg=#89b4fa,bg=#313244]'

			set -g status-right '#{?client_prefix,#{@prefix_enabled},#{@prefix_disabled}}#[fg=#1e1e2e,bg=#89b4fa]#W#[fg=#89b4fa,bg=#313244]#{@pill-inner-right}#[fg=#f9e2af,bg=#313244]#{@pill-inner-left}#[fg=#1e1e2e,bg=#f9e2af]#H#[fg=#f9e2af,bg=#1e1e2e]#{@pill-outer-right}'
		'';
	};
}

