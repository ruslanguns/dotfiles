#!/bin/bash

# Lista de paquetes disponibles en apt o snap
AVAILABLE_PACKAGES=(
  aria2
  bat
  btop
  composer
  cowsay
  curl
  ethtool
  ffmpeg
  file
  fish
  flameshot
  fzf
  gawk
  gcc
  gdu
  gnupg
  grc
  httpie
  iftop
  iotop
  ipcalc
  iperf3
  jq
  julia
  lsof
  ltrace
  make
  mtr
  neofetch
  neovim
  nmap
  openfortivpn
  openvpn
  p7zip
  pass
  pciutils
  php
  ripgrep
  ruby
  sed
  socat
  speedtest-cli
  sshpass
  strace
  sysstat
  tar
  tmux
  tree
  unzip
  usbutils
  wget
  xclip
  zip
  zoxide
  zstd
  fd-find
  dnsutils
)

AVAILABLE_SNAP_PACKAGES=(
  yq
  zellij
  kubectl
)

# install go, rust, zellij
sudo snap install go rustup zellij --classic

# Instalar los paquetes disponibles en apt
echo "Instalando paquetes disponibles en apt..."
for PACKAGE in "${AVAILABLE_PACKAGES[@]}"; do
  echo "Instalando $PACKAGE..."
  sudo apt install -y $PACKAGE
done

# Instalar los paquetes disponibles en snap
echo "Instalando paquetes disponibles en snap..."
for SNAP_PACKAGE in "${AVAILABLE_SNAP_PACKAGES[@]}"; do
  echo "Instalando $SNAP_PACKAGE..."
  sudo snap install $SNAP_PACKAGE
done

# install fisher
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher

# install lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit.tar.gz lazygit

KUBESEAL_VERSION='0.27.1'
curl -OL "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION:?}/kubeseal-${KUBESEAL_VERSION:?}-linux-amd64.tar.gz"
tar -xvzf kubeseal-${KUBESEAL_VERSION:?}-linux-amd64.tar.gz kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
rm kubeseal-${KUBESEAL_VERSION:?}-linux-amd64.tar.gz kubeseal
