{ pkgs, ... }:

{
	imports = [
		./modules/atuin/home.nix
		./modules/bat/home.nix
		./modules/carapace/home.nix
		./modules/fd/home.nix
		./modules/fzf/home.nix
		./modules/gh/home.nix
		./modules/git/home.nix
		./modules/htop/home.nix
		./modules/jq/home.nix
		./modules/lsd/home.nix
		./modules/nushell/home.nix
		./modules/ripgrep/home.nix
		./modules/sesh/home.nix
		./modules/starship/home.nix
		./modules/tmux/home.nix
		./modules/yazi/home.nix
		./modules/zoxide/home.nix
	];

	home.packages = with pkgs; [
		ncdu # disk usage viewer
		sd # find & replace replacement
		tree-sitter # dependency for cool stuff

		# LSPs
		bash-language-server
		marksman
		markdownlint-cli2
		stylua
		lua-language-server
		nixd
		taplo
		vscode-langservers-extracted
		yaml-language-server
	];
}

