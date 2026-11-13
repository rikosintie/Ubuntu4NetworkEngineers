# Ubuntu Nuke & Pave Runbook (25.04 → 26.10)

Last updated: November 11, 2026

## Overview

This runbook takes a device from Ubuntu 25.04 to a clean 26.10 install on the same drive without losing any tools, configs, or VMs. This is commonly referred to as a "Nuke & Pave" because the old Operating system is destroyed (Nuked) before the new Operating system is installed (Disk is Paved).

- **Rebuild path:** `system-manifest.sh` (Appendix) records what you installed and configured, and you reinstall from that checklist.
- **Rollback path:** a verified Clonezilla image of the old system. You only restore it if the new install goes badly.
- **Your files:** a straight copy of your home directory and VM disks to a separate disk.

Work through the phases in order, and don't start Phase 6 until every box in Phase 5 is ticked. If this is a machine you can't afford to have down, rehearse the restore on a spare machine first (see the Rehearsal section after Phase 5).

**Set the restore variables in every terminal.** The commands below use `$BACKUP` (the backup drive), `$HOMECOPY` (your home-directory copy) and `$M` (the newest manifest folder). Plugged-in drives mount under `/media/$USER/` or `/run/media/$USER/` depending on the release, so this function looks the drive up by its label and refuses to run if it isn't mounted. Put it in your shell config (Phase 7, Shell) and run `bkenv` in each new terminal. It picks the manifest for the current hostname; `bkenv <hostname>` picks another machine's.

