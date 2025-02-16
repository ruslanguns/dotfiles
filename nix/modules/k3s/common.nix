{
  username,
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

  networking.firewall.allowedTCPPorts = [
    6443
  ];
  networking.firewall.allowedUDPPorts = [
    8472 # k3s, flannel: required if using multi-node for inter-node networking
  ];
  networking.enableIPv6 = false;

  home-manager.users.${username} = {
    imports = [
      ../../home/${username}/home-minimal.nix
    ];
  };

}
