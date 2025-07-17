{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "ensure-luarocks-packages";
      runtimeInputs = [
        pkgs.luarocks
        pkgs.gnugrep
        pkgs.coreutils
        pkgs.findutils # For xargs
      ];
      text = ''
        required_packages="tiktoken_core"
        ignored_packages=""
        installed_count=0
        uninstalled_count=0

        if ! command -v luarocks &> /dev/null; then
            echo "❌ [luarocks] luarocks is not installed. Please install luarocks first."
            exit 1
        fi

        current_value=$(luarocks config local_by_default | xargs)
        if [ "$current_value" != "true" ]; then
            echo "🔧 [luarocks] setting local_by_default to true"
            luarocks config local_by_default true
        fi

        for package in $required_packages; do
            if ! luarocks list --porcelain | grep -q "^$package\s"; then
                echo "📦 [luarocks] installing package: $package"
                if luarocks install --local "$package"; then
                    installed_count=$((installed_count + 1))
                else
                    echo "❌ [luarocks] failed to install package: $package"
                fi
            fi
        done

        installed_packages=$(luarocks list --porcelain | cut -f1 | uniq)
        for package in $installed_packages; do
            if [ -z "$package" ]; then
                continue
            fi
            if echo " $required_packages " | grep -q " $package " || echo " $ignored_packages " | grep -q " $package "; then
                continue
            fi

            echo "🗑️ [luarocks] uninstalling extraneous package: $package"
            if luarocks remove --force "$package"; then
              uninstalled_count=$((uninstalled_count + 1))
            else
              echo "❌ [luarocks] failed to uninstall package: $package"
            fi
        done

        if [ $installed_count -gt 0 ]; then
            echo "✅ [luarocks] $installed_count package(s) installed."
        fi
        if [ $uninstalled_count -gt 0 ]; then
            echo "✅ [luarocks] $uninstalled_count extraneous package(s) uninstalled."
        fi
      '';
    })
  ];
}