```bash
lsblk -o NAME,SIZE,LABEL,MOUNTPOINT          # find your backup drive's label

# Set restore variables from the backup drive:  bkenv [hostname]
bkenv() {
  local mnt host="${1:-$(hostname)}"
  mnt="$(findmnt -n -o TARGET -S LABEL=<backup-drive-label>)"
  [ -n "$mnt" ] || { echo "<backup-drive-label> is not mounted" >&2; return 1; }
  export BACKUP="$mnt" HOMECOPY="$mnt/home-$USER"
  export M="$(ls -d "$mnt"/system-manifest-"$host"-* 2>/dev/null | tail -1)"
  echo "BACKUP=$BACKUP"; echo "HOMECOPY=$HOMECOPY"; echo "M=${M:-<no manifest for $host>}"
}
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

Plugged-in drives are automounted by the desktop under `/media/$USER/<label>`, or `/run/media/$USER/<label>` on newer releases. Find the real path with `findmnt -n -o TARGET -S LABEL=<label>` rather than assuming one. A drive with no `/etc/fstab` entry automounts the same way after the reinstall, so there's nothing to restore for it.

## Phase 1 — Make and verify the Clonezilla rollback image

An unverified image isn't a rollback. A clean save log only proves the image was written; Clonezilla's restorable check proves it can be read back. These steps work for any Clonezilla backup.

1. Take a full-disk image of the OS disk with Clonezilla live (**device-image → savedisk**). At the end, choose **reboot** or **cmd**, not poweroff, so you can read the final messages.
2. Read the save log. In the image folder on the Clonezilla drive:

    ```bash
    IMG=$(findmnt -n -o TARGET -S LABEL=<clonezilla-drive-label>)/<image-folder>
    grep -iE 'restorable|succe|fail|error' "$IMG"/clonezilla-img
    ```

    You want `Partclone successfully cloned` for every partition and `The operation has completed successfully`. The `If this action fails or hangs, check:` lines are boilerplate.

3. If there are no `restorable` lines, the post-save check didn't run. Run it now. Boot Clonezilla live (any machine works, because the check only reads the image), then **device-image → local\_dev**. Pick the Clonezilla drive by size and model, browse to the image folder, then **Beginner → chk-img-restorable** and select the image. It reads the entire image, which takes about 2.5 hours for \~300G over USB-C.
4. Confirm the final message says the check completed successfully.

Don't verify with Ubuntu's `partclone.chkimg`. Images made by a newer Clonezilla use a checksum format that Ubuntu's older partclone can't read. It fails with `Unknown checksum mode`, which says nothing about the image itself. `Info-packages.txt` in the image folder shows which partclone version wrote it.

If a machine won't boot the stick, use its one-time boot menu (F9 on HP, F12 on Dell/Lenovo) and pick the **UEFI** entry for the USB stick.

## Phase 2 — Run the manifest

The script writes straight to the backup drive and refuses any path on the root disk, so there's no copy-off step to forget. Run it as your normal user; it calls sudo itself where it needs to.

1. Save the Appendix script as `~/system-manifest.sh`, then lint and run it:

    ```bash
    chmod +x ~/system-manifest.sh
    shellcheck ~/system-manifest.sh
    ~/system-manifest.sh "$(findmnt -n -o TARGET -S LABEL=<backup-drive-label>)"
    ```

2. Read every `[skip]`, `[warn]` and `!!` line. A skip can mean a tool isn't installed, or something to grab by hand. A `!!` line about `IdentityFile` means some SSH keys live outside `~/.ssh`.
3. Run `bkenv` (Overview) so `$M` points at the new manifest.
4. Verify every SSH key is in the tarball, and copy it to a second drive too:

    ```bash
    tar tzvf "$M/SENSITIVE/ssh-keys.tgz"
    ```

5. Verify the network profiles. On Ubuntu 23.10 and later, NetworkManager saves connections as netplan files named `90-NM-<uuid>.yaml`, so an empty `NM-system-connections` folder is normal:

    ```bash
    sudo diff -r /etc/netplan "$M/SENSITIVE/netplan" && echo "netplan OK"
    ls "$M/SENSITIVE/netplan" | grep -c '^90-NM-'   # about one per Wi-Fi/VPN profile
    ```

6. **List what no package manager knows about.** Native installers and `curl | sh` tools (Claude Code, Tailscale, Ollama, uv and so on) aren't in any apt, snap or Flatpak list, so they're easy to forget:

    ```bash
    cat "$M/packages/native-tools.txt" "$M/system/non-package-installs.txt"
    ```

Keep `SENSITIVE/` **and** `shell/` off cloud drives. `SENSITIVE/` holds Wi-Fi passwords and SSH keys, and `shell/` holds your `.zshrc`, so keep passwords out of `.zshrc` (Phase 7, Shell, has a safer way).

**Run the manifest again, and the Phase 3 home rsync, on the day of the wipe.** Anything you changed since the last run is otherwise lost. Both only take a minute or two the second time.

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

By default, libvirt keeps VM disks in `/var/lib/libvirt/images/`, on the disk you're wiping. The manifest saved each VM's XML definition; the qcow2 files need their own copy. Copy them **compacted**: `qemu-img convert` writes a fresh image without the unused space and flattens any backing chain into one standalone file. In testing, an 87G image came out at 26G and a 101G one at 42G.

1. List the VMs, their disks and sizes:

    ```bash
    sudo virsh list --all
    cat "$M/kvm/disk-images.txt"
    ```

2. Leave out VMs you no longer want. Simply don't copy their disks, and note their names so you skip their XML at restore time.
3. Shut down every VM you're keeping (`sudo virsh shutdown <vm>`). Copying a running VM gives an inconsistent disk.
4. Copy and compact each disk straight onto the backup drive:

    ```bash
    sudo mkdir -p "$BACKUP/vm-images"
    sudo qemu-img convert -p -O qcow2 /var/lib/libvirt/images/<vm>.qcow2 "$BACKUP/vm-images/<vm>.qcow2"
    ```

    (`kvm/copy-vm-disks.sh` from the manifest also works. It copies uncompacted, keeping backing files as separate files.)

5. Check each copy. You want `No errors were found on the image.`:

    ```bash
    sudo qemu-img check "$BACKUP/vm-images/<vm>.qcow2"
    ```

The `vm-images` folder and its files are root-owned. Use `sudo` to delete or move them, or `sudo chown $USER:` a file before copying it to another machine without `sudo`.

## Phase 5 — Final checks before the wipe

Don't boot the installer until every box is ticked.

- [ ] **Manifest and home rsync re-run today**, so the backups have your latest changes
- [ ] Clonezilla image passed **chk-img-restorable**
- [ ] Manifest has no unexplained `[skip]`/`[warn]` lines
- [ ] SSH tarball lists every key, and a second copy exists
- [ ] Netplan backup matches `/etc/netplan` and has the `90-NM-*` profiles
- [ ] Non-package installs noted (`native-tools.txt`, `non-package-installs.txt`)
- [ ] Home directory copied and the dry run is clean
- [ ] VM disks compacted onto the backup drive, and `qemu-img check` is clean on each
- [ ] Local git repos with unpushed work are pushed (see `$M/dev/local-git-repos.txt`)
- [ ] Installer USB written and ISO checksum verified (Phase 6)
- [ ] You know which disk is the OS disk by **model and size**

## Rehearsal (optional) — restore onto a spare machine first

A spare machine with a fresh Ubuntu install lets you run Phases 7 and 8 for real while your working machine stays untouched. Problems show up there instead of the night before a job. The same release, or one close to it, is fine.

1. **Make the backups reachable.** If the backup drive is inside the old machine, copy the manifest folder (small) onto a portable drive, or copy files across the network.
2. **Copying across the network:** enable SSH on the spare (`sudo systemctl enable --now ssh.socket`; `ssh` shows "inactive" until a connection arrives, which is normal), then from the old machine:

    ```bash
    rsync -ahz --sparse --partial --info=progress2 <file> <you>@<spare>:
    ```

    `-z` compresses empty space in disk images, and `--partial` lets an interrupted copy resume. Check `df -h / /home` on the spare first, because restored home folders fill `/home` fast.

3. **On the spare**, run `bkenv`, then work through Phases 7 and 8.
4. **⚠️ Don't delete anything inside a cloud-synced folder on the spare.** The sync client mirrors deletions to every machine, including your working one.
5. **Write down every surprise** and fix this runbook before wiping the real machine.
6. If you plan to re-pave the spare as a test of the runbook itself, run the manifest on it first. Everything you set up there is otherwise lost.

## Phase 6 — Install 26.10

1. **Pick the ISO.** Newer CPUs can use the AMD64v3 build:

    ```bash
    /lib64/ld-linux-x86-64.so.2 --help | grep x86-64-v3   # "supported" = v3 OK
    ```
    - Standard ISO: [ubuntu.com/download/desktop](https://ubuntu.com/download/desktop)
    - AMD64v3 ISO: [cdimage.ubuntu.com/ubuntu/releases/26.10/release/](https://cdimage.ubuntu.com/ubuntu/releases/26.10/release/) (the file with `amd64v3` in its name)

2. **Verify it** before writing the USB. Download `SHA256SUMS` from the same directory, then run `sha256sum -c SHA256SUMS --ignore-missing`. You want `OK`. A USB 3 stick is much faster than USB 2 here.
3. **Boot the USB.** If the installer offers an update and you choose **Update now**, it updates itself, closes, and leaves you at the live desktop. Relaunch it with `ubuntu-desktop-bootstrap` in a terminal, or reboot and choose **Skip** instead.
4. **Choose Default selection.** Phase 7 reinstalls the apps you actually used. Tick **third-party software for graphics and Wi-Fi** and **additional media formats**, which is needed for NVIDIA cards.
5. **NVIDIA and Secure Boot:** if the installer asks for a Secure Boot (MOK) password, write it down and choose **Enroll MOK** on the blue screen at first reboot. If no such screen appears, that's fine too (Secure Boot is off, or Ubuntu used pre-signed modules). Confirm with `nvidia-smi` after logging in.
6. **Choose Manual installation** and pick the OS disk by model and size. Leave every other disk alone. Delete its old partitions so it shows only free space, then:
    - Create **`/` first**. The installer adds its own EFI partition (FAT32, `/boot/efi`) automatically, so **don't create one yourself**, or you'll end up with two.
    - Then create `/home` from the remaining space.

    | Partition | Size | Format | Mount |
    | --- | --- | --- | --- |
    | EFI (added by the installer) | \~1G | FAT32 | `/boot/efi` |
    | System | 200G | ext4 | `/` |
    | Data | the rest | ext4 | `/home` |

    200G leaves room for snaps, Flatpaks, caches, kernels and VM disks in `/var/lib/libvirt/images`. A separate `/home` means the next clean install formats only `/`.

7. Use the same username and hostname as before. Paths, `bkenv` and the manifest names assume them.
8. After the first boot: `sudo apt update && sudo apt full-upgrade -y`.

## Phase 7 — Restore, in order

Plug in the backup drive and run `bkenv` (Overview). Until your shell config is restored (the Shell step), paste the function into the terminal first. Work in this order: later steps depend on earlier ones.

### Files, SSH, git, shell, fonts

1. **Your files.** Copy back the visible folders (Documents, Pictures and so on). This deliberately skips **hidden** files and folders; the steps below restore those (the SSH, Shell, Claude Code and App settings steps).

    ```bash
    rsync -aHAX --info=progress2 --exclude='.*' "$HOMECOPY"/ ~/
    ```

2. **SSH keys and config:**

    ```bash
    tar xzpf "$M/SENSITIVE/ssh-keys.tgz" -C ~
    chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_* ~/.ssh/config
    ```

    If your `Host *` block lists legacy algorithms for old network gear, each list must start with a **`+`** (for example `KexAlgorithms +diffie-hellman-group14-sha1,diffie-hellman-group1-sha1`). Without the `+` it *replaces* OpenSSH's modern defaults, and modern hosts then fail with "no matching key exchange method found".

3. **Git and GitHub:**

    ```bash
    cp "$M/dev/.gitconfig" ~/
    ssh -T git@github.com                                      # want: "Hi <user>!"
    git config --global url."git@github.com:".insteadOf https://github.com/
    git config --global core.fileMode false
    find ~/<sync-folder> -maxdepth 4 -type d -name .git -exec git --git-dir={} config core.fileMode false \;
    ```
    - The `insteadOf` line makes HTTPS remotes push over SSH. If git asks for a username and password, this is what's missing. GitHub rejects account passwords anyway.
    - `core.fileMode false` stops repos in a synced folder from showing every script as "modified" (cloud drives don't keep the executable bit). Git writes `true` into each new clone, so run `git config core.fileMode false` after cloning. When you add a new script, record it as executable with `git update-index --chmod=+x <file>`.
    - In synced folders, use git on **one machine at a time** and let the sync finish before switching.

4. **Shell.** Install zsh, oh-my-zsh and your plugins **first**, because the oh-my-zsh installer replaces `~/.zshrc`. Then copy back `.zshrc` and `.oh-my-zsh/custom/` from `$M/shell/`, and zoxide's history from `$HOMECOPY/.local/share/zoxide/`. Reload with `exec zsh`.
    - Check your aliases for apps that changed format. For example, an alias `code='flatpak run …'` breaks once VS Code comes from apt.
    - Keep passwords out of `.zshrc`. Set them per terminal, without echo or history, using helpers in `~/.oh-my-zsh/custom/<your>.zsh` (oh-my-zsh loads only `*.zsh` files in `custom/`):

    ```bash
    venv()    { source ~/.venvs/"$1"/bin/activate; }          # venv <project>
    askpass() { read -rs "$1?$1: "; export "$1"; echo; }       # askpass MY_PASSWORD_VAR (zsh)
    ```
    - Add `bkenv` there too. Variable names are case-sensitive, so match exactly what your scripts read.
    - Add functions in an editor, not by pasting a heredoc at the prompt. A wrapped paste can write the command itself into the file. If a line ends up in there that sources `.zshrc`, every new shell hangs. Typing **Ctrl+X Ctrl+E** at the prompt opens long commands in your editor.

5. **Fonts, before opening any apps** (otherwise they fall back to a default font). Fonts installed with `sudo` live in `/usr/local/share/fonts`:

    ```bash
    sudo tar xzf "$M/system/fonts-usr-local.tgz" -C /usr/local/share
    cp -a "$M/system/fonts" ~/.local/share/ 2>/dev/null
    sudo fc-cache -f
    fc-match '<your editor font>'      # should name your font, not DejaVu
    ```

### Packages

6. **Third-party APT repos.** Each file in `$M/system/apt-sources.list.d/` is one repo. Skip `ubuntu.sources`, since the new release has its own. Sort the rest by their `Suites:` line:

    ```bash
    for f in "$M"/system/apt-sources.list.d/*; do echo "== $(basename "$f")"; grep -hE '^(URIs|Suites|Signed-By):|^deb ' "$f"; done
    ```

    | `Suites:` | Meaning | Restore |
    | --- | --- | --- |
    | `stable`, `main` and similar | Not tied to an Ubuntu release | Copy the file back, plus its key from `system/apt-keyrings/` or `system/apt-keyrings-other/` |
    | An Ubuntu codename (e.g. `plucky`) | Built per release | Use the vendor's current instructions, or their `.deb` (the Vendor .debs step) |
    | A `ppa.launchpadcontent.net` URL | A PPA | `sudo add-apt-repository ppa:<owner>/<name>`; if there's no build for your release yet, use Ubuntu's own package |

    Restored repo files and keys must be root-owned (`sudo chown root:root`, `sudo chmod 644`), then run `sudo apt update`.

7. **APT packages.** apt aborts the **whole** install if a single name is unknown, so split the list first:

    ```bash
    while read -r p; do
      if apt-cache policy "$p" 2>/dev/null | grep -q 'Candidate: [^(]'; then echo "$p"; else echo "$p" >&2; fi
    done < "$M/packages/apt-manual.txt" > ~/apt-ok.txt 2> ~/apt-missing.txt
    xargs -a ~/apt-ok.txt sudo apt install -y
    ```

    Then sort `~/apt-missing.txt`:

    | Missing | What to do |
    | --- | --- |
    | Old libraries, kernels and HWE packages from older releases | Ignore. Apps pull in current versions |
    | Packages from vendor repos (browser, sync client, editors, printer drivers) | Install from the vendor (the Vendor .debs step) |
    | `python3.X-venv`, `python3.X-tk` | Normal: get older Pythons with uv (Phase 8) |
    | `isc-dhcp-client`, `wireless-tools`, `speedtest-cli`, `p7zip-rar` | Removed. Use `dhcpcd-base` (`dhcpcd`), `iw`, `pipx install speedtest-cli`, `7zip-rar`. Update any scripts that call `dhclient` or `iwconfig` |
    | `qemu-kvm` ("virtual package") | Install `qemu-system-x86` instead |

    Also **skip** apt packages you'll run another way: apt's `mkdocs` (pipx, Phase 8), and apps you'll install as a Flatpak (for example `simplenote`), otherwise you get duplicates.

8. **Homebrew, pipx, cargo, npm.** Run `brew bundle install --file="$M/packages/Brewfile"`. For the others, see `pipx.json`, `cargo.txt` and `npm-global.txt`. A missing file just means nothing was installed with that tool.

### Apps that aren't in any package list

Check `$M/packages/native-tools.txt` and `$M/system/non-package-installs.txt` (the `~/.local/bin` and `/opt` listings). Everything in them needs reinstalling by hand.

9. **Vendor `.deb`s:** for example Chrome, your sync client, Termius and printer drivers (e.g. Epson `escpr2`). Download each from the vendor. Most add their own APT repo, so they keep updating.
10. **VS Code** from Microsoft's repo (restored in the APT repos step): `sudo apt install code`. Install it explicitly if it used to be a Flatpak, since it then won't be in the apt list. Sign in to Settings Sync for your extensions and settings.
11. **Claude Code:** native installer (it updates itself), then your settings. **Log in fresh**; don't copy `.credentials.json`:

    ```bash
    curl -fsSL https://claude.ai/install.sh | bash
    claude doctor
    mkdir -p ~/.claude && cp -a "$M/dev/claude/." ~/.claude/
    claude                                   # log in through the browser
    ```

12. **Tailscale:** in the admin console, **remove the machine's old entry first** so the rebuilt machine can reuse its name. Then:

    ```bash
    curl -fsSL https://tailscale.com/install.sh | sh
    sudo tailscale up                        # add --advertise-routes=<subnet> if this machine was a subnet router
    ```

    If you reach internal DNS names over Tailscale, add a **Split DNS** nameserver for your internal domain in the admin console (**DNS → Add nameserver → Restrict to domain**). Otherwise Tailscale's resolver (`100.100.100.100`) won't resolve them.

13. **Ollama:** `curl -fsSL https://ollama.com/install.sh | sh`. Your old models are listed in `$M/packages/ollama.txt`, but small models move fast, so check for newer ones. Size them to your GPU memory (`nvidia-smi --query-gpu=name,memory.total --format=csv`). Anything bigger than the GPU runs partly on the CPU, which works but is slower. For a 4GB card:

    | Model | Pull | Download | Role |
    | --- | --- | --- | --- |
    | Qwen 3.5 9B | `ollama pull qwen3.5:9b` | 6.6 GB | Everyday model (runs partly on the GPU) |
    | Llama 3.2 3B | `ollama pull llama3.2:3b` | 2 GB | Quick tasks (fits entirely on a 4GB GPU) |

14. **Samba** (test shares): `sudo apt install samba`, restore the config, re-add your Samba user, then restart:

    ```bash
    sudo cp "$M/system/smb.conf" /etc/samba/smb.conf
    sudo smbpasswd -a $USER
    sudo systemctl restart smbd nmbd
    ```

15. **Your own systemd units** (e.g. timers you wrote), saved in `system/systemd-local/`:

    ```bash
    sudo cp "$M"/system/systemd-local/* /etc/systemd/system/
    sudo systemctl daemon-reload && sudo systemctl enable --now <unit>.timer
    ```

### espanso, snaps, Flatpaks

16. **espanso (Wayland), built from source.** The released `.deb` (2.2.1) is linked against wxWidgets 3.0, which current Ubuntu no longer ships, so it fails to start. Building takes about 3 minutes:

    ```bash
    sudo apt install build-essential git wl-clipboard libxkbcommon-dev libdbus-1-dev libssl-dev libwxgtk3.2-dev cargo
    git clone https://github.com/espanso/espanso.git ~/src/espanso && cd ~/src/espanso
    cargo build --release --no-default-features --features wayland,modulo,vendored-tls
    ldd target/release/espanso | grep -E 'wx_|not found'        # want -3.2 libraries, no "not found"
    sudo install -m 755 target/release/espanso /usr/local/bin/espanso
    sudo setcap "cap_dac_override+p" /usr/local/bin/espanso
    cp -a "$HOMECOPY/.config/espanso" ~/.config/
    espanso service register && espanso start
    ```
    - Rerun the `setcap` line after **every** rebuild. Without it, espanso starts but doesn't expand anything.
    - To update: `git pull`, then the same build, `install` and `setcap`.
    - Use Ubuntu's `cargo`. If `rustc` is already installed from apt, the rustup installer refuses to run.

17. **Snaps.** List the ones you installed, skipping base and runtime snaps (`core*`, `gnome-*`, `kf5-*`, `kf6-*`, `mesa-*`, `snapd`, which come back automatically):

    ```bash
    awk 'NR>1 {print $1}' "$M/packages/snap.txt"
    for s in <your snaps>; do sudo snap install "$s" || echo "!! $s"; done
    ```

    Rerun each `!!` snap with `--classic` (PowerShell, asciinema and DBeaver need it). Use apt's `nmap`, not the snap, because the confined snap can't do privileged scans.

18. **Flatpaks.** Set up Flathub, then install your list in one go. A single unknown app ID aborts the **whole** install, so leave out:
    - apps you now get from apt (e.g. `com.visualstudio.code`)
    - duplicates of apps Ubuntu ships (e.g. `org.gnome.baobab`, Disk Usage Analyzer)
    - apps from a vendor's own Flatpak repo (e.g. Threema), installed with their `.flatpakref`

    ```bash
    sudo apt install flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    cut -f1 "$M/packages/flatpak.txt" | grep -vE '^(com.visualstudio.code|org.gnome.baobab|<vendor-repo-apps>)$' \
      | xargs flatpak install -y --noninteractive flathub
    flatpak install --from <vendor>.flatpakref                 # each vendor-repo app
    ```
    - **LibreOffice:** use the Flathub build (`org.libreoffice.LibreOffice`) instead of the snap. The Document Foundation publishes it, and it's current and updates automatically.
    - **Permission overrides** (e.g. letting an app see your home folder for drag-and-drop): `sudo flatpak override <app-id> --filesystem=home`. Saved ones are in `system/flatpak-overrides/`.
    - **Check for apt + Flatpak duplicates** (two entries in the app grid), and remove one copy.
    - **Daily automatic updates**, with a system timer. If you had one, it's in `systemd-local/` (the Your own systemd units step):

    ```bash
    sudo tee /etc/systemd/system/flatpak-update.service >/dev/null <<'EOF'
    [Unit]
    Description=Update Flatpak apps and runtimes
    Wants=network-online.target
    After=network-online.target
    [Service]
    Type=oneshot
    ExecStart=/usr/bin/flatpak update --noninteractive --assumeyes
    EOF
    sudo tee /etc/systemd/system/flatpak-update.timer >/dev/null <<'EOF'
    [Unit]
    Description=Daily Flatpak update
    [Timer]
    OnCalendar=daily
    Persistent=true
    RandomizedDelaySec=1h
    [Install]
    WantedBy=timers.target
    EOF
    sudo systemctl daemon-reload && sudo systemctl enable --now flatpak-update.timer
    ```

### Settings, groups, network, VMs

19. **App settings.** Copy individual folders from `$HOMECOPY/.config/<app>`, one app at a time, never the whole `.config`. Examples: `espanso`, `powershell`, `bat` (then `bat cache --build`), `solaar`. Apps with their own account sync (VS Code, Termius) just need a sign-in.
20. **Groups.** Add only the groups that exist (`usermod` fails on any that don't), then log out and back in. `dialout` is what grants access to USB-serial console cables:

    ```bash
    sudo usermod -aG dialout,libvirt,kvm $USER
    sudo dpkg-reconfigure wireshark-common && sudo usermod -aG wireshark $USER   # if you capture as non-root
    ```

21. **Network.**
    - **Wi-Fi and VPN profiles** (laptops): copy the `90-NM-*.yaml` files from `$M/SENSITIVE/netplan/` to `/etc/netplan/`, make them `root:root` with mode 600, then run `sudo netplan generate && sudo nmcli connection reload`.
    - **Lab bridge and VLANs:** put `br0` on a **dedicated NIC** so the machine's own connection is never affected. Bridge and VLAN files are specific to each host, because the NIC names differ, so keep one set per machine (they hold no secrets, so a synced folder works), and adapt them rather than copying another machine's. Then:
      1. Remove NetworkManager's profile for that NIC: `nmcli -f NAME,DEVICE connection show`, then `sudo nmcli connection delete "<name>"`.
      2. In each file, set `renderer: networkd` **on every device** (NIC, `br0`, VLANs), not once at the top. The installer's `01-network-manager-all.yaml` sorts after `01-netcfg-*` and would otherwise hand everything back to NetworkManager.
      3. In DHCP mode, give the bridge `dhcp4-overrides: {route-metric: 1000}` so the main NIC keeps the default route.
      4. `netplan try` refuses bridges with `parameters` (`stp`, `forward-delay`), so validate, then apply: `sudo netplan generate && sudo netplan apply`.
      5. Tagged VLANs need the switch port to be a trunk.

    ```yaml
    # /etc/netplan/01-netcfg-dhcp.yaml (example, chmod 600)
    network:
      version: 2
      ethernets:
        <lab-nic>: {renderer: networkd, dhcp4: false, dhcp6: false}
      bridges:
        br0:
          renderer: networkd
          interfaces: [<lab-nic>]
          dhcp4: true
          dhcp4-overrides: {route-metric: 1000}
          parameters: {stp: false, forward-delay: 0}
          optional: true
    ```

22. **udev rules:** copy back only your own rules from `$M/system/rules.d/`, then `sudo udevadm control --reload`.
23. **GNOME extensions:** reinstall current builds (Extension Manager or extensions.gnome.org) from `$M/system/gnome-extensions-enabled.txt`, then load only their settings:

    ```bash
    awk '/^\[/{p=($0 ~ /^\[org\/gnome\/shell\/extensions\//)} p' "$M/system/dconf-dump.ini" \
      | sed 's|^\[org/gnome/shell/extensions/|[|' | dconf load /org/gnome/shell/extensions/
    ```

    Places Status Indicator and Removable Drive Menu aren't on extensions.gnome.org: they come from `sudo apt install gnome-shell-extensions`. Loading the settings doesn't install or turn on anything, so turn each extension on in Extension Manager, then log out and back in.

    **Not yet updated for GNOME 51 (26.10), as of November 2026:** Rudra, Focus on Active Window, Customize Clock on Lock Screen. Their settings are already loaded, so when extensions.gnome.org lists a GNOME 51 build, install it and turn it on.

24. **Virtual machines.** Install KVM, then put the compacted disks back where the VM definitions expect them (`grep '<source file' "$M"/kvm/*.xml`):

    ```bash
    sudo apt install qemu-system-x86 libvirt-daemon-system virt-manager cpu-checker && kvm-ok
    sudo cp "$BACKUP/vm-images/<vm>.qcow2" /var/lib/libvirt/images/
    sudo chown libvirt-qemu:kvm /var/lib/libvirt/images/<vm>.qcow2      # name each file: zsh can't expand * in a root-only folder
    sudo qemu-img check /var/lib/libvirt/images/<vm>.qcow2
    sudo virsh net-list --all                                          # 'default' active (net-start / net-autostart if not)
    sudo virsh define "$M/kvm/<vm>.xml" && sudo virsh start <vm>
    ```
    - Define only the VMs you kept.
    - A VM with `<source bridge='br0'/>` needs the bridge from the Network step first. `network='default'` uses libvirt's NAT.
    - Older machine types (e.g. `pc-q35-9.2`) still run on newer QEMU.
    - Check `df -h / /home` first. VM disks are large, and `/home` fills up fast after a restore.

25. **Audit for anything missed.** Compare the old machine's records with the new one:

    ```bash
    comm -23 <(awk '/enabled/{print $1}' "$M/system/systemd-system.txt" | sort) \
             <(systemctl list-unit-files --state=enabled --no-legend | awk '{print $1}' | sort)
    cat "$M/system/non-package-installs.txt" "$M/system/crontab-user.txt" 2>/dev/null
    ```

    Ignore `snap-*.mount` lines and internal desktop services. Look for real services you used (Samba's `smbd`/`nmbd`, Ollama, Docker and so on). On newer Ubuntu, time sync uses **chrony** instead of `systemd-timesyncd`; check it with `chronyc sources`.

## Phase 8 — Rebuild your Python dev environments

Keep code in the synced folder and keep venvs **out** of it. A venv links to one machine's Python and holds compiled packages for one OS, so a synced copy is broken everywhere else. Each machine builds its own from the project's lock file:

```
~/<sync-folder>/<project>/     ← code + requirements files (synced, same everywhere)
~/.venvs/<project>/            ← interpreter + installed packages (local, per machine)
```

|  | Linux / Mac | Windows |
| --- | --- | --- |
| Layout | `bin/python` (symlink) | `Scripts\python.exe` (copy) |
| Activate | `source ~/.venvs/<project>/bin/activate` | `~\.venvs\<project>\Scripts\Activate.ps1` |
| Compiled packages (cffi, cryptography) | Linux or macOS binaries | Windows binaries |

1. **Let the sync client finish** downloading your projects.
2. **Decide what to rebuild.** `$M/dev/python-venvs.txt` lists every old venv and its Python version. Rebuild only what you need now. Entries with `home = /usr/local/opt/python@…` were built on a Mac. Some projects need no venv at all. This prints only a project's non-standard-library imports, and an empty `[]` means plain `python3` is enough:

    ```bash
    python3 -c "import ast,sys,pathlib; m=set(); [m.update(a.name.split('.')[0] for n in ast.walk(ast.parse(p.read_text())) if isinstance(n,ast.Import) for a in n.names) for p in pathlib.Path('.').rglob('*.py') if 'venv' not in str(p)]; print(sorted(x for x in m if x not in sys.stdlib_module_names))"
    ```

    For a rarely used script with a couple of dependencies, run it without a venv: `uv run --python 3.13 --with <pkg> <script>.py`.

3. **Install the Python version the lock files were built with**, using uv. It doesn't touch the system Python, which is often newer:

    ```bash
    sudo apt install pipx && pipx ensurepath
    pipx install uv
    uv python install 3.13 && uv python find 3.13
    ```

4. **Build each venv:**

    ```bash
    "$(uv python find 3.13)" -m venv ~/.venvs/<project> --upgrade-deps --prompt <project>
    source ~/.venvs/<project>/bin/activate
    cd ~/<sync-folder>/<project>
    python -m pip install --no-deps -r requirements-lock.txt
    ```
    - Standardize the lock file's name as `requirements-lock.txt`, with a hyphen like `requirements-dev.txt`.
    - `--no-deps` is right for a full exact-pin lock file.

5. **Point VS Code at it.** Use the interpreter picker at the bottom-right of the status bar, then **Enter interpreter path** and give the **absolute** path, such as `/home/<you>/.venvs/<project>/bin/python`. VS Code doesn't expand `~` there. Set it per project, not in your user settings, because Settings Sync would copy the path to your other machines.
6. **Shortcut:** `venv <project>` (Phase 7, Shell), or a per-project function that also `cd`s into the folder.
7. **MkDocs sites:** install MkDocs once with pipx, so it works in every docs project with or without a venv active, and remove apt's copy:

    ```bash
    sudo apt remove mkdocs
    sudo apt install libcairo2-dev libfreetype6-dev libffi-dev libjpeg-dev libpng-dev libz-dev
    pipx install mkdocs
    pipx inject mkdocs "mkdocs-material[imaging]" mkdocs-glightbox
    pipx upgrade --include-injected mkdocs          # later, to update everything together
    ```
    - **Pin CI to what you preview locally:** run `pipx runpip mkdocs freeze > requirements-docs.txt`, use `pip install -r requirements-docs.txt` in the workflow, and pin the workflow's `python-version` to the Python that pipx uses (`'3.x'` drifts to new releases and can reject pins).
    - The `social` plugin downloads fonts on its first build, so build once while online.
    - Material for MkDocs reaches end of life on **May 5, 2027**. Its successor, Zensical, reads `mkdocs.yml`.

8. **Clean up old in-sync venvs later:** once the new ones work on every machine, delete them from **one** machine, then add a sync-client ignore rule for venv folder names.

### macOS notes

- The same `uv` and `~/.venvs` steps work. Google Drive for desktop syncs to `~/My Drive`; other sync clients use their own path.
- If your zsh theme doesn't show `(project)` after activating, check `echo $VIRTUAL_ENV`. Some themes hide the venv prompt.
- **Local Network privacy:** if Python gets `No route to host` to LAN devices while `nc -vz <ip> 22` works, macOS is blocking your terminal app. Go to **System Settings → Privacy & Security**, scroll to **Local Network**, switch your terminal app **off and on**, then fully quit it (Cmd+Q). It can break again after app updates or network changes, so test before a demo.

## Gotchas

| Symptom | Cause | Fix |
| --- | --- | --- |
| `zsh: no matches found` on `sudo … /var/lib/libvirt/images/*` | Your shell expands `*` before sudo runs, and can't read the root-only folder | Name each file, or use `sudo sh -c '… *'` |
| `zsh: event not found` on `~/.[!.]*` | zsh treats `!` as history expansion | Use `~/*(D)` in zsh |
| `partclone.chkimg`: `Unknown checksum mode` | Ubuntu's partclone is older than Clonezilla's | Verify inside Clonezilla live (Phase 1) |
| Installer disappears after "Update now" | It updated itself and closed | `ubuntu-desktop-bootstrap` in a terminal, or reboot and choose Skip |
| A second FAT32 partition with no mount point | The installer adds its own EFI partition | Create `/` first and let it add EFI |
| `apt install` from a list installs nothing | One unknown package name aborts the whole command | Split into `apt-ok.txt` and `apt-missing.txt` (Phase 7) |
| `flatpak install` from a list installs nothing | One unknown app ID aborts the whole command | Remove apps that come from vendor repos or apt |
| Two entries for one app in the app grid | Installed from both apt and Flatpak | Remove one copy |
| A `.deb` app fails with `cannot open shared object file …-3.0.so` | Built against libraries the new release removed | Build from source (espanso, Phase 7) |
| `which -a` lists `/bin/x` and `/usr/bin/x` | `/bin` is a symlink to `/usr/bin`, so it's the same file | Don't delete either |
| `NetworkManager/system-connections` is empty | NM saves profiles as netplan `90-NM-*.yaml` | Normal; they're in the netplan backup |
| A path starts with `/SENSITIVE/…` or `/home-…` | `$M` or `$HOMECOPY` isn't set in this terminal | Run `bkenv` |
| `ssh`: "no matching key exchange method found" to modern hosts | A `Host *` block *replaces* the algorithm list | Prefix legacy lists with `+` |
| Git asks for a username and password | HTTPS remote, no stored credentials | `url."git@github.com:".insteadOf https://github.com/` |
| Every script shows as modified in `git status` | The cloud sync dropped the executable bit | `core.fileMode false` (Phase 7, Git) |
| `netplan try`: "reverting custom parameters for bridges … is not supported" | `try` can't roll back bridge `parameters` | `netplan generate`, then `netplan apply` |
| A new shell hangs after editing aliases | A pasted heredoc wrote `source ~/.zshrc` into a file `.zshrc` loads | Remove the pasted lines; edit in an editor; reload with `exec zsh` |
| `source zsh` prints binary garbage | It sourced the zsh program itself | Use `exec zsh` |
| A venv works on one machine and is broken on others | The venv lives in a synced folder | Keep venvs in `~/.venvs/<project>` |
| `which mkdocs` points into a project's venv | That venv is active | `deactivate`; use pipx MkDocs |
| CI fails: `Could not find a version that satisfies the requirement …` | The workflow's `'3.x'` moved to a newer Python than your pins | Pin `python-version` to your local Python |
| VS Code: interpreter `~/.venvs/…` not found | `~` isn't expanded in that setting | Use the absolute path, per project |
| Python: `No route to host` on macOS while `nc` works | Local Network privacy | Switch the terminal app off and on in Local Network, then Cmd+Q |
| Internal hostnames don't resolve with Tailscale on | Tailscale's resolver doesn't know your domain | Add Split DNS for the domain in the Tailscale admin console |
| A deleted folder on a test machine vanished everywhere | Sync clients mirror deletions | Never delete in synced folders on a test machine |
| Home disk full during a VM copy | Uncompacted qcow2 files, plus restored home folders | Compact with `qemu-img convert`; check `df` first |
| A doubled folder name inside a copy | rsync source given without a trailing slash | `src/` copies the contents of `src` |

## Appendix — system-manifest.sh

Save as `~/system-manifest.sh` and run it with the backup drive as the destination (Phase 2). It refuses a destination on the root disk.

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
# Claude Code: your settings, not login or session state (log in fresh after a rebuild)
if [ -d "$HOME/.claude" ]; then
  mkdir -p "$OUTDIR/dev/claude"
  for f in settings.json keybindings.json CLAUDE.md commands agents skills plugins; do
    [ -e "$HOME/.claude/$f" ] && cp -a "$HOME/.claude/$f" "$OUTDIR/dev/claude/"
  done
  echo "  [ok]   Claude Code settings       -> dev/claude/"
fi
# pipx tools with injected plugins (e.g. mkdocs + mkdocs-material)
have pipx && cap "pipx tools (json)" "$OUTDIR/packages/pipx.json" pipx list --json

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
# Keys referenced by Signed-By: that live outside /etc/apt/keyrings (e.g. /usr/share/keyrings)
mkdir -p "$OUTDIR/system/apt-keyrings-other"
grep -rhoE 'Signed-By:\s*/[^ ,]+(,/[^ ,]+)*|signed-by=/[^] ]+' /etc/apt/sources.list.d 2>/dev/null \
  | sed -E 's/^(Signed-By:\s*|signed-by=)//' | tr ',' '\n' \
  | grep -v '^/etc/apt/keyrings/' | sort -u \
  | while read -r k; do [ -f "$k" ] && cp -a "$k" "$OUTDIR/system/apt-keyrings-other/"; done
