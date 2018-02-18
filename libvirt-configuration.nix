# Help is available in the configuration.nix(5) man page and in ‘nixos-help’.

{ config, pkgs, ... }:

{
  imports = [ ./default-settings.nix ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
  };

  fileSystems."/shared" = {
    device = "shared";
    fsType = "9p";
    options = [ "trans=virtio" "version=9p2000.L" "ro" ];
    neededForBoot = true;
  };

  users.users.guest = {
    isNormalUser = true;
    extraGroups = [ "wheel" "disk" "adm" ];
    createHome = true;
    home = "/home/guest";
    initialHashedPassword = "$6$VWufMJWczj.1Pzo$ZYTiAAvXorhHPaPXvl86zWZE4KIUgkXyTH8sOy.155DqY4D0mR5VEmPUtFAFTl.nQaXsBXjUAIzYUYmoHwcwS.";
    useDefaultShell = true;
  };

  environment.systemPackages = (import ./core-packages.nix pkgs) ++ import ./gcc-packages.nix pkgs;

  services.xserver.enable = false;
  security.sudo.wheelNeedsPassword = false;
  networking.hostName = "nixos";
  networking.firewall.enable = false;
  system.stateVersion = "17.09";
}
