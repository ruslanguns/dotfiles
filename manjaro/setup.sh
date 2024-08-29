#!/bin/bash

# Actualizar el sistema
echo "Actualizando la base de datos de paquetes y el sistema..."
sudo pacman -Syu --noconfirm

# Asegurarse de que las herramientas básicas para la compilación estén instaladas
echo "Instalando herramientas de desarrollo esenciales..."
sudo pacman -S --noconfirm --needed base-devel fakeroot

# Lista de paquetes a instalar desde los repositorios oficiales
PACKAGES=(
    ffmpeg
    zip
    neofetch
    xz
    unzip
    p7zip
    jq
    yq
    wget
    curl
    fd
    fzf
    bat
    ripgrep
    nvim
    tree
    zoxide
    zellij
    mtr
    iperf3
    bind-tools
    ldns
    aria2
    socat
    nmap
    ipcalc
    networkmanager-openvpn
    openfortivpn
    openvpn
    glib2
    gcc
    grc
    cowsay
    file
    which
    sed
    tar
    gawk
    zstd
    gnupg
    make
    httpie
    lazygit
    tmux
    xclip
    pass
    libreoffice-fresh
    kubectl
    docker-compose
    go
    rust
    btop
    iotop
    iftop
    strace
    ltrace
    lsof
    gdu
    sysstat
    lm_sensors
    ethtool
    pciutils
    usbutils
    psensor
    speedtest-cli
    fish  # Añadiendo Fish
)

# Instalar los paquetes listados
echo "Instalando paquetes..."
for PACKAGE in "${PACKAGES[@]}"; do
    sudo pacman -S --noconfirm --needed $PACKAGE
done

# Instalar yay para manejar AUR
if ! command -v yay &> /dev/null; then
    echo "yay no encontrado. Instalando yay..."
    echo -e "1\n" | sudo pamac install yay --no-confirm --noinput
fi

# Lista de paquetes AUR
AUR_PACKAGES=(
    eza-git
    slack-desktop
    brave-bin
    element-desktop
    kind-bin
    dust-bin
    visual-studio-code-bin  # VSCode con soporte completo
    oh-my-fish
)

# Instalar paquetes desde AUR
echo "Instalando paquetes desde AUR..."
for AUR_PACKAGE in "${AUR_PACKAGES[@]}"; do
    yay -S --noconfirm $AUR_PACKAGE
done

# Verificar si Fish ya es el shell por defecto
CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" != "fish" ]; then
    echo "Configurando Fish como shell por defecto..."
    chsh -s /usr/bin/fish
else
    echo "Fish ya está configurado como el shell por defecto."
fi

# Verificar si oh-my-fish ya está instalado
if [ ! -d "$HOME/.local/share/omf" ]; then
    echo "Instalando Oh My Fish..."
    curl -L https://get.oh-my.fish | fish
else
    echo "Oh My Fish ya está instalado."
fi

# Verificar si Fisher ya está instalado
if ! fish -c "fisher --version" &> /dev/null; then
    echo "Instalando Fisher..."
    fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
else
    echo "Fisher ya está instalado."
fi

# Instalar plugins de Fish con Fisher
echo "Instalando plugins de Fish con Fisher..."
fish -c "fisher install grc thefuck jorgebucaran/fzf edc/bass"

# Limpiar la caché de pacman para liberar espacio
echo "Limpiando la caché de pacman..."
sudo pacman -Sc --noconfirm

echo "¡Instalación y configuración completadas!"