[ -n "$(ls -A "$OUTDIR/system/apt-keyrings-other" 2>/dev/null)" ] \
  && echo "  [ok]   other Signed-By keys       -> system/apt-keyrings-other/"

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
# Fonts — per-user and system-wide (fonts installed with sudo land in /usr/local/share/fonts)
copy "user fonts"  "$HOME/.local/share/fonts" "$OUTDIR/system"
[ -d /usr/local/share/fonts ] && [ -n "$(ls -A /usr/local/share/fonts 2>/dev/null)" ] \
  && tar czf "$OUTDIR/system/fonts-usr-local.tgz" -C /usr/local/share fonts 2>/dev/null \
  && echo "  [ok]   /usr/local/share/fonts     -> system/fonts-usr-local.tgz"
# Software installed outside package managers (native installers, curl | sh, tarballs)
{ echo "== ~/.local/bin";  ls -la "$HOME/.local/bin" 2>/dev/null
  echo "== /opt";          ls -la /opt 2>/dev/null; } > "$OUTDIR/system/non-package-installs.txt"
echo "  [ok]   ~/.local/bin + /opt listing -> system/non-package-installs.txt"
: > "$OUTDIR/packages/native-tools.txt"
for t in claude tailscale ollama uv espanso code docker vmware; do
  have "$t" && printf '%-10s %s\n' "$t" "$(command -v "$t")" >> "$OUTDIR/packages/native-tools.txt"
