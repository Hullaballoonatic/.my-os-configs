{ pkgs, ... }:

{
	programs.git = {
    enable = true;

		package = pkgs.git;

		ignores = [
			"*.BAK"
			".git"
			"out"
			"bin"
		];

		settings.credential.helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
	};

	home.packages = [
		pkgs.git-credential-manager
	];
}
