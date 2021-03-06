{ config, pkgs, ... }:

{
  environment.etc = {
    "fuse.conf".text = ''
      user_allow_other
    '';
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    terminal = "screen-256color";
    extraTmuxConf = ''
      set -g mouse on
    '';
  };

  services = {
    openssh.enable = true;
    openntpd.enable = true;
  };

  systemd.coredump = {
    enable = true;
    extraConfig = "Storage=external";
  };

  security = {
    sudo.enable = true;
    pam.loginLimits = [
      { domain = "*"; type = "hard"; item = "core"; value = "unlimited"; }
      { domain = "*"; type = "soft"; item = "core"; value = "unlimited"; }
    ];
  };

  nixpkgs.config.allowUnfree = true;
  programs.bash.enableCompletion = true;
  users.defaultUserShell = pkgs.bashInteractive;
  time.timeZone = "Europe/Moscow";
}
