{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "ensure-rust-toolchain";
      runtimeInputs = [
        pkgs.rustup
        pkgs.gnugrep
      ];
      text = ''
        if ! command -v rustup &> /dev/null; then
          echo "❌ [rustup] rustup is not installed. Please install rustup first."
          exit 1
        fi

        if ! rustup toolchain list | grep -q "stable"; then
          echo "📦 [rustup] installing stable toolchain"
          rustup toolchain install stable
        fi

        if ! rustup default | grep -q "stable"; then
          echo "🔧 [rustup] setting stable as default toolchain"
          rustup default stable
        fi
      '';
    })
  ];
}
