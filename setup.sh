#!/usr/bin/env bash
# =============================================================================
#  setup.sh — Instalador modular para Linux
#  Distros: Arch/Manjaro, Fedora/RHEL, Debian/Ubuntu, openSUSE, Void
# =============================================================================

set -euo pipefail

# ─── Colores ─────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ─── Log helpers ──────────────────────────────────────────────────────────────
info()    { echo -e "${BLUE}[INFO]${RESET}  $*"; }
ok()      { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*"; }
section() { echo -e "\n${BOLD}${CYAN}══════════════════════════════════════${RESET}"; \
            echo -e "${BOLD}${CYAN}  $*${RESET}"; \
            echo -e "${BOLD}${CYAN}══════════════════════════════════════${RESET}\n"; }

# ─── Log de paquetes fallidos ─────────────────────────────────────────────────
FAILED_PKGS=()

# =============================================================================
#  DETECCIÓN DE DISTRO
# =============================================================================
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO_ID="${ID,,}"
        DISTRO_LIKE="${ID_LIKE,,:-}"
    else
        error "No se puede leer /etc/os-release. ¿Esto es Linux?"
        exit 1
    fi

    case "$DISTRO_ID" in
        arch|manjaro|endeavouros|garuda)
            PKG_MANAGER="pacman"
            ;;
        fedora|rhel|centos|rocky|almalinux)
            PKG_MANAGER="dnf"
            ;;
        ubuntu|debian|linuxmint|pop|kali|zorin)
            PKG_MANAGER="apt"
            ;;
        opensuse*|sles)
            PKG_MANAGER="zypper"
            ;;
        void)
            PKG_MANAGER="xbps"
            ;;
        *)
            # Intentar por ID_LIKE
            if [[ "$DISTRO_LIKE" == *"arch"* ]];    then PKG_MANAGER="pacman"
            elif [[ "$DISTRO_LIKE" == *"fedora"* || "$DISTRO_LIKE" == *"rhel"* ]]; then PKG_MANAGER="dnf"
            elif [[ "$DISTRO_LIKE" == *"debian"* || "$DISTRO_LIKE" == *"ubuntu"* ]]; then PKG_MANAGER="apt"
            elif [[ "$DISTRO_LIKE" == *"suse"* ]];  then PKG_MANAGER="zypper"
            else
                error "Distro no reconocida: $DISTRO_ID"
                error "Distros soportadas: Arch, Fedora, Debian/Ubuntu, openSUSE, Void"
                exit 1
            fi
            ;;
    esac

    ok "Distro detectada: ${BOLD}$PRETTY_NAME${RESET}"
    ok "Gestor de paquetes: ${BOLD}$PKG_MANAGER${RESET}"
}

# =============================================================================
#  INSTALADOR GENÉRICO CON REINTENTO
# =============================================================================

# Instala UN paquete con reintento automático
install_pkg() {
    local pkg="$1"
    local attempt=1

    while [ $attempt -le 2 ]; do
        info "[Intento $attempt] Instalando: $pkg"
        if _do_install "$pkg"; then
            ok "Instalado: $pkg"
            return 0
        fi
        warn "Falló intento $attempt para: $pkg"
        (( attempt++ ))
        sleep 1
    done

    error "No se pudo instalar: $pkg (se continúa)"
    FAILED_PKGS+=("$pkg")
    return 1
}

# Comando real según gestor de paquetes
_do_install() {
    local pkg="$1"
    case "$PKG_MANAGER" in
        pacman)  sudo pacman -S --noconfirm --needed "$pkg" 2>/dev/null ;;
        dnf)     sudo dnf install -y "$pkg" 2>/dev/null ;;
        apt)     sudo apt-get install -y "$pkg" 2>/dev/null ;;
        zypper)  sudo zypper install -y "$pkg" 2>/dev/null ;;
        xbps)    sudo xbps-install -y "$pkg" 2>/dev/null ;;
    esac
}

# Instala lista de paquetes
install_pkgs() {
    local pkgs=("$@")
    for pkg in "${pkgs[@]}"; do
        install_pkg "$pkg"
    done
}

# Actualizar repositorios
update_repos() {
    info "Actualizando repositorios..."
    case "$PKG_MANAGER" in
        pacman)  sudo pacman -Sy ;;
        dnf)     sudo dnf check-update || true ;;
        apt)     sudo apt-get update ;;
        zypper)  sudo zypper refresh ;;
        xbps)    sudo xbps-install -S ;;
    esac
}

# =============================================================================
#  PAQUETES POR CATEGORÍA Y DISTRO
# =============================================================================

