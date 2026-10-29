# Ubuntu Nuke & Pave Runbook (25.04 → 26.10)

## Overview

This runbook takes a device from Ubuntu 25.04 to a clean 26.10 install on the same drive without losing any tools, configs, or VMs. This is commonly referred to as a "Nuke & Pave" because the old Operating system is destroyed (Nuked) before the new Operating system is installed (Disk is Paved).

- **Rebuild path:** `system-manifest.sh` (Appendix) records what you installed and configured, and you reinstall from that checklist.
- **Rollback path:** a verified Clonezilla image of the old system. You only restore it if the new install goes badly.
- **Your files:** a straight copy of your home directory and VM disks to a separate disk.

Work through the phases in order, and don't start Phase 6 until every box in Phase 5 is ticked. If this is a machine you can't afford to have down, rehearse the restore on a spare machine first (see the Rehearsal section after Phase 5).

**Set these once per terminal.** Every command below uses them:

```bash
BACKUP=/media/$USER/<backup-drive>   # a separate disk, NOT the one you're wiping
HOMECOPY=/media/$USER/<home-copy-drive>/home-$USER
```

26.10 is an interim release with 9 months of support. Future 6-month upgrades can be done in place with `do-release-upgrade`. With the partition layout in Phase 6, a future clean install only needs the system partition formatted.

## Before you start — know your disks

Everything you keep must end up on a disk other than the one you're wiping. Identify every disk by **model and size**, never by device name, because names like `sdb`/`sdc` change between boots and machines.

```bash
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,MODEL
df -h | grep -v tmpfs
```

Write down the role of each disk:

| Role | What goes there | Notes |
| --- | --- | --- |
| OS disk | Gets wiped | The one mounted at `/` |
| Clonezilla drive | Rollback image | External USB is fine; NTFS/exFAT is fine for images |
| Backup disk (`$BACKUP`) | Manifest, SSH keys, VM disks | Should be **ext4**, so Linux permissions survive |
| Home-copy disk (`$HOMECOPY`) | Copy of your home directory | Can be the same as `$BACKUP` if there's room |

Check that a backup disk is ext4 with `findmnt -no FSTYPE --target "$BACKUP"`. A `lost+found` folder at its root is also a giveaway.

A disk mounted under `/media/$USER/` with no `/etc/fstab` entry is automounted by GNOME. It will automount the same way after the reinstall, so there's nothing to restore for it.

## Phase 1 — Make and verify the Clonezilla rollback image

An unverified image isn't a rollback. A clean save log only proves the image was written; Clonezilla's restorable check proves it can be read back. These steps work for any Clonezilla backup.

1. Take a full-disk image of the OS disk with Clonezilla live (**device-image → savedisk**). At the end, choose **reboot** or **cmd**, not poweroff, so you can read the final messages.
2. Read the save log. In the image folder on the Clonezilla drive:

    ```bash
    IMG=/media/$USER/<clonezilla-drive>/<image-folder>
    grep -iE 'restorable|succe|fail|error' "$IMG"/clonezilla-img
    ```

    You want `Partclone successfully cloned` for every partition and `The operation has completed successfully`. The `If this action fails or hangs, check:` lines are boilerplate.

3. If there are no `restorable` lines, the post-save check didn't run. Run it now. Boot Clonezilla live (any machine works, because the check only reads the image), then **device-image → local_dev**. Pick the Clonezilla drive by size and model, browse to the image folder, then **Beginner → chk-img-restorable** and select the image. It reads the entire image, which takes about 2.5 hours for ~300G over USB-C.
4. Confirm the final message says the check completed successfully.

Don't verify with Ubuntu's `partclone.chkimg`. Images made by a newer Clonezilla use a checksum format that Ubuntu's older partclone can't read. It fails with `Unknown checksum mode`, which says nothing about the image itself. `Info-packages.txt` in the image folder shows which partclone version wrote it.

If a machine won't boot the stick, use its one-time boot menu (F9 on HP, F12 on Dell/Lenovo) and pick the **UEFI** entry for the USB stick.

## Phase 2 — Run the manifest

The script writes straight to `$BACKUP` and refuses any path on the root disk, so there's no copy-off step to forget. Run it as your normal user. It calls sudo itself where it needs to.

