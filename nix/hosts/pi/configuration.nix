{ pkgs, inputs, modulesPath, hostname, username, ... }:

let
  home-pi-api = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.home-pi-api;

  wake-desktop = pkgs.writeShellScriptBin "wake-desktop" ''
    exec ${pkgs.wakeonlan}/bin/wakeonlan a8:a1:59:6f:72:d5
  '';
in
  {
    imports = [
      "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    ];

    networking.hostName = hostname;
    time.timeZone = "America/Chicago";

    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" username ];
    };

    hardware.enableRedistributableFirmware = true;

    boot.loader.grub.enable = false;
    boot.loader.generic-extlinux-compatible.enable = true;
    boot.zfs.forceImportRoot = false;

    networking.networkmanager.enable = true;

    users.users.${username} = {
      isNormalUser = true;
      linger = true;
      extraGroups = [ "wheel" "networkmanager" "storage" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHNvlOFyYFiaJi7qFgpy0fJxqEsMAGtJZDsNZYVCYPHe casey@desktop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBNKTwzKqcPY2HyTlYFXkaX8WqaMXXHzYyHOrZBekdec casey@pixel"
      ];
    };

    security.sudo.wheelNeedsPassword = false;

    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    services.tailscale.enable = true;
    services.tailscale.extraUpFlags = [ "--ssh" ];

    services.adguardhome = {
      enable = true;
      openFirewall = true;
    };

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };

    services.udisks2.enable = true;

    networking.firewall.allowedTCPPorts = [
      22   # SSH
      53   # DNS TCP
      80   # AdGuard setup UI, if using port 80
      3000 # AdGuard first-run UI/default admin UI
    ];

    networking.firewall.allowedUDPPorts = [
      53   # DNS UDP
      5353 # mDNS
    ];

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
      8787
    ];

    environment.systemPackages = with pkgs; [
      curl
      wget
      wakeonlan
      (writeShellScriptBin "wake-desktop" ''
        exec ${wakeonlan}/bin/wakeonlan a8:a1:59:6f:72:d5
      '')
    ];

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    nix.settings.auto-optimise-store = true;

    system.stateVersion = "25.11";

    systemd.user.services.udiskie = {
      description = "Automount removable drives";
      wantedBy = [ "default.target" ];

      serviceConfig = { 
        ExecStart = "${pkgs.udiskie}/bin/udiskie";
        Restart = "on-failure";
      };
    };
    systemd.services.home-pi-api = {
      description = "API";

      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" "tailscaled.service" ];
      wants = [ "network-online.target" ];

      path = [
        wake-desktop
      ];

      serviceConfig = {
        ExecStart = "${home-pi-api}/bin/home-pi-api";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  }

