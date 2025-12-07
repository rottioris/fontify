#!/usr/bin/env bash
# ==> [ Version 1.2.0 ] <==
set -e
set -u

# ====== COLORS =====================================
PINK="\e[38;5;218m"
BLUE="\e[38;5;153m"
MINT="\e[38;5;157m"
YELLOW="\e[38;5;229m"
LILAC="\e[38;5;183m"
RESET="\e[0m"

# ====== ASCII ======================================
show_logo() {
    echo -e "${LILAC}"
cat << "EOF"

   ___               __           ___                  
 /'___\             /\ \__  __  /'___\                 
/\ \__/  ___     ___\ \ ,_\/\_\/\ \__/  __  __         
\ \ ,__\/ __`\ /' _ `\ \ \/\/\ \ \ ,__\/\ \/\ \        
 \ \ \_/\ \L\ \/\ \/\ \ \ \_\ \ \ \ \_/\ \ \_\ \       
  \ \_\\ \____/\ \_\ \_\ \__\\ \_\ \_\  \/`____ \      
   \/_/ \/___/  \/_/\/_/\/__/ \/_/\/_/   `/___/> \     
                   By: rottioris            /\___/     
                                            \/__/      

EOF
    echo -e "${RESET}"
}

# ===================================================
msg_ok()     { echo -e "${MINT}[✔]${RESET} $1"; }
msg_warn()   { echo -e "${YELLOW}[⚠]${RESET} $1"; }
msg_error()  { echo -e "${PINK}[✖ ERROR]${RESET} $1"; }
msg_action() { echo -e "${LILAC}→${RESET} $1"; }

# ===================================================
clear_and_show() {
    clear
    show_logo
}

check_yay() {
    if command -v yay &>/dev/null; then
        msg_ok "yay está instalado."
        return 0
    fi

    msg_warn "yay no está instalado."
    read -p "$(echo -e "${PINK}¿Deseas instalar yay? (s/n): ${RESET}")" ans
    if [[ "$ans" =~ ^[sS]$ ]]; then
        msg_action "Instalando yay..."
        sudo pacman -S --needed --noconfirm git base-devel
        git clone https://aur.archlinux.org/yay.git /tmp/yay >/dev/null 2>&1
        cd /tmp/yay
        makepkg -si --noconfirm
        cd - >/dev/null
        msg_ok "yay instalado correctamente."
    else
        msg_warn "No se podrá instalar paquetes de AUR."
    fi
}

show_font_test() {
    local type="${1:-normal}"
    echo
    echo -e "${LILAC}Prueba de iconos:${RESET}     "
    echo -e "${LILAC}Prueba de emojis:${RESET} 😀  🚀  ❤️"
    if [[ "$type" == "japanese" ]]; then
        echo -e "${LILAC}Prueba de caracteres japoneses:${RESET} こんにちは 世界"
    fi
    echo
    msg_ok "Fuente instalada correctamente."
}

install_pkg() {
    local pkg="$1"
    msg_action "Instalando $pkg..."
    if pacman -Si "$pkg" &>/dev/null; then
        sudo pacman -S --needed --noconfirm "$pkg"
        msg_ok "Instalado desde pacman."
    elif command -v yay &>/dev/null; then
        yay -S --needed --noconfirm "$pkg" && msg_ok "Instalado desde AUR." || msg_error "No se pudo instalar $pkg desde AUR."
    else
        msg_error "No se puede instalar $pkg (yay no disponible)."
        return
    fi

    # Recargar cache de fuentes
    fc-cache -fv >/dev/null 2>&1

    # Mostrar pruebas según la fuente
    if [[ "$pkg" =~ cjk ]]; then
        show_font_test "japanese"
    else
        show_font_test
    fi

    read -p "$(echo -e "${MINT}Presiona Enter para continuar…${RESET}")"
}

