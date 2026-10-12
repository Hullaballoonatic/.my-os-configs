{ pkgs, ... }:

{
	# Docker and credential helpers need to update ~/.docker/config.json.
	programs.docker-cli.enable = false;

	home.packages = with pkgs; [
		docker
		docker-buildx
		kubectl
	];
}
