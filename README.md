# 🧰 setup.sh — Instalador Modular para Linux

Un instalador interactivo y multiplataforma que convierte tu sistema Linux en una máquina lista para trabajar, personalizar y explorar 🔥

Compatible con múltiples distribuciones y gestores de paquetes, con instalación por categorías y reintentos automáticos.

---

## 🚀 Características

- ✅ Detección automática de distro  
- 📦 Instalación modular por categorías  
- 🔁 Reintento automático en fallos  
- 🎯 Soporte multi-distro:
  - Arch / Manjaro / EndeavourOS  
  - Fedora / RHEL / CentOS  
  - Debian / Ubuntu / derivados  
  - openSUSE  
  - Void Linux  
- 🔒 Configuración básica de privacidad (Tor, UFW…)  
- 🎨 Instalación de entornos de escritorio  
- 📋 Resumen final con errores  

---

## 📥 Instalación

### 1. Descargar el script

```bash
git clone <https://github.com/iangrinan0-cmd/setup.sh/blob/main/README.md>
cd <setup.sh>
```

O:

```bash
curl -O https://github.com/iangrinan0-cmd/setup.sh/blob/main/README.md
```

---

### 2. Dar permisos de ejecución

```bash
chmod +x setup.sh
```

---

### 3. Ejecutar

```bash
./setup.sh
```

⚠️ **IMPORTANTE:**
- No ejecutes el script como root  
- Necesitas `sudo` instalado  

---

## 🧠 ¿Cómo funciona?

El flujo es directo:

1. Detecta tu distribución usando `/etc/os-release`  
2. Selecciona el gestor de paquetes correcto (`pacman`, `apt`, `dnf`, `zypper`, `xbps`)  
3. Actualiza repositorios  
4. Muestra un menú interactivo  
5. Instala paquetes según la categoría elegida  
6. Reintenta automáticamente si algo falla  
7. Muestra un resumen final  

---

## 📦 Categorías disponibles

### 📦 Básico

Herramientas esenciales:

- wget, curl, git  
- vim / neovim  
- htop / btop  
- fastfetch  
- unzip, zip, tar  
- fzf, ripgrep, fd  
- bash-completion  

💡 En Arch también instala `yay` (AUR helper)

---

### 🔧 Necesario (personalización base)

- cava  
- picom  
- dunst  
- rofi  
- polybar  
- lsd, bat  
- pavucontrol, brightnessctl  
- network-manager, blueman  

---

### 🔒 Privacidad

- tor + torbrowser  
- firejail  
- ufw  
- bleachbit  
- keepassxc  
- veracrypt (según distro)  

⚙️ Extras automáticos:
- Activa UFW  
- Habilita el servicio Tor  

---

### 🎨 Personalización Extrema

Instala entornos completos:

- GNOME  
- KDE Plasma  
- XFCE  
- i3 (X11)  
- Hyprland (Wayland)  
- Sway (Wayland)  
- bspwm  

💡 Detecta tu entorno actual automáticamente  

💡 Activa el display manager adecuado:
- `gdm`, `sddm`, `lightdm`  

---

### 🚀 Todo

Instala todas las categorías en orden:

1. Básico  
2. Necesario  
3. Personalización  
4. Privacidad  

---

## 🔁 Sistema de reintentos

Cada paquete:

- Se intenta instalar hasta 2 veces  
- Si falla:
  - Se registra en una lista  
  - El script continúa  

---

## 📋 Resumen final

Al terminar verás:

- ✅ Todo correcto  
o  
- ⚠️ Lista de paquetes que fallaron  

Ejemplo:

```
✗ polybar
✗ cava
```

---

## ⚠️ Requisitos

- Linux compatible  
- Usuario con permisos `sudo`  
- Conexión a internet  

---

## 🧪 Notas

- Puedes ejecutar el script varias veces sin problema  
- Evita reinstalar paquetes ya existentes  
- Funciona bien en sistemas minimalistas  

---

## 🧠 Filosofía

Este script es como una navaja suiza digital:

> Tú eliges las piezas.  
> Él ensambla el sistema.  

Minimal si quieres.  
Bestia si te vienes arriba. 🐉

---

## 🛠️ Ideas futuras

- Soporte Flatpak / Snap  
- Módulo de desarrollo  
- Dotfiles automáticos  
- Rice completo  

---

## 📜 Licencia

Libre. Úsalo, modifícalo y mejóralo 🚀
