#!/bin/bash

# - - - - - - - - - - - - - - - - - - - - - - -
#   SCRIPT DE PÓS-INSTALAÇÃO PARA ZORIN OS 18
# - - - - - - - - - - - - - - - - - - - - - - -
# Autor: Júlio (via "empréstimo" do Adelson)
# Atualizado para base Ubuntu 24.04 LTS

## CORES
GREEN='\e[0;32m'
BLUE='\e[0;34m'
YELLOW='\e[1;33m'
RED='\e[0;31m'
DEFAULT='\e[0m'

DOWNLOADS_DIRECTORY="/tmp/programas_post_install"
FONTS_DIRECTORY="$HOME/.local/share/fonts"

# Cria diretório temporário se não existir
mkdir -p "$DOWNLOADS_DIRECTORY"

APT_PROGRAMS=(
    vim
    htop
    tree
    build-essential
    zsh
    tilix
    kitty
    alacritty
    sublime-text
    neovim
    gimp
    inkscape
    krita
    blender
    flameshot
    corectrl
    stacer
    timeshift
    steam-installer
    opera-stable
    vagrant
    libfuse2          # Essencial para AppImages no Ubuntu 24.04+
    gnome-sushi       # Preview de arquivos com barra de espaço (estilo Mac)
)

FLATPAK_PROGRAMS=(
    com.obsproject.Studio
    org.telegram.desktop
    dev.vencord.Vesktop         # Discord tunado (Melhor pra Wayland)
    com.discordapp.Discord      # Discord oficial (Backup)
    md.obsidian.Obsidian
    com.logseq.Logseq
    com.spotify.Client
    io.podman_desktop.PodmanDesktop
    com.getpostman.Postman
    rest.insomnia.Insomnia
    dev.k9s.k9s
    com.heroicgameslauncher.hgl
    net.lutris.Lutris
    io.github.mimbrero.WhatsAppDesktop  # Tentativa de suprir o Zap
)

DEPENDENCIES=(
    software-properties-common
    apt-transport-https
    ca-certificates
    gnupg
    zip
    unzip
    dconf-cli
    curl
    wget
    git
)

print_section() {
    echo -e "\n${BLUE}=================================================================================${DEFAULT}"
    echo -e "${YELLOW}>> $1${DEFAULT}"
    echo -e "${BLUE}=================================================================================${DEFAULT}"
}

check_internet() {
    print_section "Verificando conexão com a internet"
    if ! ping -c 1 8.8.8.8 -q &> /dev/null; then
        echo -e "${RED}[ERRO] - Sem conexão com a internet. Verifique os cabos ou o Wi-Fi.${DEFAULT}"
        exit 1
    else
        echo -e "${GREEN}[OK] - Conexão estabelecida.${DEFAULT}"
    fi
}

remove_apt_locks() {
    print_section "APT - Removendo locks pendentes (se houver)"
    sudo rm /var/lib/dpkg/lock-frontend &>/dev/null
    sudo rm /var/cache/apt/archives/lock &>/dev/null
}

setup_flatpak() {
    print_section "Configurando Flatpak"
    sudo apt install -y flatpak gnome-software-plugin-flatpak
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
}

install_dependencies() {
    print_section "Instalando dependencias essenciais"
    sudo apt update
    for dependence in "${DEPENDENCIES[@]}"; do
        if ! dpkg -l | grep -q $dependence; then
            echo -e "${GREEN}[INFO] - Instalando ${dependence}.${DEFAULT}"
            sudo apt install -y "$dependence"
        else
            echo -e "${YELLOW}[INFO] - ${dependence} já instalado.${DEFAULT}"
        fi
    done
}

add_external_repos() {
    print_section "Adicionando repositórios de terceiros"

    # VS Code
    echo -e "${GREEN}[INFO] - Adicionando repositório do Visual Studio Code.${DEFAULT}"
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg

    # Sublime Text
    echo -e "${GREEN}[INFO] - Adicionando repositório do Sublime Text.${DEFAULT}"
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

    # Opera
    echo -e "${GREEN}[INFO] - Adicionando repositório do Opera.${DEFAULT}"
    wget -qO- https://deb.opera.com/archive.key | gpg --dearmor | sudo tee /usr/share/keyrings/opera-browser-keyring.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/opera-browser-keyring.gpg] https://deb.opera.com/opera-stable/ stable non-free" | sudo tee /etc/apt/sources.list.d/opera-stable.list

    # Vagrant (Hashicorp)
    echo -e "${GREEN}[INFO] - Adicionando repositório do Vagrant.${DEFAULT}"
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

    sudo apt update
}

install_apt_programs() {
    print_section "Instalando programas via APT"
    APT_PROGRAMS+=(code) # Adiciona o VS Code na lista agora que o repo existe

    for program in "${APT_PROGRAMS[@]}"; do
        echo -e "${GREEN}[INFO] - Instalando $program.${DEFAULT}"
        sudo apt install -y "$program" || echo -e "${RED}[ERRO] Falha ao instalar $program${DEFAULT}"
    done
}

install_flatpak_programs() {
    print_section "Instalando programas via Flatpak"
    for program in "${FLATPAK_PROGRAMS[@]}"; do
        echo -e "${GREEN}[INFO] - Instalando $program.${DEFAULT}"
        flatpak install -y flathub "$program"
    done
}

install_docker() {
    print_section "Instalando Docker e Docker Compose"
    # No Ubuntu 24.04 o script oficial ainda é a melhor rota rápida
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh

    echo -e "${GREEN}[INFO] - Adicionando usuário ao grupo docker.${DEFAULT}"
    sudo usermod -aG docker "$USER"
}

