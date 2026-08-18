{
  programs.nushell = {
    enable = true;

    loginFile.source = ./login.nu;

    extraConfig = ''
      alias manage = ^~/.my-os-configs/manage
    '';

    extraEnv = ''
      try { source-env ($env.HOME | path join ".secret_env.nu") }
    '';

    settings.show_banner = false;
  };
}
