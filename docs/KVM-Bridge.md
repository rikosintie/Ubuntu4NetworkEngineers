# KVM Install

In BIOS, or UEFI, make sure virtualization is enabled. The easiest way to find out what virtualization is called on your PC is to google the CPU model.

## Verifying virtualization

To verify that virtualization is enabled in BIOS, run:

`egrep -c '(vmx|svm)' /proc/cpuinfo`

48

This greps the /proc/cpuinfo file,  vmx is Intel, svm is AMD. You need to see a number in the output. In my case I have a 24 core Xeon processor that provides 48 cores of virtual CPUs.

### Install cpu-checker

`sudo apt install cpu-checker -y`

This is a optional package. From the Debian site:
"There are some CPU features that are filtered or disabled by system BIOSes. This set of tools seeks to help identify when certain features are in this state, based on kernel values, CPU flags and other conditions. Supported feature tests are NX/XD and VMX/SVM."

```bash linenums="1" hl_lines="1 10"
kvm-ok
INFO: /dev/kvm exists
KVM acceleration can be used
```

### Use lscpu

lscpu is a built in tool to view cpu information. You can see on line 10 that the virtualization is VT-x:

```bash linenums="1" hl_lines="1"
lscpu | egrep -i 'Model name|Socket|Thread|NUMA|CPU\(s\)|virtual'
Address sizes:                        46 bits physical, 48 bits virtual
CPU(s):                               24
On-line CPU(s) list:                  0-23
Model name:                           Intel(R) Xeon(R) CPU E5-2697 v2 @ 2.70GHz
Thread(s) per core:                   2
Core(s) per socket:                   12
Socket(s):                            1
CPU(s) scaling MHz:                   48%
Virtualization:                       VT-x
NUMA node(s):                         1
NUMA node0 CPU(s):                    0-23
```

## Installing the packages for KVM

 If you want to verify the version of Ubuntu run:

`cat /etc/os-release`

Now make sure Ubuntu is up to date.

```bash
sudo apt update && sudo apt upgrade
```

### Install the packages

```bash linenums="1"
sudo apt install libvirt-daemon
sudo apt install virt-manager
sudo apt install qemu-kvm
sudo apt install virtinst
sudo apt install libvirt-clients
sudo apt install bridge-utils
```

or you can use this to install all at once:

```bash linenums="1"
sudo apt install libvirt-daemon virt-manager qemu-kvm virtinst libvirt-clients bridge-utils
```

I prefer to do one package at time so that I can watch each package but either works. All packages are about 200MB.

### Configure the groups

```bash linenums="1"
sudo usermod -aG kvm $USER
sudo usermod -aG libvirt $USER
```

### Verify the groups have your user

```bash linenums="1" hl_lines="1"
groups $USER
mhubbard : mhubbard adm cdrom sudo dip plugdev users kvm lpadmin libvirt wireshark
```

### Enable the virt daemon

```bash linenums="1"
sudo systemctl enable --now libvirtd
sudo systemctl start libvirtd
sudo systemctl status libvirtd
```

#### If you make changes and need to restart the daemon

`sudo systemctl restart libvirtd`

### Where are the virt files

The qemu files are located in /etc/libvirt. You can list the files using:

```bash linenums="1" hl_lines="1"
ls -l /etc/libvirt
total 126K
drwxr-xr-x 2 root root    2 2024-05-06 06:12 hooks/
-rw-r--r-- 1 root root  450 2024-01-15 01:58 libvirt-admin.conf
-rw-r--r-- 1 root root  547 2024-01-15 01:58 libvirt.conf
-rw-r--r-- 1 root root  18K 2024-05-06 06:12 libvirtd.conf
-rw-r--r-- 1 root root 2.3K 2024-01-15 01:58 libxl.conf
-rw-r--r-- 1 root root 2.2K 2024-05-06 06:12 libxl-lockd.conf
-rw-r--r-- 1 root root 2.5K 2024-05-06 06:12 libxl-sanlock.conf
-rw-r--r-- 1 root root 1.2K 2024-01-15 01:58 lxc.conf
drwxr-xr-x 2 root root   26 2024-05-07 19:47 nwfilter/
drwxr-xr-x 4 root root    8 2024-08-02 16:44 qemu/
-rw------- 1 root root  38K 2024-05-20 16:17 qemu.conf
-rw------- 1 root root  38K 2024-05-20 16:15 qemu.conf.bak
-rw-r--r-- 1 root root 2.2K 2024-05-06 06:12 qemu-lockd.conf
-rw-r--r-- 1 root root 2.5K 2024-05-06 06:12 qemu-sanlock.conf
drwx------ 2 root root    2 2024-05-07 19:47 secrets/
drwxr-xr-x 3 root root    5 2024-05-08 21:36 storage/
-rw-r--r-- 1 root root 3.0K 2024-01-15 01:58 virtlockd.conf
-rw-r--r-- 1 root root 4.0K 2024-01-15 01:58 virtlogd.conf
```