# Mapeo: get_pkgs <categoria> → imprime lista de paquetes para $PKG_MANAGER
get_pkgs() {
    local categoria="$1"

    case "$categoria" in

        # ── BÁSICO ────────────────────────────────────────────────────────────
        basico)
            case "$PKG_MANAGER" in
                pacman) echo "wget curl git vim neovim htop btop fastfetch mousepad \
                              unzip zip tar xclip xdg-utils bash-completion fzf ripgrep fd" ;;
                dnf)    echo "wget curl git vim neovim htop btop fastfetch mousepad \
                              unzip zip tar xclip xdg-utils bash-completion fzf ripgrep fd-find" ;;
                apt)    echo "wget curl git vim neovim htop btop fastfetch mousepad \
                              unzip zip tar xclip xdg-utils bash-completion fzf ripgrep fd-find" ;;
                zypper) echo "wget curl git vim neovim htop btop fastfetch mousepad \
                              unzip zip tar xclip xdg-utils bash-completion fzf ripgrep fd" ;;
                xbps)   echo "wget curl git vim neovim htop btop fastfetch mousepad \
                              unzip zip tar xclip xdg-utils bash-completion fzf ripgrep fd" ;;
            esac
            ;;

        # ── NECESARIO ─────────────────────────────────────────────────────────
        necesario)
            case "$PKG_MANAGER" in
                pacman) echo "cava picom dunst rofi polybar lsd bat \
                              pulseaudio pavucontrol playerctl brightnessctl \
                              network-manager-applet blueman" ;;
                dnf)    echo "cava picom dunst rofi polybar lsd bat \
                              pulseaudio pavucontrol playerctl brightnessctl \
                              network-manager-applet blueman" ;;
                apt)    echo "cava picom dunst rofi polybar lsd bat \
                              pulseaudio pavucontrol playerctl brightnessctl \
                              network-manager-gnome blueman" ;;
                zypper) echo "cava picom dunst rofi polybar lsd bat \
                              pulseaudio pavucontrol playerctl brightnessctl \
                              NetworkManager-applet blueman" ;;
                xbps)   echo "cava picom dunst rofi polybar lsd bat \
                              pulseaudio pavucontrol playerctl brightnessctl \
                              network-manager-applet blueman" ;;
            esac
            ;;

        # ── PRIVACIDAD ────────────────────────────────────────────────────────
        privacidad)
            case "$PKG_MANAGER" in
                pacman) echo "tor torbrowser-launcher firejail ufw bleachbit \
                              keepassxc veracrypt" ;;
                dnf)    echo "tor torbrowser-launcher firejail ufw bleachbit \
                              keepassxc" ;;
                apt)    echo "tor torbrowser-launcher firejail ufw bleachbit \
                              keepassxc" ;;
                zypper) echo "tor firejail ufw bleachbit keepassxc" ;;
                xbps)   echo "tor torbrowser-launcher firejail ufw bleachbit keepassxc" ;;
            esac
            ;;
    esac
}

# =============================================================================
#  MÓDULO: BÁSICO
# =============================================================================
instalar_basico() {
    section "📦 Básico"

    # yay solo en Arch
    if [ "$PKG_MANAGER" = "pacman" ]; then
        instalar_yay
    fi

    read -ra pkgs <<< "$(get_pkgs basico)"
    install_pkgs "${pkgs[@]}"
}

instalar_yay() {
    if command -v yay &>/dev/null; then
        ok "yay ya está instalado"
        return
    fi
    info "Instalando yay (AUR helper)..."
    local tmpdir
    tmpdir=$(mktemp -d)
    sudo pacman -S --noconfirm --needed git base-devel
    git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
    (cd "$tmpdir/yay" && makepkg -si --noconfirm)
    rm -rf "$tmpdir"
    ok "yay instalado"
}

# =============================================================================
#  MÓDULO: NECESARIO
# =============================================================================
instalar_necesario() {
    section "🔧 Necesario (personalización base)"
    read -ra pkgs <<< "$(get_pkgs necesario)"
    install_pkgs "${pkgs[@]}"
}

# =============================================================================
#  MÓDULO: PRIVACIDAD
# =============================================================================
instalar_privacidad() {
    section "🔒 Privacidad"
    read -ra pkgs <<< "$(get_pkgs privacidad)"
    install_pkgs "${pkgs[@]}"

    # Activar ufw
    if command -v ufw &>/dev/null; then
        info "Activando UFW (firewall)..."
        sudo ufw --force enable
        sudo ufw default deny incoming
        sudo ufw default allow outgoing
        ok "UFW activado y configurado"
    fi

    # Activar tor
    if command -v tor &>/dev/null; then
        info "Habilitando servicio Tor..."
        sudo systemctl enable --now tor 2>/dev/null || true
        ok "Tor habilitado"
    fi
}

