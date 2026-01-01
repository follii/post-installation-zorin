# 🔮 Zorin OS 18 Post-Install Script

> "Automatizando o tédio para voltar a codar mais rápido."

Um script de pós-instalação opinativo para o **Zorin OS 18** (base Ubuntu 24.04 LTS), focado em desenvolvimento Web (React/Next.js), produtividade e, claro, um terminal bonito.

Adaptado (leia-se: *roubado carinhosamente*) do script original de [@adelsonsljunior](https://github.com/adelsonsljunior), mas ajustado para o meu fluxo de trabalho.

## 🚀 O que ele faz?

Este script transforma uma instalação limpa do Zorin OS em uma máquina de dev pronta para uso.

### 📦 Gerenciamento de Pacotes

* Atualiza o sistema (`apt update && upgrade`).
* Remove travas (`locks`) antigas do apt.
* Configura **Flatpak** e adiciona o repositório Flathub.
* Adiciona repositórios externos essenciais (VS Code, Sublime, Opera, Hashicorp).

### 🛠️ Ferramentas de Desenvolvimento (Dev Stack)

* **Linguagens (via ASDF):** Node.js, Python, Golang, Rust, .NET Core.
* **Gerenciadores de Pacote:** Bun, pnpm, Yarn, uv.
* **Docker:** Instalação completa (Docker Engine + Compose) + **Portainer** rodando.
* **IDEs/Editores:** VS Code, Sublime Text, Neovim (configurado).
* **API Tools:** Postman, Insomnia.

### 🎨 Terminal & Produtividade (Rice)

* **Shell:** Zsh como padrão.
* **Framework:** Oh My Zsh + Plugins (Syntax Highlighting, Autosuggestions).
* **Terminal Emulator:** Tilix (definido como padrão).
* **Fontes:** MesloLGS Nerd Font (pronta para o Powerlevel10k).
* **Apps:** Obsidian, Spotify, Discord (Vesktop para Wayland), Telegram, etc.

## 📋 Pré-requisitos

* Uma instalação limpa do **Zorin OS 18** (ou Ubuntu 24.04 LTS).
* Conexão com a Internet.
* `git` instalado (o script instala, mas você precisa dele para clonar este repo).

## 💿 Como usar

1. **Clone o repositório:**

```bash
git clone https://github.com/SEU_USUARIO/zorin-post-install.git
cd zorin-post-install

```

1. **Dê permissão de execução:**

```bash
chmod +x install.sh

```

1. **Execute e vá pegar um café ☕:**

```bash
./install.sh

```

1. **Pós-instalação:**

* Reinicie o computador.
* Configure sua chave SSH no GitHub.
* Abra o terminal e configure o tema do Powerlevel10k (se solicitado).

## ⚙️ Personalização

Sinta-se à vontade para fazer um fork e alterar as listas de programas nas variáveis no início do script:

* `APT_PROGRAMS`: Pacotes do repositório oficial.
* `FLATPAK_PROGRAMS`: Apps do Flathub (melhor para desktop apps).
* `install_asdf()`: Adicione ou remova plugins de linguagem.

## 📝 Notas

* **Wayland:** O script instala o `Vesktop` em vez do Discord padrão para garantir que o compartilhamento de tela funcione corretamente no Wayland/Gnome moderno.
* **Docker:** O script adiciona seu usuário ao grupo `docker`, permitindo rodar contêineres sem `sudo`.

## 📄 Licença

Este projeto está sob a licença MIT. Use, modifique e "roube" como eu fiz. Apenas dê os créditos! 😉

---

<p align="center">
Feito com 💜 e muito Shell Script por <a href="[https://github.com/SEU_USUARIO](https://www.google.com/search?q=https://github.com/SEU_USUARIO)">Júlio</a>
</p>
