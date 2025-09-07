{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.k9s;
  yaml = pkgs.formats.yaml { };
in
{
  options.services.k9s = {
    enable = lib.mkEnableOption "k9s configuration";

    # Backwards-compat: deprecated alias for skinName
    theme = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Deprecated: use services.k9s.skinName instead.";
    };

    skinName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Optional K9s skin name to enable, per https://k9scli.io/topics/skins/.
        When set, it is referenced via k9s.ui.skin in config.yaml.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {
        k9s = {
          liveViewAutoRefresh = false;
          gpuVendors = { };
          screenDumpDir = "/tmp/dumps";
          refreshRate = 2;
          apiServerTimeout = "15s";
          maxConnRetry = 5;
          readOnly = false;
          defaultView = "";
          noExitOnCtrlC = false;
          ui = {
            enableMouse = false;
            headless = false;
            logoless = false;
            crumbsless = false;
            splashless = false;
            noIcons = false;
            reactive = false;
            defaultsToFullScreen = false;
            useFullGVRTitle = false;
          };
          noIcons = false;
          skipLatestRevCheck = false;
          keepMissingClusters = false;
          logger = {
            tail = 200;
            buffer = 500;
            sinceSeconds = 300;
            textWrap = false;
            disableAutoscroll = false;
            showTime = false;
          };
          shellPod = {
            image = "nicolaka/netshoot";
            namespace = "default";
            limits = {
              cpu = "200m";
              memory = "256Mi";
            };
            requests = {
              cpu = "100m";
              memory = "128Mi";
            };
            tty = true;
            command = [ "zsh" ];
            hostPathVolume = [
              {
                name = "docker-socket";
                mountPath = "/var/run/docker.sock";
                hostPath = "/var/run/docker.sock";
                readOnly = true;
              }
            ];
          };
        };
      };
      description = "Additional k9s settings merged into config.yaml.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.k9s ];
    home.file.".config/k9s/config.yaml".source = yaml.generate "k9s-config.yaml" (
      lib.recursiveUpdate (lib.optionalAttrs
        (cfg.skinName != null || (cfg.theme != null && cfg.theme != "default"))
        {
          k9s.ui.skin = if cfg.skinName != null then cfg.skinName else cfg.theme;
        }
      ) cfg.settings
    );

    # Convenience aliases
    home.shellAliases = {
      k9s-ctx = "k9s --command contexts";
      k9s-ns = "k9s --command namespace";
      k9s-pod = "k9s --command pods";
      k9s-deploy = "k9s --command deployments";
      k9s-svc = "k9s --command services";
    };
  };
}
