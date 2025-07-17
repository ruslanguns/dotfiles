{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "check-dns";
      runtimeInputs = [
        pkgs.dnsutils # for nslookup
        pkgs.gnugrep
        pkgs.coreutils
      ];
      text = ''
        domain="$1"
        if [ -z "$domain" ]; then
            echo "❌ Usage: check-dns <domain>"
            exit 1
        fi

        output=$(nslookup "$domain" 2>&1)
        if echo "$output" | grep -q -E "can't find|NXDOMAIN|No answer"; then
            echo "❌ $domain"
        else
            echo "✅ $domain"
        fi
      '';
    })
  ];
}
