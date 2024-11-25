# Introduction

![screenshot](img/Tux-Tools.png)

----------------------------------------------------------------

:arrow_forward: KEY TAKEAWAYS

- Linux has many different tools for working with files and networks built in.
- Ubuntu is built off of Debian Linux so any tools that are compatible with Debian will probably work on Ubuntu.
- Ubuntu comes with the [The app store for Linux](https://snapcraft.io/) built in. Thousands of applications are available.
- Ubuntu works with [Flat Pack](https://flathub.org/) applications.
- Ubuntu works with [App Images](https://appimage.org/). Linux apps that run anywhere!
- If you are coming from MacOS, you can use [Homebrew](https://docs.brew.sh/Homebrew-on-Linux) to install packages.
- Thousands of networking tools are available on [github](github.com)
- Packet Pushers network maintains a list of [Open Source Networking Projects](https://packetpushers.net/blog/open-source-networking-projects/). Most work on Ubuntu.

----------------------------------------------------------------

## Flatpak Applications

Flatpak is a standard way to install Linux applications across distributions. The Flatpak store is located [here](https://flathub.org/). There are Thousands of applications that you can browse and install. Most are free open source software (FOSS). Some will have a `Donate` button. If you install the application and find it useful please go back an donate.

### Install Flatpak

Open a terminal (ctrl+alt+t) and run the following commands:

```bash
sudo apt update
sudo apt install flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

Unfortunately you do have to restart after running the commands.

Once your system restarts we are going to install four applications for managing the system.

----------------------------------------------------------------

### Gnome Extensions

![screenshots](img/Extensions.png)

The first application is `Gnome Extensions`

Gnome Extensions handles updating extensions, configuring extension preferences and removing or disabling unwanted extensions.

**Installation Instructions**

```bash
flatpak install flathub org.gnome.Extensions
```

Once installed you run `Extensions` from the terminal using:

```bash
flatpak run org.gnome.Extensions
```

Or by tapping the Super key, typing extens and clicking on the Extensions icon

----------------------------------------------------------------

### Gnome Resources

 ![screenshot](img/resources.png)

Gnome Resources is similar to the Windows Task Manager. Here is a [link](https://apps.gnome.org/Resources/) to the homepage describing Resources.

**Installation Instructions**

```bash
flatpak install flathub net.nokyan.Resources
```

Once installed you run `Resources` from the terminal using:

```bash
flatpak run net.nokyan.Resources
```

Or by tapping the `Super` key, typing res and clicking on the Resources icon

----------------------------------------------------------------

### Flatseal

![screenshot](img/Flatseal.png)

Flatseal is a graphical utility to review and modify permissions from your Flatpak applications. This application allows you to look at all your installed Flatpak applications and verify their permissions.

**Installation Instructions**

```bash
flatpak install flathub com.github.tchx84.Flatseal
```

Once installed you run `Flatseal` from the terminal using:

```bash
flatpak run com.github.tchx84.Flatseal
```

Or by tapping the `Super` key, typing flat and clicking on the Flatseal icon

----------------------------------------------------------------

### Gnome Disk Usage analyzer

![screenshot](img/DiskUsage.png)

**Installation Instructions**

```bash
flatpak install flathub org.gnome.baobab
```

Once installed you run `Flatseal` from the terminal using:

```bash
flatpak run org.gnome.baobab
```

Or by tapping the `Super` key, typing disk and clicking on the disk  icon

```bash
flatpak run org.gnome.baobab
```

Disk Usage analyzer is similar to disk usage tools on Windows and Mac. Here is a screenshot of the disk usage on my home folder:

![screenshot](img/DiskUsage-Graph.png)

I hovered over one of the large blocks and is tells me that is the secito of disk holding my Inbox.

----------------------------------------------------------------

Now that we have the four management applications installed let's find some tools useful to a network engineer!

----------------------------------------------------------------

----------------------------------------------------------------

FreeCAD
Draw.io

----------------------------------------------------------------

## The Ubuntu App store

### PacketSender

![screenshot](img/PacketSender.png)

A cross platform open source tool. Available for Mac, Linux, Windows.

**Features**
Packet Sender can send and receive UDP, TCP, SSL, and DTLS on the ports of your choosing. It also has a built-in HTTP client for GET/POST requests and Panel Generation for the creation of complex control systems.

Common Uses
Packet Sender was designed to be very easy to use while still providing enough features for power users.

• Test automation
Using its command line tool or hotkeys

• Testing network APIs
Using the built-in UDP/TCP/SSL/DTLS clients

• Malware analysis
using the built-in UDP/TCP/SSL/DTLS servers

• Panel Generation
Create single-button panels that trigger a series of commands for control systems.

• Testing HTTP
Single-button GET/POST requests for control systems.

• Intense Traffic
Flood at a particular rate to stress-test devices

• Testing network connectivity/firewalls
by having 2 Packet Senders talk to each other

• Tech support
by sending customers a portable Packet Sender with pre-defined settings and packets

• Security research
Send SSL and then analyze the traffic log.

**Installation Instructions**
