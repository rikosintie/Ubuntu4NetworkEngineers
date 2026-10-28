# 1S1K-G5 Nuke & Pave Runbook (25.04 → 26.04)

Oct 28, 2026 · @Mike

## Overview

This runbook takes `1S1K-G5` from Ubuntu 25.04 to a clean 26.04 install on the 2TB drive without losing any tools, configs, or VMs. It comes from the August 2026 planning chat, with the script revisions merged into one final version (Appendix).

- **Rebuild path:** `system-manifest.sh` captures what you installed and configured, and you reinstall from that checklist.
- **Rollback path:** a fresh Clonezilla image of 25.04. You only restore it if 26.04 goes badly.
- **Backup target:** the 1TB Samsung NVMe at `/media/mhubbard/Backup`. Everything that must survive goes here before the wipe.

The script requires a destination and refuses any path on the root filesystem, so the manifest lands directly on the 1TB. There's no copy-off step to forget.

## Phase 1 — Run the manifest and get it off the drive

Run the script as your normal user, not with sudo. brew, gh, and code need user context, and the script calls sudo itself for `/etc` reads and `virsh`.

1. Mount the backup drive and check free space and filesystem type:

   ```bash
   df -h / /media/mhubbard/Backup
   findmnt -no FSTYPE --target /media/mhubbard/Backup
   ```

2. Save the Appendix script as `~/system-manifest.sh`, then run it with the backup drive as the destination:

   ```bash
   chmod +x ~/system-manifest.sh
   shellcheck ~/system-manifest.sh   # should be clean
   ~/system-manifest.sh /media/mhubbard/Backup
   ```

   The script exits with an error if the destination is missing, isn't writable, or sits on the root disk. If the drive is NTFS or exFAT, it warns that Linux permissions won't be kept.
3. Review every `[skip]` line. A skip can mean a tool isn't present, or that something worth grabbing by hand was missed.
4. Back up your SSH private keys yourself. The script does not copy `~/.ssh/id_*`. Use an encrypted tarball and keep it on the 1TB:

   ```bash
   tar czf - -C ~ .ssh | gpg -c -o /media/mhubbard/Backup/ssh-keys.tgz.gpg
   ```

Keep `SENSITIVE/` off Insync and Google Drive. It holds customer Wi-Fi PSKs from the NetworkManager connections, plus your netplan and ssh config.

## Phase 2 — Copy the KVM VM disks

The VM XML is small and is already in the manifest. The qcow2 disks are large and live on the 2TB, so they need a separate copy. The script walks each disk's backing chain, so an overlay never gets separated from its base.

1. Check sizes and the total against the 1TB's free space:

   ```bash
   cat /media/mhubbard/Backup/system-manifest-1S1K-G5-*/kvm/disk-images.txt
   ```
2. Shut down every running VM. Copying a running VM gives you an inconsistent disk:

   ```bash
   sudo virsh list --all
   sudo virsh shutdown <vm>
   ```
3. Run the generated helper. It uses `rsync --sparse`, so qcow2 files don't balloon:

   ```bash
   sudo /media/mhubbard/Backup/system-manifest-1S1K-G5-*/kvm/copy-vm-disks.sh /media/mhubbard/Backup/vm-images
   ```
4. Confirm every file listed in `kvm/disk-copy-list.txt` is in `vm-images/`, including any `~base` images.

## Phase 3 — Final checks before the wipe

Don't boot the installer until every box is ticked.

- [ ] Manifest folder is on `/media/mhubbard/Data` and opens there
- [ ] Encrypted SSH key tarball is on the 1TB
- [ ] VM disk images are copied, with the backing chains included
- [ ] Any data in `$HOME` that isn't synced by Insync or Git is copied, such as repos with unpushed work (see `dev/local-git-repos.txt`)
- [ ] Fresh Clonezilla image of 25.04 is on the 1TB. This is the rollback; the last G5 image was from June 2025.
- [ ] 26.04 installer USB is made and boots
- [ ] Unmount the 1TB, or physically disconnect it, so the installer can't touch it

## Phase 4 — Install 26.04

This is a clean install rather than an upgrade, which avoids dracut problems and the stale apt state from before.

1. Boot the 26.04 USB and pick the **2TB** as the install target. Check the model and size in the installer before you confirm.
2. Use the same username, `mhubbard`. Paths in your zsh configs and the copy helper assume it.
3. Keep the hostname `1S1K-G5`.
4. Finish the install, then run a full update before restoring anything:

   ```bash
   sudo apt update && sudo apt full-upgrade -y
   ```

