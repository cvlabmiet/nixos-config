# nixos-config

A collection of NixOS configurations files

# vm-guest

Insert next lines into `configuration.nix`:
```nix
{config, pkgs, ...}:

{
    imports = [
        ./hardware-configuration.nix
        /shared/nixos-config/vm-guest.nix
    ];
}
```
