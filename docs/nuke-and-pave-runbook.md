# Ubuntu Nuke & Pave Runbook (25.04 → 26.10)

Oct 28, 2026 · @Mike

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

Plug in the backup drive and run `bkenv` (Overview). Until your shell config is restored in step 4, paste the function into the terminal first. Work in this order: later steps depend on earlier ones.

### Files, SSH, git, shell, fonts

1. **Your files.** Copy back the visible folders (Documents, Pictures and so on). This deliberately skips **hidden** files and folders; the steps below restore those (SSH in 2, shell in 4, app settings in 17, Claude Code in 11).

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
   | An Ubuntu codename (e.g. `plucky`) | Built per release | Use the vendor's current instructions, or their `.deb` (step 9) |
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
   | Packages from vendor repos (browser, sync client, editors, printer drivers) | Install from the vendor (step 9) |
   | `python3.X-venv`, `python3.X-tk` | Normal: get older Pythons with uv (Phase 8) |
   | `isc-dhcp-client`, `wireless-tools`, `speedtest-cli`, `p7zip-rar` | Removed. Use `dhcpcd-base` (`dhcpcd`), `iw`, `pipx install speedtest-cli`, `7zip-rar`. Update any scripts that call `dhclient` or `iwconfig` |
   | `qemu-kvm` ("virtual package") | Install `qemu-system-x86` instead |

   Also **skip** apt packages you'll run another way: apt's `mkdocs` (pipx, Phase 8), and apps you'll install as a Flatpak (for example `simplenote`), otherwise you get duplicates.
8. **Homebrew, pipx, cargo, npm.** Run `brew bundle install --file="$M/packages/Brewfile"`. For the others, see `pipx.json`, `cargo.txt` and `npm-global.txt`. A missing file just means nothing was installed with that tool.

### Apps that aren't in any package list

Check `$M/packages/native-tools.txt` and `$M/system/non-package-installs.txt` (the `~/.local/bin` and `/opt` listings). Everything in them needs reinstalling by hand.

9. **Vendor `.deb`s:** for example Chrome, your sync client, Termius and printer drivers (e.g. Epson `escpr2`). Download each from the vendor. Most add their own APT repo, so they keep updating.
10. **VS Code** from Microsoft's repo (restored in step 6): `sudo apt install code`. Install it explicitly if it used to be a Flatpak, since it then won't be in the apt list. Sign in to Settings Sync for your extensions and settings.
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

## Phase 8 — Rebuild your Python dev environments

## Gotchas

## Appendix — system-manifest.sh
