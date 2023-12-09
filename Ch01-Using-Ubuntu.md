- [Using Ubuntu](#using-ubuntu)
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
  - [Managing Files](#managing-files)
    - [Creating archives](#creating-archives)
    - [Display the Full path in files](#display-the-full-path-in-files)
    - [Easily preview files in Files](#easily-preview-files-in-files)
    - [Search](#search)
    - [Why do I have a red Lock on a file or folder?](#why-do-i-have-a-red-lock-on-a-file-or-folder)
  - [Creating a bootable USB stick from an ISO image](#creating-a-bootable-usb-stick-from-an-iso-image)
    - [Use dd to make bootable flash](#use-dd-to-make-bootable-flash)
    - [Use the Ubuntu "Make Startup disk" tool](#use-the-ubuntu-make-startup-disk-tool)
    - [Use qemu to test a startup disk](#use-qemu-to-test-a-startup-disk)

----------------------------------------------------------------

# Using Ubuntu

Switching from Windows to Ubuntu with the Gnome desktop is both easy and hard. How can that be? It's simple, the basic operation of the desktop is similar to Windows. The file manager (Files) is similar to Windows Explorer and of course Chrome or Edge work just like they do in Windows including syncing, extensions, etc. There is a keyboard button called the superkey (on most keyboards it will have the Windows logo) just like the Windows key. You tap it and search for an application or pick from the running applications.

So, what is the hard part? Things like killing a hung application, searching for files from the terminal, checking free disk space are different and will take a little getting used to. Since MacOS is based on Open BSD Unix,
once your muscle memory is up to speed you will be able to jump back and forth easily between Windows, Mac and Linux. In a later chapter I will discuss the terminal tools that make Linux so much fun and so powerful for
a network engineer.

One of the big advantages for the Linux desktop is that you can customize almost everything since open source. You can change the terminal you use, the file manager, the way almost anything works and even the desktop itself.

The most popular desktop environments (DE) for Linux are Gnome (Ubuntu’s default), and KDE (which is available on Ubuntu) but there are many more. I use the computer for work and just learned to customize Gnome to fit my workflow but I use Terminator for my terminal app.

I listen to a lot of podcasts and KDE Plasma, XFCE and MATE are highly recommended desktop environments (DE) that you may like better than Gnome. If you watched the second episode of Mr. Robot (Season 1 – which I highly recommend) there is a scene were an executive tells Elliot that he runs KDE but
understands why Elliott prefers Gnome.

These two short YouTube videos sum it up better than I can:

- [6 Things to Know When Switching to Linux from Windows](https://www.youtube.com/watch?v=wcdquhB6hT8)
- [10 things you can do with Linux that you can't do with Windows](https://www.youtube.com/watch?v=JOOkfGv58u0)

## Podcasts on Linux

There are a lot of podcasts dedicated to Linux. In your podcast application just search Linux. My favorites are:

- Destination Linux - A weekly podcast on general Open Source topics.
- Linux Unplugged - A weekly podcast on Linux by Jupiter Broadcasting. Covers news and applications for Linux.
- Late Night Linux - A weekly podcast on Linux and the wider tech industry.
- Linux After Dark - A weekly podcast on Linux experiences.
- Linux Downtime - A weekly podcast "From working in the Industry and progressing your career, to managing a projects community"
- This Week in Linux - A weekly podcast on Linux

## Casting your display

I have a Vizio “Smart” TV with Chromecast built in. Using the Chrome browser I can click the three dot menu on the right and select “Cast...” to send the output to the TV.

In VLC, select “Playback, Renderer” to send VLC’s output to the TV. I don’t have a Chromecast dongle, but I am guessing it would work the same way as the Vizio TV.

----------------------------------------------------------------

## Working with Applications

Like in Windows, there are many ways to open applications in Gnome.

### The Super Key

You can hit the Windows key (Superkey is what it's called in Ubuntu) to bring up a search box.

<p align="center" width="100%">
    <img width="60%" src="https://github.com/rikosintie/Ubuntu4NetworkEngineers/blob/main/images/Open-Applications.png" alt="Show open applications">
</p>

Notice that the files application icon has two dots on the left side. If you click on the icon, the screen will change to show the two files windows.

<p align="center" width="100%">
    <img width="60%" src="https://github.com/rikosintie/Ubuntu4NetworkEngineers/blob/main/images/files-side-by-side.png" alt="Show multiple windows of the same application">
</p>

### Search for an application

To open an application using search, simply start typing the name of the application in the search box. As you
type, all the matching applications will be displayed below the search box. If the one you want is the first one
displayed on the left you can just hit enter. If not, keep typing and the list of displayed applications will get
smaller. In the screenshot below, hitting enter will open the built in calculator app. Right arrow, Enter will open
LibreOffice Calc!

<p align="center" width="100%">
    <img width="60%" src="https://github.com/rikosintie/Ubuntu4NetworkEngineers/blob/main/images/search.png" alt="Application Search">
</p>

You can also use the mouse and click on any application that is displayed to open it.

### Switching Applications

Tap the super key (Windows key on some keyboards). Below the search box are the applications that are currently running. If you want to switch to one of the open applications, you can use the Tab key and [enter] or use the mouse to select one of the running applications.

You can also use ctrl+tab just like in Windows.

Finally, you can use the dock to open applications that you have pinned to it.

### Viewing all installed applications

The dock has a small icon at the bottom, it’s three rows of three dots. You can click that icon to see the
installed applications in a window.

<p align="left" width="20%">
    <img width="10%" src="https://github.com/rikosintie/Ubuntu4NetworkEngineers/blob/main/images/Dock-square.png" alt="Dock icon to show all applications">
</p>

If there are too many to display, a column of circles will appear at the bottom of the screen and arrows on the right side. You can scroll down with the mouse button or click on one of the circles to jump to the next page. As you can see, it’s very easy to open applications in Ubuntu.

<p align="center" width="100%">
    <img width="80%" src="https://github.com/rikosintie/Ubuntu4NetworkEngineers/blob/main/images/frequent-new.png" alt="Installed Applications">
</p>

### Switching between multiple open windows in the same application

If you have several copies of the same application open you can switch between them using the super key and `\~ key (the key to the left of 1 on a US keyboard). You can also bring up the dock, click on the application
icon and then select the one you want but the keyboard is much easier and faster.

For Example, in LibreCalc I often have a lot of spreadsheets open. To switch to a different sheet I can use the "alt+`" key combination. Here is a screenshot of two spreadsheets.

<p align="center" width="100%">
    <img width="80%" src="https://github.com/rikosintie/Ubuntu4NetworkEngineers/blob/main/images/alt%2B~.png" alt="Switch between windows of the same application">
</p>

----------------------------------------------------------------

## Configuring the Dock

Like Windows and Mac, Ubuntu with the Gnome DE has a dock. You customize the dock using the Gnome Settings app. To open the Gnome Settings application, click on "Activities Overview" icon at the top right corner of the
screen, then select the gear icon. This will open the "settings" application. It’s very similar to “System Preferences” on the Mac or Control Panel on Windows.

At the top left corner of the screen there is a magnifying glass. Click it and enter "dock". The dock is under "Ubuntu Desktop".

<p align="center" width="100%">
    <img width="80%" src="https://github.com/rikosintie/Ubuntu4NetworkEngineers/blob/main/images/Dock.png" alt="Dock Settings">
</p>

One thing I do to help me use all three operating systems
is to customize the dock to be similar across all OSes. I set Windows, Mac and Linux to display it on the left
because I am almost 100% of the time on a laptop and the screen is wider than it is high. I also set the dock to
auto-hide and display a few commonly used apps.

Using the super key and typing the first few letters is now my preferred work flow rather than clicking on an
icon in the dock. One thing I like about Ubuntu is that when I’m using multiple monitors it puts the dock on all
the monitors.

## Customizing Gnome - The Tweaks Tool

Ubuntu ships with Gnome as the desktop environment (DE). Unlike Windows, Linux distributions can use a lot of different desktop environments (DE). Gnome is the default desktop environment for Ubuntu and Redhat (CentOS) so it has a large percentage of the desktop market in Linux. If you want to try others there are several official flavors of Ubuntu that you can download from Canonical.

First, install the Gnome Tweak Tool. This tool allows you to change a lot of the Gnome settings to your preference. Open a terminal window, ctrl+alt+t, and type the following:

`sudo apt install gnome-tweak-tool`

Press [enter], you will be prompted for your password because of sudo, and the install will start. When it finishes, hit the super key, type

`tweaks`

and hit [enter].

<p align="center" width="100%">
    <img width="80%" src="https://github.com/rikosintie/Ubuntu4NetworkEngineers/blob/main/images/tweaks.png" alt="Gnome Tweaks tool">
</p>

### Startup Applications

Gnome Tweaks is where you set the applications that run on startup. I try to keep these to a minimum. It's easy to forget that some application is automatically starting and you have forgotten about it.

There are a lot of options that you can "tweak" with the tool. I don't make a lot of changes but I do like having the Top Bar show Day, Data and Time.

----------------------------------------------------------------

## Managing Files

Files is the file manager for Gnome. The Gnome team is very creative with application names! The text editor is named "Text Editor", I kid you not. It makes Googling for tips a bit of a challenge.

Files works well and has a feature I love – Tabs! Once you get used to having tabs in your file manager it’s hard to use Windows Explorer! Here is a screenshot with three tabs open
and the right click menu showing “Open in Terminal”. You can see how convenient this is.

On a Mac, the Finder app has the tabs. I don’t know why Windows doesn’t.
Files has an extensive right click menu. Here are the options for the folder Scripts.

<p align="center" width="60%">
    <img width="60%" src="https://github.com/rikosintie/Ubuntu4NetworkEngineers/blob/main/images/Right-Click.png" alt="Right Click Menu">
</p>

### Creating archives

From the right click menu you can select "Compress..." to create a zip, password protected zip, a tar.gz or if you have installed 7zip, a 7z archive.

### Display the Full path in files

Sometimes you want to copy the full path to a file when working in the file manager. Hit ctrl+l (lowercase el) and the path will change to a format that you can copy.

<p align="center" width="60%">
    <img width="80%" src="https://github.com/rikosintie/Ubuntu4NetworkEngineers/blob/main/images/ZIP.png" alt="Display full path in files">
</p>

### Easily preview files in Files

One thing I missed from Windows Explorer was the preview pane. In Ubuntu running the Gnome desktop you can install "Sushi" to preview files. Then you just hit the space bar to preview a supported file format.

[How to Quickly Preview a File in Ubuntu's File Manager (Like "Quick Look" in macOS)](https://www.howtogeek.com/277987/how-to-quickly-preview-a-file-in-ubuntus-file-manager-like-quick-look-in-macos/)

### Search

**NOTE**: I said that you should use the LTS version of Ubuntu in the first chapter. And I usually do, but Ubuntu 23.10 includes Gnome 45 and I had to have some of the features. And 24.04 will be out in six months!

One of the features that I wanted was the completely new "Files" application that is amazing. Here is the announcement from the project [Introducing GNOME 45, “Rīga”](https://release.gnome.org/45/)

One of the best features in Files is the new search. Just click on the magnifying glass next to the address bar and enter some text. Unlike in Windows, you can enter text that is in the middle of the filename. In the screenshot below, I entered "new" and it found "frequent-new.png" in a directory one level down.

<p align="center" width="60%">
    <img width="80%" src="https://github.com/rikosintie/Ubuntu4NetworkEngineers/blob/main/images/files-search1.png" alt="Search for for files">
</p>

You can click on the funnel icon after you open search and filter on:

- Date
  - Created
    - Last Modified
    - Last Used
- What - There are well over 100 file types to choose from
- Full Text or Filename

Ubuntu has an article on using the new feature here: [Search for files](https://help.ubuntu.com/stable/ubuntu-help/files-search.html.en#:~:text=Open%20the%20Files%20application%20from,shown%20in%20the%20search%20bar.)

Ubuntu also has a [Common Tasks](https://help.ubuntu.com/stable/ubuntu-help/files.html.en#more-file-tasks) page for Files


### Why do I have a red Lock on a file or folder?

Files, like every other GUI file manager, uses icons to represent files and folders. If the icon has a green check mark in it, you have full access to the file or folder.

If the icon has a red lock in it, you don’t have full
permissions to the file or folder.
Here is a screenshot of Files showing one file with a green check mark and one with a red x.

<p align="center" width="60%">
    <img width="80%" src="https://github.com/rikosintie/Ubuntu4NetworkEngineers/blob/main/images/red-lock.png" alt="File that you don't have permissions to">
</p>

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

### Use the Ubuntu "Make Startup disk" tool

You can use the built in “Startup disk creator” by tapping the super key (Windows Key) and typing `start`. You will see the Startup disk icon:

<p align="left" width="100%">
    <img width="10%" src="https://github.com/rikosintie/Ubuntu4NetworkEngineers/blob/main/images/startup.png" alt="Startup Disk Icon">
</p>

- Pick the ISO image from the “Source disc image (.iso)” drop down
- Then select the USB stick from "Disk to Use"
- Click “Make Startup Disk”
- You will be prompted to select "Yes or No"

<p align="left" width="100%">
    <img width="75%" src="https://github.com/rikosintie/Ubuntu4NetworkEngineers/blob/main/images/startup-disk.png" alt="Startup Disk Interface">
</p>

In this example, I am burning Kali Linux 2023.3 to the flash drive.

### Use qemu to test a startup disk

You can install qemu and create a simple virtual machine to test a startup disk. I'm not going to cover that but these two articles will explain.

- [How do I install qemu on Ubuntu 23.10?](https://askubuntu.com/questions/1490805/how-do-i-install-qemu-on-ubuntu-23-10)
- [Using QEMU to quickly test an ISO or bootable USB drive](https://makandracards.com/makandra/1192-using-qemu-to-quickly-test-an-iso-or-bootable-usb-drive)
