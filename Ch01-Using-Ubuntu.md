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
    - [Easily preview files in Nautilus](#easily-preview-files-in-nautilus)
    - [Search](#search)


# Using Ubuntu

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

## Podcasts on Linux

There are a lot of podcasts dedicated to Linux. In your podcast application just search Linux. My favorites are:

- Destination Linux - A weekly podcast on general Open Source topics.
- Linux Unplugged - A weekly podcast on Linux by Jupiter Broadcasting. Covers news and applications for Linux.
- Late Night Linux - A weekly podcast on Linux and the wider tech industry.
- Linux After Dark - A weekly podcast on Linux experiences.
- Linux Downtime - A weekly podcast "From working in the Industry and progressing your career, to managing a projects community"

## Casting your display

I have a Vizio “Smart” TV with Chromecast built in. Using the Chrome browser I can click the three dot menu on the right and select “Cast...” to send the output to the TV.

In VLC, select “Playback, Renderer” to send VLC’s output to the TV. I don’t have a Chromecast dongle, but I am guessing it would work the same way as the Vizio TV.

----------------------------------------------------------------

## Working with Applications

Like in Windows, there are many ways to open applications in Gnome.

### The Super Key
You can hit the Windows key (Superkey is what it's called in Ubuntu) to bring up a search box.

<p align="center" width="100%">
    <img width="60%" src="https://github.com/rikosintie/Ubuntu4NetworkEngineers/blob/main/images/Open-Applications.png">
</p>

Notice that the files application icon has two dots on the left side. If you click on the icon, the screen will change to show the two files windows.

<p align="center" width="100%">
    <img width="60%" src="https://github.com/rikosintie/Ubuntu4NetworkEngineers/blob/main/images/files-side-by-side.png">
</p>

### Search for an application
To open an application using search, simply start typing the name of the application in the search box. As you
type, all the matching applications will be displayed below the search box. If the one you want is the first one
displayed on the left you can just hit enter. If not, keep typing and the list of displayed applications will get
smaller. In the screenshot below, hitting enter will open the built in calculator app. Right arrow, Enter will open
LibreOffice Calc!

<p align="center" width="100%">
    <img width="60%" src="https://github.com/rikosintie/Ubuntu4NetworkEngineers/blob/main/images/search.png">
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
    <img width="10%" src="https://github.com/rikosintie/Ubuntu4NetworkEngineers/blob/main/images/Dock-square.png">
</p>

If there are too many to display, a column of circles will appear at the bottom of the screen and arrows on the right side. You can scroll down with the mouse button or click on one of the circles to jump to the next page. Below is a screenshot with
frequent selected. As you can see, it’s very easy to open applications in Ubuntu.

<p align="center" width="100%">
    <img width="80%" src="https://github.com/rikosintie/Ubuntu4NetworkEngineers/blob/main/images/frequent-new.png">
</p>

### Switching between multiple open windows in the same application

If you have several copies of the same application open you can switch between them using the super key and `\~ key (the key to the left of 1 on a US keyboard). You can also bring up the dock, click on the application
icon and then select the one you want but the keyboard is much easier and faster.

For Example, in LibreCalc I often have a lot of spreadsheets open. To switch to a different sheet I can use the "alt+`" key combination. Here is a screenshot of two spreadsheets.

<p align="center" width="100%">
    <img width="80%" src="https://github.com/rikosintie/Ubuntu4NetworkEngineers/blob/main/images/alt%2B~.png">
</p>

----------------------------------------------------------------

## Configuring the Dock

Like Windows and Mac, Ubuntu with the Gnome DE has a dock. You customize the dock using the Gnome Settings app. To open the Gnome Settings application, click on "Activities Overview" icon at the top right corner of the
screen, then select the gear icon. This will open the "settings" application. It’s very similar to “System Preferences” on the Mac or Control Panel on Windows.

At the top left corner of the screen there is a magnifying glass. Click it and enter "dock". The dock is under "Ubuntu Desktop".

<p align="center" width="100%">
    <img width="80%" src="https://github.com/rikosintie/Ubuntu4NetworkEngineers/blob/main/images/Dock.png">
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
    <img width="80%" src="https://github.com/rikosintie/Ubuntu4NetworkEngineers/blob/main/images/tweaks.png">
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

<p align="center" width="40%">
    <img width="40%" src="https://github.com/rikosintie/Ubuntu4NetworkEngineers/blob/main/images/Right-Click.png">
</p>

### Creating archives

From the right click menu you can select "Compress..." to create a zip, password protected zip, a tar.gz or if you have installed 7zip, a 7z archive.

### Display the Full path in files

Sometimes you want to copy the full path to a file when working in the file manager. Hit ctrl+l (lowercase el) and the path will change to a format that you can copy.

<p align="center" width="60%">
    <img width="80%" src="https://github.com/rikosintie/Ubuntu4NetworkEngineers/blob/main/images/ZIP.png" alt="Display full path in files" />
</p>

### Easily preview files in Nautilus

One thing I missed from Windows Explorer was the preview pane. In Ubuntu running the Gnome desktop you can install "Sushi" to preview files. Then you just hit the space bar to preview a supported file format.

[How to Quickly Preview a File in Ubuntu's File Manager (Like "Quick Look" in macOS)](https://www.howtogeek.com/277987/how-to-quickly-preview-a-file-in-ubuntus-file-manager-like-quick-look-in-macos/)

### Search
NOTE: I said that you should use the LTS version of Ubuntu in the first chapter. And I usually do, but Ubuntu 23.10 includes Gnome 45 and I had to have some of the features. One of those is a completely new "Files" application that is amazing. One of the best features is search.

[Search for files](https://help.ubuntu.com/stable/ubuntu-help/files-search.html.en#:~:text=Open%20the%20Files%20application%20from,shown%20in%20the%20search%20bar.)