# =============================================================================
#  MÓDULO: PERSONALIZACIÓN EXTREMA (entornos de escritorio)
# =============================================================================

detect_current_de() {
    local de="${XDG_CURRENT_DESKTOP:-}"
    de="${de,,}"

    if   [[ "$de" == *"gnome"* ]];  then echo "gnome"
    elif [[ "$de" == *"kde"* || "$de" == *"plasma"* ]]; then echo "kde"
    elif [[ "$de" == *"xfce"* ]];   then echo "xfce"
    elif [[ "$de" == *"i3"* ]];     then echo "i3"
    elif [[ "$de" == *"hyprland"* ]]; then echo "hyprland"
    elif [[ "$de" == *"sway"* ]];   then echo "sway"
    elif [[ "$de" == *"bspwm"* ]];  then echo "bspwm"
    else echo "ninguno detectado"
    fi
}

get_de_pkgs() {
    local de="$1"
    case "$de" in
        gnome)
            case "$PKG_MANAGER" in
                pacman) echo "gnome gnome-tweaks gnome-shell-extensions" ;;
                dnf)    echo "gnome-shell gnome-tweaks gnome-extensions-app" ;;
                apt)    echo "gnome-shell gnome-tweaks gnome-shell-extensions" ;;
                zypper) echo "gnome-shell gnome-tweaks" ;;
                xbps)   echo "gnome gnome-tweaks" ;;
            esac ;;
        kde)
            case "$PKG_MANAGER" in
                pacman) echo "plasma kde-applications sddm" ;;
                dnf)    echo "@kde-desktop-environment" ;;
                apt)    echo "kde-plasma-desktop sddm" ;;
                zypper) echo "patterns-kde-kde patterns-kde-kde_yast" ;;
                xbps)   echo "kde5 sddm" ;;
            esac ;;
        xfce)
            case "$PKG_MANAGER" in
                pacman) echo "xfce4 xfce4-goodies lightdm lightdm-gtk-greeter" ;;
                dnf)    echo "@xfce-desktop-environment" ;;
                apt)    echo "xfce4 xfce4-goodies lightdm" ;;
                zypper) echo "patterns-xfce-xfce" ;;
                xbps)   echo "xfce4 xfce4-goodies lightdm" ;;
            esac ;;
        i3)
            case "$PKG_MANAGER" in
                pacman) echo "i3-wm i3status i3blocks dmenu xterm lightdm lightdm-gtk-greeter" ;;
                dnf)    echo "i3 i3status dmenu xterm lightdm" ;;
                apt)    echo "i3 i3status dmenu xterm lightdm" ;;
                zypper) echo "i3 i3status dmenu xterm lightdm" ;;
                xbps)   echo "i3 i3status dmenu xterm lightdm" ;;
            esac ;;
        hyprland)
            case "$PKG_MANAGER" in
                pacman) echo "hyprland waybar wofi sddm xdg-desktop-portal-hyprland \
                              qt5-wayland qt6-wayland polkit-kde-agent" ;;
                dnf)    echo "hyprland waybar wofi sddm" ;;
                apt)    echo "hyprland waybar wofi sddm" ;;
                zypper) echo "hyprland waybar wofi sddm" ;;
                xbps)   echo "hyprland waybar wofi sddm" ;;
            esac ;;
        sway)
            case "$PKG_MANAGER" in
                pacman) echo "sway swaybar swaybg swaylock swayidle waybar \
                              wofi foot xdg-desktop-portal-wlr" ;;
                dnf)    echo "sway waybar wofi foot" ;;
                apt)    echo "sway waybar wofi foot" ;;
                zypper) echo "sway waybar wofi foot" ;;
                xbps)   echo "sway waybar wofi foot" ;;
            esac ;;
        bspwm)
            case "$PKG_MANAGER" in
                pacman) echo "bspwm sxhkd polybar rofi picom feh" ;;
                dnf)    echo "bspwm sxhkd rofi picom feh" ;;
                apt)    echo "bspwm sxhkd rofi picom feh" ;;
                zypper) echo "bspwm sxhkd rofi picom feh" ;;
                xbps)   echo "bspwm sxhkd rofi picom feh" ;;
            esac ;;
    esac
}

