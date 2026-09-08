{ pkgs, ... }:

{
	programs.docker-cli.enable = true;

	home.packages = with pkgs; [
		docker
		docker-buildx
		kubectl
	];
}
