{ config, pkgs, ... }:

let
  qemu-shared = {
    device = "shared";
    fsType = "9p";
  };

  vbox-shared = {
    device = "shared";
    fsType = "vboxsf";
  };

  vmware-shared = {
    device = ".host:/shared";
    fsType = "vmhgfs";
  };

  parallels-shared = {
    device = "none";
    fsType = "prl_fs";
  };

  shared-config = if config.virtualisation.virtualbox.guest.enable then vbox-shared
      else if config.services.vmwareGuest.enable then vbox-shared
      else if config.hardware.parallels.enable then parallels-shared
      else qemu-shared;

in rec {
  imports = [ ./settings.nix ];

  users.users.guest = {
    isNormalUser = true;
    extraGroups = [ "wheel" "disk" "adm" ];
    createHome = true;
    home = "/home/guest";
    initialPassword = "root";
    useDefaultShell = true;
  };

  environment.systemPackages = (import ./core-packages.nix pkgs) ++ import ./gcc-packages.nix pkgs;

  boot.loader.timeout = 1;
  services.xserver.enable = false;
  security.sudo.wheelNeedsPassword = false;
  networking.hostName = "nixos";
  networking.firewall.enable = false;

  fileSystems = {
    "/tmp" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [ "nosuid" "nodev" "relatime" "size=4G" ];
    };
    "/shared" = shared-config // {
      options = [ "ro" "dmode=0555" ];
    };
  };
}