1. Save the Appendix script as `~/system-manifest.sh`, then lint and run it:

    ```bash
    chmod +x ~/system-manifest.sh
    shellcheck ~/system-manifest.sh
    ~/system-manifest.sh "$BACKUP"
    ```

2. Read every `[skip]` and `[warn]` line. A skip can mean a tool isn't installed, or something you should grab by hand. A `!!` line about `IdentityFile` means some SSH keys live outside `~/.ssh`. Copy those yourself.
3. Point `M` at the new manifest folder:

    ```bash
    M=$(ls -d "$BACKUP"/system-manifest-$(hostname)-* | tail -1); echo "$M"
    ```

4. Verify that every SSH key is in the tarball. This is your only copy outside the image, so look for each `id_*` file:

    ```bash
    tar tzvf "$M/SENSITIVE/ssh-keys.tgz"
    ```

    Copy the tarball to a second drive as well.

5. Verify the network profiles. On Ubuntu 23.10 and later, NetworkManager saves connections as netplan files named `90-NM-<uuid>.yaml`, so an empty `NetworkManager/system-connections` folder is normal:

    ```bash
    sudo diff -r /etc/netplan "$M/SENSITIVE/netplan" && echo "netplan OK"
    ls "$M/SENSITIVE/netplan" | grep -c '^90-NM-'   # ≈ number of Wi-Fi/VPN profiles
    ```

Keep `SENSITIVE/` off cloud drives. It holds Wi-Fi passwords, SSH keys and your SSH config.

The manifest also writes `dev/python-venvs.txt`, a list of every Python venv and the version that built it. Phase 8 uses it.

## Phase 3 — Copy your home directory

The manifest records configs, not your files. Pictures, Documents, Downloads and everything else need a straight copy. Copy the whole home directory and exclude only what you can regenerate. Picking folders one by one is how things get missed.

1. See what's big, hidden folders included. In zsh:

    ```bash
    du -sh ~/*(D) 2>/dev/null | sort -h | tail -25
    ```

    In bash, use `du -sh ~/* ~/.[!.]* 2>/dev/null | sort -h | tail -25`.

2. Decide what to exclude. Typical candidates:

    | Exclude | Why |
    | --- | --- |
    | `.cache` | Rebuilds itself |
    | Search indexes (e.g. `.recoll`) | The indexer rebuilds them |
    | Cloud-sync folders (Google Drive, Dropbox clients) | Resync after install, but only if 100% synced |

3. Copy, preserving permissions, hard links, ACLs and extended attributes. The destination must be ext4/btrfs/xfs for `-AX`:

    ```bash
    rsync -aHAX --info=progress2 \
      --exclude='.cache/' --exclude='.recoll/' --exclude='<cloud-folder>/' \
      ~/ "$HOMECOPY"/
    ```

    The trailing slash on `~/` matters. Without it you get `home-$USER/$USER/...`.

4. Verify with a dry run. Only files changed since the copy should show up:

    ```bash
    rsync -aHAXn --itemize-changes \
      --exclude='.cache/' --exclude='.recoll/' --exclude='<cloud-folder>/' \
      ~/ "$HOMECOPY"/ | head -20
    ```

## Phase 4 — Copy and check the VM disks

By default, libvirt keeps VM disks in `/var/lib/libvirt/images/`, on the disk you're wiping. The manifest saved each VM's XML definition, but the qcow2 files need their own copy.

1. Check where the disks live and how big they are:

    ```bash
    for vm in $(sudo virsh list --all --name); do echo "== $vm"; sudo virsh domblklist "$vm"; done
    cat "$M/kvm/disk-images.txt"
    ```

2. Shut down every VM. Copying a running VM gives you an inconsistent disk:

    ```bash
    sudo virsh list --all
    sudo virsh shutdown <vm>
    ```

3. Copy them with the helper the manifest generated. It includes backing files and uses `rsync --sparse`:

    ```bash
    sudo "$M/kvm/copy-vm-disks.sh" "$BACKUP/vm-images"
    ```

4. Check each copy. You want `No errors were found on the image.` for every disk:

    ```bash
    sudo sh -c 'for f in '"$BACKUP"'/vm-images/*.qcow2; do echo "== $f"; qemu-img check "$f"; done'
    ```

    rsync already verifies a whole-file checksum on every transfer. For a byte-for-byte comparison anyway, run `sudo qemu-img compare -p <original> <copy>`. It reads both images in full, which takes several minutes per 100G.

