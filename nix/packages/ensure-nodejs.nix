{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "ensure-nodejs";
      runtimeInputs = [
        pkgs.fnm
        pkgs.gnugrep
      ];
      text = ''
        # FNM needs to be initialized for the script's environment
        eval "$(fnm env --shell bash)"

        if ! fnm list | grep -q "v22.17.0"; then
            echo "📦 [fnm] Installing Node.js v22.17.0"
            fnm install 22.17.0
        else
            echo "✅ [fnm] Node.js v22.17.0 is already installed"
        fi

        # Note: "fnm current" can return "none" if no version is active
        current_node_version=$(fnm current)
        if [ "$current_node_version" != "v22.17.0" ]; then
            echo "🔧 Setting Node.js v22.17.0 as default"
            fnm default 22.17.0
        fi
      '';
    })
  ];
}
