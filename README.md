# dotfiles — Bootstrap multi-OS con chezmoi

Sistema de bootstrap reproducible para Linux y macOS basado en [chezmoi](https://chezmoi.io).
Convierte un sistema limpio en un entorno completamente configurado mediante dotfiles declarativos,
scripts de instalación idempotentes e integración segura con gestor de contraseñas.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## Arquitectura

El proyecto se organiza en **tres dimensiones ortogonales**:

| Dimensión | Descripción |
|-----------|-------------|
| **OS** | Detectado automáticamente por chezmoi. Controla prerequisitos del host y bifurca el comportamiento Linux / macOS. En Linux, la distro (`ubuntu`, `fedora`, `arch`) guía las instalaciones concretas. |
| **Features** | Dominios funcionales instalables de forma modular e idempotente. Se declaran en `.chezmoidata.yaml` y se ejecutan en orden. |
| **Context** | Perfil de uso (`personal` / `work`). Afecta a dotfiles, secretos y perfiles cloud. |

### Features disponibles

| Feature | Descripción |
|---------|-------------|
| `brew` | Homebrew + prerequisitos del sistema |
| `bundle` | `brew bundle` desde `dot_Brewfile.tmpl` |
| `shell` | zsh + oh-my-zsh + plugins de comunidad |
| `cloud` | CLI de proveedores cloud (AWS CLI v2) |
| `containers` | Docker Engine / Colima + lazydocker |
| `security` | Bitwarden CLI + GUI + jq |
| `gui` | VSCode + extensiones declarativas + Google Chrome |
| `ai` | Agentes de IA (Claude Code) |
| `vm` | KVM + QEMU + libvirt + Vagrant _(solo Ubuntu)_ |

---

## Estructura

```
chezmoi/
├── run_once_bootstrap.sh.tmpl   # Entry point — orquesta OS setup + features
├── .chezmoidata.yaml             # Fuente de verdad: features, context, agents, providers
├── .chezmoi.toml.tmpl            # Config chezmoi (autoCommit / autoPush)
├── .chezmoiignore                # Condicionales de aplicación por feature / OS
│
├── bootstrap/
│   ├── lib.sh                   # Logging, sudo_keepalive, require_command, _feature_deps
│   ├── features/
│   │   ├── brew.sh
│   │   ├── bundle.sh
│   │   ├── shell.sh → shell/zsh.sh
│   │   ├── cloud.sh → cloud/aws.sh
│   │   ├── containers.sh
│   │   ├── security.sh
│   │   ├── gui.sh
│   │   ├── ai.sh → ai/claude_code.sh
│   │   └── vm.sh
│   └── os/
│       ├── linux.sh → linux/ubuntu.sh | fedora.sh | arch.sh
│       └── darwin.sh
│
├── dot_zshrc.tmpl
├── dot_gitconfig.tmpl
├── dot_Brewfile.tmpl
├── private_dot_aws/config.tmpl
├── private_dot_local/bin/
│   └── aws-bw-helper.sh         # Extrae credenciales AWS de Bitwarden on-demand
│
└── tests/integration/
    ├── run_tests.sh              # Runner: ./run_tests.sh [distro] [feature]
    ├── helpers.sh
    ├── dockerfiles/              # Dockerfile.ubuntu / .fedora / .arch
    └── features/                # Un test por feature
```

---

## Inicio rápido

### 1. Instalar chezmoi

Instala el binario en `/usr/local/bin` para que quede disponible inmediatamente en PATH en cualquier terminal, tanto en Linux como en macOS:

```bash
sudo sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin
```

### 2. Inicializar el repositorio

```bash
chezmoi init <tu_usuario_github>
```

Esto clona el repositorio en `~/.local/share/chezmoi/` sin aplicar nada aún.

### 3. Personalizar antes de aplicar

Edita `.chezmoidata.yaml` para adaptarlo a tus necesidades antes del primer apply:

```bash
chezmoi edit ~/.local/share/chezmoi/.chezmoidata.yaml
```

```yaml
email: tu@email.com
features: [brew, bundle, shell, cloud, containers, security, gui, ai]
context: personal          # "personal" | "work"
default_shell: zsh
ai_agents: [claude_code]
cloud_providers: [aws]
vscode_extensions:
  - ms-azuretools.vscode-docker
  - eamodio.gitlens
  - redhat.vscode-yaml
secrets:
  aws:
    personal: nombre-del-item-en-bitwarden
    work: nombre-del-item-en-bitwarden
```

### 4. Aplicar

```bash
chezmoi apply
```

### Apply sin ejecutar scripts de bootstrap

```bash
chezmoi apply --exclude=scripts
```

---

## Uso diario

```bash
chezmoi edit <dotfile>   # Edita, hace commit y push automáticamente
chezmoi diff             # Previsualiza cambios pendientes
chezmoi apply            # Aplica cambios al sistema
chezmoi add <fichero>    # Incorpora un nuevo fichero al repositorio
```

El autocommit y autopush están configurados en `.chezmoi.toml.tmpl`:

```toml
[git]
    autoCommit = true
    autoPush   = true
```

---

## Gestión de secretos

Este repositorio **no almacena secretos**. La estrategia es zero-storage:

- [Bitwarden](https://bitwarden.com) actúa como único vault externo.
- `aws-bw-helper.sh` lee `$BW_SESSION`, llama a `bw get item` y devuelve JSON válido para el `credential_process` de AWS.
- Las credenciales nunca se escriben en disco.

```
AWS SDK → credential_process → aws-bw-helper → bw get item → credencial temporal
```

El prefijo `private_` en chezmoi limita permisos en el sistema destino (0600/0700). No implica almacenamiento de secretos en el repositorio.

---

## Virtualización

La feature `vm` implementa virtualización nativa en Linux mediante **KVM + QEMU + libvirt + Vagrant**.

> **Estado actual:** solo implementada para Ubuntu. Fedora, Arch y macOS emiten `log_warn` y omiten la instalación.

**Resolución de problemas habituales:**

- Verificar que el box Vagrant declara soporte para el provider `libvirt` → [Vagrant Registry](https://portal.cloud.hashicorp.com/vagrant/discover)
- Comprobar compatibilidad del procesador con KVM → [Processor support](https://www.linux-kvm.org/page/Processor_support)
- Activar la virtualización en la BIOS (Intel VT-x / AMD-V)

---

## Testing

Los tests de integración usan Docker para validar cada feature por distro.

```bash
make test             # Todas las distros × todas las features
make test-ubuntu      # Solo Ubuntu
make test-fedora      # Solo Fedora
make test-arch        # Solo Arch
make test-fast        # Solo shell, cloud, ai (sin brew — más rápido)
make test-build       # Pre-construye imágenes sin ejecutar tests
```

O directamente:

```bash
./tests/integration/run_tests.sh ubuntu brew
```

### Estado de validación

| Distro | Estado |
|--------|--------|
| Ubuntu | ✅ Validado (brew, bundle, shell, cloud, ai, security, containers, gui) |
| Fedora | ✅ Validado (brew, bundle, shell, cloud, ai, security, containers, gui) |
| Arch   | ✅ Validado (brew, bundle, shell, cloud, ai, security, containers, gui) |
| macOS  | ⬜ Pendiente (fuera del scope Docker) |

---

## Extensión del proyecto

### Nuevo agente AI

1. `bootstrap/features/ai/<agente>.sh`
2. Añadir `case` en `bootstrap/features/ai.sh`
3. Declarar en `.chezmoidata.yaml`: `ai_agents: [..., nombre]`

### Nuevo cloud provider

1. `bootstrap/features/cloud/<provider>.sh`
2. Añadir `case` en `bootstrap/features/cloud.sh`
3. Declarar en `.chezmoidata.yaml`: `cloud_providers: [..., nombre]`
4. Actualizar `.chezmoiignore` si hay dotfiles del provider

### Nueva distro Linux

1. `bootstrap/os/linux/<distro>.sh`
2. Añadir `case` en `bootstrap/os/linux.sh`
3. `tests/integration/dockerfiles/Dockerfile.<distro>`
4. Actualizar array `ALL_DISTROS` en `run_tests.sh`

---

## Roadmap

- [x] Validar suite completa de tests en Ubuntu, Fedora y Arch
- [x] Gestión de extensiones VSCode declarativas via `vscode_extensions` en `.chezmoidata.yaml`
- [ ] Implementar `vm` para Fedora, Arch y macOS
- [ ] Arquitectura multi-profile completa para secretos (`work` / `personal`)
- [ ] Evaluar soporte Windows (WSL2)

---

## Filosofía

- **Idempotencia** — cada script es seguro de ejecutar múltiples veces
- **Composición** — las features son independientes y combinables
- **Zero-storage** — ningún secreto persiste en disco ni en el repositorio
- **Fail fast** — errores fatales abortan; advertencias no bloquean el bootstrap
- **Reproducibilidad** — mismo resultado en cualquier sistema limpio soportado

---

## Licencia

[MIT](LICENSE) © 2026 Guillermo Marante