instalar_personalizacion_extrema() {
    section "🎨 Personalización Extrema — Entornos de escritorio"

    local de_actual
    de_actual=$(detect_current_de)
    info "Entorno detectado actualmente: ${BOLD}$de_actual${RESET}"

    echo ""
    echo "¿Qué entorno quieres instalar?"
    echo ""

    local opciones=("GNOME" "KDE Plasma" "XFCE" "i3 (X11)" "Hyprland (Wayland)" "Sway (Wayland)" "bspwm" "Cancelar")
    local de_keys=("gnome" "kde" "xfce" "i3" "hyprland" "sway" "bspwm" "cancelar")

    select opt in "${opciones[@]}"; do
        local idx=$(( REPLY - 1 ))
        local de_elegido="${de_keys[$idx]:-}"

        if [ -z "$de_elegido" ] || [ "$de_elegido" = "cancelar" ]; then
            warn "Instalación de entorno cancelada"
            return
        fi

        info "Instalando: $opt"
        read -ra pkgs <<< "$(get_de_pkgs "$de_elegido")"

        if [ ${#pkgs[@]} -eq 0 ]; then
            warn "No hay paquetes definidos para $opt en tu distro"
            return
        fi

        install_pkgs "${pkgs[@]}"

        # Habilitar display manager si se instaló
        local dm=""
        case "$de_elegido" in
            gnome)              dm="gdm" ;;
            kde|hyprland)       dm="sddm" ;;
            xfce|i3|bspwm)     dm="lightdm" ;;
            sway)               dm="" ;;  # sway se lanza manual o con greetd
        esac

        if [ -n "$dm" ] && command -v "$dm" &>/dev/null; then
            info "Habilitando display manager: $dm"
            sudo systemctl enable "$dm" 2>/dev/null || true
            ok "$dm habilitado (efectivo en el próximo reinicio)"
        fi

        break
    done
}

# =============================================================================
#  RESUMEN FINAL
# =============================================================================
mostrar_resumen() {
    echo ""
    section "📋 Resumen de instalación"

    if [ ${#FAILED_PKGS[@]} -eq 0 ]; then
        ok "Todo instalado sin problemas. ¡Perfecto!"
    else
        warn "Los siguientes paquetes NO pudieron instalarse:"
        for pkg in "${FAILED_PKGS[@]}"; do
            echo -e "  ${RED}✗${RESET} $pkg"
        done
        echo ""
        warn "Puedes intentar instalarlos manualmente."
    fi
}

# =============================================================================
#  MENÚ PRINCIPAL
# =============================================================================
menu_principal() {
    echo ""
    echo -e "${BOLD}${CYAN}"
    echo "  ███████╗███████╗████████╗██╗   ██╗██████╗ "
    echo "  ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗"
    echo "  ███████╗█████╗     ██║   ██║   ██║██████╔╝"
    echo "  ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ "
    echo "  ███████║███████╗   ██║   ╚██████╔╝██║     "
    echo "  ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     "
    echo -e "${RESET}"
    echo -e "  ${BOLD}Instalador modular para Linux${RESET}"
    echo ""

    detect_distro
    update_repos

    echo ""
    echo "Selecciona qué categorías instalar (puedes ejecutar el script varias veces):"
    echo ""

    local opciones=(
        "📦  Básico        — wget, git, neovim, mousepad, yay (Arch)..."
        "🔧  Necesario     — cava, picom, dunst, rofi, polybar..."
        "🎨  Personalización Extrema — Entornos de escritorio"
        "🔒  Privacidad    — tor, firejail, ufw, keepassxc..."
        "🚀  Todo          — Instalar todas las categorías"
        "❌  Salir"
    )

    select opt in "${opciones[@]}"; do
        case $REPLY in
            1) instalar_basico ;;
            2) instalar_necesario ;;
            3) instalar_personalizacion_extrema ;;
            4) instalar_privacidad ;;
            5)
                instalar_basico
                instalar_necesario
                instalar_personalizacion_extrema
                instalar_privacidad
                ;;
            6) echo "Saliendo..."; break ;;
            *) warn "Opción inválida, elige entre 1 y ${#opciones[@]}" ;;
        esac

        mostrar_resumen

        echo ""
        echo "¿Quieres hacer algo más?"
        echo ""
    done

    mostrar_resumen
}

# =============================================================================
#  ENTRY POINT
# =============================================================================

# Comprobar que se ejecuta como usuario normal (no root directo)
if [ "$EUID" -eq 0 ]; then
    error "No ejecutes el script como root. Usa tu usuario normal (se pedirá sudo cuando haga falta)."
    exit 1
fi

# Comprobar que sudo está disponible
if ! command -v sudo &>/dev/null; then
    error "sudo no está instalado o no está en el PATH"
    exit 1
fi

menu_principal
