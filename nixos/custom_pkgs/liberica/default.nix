self: super: {
  liberica = super.stdenv.mkDerivation {
    name = "liberica-jdk-21";
    src = super.fetchurl {
      url = "https://github.com/bell-sw/Liberica/releases/download/21.0.3%2B13/bellsoft-jdk21.0.3+13-linux-amd64-crac.tar.gz";
      sha256 = "cb7206f8c07e6686c3c895323fd8ca190391a677";
    };
    buildInputs = [ super.stdenv.cc ];
    installPhase = ''
      mkdir -p $out
      tar -xzf $src --strip-components=1 -C $out
    '';
  };
}

