{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Bootloader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl."kernel.unprivileged_userns_clone" = 1;

  # Network configuration
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;

  # Hardware configuration
  hardware.enableRedistributableFirmware = true;

  # POWER MANAGEMENT
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';
  
  # VIDEO CONFIGURATION
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    prime = {
      sync.enable = true;
      offload = {
        enable = false;
        enableOffloadCmd = false;
      };
      intelBusId = "PCI:0:2:0"; # Fake bus ID, since I only have one GPU, is here because otherwise it won't work
      nvidiaBusId = "PCI:1:0:0";
    };
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  
  # VIRTUALIZATION
  virtualisation = {
    containers.enable = true;
    libvirtd.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];

      desktopManager.gnome.enable = true; 
      displayManager.gdm.enable = true;
      displayManager.gdm.wayland = false;
     # displayManager.autoLogin.enable = true;
     # displayManager.autoLogin.user = "rus";

      xkb = {
        layout = "es";
        variant = "";
      };
    };
  }; 
  
  console = {
    packages = [pkgs.terminus_font];
    font = "${pkgs.terminus_font}/share/consolefonts/ter-i22b.psf.gz";
    useXkbConfig = true;
  };

  # Sound configuration with PipeWire
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # User configuration
  users.users.rus = {
    isNormalUser = true;
    description = "Ruslan";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
  };

  # Package & Programs configuration
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
  programs.fish.enable = true;
  programs.firefox.enable = true;
  services.openssh.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  environment.systemPackages = with pkgs; [
    git
  ];

  # Locale settings
  time.timeZone = "Europe/Madrid";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_ES.UTF-8";
    LC_IDENTIFICATION = "es_ES.UTF-8";
    LC_MEASUREMENT = "es_ES.UTF-8";
    LC_MONETARY = "es_ES.UTF-8";
    LC_NAME = "es_ES.UTF-8";
    LC_NUMERIC = "es_ES.UTF-8";
    LC_PAPER = "es_ES.UTF-8";
    LC_TELEPHONE = "es_ES.UTF-8";
    LC_TIME = "es_ES.UTF-8";
  };

  # Fonts configuration
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      font-awesome
      source-han-sans
      source-han-serif-japanese
      source-han-sans-japanese
      (nerdfonts.override { fonts = [ "CascadiaCode" "FiraCode" "DroidSansMono" "Meslo" ]; })
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = ["Meslo LG M Regular Nerd Font Complete Mono"];
        serif = ["Noto Serif" "Source Han Serif"];
        sansSerif = ["Noto Sans" "Source Han Sans"];
      };
    };
  };

  # System state version
  system.stateVersion = "24.05";
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;
  nix = {
    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
