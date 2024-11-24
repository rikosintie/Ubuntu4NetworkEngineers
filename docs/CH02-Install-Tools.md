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

## Gnome Extensions

WHile the Ubuntu project ships with Canonical's `Snap Packages` the Gnome project prefers Flatpaks. There are three flatpak extensions that we will install now.

----------------------------------------------------------------

### First install Flatpak

Open a terminal (ctrl+alt+t) and run the following commands:

```bash
sudo apt update
sudo apt install flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
``


----------------------------------------------------------------

The first extension is `Gnome Resources` which is similar to the Windows Task Manager. Here is a [link](https://apps.gnome.org/Resources/) to the homepage describing Resources.

Once installed you run `Resources` from the terminal using:

```bash
flatpak run net.nokyan.Resources
```

Or by tapping the `Super` key, typing res and clicking on the Resources icon

 ![screenshot](img/resources.png)


----------------------------------------------------------------

FreeCAD
