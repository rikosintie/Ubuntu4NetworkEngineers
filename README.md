# The Ubuntu for Network Engineers Cookbook<!-- omit from toc -->

[markdownlint rules](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)

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

## Why use Ubuntu?

Network Engineering is moving to a NetDevOps model and away from the CLI. This means using Python, Ansible, Git and other DevOps tools. Ubuntu is the OS that Cisco recommends for the DevNet certifications. In fact, Cisco released an Ubuntu image for the DevNet Expert course. There is no reason not to use it for the associate course. It's available as an OVA for VMWare Workstation and a QCOW2 for Linux.

Download it here: [Cisco Certified DevNet Expert (v1.0) Equipment and Software List](https://learningnetwork.cisco.com/s/article/devnet-expert-equipment-and-software-list?t=1696124836669)

Here is an image from the Cisco DevNet Associate course. You can see the emphasis on coding and automation.

<p align="center" width="100%">
    <img width="60%" src="https://github.com/rikosintie/Ubuntu4NetworkEngineers/blob/main/images/DevNet-Exam-Topics.png">
</p>

## Installing Ubuntu

The first question is should I just spin up a virtual machine or use bare metal. I used Linux for a few years as a VM before I bought dedicated hardware. The advantage of using a VM is that if you damage it or decide for any reason it’s not the right distribution you can just delete it and try another one. The drawback to a VM is that the hypervisor hides the hardware so you don’t really get the experience of installing, configuring and maintaining Linux.

My suggestion if you have never touched Linux is to install Ubuntu as a VM and get some experience with it. You won’t have to spend any money, Ubuntu is free, although I usually donate $10 when I download it to install on a fresh machine, and you can run any of the tools in this book.

I have Kali running on a System 76 Gazelle laptop and Ubuntu on a Dell G5 laptop. I did this because I wanted to get my Linux certifications and I felt that I needed to be running Linux on my daily driver to really learn. The
VM can do just about anything the bare metal can do but when I would get stuck on something I would just shut it down and go back to Windows instead of figuring it out. Running on bare metal removed the temptation to do that!

There are a lot of good tutorials on installing Ubuntu available on the Internet so I am not going to cover it here. It is actually very easy, pretty much click, click, next, reboot! The site [linux config](https://linuxconfig.org) has a lot of great Ubuntu tutorials, here is link to a tutorial on installing 22.04 – [How to install Ubuntu 22.04 Jammy Jellyfish Desktop](https://linuxconfig.org/how-to-install-ubuntu-22-04-jammy-jellyfish-desktop). If you want to install Ubuntu 22.04 on bare metal the Lenovo x280 is a good choice. They are under $200 on ebay in good condition and they have hardware that is supported on Ubuntu. You can also use the Ubuntu [Search Ubuntu certified hardware](https://ubuntu.com/certified?q=&limit=20&category=Desktop&category=Laptop) site to verify that the hardware you want to use will be well supported on Ubuntu.

**NOTE**: Ubuntu has two types of releases

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