install_selected_fonts() {
    while true; do
        clear_and_show
        echo -e "${BLUE}Escoge la fuente que quieres instalar:${RESET}\n"

        echo -e " ${YELLOW}1${RESET}) ${PINK}JetBrainsMono Nerd Font${RESET}"
        echo -e " ${YELLOW}2${RESET}) ${PINK}FiraCode Nerd Font${RESET}"
        echo -e " ${YELLOW}3${RESET}) ${PINK}DejaVu${RESET}"
        echo -e " ${YELLOW}4${RESET}) ${PINK}Noto Sans/Serif${RESET}"
        echo -e " ${YELLOW}5${RESET}) ${PINK}Noto Color Emoji${RESET}"
        echo -e " ${YELLOW}6${RESET}) ${PINK}Microsoft Core Fonts (AUR)${RESET}"
        echo -e " ${YELLOW}7${RESET}) ${PINK}FontAwesome (AUR)${RESET}"
        echo -e " ${YELLOW}8${RESET}) ${PINK}Material Icons (AUR)${RESET}"
        echo -e " ${YELLOW}9${RESET}) ${PINK}Noto CJK (japonés/chino/coreano)${RESET}"
        echo -e " ${YELLOW}10${RESET}) ${MINT}Instalar TODO el pack recomendado${RESET}"
        echo -e " ${YELLOW}0${RESET}) ${LILAC}Volver al menú principal${RESET}\n"

        read -p "$(echo -e "${PINK}Selecciona una opción: ${RESET}")" op

        case "$op" in
            1) install_pkg ttf-jetbrains-mono-nerd ;;
            2) install_pkg ttf-fira-code-nerd ;;
            3) install_pkg ttf-dejavu ;;
            4) install_pkg noto-fonts ;;
            5) install_pkg noto-fonts-emoji ;;
            6) install_pkg ttf-ms-fonts ;;
            7) install_pkg ttf-font-awesome ;;
            8) install_pkg material-icons ;;
            9) install_pkg noto-fonts-cjk ;;
            10)
                install_pkg ttf-jetbrains-mono-nerd
                install_pkg ttf-fira-code-nerd
                install_pkg ttf-dejavu
                install_pkg noto-fonts
                install_pkg noto-fonts-emoji
                install_pkg ttf-ms-fonts
                install_pkg ttf-font-awesome
                install_pkg material-icons
                install_pkg noto-fonts-cjk
                ;;
            0) break ;;
            *) msg_error "Opción inválida" ;;
        esac
    done
}

configure_fontconfig() {
    mkdir -p "$HOME/.config/fontconfig"

    cat > "$HOME/.config/fontconfig/fonts.conf" << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>

    <match>
        <test name="family">
            <string>monospace</string>
        </test>
        <edit name="family" mode="prepend">
            <string>JetBrainsMono Nerd Font</string>
        </edit>
    </match>

    <match>
        <test name="family">
            <string>sans-serif</string>
        </test>
        <edit name="family" mode="prepend">
            <string>JetBrainsMono Nerd Font</string>
        </edit>
    </match>

    <match>
        <test name="family">
            <string>sans-serif</string>
        </test>
        <edit name="family" mode="append">
            <string>Noto Color Emoji</string>
        </edit>
    </match>

</fontconfig>
EOF

    msg_action "Recargando caché de fuentes…"
    fc-cache -fv
    msg_ok "Fontconfig configurado."
}

# ==============================================================
check_yay

while true; do
    clear_and_show
    echo -e "${BLUE}Menú principal:${RESET}\n"
    echo -e " ${YELLOW}1${RESET}) ${MINT}Instalar TODAS las fuentes recomendadas${RESET}"
    echo -e " ${YELLOW}2${RESET}) ${PINK}Elegir fuentes individualmente${RESET}"
    echo -e " ${YELLOW}3${RESET}) ${LILAC}Solo configurar fontconfig${RESET}"
    echo -e " ${YELLOW}0${RESET}) ${PINK}Salir${RESET}\n"

    read -p "$(echo -e "${PINK}Selecciona una opción: ${RESET}")" mainop

    case "$mainop" in
        1)
            clear_and_show
            install_pkg ttf-jetbrains-mono-nerd
            install_pkg ttf-fira-code-nerd
            install_pkg ttf-dejavu
            install_pkg noto-fonts
            install_pkg noto-fonts-emoji
            install_pkg ttf-ms-fonts
            install_pkg ttf-font-awesome
            install_pkg material-icons
            install_pkg noto-fonts-cjk
            ;;
        2)
            install_selected_fonts
            ;;
        3)
            clear_and_show
            configure_fontconfig
            read -p "$(echo -e "${MINT}Presiona Enter para volver al menú principal…${RESET}")"
            ;;
        0)
            clear_and_show
            echo -e "${PINK}Saliendo…${RESET}"
            exit 0
            ;;
        *)
            msg_error "Opción inválida"
            read -p "$(echo -e "${MINT}Presiona Enter para continuar…${RESET}")"
            ;;
    esac
done
