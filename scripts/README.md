# scripts

Scripts de instalación ejecutables directamente vía `curl`, **sin necesidad de clonar el repositorio**.

## Instalación vía curl (sin clonar)

Cada script puede ejecutarse directamente desde GitHub:

```bash
# Herramientas de terminal: bat, ripgrep, eza (aliases en .bashrc/.zshrc)
curl -fsSL https://raw.githubusercontent.com/ardy-x/dotfiles/main/scripts/setup-tools.sh | bash

# Entorno de escritorio: Zen Browser, Docker/OrbStack, VS Code, TablePlus, Bitwarden, LocalSend
curl -fsSL https://raw.githubusercontent.com/ardy-x/dotfiles/main/scripts/setup-workstation.sh | bash
```

> Se ejecutan en el directorio actual. Tras `setup-tools.sh`, recarga tu shell con `source ~/.bashrc` (o `source ~/.zshrc` en macOS).
