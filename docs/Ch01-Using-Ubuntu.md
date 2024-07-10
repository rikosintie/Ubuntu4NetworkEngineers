- [Using Ubuntu](#using-ubuntu)
  - [Desktop Environments in Linux](#desktop-environments-in-linux)
  - [Podcasts on Linux](#podcasts-on-linux)
  - [Casting your display](#casting-your-display)
  - [Working with Applications](#working-with-applications)
    - [The Super Key](#the-super-key)
    - [Search for an application](#search-for-an-application)
    - [Switching Applications](#switching-applications)
    - [Viewing all installed applications](#viewing-all-installed-applications)
    - [Switching between multiple open windows in the same application](#switching-between-multiple-open-windows-in-the-same-application)
  - [Configuring the Dock](#configuring-the-dock)
  - [Customizing Gnome - The Tweaks Tool](#customizing-gnome---the-tweaks-tool)
    - [Startup Applications](#startup-applications)
  - [Using the GUI Files application](#using-the-gui-files-application)
    - [Creating archives](#creating-archives)
    - [Display the Full path in files](#display-the-full-path-in-files)
    - [Easily preview files in Files](#easily-preview-files-in-files)
    - [Search](#search)
    - [Why do I have a red Lock on a file or folder?](#why-do-i-have-a-red-lock-on-a-file-or-folder)
  - [Creating a bootable USB stick from an ISO image](#creating-a-bootable-usb-stick-from-an-iso-image)
    - [Use dd to make bootable flash](#use-dd-to-make-bootable-flash)
    - [Use the Ubuntu "Make Startup disk" tool](#use-the-ubuntu-make-startup-disk-tool)
    - [Use qemu to test a startup disk](#use-qemu-to-test-a-startup-disk)
  - [Working with the Linux File System](#working-with-the-linux-file-system)
    - [LSBLK](#lsblk)
    - [LSUSB](#lsusb)
  - [SSH](#ssh)
    - [OpenSSH Server](#openssh-server)
    - [Useful SSH system commands](#useful-ssh-system-commands)
    - [Connecting to Network Devices](#connecting-to-network-devices)
    - [Run network commands remotely](#run-network-commands-remotely)
    - [Network Devices with legacy ciphers](#network-devices-with-legacy-ciphers)
    - [Using a wildcard in the configuration file](#using-a-wildcard-in-the-configuration-file)
    - [Creating SSH Keys](#creating-ssh-keys)
    - [Display the existing keys on your system](#display-the-existing-keys-on-your-system)
    - [SSH Key permissions](#ssh-key-permissions)
    - [Yubico Authenticator](#yubico-authenticator)
    - [Reference](#reference)
  - [Gnome System Tool (GUI)](#gnome-system-tool-gui)
  - [Working with services](#working-with-services)
  - [Viewing Log Messages](#viewing-log-messages)
  - [Locating files from the terminal](#locating-files-from-the-terminal)
    - [Drill - A graphical and CLI tool for searching files](#drill---a-graphical-and-cli-tool-for-searching-files)

----------------------------------------------------------------

# Using Ubuntu

Switching from Windows to Ubuntu with the Gnome desktop is easy and hard. How can that be? It's simple, the basic operation of the desktop is similar to Windows. The file manager (Files) is similar to Windows Explorer and of course, Chrome or Edge work just like they do in Windows including syncing, extensions, etc. There is a keyboard button called the superkey (on most keyboards it will have the Windows logo) just like the Windows key. You tap it and search for an application or pick from the running applications.

So, what is the hard part? Things like killing a hung application, searching for files from the terminal, and checking free disk space are different and will take a little getting used to. It's a lot like working on Cisco IOS for years and then having to work on an Aruba or Juniper switch. At first, it's frustrating, you have to look up commands and it's frustrating.

The reason for this guide is to help get you past the hurdles so that you can start enjoying Ubuntu. I promise that if you get over the hump your productivity as a network engineer will soar. Since MacOS is based on Open BSD Unix,
once your muscle memory is up to speed you can jump back and forth easily between Windows, Mac and Linux. In a later chapter I will discuss the terminal tools that make Linux so much fun and so powerful for
a network engineer.

----------------------------------------------------------------

## Desktop Environments in Linux

One of the big advantages for Linux is that you can customize almost everything since it's open source. You can change the terminal you use, the file manager, the way almost anything works and even the desktop itself.

The first choice you have to make with Ubuntu is which Desktop Environment do  you want to us. The two most popular desktop environments (DE) for Linux are Gnome (Ubuntu’s default), and KDE (which is available on Ubuntu) but there are many more. I use the computer for work and just learned to customize Gnome to fit my workflow but I use Terminator for my terminal app. Here is a TecMint article on [Desktop Environments](https://www.tecmint.com/top-best-linux-lightweight-desktop-environments/). My advice is to start out with the standard Ubuntu with Gnome until you some comfort with Linux.

I listen to a lot of podcasts and KDE Plasma, XFCE and MATE are highly recommended desktop environments (DE) that you may like better than Gnome. If you watched the second episode of Mr. Robot (Season 1 – which I highly recommend) there is a scene were an executive tells Elliot that he runs KDE but
understands why Elliott prefers Gnome.

These two short YouTube videos sum it up better than I can:

- [6 Things to Know When Switching to Linux from Windows](https://www.youtube.com/watch?v=wcdquhB6hT8)
- [10 things you can do with Linux that you can't do with Windows](https://www.youtube.com/watch?v=JOOkfGv58u0)

----------------------------------------------------------------

## Podcasts on Linux

There are a lot of podcasts dedicated to Linux. In your podcast application just search Linux. My favorites are:

- Destination Linux - A weekly podcast on general Open Source topics.
- Late Night Linux - A weekly podcast on Linux and the wider tech industry. NOTE: Lots of F bombs!
- Linux After Dark - A weekly podcast on Linux experiences.
- Linux Dev Time - A weekly podcast on Developing on Linux
- Linux Downtime - A weekly podcast "From working in the Industry and progressing your career, to managing a projects community"
- Linux Unplugged - A weekly podcast on Linux by Jupiter Broadcasting. Covers news and applications for Linux.
- This Week in Linux - A weekly podcast on Linux

----------------------------------------------------------------

## Casting your display

I have a Vizio “Smart” TV with Chromecast built in. Using the Chrome browser I can click the three dot menu on the right and select “Cast...” to send the output to the TV.

In VLC, select “Playback, Renderer” to send VLC’s output to the TV. I don’t have a Chromecast dongle, but I am guessing it would work the same way as the Vizio TV.

----------------------------------------------------------------

## Working with Applications

Like in Windows, there are many ways to open applications in Gnome.

### The Super Key

You can hit the Windows key (Superkey is what it's called in Ubuntu) to bring up a search box.

![screenshot](img/Open-Applications.png)

Notice that the files application icon has two dots on the left side. If you click on the icon, the screen will change to show the two files windows.

![screenshot](img/files-side-by-side.png)

----------------------------------------------------------------

### Search for an application

To open an application using search, simply start typing the name of the application in the search box. As you
type, all the matching applications will be displayed below the search box. If the one you want is the first one
displayed on the left you can just hit enter. If not, keep typing and the list of displayed applications will get
smaller. In the screenshot below, hitting enter will open the built in calculator app. Right arrow, Enter will open
LibreOffice Calc!

![screenshot](img/search.png)

You can also use the mouse and click on any application that is displayed to open it.

----------------------------------------------------------------

### Switching Applications

Tap the super key (Windows key on some keyboards). Below the search box are the applications that are currently running. If you want to switch to one of the open applications, you can use the Tab key and [enter] or use the mouse to select one of the running applications.

You can also use ctrl+tab just like in Windows.

Finally, you can use the dock to open applications that you have pinned to it.

----------------------------------------------------------------

### Viewing all installed applications

The dock has a small icon at the bottom, it’s three rows of three dots. You can click that icon to see the
installed applications in a window.

![screenshot](img/Dock-square.png)

If there are too many to display, a column of circles will appear at the bottom of the screen and arrows on the right side. You can scroll down with the mouse button or click on one of the circles to jump to the next page. As you can see, it’s very easy to open applications in Ubuntu.

![screenshot](img/frequent-new.png)

----------------------------------------------------------------

### Switching between multiple open windows in the same application

If you have several copies of the same application open you can switch between them using the super key + ~ key (the key to the left of 1 on a US keyboard). You can also bring up the dock, click on the application
icon and then select the one you want but the keyboard is much easier and faster.

For Example, in LibreCalc I often have a lot of spreadsheets open. To switch to a different sheet I can use the super + ` key combination. On a US keyboard that is the key to teh left of the 1 key. Here is a screenshot of two spreadsheets.

![screenshot](img/alt%2B~.png)

----------------------------------------------------------------

## Configuring the Dock

Like Windows and Mac, Ubuntu with the Gnome DE has a dock. You customize the dock using the Gnome Settings app. To open the Gnome Settings application, click on "Activities Overview" icon at the top right corner of the
screen, then select the gear icon. This will open the "settings" application. It’s very similar to “System Preferences” on the Mac or Control Panel on Windows.

At the top left corner of the screen there is a magnifying glass. Click it and enter "dock". The dock is under "Ubuntu Desktop".

![screenshot](img/Dock.png)

One thing I do to help me use all three operating systems
is to customize the dock to be similar across all OSes. I set Windows, Mac and Linux to display it on the left
because I am almost 100% of the time on a laptop and the screen is wider than it is high. I also set the dock to
auto-hide and display a few commonly used apps.

Using the super key and typing the first few letters is now my preferred work flow rather than clicking on an
icon in the dock. One thing I like about Ubuntu is that when I’m using multiple monitors it puts the dock on all
the monitors.

----------------------------------------------------------------

## Customizing Gnome - The Tweaks Tool

Ubuntu ships with Gnome as the desktop environment (DE). Unlike Windows, Linux distributions can use a lot of different desktop environments (DE). Gnome is the default desktop environment for Ubuntu and Redhat (CentOS) so it has a large percentage of the desktop market in Linux. If you want to try others there are several official flavors of Ubuntu that you can download from Canonical.

First, install the Gnome Tweak Tool. This tool allows you to change a lot of the Gnome settings to your preference. Open a terminal window, `ctrl+alt+t`, and type the following:

`sudo apt install gnome-tweak-tool`

Press [enter], you will be prompted for your password because of sudo, and the install will start. When it finishes, hit the super key, type

`tweaks`

and hit [enter].

![screenshot](img/tweaks.png)

----------------------------------------------------------------

### Startup Applications

Gnome Tweaks is where you set the applications that run on startup. I try to keep these to a minimum. It's easy to forget that some application is automatically starting and you have forgotten about it.

There are a lot of options that you can "tweak" with the tool. I don't make a lot of changes but I do like having the Top Bar show Day, Data and Time.

----------------------------------------------------------------

## Using the GUI Files application

Files is the file manager for Gnome. The Gnome team is very creative with application names! The text editor is named "Text Editor", I kid you not. It makes Googling for tips a bit of a challenge.

Files works well and has a feature I love – Tabs! Once you get used to having tabs in your file manager it’s hard to use Windows Explorer! Here is a screenshot with three tabs open
and the right click menu showing “Open in Terminal”. You can see how convenient this is. On a Mac, the Finder app has the tabs. I don’t know why Windows doesn’t.

Files has an extensive right click menu. Here are the options for the folder Scripts.

![screenshot](img/Right-Click.png)

----------------------------------------------------------------

### Creating archives

From the right click menu you can select "Compress..." to create an archive. The `Compress...` menu supports:

- zip
- 7zip (Must install 7z `sudo apt install 7zip`)
- tar.xz

----------------------------------------------------------------

### Display the Full path in files

Sometimes you want to copy the full path to a file when working in the file manager. Hit ctrl+l (lowercase el) and the path will change to a format that you can copy.

![screenshot](img/ZIP.png)

----------------------------------------------------------------

### Easily preview files in Files

One thing I missed from Windows Explorer was the preview pane. In Ubuntu running the Gnome desktop you can install "Sushi" to preview files. Then you just hit the space bar to preview a supported file format.

[How to Quickly Preview a File in Ubuntu's File Manager (Like "Quick Look" in macOS)](https://www.howtogeek.com/277987/how-to-quickly-preview-a-file-in-ubuntus-file-manager-like-quick-look-in-macos/)

----------------------------------------------------------------

### Search

**NOTE**: I said that you should use the LTS version of Ubuntu in the first chapter. And I usually do, but Ubuntu 23.10 includes Gnome 45 and I had to have some of the features. And 24.04 is out now so I will be upgrading!

One of the features that I wanted was the completely new "Files" application that is amazing. Here is the announcement from the project [Introducing GNOME 45, “Rīga”](https://release.gnome.org/45/)

One of the best features in Files is the new search. Just click on the magnifying glass next to the address bar and enter some text. Unlike in Windows, you can enter text that is in the middle of the filename. In the screenshot below, I entered "new" and it found "frequent-new.png" in a directory one level down.

![screenshot](img/files-search1.png)

You can click on the funnel icon after you open search and filter on:

- Date
  - Created
    - Last Modified
    - Last Used
- What - There are well over 100 file types to choose from
- Full Text or Filename

Ubuntu has an article on using the new feature here: [Search for files](https://help.ubuntu.com/stable/ubuntu-help/files-search.html.en#:~:text=Open%20the%20Files%20application%20from,shown%20in%20the%20search%20bar.)

Ubuntu also has a [Common Tasks](https://help.ubuntu.com/stable/ubuntu-help/files.html.en#more-file-tasks) page for Files

----------------------------------------------------------------

### Why do I have a red Lock on a file or folder?

Files, like every other GUI file manager, uses icons to represent files and folders. If the icon has a green check mark in it, you have full access to the file or folder.

If the icon has a red lock in it, you don’t have full
permissions to the file or folder.
Here is a screenshot of Files showing one file with a green check mark and one with a red x.

![screenshot](img/red-lock.png)

To take ownership of the file open the terminal and enter:

`sudo chown mhubbard testsync.txt`

You will be prompted to enter your password.

**Reference**

[Meaning of files-folders with a red x](https://askubuntu.com/questions/835588/meaning-of-files-folders-with-a-red-gray-x-on-them/835590)

----------------------------------------------------------------

## Creating a bootable USB stick from an ISO image

You don't need a third-party tool to create a bootable USB stick on Linux if you don't mind using the terminal.

### Use dd to make bootable flash

**NOTE**: Ubuntu uses a system called "snaps" to sandbox applications. The drawback to snaps is that they mount every application using a "squashfs". I use the following alias so that I don't have to see all the applications.

`alias df="df -h --exclude=squashfs"`

I will show you how to create aliases in a later section.

If you create the alias you can use df -h instead of including the --exclude=squashfs option.

- run df -h --exclude=squashfs
- Insert the flash drive
- run df -h --exclude=squashfs

Look for a new entry in the table. For example, on my laptop I have two flash drives mounted.

```bash
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           3.2G  4.0M  3.1G   1% /run
/dev/nvme0n1p2  457G  392G   43G  91% /
tmpfs            16G  219M   16G   2% /dev/shm
tmpfs           5.0M   12K  5.0M   1% /run/lock
efivarfs        384K   80K  300K  21% /sys/firmware/efi/efivars
/dev/nvme0n1p1  513M   31M  483M   6% /boot/efi
tmpfs           3.2G  1.3M  3.2G   1% /run/user/1000
/dev/sdc1       7.5G  4.1G  3.5G  55% /media/mhubbard/C253-EE9A
/dev/sdb1       116G  5.0G  111G   5% /media/mhubbard/LINUX-ARCHI
```

The two flash drives are /dev/sdc1 and /dev/sdb1. I can tell because they are listed as /media/mhubbard which is the mount point for the flash drives.

In this example I am burning System Rescue to the flash drive.
Parameters:

- if - input file name
- of - output filename
- bs - Block size to use
- status=progress - display progress
- && sync - In Linux the "&&" means finish the first command then run the next command. In this case sync the writes to make sure it's ejected cleanly
Enter the following:

`dd if=systemrescue.iso of=/dev/sdb bs=10M status=progress && sync`

**NOTE**: dd is commonly referred to as "disk destroyer", meaning that it starts as soon as you hit enter, there are no "Are you sure" prompts.

MAKE SURE THAT YOU HAVE THE OF (output file) SET TO THE FLASH DRIVE!!

----------------------------------------------------------------

### Use the Ubuntu "Make Startup disk" tool

You can use the built in “Startup disk creator” by tapping the super key (Windows Key) and typing `start`. You will see the Startup disk icon:

![screenshot](img/startup.png)

- Pick the ISO image from the “Source disc image (.iso)” drop down
- Then select the USB stick from "Disk to Use"
- Click “Make Startup Disk”
- You will be prompted to select "Yes or No"

![screenshot](img/startup-disk.png)

In this example, I am burning Kali Linux 2023.3 to the flash drive.

----------------------------------------------------------------

### Use qemu to test a startup disk

You can install qemu and create a simple virtual machine to test a startup disk. I'm not going to cover that but these two articles will explain.

- [How do I install qemu on Ubuntu 23.10?](https://askubuntu.com/questions/1490805/how-do-i-install-qemu-on-ubuntu-23-10)
- [Using QEMU to quickly test an ISO or bootable USB drive](https://makandracards.com/makandra/1192-using-qemu-to-quickly-test-an-iso-or-bootable-usb-drive)

----------------------------------------------------------------

## Working with the Linux File System

If you have been a Windows user for a long time the hardest part of switching to Linux is the file system. There is no concept of drive letters in Linux. The Linux file system is based on the “File system Hierarchy Standard” maintained by the Linux Foundation.

The top of the Linux file system is called the root. All files and directories are referenced from the root, even if they are stored on different physical or virtual devices. That is so different from Windows that it will take some
time to get comfortable with.

Here is a link to a great tutorial on the Linux file system by Abhishek Prakash - [Linux Directory Structure Explained for Beginners](https://linuxhandbook.com/linux-directory-structure/). His tutorial will get you up to speed on the Linux file system. Abhishek creates Linux tutorials and I recommend that you sign up for his newsletter. The subscribe button is at the top of the page.

On Windows you have drive letters and the root of the file system is the “\” character – The good old C:\. But Linux/Mac, or any *NIX for that matter, doesn’t use drive letters. The file system is usually described as a tree
with root at the beginning. Root is shown in the file system as /. Everything is then displayed off the root. The “/” is another difference that will take a while to get used to. Unix/Linux/Mac use a forward slash instead of the backslash “\” for file system commands. When you use a web browser, you use the forward slash for file commands – <https://github.com/rikosintie> for example.

----------------------------------------------------------------

### LSBLK

For a quick look at block devices (hard drives, thumb drives, nvme, etc.) on the system, you can use the "list block devices" command - lsblk. Here is an lsblk listing on my Dell laptop which has an m.2 NVME drive with the OS on it and 1TB SSD for data.

```bash
$ lsblk -e7
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda           8:0    0 931.5G  0 disk /media/mhubbard/Data
nvme0n1     259:0    0 465.8G  0 disk
├─nvme0n1p1 259:1    0 513.1M  0 part /boot/efi
└─nvme0n1p2 259:2    0 465.3G  0 part /
```

Notice that I included -e7 on the end of the `lsblk` command. That is because Ubuntu uses "snaps" for a lot of applications and the show up as "loop" devices in lsblk. The -e means exclude and 7 is the number loop devices.

So you can see that I have an NVME drive called nvme01n1. There are two partitions on the nvme drive:

- nvme01n1p1
- nvme01n1p2

P1 is the boot partition and p2 has the operating system. Notice
that nvme0n1p2 is type partition and mount is /. That means nvme0n1p2 is the root of the file system.

There is also a "block device" named sda. This is a 1TB SATA SSD drive and it's mounted at /media/mhubbard/Data off the root.

![screenshot](img/Drives.png)

The display needs a little explanation. For the disk labeled “Ubuntu” it says 45.4 GB / 490.6 GB available.
That actually means it’s a 490.6GB drive with 45.4GB available.

Once you get used to it, this seems more intuitive and easier to scale than the drive letter model used by Windows. You will also notice in the lsblk output that Linux/Mac, and again all *NIX systems, use the forward
slash as a delimiter rather than the backslash.

Linux has many “ls” commands for listing things:

- lsblk – list block level devices like disk drives, thumb drives, etc.
- lspci – list the PCI bus devices on the system
- lsusb – list USB bus devices
- lsof – list open files
- lslogins – list logins
- lsmod – list the status of modules inserted into the kernel

I will cover each of these a later in this section.

To list the commands that start with "ls" you can type ls and press [tab]. This works with any Linux command. Just like in a Cisco switch, Linux has "tab completion" but it will also show you a list f all commands that match.

```bash
$ ls
ls           lsattr       lsb_release  LSCOLORS     lsdiff       lsinitramfs  lslocks      lsmem        lsns         lspci        lspgpot      lsusb
lsa          lsblk        LS_COLORS    lscpu        lshw         lsipc        lslogins     lsmod        lsof         lspcmcia     lspower

```

----------------------------------------------------------------

### LSUSB

lsusb
Linux makes it easy to see what USB devices are connected, who the manufacturer is and what the Product ID (PID) and Vendor ID (VID) are.

In this example, I have a USB to Serial adapter connected. It uses the Future Technology Devices International (FTDI) UART. It’s connected to Bus 001, the Vendor ID is 0403, and the Product ID is 6001.

```bash
lsusb
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 001 Device 002: ID 0c45:6a08 Microdia
Bus 001 Device 003: ID 8087:0aaa Intel Corp.
Bus 001 Device 006: ID 0403:6001 Future Technology Devices International, Ltd FT232 USB-Serial (UART) IC
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
```

This is a very useful command once you make it part of your skill set. Anytime you connect a USB device you can quickly see who the manufacturer of the chipset is. This is especially useful if the device isn’t working correctly and want to Google for some information.

Another command that will help here is dmesg. This displays the system messages that have been logged. With the `lsusb` command above you can see a Future Technology USB-Serial adapter has been inserted.

If I run:

```bash
dmesg | grep FT232
[83003.234941] usb 1-3: Product: FT232R USB UART
[83003.242719] usb 1-3: Detected FT232RL
[106493.653320] usb 1-3: Detected FT232RL
```

You can see that the system logged the insertion of the UART.
To see what kernel module is loaded for the UART (Note – I am only showing the UART module. Other USB kernel modules were displayed):

```bash
lsmod | grep usb
usbserial
49152 3 ftdi_sio
```

In this example the Future Technology USB-Serial adapter is working correctly but you would do the same things to troubleshoot a device that wasn’t working.
The big difference over Windows is that support for a device in Linux is built into the kernel and loads when the device is inserted.

There are cases where there is no support in the kernel and you will have to go to the manufacturer’s site and download a kernel module (driver in Windows).

The steps above will quickly let you
know that the device isn’t being discovered by Linux

----------------------------------------------------------------

## SSH

I highly recommend [SSH Mastery](https://mwl.io/nonfiction/tools#ssh) by Michael Lucas. It’s available at [SSH Mastery](https://mwlucas.gumroad.com/l/CngLH) or [Amazon](https://www.amazon.com/). When I switched to Linux my only experience with SSH was Putty. There is so much more to SSH and Michael explains all of it.

----------------------------------------------------------------

### OpenSSH Server

Ubuntu comes with an SSH client. If you want to be able to ssh back into your laptop or send files to network devices using SCP you need to install and configure the Open-ssh server. Follow these instruction to enable the SSH server:

```bash
sudo apt update
sudo apt install ssh
```

----------------------------------------------------------------

### Useful SSH system commands

- sudo systemctl start ssh - Start the SSH server
- sudo systemctl stop ssh - Stop the SSH server
- systemctl status ssh - Show server status
- sudo systemctl disable ssh – disables SSH server after next reboot
- sudo systemctl enable ssh – enables SSH after the next reboot.

The OpenSSH server configuration file is located at `/etc/ssh/ssh_config`. To edit the configuration file use the following `sudo nano /etc/ssh/ssh_config` command.

Reference:

[How to Set Up and Use SSH in Linux](https://www.maketecheasier.com/setup-enable-ssh-ubuntu/)

----------------------------------------------------------------

### Connecting to Network Devices

*nix systems like macOS and Linux have the SSH client installed by default.

To connect using ssh:

- Open the terminal
- Enter the following command. Change the username and IP address to fit your device.

`ssh mhubbard@192.168.10.50`

### Run network commands remotely

You can also run commands remotely on the network device using ssh. For example, to execute `show running-configuration` use:

```bash
ssh 192.168.10.253 show run
(mhubbard@192.168.10.253) Password:
DECOM___MCI-KSC-SW1 line 2

Building configuration...

Current configuration : 17541 bytes
!
! Last configuration change at 23:34:18 PDT Thu Jul 4 2024 by mhubbard
! NVRAM config last updated at 16:19:00 PDT Tue Jul 9 2024
.
.
.
end
```

But you can also use bash commands to get just what you need. For example, let's say I want to know what `ip ssh` commands are in the running configuration.

```bash
ssh 192.168.10.253 show run | grep "ip ssh"
(mhubbard@192.168.10.253) Password:
ip ssh source-interface Vlan10
ip ssh rsa keypair-name SSH-KEYS
ip ssh version 2
ip ssh dh min size 4096
ip ssh server algorithm mac hmac-sha2-256 hmac-sha2-512
ip ssh server algorithm encryption aes256-ctr aes192-ctr aes128-ctr
ip ssh server algorithm kex diffie-hellman-group14-sha1
Connection to 192.168.10.253 closed by remote host.
```

### Network Devices with legacy ciphers

One problem for a network engineer is that newer versions of the OpenSSH client don’t allow weak ciphers. Most network devices have weak ciphers by default.

If you are connecting to network devices from a modern version of Mac/Linux you will probably get an error and the connection will fail. You will have to customize the `~/.ssh/config` file because they don't support modern crypto!

This is an example trying to connect to Cisco 3850 IOS XE switch running 16.12.x:

```bash
Unable to negotiate with 192.168.10.253 port 22: no matching key exchange method found. Their offer: diffie-hellman-group14-sha1
```

Here is the entry I added to ~/.ssh/config::

```bash
nano ~/.ssh/config
Host 192.168.10.253
        KexAlgorithms diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1,diffie-hellman-group1-sha1
        MACs hmac-sha1,hmac-sha2-256,hmac-sha2-512
        HostKeyAlgorithms ssh-rsa
```

You can add the key file if you have more than one and a custom port if needed:

```bash
Host 192.168.10.253
    KexAlgorithms diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1,diffie-hellman-group1-sha1
    MACs hmac-sha1,hmac-sha2-256
    HostKeyAlgorithms ssh-rsa
    IdentityFile ~/.ssh/id_custom_25519
    Port 45005
```

To use a specific key on the fly:
`ssh -i ~/.ssh/id_custom_25519  192.168.10.253`

I have tried to connect to network devices that required the ancient dss HostKeyAlgorithm. Add that with:
`HostKeyAlgorithms ssh-dss`

### Using a wildcard in the configuration file

If you have 100s or 1000s of devices with legacy crypto it gets painful to create an entry in `~/.ssh/config` for every device. You can use a wildcard in the configuration file that will pass the same configuration to every connection.

This is not the best solution because it can lead to a downgrade attack on a device that supports modern ciphers and legacy ciphers. But if you want to take the risk here is how to do it:

```bash
nano ~/.ssh/config
Host *
        Protocol 2
        HostKeyAlgorithms ssh-rsa,ssh-dss
        MACs hmac-sha2-512,hmac-sha2-256
        KexAlgorithms diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1,diffie-hellman-group1-sha1
        ```

Add any settings that are common to your devices.

### Debugging SSH connections

You can use the -v switch to debug the SSH connection. You can repeat the v up to 4 times - -vvvv. Each extra v adds more details to the output.

On most switches you can use something like `show ip ssh` to get a list of the current ssh ciphers. You can also use nmap. This is from the Ubiquiti Nano Station in my home lab.

```bash
sudo nmap -sV --script ssh2-enum-algos 192.168.10.50
Starting Nmap 7.95 ( https://nmap.org ) at 2024-07-08 16:36 PDT
Nmap scan report for office.pu.pri (192.168.10.50)
Host is up (0.020s latency).
Not shown: 996 closed tcp ports (reset)
PORT      STATE SERVICE    VERSION
22/tcp    open  ssh        Dropbear sshd (protocol 2.0)
| ssh2-enum-algos:
|   kex_algorithms: (6)
|       curve25519-sha256
|       curve25519-sha256@libssh.org
|       diffie-hellman-group14-sha256
|       diffie-hellman-group14-sha1
|       diffie-hellman-group1-sha1
|       kexguess2@matt.ucc.asn.au
|   server_host_key_algorithms: (2)
|       ssh-rsa
|       ssh-dss
|   encryption_algorithms: (2)
|       aes128-ctr
|       aes256-ctr
|   mac_algorithms: (2)
|       hmac-sha1
|       hmac-sha2-256
|   compression_algorithms: (1)
|_      none
80/tcp    open  http       lighttpd 1.4.54
|_http-server-header: lighttpd/1.4.54
443/tcp   open  ssl/http   lighttpd 1.4.54
|_http-server-header: lighttpd/1.4.54
10001/tcp open  tcpwrapped
MAC Address: FC:EC:DA:C4:6E:55 (Ubiquiti)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 17.98 seconds
```

As you can see, it has good crypto like curve 25519 and aes256-ctr but then it also supports rsa-dss and diffie-hellman group1 sha1! Why?

----------------------------------------------------------------

### Creating SSH Keys

The OpenSSH client allows you to create custom SSH keys. You can create as many keys as you need. You should think about your security requirements and create SSH keys to fit the requirements. For example, if you work for a VAR or MSP, you may want to create unique keys for each customer.

My current recommended cipher is Bruce Schnierer's ED25519. To create a set of keys using ed25519 run the following in the terminal from the ~/.ssh directory:

`ssh-keygen -a 100 -o -C "$(whoami)@$(uname -n)-$(date -I)" -f id_custom_25519 -t ed25519`

-o Use the new RFC4716 key format and the use of a modern key derivation function powered by bcrypt.

-a 100 Use 100 rounds of pbkdf2 (password based key derivation 2)

-t Specifies the type of key to create. The choices are dsa | ecdsa | ecdsa‐sk | ed25519 | ed25519‐sk | rsa

dsa and rsa are not good choices. DSA was deprecated in 2016 and RSA in 2018. The keys with -sk at the end are for use with `physical security keys`. See the "Yubico" topic later in this section for more information.

-C Specifies a comment to be added to the public key to make it easier to identify the key in the known_hosts file.

Specify a strong passphrase when prompted. The passphrase is required anytime you use the key. If you don’t password protect the key, and an attacker gets access to the keys, they can log into any server you used them on.

Here is what the output of the command should look like:

```bash
ssh-keygen -a 100 -o -C "$(whoami)@$(uname -n)-$(date -I)" -f id_custom_25519 -t ed25519
Generating public/private ed25519 key pair.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in id_custom_25519
Your public key has been saved in id_custom_25519.pub
The key fingerprint is:
SHA256:4alqMRHMO/O91aJjlON2NLOUVcwZ5WLBVpcIaOFKylw mhubbard@HP8600-2328.local-2024-07-08
The key's randomart image is:
+--[ED25519 256]--+
|   o     .o..++==|
|    +   .o   .B+.|
|     o Eo.   oo .|
|    B +..o  .. . |
|     O oS. +     |
|    o ..= O .    |
|     o.o B =     |
|    ..  B o      |
|   ..  o o       |
+----[SHA256]-----+
```

Here is what the public key looks like with the comment:

```bash
cat id_custom_25519.pub
       │ File: id_custom_25519.pub
       │ ssh-ed25519·AAAAC3NzaC1lZDI1NTE5AAAAINCnTz475PiCydfW10kXIwPqpRpufeeuicoY9NLUndbt·mhubbard@HP8600.local-2024-07-08
```

You can see my username, hostname and date at the end.

### Display the existing keys on your system

Note: I always start my key names wih `id_`. If you don't, you will need to modify the `~/.ssh/id_*` section of the next command.

`for keyfile in ~/.ssh/id_*; do ssh-keygen -l -f "${keyfile}"; done | uniq`

- DSA or RSA 1024 bits: This is a red flag. Unsafe.
- RSA 2048: This is a yellow flag, recommended to change
- RSA 3072/4096: Good, but ED25519 is better!
- ECDSA: depends. Recommended to change
- ED25519: The best choice!

Here is what it looked like on my laptop.

```bash
for keyfile in ~/.ssh/id_*; do ssh-keygen -l -f "${keyfile}"; done | uniq
256 SHA256:2uWbzS9A/4dI+ZS+bM8f5q6wTqeb8vsBvylvQi5B9dE mhubbard@1S1K-G5-5587-2024-07-08 (ED25519)
256 SHA256:2XtMiDbg64rBnUXOzcFFXqwzUbbAjAO2Y9RwrWvVTB4 michael.hubbard999@gmail.com (ED25519)
2048 SHA256:WFuzqdjjnEVd+tW+2fKz1dEKVzK+vfjhgvsCGlSZrrk mhubbard@1S1K-G5-5587 (RSA)

```

You can see the comment on the first key.

### SSH Key permissions

The private key should have rw to only the user. No other users or groups should have any permissions. Use the following to view/set the permissions:

```bash
ls -l
-rw-------    1 mhubbard  staff   464B Jul  8 15:54 id_custom_25519
-rw-r--r--    1 mhubbard  staff   108B Jul  8 15:54 id_custom_25519.pub

If the permissions are wrong, use the following:
chmod 600 ~/.ssh/id_custom_25519
```

### Yubico Authenticator

Yubico is one of the company that makes Physical Security keys. These allow you to copy your private key to the Yubico and have access no matter what laptop you are on. It's beyond the scope of this guide but here are links to Yubico.

- [Highest assurance authentication that’s fast and easy](https://www.yubico.com/products/yubikey-5-overview/)
- [Securing SSH Authentication with FIDO2](https://developers.yubico.com/SSH/Securing_SSH_with_FIDO2.html)

### Reference

- [Upgrade your SSH keys!](https://blog.g3rt.nl/upgrade-your-ssh-keys.html) - In this post I'll demonstrate how to transition to an Ed25519 type of key smoothly, why you would want this and show some tips and tricks on the way there.
- [ssh keys](https://wiki.archlinux.org/title/SSH_keys) - As always, the Arch wiki has a great page on ssh
- [Authenticating to Cisco devices using SSH and your RSA Public Key](https://mwhubbard.blogspot.com/2015/07/authenticating-to-cisco-devices-using_92.html) - Here is a blog post I did on setting up the network device to use ssh keys.

----------------------------------------------------------------

## Gnome System Tool (GUI)

Gnome includes a tool like “service.msc” on Windows. You start it by tapping the super key and typing “System". Here is a screenshot of the "Processes" panel.

![screenshot](img/Gnome-System.png)

Like in Windows, you can right click and select an action:

![screenshot](img/Gnome-Right-Click.png)

Here is a screenshot of the "Resources" panel

![screenshot](img/Gnome-Resources.png)

Here is a screenshot of the "File Systems" panel

![screenshot](img/Gnome-FileSystems.png)

You can see that my laptop boots off a 500GB nvme disk and has a 1TB drive (sdb) for storage.

----------------------------------------------------------------

## Working with services

Ubuntu uses an "init system" called systemd to start and control services. At first it seems confusing and a little difficult compared to  “services.msc” on Windows. But like most things, after you do it a few times it’s very logical and easy to use. Here is a cheat sheet for systemd.

| Viewing Systemd Information |                                      |
|-----------------------------|--------------------------------------|
| systemctl list-dependencies | Show a unit's dependencies           |
| systemctl list-sockets      | List sockets and what activates      |
| systemctl list-jobs         | View active systemd jobs             |
| systemctl list-unit-files   | See unit files and their states      |
| systemctl list-units        | Show if units are loaded/active      |
| systemctl get - default     | List default target (like run level) |

**Example**

```bash
systemctl list-dependencies ufw
ufw.service
● ├─system.slice
● ├─local-fs.target
● │ ├─-.mount
● │ ├─boot-efi.mount
○ │ ├─systemd-fsck-root.service
● │ └─systemd-remount-fs.service
● └─network-pre.target
```

----------------------------------------------------------------

| Working with Services            |                                         |
|----------------------------------|-----------------------------------------|
| systemctl stop service           | Stop a running service                  |
| systemctl start service          | Start a service                         |
| systemctl restart service        | Restart a running service               |
| systemctl reload service         | Restart a running service               |
| systemctl status service         | See if service is running/enabled       |
| systemctl enable service         | Enable a service to start on boot       |
| systemctl disable service        | Disable a service - won't start at boot |
| systemctl -H host status network | Run any systemctl command remotely      |

The difference between start and enable is that you use enable to set the service to start on boot. If you just run "start" the service will be started but on reboot the service will not be started.

**Example**

```bash
systemctl status ufw
● ufw.service - Uncomplicated firewall
     Loaded: loaded (/lib/systemd/system/ufw.service; enabled; preset: enabled)
     Active: active (exited) since Mon 2024-07-01 17:42:00 PDT; 1 day 4h ago
       Docs: man:ufw(8)
   Main PID: 1713 (code=exited, status=0/SUCCESS)
        CPU: 89ms

Jul 01 17:41:59 1S1K-G5-5587 systemd[1]: Starting ufw.service - Uncomplicated firewall...
Jul 01 17:42:00 1S1K-G5-5587 systemd[1]: Finished ufw.service - Uncomplicated firewall.
```

----------------------------------------------------------------

| Changing System states |                                            |
|------------------------|--------------------------------------------|
| systemctl reboot       | Reboot the system        |
| systemctl poweroff     | Power off the system    |
| systemctl emergency    | Put in emergency mode   |
| systemctl default      | Back to default target |

## Viewing Log Messages

| Viewing Log Messages           |                                 |
|--------------------------------|---------------------------------|
| journalctl                     | Show all collected log messages |
| journalctl -u network.services | See network service messages    |
| journalctl -f                  | Follow messages as they appear  |
| journalctl -k                  | show only kernel messages       |
| journalctl -e                  | Jump to the end                 |

**Example**

```bash
journalctl -e | grep clam
Jul 02 19:00:01 1S1K-G5-5587 CRON[1218459]: (mhubbard) CMD (clamav sleep $((RANDOM % 42)); venv/bin/fangfrisch --conf /etc/fangfrisch.conf refresh)
Jul 02 19:10:01 1S1K-G5-5587 CRON[1226306]: (mhubbard) CMD (clamav sleep $((RANDOM % 42)); venv/bin/fangfrisch --conf /etc/fangfrisch.conf refresh)
Jul 02 19:20:01 1S1K-G5-5587 CRON[1234175]: (mhubbard) CMD (clamav sleep $((RANDOM % 42)); venv/bin/fangfrisch --conf /etc/fangfrisch.conf refresh)
Jul 02 19:30:01 1S1K-G5-5587 CRON[1242328]: (mhubbard) CMD (clamav sleep $((RANDOM % 42)); venv/bin/fangfrisch --conf /etc/fangfrisch.conf refresh)
```

## Locating files from the terminal

The locate tool allows you to search everywhere on the file system.

`sudo apt install mlocate` – Install the tool
`sudo updatedb` - Updates the database, run this periodically especially if you modify the configuration file.

To configure locate:
These two articles have detailed information on customizing locate.
    • [configure locate](https://linux.die.net/man/5/updatedb.conf) - configure locate
    • [Linux locate command practical examples](https://www.tecmint.com/linux-locate-command-practical-examples/)

**Example**

```bash
locate apsum.py
/home/mhubbard/Insync/michael.hubbard999@gmail.com/GoogleDrive/Python/Scripts/prod/apsum.py
```

### Drill - A graphical and CLI tool for searching files

From the website, “Search files without indexing, but clever crawling. It uses a different algorithm than most search tools and doesn't use a database like the the Ubuntu locate utility. It will search every mount point on the computer and is multithreaded so that it can search many at once. It will also use all available RAM to speed up the search.”

In the GUI, just enter any part of the filename that you can remember. It's not case sensitive and will find the string anywhere in the name.
From the website, Download Drill, you can download the GUI (.deb) and the cli (CLI .deb). It is also available as an appimage if you don't want to install it.

**Example**

```bash
drill-search-cli apsum.py
/home/mhubbard/Insync/michael.hubbard999@gmail.com/GoogleDrive/Python/Scripts/prod/apsum.py
```
