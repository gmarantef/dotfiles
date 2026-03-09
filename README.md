# Bootstrap de Sistema Multi-OS con chezmoi

Repositorio personal para el bootstrap reproducible de sistemas Linux y macOS
usando chezmoi como motor de orquestación.

Este proyecto convierte un sistema limpio en un entorno completamente
configurado mediante la gestión declarativa de dotfiles, ejecución controlada
de scripts de bootstrap y consumo seguro de secretos desde un gestor externo.

> Objetivo: reproducibilidad, portabilidad y separación clara entre OS,
features y contexto.

---

## ¿Qué es este proyecto?

Este repositorio implementa una arquitectura de bootstrap basada en:

- Gestión declarativa de dotfiles
- Instalación modular de características del sistema (features)
- Separación por sistema operativo
- Adaptación por contexto (work / personal)
- Integración con gestor de contraseñas sin almacenar secretos

No pretende ser un framework genérico, sino una base sólida, extensible y
profesional para la gestión de mis entornos de trabajo.

Puede ser reutilizado por terceros con conocimientos previos en:
- Git
- Terminal
- chezmoi
- Gestión básica de sistemas Linux/macOS

---

# Índice

- [Arquitectura](#arquitectura)
  - [Tools utilizadas](#tools-utilizadas)
  - [Dimensiones](#dimensiones)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Requisitos](#requisitos)
- [Gestión de secretos](#gestión-de-secretos)
- [Virtualización](#virtualización)
  - [Vagrant](#vagrant)
- [Asistente IA](#asistente-ia)
- [Uso inicial](#uso-inicial)
- [Uso diario](#uso-diario)
- [Testing](#testing)
- [Roadmap](#roadmap)
- [Filosofía del proyecto](#filosofía-del-proyecto)

# Arquitectura

El eje central del proyecto es:

- [chezmoi](https://www.chezmoi.io/)

Sobre este se construye una arquitectura basada en **3 dimensiones**:

1. OS
2. Features
3. Context

Esta separación permite composición, idempotencia y superposición de
configuraciones.

---

## Tools utilizadas

El entorno se apoya en:

- Homebrew + Flatpak → gestión de paquetes
- zsh + oh-my-zsh → configuración de shell
- docker (+ Colima en macOS) → contenedores
- Bitwarden → gestión de secretos
- QEMU (KVM) + libvirt + vagrant → virtualización de máquinas

---

## Dimensiones

### OS

Detectado automáticamente por chezmoi.

Responsabilidades:
- Garantizar entorno mínimo del host
- Preparar prerequisitos para features
- Diferenciar comportamiento Linux / macOS

En Linux, las distros guían los procesos concretos de instalación.

---

### Features

Las features representan dominios funcionales instalables de forma modular e
idempotente.

Se ejecutan desde:

```bash
run_once_bootstrap.sh.tmpl
```

Features disponibles:

- `ai` → entorno asistido por IA
- `brew` → instalación y configuración de Homebrew
- `bundle` → instalación desde Brewfile
- `cloud` → CLI de proveedores cloud
- `containers` → entorno Docker
- `gui` → aplicaciones GUI
- `security` → gestor de contraseñas
- `shell` → configuración de shell
- `vm` → virtualización

Cada feature está diseñada para:
- Ser independiente
- Ser combinable
- Poder ejecutarse en cualquier orden lógico definido en data

> Nota: ciertas features como por ejemplo bundle que requiere de Homebrew
instalado y por tanto puede aparentar que existe dependencia frente a la
feature brew se tratan con independencia en gestión de instalación.

---

### Context

Permite variar tanto dotfiles como templates scripts según perfil:

- `work`
- `personal`

El contexto afecta especialmente a:
- Configuración
- Secretos
- Perfiles cloud
- Ajustes específicos de entorno

---

# Estructura del proyecto

```
chezmoi/
├── .chezmoitemplates
│   ├── ...
├── bootstrap/
│   ├── features
│   |   ├── ...
│   └── os
│       ├── ...
├── dot_folders
│   ├── ...
├── private_dot_folders
│   ├── ...
├── .chezmoi.toml.tmpl
├── .chezmoidata.yaml
├── .chezmoiignore
├── .gitignore
├── dot_files
├── private_dot_files
├── README.md
└── run_once_bootstrap.sh.tmpl
```

---

# Requisitos

- Git
- curl
- Acceso a internet
- Conocimientos básicos de terminal
- Cuenta en Bitwarden o gestor de contraseñas alternativo

---

# Gestión de secretos

Este repositorio **no almacena secretos**.

La estrategia es:

- Uso de Bitwarden como vault externo
- Extracción de credenciales en caliente
- No persistencia en disco

Ejemplo destacado:

```private_dot_local/bin/aws-bw-helper.sh```


Este script permite autenticación temporal en AWS usando el Process Credential
Provider del SDK, evitando almacenar claves localmente.

El uso de `private_` en chezmoi solo limita visibilidad en el sistema destino.
No implica almacenamiento de secretos en el repositorio.

---

# Virtualización

La virtualización en el presente setup se consigue en sistemas Linux empleando
la tool nativa de Linux KVM para conseguir así los mejores rendimientos en las
máquinas virtuales levantadas.

Para acometer esta virtualización se emplean conjuntamente KVM + QEMU + libvirt.
Este setup puede arrojar dos posibles problemas iniciales:

1. Fallos en la instalación del provider libvirt.
  1. Incompatibilidad de los boxs empleados con este provider.
  2. Fallos en la instalación del plugin por dependencias necesarias no
  instaladas.
2. Fallos en la ejecución de KVM.
  1. Procesadores no compatibles con esta tecnología.
  2. No activada en la BIOS.

Para la resolución de problemas seguir las siguientes indicaciones:

1. Consultar en la descripción del box los providers aceptados.
2. Asegurarse de disponer de todas las dependencias indicadas en la instalación
del plugin de vagrant-libvirt.
3. Consultar si el procesador del host está entre los compatibles de KVM.
4. Activar en la BIOS la característica de virtualización de la CPU que permita
ejecutar KVM.

Los enlaces de interés para la resolución de los problemas indicados son:

- [Vagrant Public Registry](https://portal.cloud.hashicorp.com/vagrant/discover)
- [Processor support](https://www.linux-kvm.org/page/Processor_support)
- [Enabling virtualization](https://support.faceit.com/hc/en-us/articles/21523645046300-Enabling-virtualization-Intel-VT-x-AMD-SVM)

## Vagrant

---

# Asistente IA

La feature `ai` permite instalar agentes de IA de forma modular, siguiendo la
misma arquitectura que el resto de features del proyecto.

## Configuración

Los agentes a instalar se declaran en `.chezmoidata.yaml`:

```yaml
ai_agents:
  - claude_code
```

## Agentes disponibles

### claude_code

Instala [Claude Code](https://claude.ai/code), el CLI oficial de Anthropic,
usando el instalador nativo mediante curl:

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

Compatible con macOS y Linux. La instalación es idempotente: si el binario
`claude` ya está presente en el sistema, se omite.

La instalación nativa se actualiza automáticamente en segundo plano.

## Añadir nuevos agentes

1. Añadir el nombre del agente a `ai_agents` en `.chezmoidata.yaml`
2. Crear el script `bootstrap/features/ai/<nombre_agente>.sh`
3. Registrar el nuevo `case` en `bootstrap/features/ai.sh`

---

# Uso inicial

## 1. Instalar chezmoi

```bash
sh -c "$(curl -fsLS get.chezmoi.io)"
```

## 2. Crear tu propio fork del repositorio

Se recomienda clonar este proyecto y generar un repositorio propio
para personalización y versionado.

## 3. Inicializar en un sistema limpio

```bash
chezmoi init https://github.com/<tu_usuario>/dotfiles.git
```

## 4. Personalizar configuración

Modificar principalmente:

- ```.chezmoidata.yaml```

- ```.chezmoi.toml.tmpl```

- dotfiles y dot folders

Puede hacerse:

- Desde ```~/.local/share/chezmoi```

- O usando ```chezmoi edit```

> IMPORTANTE: modificar ```.chezmoidata.yaml``` para adaptar las variables  a
las necesidades del usuario sobre la configuración del sistema deseado.

## 5. Aplicar configuración

### Apply con configuración por defecto

```bash
chezmoi apply
```

### Apply sin ejecutar scripts

```bash
chezmoi apply --exclude=scripts
```

---

### Flujo interno de ejecución

1. Carga ```.chezmoidata.yaml```
2. Genera ```chezmoi.toml``` desde ```.chezmoi.toml.tmpl```
3. Renderiza y aplica dotfiles
4. Ejecuta ```run_once_bootstrap.sh.tmpl```
5. Ejecuta features en orden definido

---

# Uso diario

Una vez inicializado:

## Modificar ficheros

### Opción recomendada por chezmoi

```bash
chezmoi edit <ruta_del_dotfile>
```

Permite:

- Abrir con ```$EDITOR```
- Mantener coherencia
- Evitar desincronización

Ver cambios antes de aplicar:

```bash
chezmoi diff
```

Aplicar cambios:

```bash
chezmoi apply <ruta_del_dotfile>
```

---

### Modificación directa en source directory

También se pueden editar directamente en:

```code
~/.local/share/chezmoi
```

Útil para:

- Cambios grandes
- Uso de IDE

Después:

```bash
chezmoi diff
chezmoi apply
```

---

## Añadir nuevos ficheros

```bash
chezmoi add <fichero>
```

---

## Auto commit y auto push

Si en ```chezmoi.toml``` se configura:

```toml
[git]
    autoCommit = true
    autoPush = true
```

Entonces ```chezmoi edit``` realizará automáticamente:

- add
- commit
- push

Simplificando la sincronización con el repo.

---

# Testing

Estado actual de validación:

## Linux

- [ ] Arch
- [ ] Fedora
- [ ] Ubuntu

## macOS (Darwin)

- [ ] brew
- [ ] bundle
- [ ] cloud
- [ ] containers
- [ ] gui
- [ ] security
- [ ] shell

---

# Roadmap

- Implementar completamente ai.sh
- Validar todas las features en Ubuntu
- Arquitectura multi-profile para secretos
- Evaluar soporte Windows

---

# Filosofía del proyecto

- Idempotencia
- Composición
- Separación de responsabilidades
- No almacenar secretos
- Infraestructura personal reproducible
- Claridad estructural por encima de complejidad oculta
