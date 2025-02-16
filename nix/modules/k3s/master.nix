{
  tokenFile,
  ...
}:
{
  imports = [ ./common.nix ];

  #  FIXME: tenemos problemas con la instalación, sospecho por las previas pruebas, necesito probar con una instancia completamente limpia.
  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = tokenFile;
    clusterInit = true;
    # FIXME: el objetivo es controlar lo que instalamos, no queremos que K3S tenga control sobre nosotros.
    extraFlags = toString [
      # "--disable traefik"
      # "--disable servicelb"
      # "--disable local-storage"
      # "--flannel-backend=none"
      # "--cluster-cidr=10.42.0.0/16"
      # "--service-cidr=10.43.0.0/16"
    ];
  };
}
