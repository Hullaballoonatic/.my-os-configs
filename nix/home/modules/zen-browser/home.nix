{ pkgs, ... }:

{
	programs.zen-browser = {
		enable = true;

		setAsDefaultBrowser = true;

		nativeMessagingHosts = [pkgs.firefoxpwa];

		profiles = {
			"Default Profile" = {
				path = "4t3rrncb.Default Profile";
			};
		};
	};
}
