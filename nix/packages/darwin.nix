{ pkgs }:

(import ./core.nix { inherit pkgs; })
++
(with pkgs; [
	#	ghostty has an issue installing thru nix package manager
])

