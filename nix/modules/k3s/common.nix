{
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
    ./../px-disk-config.nix
    ./../nix-common.nix
    ./../users.nix
    ./sops.nix
  ];

  environment.systemPackages = with pkgs; [
    openiscsi
  ];

  services.openiscsi.enable = true;
  services.openiscsi.name = "iqn.2025-02.ruso.dev:${hostname}";

  # networking.firewall = {
  #   enable = true;
  #   allowedTCPPorts = [
  #     6443 # k3s API
  #     4240 # Cilium health checks
  #     4222 # Cilium hubble relay
  #     4244 # Hubble relay
  #     4245 # Hubble peer service
  #     9962 # Cilium agent prometheus metrics
  #     9963 # Cilium operator prometheus metrics
  #     9961 # Cilium hubble prometheus metrics
  #   ];
  #   allowedUDPPorts = [
  #     8472 # VXLAN
  #   ];
  # };
  #

  networking.enableIPv6 = false;
  networking.firewall.enable = false;

  home-manager.users.${username} = {
    imports = [
      ../../home/${username}/home-minimal.nix
    ];
  };

}
