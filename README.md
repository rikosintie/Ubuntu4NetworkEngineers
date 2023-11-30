# The Ubuntu for Network Engineers Cookbook<!-- omit from toc -->

A guide to network engineering with Ubuntu

<p align="center" width="100%">
    <img width="60%" src="https://github.com/rikosintie/Ubuntu4NetworkEngineers/blob/main/images/penquin.jpg">
</p>

Advance your “Network Engineer of the future” career with the OS of the Cloud

----------------------------------------------------------------

The following conventions are used in “Ubuntu for Network Engineers”:

- Italic
  - Used for URLs, email addresses, acronyms, filenames, and new terms.
- Constant Width (Consolas Typeface)
  - Used for program listings and terminal command output
- Constant Width Bold (Consolas Typeface)
  - Text that should be typed into the terminal
- Constant Width Italic
  - Text that should be replaced by user supplied values

----------------------------------------------------------------

## Installing Ubuntu

The first question is should I just spin up a virtual machine or use bare metal. I used Linux for a few years as a VM before I bought dedicated hardware. The advantage of using a VM is that if you damage it or decide for any reason it’s not the right distribution you can just delete it and try another one. The drawback to a VM is that the hypervisor hides the hardware so you don’t really get the experience of installing, configuring and maintaining Linux.

My suggestion if you have never touched Linux is to install Ubuntu as a VM and get some experience with it. You won’t have to spend any money, Ubuntu is free, although I usually donate $10 when I download it to install on a fresh machine, and you can run any of the tools in this book.

I have Kali running on a System 76 Gazelle laptop and Ubuntu on a Dell G5 laptop. I did this because I wanted to get my Linux certifications and I felt that I needed to be running Linux on my daily driver to really learn. The
VM can do just about anything the bare metal can do but when I would get stuck on something I would just shut it down and go back to Windows instead of figuring it out.

There are a lot of good tutorials on installing Ubuntu available on the Internet so I am not going to cover it here. It is actually very easy, pretty much click, click, next, reboot! The site [linux config](https://linuxconfig.org) has a lot of great Ubuntu tutorials, here is link to a tutorial on installing 22.04 – [How to install Ubuntu 22.04 Jammy Jellyfish Desktop](https://linuxconfig.org/how-to-install-ubuntu-22-04-jammy-jellyfish-desktop).

NOTE: Ubuntu has two types of releases

- LTS releases - Every two years on even years. So 22.04 is the long term release from 2022.
- Interim Releases - Released in October and April. So 22.10, 23.04, and 23.10 are interim releases after the LTS 22.04. The next LTS will be 24.04.

The LTS releases are rock solid but they don't get new features or the latest kernel versions. If you put Ubuntu on bare metal and use it as your daily driver I recommend that you use an LTS release.

**Appendix A** covers the installation I did on a Dell G5 laptop that wasn’t 100% compatible out of the box. It took a lot more time than I expected to get everything working on the Dell and I documented the steps in the Appendix. Dell and System 76 both sell laptops with Ubuntu pre-installed.

Even if you buy a System 76 or Dell laptop with Ubuntu preinstalled you may still want to take a look at the Appendix since I documented some things like customizing the Grub boot loader and running nVidia and Intel
graphics.

In this book I am going to document the tools that I found useful in the transition to Linux for network engineering tasks.

**A note on encryption.** Ubuntu supports the Linux LUKS full disk encryption. During setup you can select the encrypt full disk option. This is, of course, a good idea for security but if you encrypt and then decide you don’t want it you will need to decrypt the disk. Use the instructions here to decrypt the LUKS volume:
[How to remove LUKS encryption](https://unix.stackexchange.com/questions/60971/how-to-remove-luks-encryption)

----------------------------------------------------------------

## Using Ubuntu

Switching from Windows to Ubuntu with the Gnome desktop is both easy and hard. How can that be? It's simple, the basic operation of the desktop is similar to Windows. The file manager (Nautilus) is similar to Windows Explorer and of course Chrome or Firefox work just like they do in Windows including syncing, Extensions, etc. There is a keyboard button called the superkey (on most keyboards it will have the Windows logo) just like the Windows key. You tap it and search for an application or pick from the running applications.

So, what is the hard part? Things like killing a hung application, searching for files from the terminal, checking free disk space are different and will take a little getting used to. Since MacOS is based on Open BSD Unix,
once your muscle memory is up to speed you will be able to jump back and forth easily between Windows, Mac and Linux. In a later chapter I will discuss the terminal tools that make Linux so much fun and so powerful for
a network engineer.

One of the big advantages for the Linux desktop is that you can customize almost everything since it’s free and open source. You can change the terminal you use, the file manager, the way almost anything works and even the desktop itself.

The most popular desktop environments (DE) for Linux are Gnome (Ubuntu’s default), and KDE (which is available on Ubuntu) but there are many more. I use the computer for work and just learned to customize Gnome to fit my workflow but I use Terminator for my terminal app.

I listen to a lot of podcasts and KDE Plasma, XFCE and MATE are highly recommended desktop environments (DE) that you may like better than Gnome. If you watched the second episode of Mr. Robot (Season 1 – which I highly recommend) there is a scene were an executive tells Elliot that he runs KDE but
understands why Elliott prefers Gnome.

These two short YouTube videos sum it up better than I can:

- [6 Things to Know When Switching to Linux from Windows](https://www.youtube.com/watch?v=wcdquhB6hT8)
- [10 things you can do with Linux that you can't do with Windows](https://www.youtube.com/watch?v=JOOkfGv58u0)

### Podcasts on Linux

There are a lot of podcasts dedicated to Linux. In your podcast application just search Linux. My favorites are:

- Destination Linux - A weekly podcast on general Open Source topics.
- Linux Unplugged - A weekly podcast on Linux by Jupiter Broadcasting. Covers news and applications for Linux.
- Late Night Linux - A weekly podcast on Linux and the wider tech industry.
- Linux After Dark - A weekly podcast on Linux experiences.
- Linux Downtime - A weekly podcast "From working in the Industry and progressing your career, to managing a projects community"

### Casting your display

I have a Vizio “Smart” TV with Chromecast built in. Using the Chrome browser I can click the three dot menu on the right and select “Cast...” to send the output to the TV.

In VLC, select “Playback, Renderer” to send VLC’s output to the TV. I don’t have a Chromecast dongle, but I am guessing it would work the same way as the Vizio TV.
