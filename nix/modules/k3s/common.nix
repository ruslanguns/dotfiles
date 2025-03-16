{
  lib,
  pkgs,
  username,
  hostname,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./../nix-common.nix
    ./../users.nix
    ./sops.nix
  ];
  networking.enableIPv6 = false;
  networking.firewall.enable = false;

  home-manager.users.${username} = {
    imports = [
      ../../home/${username}/home-minimal.nix
    ];
  };

  environment.systemPackages = with pkgs; [
    openiscsi
    parted
  ];

  services.openiscsi.enable = true;
  services.openiscsi.name = "iqn.2025-02.ruso.dev:${hostname}";

  disko.devices = {
    disk.disk1 = {
      device = lib.mkDefault "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
          };
          esp = {
            name = "ESP";
            size = "500M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "pool";
            };
          };
        };
      };
    };
    disk.disk2 = {
      device = "/dev/sdb";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          longhorn = {
            name = "longhorn";
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/var/lib/longhorn";
              mountOptions = [ "defaults" ];
            };
          };
        };
      };
    };

    lvm_vg = {
      pool = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [
                "defaults"
              ];
            };
          };
        };
      };
    };
  };

}
