# Useful aliases

If you find any aliases here that you want to use just open `~//home/mhubbard/.oh-my-zsh/custom/my-aliases.zsh` and paste them in. Save and close the file and reload zsh suing `exec zsh` or `sc` if you followed the `oh-my-zsh` [install instructions](/docs/terminal.md#install-oh-my-zsh). If you hover over an alias, you will see an icon that looks like two sheets of paper on top of each other. You can click that icon to copy the alias.

----------------------------------------------------------------

## Open Gnome Text Editor

I use Microsoft VS Code for coding and creating markdown files. But it's pretty heavy to just edit a text file. For that I use the built in `Gnome-Text-Editor` but typing `Gnome-Text-Editor config.txt` is tiresome.

```bash hl_lines='2'
#call Gnome Text Editor
alias gte="gnome-text-editor"
```

With this alias I just have to type `gte config.txt`

----------------------------------------------------------------

## BD

bd's GitHub repository describes it as `Quickly go back to a specific parent directory in bash instead of typing "cd ../../.." redundantly.` But it does a lot more!

```bash hl_lines='2'
# bd jumps backward in paths https://github.com/vigneshwaranr/bd
alias bd='. bd -si'
```

### How to use

If you are in this path `/home/mhubbard/Insync/GD/04_Tools/Discovery/port-maps/pinginfo` and you want to go to the `04_Tools` directory quickly, then just type:

`bd 04_Tools`

In fact, You can simply type `bd <starting few letters>` like `bd 0` or `bd 04`

```bash linenums='1' hl_lines='1'
┌─[mhubbard@1S1K-G5] - [~/Insync/GD/04_Tools/Discovery/port-maps/pinginfo] - [9677]
└─[$] bd 0
/home/mhubbard/Insync/GD/04_Tools/
┌─[mhubbard@1S1K-G5] - [~/Insync/GD/04_Tools]
```

If there are more than one directory with the same name up in the hierarchy, bd will take you to the closest. (Not considering the immediate parent.)

----------------------------------------------------------------

### Other uses

Using bd within backticks

```bash
`bd <letter(s)>` prints out the path without changing the current directory.
```

You can take advantage of that by combining

```bash
`bd <letter(s)>`
```

with other commands such as ls, ln, echo, zip, tar etc..

Example:

If you just want to list the contents of a higher directory, without going there, then you can use:

```bash
ls `bd D`
```

in the example, it will list the contents of `/home/mhubbard/Insync/GD/04_Tools/Discovery`:

```bash hl_lines='2'
┌─[mhubbard@1S1K-G5] - [~/Insync/GD/04_Tools/Discovery/port-maps/pinginfo]
└─[$] ls `bd D`
```

```bash hl_lines=13 title='Command Output'
drwxrwxr-x    - mhubbard 2026-07-14 16:19  __pycache__
drwxrwxr-x    - mhubbard 2024-01-18 16:57  bin
drwxrwxr-x    - mhubbard 2025-07-28 09:20  CR-data
drwxrwxr-x    - mhubbard 2025-11-12 18:46  docs
drwxrwxr-x    - mhubbard 2026-07-19 21:50  Failure-Logs
drwxrwxr-x    - mhubbard 2025-07-14 13:57  images
drwxrwxr-x    - mhubbard 2023-12-21 19:19  include
drwxrwxr-x    - mhubbard 2026-07-14 17:26  Interface
drwxrwxr-x    - mhubbard 2023-12-21 19:19  lib
lrwxrwxrwx    - mhubbard 2025-04-28 20:31  lib64 -> lib
drwxrwxr-x    - mhubbard 2025-06-30 22:33  nmap
drwxr-xr-x    - mhubbard 2023-09-01 08:26  ntc_templates
drwxrwxr-x    - mhubbard 2026-07-23 09:43  port-maps
drwxrwxr-x    - mhubbard 2025-06-30 22:33  Running
drwxrwxr-x    - mhubbard 2024-11-05 13:27  tempDir
drwxrwxr-x    - mhubbard 2026-06-23 15:09  venv
.rw-rw-r--   65 mhubbard 2025-01-03 10:08  01_lab.csv
.rw-rw-r--   15 mhubbard 2025-06-30 22:33  arp.txt
.rw-rw-r-- 2.0k mhubbard 2024-12-19 22:57  aruba-cx-textfsm.txt
```

----------------------------------------------------------------

### Execute up the path

This is very useful! If you want to execute a file in `Discovery` but you are in `/home/mhubbard/Insync/GD/04_Tools/Discovery/port-maps/pinginfo`:

```bash hl_lines='1'
 `bd D`/build.sh
```

will execute `/home/mhubbard/Insync/GD/04_Tools/Discovery/build.sh` while not changing the current directory.

----------------------------------------------------------------

### Jump to new path

If you reside in /home/mhubbard/Insync/GD/04_Tools/Discovery/port-maps/pinginfo and want to change to /home/mhubbard/Insync/GD/04_Tools/Haas:

```bash linenums='1' hl_lines='1'
┌─[mhubbard@1S1K-G5] - [~/Insync/GD/04_Tools/Discovery/port-maps/pinginfo]
└─[$] cd `bd 04`/Haas
┌─[mhubbard@1S1K-G5] - [~/Insync/GD/04_Tools/Haas]
```

It does take effort to get `bd` into muscle memory but it will save you a lot of time if you work on projects with deep directory structures..

----------------------------------------------------------------

```bash hl_lines='2'
# run bat instead of cat
alias cat="bat"
```

```bash hl_lines='2'
# gsw - run gnome-screenshot capture window
alias gsw='gnome-screenshot -w'
```

```bash hl_lines='2'
# gsa - run gnome-screenshot capture area
alias gsa='gnome-screenshot -a'
```

```bash hl_lines='1'
alias python=python3
```

```bash hl_lines='2'
# mw-sensors - show temperatures
alias mw-sensors='sensors'
```

```bash hl_lines='2'
# mw-nmcli-examples - show nmcli examples
alias mw-nmcli-examples='man nmcli-examples'
```

```bash hl_lines='2'
# mw-interface - show only interfaces
alias mw-interface='ip addr show | grep ": \w*"'
```

```bash hl_lines='2'
# mw-interface-vlan - show only interfaces with vlan tags
alias mw-interface-vlan='ip addr show | grep ": \w*\.[0-9]*@\w*"'
```

```bash hl_lines='2'
# show the public IP address your are using
# alias mw-extip='dig +short myip.opendns.com @resolver1.opendns.com;dig -6 TXT +short o-o.myaddr.l.google.com @ns1.google.com | sed "s/"//g"'

alias mw-extip='dig +short myip.opendns.com @resolver1.opendns.com; dig -6 TXT +short o-o.myaddr.l.google.com @ns1.google.com | sed "s/\"//g"'
```

```bash hl_lines='2'
# mw-ipen0 - show IP info for wlan0
alias mw-ipen0='ip addr show wlp61s0 | grep "link\|inet";ip route | grep default | grep wlp0s20f3;nmcli dev show wlp61s0 | grep DNS | grep IP4'
```

```bash hl_lines='2'
# mw-ipen6 - show IP info for enp60s0
alias mw-ipen6='ip addr show enp60s0 | grep "link\|inet";ip route | grep default | grep enp60s0;nmcli dev show enp60s0 && grep DNS'
```

```bash hl_lines='1'
alias mw-ipenbr0='ip addr show br0 | grep "link\|inet";ip route | grep default | grep br0;nmcli dev show br0 && grep DNS'
```

```bash hl_lines='2'
# mw-ipen8 - show IP info for enp8s0
alias mw-ipen8='ip addr show enx0050b61ca0c0 | grep "link\|inet";ip route | grep default | grep enx0050b61ca0c0;nmcli dev show enx0050b61ca0c0 | grep DNS | grep IP4;ip addr show enx0050b61ca0c0 | grep inet6'
```

```bash hl_lines='2'
# mw-nmshrun - show status of network manager
alias mw-nmshrun="nmcli -t -f RUNNING general"
```

```bash hl_lines='2'
# mw-nmshstate - show network manager state
alias mw-nmshstate="nmcli -t -f STATE general"
```

```bash hl_lines='2'
# mw-nmcli-vlan-dhcp - add a vlan interface $1 is the vlan id
alias mw-nmcli-vlan-dhcp='(){nmcli con add type vlan con-name vl$1 dev enp60s0 id $1 autoconnect yes}'
```

```bash hl_lines='2'
# mw-nmcli-vlan-mac - change the MAC on the vlan interface $1 vlan id, $2 MAC with colons
alias mw-nmcli-vlan-mac='(){sudo ifconfig enp60s0.$1 hw ether $2}'
```

```bash hl_lines='2'
# mw-nmshprofiles - show network connection profiles $1 is interface name
alias mw-nmshprofiles='(){nmcli -a -f CONNECTIONS device show $1}'
```

```bash hl_lines='2'
# mw-nmconnectprof - connect to an existing network profile $1 - connection name, $2 ifname
alias mw-nmconnectprof='(){nmcli -p connection up "$1" ifname $2}'
```

```bash hl_lines='2'
# mw-nmshipv4 - show profile IPv4 settings. Profile must be active. $1 is profile name I.E. "Wired connection 1"
alias mw-nmshipv4='(){nmcli -a -f IP4 connection show $1}'
```

```bash hl_lines='2'
# mw-nmwifi - show wifi properties
alias mw-nmwifi='nmcli -f GENERAL,WIFI-PROPERTIES dev show $1'
```

```bash hl_lines='2'
# mw-nmsh-ap - lists available Wi-Fi access points known to NetworkManager
alias mw-nmsh-ap='nmcli dev wifi'
```

```bash hl_lines='2'
# show wifi passwords
alias mw-nmshwifi='(){sudo nmcli -a -p device wifi show-password ifname $1}'
```

```bash hl_lines='2'
# show wifi password of saved SSIDs
alias mw-nmshwifi-pw='(){sudo nmcli connection show $1 -s | grep psk:}'
```

```bash hl_lines='2'
# mw-nmlldp list lldp neighbors
alias mw-nmlldp='(){sudo nmcli -a -p device lldp list ifname $1}'
```

```bash hl_lines='2'
# mw-running_services - show running systemd services
alias mw-running_services='systemctl list-units --type=service --state=running'
```

```bash hl_lines='1'
# lookup MAC vendor from OUI. The final command cd - returns to the directory that the command started in.
alias mw-manuf='() {cd /home/mhubbard/Insync/GD/Python/Scripts/prod && python3 manuf.py $1 && cd -}'
alias mw-manuf1='() {z prod && python3 manuf.py $1 && cd -}'
```

```bash hl_lines='1'
#Run the nmap ntp-info script. $1 is the ip of the ntp server.
alias mw-ntp='(){sudo nmap -sU -p 123 --script ntp-info $1}'
```

```bash hl_lines='1'
# start chrome and allow local file read to use xml on the local disk
alias mw-chrome='cd /opt/google/chrome;./chrome --allow-file-access-from-files'
```

```bash hl_lines='2'
# open ~/.oh-my-zsh/custom/my-aliases.zsh
alias ec1='$EDITOR ~/.oh-my-zsh/custom/my-aliases.zsh'
```

```bash hl_lines='2'
# rerun ~/.zshrc after making changes
alias sc='exec zsh'
```

```bash hl_lines='2'
alias wtf='(){man $1}'

```bash hl_lines='2'
# mw-ports show netstat ports
alias mw-ports='netstat -tulanp'
```

```bash hl_lines='2'
# mw-vmware - Recompile VMware kernel
alias mw-vmware='cd /media/mhubbard/Data1/VMs && ./VMware-Update-after-Kernel-upgrade.sh'
```

```bash hl_lines='2'
# mw-vmnet - Change permission on VMware vnet after upgrading the kernel $1 for vmnet number
alias mw-vmnet='(){sudo chmod a+rw /dev/vmnet$1}'
```

```bash hl_lines='2'
# mw-vmnet-all - Change permission on VMware vnet after upgrading the kernel
alias mw-vmnet-all='sudo chmod a+rw /dev/vmnet*'
```

```bash hl_lines='2'
# edit the tftp configuration file
alias mw-tftp-conf='sudo nano /etc/default/tftpd-hpa'
```

```bash hl_lines='2'
# start tftpd-hfa and display the status
alias mw-tftp='systemctl start tftpd-hpa && sudo ufw allow from any to any proto udp port 69 && systemctl status tftpd-hpa && sudo sudo ufw status verbose'
```

```bash hl_lines='2'
#stop tftpd-hfa
alias mw-tftp-stop='systemctl stop tftpd-hpa && sudo ufw delete allow from any to any proto udp port 69 && sudo sudo ufw status verbose'
```

```bash hl_lines='2'
# add tftp to the firewall
alias mw-tftp-fw='sudo ufw allow from any to any proto udp port 69'
```

```bash hl_lines='2'
# start the ssh daemon and display the status
alias mw-ssh='sudo systemctl start ssh && sudo ufw allow 22/tcp comment "Open port ssh tcp port 22" && sudo systemctl status ssh && sudo ufw status numbered'
```

```bash hl_lines='2'
# stop the ssh daemon and display the status
alias mw-ssh-stop='sudo systemctl stop ssh && sudo ufw delete allow 22/tcp && sudo systemctl status ssh && sudo ufw status numbered'
```

```bash
# Start/stop/status of systemd services
alias mw-start='(){sudo systemctl start $1}'
alias mw-restart='(){sudo systemctl restart $1}'
alias mw-reload='(){sudo systemctl reload $1}'
alias mw-stop='(){sudo systemctl stop $1}'
alias mw-status='(){sudo systemctl status $1}'
```

```bash hl_lines='2'
# mount the WD 3TB Drive
alias mw-mount='sudo mount -t ntfs-3g /dev/sdb1 /mnt/WD-3TB'
```

```bash hl_lines='2'
# Unmount the WD 3TB Drive
alias mw-umount='sudo umount /dev/sdb1'
```

```bash hl_lines='2'
# mw-chrome - start chrome and allow local file read
alias mw-chrome='cd /opt/google/chrome;./chrome --allow-file-access-from-files'
```

```bash hl_lines='1'
# Display SSH ciphers
alias mw-ssh='ssh -V && echo "" && echo HostKeyAlgorithms && ssh -Q HostKeyAlgorithms && echo "" && echo MACs && ssh -Q MACs && echo "" && echo KEXAlgorithms && ssh -Q KexAlgorithms'
```

```bash hl_lines='1'
# -p no error if existing, make parent directories as needed -v print a message for each created directory
alias mkdir='mkdir -pv'
```

```bash hl_lines='2'
# Hide the snap file system
alias df="df -h --exclude=squashfs"
```

```bash hl_lines='2'
# -c like verbose but report only when a change is made
alias chmod="chmod -c"

```bash hl_lines='2'
# Jump to previous directory
alias back='cd $OLDPWD'
```

```bash
# -i prompt before overwrite -v verbse
alias cp='cp -iv'
alias mv='mv -iv'
```

```bash hl_lines='2'
# List files with long time format
alias l.='ls -lha --time-style=long-iso --color=auto'
```

#### Brew-installed tools

We briefly discussed `homebrew`, usually called `brew` in [Gnome Desktop Tools](CH02-Install-Tools.md/#gnome-desktop-tools). It's a package manager that is popular on macOS and Linux. The format to install a tool is `brew install tool-name`. Brew takes care of any dependencies. To get started with `Homebrew` start at the [Brew homepage](https://brew.sh/){_target=blank}

You can find brew formulas here: [Brew formulas](https://formulae.brew.sh/formula/){target="_blank"}. There are thousands of tools in the brew ecosystem. If you are a network engineer in 2026, you will find a lot of tools for your daily workflow in brew. Brew is free, open source software (FOSS), maintained by volunteers. If you use brew and find useful, please go back to the homepage and make a donation.

To see the packages you have installed use `brew list` or `brew list | grep eza` to limit the output to just eza.

----------------------------------------------------------------

```bash linenums='1' hl_lines='1'
brew list
```

The aliases below use:

- bat - A better cat
- duf - Disk Usage/Free Utility - a better 'df' alternative
- dust - More intuitive version of du in rust
- eza
- lm-sensors
- sniffnet
- tailspin

==> Formulae
<table>
  <tr>
    <td>alsa-lib</td><td>ca-certificates</td><td>expat</td><td>freetype</td><td>htop</td><td>jansson</td>
  </tr>
  <tr>
    <td>bat</td><td>csvlens</td><td>eza</td><td>fresh</td><td>hyperfine</td><td>jq</td>
  </tr>
  <tr>
    <td>bottom</td><td>duf</td><td>fd</td><td>fzf</td><td>icu4c@77</td><td>libgcrypt</td>
  </tr>
  <tr>
    <td>bzip2</td><td>dust</td><td>fontconfig</td><td>gping</td><td>iputils</td><td>libgit2</td>
  </tr>
</table>

----------------------------------------------------------------

#### eza

eza is a modern replacement for the Linux ls command. It uses colours for information by default, helping you distinguish between many types of files, such as whether you are the owner, or in the owning group. See [Eza Rocks](https://eza.rocks/) for more detail. To install `eza`, see [the eza repository on git](https://github.com/eza-community/eza)

Run `man eza` to see all the options available.

----------------------------------------------------------------

These aliases have the '--time-style=long-iso --color=auto --icons' options. They print the time in this format: `2026-07-19 21:50', add color, and icons.

```bash hl_lines='1'
alias la='eza -la --time-style=long-iso --color=auto --icons' # ls -la alternative
```

```bash hl_lines='1'
alias ll='eza -l --time-style=long-iso --color=auto --icons --icons'    # ls -l alternative
```

```bash hl_lines='1'
alias ls='eza --time-style=long-iso --color=auto --icons'       # Modern ls with icons
```

#### eza with git

Eza supports a `--git` options that is very useful if you use git.

The Git column shows the version control status of each file or folder relative to your Git repository. The letters you see in your terminal output represent:

-N (New / Untracked): The file or folder is new and has not yet been added or tracked by Git.

-I (Ignored): The item is ignored by Git (typically matched by a pattern inside a .gitignore file, such as python build files or virtual environments).

-M (Modified): A tracked file or directory contains modified changes that have not yet been committed.

-- (Unmodified / Clear): The item is tracked and clean—there are no unstaged changes or pending updates.

!!! Note
    The two character slots in the Git column correspond to Staged status (left) and Unstaged/Workspace status (right). For instance, -N means unstaged/untracked new, whereas N- would mean a newly added file staged for commit.

```bash hl_lines='1'
alias lt='eza --long --header --git --time-style=long-iso --color=auto' # ls with git status
```

----------------------------------------------------------------

```bash title='Command Output'
lt
Permissions Size User     Date Modified    Git Name
drwxrwxr-x     - mhubbard 2026-07-25 12:23  -N img
.rw-rw-r--   45k mhubbard 2025-11-04 20:16  -- Ch01-Using-Ubuntu.md
.rw-rw-r--   56k mhubbard 2026-01-30 14:42  -- CH02-Install-Tools.md
.rw-rw-r--  5.7k mhubbard 2024-11-30 13:12  -- GUI-Tools.md
.rw-rw-r--   15k mhubbard 2025-01-05 13:04  -- Introduction.md
.rw-rw-r--   23k mhubbard 2024-08-20 13:55  -- Join-Ubuntu-24.04-desktop-to-AD.md
.rw-rw-r--   43k mhubbard 2026-03-03 21:56  -- KVM-Bridge.md
.rw-rw-r--  3.3k mhubbard 2025-10-28 08:02  -- kvm_ubuntu_24_vm_setup.md
.rw-rw-r--   12k mhubbard 2024-12-23 16:34  -- Log_tools.md
.rwxrwxr-x   116 mhubbard 2024-12-15 10:59  -- morning.sh
.rw-rw-r--  1.6k mhubbard 2025-08-01 21:55  -- README.md
.rw-rw-r--   799 mhubbard 2025-05-03 13:29  -N Snaps.md
.rw-rw-r--  101k mhubbard 2025-08-07 22:10  -- SSH.md
.rw-rw-r--   66k mhubbard 2026-07-25 12:11  -M terminal.md
```

#### eza with tree view

```bash hl_lines='1'
alias ezat='eza --tree --long --sort=name'
```

----------------------------------------------------------------

```bash title='Command Output'
ezat
drwxrwxr-x     - mhubbard  4 Nov  2025 .
drwxrwxr-x     - mhubbard 25 Jul 12:23 ├── img
drwxrwxr-x     - mhubbard 29 Jan 16:13 │   ├── 'resources-kill (2).png'
drwxrwxr-x     - mhubbard 29 Jan 16:13 │   ├── 'SystemMonitor.resized (2).png'
.rw-rw-r--  1.6k mhubbard 20 Nov  2024 │   ├── All-Apps-New.png
.rw-rw-r--  223k mhubbard  6 Dec  2023 │   ├── alt+~.png
.rw-rw-r--  219k mhubbard 24 Nov  2024 │   ├── AppCenter.png
.rw-r--r--  102k mhubbard 23 Dec  2024 │   ├── bat.png
.rw-r--r--   99k mhubbard 23 Dec  2024 │   ├── bat1.png
.rw-r--r--  104k mhubbard 23 Dec  2024 │   ├── bat2.png
.rw-rw-r--  4.9k mhubbard 25 Nov  2024 │   ├── Bottles.png
.rw-rw-r--   52k mhubbard 10 Dec  2024 │   ├── Bottles1.png
.rw-r--r--   63k mhubbard 11 Aug  2024 │   ├── BR40-VM-Interface.png
```

----------------------------------------------------------------

#### dust

Dust - Like du but more intuitive. Run `man dust` to see a complete list of options. See [Dust on Github](https://github.com/bootandy/dust) for more detail.

```bash
alias du='dust -rR' # Print largest files first, screen reader mode
```

----------------------------------------------------------------

```bash hl_lines='1 3 5 7 9' title='Command Output'
.                       0   58M 100%
img                     1   57M  99%
vesktop1.png            2  1.7M   3%
Tux-Log1.png            2  1.4M   2%
Tux-Tools5.png          2  1.3M   2%
Tux-Log5.png            2  1.3M   2%
Tux-Tools1.png          2  1.3M   2%
Tux-Log9.png            2  1.2M   2%
Tux-ZSH2.png            2  1.2M   2%
```

----------------------------------------------------------------

alias top='btm'              # Better top

#### duf

duf is a replacement for the Linux df command. It report file system space usage. duf creates a table for each device. This alias maps df to duf. See [Duf on GitHub](https://github.com/muesli/duf) for more detail.

```bash hl_lines='1'
alias df='duf'
```

----------------------------------------------------------------

![screenshot](/docs/img/duf.resized.png)

----------------------------------------------------------------

alias ps='procs'             # ps (process viewer with colors)

# Hide loop devices
alias lsblk='lsblk -e7'

# EZA aliases
alias mw-eza1='eza -lT --group-directories-first'

# exa2 display directories first, sort by extension
alias mw-eza2='eza -lF -s extension --group-directories-first'

# alias mw-bright60='xrandr --output eDP-1 --brightness 0.60'

# mw-bright - set a different screen brightness use bright .9
alias mw-bright='xrandr --output eDP-1 --brightness $1'

# mw-kbd set keyboard brightness
alias mw-kbd='sudo brightnessctl --device='dell::kbd_backlight' set $1'

# alias mw-led='sudo brightnessctl --device='intel_backlight' set $1'

# mw-mem5 - get 5 top process eating memory
alias mw-mem5='ps auxf | sort -nr -k 4 | head -5'

# mw-mem10 - get 10 top process eating memory
alias mw-mem10='ps auxf | sort -nr -k 4 | head -10'

# mw-cpu5 - get top process eating cpu
alias mw-cpu5='ps auxf | sort -nr -k 3 | head -5'

# mw-cpu10 - get top process eating cpu
alias mw-cpu10='ps auxf | sort -nr -k 3 | head -10'

# Bauh - Appimage, snap, flatpak manager
alias mw-bauh='() {cd ~/Insync/michael.hubbard999@gmail.com/GoogleDrive/04_Tools/Bauh && source venv/bin/activate && bauh}'

# Tailspin using cx-config.toml
alias tspincx='tspin --print --config-path ~/.config/tailspin/cx-config.toml $1'

# Tailspin using ios-config.toml
alias tspinios='tspin --print --config-path ~/.config/tailspin/IOS-config.toml $1'

# Log into the Juniper vmx router
alias juniper='ssh -i ~/.ssh/juniper_ed25519_key root@192.168.10.162 H3lpd3sk | ct'

# start termianl RPN calculator
alias rpn='flatpak run fr.rubet.rpn'

# Open the expanso base.yml file
alias espanso-base="espanso path | grep Config | awk '{ print \$2\"/match/base.yml\" }' | xargs micro"

# Use Gear Lever from the cli
alias gearlever='flatpak run it.mijorus.gearlever'


# Pull the password from netperf.bufferbloat.net, parse it and pass to betterspeedtest
alias bst="curl https://netperf.bufferbloat.net/ | grep \"Today's passphrase\" | awk '{ print \$4 }' | cut -c 7-20 | xargs -0 -I % betterspeedtest.sh -Z \"%\""

# Check which compositor is running
alias way="echo $XDG_SESSION_TYPE"

----------------------------------------------------------------

### My Functions

Aliases are great, but sometimes it's cleaner to use a function. Claude, Gemini, Copilot and chatGPT are very good at writing zsh functions.

----------------------------------------------------------------

#### Display Memory statistics

If you are running a lot of VMs or other memory intensive applications you may get a message "System Memory low. Process "x" has been killed.

I (and Claude) wrote this function to quickly show me free memory, the swap file usage, any Out of Memory (OOM) messages, and top memory consumers:

```bash linenums='1'
mw-mem-check() {
    echo "=== Memory statistics ==="
    free -h
    echo
    echo "=== Swap ==="
    swapon --show
    echo
    echo "=== OOM killer messages ==="
    sudo dmesg -T | grep -i "out of memory\|killed process"
    echo
    echo "=== Top memory consumers ==="
    \ps -eo pid,user,%mem,%cpu,rss,comm --sort=-%mem \
        | head -11 \
        | awk 'NR==1{print;next}{$5=$5*1024; print}' \
        | numfmt --header --field=5 --to=iec \
        | column -t
    echo
    read -q "reply?Do you want to run procs? (y/n) "
    echo
    if [[ $reply == [yY] ]]; then
        echo
        echo "=== procs full table ==="
        procs --sortd mem
    fi
}
```

```text title='Command Output after I rebooted and memory was cleaned up'
=== Memory statistics ===
                    total        used        free            shared  buff/cache   available
Mem:           30Gi        13Gi       977Mi       3.8Gi        19Gi        16Gi
Swap:          8.0Gi       2.0Mi       8.0Gi

=== Swap ===
NAME      TYPE SIZE USED PRIO
/swap.img file   8G   2M   -2

=== OOM killer messages ===
[sudo] password for mhubbard:
-- no messages were found. No APs had been killed so there was no output --

=== Top memory consumers ===
| PID   | USER     | %MEM | %CPU | RSS  | COMMAND     |
|-------|----------|------|------|------|-------------|
| 32971 | mhubbard | 3.9  | 6.8  | 1.3G | soffice.bin |
| 10845 | mhubbard | 2.5  | 13.6 | 804M | firefox     |
| 4260  | mhubbard | 2.1  | 8.4  | 683M | gnome-shell |
| 5270  | mhubbard | 1.9  | 10.1 | 603M | insync      |
| 40671 | mhubbard | 1.6  | 5.1  | 522M | msedge      |
| 11172 | mhubbard | 1.6  | 1.2  | 517M | Isolated    |
| 11982 | mhubbard | 1.5  | 4.8  | 477M | Isolated    |
| 37662 | mhubbard | 1.4  | 13.5 | 458M | code        |
| 37693 | mhubbard | 1.4  | 6.8  | 443M | code        |
| 11202 | mhubbard | 1.2  | 0.5  | 397M | Isolated    |

Do you want to run procs? (y/n)
```

----------------------------------------------------------------

#### mw-iwget

This one is handy if you do any Wi-Fi work. For the AP that you are connected to it displays:

- the MAC of the AP
- The Interface on you laptop
- The Frequency you are using
- The SSID

----------------------------------------------------------------

```bash linenums='1'
mw-iwget () {
    APMac=`iwgetid -ar`
    IntFace=`iwgetid -f`
    ID=`iwgetid -s`
    echo "AP Mac:" $APMac && echo "Interface:" $IntFace && echo "SSID:" $ID
}
```

----------------------------------------------------------------

```bash title='Command Output'
mw-iwget
AP Mac: 9C:8C:D8:11:7A:F0
Interface: wlp61s0   Frequency:5.18 GHz
SSID: test
```

----------------------------------------------------------------

#### Verify network settings - mw-nplan

My laptop has Wi-Fi and Ethernet. I let the Linux `network manager` manage the Wi-Fi and use `networkd` for the built in Ethernet. This is because I have created a bridge to use with KVM for virtual machines and to be able to connect to vlans different than the Wi-Fi vlan.

That means I can use the GUI settings tool to manage the WiFI but I have to edit a text file to manage the built in Ethernet. If I use a USB Ethernet adapter I can use the `network manager` GUI to manage it.

The functions below:

- Retrieve the IPv4/IPv6 addresses from the WiFi and Br0 interfaces
- prints the default routes - WiFi is lower so that I can still access the internet
- pings `8.8.8.8` using the Wi-Fi interface
- pings `8.8.8.8` using the bridge interface
- shows the DNS settings for both interfaces

----------------------------------------------------------------

```bash linenums='1'
# section header + separator helpers (top-level so they're
# defined once and don't leak/redefine on every call)
_mw_hdr() { printf "\e[31m         %s\e[0m\n\n" "$1"; }
_mw_sep() { printf "\n---------------------\n\n"; }

# return the IPv4 address (with CIDR) of an interface, or "no IP"
_mw_ip() {
    local addrs
    addrs=$(ip -br addr show dev "$1" 2>/dev/null \
            | awk '{$1=$2=""; print}' \
            | tr ' ' '\n' | grep -v '^fe80' | grep . | paste -sd' ')
    print -r -- "${addrs:-no IP}"
}

# verify that netplan is working with
# NetWorkManager for wifi
# networkd for ethternet
mw-nplan() {
    local ethif="br0"          # bridge/ethernet interface (edit as needed)
    local wintf dev

    # detect the wifi interface via sysfs (robust; no perl/proc parsing)
    for dev in /sys/class/net/*(N); do
        [[ -d "$dev/wireless" ]] && { wintf=${dev:t}; break; }
    done

    _mw_hdr "Check that route metrics are correct"
    ip route | grep default
    _mw_sep

    # --- WiFi ---
    if [[ -n "$wintf" ]]; then
        _mw_hdr "ping 8.8.8.8 from Interface $wintf ($(_mw_ip $wintf))"
        ping -I "$wintf" -c 3 8.8.8.8
    else
        _mw_hdr "No wireless interface found — skipping WiFi ping"
    fi
    _mw_sep

    # --- Ethernet / bridge ---
    if [[ -d "/sys/class/net/$ethif" ]]; then
        _mw_hdr "ping 8.8.8.8 from Interface $ethif ($(_mw_ip $ethif))"
        ping -I "$ethif" -c 3 8.8.8.8
    else
        _mw_hdr "Interface $ethif not present — skipping Ethernet ping"
    fi
    _mw_sep

    # --- DNS ---
    _mw_hdr "Check DNS resolution"
    [[ -n "$wintf" ]] && resolvectl status "$wintf"
    printf "\n-------------------------------\n\n"
    [[ -d "/sys/class/net/$ethif" ]] && resolvectl status "$ethif"
}
```

----------------------------------------------------------------

```check title='Command Output'
         Check that route metrics are correct

default via 192.168.10.253 dev wlp61s0 proto dhcp src 192.168.10.143 metric 600
default via 192.168.1.1 dev br0 proto dhcp src 192.168.1.101 metric 1000

---------------------

         ping 8.8.8.8 from Interface wlp61s0 (192.168.10.143/24 fd24:42b2:12ce:0:f1:a0c8:8f6:2055/128 fd24:42b2:12ce:0:ed02:f923:2bfa:f90e/64 fd24:42b2:12ce:0:50db:9203:b498:cd66/64)

PING 8.8.8.8 (8.8.8.8) from 192.168.10.143 wlp61s0: 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=115 time=23.0 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=115 time=13.0 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=115 time=12.7 ms

--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 12.661/16.221/23.033/4.818 ms

---------------------

         ping 8.8.8.8 from Interface br0 (192.168.1.101/24 metric 1000)

PING 8.8.8.8 (8.8.8.8) from 192.168.1.101 br0: 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=114 time=16.0 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=114 time=13.1 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=114 time=10.9 ms

--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 10.927/13.355/16.023/2.087 ms

---------------------

         Check DNS resolution

Link 4 (wlp61s0)
    Current Scopes: DNS
         Protocols: +DefaultRoute -LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
Current DNS Server: fd24:42b2:12ce::1
       DNS Servers: 192.168.10.222 fd24:42b2:12ce::1
        DNS Domain: pu.pri
     Default Route: yes

-------------------------------

Link 5 (br0)
    Current Scopes: DNS
         Protocols: +DefaultRoute -LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
Current DNS Server: 192.168.10.222
       DNS Servers: 192.168.10.222
     Default Route: yes
```

----------------------------------------------------------------

#### mw-nplan-br0

Displays the status of the bridge interface

```bash linenums='1'
# wait for an interface to get an IPv4 address (default 20s timeout)
# Used with mw-nplan_mode_switch also
_mw_wait_ip() {
    local ifc=$1 waited=0 max=${2:-40}
    until ip -4 addr show dev "$ifc" | grep -q "inet "; do
        sleep 0.5
        (( waited += 1 ))
        (( waited >= max )) && return 1
    done
}

# quick status display for br0
mw-nplan-br0() {
    sudo netplan apply
    _mw_wait_ip br0 || echo "Timed out waiting for br0 IPv4."
    ip a show dev br0
    ip route | grep default
}
```

----------------------------------------------------------------

```text title='Command Output'
mw-nplan-br0
5: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 96:1b:00:a7:1a:98 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.101/24 metric 1000 brd 192.168.1.255 scope global dynamic br0
       valid_lft 1800sec preferred_lft 1800sec
    inet6 fe80::941b:ff:fea7:1a98/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever
default via 192.168.1.1 dev br0 proto dhcp src 192.168.1.101 metric 1000
```

----------------------------------------------------------------

#### mw-nplan_mode_switch

Switch between DHCP and Static on the bridge interface. When moving to static, the function opens `/etc/netplan/02-netcfg-static.yaml` in nano so that you can edit it.

!!! Warning
    Be careful when editing the file. It's yaml so it has no sense of humor about errors. The function makes a backup with a `.bak` extension that you can recover from using `sudo cp /etc/netplan/02-netcfg-static.yaml.bak 02-netcfg-static.yaml`

Here is the function.

----------------------------------------------------------------

```bash linenums='1'
# switch netplan br0 between dhcp and static (enable/disable via file extension)
function mw-nplan_mode_switch() {
    local mode=$1
    local static_yaml="/etc/netplan/02-netcfg-static.yaml"
    local static_disabled="/etc/netplan/02-netcfg-static.disabled"
    local dhcp_yaml="/etc/netplan/01-netcfg-dhcp.yaml"
    local dhcp_disabled="/etc/netplan/01-netcfg-dhcp.disabled"

    case "$mode" in
        static)
            echo "Preparing Static IP configuration..."
            [[ -f "$dhcp_yaml" ]] && sudo mv "$dhcp_yaml" "$dhcp_disabled"
            [[ -f "$static_disabled" ]] && sudo mv "$static_disabled" "$static_yaml"
            sudo cp "$static_yaml" "$static_yaml.bak"   # <-- here: file is guaranteed active
            echo "Opening $static_yaml for review/edit. Close the editor when finished."
            # sudo gnome-text-editor "$static_yaml"
            sudo nano "$static_yaml"
            echo "Editor closed."
            ;;
        dhcp)
            echo "Preparing DHCP configuration..."
            [[ -f "$static_yaml" ]] && sudo mv "$static_yaml" "$static_disabled"
            [[ -f "$dhcp_disabled" ]] && sudo mv "$dhcp_disabled" "$dhcp_yaml"
            ;;
        *)
            echo "Usage: mw-nplan_mode_switch [static|dhcp]"
            return 1
            ;;
    esac

    # validate before applying — catches YAML typos without breaking networking
    if ! sudo netplan generate; then
        echo "netplan generate failed — config not applied. Fix the YAML and retry." >&2
        return 1
    fi

    sudo netplan apply

    # wait 10 seconds for br0 to get an address, but don't hang forever
    _mw_wait_ip br0 20 || echo "Timed out waiting for br0 to get an IPv4 address." >&2

    ip a show dev br0
    ip route | grep default
}
```

----------------------------------------------------------------

```bash title='Command Output'
Preparing Static IP configuration...
Opening /etc/netplan/02-netcfg-static.yaml for review/edit. Close the editor when finished.
--Nano opens the yaml file at this point--
Editor closed.
5: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 96:1b:00:a7:1a:98 brd ff:ff:ff:ff:ff:ff
    inet 192.168.10.148/24 brd 192.168.10.255 scope global br0
       valid_lft forever preferred_lft forever
    inet6 fe80::941b:ff:fea7:1a98/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever
default via 192.168.10.253 dev br0 proto static metric 1000

```

----------------------------------------------------------------
