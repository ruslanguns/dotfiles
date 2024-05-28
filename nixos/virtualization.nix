{ inputs, config, pkgs, ... }:

{
  virtualisation.containers.enable = true;

  virtualisation = {
    podman = {
      enable = true;
      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # The reason for this is that the user@.service unit has a number of resource control settings that are not
  # suitable for containers. The Delegate= setting tells systemd to delegate the resource control settings to the
  # container manager (in this case, podman). This is necessary for the container to be able to manage its own
  systemd.services."user@".serviceConfig.Delegate="cpu cpuset io memory pids";
  systemd.packages = [
    (
      pkgs.writeTextFile {
        name = "delegate.conf";
        text = ''
        [Service]
        Delegate=yes
        '';
        destination = "/etc/systemd/system/user@.service.d/delegate.conf";
      }
    )
  ];
}
