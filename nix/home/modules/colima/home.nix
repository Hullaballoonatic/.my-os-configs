{ config, lib, ... }:

{
	services.colima = {
		enable = true;

		profiles.default = {
			isActive = true;
			isService = false;
			setDockerHost = lib.versionAtLeast config.home.stateVersion "26.05";
		};
	};
}
