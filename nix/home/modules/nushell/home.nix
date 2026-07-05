{
	programs.nushell = {
        enable = true;

        loginFile.source = ./login.nu;

        extraConfig = ''
          alias manage = ^~/.my-os-configs/manage
        '';

        settings.show_banner = false;
    };
}