install_portainer() {
    print_section "Subindo contêiner do Portainer"
    # Verifica se o docker está rodando antes
    if systemctl is-active --quiet docker; then
        sudo docker volume create portainer_data || true
        sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
    else
        echo -e "${YELLOW}[SKIP] Docker não parece estar ativo. Portainer pulado.${DEFAULT}"
    fi
}

install_asdf() {
    print_section "Instalando ASDF-VM"
    if [ ! -d "$HOME/.asdf" ]; then
        git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
    else
        echo -e "${YELLOW}[INFO] ASDF já existe. Pulando clone.${DEFAULT}"
    fi

    # Carrega o ASDF para a sessão atual do script
    . "$HOME/.asdf/asdf.sh"

    # Adiciona ao zshrc se não estiver lá
    if ! grep -q "asdf.sh" "$HOME/.zshrc"; then
        echo -e '\n. "$HOME/.asdf/asdf.sh"' >> ~/.zshrc
        echo -e '\n. "$HOME/.asdf/completions/asdf.bash"' >> ~/.zshrc
    fi

    # Função auxiliar para plugins
    install_asdf_plugin() {
        local name=$1
        local url=$2
        if ! asdf plugin-list | grep -q "^$name$"; then
            asdf plugin-add "$name" "$url"
        fi
        asdf install "$name" latest
        asdf global "$name" latest
    }

    install_asdf_plugin "nodejs" "https://github.com/asdf-vm/asdf-nodejs.git"
    install_asdf_plugin "python" ""
    install_asdf_plugin "golang" "https://github.com/asdf-community/asdf-golang.git"
    install_asdf_plugin "rust" "https://github.com/asdf-community/asdf-rust.git"

    # Dotnet Core (para seu C# futuro)
    install_asdf_plugin "dotnet-core" "https://github.com/emersonsoares/asdf-dotnet-core.git"
}

install_dev_tools() {
    print_section "Instalando ferramentas de desenvolvimento adicionais"

    echo -e "${GREEN}[INFO] - Instalando Bun.${DEFAULT}"
    curl -fsSL https://bun.sh/install | bash

    echo -e "${GREEN}[INFO] - Instalando pnpm.${DEFAULT}"
    curl -fsSL https://get.pnpm.io/install.sh | sh -

    echo -e "${GREEN}[INFO] - Habilitando Yarn via Corepack.${DEFAULT}"
    # Corepack vem com node, precisa garantir que o asdf nodejs está no path
    . "$HOME/.asdf/asdf.sh"
    corepack enable || echo -e "${YELLOW}Corepack falhou, verifique se o Node está ok.${DEFAULT}"

    echo -e "${GREEN}[INFO] - Instalando uv (Python tooling).${DEFAULT}"
    curl -LsSf https://astral.sh/uv/install.sh | sh
}

install_oh_my_zsh() {
    print_section "Instalando Oh My Zsh e Plugins"
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo -e "${YELLOW}[AVISO] - Oh My Zsh já está instalado.${DEFAULT}"
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
    fi

    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
    fi

    echo -e "${GREEN}[INFO] - Configurando o ZSH como shell padrão.${DEFAULT}"
    # Verifica se já é zsh para evitar pedir senha a toa
    if [ "$SHELL" != "$(which zsh)" ]; then
        chsh -s $(which zsh)
    fi
}

configure_zsh() {
    print_section "Aplicando configurações ao .zshrc"
    # Backup antes de mexer
    cp ~/.zshrc ~/.zshrc.backup
    sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc
}

configure_git() {
    print_section "Configurando Git"
    git config --global init.defaultBranch main
    echo -e "${YELLOW}Lembre-se de configurar seu user.name e user.email depois!${DEFAULT}"
}

install_nerd_font() {
    print_section "Instalando a fonte Meslo Nerd Font"
    [[ ! -d "$FONTS_DIRECTORY" ]] && mkdir -p "$FONTS_DIRECTORY"

    # Loop para baixar fontes, código mais limpo
    for type in "Regular" "Bold" "Italic" "Bold%20Italic"; do
        local file="MesloLGS NF ${type//%20/ }.ttf"
        local url="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20$type.ttf"
        if [ ! -f "$FONTS_DIRECTORY/$file" ]; then
            echo -e "Baixando $file..."
            curl -fLo "$FONTS_DIRECTORY/$file" "$url"
        fi
    done

    fc-cache -fv
}

set_default_terminal() {
    print_section "Definindo Tilix como terminal padrão"
    # Verifica se o tilix está instalado antes de setar
    if command -v tilix &> /dev/null; then
        sudo update-alternatives --set x-terminal-emulator /usr/bin/tilix
    else
        echo -e "${RED}[ERRO] Tilix não encontrado.${DEFAULT}"
    fi
}

final_system_update() {
    print_section "Limpeza final"
    sudo apt autoclean -y
    sudo apt autoremove -y
}

main() {
    check_internet
    remove_apt_locks
    install_dependencies
    add_external_repos
    setup_flatpak
    install_apt_programs
    install_flatpak_programs
    install_docker
    install_portainer
    install_asdf
    install_dev_tools
    install_oh_my_zsh
    configure_zsh
    configure_git
    install_nerd_font
    set_default_terminal
    final_system_update

    print_section "SETUP CONCLUÍDO!"
    echo -e "${YELLOW}Recomendado: Reinicie o sistema.${DEFAULT}"
    echo -e "${GREEN}Dica de ex-usuário de Windows: Use 'newgrp docker' para usar o docker sem reiniciar agora.${DEFAULT}"
    echo -e "${BLUE}Agora volta pro código que esse Next.js não vai se escrever sozinho!${DEFAULT}"
}

main
