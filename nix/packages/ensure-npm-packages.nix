{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "ensure-npm-packages";
      runtimeInputs = [
        pkgs.nodejs
        pkgs.gnugrep
        pkgs.gawk
        pkgs.gnused
        pkgs.coreutils
      ];
      text = ''
        # This script assumes 'npm' is already in the PATH,
        # configured by the calling shell function.

        required_packages="@google/gemini-cli markdown-toc @biomejs/biome"
        ignored_packages="npm corepack"
        installed_count=0
        uninstalled_count=0

        if ! command -v npm &> /dev/null; then
            echo "❌ [npm] npm is not available. FNM might not be configured correctly in the parent shell."
            exit 1
        fi

        for package in $required_packages; do
            if ! npm list -g --depth=0 | grep -q "$package"; then
                echo "📦 [npm] installing package: $package"
                if npm install -g "$package" > /dev/null 2>&1; then
                    installed_count=$((installed_count + 1))
                else
                    echo "❌ [npm] failed to install package: $package"
                fi
            fi
        done

        installed_packages=$(npm list -g --depth=0 | grep -E '^[└├]' | sed -e 's/^.*── //' -e 's/ @[0-9][^ ]*$//' -e 's/@[0-9][^ ]*$//' | xargs)
        for package in $installed_packages; do
            if [ -z "$package" ]; then
                continue
            fi
            if echo " $required_packages " | grep -q " $package " || echo " $ignored_packages " | grep -q " $package "; then
                continue
            fi

            echo "🗑️ [npm] uninstalling extraneous package: $package"
            if npm uninstall -g "$package" > /dev/null 2>&1; then
              uninstalled_count=$((uninstalled_count + 1))
            else
              echo "❌ [npm] failed to uninstall package: $package"
            fi
        done

        if [ $installed_count -gt 0 ]; then
            echo "✅ [npm] $installed_count package(s) installed."
        fi
        if [ $uninstalled_count -gt 0 ]; then
            echo "✅ [npm] $uninstalled_count extraneous package(s) uninstalled."
        fi
      '';
    })
  ];
}

