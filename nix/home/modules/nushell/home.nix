{
  programs.nushell = {
    enable = true;

    loginFile.source = ./login.nu;

    extraConfig = ''
      alias manage = ^~/.my-os-configs/manage
    '';

    extraEnv = ''
      try { source-env "~/.secrets.nu" }
    '';

    settings.show_banner = false;
  };
}
