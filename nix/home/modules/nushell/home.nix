{
  programs.nushell = {
    enable = true;

    loginFile.source = ./login.nu;

    extraConfig = ''
      alias manage = ^~/.my-os-configs/manage
    '';

    extraEnv = ''
      source-env (if ("~/.secrets.nu" | path exists) { "~/.secrets.nu" } else { null }) 
    '';

    settings.show_banner = false;
  };
}