done
echo "  [ok]   native tools present       -> packages/native-tools.txt"
have ollama && cap "ollama models" "$OUTDIR/packages/ollama.txt" ollama list
# Locally created systemd units (e.g. timers you wrote), not package-owned symlinks
mkdir -p "$OUTDIR/system/systemd-local"
find /etc/systemd/system -maxdepth 1 -type f \( -name '*.service' -o -name '*.timer' \) \
  -exec cp -a {} "$OUTDIR/system/systemd-local/" \; 2>/dev/null
[ -n "$(ls -A "$OUTDIR/system/systemd-local" 2>/dev/null)" ] \
  && echo "  [ok]   local systemd units        -> system/systemd-local/"
# Flatpak permission overrides (e.g. --filesystem=home for an app)
for d in /var/lib/flatpak/overrides "$HOME/.local/share/flatpak/overrides"; do
  [ -d "$d" ] && [ -n "$(ls -A "$d" 2>/dev/null)" ] && mkdir -p "$OUTDIR/system/flatpak-overrides" \
    && cp -a "$d"/. "$OUTDIR/system/flatpak-overrides/" \
    && echo "  [ok]   flatpak overrides ($d) -> system/flatpak-overrides/"
done
# Samba config (shares for testing)
[ -f /etc/samba/smb.conf ] && copy "samba smb.conf" "/etc/samba/smb.conf" "$OUTDIR/system"

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
11. Fonts (before opening apps):
       sudo tar xzf $M/system/fonts-usr-local.tgz -C /usr/local/share && sudo fc-cache -f
