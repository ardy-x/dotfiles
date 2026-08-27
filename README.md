# dotfiles

Configuración y herramientas para terminal, con soporte para **Linux** (familias RHEL y Debian/Ubuntu) y **macOS**.

## Qué instala

El script `setup-tools.sh` instala y configura:

- **[bat](https://github.com/sharkdp/bat)** — reemplazo de `cat` con resaltado de sintaxis.
- **[ripgrep](https://github.com/BurntSushi/ripgrep)** — búsqueda de texto rápida.
- **[eza](https://github.com/eza-community/eza)** — reemplazo moderno de `ls` con iconos y colores.

Además agrega los siguientes aliases a `~/.bashrc` (y `~/.zshrc` si existe):

```bash
alias cat="bat --plain --paging=never"
alias ls="eza --icons --group-directories-first"
alias ll="eza -la --icons --octal-permissions --group-directories-first --time-style=relative"
alias la="eza -a --icons --group-directories-first"
alias tree='eza --tree --level=2 --icons --group-directories-first --ignore-glob="node_modules|.git|.next|dist"'
```

## Instalación

### Opción A — Rápida (sin clonar, vía curl)

Descarga y ejecuta el script directamente desde GitHub:

```bash
curl -fsSL https://raw.githubusercontent.com/ardy-x/dotfiles/main/setup-tools.sh | bash
```

> El script se descarga y ejecuta en el directorio actual. Al finalizar recarga tu shell (ver abajo).

### Opción B — Clonando el repositorio

```bash
git clone git@github.com:ardy-x/dotfiles.git
cd dotfiles
chmod +x setup-tools.sh
./setup-tools.sh
```

Luego recarga tu shell:

```bash
source ~/.bashrc   # o source ~/.zshrc en macOS
```

## Notas por sistema

- **macOS**: usa [Homebrew](https://brew.sh). Si no está instalado, el script lo instala automáticamente.
- **RHEL / Fedora / CentOS / AlmaLinux / Rocky**: usa `dnf`. Si `eza` no está disponible en los repositorios, se descarga el binario oficial.
- **Debian / Ubuntu**: usa `apt` y el repositorio oficial de `eza`. En estas distros `bat` se instala como `batcat`, pero el script crea el alias `bat` correspondiente.

## Verificación

```bash
cat --version
eza --version
rg --version
```
