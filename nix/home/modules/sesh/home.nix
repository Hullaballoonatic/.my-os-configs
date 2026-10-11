{ pkgs, ... }:

{
	programs.sesh = {
		enable = true;

		# Mockery 3.8.0 cannot parse Go 1.27's export data (version 5).
		# Keep Sesh and its Mockery dependency on Go 1.26 until nixpkgs
		# includes the fix from https://github.com/vektra/mockery/pull/1188
		# (golang.org/x/tools >= 0.51.0). Remove this override once the
		# unmodified pkgs.sesh builds successfully with Go 1.27.
		package = pkgs.sesh.override {
			buildGo127Module = pkgs.buildGo126Module;
		};

		# broken for nushell
		enableAlias = false;

		enableTmuxIntegration = true;
	};
}
