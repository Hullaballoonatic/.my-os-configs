{ pkgs, inputs, hostname, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nix.nix
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nix.optimise.automatic = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  networking.hostName = hostname;
  networking.networkmanager.enable = true;
  systemd.services.enable-wake-on-lan = {
    description = "Enable Wake-on-LAN for the wired interface";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.ethtool}/bin/ethtool -s enp9s0 wol g";
      RemainAfterExit = true;
    };
  };

  networking.firewall = {
    enable = true;

    allowedTCPPorts = [
      47984
      47989
      47990
      48010
    ];

    allowedUDPPorts = [
      47998
      47999
      48000
      48002
      48010
    ];
  };

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-uuid/d41b96be-10b5-4d3b-ac04-6d81ec4323b4";
    fsType = "ext4";
    options = [ "nofail" "x-systemd.autmount" ];
  };

  hardware.cpu.amd.updateMicrocode = true;
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.bluetooth.enable = true;
  
  services.xserver.videoDrivers = [ "nvidia" ];
  boot.kernelParams = [
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_TemporaryFilePath=/var/tmp"
  ];
  hardware.nvidia = {
    modesetting.enable = true;

    powerManagement.enable = true;
    powerManagement.finegrained = false;

    open = true;
    nvidiaSettings = true;
  };

  security.rtkit.enable = true;
  security.polkit.enable = true;
  security.sudo.wheelNeedsPassword = true;

  services.openssh.enable = true;
  
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  services.udisks2.enable = true;
  services.flatpak.enable = true;

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.gnome.evolution-data-server.enable = true;

  services.getty.autologinUser = "casey";

  programs.gpu-screen-recorder.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    silent = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  programs.kdeconnect.enable = true;
  programs.steam.enable = true;
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;

  users.mutableUsers = false;
  users.users.${username} = {
    isNormalUser = true;
    description = "Casey";
    shell = pkgs.nushell;
    hashedPasswordFile = "/etc/nixos/secrets/${username}-password.hash";
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "input"
      "dialout"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGGzdglPRmtwQ0i7Jv1uA9V8N6fuIFHp3jcfLzkdCn5D pi"
    ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
  ];

  hardware.steam-hardware.enable = true;
  hardware.keyboard.zsa.enable = true;

  environment.systemPackages = 
    (import ../../packages/linux.nix { inherit pkgs; })
    ++
    (with pkgs; [
      # compilers
      gcc

      # utilities
      bubblewrap # wanted by codex
      ethtool

      # screenshot and clipboard
      grim
      slurp
      wl-clipboard
      satty
      hyprshot

      # gui apps
      ghostty
      protonup-qt
      scrcpy # control android phone 
      vesktop # discord but not shit
      keymapp # keyboard editing

      # flakes
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.codex-nix.packages.${pkgs.stdenv.hostPlatform.system}.default # openai's terminal agentic ai

      # Noctalia with calendar support
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    ]);

  systemd.user.services.vicinae = {
    description = "Vicinae";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/vicinae server";
      Environment = [
        "USE_LAYER_SHELL=1"
        "PATH=/run/wrappers/bin:/run/current-system/sw/bin:/etc/profiles/per-user/${username}/bin"
      ];
      Restart = "on-failure";
    };
  };

  environment.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "zen-browser";
    TERMINAL = "ghostty";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
    GTK_USE_PORTAL = "1";
  };

  # home-manager.users.casey = import ./home.nix;

  system.stateVersion = "25.05";
}
