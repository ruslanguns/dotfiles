{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "ensure-krew-plugins";
      runtimeInputs = [
        pkgs.krew
        pkgs.gnugrep
        pkgs.coreutils
      ];
      text = ''
        required_plugins="krew ns ctx foreach apidocs argo-apps-viz cilium count ctr df-pv kyverno kubescape resource-capacity stern view-utilization view-quotas modify-secret view-secret unused-volumes"
        ignored_plugins="rise/accio-token"
        installed_count=0
        uninstalled_count=0

        for plugin in $required_plugins; do
            if ! krew list | grep -q "^''${plugin}$"; then
                echo "📦 [krew] installing plugin: $plugin"
                if krew install "$plugin" > /dev/null 2>&1; then
                    installed_count=$((installed_count + 1))
                else
                    echo "❌ [krew] failed to install plugin: $plugin"
                fi
            fi
        done

        installed_plugins=$(krew list)
        for plugin in $installed_plugins; do
            if [ -z "$plugin" ]; then
                continue
            fi
            # Check if the plugin is in the required or ignored list
            if echo " $required_plugins " | grep -q " $plugin " || echo " $ignored_plugins " | grep -q " $plugin "; then
                continue
            fi

            echo "🗑️ [krew] uninstalling extraneous plugin: $plugin"
            if krew uninstall "$plugin" > /dev/null 2>&1; then
              uninstalled_count=$((uninstalled_count + 1))
            else
              echo "❌ [krew] failed to uninstall plugin: $plugin"
            fi
        done

        if [ $installed_count -gt 0 ]; then
            echo "✅ [krew] $installed_count plugin(s) installed."
        fi
        if [ $uninstalled_count -gt 0 ]; then
            echo "✅ [krew] $uninstalled_count extraneous package(s) uninstalled."
        fi
      '';
    })
  ];
}

