# Use VS Code with Wayland

Ubuntu supports two display managers - Wayland and Xorg. Wayland is the replacement for xorg and is the default in Ubuntu 25.04 and newer. I have decided to use Wayland and deal with the issues that arise. Unfortunately, if you install VS Code using 'sudo apt install code' it doesn't work in Wayland.

I asked chatGPT how to make VS Code work with Wayland. Below are the steps it provided. I followed them and VS Code is working correctly under Wayland.

## A Bash script to install the Flatpak version of VS Code

Save this as: setup-vscode-flatpak.sh

```bash
#!/bin/bash

# 🚨 Auto-restart with sudo if not running as root
if [ "$EUID" -ne 0 ]; then
  echo "🔒 This script needs sudo privileges. Re-running with sudo..."
  exec sudo bash "$0" "$@"
fi

echo "🚀 Installing Visual Studio Code Flatpak..."
flatpak install flathub com.visualstudio.code -y

echo "✅ Applying Flatpak overrides for full functionality..."

# Full filesystem access
flatpak override com.visualstudio.code --filesystem=host

# Docker socket access
flatpak override com.visualstudio.code --filesystem=/run/docker.sock

# SSH agent and Secrets access
flatpak override com.visualstudio.code --socket=ssh-auth --talk-name=org.freedesktop.secrets

# Host network access
flatpak override com.visualstudio.code --share=network

# D-Bus portal access (file pickers, notifications)
flatpak override com.visualstudio.code --talk-name=org.freedesktop.portal.Desktop

# ✅ Remove SDK warning
flatpak override com.visualstudio.code --unset-env=FLATPAK_ENABLE_SDK_EXT

# ✅ Native file picker fix (GTK portals off)
flatpak override com.visualstudio.code --env=GTK_USE_PORTAL=0

echo "✅ Flatpak overrides applied."

# Detect user home
USER_HOME=$(eval echo ~${SUDO_USER})
if [ -n "$SUDO_USER" ]; then
  SHELL_RC="$USER_HOME/.bashrc"
  [ -f "$USER_HOME/.zshrc" ] && SHELL_RC="$USER_HOME/.zshrc"
else
  SHELL_RC="$HOME/.bashrc"
  [ -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.zshrc"
fi

# Add clean alias only if missing
if sudo -u "$SUDO_USER" grep -q "alias code=" "$SHELL_RC"; then
  echo "ℹ️  Alias 'code' already exists in $SHELL_RC. Skipping alias addition."
else
  echo "🔗 Adding clean 'code' alias to $SHELL_RC..."
  echo "" | sudo -u "$SUDO_USER" tee -a "$SHELL_RC" > /dev/null
  echo "# VS Code Flatpak alias (clean Wayland-native)" | sudo -u "$SUDO_USER" tee -a "$SHELL_RC" > /dev/null
  echo "alias code='flatpak run com.visualstudio.code'" | sudo -u "$SUDO_USER" tee -a "$SHELL_RC" > /dev/null
  echo "✅ Alias added."
fi

echo ""
echo "📦 Installing VS Code Dev Containers extension..."

sudo -u "$SUDO_USER" flatpak run com.visualstudio.code --install-extension ms-vscode-remote.remote-containers

echo ""
echo "✅ All done! Please restart your terminal or run: source $SHELL_RC"
echo "Then you'll be able to use 'code .' with Flatpak + Dev Containers + Docker + Wayland + native file picker!"
echo ""
echo "🎉 VS Code Flatpak is now ready, with Dev Containers and all features working!"
```

**Make it executable**

```bash
chmod +x setup-vscode-flatpak.sh
```

**Run the script**

```bash
./setup-vscode-flatpak.sh
```

**Then restart zsh**

```bash
source ~/.zshrc
```

**Start VS Code**

```bash
code .
```

The dot character means open in the current folder.

The script is well commented so you can figure out what it's doing.

----------------------------------------------------------------

When you start Code for the first time it will present this file - `Flatpak-warning.txt`

