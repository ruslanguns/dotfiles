{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "ensure-all-packages-background";
      runtimeInputs = [
        pkgs.coreutils
      ];
      text = ''
        lock_dir="/tmp/fish_packages_check.lock"
        log_file="/tmp/fish_packages_check.log"

        if ! mkdir "$lock_dir" >/dev/null 2>&1; then
          exit 0 # Another check is already running, exit silently.
        fi

        # Ensure the lock directory is removed on exit
        trap 'rmdir "$lock_dir"' EXIT

        # Use a subshell to redirect all output to the log file
        (
          echo "🚀 Starting background package check at $(date '+%Y-%m-%d %H:%M:%S')"
          echo "---"

          command -v ensure-nodejs &> /dev/null && ensure-nodejs
          command -v ensure-npm-packages &> /dev/null && ensure-npm-packages
          command -v ensure-krew-plugins &> /dev/null && ensure-krew-plugins
          command -v ensure-rust-toolchain &> /dev/null && ensure-rust-toolchain
          command -v ensure-luarocks-packages &> /dev/null && ensure-luarocks-packages

          echo "---"
          echo "✅ Background package check finished at $(date '+%Y-%m-%d %H:%M:%S')"
        ) > "$log_file" 2>&1
      '';
    })
  ];
}