## Phase 5 — Final checks before the wipe

Don't boot the installer until every box is ticked.

- [ ] Clonezilla image passed **chk-img-restorable**
- [ ] Manifest is on `$BACKUP`, with no unexplained `[skip]`/`[warn]` lines
- [ ] SSH tarball lists every key, and a second copy exists
- [ ] Netplan backup matches `/etc/netplan` and contains the `90-NM-*` profiles
- [ ] Home directory copied and the dry run is clean
- [ ] VM disks copied and `qemu-img check` is clean on each
- [ ] Local git repos with unpushed work are pushed or copied (see `$M/dev/local-git-repos.txt`)
- [ ] 26.10 installer USB is written and its ISO checksum verified (Phase 6)
- [ ] You know which disk is the OS disk by **model and size**

## Rehearsal (optional) — restore onto a spare machine first

A spare machine with a fresh Ubuntu install lets you run Phases 7 and 8 for real while your working machine stays untouched. Problems show up on the spare, not the night before a job. The same release or one close to it is fine for the rehearsal.

1. **Make the backups reachable.** If `$BACKUP` is an internal disk in the old machine, copy the manifest folder (small) to a portable drive the spare can read:

    ```bash
    cp -a "$M" /media/$USER/<portable-drive>/
    ```

    For VMs, copy one small disk to test the restore, not all of them.

2. **On the spare,** set `BACKUP` and `HOMECOPY` to wherever the portable drive mounts, then work through Phase 7 and Phase 8.
3. **⚠️ Don't delete anything inside a cloud-synced folder on the spare.** The sync client mirrors deletions to every machine, including your working one. Leave old venvs and stray copies alone there, and clean them up later from one machine on purpose.
4. **Write down every surprise** (a renamed package, a missing step, a repo that needs a new key) and fix the runbook before you wipe the real machine.

## Phase 6 — Install 26.10

