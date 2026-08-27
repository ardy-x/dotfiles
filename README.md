# dotfiles

Configuración y scripts de instalación de entorno para **Linux** (familias RHEL y Debian/Ubuntu) y **macOS**.

Todos los scripts se ejecutan directamente vía `curl`, **sin necesidad de clonar el repositorio**. Los comandos están en [`scripts/README.md`](scripts/README.md).

## Scripts disponibles

### `scripts/setup-tools.sh`

Instala y configura herramientas de terminal:

- **[bat](https://github.com/sharkdp/bat)** — reemplazo de `cat` con resaltado de sintaxis.
- **[ripgrep](https://github.com/BurntSushi/ripgrep)** — búsqueda de texto rápida.
- **[eza](https://github.com/eza-community/eza)** — reemplazo moderno de `ls` con iconos y colores.

Agrega los siguientes aliases a `~/.bashrc` (y `~/.zshrc` si existe):

```bash
alias cat="bat --plain --paging=never"
alias ls="eza --icons --group-directories-first"
alias ll="eza -la --icons --octal-permissions --group-directories-first --time-style=relative"
alias la="eza -a --icons --group-directories-first"
alias tree='eza --tree --level=2 --icons --group-directories-first --ignore-glob="node_modules|.git|.next|dist"'
```

### `scripts/setup-workstation.sh`

Instala aplicaciones de escritorio mediante un menú interactivo (selecciona una o varias opciones):

1. **Zen Browser**
2. **OrbStack** (macOS) / **Docker Engine** (Linux)
3. **Visual Studio Code** (con el comando `code` habilitado)
4. **TablePlus**
5. **Bitwarden**
6. **LocalSend**
7. Instalar todas

## Instalación rápida

```bash
curl -fsSL https://raw.githubusercontent.com/ardy-x/dotfiles/main/scripts/setup-tools.sh | bash
curl -fsSL https://raw.githubusercontent.com/ardy-x/dotfiles/main/scripts/setup-workstation.sh | bash
```

Tras `setup-tools.sh`, recarga tu shell:

```bash
source ~/.bashrc   # o source ~/.zshrc en macOS
```

## Notas por sistema

- **macOS**: usa [Homebrew](https://brew.sh). Si no está instalado, los scripts lo instalan automáticamente.
- **RHEL / Fedora / CentOS / AlmaLinux / Rocky**: usa `dnf`.
- **Debian / Ubuntu**: usa `apt`. En estas distros `bat` se instala como `batcat`, pero el script crea el alias `bat` correspondiente.

## Verificación

```bash
cat --version
eza --version
rg --version
```