```text
https://www.flathub.org

------------------------------------------------------------------------------------
| Warning: You are running an unofficial Flatpak version of Visual Studio Code !!! |
------------------------------------------------------------------------------------

Please open issues under: https://github.com/flathub/com.visualstudio.code/issues


This version is running inside a container and is therefore not able
to access SDKs on your host system!

To execute commands on the host system, run inside the sandbox:

  $ host-spawn <COMMAND>

To make the Integrated Terminal automatically use the host system's shell,
you can add this to the settings:

{
  "terminal.integrated.defaultProfile.linux": "bash",
  "terminal.integrated.profiles.linux": {
    "bash": {
      "path": "host-spawn",
      "args": ["bash"]
    }
  }
}

This Flatpak provides a standard development environment (gcc, python, etc).
To see what's available:

  $ flatpak run --command=sh com.visualstudio.code
  $ ls /usr/bin (shared runtime)
  $ ls /app/bin (bundled with this flatpak)

To get support for additional languages or tools within the Flatpak, you have to install SDK extensions, e.g.

  $ flatpak install flathub org.freedesktop.Sdk.Extension.dotnet
  $ flatpak install flathub org.freedesktop.Sdk.Extension.golang
  $ FLATPAK_ENABLE_SDK_EXT=dotnet,golang flatpak run com.visualstudio.code

Similarly for shells and other tools:

  $ flatpak install com.visualstudio.code.tool.fish
  $ flatpak install com.visualstudio.code.tool.podman

You can use

  $ flatpak search <TEXT>

to find others.

```

----------------------------------------------------------------

## ✅ VS Code Flatpak — Backup & Reset Guide (Wayland Friendly)

chatGPT provided this `One-Liner` to backup all the settings and restore VS Code to factory defaults.

### 1. Run this One-Liner to Backup + Reset VS Code Flatpak

```bash
BACKUP_DIR=~/vscode-flatpak-backup-$(date +%Y%m%d-%H%M%S) && mkdir -p "$BACKUP_DIR" && flatpak run com.visualstudio.code --list-extensions > "$BACKUP_DIR/extensions.txt" && cp -r ~/.var/app/com.visualstudio.code "$BACKUP_DIR/userdata" && cat "$BACKUP_DIR/extensions.txt" | xargs -n1 flatpak run com.visualstudio.code --uninstall-extension && flatpak override --reset com.visualstudio.code && rm -rf ~/.var/app/com.visualstudio.code && echo "✅ VS Code Flatpak reset complete! 🛟 Backup saved at $BACKUP_DIR"
```

- 📦 **Backup saved in** `~/vscode-flatpak-backup-YYYYMMDD-HHMMSS`
- 🔄 **Reset**: All extensions, overrides, and user settings are wiped

---

## 🔄 Restore Later (Optional)

### 2. Restore Your VS Code User Settings

```bash
cp -r ~/vscode-flatpak-backup-*/userdata/* ~/.var/app/com.visualstudio.code/
```

### 3. Reinstall All Your Extensions

```bash
cat ~/vscode-flatpak-backup-*/extensions.txt | xargs -n1 flatpak run com.visualstudio.code --install-extension
```

---

## 🚀 Reinstall Popular Remote Extensions (Remote Pack)

### 4. Remote Pack (Dev Containers + SSH + WSL)

```bash
flatpak run com.visualstudio.code --install-extension ms-vscode-remote.remote-containers --install-extension ms-vscode-remote.remote-ssh --install-extension ms-vscode-remote.remote-wsl
```

---

## 🗑 Optional: Uninstall All Remote Extensions

```bash
flatpak run com.visualstudio.code --uninstall-extension ms-vscode-remote.remote-containers --uninstall-extension ms-vscode-remote.remote-ssh --uninstall-extension ms-vscode-remote.remote-wsl
```

---

## ✅ Check Installed Extensions

```bash
flatpak run com.visualstudio.code --list-extensions
```

---

## 🛟 Backups Folder Example

```bash
ls ~/vscode-flatpak-backup-*
```

Each backup contains:
- `extensions.txt` ➔ List of all your extensions
- `userdata/` ➔ Your VS Code settings, keybindings, state

---

## 👑 Pro Tip (Wayland users like you!)

- Always launch VS Code Flatpak using **Wayland mode**:

```bash
flatpak run com.visualstudio.code --ozone-platform-hint=auto
```

- You can alias this in your `~/.zshrc` or `~/.bashrc`:

```bash
alias code="flatpak run com.visualstudio.code --ozone-platform-hint=auto"
```