1. **Pick the ISO.** Newer CPUs can use the AMD64v3 build, which is compiled for x86-64-v3:

    ```bash
    /lib64/ld-linux-x86-64.so.2 --help | grep x86-64-v3   # "supported" = v3 OK
    ```

    - Standard ISO: [ubuntu.com/download/desktop](https://ubuntu.com/download/desktop)
    - AMD64v3 ISO: [cdimage.ubuntu.com/ubuntu/releases/26.10/release/](https://cdimage.ubuntu.com/ubuntu/releases/26.10/release/). Use the file with `amd64v3` in its name.

2. **Verify the ISO** before writing it to USB. Download `SHA256SUMS` from the same directory:

    ```bash
    sha256sum -c SHA256SUMS --ignore-missing   # want: OK
    ```

3. **Boot the USB** and choose **Manual installation**. Pick the OS disk by model and size. Leave every other disk alone, especially any disk with a filesystem directly on it and no partitions, which some installer screens display oddly.
4. **Partition the OS disk.** Keeping the system and `/home` on separate partitions means the next clean install formats only `/`:

    | Partition | Size | Format | Mount |
    | --- | --- | --- | --- |
    | EFI | 1G | FAT32 | `/boot/efi` |
    | System | 200G | ext4 | `/` |
    | Data | the rest | ext4 | `/home` |

    200G leaves room for snaps, flatpaks, apt caches and old kernels. 100G gets tight within a release or two. A Clonezilla image of just the system partition is small, quick, and restorable without touching your data.

5. Use the same username as before. Paths in your shell configs probably assume it.
6. After the first boot, update before restoring anything:

    ```bash
    sudo apt update && sudo apt full-upgrade -y
    ```

## Phase 7 — Restore, in order

Set the variables again in the new system's terminal:

```bash
BACKUP=/media/$USER/<backup-drive>
HOMECOPY=/media/$USER/<home-copy-drive>/home-$USER
M=$(ls -d "$BACKUP"/system-manifest-*-* | tail -1); echo "$M"
```

1. **Your files.** Copy back the visible folders (Documents, Pictures and so on) and leave the old hidden config folders behind. You'll restore those selectively below:

    ```bash
    rsync -aHAX --info=progress2 --exclude='.*' "$HOMECOPY"/ ~/
    ```

2. **SSH keys:**

    ```bash
    tar xzpf "$M/SENSITIVE/ssh-keys.tgz" -C ~
    chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_* ~/.ssh/config
    ```

3. **Third-party APT repos.** `$M/system/apt-sources.list.d/` is reference only, because the release codename changed. Re-add each repo with its vendor's current instructions and keyring.
4. **APT packages.** Review the list first, since some packages are renamed or gone:

    ```bash
    less "$M/packages/apt-manual.txt"
    xargs -a "$M/packages/apt-manual.txt" sudo apt install -y
    ```

5. **Homebrew:**

    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew bundle install --file="$M/packages/Brewfile"
    ```

6. **pipx, cargo, npm.** Reinstall from `$M/packages/pipx.txt`, `cargo.txt` and `npm-global.txt`.
7. **VS Code extensions:**

    ```bash
    while read -r ext; do code --install-extension "$ext"; done < "$M/dev/vscode-extensions.txt"
    ```

8. **Git and gh.** Copy `.gitconfig` and `.gitignore` from `$M/dev/`, run `gh auth login`, then reinstall the extensions listed in `gh-extensions.txt`.
9. **Shell.** Copy `.zshrc`, `.zsh_history`, oh-my-zsh `custom/` and `.tmux.conf` from `$M/shell/`. Check for hard-coded paths, then open a new terminal.
10. **Groups.** Log out and back in afterwards. `dialout` is what grants access to USB-serial console cables:

    ```bash
    sudo usermod -aG libvirt,kvm,dialout,wireshark $USER
    ```

11. **Wi-Fi and VPN profiles.** These are the `90-NM-*` netplan files:

    ```bash
    sudo cp "$M"/SENSITIVE/netplan/90-NM-*.yaml /etc/netplan/
    sudo chown root:root /etc/netplan/90-NM-*.yaml && sudo chmod 600 /etc/netplan/90-NM-*.yaml
    sudo netplan generate && sudo nmcli connection reload
    ```

    Don't copy the other netplan files over blind. Compare them with the fresh defaults, then rebuild bridges and VLANs by hand.

12. **udev rules.** Copy back only your custom rules from `$M/system/rules.d/`, then run `sudo udevadm control --reload`.
13. **GNOME extensions.** Extensions are tied to the GNOME version, so reinstall current builds (Extension Manager or extensions.gnome.org) from `$M/system/gnome-extensions-enabled.txt`. Then restore only their settings:

    ```bash
    awk '/^\[/{p=($0 ~ /^\[org\/gnome\/shell\/extensions\//)} p' "$M/system/dconf-dump.ini" \
      | sed 's|^\[org/gnome/shell/extensions/|[|' \
      | dconf load /org/gnome/shell/extensions/
    ```

14. **VMs.** Keep VM disks off the 200G system partition by putting them on `/home`:

    ```bash
    sudo mkdir -p /home/libvirt-images
    sudo rsync -ah --sparse --info=progress2 "$BACKUP"/vm-images/ /home/libvirt-images/
    sudo virsh pool-define-as home-images dir --target /home/libvirt-images
    sudo virsh pool-autostart home-images && sudo virsh pool-start home-images
    for x in "$M"/kvm/*.xml; do
      case "$x" in */net-*) continue;; esac
      sed 's|/var/lib/libvirt/images/|/home/libvirt-images/|' "$x" > /tmp/vm.xml
      sudo virsh define /tmp/vm.xml
    done
    ```

    Re-create any non-default networks with `sudo virsh net-define "$M/kvm/net-<name>.xml"`.

15. **Everything else.** Compare `$M/system/systemd-*.txt`, `crontab-user.txt` and `usr-local-bin.txt` with the new system. Restore other desktop settings selectively with `dconf load` rather than loading the whole dump.

## Phase 8 — Rebuild your Python dev environments

Keep your code in the synced folder and keep the venvs out of it. A venv holds a link to one machine's Python plus compiled packages for one OS. A synced copy is broken on any other machine, and on another OS it can never work. Each machine builds its own from the project's lock file:

```
~/<sync-folder>/<project>/     ← code + requirements files (synced, same everywhere)
~/.venvs/<project>/            ← interpreter + installed packages (local, per machine)
```

| | Linux / Mac | Windows |
| --- | --- | --- |
| Layout | `bin/python` (symlink) | `Scripts\python.exe` (copy) |
| Activate | `source ~/.venvs/<project>/bin/activate` | `~\.venvs\<project>\Scripts\Activate.ps1` |
| Compiled packages (cffi, cryptography) | Linux or macOS binaries | Windows binaries |

1. **Let your sync client finish** downloading your project folders before you start.
2. **Decide what to rebuild now.** `$M/dev/python-venvs.txt` lists every old venv and the Python version that built it. Rebuild only what you need right now; the rest can wait. Entries with `home = /usr/local/opt/python@…` were built on a Mac and never worked on Linux.
3. **Install the Python version your lock files were built with.** A newer release may ship a newer default `python3`, and lock files pinned on an older Python often fail to install on a newer one. Check apt first:

    ```bash
    apt-cache policy python3.13
    sudo apt install python3.13 python3.13-venv          # if apt has it
    # otherwise, without touching the system Python:
    pipx install uv && uv python install 3.13
    ```

4. **Build a venv for each project** (example: a project called `Discovery`):

    ```bash
    python3.13 -m venv ~/.venvs/Discovery                # or: uv venv --seed --python 3.13 ~/.venvs/Discovery
    source ~/.venvs/Discovery/bin/activate
    cd ~/<sync-folder>/Discovery
    python -m pip install -r requirements-lock.txt
    ```

5. **Point VS Code at it.** Use the interpreter picker at the bottom-right of the status bar, then **Enter interpreter path** → `~/.venvs/Discovery/bin/python`. VS Code remembers it per folder.
6. **Optional shortcut,** one shell function per project:

    ```bash
    disc() { source ~/.venvs/Discovery/bin/activate && cd ~/<sync-folder>/Discovery; }
    ```

7. **MkDocs sites** (Material theme with the `social` and `glightbox` plugins). Install MkDocs once with pipx so it works from every docs project, venv active or not:

    ```bash
    sudo apt install libcairo2-dev libfreetype6-dev libffi-dev libjpeg-dev libpng-dev libz-dev
    pipx install mkdocs
    pipx inject mkdocs "mkdocs-material[imaging]" mkdocs-glightbox
    cd ~/<sync-folder>/<docs-project> && mkdocs serve    # test it
    ```

    The `social` plugin downloads theme fonts on its first build. Build each site once while you're online so later builds work offline.

8. **Clean up the old synced venvs later.** Only do it once the new venvs work on every machine you use, and only from one machine, because deletions sync everywhere. Then add an ignore rule in your sync client for venv folder names.

## Gotchas

| Symptom | Cause | Fix |
| --- | --- | --- |
| `zsh: no matches found` on `sudo du /var/lib/libvirt/images/*` | Your shell expands the glob as you, before sudo, and can't read the root-only folder | `sudo sh -c 'du -sh /var/lib/libvirt/images/*'` |
| `zsh: event not found` on `~/.[!.]*` | zsh treats `!` as history expansion | Use `~/*(D)` in zsh |
| `partclone.chkimg`: `Unknown checksum mode` | Ubuntu's partclone is older than Clonezilla's | Verify inside Clonezilla live (Phase 1) |
| `NetworkManager/system-connections` is empty | NM saves profiles as netplan `90-NM-*.yaml` | Normal. They're in the netplan backup |
| A command path starts with `/SENSITIVE/...` | `$M` isn't set in this terminal | Re-run the `M=...` line |
| `qemu-img compare` sits silent for minutes | It reads both images in full | Add `-p` for progress, or rely on `qemu-img check` |
| A doubled folder such as `Downloads/Downloads` | rsync source given without a trailing slash | Use `src/` to copy the contents of src |
| A project's venv works on one machine and is broken on the others | The venv lives in a synced folder; it's tied to one machine's Python and OS | Keep venvs in `~/.venvs/<project>` (Phase 8) |
| `which mkdocs` points into some project's venv | That venv is active and first on `PATH` | `deactivate` first; install MkDocs with pipx (Phase 8) |
| A folder you deleted on the test machine vanished from your main one | Sync clients mirror deletions | Never delete in synced folders on a test machine |

## Appendix — system-manifest.sh

Save as `~/system-manifest.sh` and run it with `~/system-manifest.sh "$BACKUP"`. The destination is required, and the script refuses one on the root disk.

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
```