12. Native installs (not in any package list): see packages/native-tools.txt and
    system/non-package-installs.txt (Claude Code, Tailscale, Ollama, ...).
    Claude Code settings: dev/claude/ -> ~/.claude/  (log in fresh)
    Ollama models: packages/ollama.txt
13. Local systemd units: system/systemd-local/ -> /etc/systemd/system/, then
       sudo systemctl daemon-reload && sudo systemctl enable --now <unit>
14. Flatpak overrides: system/flatpak-overrides/ ; Samba: system/smb.conf
NOTES
echo "  [ok]   REINSTALL-NOTES.md"

# ---------------------------------------------------------------------------
sec "Done"
SIZE=$(du -sh "$OUTDIR" 2>/dev/null | cut -f1)
cat <<EOF

Manifest complete: $OUTDIR  ($SIZE)

  SENSITIVE/  holds WiFi PSKs, ssh keys and ssh config; shell/ holds your .zshrc.
              Keep both off cloud drives.

Already written to $DEST — nothing to copy off.
Still to do before the wipe: copy the VM disks compacted
(sudo qemu-img convert -p -O qcow2 <src> <backup>/vm-images/<vm>.qcow2) and check them,
then verify the ssh tarball:  tar tzvf SENSITIVE/ssh-keys.tgz
EOF
```
