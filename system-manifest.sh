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
#   ./system-manifest.sh <dest-dir>          e.g. /media/$USER/Data
#   ./system-manifest.sh --force <dest-dir>  allow a dest on the root disk
#
# Output: <dest-dir>/system-manifest-<host>-<date>/
# The destination is REQUIRED and must not be on the same filesystem as /,
# so the manifest is already off the disk you're about to wipe.
# ============================================================================

set -uo pipefail   # NOT -e: we want to continue past individual failures
USER="${USER:-$(id -un)}"

usage() {
  echo "usage: $0 [--force] <dest-dir>   (e.g. /media/$USER/Data)" >&2
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
# Python venvs: where each lives and which Python built it (your rebuild list)
find "$HOME" -maxdepth 6 -name pyvenv.cfg -not -path '*/.cache/*' -not -path '*/.local/share/*' \
  -exec grep -H '^version' {} \; 2>/dev/null | sort > "$OUTDIR/dev/python-venvs.txt" \
  && echo "  [ok]   python venv inventory      -> dev/python-venvs.txt"

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
sec "Network config  (netplan, bridges/VLANs, Wi-Fi/VPN profiles)"
# netplan — root-readable; captured to SENSITIVE (may embed keys)
if [ -d /etc/netplan ]; then
  sudo cp -a /etc/netplan "$OUTDIR/SENSITIVE/netplan" 2>/dev/null \
    && sudo chown -R "$USER":"$USER" "$OUTDIR/SENSITIVE/netplan" \
    && echo "  [ok]   /etc/netplan              -> SENSITIVE/netplan/"
fi
# NetworkManager keyfiles (older releases; 23.10+ stores profiles as netplan 90-NM-*.yaml)
if [ -d /etc/NetworkManager/system-connections ]; then
  sudo cp -a /etc/NetworkManager/system-connections "$OUTDIR/SENSITIVE/NM-system-connections" 2>/dev/null \
    && sudo chown -R "$USER":"$USER" "$OUTDIR/SENSITIVE/NM-system-connections" \
    && echo "  [ok]   NM system-connections      -> SENSITIVE/  (has WiFi passwords)"
fi
cap "ip addr snapshot"  "$OUTDIR/network/ip-addr.txt"   ip -br a
cap "ip route snapshot" "$OUTDIR/network/ip-route.txt"  ip route
copy "/etc/hosts"       "/etc/hosts"                    "$OUTDIR/network"

# ---------------------------------------------------------------------------
sec "APT sources + keyrings"
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
# GNOME Shell extensions — the list is the restore path (reinstall current
# versions for the new GNOME); the copied code is only a fallback.
if have gnome-extensions; then
  cap "gnome ext (all)"     "$OUTDIR/system/gnome-extensions.txt"         gnome-extensions list --user --details
  cap "gnome ext (enabled)" "$OUTDIR/system/gnome-extensions-enabled.txt" gnome-extensions list --user --enabled
fi
copy "gnome ext (code)" "$HOME/.local/share/gnome-shell/extensions" "$OUTDIR/system"
# Custom local binaries and udev rules (e.g., USB-serial console adapters)
[ -d /usr/local/bin ] && ls -la /usr/local/bin > "$OUTDIR/system/usr-local-bin.txt" 2>/dev/null
copy "udev rules" "/etc/udev/rules.d" "$OUTDIR/system"
# Fonts
copy "user fonts"  "$HOME/.local/share/fonts" "$OUTDIR/system"

# ---------------------------------------------------------------------------
sec "SSH  (keys, config, known_hosts)"
# Plain tar, permissions preserved. Lands in SENSITIVE/ — keep it off cloud drives.
if [ -d "$HOME/.ssh" ]; then
  tar czpf "$OUTDIR/SENSITIVE/ssh-keys.tgz" -C "$HOME" .ssh 2>/dev/null \
    && chmod 600 "$OUTDIR/SENSITIVE/ssh-keys.tgz" \
    && echo "  [ok]   ~/.ssh (all keys)          -> SENSITIVE/ssh-keys.tgz" \
    || echo "  [warn] ~/.ssh tarball failed — back up ~/.ssh by hand!"
  ls -la "$HOME/.ssh" > "$OUTDIR/SENSITIVE/ssh-listing.txt" 2>/dev/null
  # Warn about keys referenced from outside ~/.ssh (the tarball won't have them)
  grep -iE '^\s*IdentityFile' "$HOME/.ssh/config" 2>/dev/null | grep -v '\.ssh/' \
    && echo "  !! IdentityFile entries above point OUTSIDE ~/.ssh — copy those keys by hand."
else
  echo "  [skip] ~/.ssh                       (not found)"
fi

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

  # Total footprint so you know it fits on the backup disk before you start
  if [ -s "$OUTDIR/kvm/disk-copy-list.txt" ]; then
    total=$(xargs -d '\n' sudo du -ch < "$OUTDIR/kvm/disk-copy-list.txt" 2>/dev/null | tail -1 | cut -f1)
    echo "  >> Total VM disk data to copy off: ${total:-unknown}"
  fi

  # Ready-to-run helper that copies every image (chain included) to a target dir
  cat > "$OUTDIR/kvm/copy-vm-disks.sh" <<'CPEOF'
#!/usr/bin/env bash
# Copy all VM disk images (including backing files) off before you wipe.
# Usage: sudo ./copy-vm-disks.sh <backup-dir>/vm-images
# Shut the VMs down first. Verify afterwards with: qemu-img check <copy>
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
# Reinstall quick reference  (full steps: the Nuke & Pave runbook)

    M=<this folder>

1. APT packages (review first; some may be renamed in the new release)
       xargs -a $M/packages/apt-manual.txt sudo apt install -y
2. Homebrew
       brew bundle install --file=$M/packages/Brewfile
3. VS Code extensions
       while read -r ext; do code --install-extension "$ext"; done < $M/dev/vscode-extensions.txt
4. SSH keys
       tar xzpf $M/SENSITIVE/ssh-keys.tgz -C ~
5. Groups (see system/groups.txt), then log out/in
       sudo usermod -aG libvirt,kvm,dialout,wireshark $USER
6. NetworkManager profiles are netplan files: SENSITIVE/netplan/90-NM-*.yaml
       sudo cp $M/SENSITIVE/netplan/90-NM-*.yaml /etc/netplan/
       sudo chmod 600 /etc/netplan/90-NM-*.yaml && sudo netplan generate
   Don't blind-copy the other netplan files; compare with the fresh defaults.
7. udev rules: copy custom ones from system/rules.d/, then
       sudo udevadm control --reload
8. GNOME extensions: reinstall from system/gnome-extensions-enabled.txt,
   then:  dconf load /org/gnome/shell/extensions/ < <section of system/dconf-dump.ini>
9. APT sources: reference only (codename changes). Re-add third-party repos.
10. libvirt: copy qcow2 images back, then
       sudo virsh define $M/kvm/<vm>.xml
NOTES
echo "  [ok]   REINSTALL-NOTES.md"

# ---------------------------------------------------------------------------
sec "Done"
SIZE=$(du -sh "$OUTDIR" 2>/dev/null | cut -f1)
cat <<EOF

Manifest complete: $OUTDIR  ($SIZE)

  SENSITIVE/  holds WiFi PSKs, ssh keys and ssh config.
              Keep it off cloud drives.

Already written to $DEST — nothing to copy off.
Still to do before the wipe: copy the VM disks (kvm/copy-vm-disks.sh) and
check them, then verify the ssh tarball:  tar tzvf SENSITIVE/ssh-keys.tgz
EOF