If you want to make any changes to the qemu.conf file I recommend making a backup first using:

`sudo cp /etc/libvirt/qemu.conf /etc/libvirt/qemu.conf.bak`

Run the following to view the backup:

```bash linenums="1" hl_lines="1"
sudo ls -l /etc/libvirt/qemu.conf*
-rw------- 1 root root 38439 May 20 16:17 /etc/libvirt/qemu.conf
-rw------- 1 root root 38407 May 20 16:15 /etc/libvirt/qemu.conf.bak
```

To list the qemu.conf file:

`sudo cat etc/libvirt/qemu.conf`

To edit the qemu.conf file:

`sudo gnome-text-editor /etc/libvirt/qemu.conf`

## Start virt-manager

`virt-manager`

This will open the virt-manager GUI. Now we can create our first virtual machine!

Click on teh "New Virtual Machine" Icon.

![screenshot](img/virt-manager-new.png)

virt-viewer - open the VM's GUI console

## Creating a KVM Bridge

I built a KVM based lab on my HP z420 workstation running Ubuntu 24.04. Why do I need create a bridge?

**From the Tecmint link in the reference section below**

A typical use case of software network bridging is in a virtualization environment to connect virtual machines (VMs) directly to the host server network. This way, the VMs are deployed on the same subnet as the host and can access services such as DHCP and much more.

### LAN Information

- LAN Network 192.168.10.0/24
- Ubuntu workstation NIC - `eno1`

### Install the bridge-utils package

`sudo apt-get install bridge-utils`

### Create the Netplan yaml file

- `sudo touch etc/netplan/01-netcfg.yaml`
- `sudo gnome-text-editor etc/netplan/01-netcfg.yaml`
- Paste the following into the yaml file. Change IP addresses and interfaces to match your machine.

```c#
# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
  version: 2
  renderer: networkd
  ethernets:
      eno1:
          addresses:
              - 192.168.10.235/24

  bridges:
    br0:
      interfaces: [ eno1 ]
      dhcp4: false
      addresses: [192.168.10.250/24]
      routes:
      - to: default
        via: 192.168.10.253
        metric: 100
        on-link: true
      nameservers:
        addresses: [1.1.1.1]
      dhcp6: yes
      link-local: [ ]
      parameters:
        stp: true
        forward-delay: 4
```

Save the file, then change the permissions

`sudo chmod 600 etc/netplan/01-netcfg.yaml`

### Activate the bridge

`sudo netplan apply`

Fix any errors. Yaml is a pain to work with. You will probably have some errors in the beginning!

This creates a bridge named br0 mastered to eno1.

Use `ip a` to view the interfaces:

`eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master br0 state UP group default qlen 1000`

`br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether e6:b5:f8:a0:9b:c5 brd ff:ff:ff:ff:ff:ff
    inet 192.168.10.250/24 brd 192.168.10.255 scope global noprefixroute br0
       valid_lft forever preferred_lft forever`

### Display the bridge

```c# linenums="1" hl_lines="1"
sudo brctl show
bridge name bridge id          STP enabled  interfaces
br0         8000.e6b5f8a09bc5  yes          eno1
                                            vnet3
                                            vnet5
```

### Display the netplan configuration

The following displays the system wide network configuration

`sudo netplan get`

### Ping the hosts on the bridge

The Window server is at 192.168.10.231 and the Windows 10 guest is at 192.168.10.232

```c# linenums="1" hl_lines="2 8"
┌─[mhubbard@HP-Z420] - [~] - [375]
└─[$] ping 192.168.10.231
PING 192.168.10.231 (192.168.10.231) 56(84) bytes of data.
64 bytes from 192.168.10.231: icmp_seq=1 ttl=128 time=0.358 ms
64 bytes from 192.168.10.231: icmp_seq=2 ttl=128 time=0.390 ms

┌─[mhubbard@HP-Z420] - [~] - [376]
└─[$] ping 192.168.10.232
PING 192.168.10.232 (192.168.10.232) 56(84) bytes of data.
64 bytes from 192.168.10.232: icmp_seq=1 ttl=128 time=0.657 ms
```

