{
  inputs,
  config,
  pkgs,
  ...
}: {
  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = with pkgs; [
    hyprpaper
    hyprland
    hyprpicker
    dunst
    waybar
    swaybg
    swaylock
    swayidle
    rofi
    greetd.tuigreet
    rofi-wayland
    gnome-icon-theme
    pyprland
    hyprpicker
    hyprpaper
    cool-retro-term
    helix
    qutebrowser
    zathura
    mpv
    imv
    synergy
    swaycons
    xfce.tumbler
    xdg-desktop-portal-gtk
    xorg.libX11
    xorg.libX11.dev
    xorg.libxcb
    xorg.libXft
    xorg.libXinerama
    xorg.xinit
    xorg.xinput
    terminus-nerdfont
    pamixer
    nwg-look
    papirus-icon-theme
    nerdfonts
    noto-fonts
    noto-fonts-emoji
    brightnessctl
    iclip
    polkit_gnome
    ffmpeg
    viewnior
    pavucontrol
    wf-recorder
    grimblast
    ffmpegthumbnailer
    dmenu
    w3m
    playerctl
    waybar
    wlogout
    sddm
    qemu
    tldr
  ];
}