## Phase 5 — Restore

Work from the manifest copy on the 1TB, in this order. Set `M` once per shell:

```bash
M=$(ls -d /media/mhubbard/Backup/system-manifest-1S1K-G5-* | tail -1)
```

1. **APT sources and keys (reference only).** The 26.04 `ubuntu.sources` codename is different, so don't copy files over. Re-add the third-party repos one at a time from `$M/system/apt-sources.list.d/`: vscode (with keyring), termius, gierens, insync, chrome, solaar.
2. **APT packages.** Review the list first, because some packages may be 25.04-only or renamed:

   ```bash
   less $M/packages/apt-manual.txt
   xargs -a $M/packages/apt-manual.txt sudo apt install -y
   ```

3. **Homebrew:**

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   brew bundle install --file=$M/packages/Brewfile
   ```

4. **pipx, cargo, npm.** Reinstall from `$M/packages/pipx.txt`, `cargo.txt`, and `npm-global.txt`.
5. **VS Code extensions:**

   ```bash
   while read -r ext; do code --install-extension "$ext"; done < $M/dev/vscode-extensions.txt
   ```

6. **Git and gh.** Copy `.gitconfig` and `.gitignore` back from `$M/dev/`, run `gh auth login`, then reinstall the extensions listed in `gh-extensions.txt`.

7. **SSH.** Decrypt the key tarball to `~/.ssh`. Restore `config` and `known_hosts` from `$M/SENSITIVE/`, then fix permissions:

   ```bash
   chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_* ~/.ssh/config
   ```

8. **Shell.** Copy `.zshrc`, `.zsh_history`, oh-my-zsh `custom/`, and `.tmux.conf` from `$M/shell/`. Check for absolute paths that assumed 25.04, then open a new shell.

9. **Groups.** Log out and back in afterwards. `dialout` is what lets you use the serial console to Cisco gear:

   ```bash
   sudo usermod -aG libvirt,kvm,dialout,wireshark $USER
   ```

10. **Network.** Don't copy the old netplan onto 26.04 blind. Compare `$M/SENSITIVE/netplan` against the fresh default before rebuilding br0 on enp60s0 and the VLANs. Restore Wi-Fi profiles:

    ```bash
    sudo cp $M/SENSITIVE/NM-system-connections/*.nmconnection /etc/NetworkManager/system-connections/
    sudo chown root:root /etc/NetworkManager/system-connections/*
    sudo chmod 600 /etc/NetworkManager/system-connections/*
    sudo nmcli connection reload
    ```

11. **Desktop settings (optional).** Restore selectively with `dconf load`. Loading the whole dump at once can bring back stale 25.04 keys.
12. **VMs.** Copy the disk images back to their original paths (see `kvm/disk-images.txt`) first, then:

    ```bash
    sudo virsh define $M/kvm/<vm>.xml
    sudo virsh net-define $M/kvm/net-<name>.xml   # for any non-default networks
    ```

13. **Check against the manifest.** Compare `$M/system/systemd-*.txt`, `crontab-user.txt`, `usr-local-bin.txt`, and `udev-rules.txt` with the new system.

## Appendix — Final system-manifest.sh

Save as `~/system-manifest.sh` and run `~/system-manifest.sh /media/mhubbard/Backup`. It requires a destination and refuses the root disk.

```bash
#!/usr/bin/env bash
# ============================================================================
# system-manifest.sh
# Capture a full tool + config inventory before an OS reinstall, so you can
# rebuild your environment from a checklist instead of memory.
#
# Run as your NORMAL USER (not sudo) — brew/code/gh must run in user context.
# The script calls sudo itself only for the few system files that need it.
#
# Usage:
#   chmod +x system-manifest.sh
#   ./system-manifest.sh <dest-dir>          e.g. /media/mhubbard/Backup
#   ./system-manifest.sh --force <dest-dir>  allow a dest on the root disk
#
# Output: <dest-dir>/system-manifest-<host>-<date>/
# The destination is REQUIRED and must not be on the same filesystem as /,
# so the manifest is already off the disk you're about to wipe.
# ============================================================================

set -uo pipefail   # NOT -e: we want to continue past individual failures
USER="${USER:-$(id -un)}"

usage() {
  echo "usage: $0 [--force] <dest-dir>   (e.g. /media/mhubbard/Backup)" >&2
  exit 2
}

FORCE=0
if [ "${1:-}" = "--force" ]; then FORCE=1; shift; fi
[ $# -eq 1 ] || usage
DEST="${1%/}"

if [ ! -d "$DEST" ]; then
  echo "ERROR: $DEST does not exist or isn't mounted." >&2
  exit 1
fi
if [ ! -w "$DEST" ]; then
  echo "ERROR: $DEST is not writable by $USER." >&2
  exit 1
fi
# Refuse a destination on the same filesystem as / (the disk you're wiping)
root_dev=$(findmnt -n -o SOURCE --target / 2>/dev/null)
dest_dev=$(findmnt -n -o SOURCE --target "$DEST" 2>/dev/null)
if [ -n "$root_dev" ] && [ "$root_dev" = "$dest_dev" ] && [ "$FORCE" -eq 0 ]; then
  echo "ERROR: $DEST is on the root filesystem ($root_dev) — the disk you're about to wipe." >&2
  echo "       Pick a path on the backup drive, or use --force if you really mean it." >&2
  exit 1
fi

# Warn if the destination can't hold Linux permissions/ownership
dest_fs=$(findmnt -n -o FSTYPE --target "$DEST" 2>/dev/null)
case "$dest_fs" in
  ntfs|ntfs3|fuseblk|exfat|vfat|msdos)
    echo "WARNING: $DEST is $dest_fs — Linux permissions and ownership won't stick." >&2
    echo "         SENSITIVE/ will NOT be locked to 700, and some copies may report [warn]." >&2
    ;;
esac

OUTDIR="$DEST/system-manifest-$(hostname)-$(date +%Y-%m-%d)"
mkdir -p "$OUTDIR"/{packages,dev,shell,network,system,kvm,SENSITIVE} || {
  echo "ERROR: could not create $OUTDIR" >&2; exit 1; }
chmod 700 "$OUTDIR/SENSITIVE"

have() { command -v "$1" >/dev/null 2>&1; }
sec()  { printf '\n\033[1;36m=== %s ===\033[0m\n' "$1"; }
cap()  { # cap <label> <outfile> <command...>
  local label="$1" out="$2"; shift 2
  if "$@" >"$out" 2>/dev/null; then
    printf '  [ok]   %-28s -> %s\n' "$label" "${out#"$OUTDIR"/}"
  else
    printf '  [skip] %-28s (not present / no output)\n' "$label"
    rm -f "$out"
  fi
}
copy() { # copy <label> <src> <destdir>
  local label="$1" src="$2" dest="$3"
  if [ -e "$src" ]; then
    cp -a "$src" "$dest"/ 2>/dev/null \
      && printf '  [ok]   %-28s -> %s\n' "$label" "${dest#"$OUTDIR"/}/" \
      || printf '  [warn] %-28s (copy failed)\n' "$label"
  else
    printf '  [skip] %-28s (not found)\n' "$label"
  fi
}

echo "Writing manifest to: $OUTDIR"

# ---------------------------------------------------------------------------
sec "Package managers"
# apt: MANUALLY installed only — this is your rebuild list (covers nala too)
cap "apt manual packages"   "$OUTDIR/packages/apt-manual.txt"        apt-mark showmanual
cap "dpkg full (reference)" "$OUTDIR/packages/dpkg-full.txt"         dpkg -l
cap "apt auto-installed"    "$OUTDIR/packages/apt-auto.txt"          apt-mark showauto
have nala    && cap "nala history"      "$OUTDIR/packages/nala-history.txt"  nala history
have snap    && cap "snap packages"     "$OUTDIR/packages/snap.txt"          snap list
have flatpak && cap "flatpak apps"      "$OUTDIR/packages/flatpak.txt"       flatpak list --app --columns=application,name

# Homebrew — Brewfile is the one-shot restore artifact
if have brew; then
  brew bundle dump --force --file="$OUTDIR/packages/Brewfile" >/dev/null 2>&1 \
    && echo "  [ok]   Brewfile (taps+formulae+casks) -> packages/Brewfile"
  cap "brew leaves (top-level)" "$OUTDIR/packages/brew-leaves.txt" brew leaves --installed-on-request
fi

# Language/dev package managers
have pipx  && cap "pipx apps"        "$OUTDIR/packages/pipx.txt"        pipx list
have pip   && cap "pip (system)"     "$OUTDIR/packages/pip-freeze.txt"  pip freeze
have pip3  && cap "pip3 (system)"    "$OUTDIR/packages/pip3-freeze.txt" pip3 freeze
have cargo && cap "cargo installed"  "$OUTDIR/packages/cargo.txt"       cargo install --list
have npm   && cap "npm global"       "$OUTDIR/packages/npm-global.txt"  npm ls -g --depth=0
have go    && cap "go version"       "$OUTDIR/packages/go-version.txt"  go version

# ---------------------------------------------------------------------------
sec "Dev tooling"
have code && cap "VS Code extensions" "$OUTDIR/dev/vscode-extensions.txt" code --list-extensions
if have gh; then
  cap "gh extensions"  "$OUTDIR/dev/gh-extensions.txt" gh extension list
  cap "gh auth status" "$OUTDIR/dev/gh-auth.txt"       gh auth status
  cap "gh own repos"   "$OUTDIR/dev/gh-repos.txt"      gh repo list --limit 200
fi
copy "git global config" "$HOME/.gitconfig"     "$OUTDIR/dev"
copy "git ignore global" "$HOME/.gitignore"     "$OUTDIR/dev"
# Find local git repos (working copies you'll want to re-clone or re-sync)
find "$HOME" -maxdepth 5 -type d -name .git 2>/dev/null \
  | sed 's|/.git$||' > "$OUTDIR/dev/local-git-repos.txt" \
  && echo "  [ok]   local git repos            -> dev/local-git-repos.txt"

# ---------------------------------------------------------------------------
sec "Shell / zsh"
for f in .zshrc .zshenv .zprofile .zlogin .p10k.zsh .aliases .functions; do
  copy "$f" "$HOME/$f" "$OUTDIR/shell"
done
copy "zsh history"    "$HOME/.zsh_history"        "$OUTDIR/shell"
copy "oh-my-zsh custom" "$HOME/.oh-my-zsh/custom" "$OUTDIR/shell"
[ -d "$HOME/.config/zsh" ] && copy ".config/zsh" "$HOME/.config/zsh" "$OUTDIR/shell"
copy "tmux.conf"      "$HOME/.tmux.conf"          "$OUTDIR/shell"
# Snapshot resolved aliases/functions as readable reference
if [ -n "${ZSH_VERSION:-}" ] || have zsh; then
  zsh -ic 'alias' 2>/dev/null > "$OUTDIR/shell/aliases-resolved.txt" || true
fi

# ---------------------------------------------------------------------------
sec "Network config  (br0 / VLANs / customer WiFi)"
# netplan — root-readable; captured to SENSITIVE (may embed keys)
if [ -d /etc/netplan ]; then
  sudo cp -a /etc/netplan "$OUTDIR/SENSITIVE/netplan" 2>/dev/null \
    && sudo chown -R "$USER":"$USER" "$OUTDIR/SENSITIVE/netplan" \
    && echo "  [ok]   /etc/netplan              -> SENSITIVE/netplan/"
fi
# NetworkManager system connections — CONTAIN WiFi PSKs
if [ -d /etc/NetworkManager/system-connections ]; then
  sudo cp -a /etc/NetworkManager/system-connections "$OUTDIR/SENSITIVE/NM-system-connections" 2>/dev/null \
    && sudo chown -R "$USER":"$USER" "$OUTDIR/SENSITIVE/NM-system-connections" \
    && echo "  [ok]   NM system-connections      -> SENSITIVE/  (has WiFi passwords)"
fi
cap "ip addr snapshot"  "$OUTDIR/network/ip-addr.txt"   ip -br a
cap "ip route snapshot" "$OUTDIR/network/ip-route.txt"  ip route
copy "/etc/hosts"       "/etc/hosts"                    "$OUTDIR/network"

# ---------------------------------------------------------------------------
sec "APT sources + keyrings  (your cleaned config)"
sudo cp -a /etc/apt/sources.list.d "$OUTDIR/system/apt-sources.list.d" 2>/dev/null \
  && sudo chown -R "$USER":"$USER" "$OUTDIR/system/apt-sources.list.d" \
  && echo "  [ok]   /etc/apt/sources.list.d    -> system/apt-sources.list.d/"
sudo cp -a /etc/apt/keyrings "$OUTDIR/system/apt-keyrings" 2>/dev/null \
  && sudo chown -R "$USER":"$USER" "$OUTDIR/system/apt-keyrings" \
  && echo "  [ok]   /etc/apt/keyrings          -> system/apt-keyrings/"
[ -d /etc/apt/preferences.d ] && sudo cp -a /etc/apt/preferences.d "$OUTDIR/system/apt-preferences.d" 2>/dev/null \
  && sudo chown -R "$USER":"$USER" "$OUTDIR/system/apt-preferences.d"

# ---------------------------------------------------------------------------
sec "System state"
cap "groups (id)"          "$OUTDIR/system/groups.txt"          id
cap "crontab (user)"       "$OUTDIR/system/crontab-user.txt"    crontab -l
cap "enabled user units"   "$OUTDIR/system/systemd-user.txt"    systemctl --user list-unit-files --state=enabled
cap "enabled sys units"    "$OUTDIR/system/systemd-system.txt"  systemctl list-unit-files --state=enabled
cap "default target"       "$OUTDIR/system/systemd-target.txt"  systemctl get-default
cap "timezone/locale"      "$OUTDIR/system/locale.txt"          localectl status
cap "foreign arches"       "$OUTDIR/system/dpkg-arches.txt"     dpkg --print-foreign-architectures
# Desktop settings
have dconf && dconf dump / > "$OUTDIR/system/dconf-dump.ini" 2>/dev/null \
  && echo "  [ok]   dconf (GNOME settings)     -> system/dconf-dump.ini"
# Custom local binaries and udev rules you may have added
[ -d /usr/local/bin ] && ls -la /usr/local/bin > "$OUTDIR/system/usr-local-bin.txt" 2>/dev/null
sudo ls -la /etc/udev/rules.d 2>/dev/null > "$OUTDIR/system/udev-rules.txt"
# Fonts
copy "user fonts"  "$HOME/.local/share/fonts" "$OUTDIR/system"

# ---------------------------------------------------------------------------
sec "SSH config  (legacy Cisco kex etc.)"
copy "ssh config"      "$HOME/.ssh/config"      "$OUTDIR/SENSITIVE"
copy "ssh known_hosts" "$HOME/.ssh/known_hosts" "$OUTDIR/SENSITIVE"
echo "  note: private keys NOT auto-copied. Handle ~/.ssh/id_* yourself, encrypted."

# ---------------------------------------------------------------------------
sec "KVM / libvirt  (VM definitions + disk image paths)"
# sudo so we hit qemu:///system where your VMs live. Plain user virsh talks to
# qemu:///session and would list NONE of your system VMs.
VIRSH="sudo virsh"
if have virsh; then
  $VIRSH list --all > "$OUTDIR/kvm/vms.txt" 2>/dev/null && echo "  [ok]   VM list -> kvm/vms.txt"

  : > "$OUTDIR/kvm/disk-copy-list.txt"
  printf '%-28s %-12s %-9s %s\n' "VM" "TARGET" "SIZE" "SOURCE (chain member)" \
    > "$OUTDIR/kvm/disk-images.txt"

  for vm in $($VIRSH list --all --name 2>/dev/null); do
    [ -n "$vm" ] || continue
    $VIRSH dumpxml "$vm" > "$OUTDIR/kvm/$vm.xml" 2>/dev/null && echo "  [ok]   dumpxml $vm"

    # file-backed disks only (skip cdroms and empty slots)
    $VIRSH domblklist "$vm" --details 2>/dev/null \
      | awk 'NR>2 && $1=="file" && $2=="disk" && $4!="-" {print $3" "$4}' \
      | while read -r target src; do
          [ -n "$src" ] || continue
          # Walk the backing chain so an overlay image never gets
          # separated from its base — copying only the overlay = dead VM.
          members=""
          if have qemu-img; then
            members=$(sudo qemu-img info --backing-chain "$src" 2>/dev/null \
                       | awk -F': ' '/^image:/{print $2}')
          fi
          [ -n "$members" ] || members="$src"
          n=0
          while read -r member; do
            [ -n "$member" ] || continue
            sz=$(sudo du -h "$member" 2>/dev/null | cut -f1)
            tag="$target"; [ "$n" -gt 0 ] && tag="$target~base$n"
            printf '%-28s %-12s %-9s %s\n' "$vm" "$tag" "${sz:-?}" "$member" \
              >> "$OUTDIR/kvm/disk-images.txt"
            echo "$member" >> "$OUTDIR/kvm/disk-copy-list.txt"
            n=$((n+1))
          done <<< "$members"
        done
  done

  # De-dup shared backing files across VMs
  sort -u "$OUTDIR/kvm/disk-copy-list.txt" -o "$OUTDIR/kvm/disk-copy-list.txt"
  echo "  [ok]   disk image report -> kvm/disk-images.txt"
  echo "  [ok]   copy list         -> kvm/disk-copy-list.txt"

  # libvirt networks
  $VIRSH net-list --all > "$OUTDIR/kvm/networks.txt" 2>/dev/null
  for net in $($VIRSH net-list --all --name 2>/dev/null); do
    [ -n "$net" ] && $VIRSH net-dumpxml "$net" > "$OUTDIR/kvm/net-$net.xml" 2>/dev/null
  done

  # Total footprint so you know if it fits on the 1TB before you start
  if [ -s "$OUTDIR/kvm/disk-copy-list.txt" ]; then
    total=$(xargs -d '\n' sudo du -ch < "$OUTDIR/kvm/disk-copy-list.txt" 2>/dev/null | tail -1 | cut -f1)
    echo "  >> Total VM disk data to copy off: ${total:-unknown}"
  fi

  # Ready-to-run helper that copies every image (chain included) to a target dir
  cat > "$OUTDIR/kvm/copy-vm-disks.sh" <<'CPEOF'
#!/usr/bin/env bash
# Copy all VM disk images (including backing files) off before you wipe.
# Usage: sudo ./copy-vm-disks.sh /media/mhubbard/Backup/vm-images
set -euo pipefail
DEST="${1:?usage: copy-vm-disks.sh <dest-dir>}"
mkdir -p "$DEST"
LIST="$(dirname "$0")/disk-copy-list.txt"
while read -r img; do
  [ -n "$img" ] || continue
  echo ">> $img"
  rsync -ah --info=progress2 --sparse "$img" "$DEST/"
done < "$LIST"
echo "Done -> $DEST"; ls -lh "$DEST"
CPEOF
  chmod +x "$OUTDIR/kvm/copy-vm-disks.sh"
  echo "  [ok]   copy helper       -> kvm/copy-vm-disks.sh"
  echo "  !! Disk images live on the drive you will wipe. Run:"
  echo "        sudo $OUTDIR/kvm/copy-vm-disks.sh $DEST/vm-images"
fi

# ---------------------------------------------------------------------------
sec "Writing reinstall notes"
cat > "$OUTDIR/REINSTALL-NOTES.md" <<'NOTES'
# Reinstall checklist  (26.04)

## 1. APT packages you asked for
    xargs -a packages/apt-manual.txt sudo apt install -y
Review the list first — some may be 25.04-only or renamed on 26.04.

## 2. Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew bundle install --file=packages/Brewfile

## 3. VS Code extensions
    while read -r ext; do code --install-extension "$ext"; done < dev/vscode-extensions.txt

## 4. pipx CLI tools  (see packages/pipx.txt)
    pipx install <each>

## 5. Shell — copy back .zshrc etc. from shell/, then re-source.
   Re-check any absolute paths that assumed 25.04.

## 6. Groups — re-add yourself (see system/groups.txt). Likely:
    sudo usermod -aG libvirt,kvm,dialout,wireshark $USER
   (dialout = serial console to Cisco gear — easy to forget)

## 7. Network — DO NOT blind-copy 25.04 netplan onto 26.04.
   Review SENSITIVE/netplan against a fresh 26.04 default before applying.
   Customer WiFi: SENSITIVE/NM-system-connections/*.nmconnection ->
   /etc/NetworkManager/system-connections/  (chmod 600, chown root:root).

## 8. APT sources — reference only. On 26.04 the ubuntu.sources codename
   differs. Re-add third-party repos from system/apt-sources.list.d/.

## 9. libvirt VMs — redefine from kvm/*.xml AFTER copying qcow2 images back:
    sudo virsh define kvm/<vm>.xml
NOTES
echo "  [ok]   REINSTALL-NOTES.md"

# ---------------------------------------------------------------------------
sec "Done"
SIZE=$(du -sh "$OUTDIR" 2>/dev/null | cut -f1)
cat <<EOF

Manifest complete: $OUTDIR  ($SIZE)

  SENSITIVE/  holds WiFi PSKs and ssh config — treat accordingly.
              Do NOT sync to cloud unless you're OK with that.

Already written to $DEST — nothing to copy off.
Still to do before the wipe: VM disks (kvm/copy-vm-disks.sh) and your
encrypted ~/.ssh key tarball.
EOF
```
