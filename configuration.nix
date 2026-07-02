{ config, pkgs, ... }:

{
  nix.settings = {
    experimental-features = "nix-command flakes";
  };

  environment.systemPackages = [
    pkgs.git
    pkgs.nixfmt
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "ext4";
  };
  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "de";

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
    "sr_mod"
    "ext4"
  ];

  services.vscode-server.enable = true;

  users.users = {
    root.hashedPassword = "!"; # Disable root login
    selim = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOoPbdeg6m8b7fWa6Og/yNespDkC69mj0frS1pfk0SxP selim@computer"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID7Y2QfGe+ZIaz/HK13wP2QEeoJGpUhtlqaYMEDofqPa selim@laptop"
      ];
    };
  };

  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  systemd.services = {
    ws-landing-page = {
      description = "ws-landing-page";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      path = with pkgs; [
        bash
        nodejs
      ];

      serviceConfig = {
        User = "selim";
        WorkingDirectory = "/opt/ws-landing-page";
        ExecStart = "${pkgs.nodejs}/bin/npm run start";
        Restart = "always";
      };
    };
  };

  services.zakkig = {
    enable = true;
    user = "root";

    environment = {
      "PORT" = "4173";
      "DATABASE_PATH" = "/var/lib/zakkig.db";
    };
  };

  services.trustolino-landingpage = {
    enable = true;
    user = "root";

    environment = {
      "PORT" = "3002";
      "DATABASE_PATH" = "/var/lib/trustolino_leads.db";
      "VITE_COUNTDOWN_TARGET" = "2026-09-31T23:59:59Z";
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;

    appendHttpConfig = ''
      limit_req_zone $binary_remote_addr zone=perip:10m rate=10r/s;
      limit_req_status 429;
    '';

    virtualHosts = {
      "ws-boardinghouse.de" = {
        enableACME = true;
        forceSSL = true;
        globalRedirect = "www.ws-boardinghouse.de";
      };

      "www.ws-boardinghouse.de" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:3001";
          proxyWebsockets = true;

          extraConfig = ''
            limit_req zone=perip burst=20 nodelay;
          '';
        };
      };

      "selimeser.de" = {
        enableACME = true;
        forceSSL = true;
        globalRedirect = "www.selimeser.de";
      };

      "www.selimeser.de" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:3002";
          proxyWebsockets = true;

          extraConfig = ''
            limit_req zone=perip burst=20 nodelay;
          '';
        };
      };

      "zakkig.de" = {
        enableACME = true;
        forceSSL = true;
        globalRedirect = "www.zakkig.de";
      };

      "www.zakkig.de" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:4173";
          proxyWebsockets = true;

          extraConfig = ''
            limit_req zone=perip burst=20 nodelay;
          '';
        };
      };
    };
  };

  security.acme = {
    acceptTerms = true;

    certs = {
      "ws-boardinghouse.de".email = "info@ws-boardinghouse.de";
      "www.ws-boardinghouse.de".email = "info@ws-boardinghouse.de";
      "selimeser.de".email = "selim@selimeser.de";
      "www.selimeser.de".email = "selim@selimeser.de";
      "zakkig.de".email = "selim@zakkig.de";
      "www.zakkig.de".email = "selim@zakkig.de";
    };
  };

  networking.hostName = "selims-server";

  networking.firewall.allowedTCPPorts = [
    80
    443
    22
  ];

  system.stateVersion = "26.11";
}