### list out the xml config files

`l -la /etc/libvirt/qemu/networks`

## Verify the network switch settings

Make sure that the switchport of the physical network switch doesn't have bpdu-guard enabled! Once the bridge comes up it sends bpdu frames.

I was connected to a Cisco 3850 on an access port. The switch had `spanning-tree portfast bpduguard default` in global configuration. The port went into err-disabled when the bridge came up. It took me a while  to figure out why the bridge wasn't working!

I changed the port to a trunk with native vlan 10 to match the configuration that had been on the acces port.

```c# linenums="1"
interface GigabitEthernet1/0/6
 description < HP z420 >
 switchport access vlan 10
 switchport trunk native vlan 10
 switchport mode trunk
 storm-control broadcast level 1.00 0.50
 storm-control multicast level 1.00 0.50
end
```

## Virt Commands

View saved configuration

- `virsh dumpxml win2k16 | grep -i 'bridge'` show bridge config for a host named win2k16
- `virsh dumpxml win2k16 > ~/win2k16.xml` Save the configuration for a host named win2k16

Start/stop a virtual machine

- `sudo virsh win2k16 start` Start a virtual machine named win2k16
- `sudo virsh shutdown win2k16` Send an ACPI shutdown signal to the virtual machine
- `sudo virsh destroy win2k16` Power off the VM without signalling it. Data loss can occur
- `sudo virsh reboot` win2k16 Does not signal the VM. Data loss can occur

View VM Details

- `virsh dominfo win2k16` Show detailed information

Check Virtual Machine status

- `virsh domstate win2k16`

List virtual machines

- `virsh list --all` List all vms including those not running
- `virsh list` List all running vms

Connect to VM Console

- `sudo virsh console win2k16` See [How to enable KVM virsh console access]([#how-to-enable-kvm-virsh-console-access](https://ravada.readthedocs.io/en/latest/docs/config_console.html)) for a detailed article on how to setup console access

View DHCP leases

- `virsh net-dhcp-leases default` show dhcp leases on network default.
- `virsh net-dhcp-leases host-bridge` show dhcp leases on network host-bridge.

In the yaml file we disabled dhcp with `dhcp4: false` so there are no leases.

You can manually create the bridge and link it to eno1 from the terminal

```c# linenums="1"
sudo ip link add name br0 type bridge
sudo ip link set eno1 master br0
sudo ip address add 192.168.10.250/16 brd 192.168.10.255
```

THis method will not survive a reboot but it's quick for testing.

## Reference Links

- [VM Networking Libvirt / Bridge](https://www.youtube.com/watch?v=6435eNKpyYw) - A youtube video
- [How to add a static IP in Ubuntu 22.04 Server](https://gist.github.com/devantler/6d8bea11f73cc80d00be1502a9437ff0)
- [How to Configure Network Bridge in Ubuntu](https://www.tecmint.com/create-network-bridge-in-ubuntu/)
- [Error in network definition: bond0: interface not defined](https://askubuntu.com/questions/1257461/error-in-network-definition-bond0-interface-eno2-is-not-defined)
- [use the stable VirtIO ISO, download it from here](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso) - Virtio drivers for Windows guests
- [The Essential KVM Cheat Sheet for System Administrators](https://tuxcare.com/blog/the-essential-kvm-cheat-sheet-for-system-administrators/)
- [How to enable KVM virsh console access](https://ravada.readthedocs.io/en/latest/docs/config_console.html)
- [Windows 10 guest best practices](https://pve.proxmox.com/wiki/Windows_10_guest_best_practices) - This video is for ProxMox but the section on installing the virtio drives for the Windows NIC works on KVM with virt manager.
- [Introduction to Linux interfaces for virtual networking](https://developers.redhat.com/blog/2018/10/22/introduction-to-linux-interfaces-for-virtual-networking) - A great article by Redhat. It discusses every type of Linux interface that you can create.
- [How to Install KVM on Ubuntu 24.04 Step-by-Step](https://www.youtube.com/watch?v=qCUmf5gyOYY)
