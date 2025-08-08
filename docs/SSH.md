# SSH

![screenshot](img/Tux-SSH9-2.png)

----------------------------------------------------------------

:arrow_forward: KEY TAKEAWAYS

- Ubuntu has the latest version of the OpenSSH client installed by default.
- All the tools needed to secure and customize the SSH daemon are built in.
- You can use terminal tools like tmux and screen to log into devices and manage SSH sessions.
- You can use GUI tools like [SecureCRT](https://www.vandyke.com/products/securecrt/), [Termius](https://termius.com/), and putty. See [SSH GUI clients](#ssh-gui-clients)

----------------------------------------------------------------

I highly recommend buying a copy of [SSH Mastery](https://mwl.io/nonfiction/tools#ssh) by Michael Lucas. It’s available at [SSH Mastery](https://mwlucas.gumroad.com/l/CngLH) or [Amazon](https://www.amazon.com/) as an ebook for about $10.

When I switched to Linux my only experience with SSH was Putty. Basically just opening putty, putting in an ip address and connecting. I knew that Putty had a separate program, puttygen, to create ssh keys and other functionality but I really just used it to do a simple ssh connection. There is so much more to SSH and Michael explains all of it in SSH Mastery.

For a network engineer the biggest benefit of Ubuntu is that you have an SSH client and server that can be used from the terminal without installing proprietary software. It gets updated automatically when Ubuntu is updated.

As I moved more and more to NetDevOps and started working with Linux servers in the cloud I started to appreciate the benefits of having an ssh client and server integrated with the operating system.

## History of SSH

Secure Shell (SSH) has always been an open source project. It was originally released in 1995 by a Finnish computer scientist Tatu Ylönen. Before SSH, telnet was the most popular remote access protocol but it doesn't support encryption.

OpenSSH was released in 1999 by the [OpenBSD](https://en.wikipedia.org/wiki/OpenBSD) project. Most network devices supports SSH V1 and V2. V1 has been deprecated and V2 was released in 2006. On network devices if you do a `show ip ssh` command you might see `SSH Enabled - version 1.99` which means both V1 and V2 are enabled. What you want to see is `SSH Enabled - version 2.0` meaning V1 is disabled.

The open source community for ssh and ssl are moving rapidly to drop support for legacy ciphers.

!!! Warning
    Ubuntu 25.04 includes openSSH 9.9p1 which dropped all support for ssh V1! Any device that uses ssh-dss for the Host Key Algorithm will not connect

I upgraded to Ubuntu 25.04 on my laptop because I wanted some features in Gnome 48. The openSSH 9.9p1 update turns out a problem for older network devices like an HPE Procurve 2920, a Cisco IOS-XE device running 3.6.7 or older or a Ubiquiti M5 NanoStation. The reason is they are using ssh-dss for the Host Key Algorithm. This was part of the ssh V1 spec so it is gone.

I tried to recompile openSSH using flags but they were serious and there isn't a way to add ssh-dss back. This means that you cannot open a terminal and ssh to an older network device.

### Work Around for ssh-dss

- You can install putty using `sudo snap install putty` since putty brings legacy crypto with it.
- You can spin up a virtual machine of Ubuntu 24.04 using KVM.

I installed Putty but then realized that I use netmiko and other tools so I had to install a VM. I will glad when ancient network equipment is gone. Just last week (June 2025) a friend texted me that he was at a customer with a working Cisco 4500 running CatOS and Cisco 2926 switches. Gemini couldn't figure out how old these devices were!

### Verifying ssh ciphers

From a terminal you can use:

- ssh -V - Display openSSH version
- ssh -Q HostKeyAlgorithms - Display the Host Key Algorithms supported
- ssh -Q MACs - Display the Message Authentication Code algorithms supported
- ssh -Q KexAlgorithms - Display the Key Exchange Algorithms supported.

I created the following alias since I was checking often and on several machines:

```bash
alias mw-ssh='ssh -V && echo "" && echo HostKeyAlgorithms && ssh -Q HostKeyAlgorithms && echo "" && echo MACs && ssh -Q MACs && echo "" && echo KEXAlgorithms && ssh -Q KexAlgorithms'
```

I preface my custom aliases with "mw" so that I can type `mw-` and hit tab to display them.

This is the output on Ubuntu 25.04

```bash
mw-ssh
OpenSSH_9.9p1 Ubuntu-3ubuntu3.1, OpenSSL 3.4.1 11 Feb 2025

HostKeyAlgorithms
ssh-ed25519
ssh-ed25519-cert-v01@openssh.com
sk-ssh-ed25519@openssh.com
sk-ssh-ed25519-cert-v01@openssh.com
ecdsa-sha2-nistp256
ecdsa-sha2-nistp256-cert-v01@openssh.com
ecdsa-sha2-nistp384
ecdsa-sha2-nistp384-cert-v01@openssh.com
ecdsa-sha2-nistp521
ecdsa-sha2-nistp521-cert-v01@openssh.com
sk-ecdsa-sha2-nistp256@openssh.com
sk-ecdsa-sha2-nistp256-cert-v01@openssh.com
webauthn-sk-ecdsa-sha2-nistp256@openssh.com
ssh-rsa
ssh-rsa-cert-v01@openssh.com
rsa-sha2-256
rsa-sha2-256-cert-v01@openssh.com
rsa-sha2-512
rsa-sha2-512-cert-v01@openssh.com

MACs
hmac-sha1
hmac-sha1-96
hmac-sha2-256
hmac-sha2-512
hmac-md5
hmac-md5-96
umac-64@openssh.com
umac-128@openssh.com
hmac-sha1-etm@openssh.com
hmac-sha1-96-etm@openssh.com
hmac-sha2-256-etm@openssh.com
hmac-sha2-512-etm@openssh.com
hmac-md5-etm@openssh.com
hmac-md5-96-etm@openssh.com
umac-64-etm@openssh.com
umac-128-etm@openssh.com

KEXAlgorithms
diffie-hellman-group1-sha1
diffie-hellman-group14-sha1
diffie-hellman-group14-sha256
diffie-hellman-group16-sha512
diffie-hellman-group18-sha512
diffie-hellman-group-exchange-sha1
diffie-hellman-group-exchange-sha256
ecdh-sha2-nistp256
ecdh-sha2-nistp384
ecdh-sha2-nistp521
curve25519-sha256
curve25519-sha256@libssh.org
sntrup761x25519-sha512
sntrup761x25519-sha512@openssh.com
mlkem768x25519-sha256
```

Notice there are no ssh-dss ciphers

This is the output on Ubuntu 24.04. You can see ssh-dss on lines 18-19.

```bash linenums="1" hl_lines="18-19"
mw-ssh
OpenSSH_9.6p1 Ubuntu-3ubuntu13.12, OpenSSL 3.0.13 30 Jan 2024

HostKeyAlgorithms
ssh-ed25519
ssh-ed25519-cert-v01@openssh.com
sk-ssh-ed25519@openssh.com
sk-ssh-ed25519-cert-v01@openssh.com
ecdsa-sha2-nistp256
ecdsa-sha2-nistp256-cert-v01@openssh.com
ecdsa-sha2-nistp384
ecdsa-sha2-nistp384-cert-v01@openssh.com
ecdsa-sha2-nistp521
ecdsa-sha2-nistp521-cert-v01@openssh.com
sk-ecdsa-sha2-nistp256@openssh.com
sk-ecdsa-sha2-nistp256-cert-v01@openssh.com
webauthn-sk-ecdsa-sha2-nistp256@openssh.com
ssh-dss
ssh-dss-cert-v01@openssh.com
ssh-rsa
ssh-rsa-cert-v01@openssh.com
rsa-sha2-256
rsa-sha2-256-cert-v01@openssh.com
rsa-sha2-512
rsa-sha2-512-cert-v01@openssh.com

MACs
hmac-sha1
hmac-sha1-96
hmac-sha2-256
hmac-sha2-512
hmac-md5
hmac-md5-96
umac-64@openssh.com
umac-128@openssh.com
hmac-sha1-etm@openssh.com
hmac-sha1-96-etm@openssh.com
hmac-sha2-256-etm@openssh.com
hmac-sha2-512-etm@openssh.com
hmac-md5-etm@openssh.com
hmac-md5-96-etm@openssh.com
umac-64-etm@openssh.com
umac-128-etm@openssh.com

KEXAlgorithms
diffie-hellman-group1-sha1
diffie-hellman-group14-sha1
diffie-hellman-group14-sha256
diffie-hellman-group16-sha512
diffie-hellman-group18-sha512
diffie-hellman-group-exchange-sha1
diffie-hellman-group-exchange-sha256
ecdh-sha2-nistp256
ecdh-sha2-nistp384
ecdh-sha2-nistp521
curve25519-sha256
curve25519-sha256@libssh.org
sntrup761x25519-sha512@openssh.com
```

### Locating devices with ssh-dss Host Key Algorithms

You can use nmap to quickly scan devices and find those with ssh-dss ciphers.

`nmap -sV -p 22 -oN ssh-dss.nmap --script ssh2-enum-algos 192.168.10.50-254`

The -oN ssh-dss creates a `.nmap` file.

Here is the output from the HPE 2920 in my garage:

```bash linenums="1" hl_lines="13"
Nmap scan report for 2920-Garage.pu.pri (192.168.10.52)
Host is up (0.0069s latency).

PORT   STATE SERVICE VERSION
22/tcp open  ssh     Mocana NanoSSH 6.3 (protocol 2.0)
| ssh2-enum-algos:
|   kex_algorithms: (4)
|       ecdh-sha2-nistp521
|       ecdh-sha2-nistp384
|       ecdh-sha2-nistp256
|       diffie-hellman-group14-sha1
|   server_host_key_algorithms: (1)
|       ssh-dss
|   encryption_algorithms: (8)
|       aes256-ctr
|       aes256-cbc
|       rijndael-cbc@lysator.liu.se
|       aes192-ctr
|       aes192-cbc
|       aes128-ctr
|       aes128-cbc
|       3des-cbc
|   mac_algorithms: (4)
|       hmac-sha1-96
|       hmac-md5
|       hmac-sha1
|       hmac-md5-96
|   compression_algorithms: (1)
|_      none
```

Since we created the nmap file we can use:

`grep -i '192.168|dss' ssh-dss.nmap` to quickly find all devices.

Here is a sample output:

```bash linenums="1" hl_lines="2 4 6"
 2:Nmap scan report for Ubiquiti-ofc.pu.pri (192.168.10.50)
17:|       ssh-dss
28:Nmap scan report for Ubiquiti-garage.pu.pri (192.168.10.51)
43:|       ssh-dss
54:Nmap scan report for 2920-Garage.pu.pri (192.168.10.52)
66:|       ssh-dss
```

As you can see, devices 192.168.10.51-52 are using `ssh-dss` as the Host Key Algorithm. I have my network devices registered in DNS to it's easy to identify them. If you use MS Windows you can easily ask chatGPT to create a PowerShell script to read a spreadsheet of hostnames/IP addresses and create the DNS entries.

The HPE 2920 is running `WB.16.10.0025` firmware which I think is the last release. Here is a `show ip ssh` from the 2920:

```bash linenums="1" hl_lines="7"
HP-2920-24G-PoEP# sh ip ssh

  SSH Enabled     : Yes                 Secure Copy Enabled : No
  TCP Port Number : 22                  Timeout (sec)       : 120
  Rekey Enabled   : No                  Rekey Time (min)    : 60
                                        Rekey Volume (KB)   : 1048576
  Host Key Type   : DSA                 Host Key/Curve Size : 1024

  Ciphers : aes256-ctr,aes256-cbc,rijndael-cbc@lysator.liu.se,aes192-ctr,
            aes192-cbc,aes128-ctr,aes128-cbc,3des-cbc
  MACs    : hmac-sha1-96,hmac-md5,hmac-sha1,hmac-md5-96
```

You can see from the ip ssh config that you can change the cipher and the MAC but not the Host Key Algorithm. FYI, HMAC is Hashed Message Authentication Code. All ssh MACs are actually HMACs.

```bash linenums="1" hl_lines="2 5"
HP-2920-24G-PoEP(config)# ip ssh
 cipher                Specify a cipher to enable/disable.
 filetransfer          Enable/disable secure file transfer capability.
 listen                Specify in which mode daemon should listen in.
 mac                   Specify a mac to enable/disable.
 port                  Specify the TCP port on which the daemon should listen for SSH connections.
 public-key            Configure a client public-key.
 rekey                 Enable SSH key re-exchange.
 timeout               Specify the maximum length of time (seconds) permitted for protocol
                       negotiation and authentication.
```

## What Cryptographic Algorithms Should I use

When building a configuration template for a deployment you should remove as many legacy ciphers as possible. As the US CISA pushes for more secure IT infrastructure you will find more customers running security scans after you deploy. It's better to pass a security scan than have to answer questions about why your refresh failed a basic security audit.

Since SSH is almost 30 years old there are a lot of ciphers available. But of course, many are no longer secure. IoT manufactures and network devices typically have a lot of ancient ciphers. Episode 209 of the [2.5 Admins](https://2.5admins.com/2-5-admins-209/) podcast titled: Faulty Defaults is worth listening to if any of this is new to you.

Asking which ciphers are secure is like asking "Is Mac better than Windows?". But here are some general guidelines:

- Don't use any encryption with CBC in the name. For example aes128-cbc. The CBC means `cipher block chaining` and PCI will fail you if it finds it.
- Do use encryption with CTR in the name. For example aes256-ctr.
- Don't use a MAC with SHA1 in the name if possible. For example hmac-sha1
- Do use a MAC with SHA2 in the name. For example hmac-sha2-256 or hmac-sha2-512
- Don't use a Key Exchange Algorithm (KEX) with SHA1 in the name if possible. For example diffie-hellman-group1-sha1
- Don't use a HostKeyAlgorithm with dss in the name. This is an SSH V1 Host key and has been dropped on openSSH 9.9 and above.

You can do a search on the Internet for current algorithms. But, you will find that a lot of network devices don't support modern cryptographic algorithms. Some notable exceptions that support modern ciphers are:

- Aruba CX version 10.07 and newer
- Juniper Junos version 18.2R1.9 or higher
- Cisco IOS version 15.2(7)E2 or higher
- Cisco IOS-XE 17.2.x or later

----------------------------------------------------------------

### How to configure the algorithms

This is not an exhaustive tutorial. It's here to give you an idea of how to configure ssh algorithms for your base template.

Aruba CX

```bash
ssh ciphers chacha20-poly1305@openssh.com aes256-ctr aes256-cbc
ssh host-key ed25519
ssh host-key-algorithms ssh-ed25519 ecdsa-sha2-nistp521
ssh key-exchange-algorithms ecdh-sha2-nistp256 curve25519-sha256
 diffie-hellman-group-exchange-sha256
ssh macs hmac-sha2-256 hmac-sha2-512
ssh public-key-algorithms x509v3-ssh-rsa rsa-sha2-256
ssh maximum-auth-attempts 5
```

The Aruba CX firmware has rock solid cryptographic algorithms out of the box. See the [link](#references-ssh-history) in the references below for the exact algorithms. For a table of ssh server commands, see the [Aruba CX SSH server commands](#aruba-cx-ssh-server-commands) below.

Cisco IOS

```bash
ip ssh version 2
crypto key generate rsa modulus 4096 label SSH-KEYS
ip ssh rsa keypair-name SSH-KEYS !associate keys to SSH
ip ssh server algorithm encryption aes256-ctr aes192-ctr aes128-ctr
ip ssh server algorithm mac hmac-sha2-256 hmac-sha2-512
no ip ssh server algorithm mac hmac-sha1
no ip ssh server algorithm mac hmac-sha1-96
ip ssh authentication-retries 5
```

Ciscco IOS XE

```bash
ip ssh version 2
crypto key generate rsa modulus 4096 label RSA4096_SSH_KEY
ip ssh rsa keypair-name RSA4096_SSH_KEY !associate keys to SSH
ip ssh server algorithm authentication keyboard
ip ssh server algorithm mac hmac-sha2-512 hmac-sha2-256
ip ssh server algorithm encryption aes256-gcm aes256-ctr
ip ssh server algorithm kex ecdh-sha2-nistp521 ecdh-sha2-nistp384
ip ssh server algorithm hostkey rsa-sha2-512 rsa-sha2-256
ip ssh server algorithm publickey ecdsa-sha2-nistp521 ecdsa-sha2-nistp384
ip ssh authentication-retries 5
```

Juniper

```bash
set system services ssh ciphers aes256-ctr
set system services ssh macs hmac-sha2-256
set system services ssh macs hmac-sha2-512
set system services ssh hostkey-algorithm ssh-ed25519
```

----------------------------------------------------------------

### References SSH History

- [Secure Shell Wikipedia](https://en.wikipedia.org/wiki/Secure_Shell)
- [Top 20 OpenSSH Server Best Security Practices](https://www.cyberciti.biz/tips/linux-unix-bsd-openssh-server-best-practices.html)
- [Aruba CX SSH ciphers](https://www.arubanetworks.com/techdocs/AOS-CX/10.13/HTML/security_83xx-8400-9300-10000/Content/Chp_SSH_serv/SSH_serv_cmds/ssh-cip.htm)
- [IOS-XE SSH Best Practices](https://mrncciew.com/2023/08/28/ios-xe-ssh-best-practices/)
- [Configuring IOS XE for Strong Security SSH Sessions](https://community.cisco.com/t5/networking-knowledge-base/configuring-ios-xe-for-strong-security-ssh-sessions/ta-p/4556490#toc-hId--889430449)

----------------------------------------------------------------

## Connecting to Network Devices

:arrow_forward: KEY TAKEAWAYS

- Ubuntu makes it easy to use SSH from the terminal
- You can create custom entries in the ssh config file for each device if needed
- You can use password authentication or public key authentication with the ssh client
- You can easily create a jump host and secure your network devices even further.

----------------------------------------------------------------

**To connect using ssh:**

- Open the terminal
- Enter the following command.

`ssh mhubbard@192.168.10.253`

Change the username and IP address to fit your device.

----------------------------------------------------------------

### Run network commands remotely

You can run commands remotely on the network device using ssh. For example, to execute `show running-configuration` use:

```c# linenums="1" hl_lines="1"
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

You can also use shell commands to get just what you need. For example, let's say I want to know what `ip ssh` commands are in the running configuration.

```c# linenums="1" hl_lines="1"
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

----------------------------------------------------------------

### Network Devices with legacy ciphers

One problem for a network engineer is that newer versions of the OpenSSH client don’t allow weak crypto by default and most network devices have weak ciphers by default. If you are connecting to network devices from a modern version of Mac/Linux you will probably get an error and the connection will fail. You will have to customize the `~/.ssh/config` file to add the ciphers needed.

This is an example trying to connect to a Cisco 3850 IOS XE switch running 16.12.3a:

```c#
Unable to negotiate with 192.168.10.253 port 22: no matching key exchange method found. Their offer: diffie-hellman-group14-sha1
```

Here is the entry I added to `~/.ssh/config`:

Open the file using `gnome-text-editor ~/.ssh/config` and add the following:

```c# linenums="1"
Host 192.168.10.253
    KexAlgorithms +diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1,diffie-hellman-group1-sha1
    MACs +hmac-sha1,hmac-sha2-256,hmac-sha2-512
    HostKeyAlgorithms +ssh-rsa
```

You can add an SSH key file and a custom port for ssh if needed:

```c# linenums="1" hl_lines="5 6"
Host 192.168.10.253
    KexAlgorithms +diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1,diffie-hellman-group1-sha1
    MACs +hmac-sha1,hmac-sha2-256,hmac-sha2-512
    HostKeyAlgorithms +ssh-rsa
    IdentityFile ~/.ssh/id_rsa
    Port 45005
```

To use a specific key on the fly:
`ssh -i ~/.ssh/customer1/id_rsa  192.168.10.253`

I have run across network devices that required the ancient `dss` HostKeyAlgorithm. Add that with:
`HostKeyAlgorithms +ssh-rsa,ssh-dss`

----------------------------------------------------------------

### Using a wildcard in the config file

If you have 100s or 1000s of devices with legacy crypto it gets painful to create an entry in `~/.ssh/config` for every device. You can use a wildcard in the configuration file that will pass the same configuration to every connection. Keep in mind that the wildcard configuration applies to all devices that match the wildcard, not just network devices.

If you have a dedicated management network, for example, 192.168.10.0/24:

```c# linenums="1" hl_lines="1"
Host 192.168.10.*
    Protocol 2
    KexAlgorithms +diffie-hellman-group14-sha1,diffie-hellman-group1-sha1,diffie-hellman-group-exchange-sha1
    HostKeyAlgorithms +ssh-rsa
    MACs +hmac-sha1,hmac-sha2-256,hmac-sha2-512
    PubkeyAcceptedKeyTypes +ssh-rsa
```

The `+` sign adds the legacy ciphers but leaves the new ciphers in place. So a device that only has legacy ciphers can connect but a new device should still negotiate new ciphers.

You can use the `?` as wildcard placeholders. For example, `192.168.10.??` would match any host address with 2 digits.

You can also put multiple hosts on the same line, separated by spaces.

`host 192.168.10.* 172.16.1.*`

You can use an `*` to cover any hosts. The `~/.ssh/config` file is read top to bottom so you can place this at the bottom and have specific devices defined above it.

```bash linenums="1" hl_lines="2"
gnome-text-editor ~/.ssh/config
Host *
    Protocol 2
    KexAlgorithms +diffie-hellman-group14-sha1,diffie-hellman-group1-sha1,diffie-hellman-group-exchange-sha1
    HostKeyAlgorithms +ssh-rsa
    MACs +hmac-sha1,hmac-sha2-256,hmac-sha2-512
    PubkeyAcceptedKeyTypes +ssh-rsa
```

### Create an ssh config file for testing purposes

You can use a different configuration if you want to test changes without modifying `~/.ssh/config`. Use `-F` option, for example:

`ssh -F test-config 192.168.10.253`

### Use a different username for network access

Let's say that your laptop's username is `mhubbard` but the customer uses `vector` on all network devices. You can add the username to your config file:

```c# linenums="1" hl_lines="7"
Host 192.168.10.*
    Protocol 2
    KexAlgorithms +diffie-hellman-group14-sha1,diffie-hellman-group1-sha1,diffie-hellman-group-exchange-sha1
    HostKeyAlgorithms +ssh-rsa
    MACs +hmac-sha1,hmac-sha2-256,hmac-sha2-512
    PubkeyAcceptedKeyTypes +ssh-rsa
    User vector
```

Now list the username on my laptop

```bash linenums="1" hl_lines="2"
~/.ssh ⌚ 21:33:59
$ whoami
mhubbard
```

Log into the switch and run who:

```c# linenums="1" hl_lines="6"
$ ssh 192.168.10.253
(vector@192.168.10.253) Password:
DECOM___MCI-KSC-SW1 line 2
DECOM___MCI-KSC-SW1#who
    Line       User       Host(s)              Idle       Location
*  2 vty 0     vector     idle                 00:00:00 ubuntu.pu.pri
```

This is very convenient even if you are not using ssh keys.

### Display the configuration that will be used

Using `-G` Causes ssh to print its configuration after evaluating Host and Match blocks and exit. You can review your settings to verify you’re getting what you need.

In this example I removed a lot of detail but you can see the key that will be used, the ciphers, and other important details. The `-G` switch will save you a lot of time preparing you config file.

```C# linenums="1" hl_lines="10 15 16 17 18 19 21 22 23 25 26"
ssh -G 192.168.10.253
host 192.168.10.253
user mhubbard
hostname 192.168.10.253
port 22
addressfamily any
canonicalizehostname false
fingerprinthash SHA256
hashknownhosts yes
pubkeyauthentication true
stricthostkeychecking ask
tcpkeepalive yes
updatehostkeys true
requiredrsasize 1024
ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc
hostkeyalgorithms ssh-ed25519-cert-v01@openssh.com,ecdsa-sha2-nistp256-cert-v01@openssh.com,ecdsa-sha2-nistp384-cert-v01@openssh.com,ecdsa-sha2-nistp521-cert-v01@openssh.com,sk-ssh-ed25519-cert-v01@openssh.com,sk-ecdsa-sha2-nistp256-cert-v01@openssh.com,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-256-cert-v01@openssh.com,ssh-ed25519,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,sk-ssh-ed25519@openssh.com,sk-ecdsa-sha2-nistp256@openssh.com,rsa-sha2-512,rsa-sha2-256,ssh-rsa,ssh-dss
hostbasedacceptedalgorithms ssh-ed25519-cert-v01@openssh.com,ecdsa-sha2-nistp256-cert-v01@openssh.com,ecdsa-sha2-nistp384-cert-v01@openssh.com,ecdsa-sha2-nistp521-cert-v01@openssh.com,sk-ssh-ed25519-cert-v01@openssh.com,sk-ecdsa-sha2-nistp256-cert-v01@openssh.com,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-256-cert-v01@openssh.com,ssh-ed25519,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,sk-ssh-ed25519@openssh.com,sk-ecdsa-sha2-nistp256@openssh.com,rsa-sha2-512,rsa-sha2-256
kexalgorithms diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1,diffie-hellman-group1-sha1
casignaturealgorithms ssh-ed25519,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,sk-ssh-ed25519@openssh.com,sk-ecdsa-sha2-nistp256@openssh.com,rsa-sha2-512,rsa-sha2-256
loglevel INFO
macs hmac-sha2-512,hmac-sha2-256
securitykeyprovider internal
pubkeyacceptedalgorithms ssh-ed25519-cert-v01@openssh.com,ecdsa-sha2-nistp256-cert-v01@openssh.com,ecdsa-sha2-nistp384-cert-v01@openssh.com,ecdsa-sha2-nistp521-cert-v01@openssh.com,sk-ssh-ed25519-cert-v01@openssh.com,sk-ecdsa-sha2-nistp256-cert-v01@openssh.com,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-256-cert-v01@openssh.com,ssh-ed25519,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,sk-ssh-ed25519@openssh.com,sk-ecdsa-sha2-nistp256@openssh.com,rsa-sha2-512,rsa-sha2-256,ssh-rsa
xauthlocation /usr/bin/xauth
identityfile ~/.ssh/id_rsa
addkeystoagent true
syslogfacility USER
```

### SSH Jump hosts

A jump host is a device that you connect to and then connect to other devices. This is done to limit administrative access to just the jump host. This is very easy to do with Linux. Spin up an Ubuntu server VM with a NIC that has access to the network devices, hardened per your company security policy and then add `ProxyJump` to the ssh config file.

In this example I have an Ubuntu server at 192.168.10.223:

```c# linenums="1" hl_lines="9"
Host 192.168.10.* !192.168.10.223
        Protocol 2
        HostKeyAlgorithms +ssh-rsa,ssh-dss
        MACs hmac-sha2-512,hmac-sha2-256
        KexAlgorithms diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1,diffie-hellman-group1-sha1
        PubkeyAcceptedKeyTypes +ssh-rsa
        IdentityFile ~/.ssh/id_rsa
        AddKeysToAgent yes
        ProxyJump 192.168.10.223
```

The `!192.168.10.223` parameter means `not 192.168.10.223`. Without this entry there would be a loop and the jump would fail.

Now use the - J option:

```c# linenums="1" hl_lines="2"
~/.ssh ⌚ 17:00:00
$ ssh -J mhubbard@192.168.10.223 mhubbard@192.168.10.253
DECOM___MCI-KSC-SW1 line 2

DECOM___MCI-KSC-SW1#
```

None of your keystrokes reach the jump host. The only thing the jump host can see is an encrypted data stream between your client and the destination server.

!!! note
    Keep in mind that if the jump box is down you will not be able to log into the network devices. If you use `ssh -v` you will see these messages:

    - debug1: Reading configuration data /Users/mhubbard/.ssh/config
    - debug1: /Users/mhubbard/.ssh/config line 4: Skipping Host block because of negated match for 192.168.10.223
    - debug1: /Users/mhubbard/.ssh/config line 18: Applying options for *

    You can comment out the ProxyJump 192.168.10.223 line in the configuration with a # symbol until the jump box is back online.

### References Wild Cards

[SSH config wildcard on expanded Hostname](https://superuser.com/questions/469329/ssh-config-wildcard-on-expanded-hostname)

----------------------------------------------------------------

### Debugging SSH connections

You can use the -v switch to debug the SSH connection. You can repeat the v up to 4 times - -vvvv. Each extra v adds more details to the output.

----------------------------------------------------------------

### What crypto does my device support?

On most switches you can use something like `show ip ssh` to get a list of the current ssh ciphers.

Here is an example from the Cisco 3850 in my home lab:

```c# linenums="1" hl_lines="6 7 8 9 10 11 12 13 14 15"
ssh 192.168.10.253 show ip ssh
(mhubbard@192.168.10.253) Password:

DECOM___MCI-KSC-SW1 line 2

SSH Enabled - version 2.0
Authentication methods:publickey,keyboard-interactive,password
Authentication Publickey Algorithms:x509v3-ssh-rsa,ssh-rsa
Hostkey Algorithms:x509v3-ssh-rsa,ssh-rsa
Encryption Algorithms:aes256-ctr,aes192-ctr,aes128-ctr
MAC Algorithms:hmac-sha2-256,hmac-sha2-512
KEX Algorithms:diffie-hellman-group14-sha1
Authentication timeout: 120 secs; Authentication retries: 3
Minimum expected Diffie Hellman key size : 4096 bits
IOS Keys in SECSH format(ssh-rsa, base64 encoded): SSH-KEYS
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9HNJvj5z6RlhYQxxXk7WmWzoSGl8O9Iw5mUIFEmkR
MRwG7Hg32r5qZ0JSI//gZv8xAVfaR8h2Z5dlJnZyHkpH9eUyXcQOFTY6Y7O4GlFcIGCsVwMWSNslipyf
UVW9NBHFrbdfPgZnPzU6FxiTsKLCgIdbrGi51X1jpJf762Q6ZCsPV6h963gRgAMs+BsxRzDXxOVVcjYW
nDhN+nK9FNdHC4xlf7y3LLAb3zL41JuWN3N+7NEeNlM8fVgSI4Wzv3RE6uLRB6HIir/WjUgfzAOnBi5/
j52pac2gkstrdJmpko5ImRSWxuZfLYzn4LLXoIBXAKbps7BSk7Ci+to+RVDje5d68+Ech19ogzsfufNU
nYHvKNkxmahaZSZav6BPZWBiJ6Xc9c1OcqHX0seVXEp7ZZ+a99yrtY22yBC5W5Wh1hY/PEULbP7W64E+
mUQP9U8lIxCCw3MvmafZx2XvbPPENzYdIVO1nfIkAC/1QeK47Jh+HJMGZQbsfoTA4Gz3REKUXiU2eLRV
8hQznQVtjKn/Ey+aziHBrYo7IvwyKALA6Ofk+KehGgcmijEGi8HeyQdwmKzZ9t1XlVWE25M+RZMk0YCa
uWp6C0y9Zb2GUDgoazWp09gqEjNH2vnefIJvFvR7oRjGgSyYdyBm4z9PGEyRg//asR8+rkNi5jXaqzUd%

```

----------------------------------------------------------------

### Checking ciphers with nmap

For devices that don't have `show ip ssh`, like IoT devices, you can use nmap with the built in `ssh-enum-algos` script. This is from the Ubiquiti Nano Station in my home lab.

```c linenums="1" hl_lines="9 16 19 22 25"
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

This is an example of why you don't want to use the wildcard in the configuration file. depending on the client you could end up using sha1 instead of sha2 or ssh-dss instead of ssh-rsa.

nmap also has a similar script for checking SSL (TLS) crypto:

```c linenums="1" hl_lines="7 21 22 23 24 25 26 27 28 29"
sudo nmap --script ssl-cert,ssl-enum-ciphers -p 443 192.168.10.253
Starting Nmap 7.94 ( https://nmap.org ) at 2024-07-12 13:45 PDT
Nmap scan report for 3850.pu.pri (192.168.10.253)
Host is up (0.0043s latency).

PORT     STATE  SERVICE
443/tcp  open   https
| ssl-enum-ciphers:
|   TLSv1.2:
|     ciphers:
|       TLS_RSA_WITH_AES_256_GCM_SHA384 (rsa 2048) - F
|       TLS_RSA_WITH_AES_128_GCM_SHA256 (rsa 2048) - F
|       TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 (secp256r1) - F
|       TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 (secp256r1) - F
|     compressors:
|       NULL
|     cipher preference: server
|     warnings:
|       Insecure certificate signature (SHA1), score capped at F
|_  least strength: F
| ssl-cert: Subject: commonName=IOS-Self-Signed-Certificate-1097548300
| Issuer: commonName=IOS-Self-Signed-Certificate-1097548300
| Public Key type: rsa
| Public Key bits: 2048
| Signature Algorithm: sha1WithRSAEncryption
| Not valid before: 2023-03-08T00:38:42
| Not valid after:  2030-01-01T00:00:00
| MD5:   12d5:9652:7129:3c66:169d:1e69:2dc1:ddcc
|_SHA-1: 9fcc:9d66:f55a:ccec:4949:4da8:a3f7:205a:046d:78b0
MAC Address: F8:7B:20:34:A3:C6 (Cisco Systems)

Nmap done: 1 IP address (1 host up) scanned in 1.53 seconds
```

For new deployments you should take the time to remove legacy crypto in the switch configuration that you build. Once you decide on the best setup, add it to your base template. This is a best practice and will save you some embarrassment if the customer has a security team. Don't ask me how I know this.

If you have written permission from the network owner, you can use this script to do a quick cipher suite assessment of the existing network devices. I have a python script that creates a menu of nmap scripts for security testing. You can find it [here](https://github.com/rikosintie/nmap-python). The script is easy to use has a lot of nmap goodness for a network engineer.

----------------------------------------------------------------

## SSH GUI Clients

Here are three different GUI SSH clients for Linux.

### Putty

If you are coming from Windows you have probably used Putty. There is a Linux version of putty that is free to use.

#### Installation

You can install putty using the Ubuntu package manager:

`sudo apt-get install -y putty`

```bash
 sudo apt-get install -y putty
[sudo] password for mhubbard:
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  putty-tools
Suggested packages:
  putty-doc
The following NEW packages will be installed:
  putty putty-tools
0 upgraded, 2 newly installed, 0 to remove and 6 not upgraded.
Need to get 1,240 kB of archives.

putty --version
putty --version
PuTTY: Release 0.78
Build platform: 64-bit Unix (GTK + X11)
Compiler: gcc 13.2.0
Compiled against GTK version 3.24.38
Source commit: 4ff82ab29a22936b78510c68f544a99e677efed3
```

Notice that it's a fairly old version. Tap the Super key and type `putty` to run it. I would not install it, instead use ssh from terminator or purchase Termius/SecureCRT.

### Termius

Termius is a modern SSH client and terminal that works on:

- Windows
- Mac OS
- Linux
- IOS
- Android

Which makes it a great option. I personally use it on all of those except Windows. It syncs to the cloud so no matter what device I am on I have all of my hosts, keys, etc. It also has color coding for most network devices and a lot of themes.

I bought it years ago when it was in beta. It's now a $10.00 per month subscription. I think it's worth $10 per month but you will have to decide for yourself.

#### Installation Termius

go to [download](https://termius.com/download/windows) and select `Download .DEB` then open a terminal and run `sudo dpkg -i Termius.deb`

----------------------------------------------------------------

### SecureCRT

This is the 800lb Gorilla of SSH clients. If your company pays for a license for Windows users, you should be able jump on that plan. If not it's $209 for a three year subscription or $129 for a 1 year subscription.

I have never used SecureCRT so I am just going to put a link to the download here and you can research it yourself.

#### Installation SecureCRT

[SecureCRT Downloads](https://www.vandyke.com/cgi-bin/releases.php?product=securecrt)

----------------------------------------------------------------

## Creating SSH Keys

The OpenSSH client allows you to create custom SSH keys. You can create as many keys as you need. You should think about your security requirements and create SSH keys to fit the requirements. For example, if you work for a VAR or MSP, you may want to create unique keys for each customer. You can create subdirectories for different customers. For example:

`~/.ssh/customer1/`

See the section [Network Devices with legacy ciphers](#network-devices-with-legacy-ciphers) for an example of how to add a key to a device profile.

My current recommended public-key signing algorithm is Dan Bernstein's ED25519. To create a set of keys using ed25519, run the following in the terminal from the ~/.ssh directory:

`ssh-keygen -a 100 -f id_custom_25519 -o -t ed25519 -C "$(whoami)@$(uname -n)-$(date -I)"`

-a 100 Use 100 rounds of pbkdf2 (password based key derivation function 2).

-f name for the key pair.

-o Use the new RFC4716 key format and the use of a modern key derivation function powered by bcrypt.

-t Specifies the type of key to create. The options are:

- dsa (weak)
- ecdsa
- ecdsa‐sk
- ed25519
- ed25519‐sk
- rsa (weak)

dsa and rsa are not good choices as they are deprecated. The keys with -sk at the end are for use with physical Security Keys. See the [Yubico](#yubico-authenticator) topic later in this section for more information.

-C Specifies a comment to be added to the public key to make it easier to identify the key in the authorized_keys file of the server you connect to. This is optional. In the example:

- whoami - The username
- uname -n - The device hostname
- date -I - The year-month-day

Specify a strong passphrase when prompted. The passphrase is required anytime you use the key. If you don’t password protect the key, and an attacker gets access to the keys, they can log into any server you used them on.

Here is what the output of the command should look like:

```bash linenums="1" hl_lines="1 5 6 7"
ssh-keygen -a 100 -o -C "$(whoami)@$(uname -n)-$(date -I)" -f id_custom_25519 -t ed25519
Generating public/private ed25519 key pair.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in id_custom_25519
Your public key has been saved in id_custom_25519.pub
The key fingerprint is:
SHA256:4alqMRHMO/O91aJjlON2NLOUVcwZ5WLBVpcIaOFKylw mhubbard@1S1K-G5-5587-2024-07-11
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

```bash linenums="1" hl_lines="1"
cat id_custom_25519.pub
       │ File: id_custom_25519.pub
       │ ssh-ed25519·AAAAC3NzaC1lZDI1NTE5AAAAINCnTz475PiCydfW10kXIwPqpRpufeeuicoY9NLUndbt·mhubbard@1S1K-G5-5587-2024-07-11
```

You can see my username (mhubbard), hostname (1S1K-G5-5587) and date at the end.

You can replace any of the variables between the starting `"` and ending `"`. For example instead of hostname you could use `key-4-cisco`:

`"$(whoami)-key4cisco-$(date -I)"`

```bash linenums="1" hl_lines="1 4"
ssh-keygen -a 100 -f id_custom_25519  -o  -t ed25519 -C "$(whoami)-key4cisco-$(date -I)"

The key fingerprint is:
SHA256:nDm2hRdFrE7xLV3UxKh1DHEOS1C5Ftm0l/Wtqvb6OgI mhubbard-key4cisco-2024-07-24
```

----------------------------------------------------------------

### Display the existing keys on Ubuntu

!!! Note "Tip for naming keys"

    I always start my key names wih `id_`. If you don't, you will need to modify the `~/.ssh/id_*` section of the next command.

`for keyfile in ~/.ssh/id_*; do ssh-keygen -l -f "${keyfile}"; done | uniq`

- DSA or RSA 1024 bits: This is a red flag. Unsafe.
- RSA 2048: This is a yellow flag, recommended to change
- RSA 3072/4096: Good, but ED25519 is better!
- ECDSA: depends. Recommended to change
- ED25519: The best choice!

Here is what it looked like on my laptop.

```bash linenums="1" hl_lines="1"
for keyfile in ~/.ssh/id_*; do ssh-keygen -l -f "${keyfile}"; done | uniq
256 SHA256:2uWbzS9A/4dI+ZS+bM8f5q6wTqeb8vsBvylvQi5B9dE mhubbard@1S1K-G5-5587-2024-07-08 (ED25519)
256 SHA256:2XtMiDbg64rBnUXOzcFFXqwzUbbAjAO2Y9RwrWvVTB4 michael.hubbard999@gmail.com (ED25519)
4096 SHA256:0WF9uxNBCPeeHzMAGsYJy2wrsOXNrhPxJ+3lp2PxI+E mhubbard@1S1K-G5-5587-2024-07-11 (RSA)
2048 SHA256:YRwfm94a26cfCQZK6mT3SO29XaLoAHWJgnixN2OZDM0 mhubbard@1S1K-G5-5587 (RSA)
```

You can see the comment on the first key.

You can print the file name out by adding a print statement:

```bash linenums="1" hl_lines="1 3 5 7 9"
for keyfile in ~/.ssh/id_*.pub; do ssh-keygen -l -f "${keyfile}"; print ${keyfile}; done | uniq
256 SHA256:2uWbzS9A/4dI+ZS+bM8f5q6wTqeb8vsBvylvQi5B9dE mhubbard@1S1K-G5-5587-2024-07-08 (ED25519)
/home/mhubbard/.ssh/id_custom_25519.pub
256 SHA256:2XtMiDbg64rBnUXOzcFFXqwzUbbAjAO2Y9RwrWvVTB4 michael.hubbard999@gmail.com (ED25519)
/home/mhubbard/.ssh/id_github.pub
4096 SHA256:0WF9uxNBCPeeHzMAGsYJy2wrsOXNrhPxJ+3lp2PxI+E mhubbard@1S1K-G5-5587-2024-07-11 (RSA)
/home/mhubbard/.ssh/id_rsa.pub
2048 SHA256:YRwfm94a26cfCQZK6mT3SO29XaLoAHWJgnixN2OZDM0 mhubbard@1S1K-G5-5587 (RSA)
/home/mhubbard/.ssh/id_rsa_pub_2096.pub
```

### SSH Key permissions

The private key should have rw permission to only the user. No other users or groups should have any permissions. Use the following to view/set the permissions:

```bash linenums="1" hl_lines="1 6"
ls -l
-rw-------    1 mhubbard  staff   464B Jul  8 15:54 id_custom_25519
-rw-r--r--    1 mhubbard  staff   108B Jul  8 15:54 id_custom_25519.pub

If the permissions are wrong, use the following:
chmod 600 ~/.ssh/id_custom_25519
```

Here is the output using keys with 0644 instead of 0600:

```bash linenums="1" hl_lines="1 6"
ssh -i ~/.ssh/juniper_ed25519_key root@192.168.10.162
Authorized access only! Violators will be violated!
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@         WARNING: UNPROTECTED PRIVATE KEY FILE!          @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
Permissions 0664 for '/home/mhubbard/.ssh/juniper_ed25519_key' are too open.
It is required that your private key files are NOT accessible by others.
This private key will be ignored.
Load key "/home/mhubbard/.ssh/juniper_ed25519_key": bad permissions
```

----------------------------------------------------------------

## Using the SSH keys

:arrow_forward: KEY TAKEAWAYS

- SSH Keys use Public Key Infrastructure (PKI) instead of usernames/passwords. Keys are more challenging to brute force than passwords.
- Linux servers are very easy to configure to use ssh keys on. The `ssh-copy-id -i ~/.ssh/id_rsa.pub <Server_IP>` command copies the public key to the server in one step.
- Hardware Security devices such as Yubico [Yubikey](https://www.yubico.com/products/security-key/) and the Google [Titan Security Key](https://store.google.com/product/titan_security_key?hl=en-US&pli=1) allow you to store your keys securely and login from any laptop or desktop.
- Many Network Devices (Cisco, Aruba, Juniper, Arista, Ubiquiti, etc.) support ssh key authentication.

----------------------------------------------------------------

Once you have keys created what do you do with them? If you support Linux servers it's very easy to copy the public key to the server. Using a Public/Private key pair instead of a password to authenticate an SSH session is popular on Linux/Unix boxes. If you spin up a Virtual Private server on Digital Ocean or Linode you will want to use keys instead of a username and password.

Digital Ocean, a Virtual Private Server (VPS) provider, has this advice on how you should log into their Droplets:  "you should use public key authentication instead of passwords, if at all possible. This is because SSH keys provide a more secure way of logging in compared to using a password alone. While a password can eventually be cracked with a brute-force attack, SSH keys are nearly impossible to decipher by brute force alone." Plus, it means you never have to type C!$c0 again!

See [Brute Forcing SSH](#brute-forcing-ssh) below for an example of brute forcing ssh with nmap.

----------------------------------------------------------------

### SSH Keys with a Linux server

 Following along with our `id_custom_25519` example and an Ubuntu server at 192.168.10.223:

```c# linenums="1" hl_lines="1 19 22"
ssh-copy-id -i ~/.ssh/id_custom_25519 192.168.10.223
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/mhubbard/.ssh/id_custom_25519.pub"
The authenticity of host '192.168.10.223 (192.168.10.223)' can't be established.
RSA key fingerprint is SHA256:oKfQX+/8lwu3rfP8OMRpAfoeJo8EaOeUZ9kxMQfFNsc.
This host key is known by the following other names/addresses:
    ~/.ssh/known_hosts:186: [hashed name]
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
mhubbard@192.168.10.223's password:

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh '192.168.10.223'"
and check to make sure that only the key(s) you wanted were added.


~/.ssh ⌚ 13:19:05
$ ssh 192.168.10.223
Welcome to Ubuntu 24.04 LTS (GNU/Linux 6.8.0-35-generic x86_64)
╭─mhubbard@ubuntu-server ~
╰─$ cat ~/.ssh/authorized_keys
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGrwMtnnQo0kfjQVwcWOKx72SgsTB7Qj8FPTyyVwduxn mhubbard@1S1K-G5-5587-2024-07-08
```

You can see how the comment makes the key easy to identify in the authorized_keys file.

Since we created a passphrase for the key we are prompted for the passphrase, then logged in.

### Automatic logins

If you need to have an automated login, you can create a key without a passphrase. The actual connection is still secure, but if you lose control of the private key anyone can use it. It's one of those religious arguments that exit in security circles.

Alternatively, you can add the ssh private key to the ssh agent using the following command:

`ssh-add ~/.ssh/id_custom_ed25519`

You will be prompted for the passphrase.

#### ssh-add switches

You can find all switches using `man ssh-add`. Here I'm listing the more common switches.

- D Deletes all identities from the agent.
- d Deletes the given identities from the agent. The private key files for the identities to be deleted should be listed on the command line.
- K Load resident keys from a FIDO authenticator.
- k When loading keys into or deleting keys from the agent, process plain private keys only, skipping certificates.
- L Lists public key parameters of all identities currently represented by the agent.
- l Lists fingerprints of all identities currently represented by the agent.
- X Unlocks the agent. This asks for a password to unlock.
- x Locks the agent. This asks for a password; the password is required for unlocking the agent. When the agent is locked, it cannot be used for authentication.

Be sure to ask your security team if using the ssh-agent is permitted.

### I get an error when trying to use the key

If the login fails, rerun the ssh command with -vvvv `ssh -vvvv 192.168.10.253`. If you see a debug message `sign_and_send_pubkey: signing failed: agent refused operation` the first time you use the key enter the following:

`ssh-add` to add the default private keys to the ssh agent and

`ssh-add ~/.ssh/id_custom_ed25519` to add our custom key.

You can view the keys in the agent using:

```bash linenums="1" hl_lines="1"
ssh-add -l
4096 SHA256:0WF9uxNBCPeeHzMAGsYJy2wrsOXNrhPxJ+3lp2PxI+E mhubbard@1S1K-G5-5587-2024-07-11 (RSA)
4096 SHA256:569SKPB/kLsw1DqVlSV4J+bE+NYUDfY/LHNbvjvRs+o mhubbard@vectorusa.com (RSA)
```

For the first key you can see the size, 4096 bits, the fingerprint, the label we used when creating the key and the type (RSA).

### References ssh-add

- [SSH Keys for SSO: Usage, ssh-add Command, ssh-agent](https://www.ssh.com/academy/ssh/add-command)

----------------------------------------------------------------

### SSH Keys with github

Github doesn't accept username/password for repositories any longer. You will need to use a key pair and configure git to use it. I created a key pair just for github named id_github. To add it to your global git configuration:

```bash linenums="1" hl_lines="2 5"
add the key
git config --global user.signingkey ~/.ssh/id_github.pub

Display the user settings in the ~/.gitconfig file
git config --global --list
user.name=rikosintie
user.email=michael.hubbard999@gmail.com
user.signingkey=/home/mhubbard/.ssh/id_github.pub
```

Once you have the key configured in the ~/.gitconfig file you will need log into github.com, settings, SSH and GPG keys, and click "New SSH key".

----------------------------------------------------------------

### Using SSH keys with network devices

First off why would you want to use ssh keys on switches/routers/etc? With large customers you typically use Cisco ISE, Aruba Clearpass or Microsoft Network Policy Server (NPS) and authenticate to Microsoft AD.

But with smaller customers you may not have these infrastructure services available. Using SSH keys on switches/routers/etc when ISE, Clearpass or NPS isn't available is better than using local users and passwords. In this situation, over time,  the customer will usually have several different usernames and passwords across different switches and it can be a nightmare to log into all the switches.

They may not even have the credentials for all devices. In that case, you may want to use the nmap ssh-brute script. See [Brute Forcing SSH](#brute-forcing-ssh) below for an example of brute forcing ssh with nmap.

If you add your public key to the network devices before deploying, at least you will be able to log in efficiently without wasting time trying different passwords. You can also give the private key to the customer and they can import it into Putty.

----------------------------------------------------------------

## Using SSH keys with a Cisco IOS switch

Unfortunately it's not quite as easy to enable key based login on network devices but it's just a process. You can include it in your basic security template for example and automate it.

I'm using a WS-C3850-48U running 16.12.3a CAT3K_CAA-UNIVERSALK9 for this example.

----------------------------------------------------------------

### Configure a Time Server

Accurate time is required to use ssh keys. The first step is to configure a time server.

```c#
no ntp allow mode control 3
ntp server ip time-b.nist.gov
ntp server 192.168.10.222 prefer
```

The `no ntp allow mode control 3` is a Cisco recommended best practice to prevent DOS attacks.

- ntp allow mode control 3 --> causes the device to respond to mode 6 packet with a delay of 3 seconds, hence rate limiting and being considered not vulnerable (recommended)

#### Check NTP server config with nmap

nmap has two built in scripts for checking the NTP server configuration.

```c#
sudo nmap -sU -p 123 -n --script=ntp-monlist  192.168.10.253
sudo nmap -sU -p 123 --script ntp-info 192.168.10.253
```

The first one is for verifying that your ntp server doesn't support the "Monitor List" command that led to serious DDoS attacks back in 2014. Here I ran it against the ntp server on the Cisco 3850:

```c# linenums="1" hl_lines="1"
sudo nmap -sU -p 123 -n --script=ntp-monlist  192.168.10.253
Starting Nmap 7.94 ( https://nmap.org ) at 2024-07-12 13:50 PDT
Nmap scan report for 192.168.10.253
Host is up (0.0052s latency).

PORT    STATE SERVICE
123/udp open  ntp
MAC Address: F8:7B:20:34:A3:C6 (Cisco Systems)

Nmap done: 1 IP address (1 host up) scanned in 5.34 seconds
```

Notice the only output is that the port is open. If the switch supported "monitor list" it would have returned a list of devices that have requested time.

The second is very useful when you are having time issues. You can run it against the configured time server and see if you get response. I have an alias setup for this script:

```c# linenums="1" hl_lines="2"
#Run the nmap ntp-info script. $1 is the ip of the ntp server.
alias mw-ntp='(){sudo nmap -sU -p 123 --script ntp-info $1}'
mw-ntp 192.168.10.253
```

Here I ran it against my Cisco 3850 after I configured it for time.

```c# linenums="1" hl_lines="1"
sudo nmap -sU -p 123 --script ntp-info 192.168.10.253
Starting Nmap 7.94 ( https://nmap.org ) at 2024-07-12 13:50 PDT
Nmap scan report for 3850.pu.pri (192.168.10.253)
Host is up (0.0032s latency).

PORT    STATE SERVICE
123/udp open  ntp
| ntp-info:
|_  receive time stamp: 2024-07-12T20:51:09
MAC Address: F8:7B:20:34:A3:C6 (Cisco Systems)

Nmap done: 1 IP address (1 host up) scanned in 10.35 seconds
```

To verify that the switch is syncing with the ntp server I configured:

```c# linenums="1" hl_lines="1"
show ntp association

  address         ref clock       st   when   poll reach  delay  offset   disp
+~129.6.15.29     .NIST.           1    369   1024   377 68.998  -1.408  1.066
*~192.168.10.222  129.6.15.28      2    109   1024   377  0.989   0.619  1.037
 * sys.peer, # selected, + candidate, - outlyer, x falseticker, ~ configured
```

----------------------------------------------------------------

### Add a Domain Name, create the key, set SSH v2

To enable ssh on the switch you have to create an SSH key pair. I used a modulus of 4096, the maximum. It took 113 seconds to generate!  We will copy our RSA public key to the switch's pubkey-chain in the next section. That public key will be used with our private key to secure the SSH session.

```bash
ip domain name pu.pri
crypto key generate rsa modulus 4096 exportable label RSA-SSH-Key
ip ssh version 2
ip ssh rsa keypair-name RSA-SSH-Key !associate keys to SSH
```

!!! Note "Optional but informational"

    The "exportable" parameter. This isn't required but I wanted to point that out that you can make the keys exportable. It's not so important in this case but if you have setup GetVPN on a router you absolutely want to export the keys used for the tunnels. If you don't and the router fails you will have to touch EVERY tunnel once you replace the hardware. If you have exported the keys you just reload them on the new hardware and call it a day.

----------------------------------------------------------------

#### Display the key

```bash
show crypto key mypubkey rsa RSA-SSH-Key
% Key pair was generated at: 14:15:39 PDT Jul 21 2024
Key name: RSA-SSH-Key
Key type: RSA KEYS
 Storage Device: not specified
 Usage: General Purpose Key
 Key is exportable. Redundancy enabled.
 Key Data:
  30820222 300D0609 2A864886 F70D0101 01050003 82020F00 3082020A 02820201
  009EB39F 14DF98CA 96D74597 E3056C4B A1DD37B3 71019ADC D8FD0AD7 81335E21
  D14CC267 79409A66 FD687EA3 312D65A5 E6D14A22 0EE598BC 0991E5FB 91261101
  B29BDF85 05058257 8373F9B6 83093E65 ABBCF25C 422965EB 5D84A07D 9E97F8D1
  E834BE4B 74970547 42F5C48C BFA3A968 00569467 FA65080B A0F5F8DC 27AFC43C
  B00FBAE6 899C8B5C 3B5F6A6A 9F8EC065 C7A50455 6B5D4345 F3CD9B74 C55D0180
  F8870094 55A86FDF A514C4BA 74FC2E21 B7F3D7F4 1924847C B420BF2C 4FD14250
  C7D40209 914F3FF6 67F2EEEA F4674BDF FF692E36 C73BC4DF 597261D2 80B7FFC3
  DAF6E93C C167F196 D1A3B7AE A4B8EFC3 1FB3DA2C 681C1A9F 601F096E 1E73534F
  CCE25F9E DC753531 98DADDB1 C6C127E9 033EF061 7EB1DD44 33186410 15D23500
  A5569BE0 B1FB1C5F 83C017C2 8C223DD5 C07B3759 816E84B7 D9D6E503 C0A3DDD3
  5B3323AE 485744F9 B131422F 45E8DAED CF595280 F8ACE13A E2DFF9BE A75EA8ED
  78AB6DB3 52FC940C 40D4AC25 CF976D72 47E51F67 6EC05E8F CB6BEE99 53318C0D
  076880F0 A6AE0FD6 950AE9ED B17C5CCE D95209EA CA74B09B 83B103A9 510357CB
  D5514EA8 DD71BFC4 C57E7FD6 8EFE80E1 FA6CAADD 751EA11B 7D179394 791CE1BC
  71660659 E59E9FA0 9D0A3A0C 078C569D FF3CCB4D 4D6191E6 1A627C1E 64BC9649
  C25476B0 610EA0BC 1A124B93 FD6B61BC F5B09D38 427019FD D8D7B5D8 AB0AF723
  B5020301 0001
```

----------------------------------------------------------------

#### Export the Key

```bash
(config)#crypto key export rsa RSA-SSH-Key pem terminal 3des Sup3rS3crt
% Key name: RSA-SSH-Key
   Usage: General Purpose Key
   Key data:
-----BEGIN PUBLIC KEY-----
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAnrOfFN+YypbXRZfjBWxL
od03s3EBmtzY/QrXgTNeIdFMwmd5QJpm/Wh+ozEtZaXm0UoiDuWYvAmR5fuRJhEB
spvfhQUFgleDc/m2gwk+Zau88lxCKWXrXYSgfZ6X+NHoNL5LdJcFR0L1xIy/o6lo
AFaUZ/plCAug9fjcJ6/EPLAPuuaJnItcO19qap+OwGXHpQRVa11DRfPNm3TFXQGA
+IcAlFWob9+lFMS6dPwuIbfz1/QZJIR8tCC/LE/RQlDH1AIJkU8/9mfy7ur0Z0vf
/2kuNsc7xN9ZcmHSgLf/w9r26TzBZ/GW0aO3rqS478Mfs9osaBwan2AfCW4ec1NP
zOJfntx1NTGY2t2xxsEn6QM+8GF+sd1EMxhkEBXSNQClVpvgsfscX4PAF8KMIj3V
wHs3WYFuhLfZ1uUDwKPd01szI65IV0T5sTFCL0Xo2u3PWVKA+KzhOuLf+b6nXqjt
eKtts1L8lAxA1Kwlz5dtckflH2duwF6Py2vumVMxjA0HaIDwpq4P1pUK6e2xfFzO
2VIJ6sp0sJuDsQOpUQNXy9VRTqjdcb/ExX5/1o7+gOH6bKrddR6hG30Xk5R5HOG8
cWYGWeWen6CdCjoMB4xWnf88y01NYZHmGmJ8HmS8lknCVHawYQ6gvBoSS5P9a2G8
9bCdOEJwGf3Y17XYqwr3I7UCAwEAAQ==
-----END PUBLIC KEY-----
-----BEGIN RSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: DES-EDE3-CBC,067C3CC2D69C7213

TQ6ytl7+uSw/P4lHdpykCnJux8hAfT3LnC7OPcUE0hRjVPhP0+dPC4AlYhZ9AuPw
1J3tXogtfy+gry5lmRZn6xa6HFvxGywfA5ekj7jfYWiIp9tlC4YqZFFgkdLC5gwJ
nEov0ZzXYPU9gmRBloA5lpFtAPuhoSVXscCoDBnrsdxfLa7yQbd7LjQKp9xCWtF/
CjN392p7TPS4tNE7X8SE4F+dm7DOFdUUalcV3J0CLtIkNs/wxJke+qheBqIgVT3o
2fhJJNLc09nvsetyI/ezxqAidwBK47ZU7lsmu7O59uRCRwUndedIWMoRZ8Odr68Y
g5XEhoNiDFGS743kIoiL0Ahx2fCg+crh+Kw1vO3GbLDBfG0jtIKOcO3ua+laC2cB
Uk5Vj4UEztK9TzD/3MzAOQlBdxDnfMTCWI0qyKuQ5vcPap+mEBk+FVkyftu+aV4n
Aat8vCdWGxDSKueHgHNggR2JvP371i4ZfbIjtO8nQDGz9DYsYuSNPxl0xjr9Ivd3
LGfz3srfe6R4NHlu2g2fzp4jLumfB79t6ZO2GPTxGtTs6OYEvdN9zrH2yGw7VYOP
gMrvZcXpKUADZyDzO+Dt0prsRAsYruM5n5E/ofwr/tgqH8cpnJ6c6rcUzFbZMnp5
Mxjas3IdYZ5YoS3yPlUfIq/tFfXZgqJmxxNJyjZcQn1Q0H9RFv3jZcjdOlwWvuV2
Js5tn/ZrzV/lUengx6lkCuLA33vrDQjmM2K4xScbKbuNDW/xjxHoFyUkj0oNretU
xIvl+O3vVRA0wRVmtRUDBN/2r9eOqGsDX2BynCnksvO8hdn2JF4k7jsClVn5jYcg
LMVUEKsWiLNkUWJlcw/fkT38gAF5DH8J0yjz0rrhzkJ7dMwDcMc0qA9DGUy8Kwj6
mUZtr8TR1VlwRB9O3dFvdo9TGzhlugNE0Tm8CaOp8bS5wPiKUQPPw4EbSPBYdo/7
EBBincyjeNrhiSdVWIfNYhUMZU95wSafgCnHFDRIO9hdOof3550uo72xwk4NTbpm
qc8Lqygx6DJry6hJio9emLNHKf75jX7zYsEoy6Jvofz4ky5O1Ace1scgEW7bgjoa
eXq+Xskri3T78gCUMEP4WxWlxE4UbU3GQ7LsW9x9Yz4qd/BkcvSD1VmTcju3t/KC
8vRx0LwaqhSycedO2M0lGsmlH9OSmdh7Aui5QU3e8Zj6Vb/qUTNS88pyWWi5+zGC
zVejUEi9zdCQcfdhdvgMphVyq86fagoEFMpu4m+61JuWFqtjLxncSr6hOW8+R9xN
D6YiAgobH1sXkcgQsS2iRJrqGSFVL09NetEApTBpgZmmoQDd14VRKiqXFd5djHk+
GjOqn6cFJCQynfehHKJVkoTuSLa1CYDQ46YSdEwisXU+CVDt26OZ4G3GieNAUzQn
yTzHuONMffnjTJlSiVhbIGnV+3UMQY/lyTKyJpMePidvhC7Aue19TLc6TSZcFNIK
QFlkONDOEftIq4ceRozKwkijqg+PmJ5iYMUwlunW9b4gqfI2QrSJ0NLZhsV0ItqT
vbM+UTc8UI4xODdi+5CGhY5zCV+Up6EBkkrnuDCVUrPVPEBkOkkDXjPx/WVNHzQ+
oaCDxHVz8238yiw9ztqPqaL3G8JAPzNtn2mBgK/HgACsLKeD3xUsI8c27YJB/M1M
YvL9glbKIhSuoySKxFvMEsqic2uQXDHPJTdKLPbdwnhBDiRo7vHOPXzoth74p/Hw
xGycOvkSW1xt+vIcqdJ4dXO+sXLzzK2xd8cxrDD6yHcu3axmUNz8hfPwVUfIl8Cy
Gz0NaDyGByHhVjpigZ4GSyXiyPfIZlgol2yyblktLrPGRgJyWlU5lb6ZYm8E0+K/
gmz85q7JgfuQm3KihDRpOq3rqaIaabg6rhgxEazk7Z/tqRg7BIZelmSI8BRGwK/t
N76YVG19DjzLB93we25euV2pXKJ09DN4noILRK3hialvaGwT6LZ3eUqfiJ2vdHAT
30N8/QYxfh5avrTXKO0siwTBheslDwUq31oJXOvygrCDDusZ3Qf3IKp3AjZr1fv3
MMV3qhkpDiiLZOcqGbmLjzzONSvyq23DR31vHLhijct5lVjXtHTe1neiChvmgNp7
ciWj2J+Xu4krw/5ewO8JfQXkb2JQc/WraVKJxmT4oxPq0djGIWjOdz6RNShXIppt
UmP9TTK9KEQbgj+lI4djj0W++fI5j6GK3CDckJoTyZ2NS2WoQU9aeb1ucxEAsye+
sudObLhH+af1e1kFBjaMiVoGzBsTOM5tzXIlKuNASB2pJTwWPjkCWXlSDrSE0g+F
i2bhIa/VA5Xhgb6Pxp2eUjodOHPXyFiP78BpjOtLRrVwp70QHudXbXTqmMceE3DV
rHD3u2ag5HO66RpE1Jgd0VBt4ImQ9aNOZemXmLC/Z+S5Zz5lrkR5Ar8q6LONYxSL
3r7VfyLbzHz2itnsoXM0rJ9WY80su3cz1pbYW20kURVkRAfgUTk9si0w2nhZfLnr
9uQtsgPc10z72BhlLjhMhq2SFK6HUQUUpi4oehOmSWz6xr627GyOV+u5A6SRlGlV
4Ps4t9Ug8+wjsC+nC/B9DZkB6dEE4iESXbblx4fI/EN8BwGUgBQvh/1PV8uRA+ND
eiwXU4vY3MR/Iy4G4Rp8JbJggkNPFOmKhStoH3U06Zi+9E2lXhXVNIadGyRCmeXI
p77a8fCXIofO20R0lHyOW4Za0eJ8+xDcE26wRAOvXa80IIPu5rfNszKz4cTep4/q
aShY1vQmBlfgge0D5G1cDG05kN8gJlHY5Q8z8KdMXJtRNG+ae2yoWSHb1Ca0Cnul
j4oyrxUhaG4UtR0W7czGIb8oMj8vfhd6PxYsZIjpnQHBSx3HvCeue7ef1+Zf/P1H
X4/JfLE14Qe85/IKYZD9wXEth4zFbGpUsDE3YQe2YQLsOUgZZeQhvgTHOYDCxwTA
9abHL6YkXTWrcTc2dXMsrgIVCXyGJYmdVLX761y3sCiSMwoYSFC+inuPIPjZVh5y
bUtxlWRFyuRx0t0eFzb7rMHf9y0KvCfr3RTRnVNa/1l0dd3UJ+ok7RCGHyynYwZr
n6FpY2CsvK9R5cDrjLWMjjHCC4Y+adD3pS1g4CQWH3saQH1PmbSQ9ul/K8fYYe2v
-----END RSA PRIVATE KEY-----

```

Copy the key stating at `BEGIN PUBLIC KEY` until `END PRIVATE KEY`, save it to a file and store it in a secure place.

----------------------------------------------------------------

### Configure AAA authentication

The aaa new-model command causes the local username and password on the router to be used in the absence of other AAA statements. Once you enter "aaa new-model" you will not be able to enter "login local" on vty line configuration. If you had login local configured it will be removed.

When you create the username be sure to include a secret. If you don't, anyone will be able to login with just the username. As always, create a strong secret and use a password manager to store it.

```c#
(config)#username mhubbard privilege 15 algorithm-type scrypt secret ^8(nn-!#who
(config)#aaa new-model
(config)#aaa authentication login default local
(config)#aaa authorization exec default local
(Authentication through the line password is not possible with SSH)
```

----------------------------------------------------------------

#### Configure the vty lines

```bash
(config)#line vty 0 4
(config-line)#transport input ssh
(config-line)#logging sync (prevents console messages from interfering with your inputs)
```

----------------------------------------------------------------

### Add your PUBLIC key to the device

Open the public key file you created earlier in a text editor (not a word processor). Copy the text between the comments. If you generated a 2048/4096 bit key you will need to break it into smaller pieces or you may see "%SSH: Failed to decode the Key Value" when you exit. I break it into 100 characters per line.

```text linenums="1" hl_lines="1"
gnome-text-editor id_rsa.pub
break the lines into lengths of 100 characters
copy the text after ssh-rsa till the comment begins.
close the key file but do not save it
```

**Paste the key into the device**

```bash  linenums="1" hl_lines="1 2 3 12 13"
(config)#ip ssh pubkey-chain
(conf-ssh-pubkey)#username mhubbard
(conf-ssh-pubkey-user)#key-string
(conf-ssh-pubkey-data)#AAAAB3NzaC1yc2EAAAADAQABAAACAQDhgWxFej4ybQHAEtMHo9gYL6zU5t7HeQE0vy3IFONK9JFsM0HSoxZPK18nh26
(conf-ssh-pubkey-data)#58l+i8FonksmnhhjX+VOn6dkPwdedEHAOZeSPNGbPdCwQeMZhRZSgE+NCxCesgp3wOOlYLvIaBYFnpF3TbXG8SGSjPmXvupvl75
(conf-ssh-pubkey-data)#6Obax6cxi/o5MvnRi0aA4kmQYkoDHm/3SDc/fkeEJ3Cqljsc4kTJOGOLiFvfik+wDFILt630J/2cKV/iGhk98cYxVUsPVtlV254
(conf-ssh-pubkey-data)#ayu8x1aUxTzIhdj11T7Yw20H/+2NHbGbwLRyNn2xMPgFz6UmqnPMreNBWspR0xGcmCjqIxsI73UNZjA0YMm7ob1wTDPHRbJU7Yn
(conf-ssh-pubkey-data)#j1Oyiqo4fISNtc6nI+MY0t95JEKBcpt653Bq//h/319pzI2h0FAh4UL2XgV581TWMZWtAe2gFQmh5wLyUhxkPyZpwdZomxS58An
(conf-ssh-pubkey-data)#ZbxQtO8YaSJTGbWzd06lPaWYKYQ+6CMmfGTdPMPS3LsG17rfWUoE4T9ot8uWvD/+ZfteGId+gftva8kxl0rX3VW4lmOG5Vf0FNG
(conf-ssh-pubkey-data)#HoVRNyQ00xj/rRRo6zgfzJQe7rpjp1nEWmftc2ZouTHtidGCtJ2fmfFS09A+kUHdY51gS1FeJLCySSz+2HIkZpaOVOqlhqz//xa
(conf-ssh-pubkey-data)#g9QIk4RSWAfpKt+TqB5R+iBCpWYoQ==
(conf-ssh-pubkey-data)#exit
(conf-ssh-pubkey-user)#end

```

Make sure to press `enter` after `key-string` before you paste the key in. You have to use `exit` to end the key-string input. Then use `end` to exit configuration mode.

----------------------------------------------------------------

### Verify the ssh configuration

```bash  linenums="1" hl_lines="1"
show run | sec ssh
ip ssh source-interface Vlan10
ip ssh rsa keypair-name RSA-SSH-Key
ip ssh logging events
ip ssh version 2
ip ssh dh min size 4096
ip ssh pubkey-chain
  username mhubbard
   key-hash ssh-rsa 5D24EA1D261C1836E437F4E67E2CEBEB
   key-hash ssh-rsa CCA79DBB37A7EA060C781DA2767509C0
ip ssh server algorithm mac hmac-sha2-256 hmac-sha2-512
ip ssh server algorithm encryption aes256-ctr aes192-ctr aes128-ctr
ip ssh server algorithm kex diffie-hellman-group14-sha1
 transport input ssh
 transport output ssh
```

!!! Note "Use the hash for setting up the rest of the switches"

    You can use the HASH instead of the key for the next devices you setup. Instead of using "Key-string" in the ip ssh pubkey-chain statement use `key-hash ssh-rsa 5D24EA1D261C1836E437F4E67E2CEBEB`.

If you need to remove a key use the `no` keyword with the key-hash keyword. I needed to remove the old 2096 bit RSA key after I changed the `ip ssh dh min key size` to 4096.

```bash linenums="1" hl_lines="3"
ip ssh pubkey-chain
username mhubbard
no key-hash ssh-rsa 4682578A0267D583568FCDCD1229B62C
```

----------------------------------------------------------------

### Login using the SSH Keys

Continuing in the theme of network devices having legacy crypto, you will have to add `PubkeyAcceptedKeyTypes +ssh-rsa` to the `~/.ssh/config` file for the host.

`ssh -i ~/.ssh/id_rsa.pub 192.168.10.253`

Remember that you can add -vvvv to the command to get verbose debugging. I had to do that because the key was failing. In the debugs I saw `send_pubkey_test: no mutual signature algorithm` which reminded me to add  `PubkeyAcceptedKeyTypes +ssh-rsa` to the config file for this host.

You can also use `ssh 192.168.10.253` and the SSH client will try all the keys. I prefer to explicitly call the key, but it doesn't matter if you don't.

Here is the complete configuration and debug to log into the Cisco 3850 using the id_rsa key:

```c# linenums="1" hl_lines="1 10 16"
gnome-text-editor ~/.ssh/config
Host 192.168.10.253
        Protocol 2
        HostKeyAlgorithms +ssh-rsa,ssh-dss
        MACs hmac-sha2-512,hmac-sha2-256
        KexAlgorithms diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1,diffie-hellman-group1-sha1
        PubkeyAcceptedKeyTypes +ssh-rsa
        IdentityFile ~/.ssh/id_rsa

ssh -vvvv 192.168.10.253
Next authentication method: publickey
Offering public key: /home/mhubbard/.ssh/id_rsa.pub RSA SHA256:0WF9uxNBCPeeHzMAGsYJy2wrsOXNrhPxJ+3lp2PxI+E explicit agent
send packet: type 50
we sent a publickey packet, wait for reply
receive packet: type 60
Server accepts key: /home/mhubbard/.ssh/id_rsa.pub RSA SHA256:0WF9uxNBCPeeHzMAGsYJy2wrsOXNrhPxJ+3lp2PxI+E explicit agent
sign_and_send_pubkey: using publickey with RSA SHA256:0WF9uxNBCPeeHzMAGsYJy2wrsOXNrhPxJ+3lp2PxI+E
sign_and_send_pubkey: signing using ssh-rsa SHA256:0WF9uxNBCPeeHzMAGsYJy2wrsOXNrhPxJ+3lp2PxI+E
send packet: type 50
receive packet: type 52
Authenticated to 192.168.10.253 ([192.168.10.253]:22) using "publickey".
```

Once you have entered the passphrase it will be added to the ssh agent and you won't be prompted again until you close the terminal and open a new one. If you want to remove the key from the agent without closing the terminal use:

`ssh-add -D ~/.ssh/id_rsa`

If you want to change the password on the key use:

`ssh-keygen -p -f ~/.ssh/id_rsa`

----------------------------------------------------------------

### Using keys with Putty

If you want to connect from a Windows computer with Putty I have a blog with a tutorial on how to create keys and connect using putty/puttygen - [Authenticating to Cisco devices using SSH and your RSA Public Key](https://mwhubbard.blogspot.com/2015/07/authenticating-to-cisco-devices-using_92.html).

#### Can users still login who don't have keys configured?

Yes, the key-chain must be configured for each user.

```bash linenums="1" hl_lines="1"
sh run | sec pubkey
ip ssh pubkey-chain
  username mhubbard
   key-hash ssh-rsa 5D24EA1D261C1836E437F4E67E2CEBEB
   key-hash ssh-rsa CCA79DBB37A7EA060C781DA2767509C0
```

Here are the users I have configured on this switch:

```bash linenums="1" hl_lines="1"
show run | sec user
username thubbard privilege 15 secret 9 $9$95tTO1OC4HNmIE$bt1Z4.7aw/EBUQHl3NmLUNMacw4hRPI.742Kbs2r4jA
username mhubbard privilege 15 secret 9 $9$y4j0lAgHcDtV3.$sH6LI79G3qmdpVdICokss8dzjGUC3u7we4.wcPnwNQ.
  username mhubbard
   key-hash ssh-rsa 5D24EA1D261C1836E437F4E67E2CEBEB
   key-hash ssh-rsa CCA79DBB37A7EA060C781DA2767509C0
```

You can see that `thubbard` has to use a password but `mhubbard` can use a password or SSH keys. User `mhubbard` has two keys listed because I generated keys on my Ubuntu machine and my M1 MacBook Air. I could have copied my private key from Ubuntu to the MacBook but I wanted to show two keys.

!!! Note

    IOS only allows two keys in the key-chain.

You can see in the ouput the user's secret is hashed as type 9. In Cisco speak that is scrypt. Scrypt is a `memory` hard hash so having hardware GPUs doesn't speed up reversing the hash. To create a users with scrypt:

`username thubbard privilege 15 algorithm-type scrypt secret Sup3rS3cr3t`

----------------------------------------------------------------

## Using the keys with a JunOS switch

Setting up the JunOS switch is similar to setting up the Cisco switch.

```bash linenums="1" hl_lines="1"
ssh -i ~/.ssh/juniper_ed25519_key root@192.168.10.162
Authorized access only! Violators will be violated!
Enter passphrase for key '/home/mhubbard/.ssh/juniper_ed25519_key':
Last login: Fri Jul 12 14:01:28 2024 from 192.168.10.143
--- JUNOS 18.2R1.9 Kernel 64-bit  JNPR-11.0-20180614.6c3f819_buil
root@TEST-Router:~ #
```

----------------------------------------------------------------

## Using the keys with an Aruba CX switch

The Aruba CX switches are easy to set up for SSH and public key access. They support strong cipher suites and it's easy to reset the cipher suite if you remove some and your client can't connect. I personally think they set the standard for how the SSH server implementation should be done on network devices.

### Initial setup

In the Cisco section above we configured NTP, and the user accounts before setting up SSH. You need to do the same for the Aruba CX.

You need to decide which VRF to enable the server on. In this example, we will use the mgmt vrf. Use the following command to enable the ssh server:

```bash
ssh server vrf mgmt
```

When an SSH server is enabled on a VRF for the first time, host-keys are generated. Keeping with the "Aruba sets the standard for ssh" theme, the default RSA key is 4096 bits!

!!! note

    If the host-key of the given type exists, a warning message is displayed with a request to overwrite the previous host-key with the new key.

    That isn't a problem as far as setting up ssh, but keep in mind that if you have connected before, the client will complain that the key has changed.

If that happens you will see the following message:

```bash linenums='1' hl_lines='1'
ssh 192.168.10.233
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the ED25519 key sent by the remote host is
SHA256:fImGI4bZxLw7eRKZ1Sz5PJPLVGy...J3W4.
Please contact your system administrator.
Add correct host key in /home/mhubbard/.ssh/known_hosts to get rid of this message.
Offending RSA key in /home/mhubbard/.ssh/known_hosts:200
  remove with:
  ssh-keygen -f "/home/mhubbard/.ssh/known_hosts" -R "192.168.10.233"
Host key for 192.168.10.233 has changed and you have requested strict checking.
Host key verification failed.
```

You can copy/paste the following into the terminal to remove the old host:

```bash linenums='1'
ssh-keygen -f "/home/mhubbard/.ssh/known_hosts" -R "192.168.10.233"
```

On macOS you don't get the command to delete the old key but it does give you the line number in the `~/.ssh/config` file that you need to delete.

### Viewing the host-keys

```bash linenums='1' hl_lines='1 8'
show ssh host-key ?
  ecdsa    Show SSH server ECDSA host-key.
  ed25519  Show SSH server ED25519 host-key.
  rsa      Show SSH server RSA host-key.

To Show all keys

show ssh host-key

Key Type : ECDSA     Curve : ecdsa-sha2-nistp256
ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEcAjbbHW7bUnubX5SFZJ31Tkgs5dDSXMxyrXFFVC8P+rm48GQ75WIvxp4mPFFsmkJoi5OhuAA+rTncTXl3bAYM= root@switch


Key Type : ED25519
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOV1JvayGmBsryg+uyR/fKwABQ5jllra6mBRnc1pwprY


Key Type : RSA       Key Size : 4096
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCpG5P1MQOp1q98++nLoVMnwwZFsYgapfB/akN44rJ+ULOusPX95+sGCDl33kBebzeA0+AbkvBNetZRWJ7J+CBihpQ9f9ms6jS4wb1GtlV/HlP9JbpYEPIfCH9HxKHThuMLd36K/UeDkaZo4B22l8DJBIJrYl5T5hVZ73VBqdf7O/UsC9gUGZSDp7nXmCFWc38x8CW6+VBNo0K7MsHHff7ajLAi6lfrlbSOOn/Xzls3eil9bX0uzL69biflyA6y7ESnMX7PFijOoYqz2hp0cxk4La0NSJbRi+efbUyyaZ/0/xYUcnrv/QXYvCPGZEfDOycyBYgtgVD942OO+OZC3NB5jRb6QtIlb+tbw43yGcDdQiFrPUi3cxZlvnUr/CCVrnSaNEj4yliQ+QF9tLG5ap+cbAxW8I6ofy/eX6xvIuNf43ycilN+E/OJbPTvW4lndTATDeyNhHeIrPae87x0Cx0x2sHEi5dXgJdl/IQlrJFNLqydJQq1DSazVSaG7Zfd12a/9XW0fm/1InS/rQ5gd9Rot4Ou/VtNO1+v7CyAG2aaPKLaYSi4jfbCB7NFrbSlqdzLP4ODVzsWZg6CNk9bqmAb/eKaMCXK2u4w0rKVPcQJ5yYWThmAb6X2SUEi3mbGZzOEko2T9uSHpPch1EOJ6gmPkJ7kt53x2fDfbpTcUoBTEw==
```

### List the enabled auth methods

Before adding our public key check to make sure publickey authentication is enabled. Public Key Authentication is enabled by default.

```bash linenums='1' hl_lines='1'
show ssh authentication-method
 SSH publickey authentication  : Enabled
 SSH password authentication   : Enabled
 SSH two factor authentication : Disabled
```

Public key authentication can be enabled/disabled using the following:

```bash linenums='1' hl_lines='1'
no ssh public-key-authentication
ssh public-key-authentication
```

### Add your public key

This is where the Aruba shines! You need to display the public key on your laptop and copy it to the clipboard. In the [Creating SSH Keys](#creating-ssh-keys) section we created id_custom_25519, you can use the following commands to view that public key on your computer and copy it to the Aruba:

```bash linenums='1' hl_lines='1'
gnome-text-editor id_custom_25519.pub
CX-10-10(config)# user mhubbard authorized-key ssh-ed25519 AAAAC3NzaC1...FC8 mhubbard@HP8600-2328.local-2024-07-08
end
write mem
```

### View the public key

In this example, I have copied the public keys from my Linux and Mac laptops:

```bash linenums='1' hl_lines='1'
CX-10-10# show user mhubbard authorized-key

1. ed25519 AAAAC3NzaC1lZDI1NTE5...uxn mhubbard@1S1K-G5-5587-2024-07-08

2. Key Type : ED25519
ssh-ed25519 AAAAC3NzaC1lZDI1NT...KFC8 mhubbard@HP8600-2328.local-2024-07-08
```

That's all that's needed to setup pulic key login on the Aruba CX switches!

### List logged in users

I logged into the switch from my Linux and Mac laptops:

```text linenums='1' hl_lines='1'
show ssh server sessions all-vrfs

SSH sessions on VRF default :
    IPv4 SSH Sessions :
        Server IP        : 192.168.10.233
        Client IP        : 192.168.10.106
        Client Port      : 64407

        Server IP        : 192.168.10.233
        Client IP        : 192.168.10.130
        Client Port      : 42954

    IPv6 SSH Sessions :
        IPv6 session does not exist.
```

### Configure Key Exchange

The default key exchange algorithms are good but `diffie-hellman-group14-sha1` is available. Since I'm using Ubuntu 24.04 and this switch is in my lab I changed the algorithms using the following. Notice that no comma is used between the algorithms.:

```bash linenums='1' hl_lines='1'
ssh key-exchange-algorithms curve25519-sha256 curve25519-sha256@libssh.org ecdh-sha2-nistp256 ecdh-sha2-nistp384`
```

### Configure MACs

MAC stands for  message authentication code. In SSH it's actually HMAC, or Hash Message Authentication code. The default MACs are good but it does include `hmac-sha1` which is weak. Since I'm using Ubuntu 24.04 and this switch is in my lab I changed the MACs using the following. Notice that no comma is used between the macs.:

```bash linenums='1' hl_lines='1'
ssh macs hmac-sha2-256-etm@openssh.com hmac-sha2-512-etm@openssh.com hmac-sha1-etm@openssh.com hmac-sha2-256 hmac-sha2-512
```

### Configure the Public Key Algorithms

Again, the default public key algorithms are good but it does include ssh-rsa with is weak.  Since I'm using Ubuntu 24.04 and this switch is in my lab I changed the MACs using the following. I shortened the list substantially, and I really would just use the ssh-ed-25519 if I had all modern clients in my organization. Notice that no comma is used between the algorithms.:

```bash linenums='1' hl_lines='1'
ssh public-key-algorithms rsa-sha2-512 ecdsa-sha2-nistp256 ecdsa-sha2-nistp384 ecdsa-sha2-nistp521 ssh-ed25519
```

### Final SSH ciphers

Here is what the final ssh server configuration looks like. Notice that Aruba doesn't even offer ssh v1, version 2 has been available since 2006. I have no ideas why Cisco and others still ship it.

```bash linenums='1' hl_lines='1'
CX-10-10# show ssh server

SSH server configuration on VRF default :

    IP Version        : IPv4 and IPv6        SSH Version          : 2.0
    TCP Port          : 22                   Grace Timeout (sec)  : 60
    Max Auth Attempts : 6

    Ciphers:
    chacha20-poly1305@openssh.com, aes128-ctr, aes192-ctr, aes256-ctr,
    aes128-gcm@openssh.com, aes256-gcm@openssh.com

    Host Key Algorithms:
    ssh-ed25519, ecdsa-sha2-nistp521

    Key Exchange Algorithms:
    curve25519-sha256, curve25519-sha256@libssh.org, ecdh-sha2-nistp256,
    ecdh-sha2-nistp384

    MACs:
    hmac-sha2-256-etm@openssh.com, hmac-sha2-512-etm@openssh.com,
    hmac-sha1-etm@openssh.com, hmac-sha2-256, hmac-sha2-512

    Public Key Algorithms:
    rsa-sha2-512, ecdsa-sha2-nistp256, ecdsa-sha2-nistp384, ecdsa-sha2-nistp521,
    ssh-ed25519
```

### Reset cipher suites

You can reset individual cipher components or run all of these to get back to factory default settings.

```bash linenums='1' hl_lines='1'
no ssh ciphers
no host-key-algorithms
no key-exchange-algorithms
no ssh macs
no ssh public-key-algorithms
```

### Aruba CX SSH server commands

The following commands cover everything you need to do to configure ssh.

| Task | Command | Example|
| :----- | :-------------- | : -----------|
| Enabling the SSH server | ssh server vrf | ssh server vrf default |
| Disabling the SSH server | no ssh server vrf | no ssh server vrf default |
| Clearing the list of trusted SSH servers for your user account | ssh known-host remove | ssh known-host remove 192.168.10.130 |
Configuring SSH to use a set of ciphers | ssh ciphers | ssh ciphers chacha20-poly1305@openssh.com aes256-ctr aes256-cbc |
|Configuring SSH to use a set of host key algorithms | ssh host-key-algorithms | ssh host-key-algorithms ssh-rsa ssh-ed25519 ecdsa-sha2-nistp521 |
| Configuring SSH to use a set of MACs | ssh macs | ssh macs hmac-sha2-256 hmac-sha2-512 |
| Configuring SSH to use a set of key exchange algorithms | ssh key-exchange-algorithms | ssh key-exchange-algorithms ecdh-sha2-nistp256 |
| Configuring SSH to use a set of public key algorithms | ssh public-key-algorithms | ssh public-key-algorithms x509v3-ssh-rsa ssh-rsa rsa-sha2-256 |
| Showing the SSH server configuration | show ssh server | show ssh server all-vrfs |
| Showing the active SSH sessions | show ssh server sessions | show ssh server sessions all-vrfs |
| Showing the SSH server host keys | show ssh host-key | show ssh host-key ecdsa |
| Show state of local password-based (for SSH) and SSH public key authentication | show ssh authentication-method | show ssh authentication-method |
| Copying the client SSH public key into the key list | user authorized-key | user admin authorized-key ssh-ed25519 AAAAC3NzaC1lZD...uxn mhubbard@1S1K-G5-5587-2024-07-08 |
| Removing SSH public keys from the key list | user authorized-key | no user admin authorized-key 2 |
| Showing the SSH client public key list | show user | show user admin authorized-key |
| Configuring SSH idle session timeout | cli-session | <ul><li>switch(config)# cli-session</li><li> switch(config-cli-session)# timeout 20</li></ul> |

----------------------------------------------------------------

## Using the keys with an HPE Procurve switch

----------------------------------------------------------------

## Colorizing the ssh output

There is a github project called chromaterm that allows you to colorize the linux `screen` command which allows you to use a USB serial cable with color. Unfortunately that project was discontinued in 2022. It is still available on github if you want to try it out [chromaterm](https://github.com/hSaria/ChromaTerm)

Luckily a new project is available called chromaterm-- and works great with the latest version of Ubuntu. Here is the link [chromaterm--](https://github.com/Houseman303/ChromaTerm--)

On macOS, it's available from brew using `brew install hSaria/tap/chromaterm`

For Ubuntu we will clone the repository and install it. I have a directory 04_tools that I use for networking tools. You should make a directory for tools, cd into it and then run:

```bash
git clone https://github.com/hSaria/ChromaTerm--.git
cd ChromaTerm--/src/
./configure
sudo make install
```

Copy the chromatermrc config file into ~/.chromatermrc. The configuration is written in Perl Compatable Regular Expression v2. You can test new regexes using [Regex101](https://regex101.com/). Set the FLAVOUR to PCRE2 (PHP >=7.3).

You can also use chatGPT to help you create new regexes. Just tell it you need PCRE v2 regexes and it will create a regex. It will probably be an interative deal to get the regex just right.

I found a good starting configuration file [here](https://gist.github.com/vista-/88c90110dd320be4c78da4f55783b41a) and then added several Cisco IOS XE regexes.

My config file is at [Ubuntu4NetworkEngineers](https://raw.githubusercontent.com/rikosintie/Ubuntu4NetworkEngineers/main/.chromatermrc). You can click on the linnk, and copy it. Save it to `~/.chromatermrc`

You can use chromaterm with a lot of Linux commands, to use it with ssh simply pipe the output to ct.

`ssh 192.168.10.253 | ct`

Here is an [asciinema recording](https://asciinema.org/a/670211) of chromaterm-- in action.

----------------------------------------------------------------

## The OpenSSH Server

:arrow_forward: KEY TAKEAWAYS

- OpenSSH is a powerful collection of tools for remotely controlling networked computers and transferring data between them.
- OpenSSH includes SCP so you can copy files to and from a network device.
- OpenSSH can use passwords or public keys to authenticate.

Ubuntu comes with an SSH client. If you want to be able to ssh back into your laptop or send files to network devices using SCP you need to install and configure the OpenSSH server. Run these commands to enable the SSH server:

```bash
sudo apt update
sudo apt install openssh-server
```

----------------------------------------------------------------

### Useful SSH system commands

- sudo systemctl start ssh - Start the SSH server
- sudo systemctl stop ssh - Stop the SSH server
- systemctl status ssh - Show server status
- sudo systemctl disable ssh – disables SSH server after next reboot
- sudo systemctl enable ssh – enables SSH after the next reboot.

Example with OpenSSH installed but not started:

```bash linenums="1" hl_lines="1"
 systemctl status ssh
○ ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; disabled; preset: enabled)
    Drop-In: /etc/systemd/system/ssh.service.d
             └─00-socket.conf
     Active: inactive (dead)
TriggeredBy: ● ssh.socket
       Docs: man:sshd(8)
             man:sshd_config(5)
```

Notice the Active status is `inactive (dead)`.

Example with OpenSSH installed and started:

```bash linenums="1" hl_lines="1 3"
sudo systemctl start ssh

systemctl status ssh
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; disabled; preset: enabled)
    Drop-In: /etc/systemd/system/ssh.service.d
             └─00-socket.conf
     Active: active (running) since Mon 2024-07-15 09:38:12 PDT; 4s ago
TriggeredBy: ● ssh.socket
       Docs: man:sshd(8)
             man:sshd_config(5)
    Process: 3410496 ExecStartPre=/usr/sbin/sshd -t (code=exited, status=0/SUCCESS)
   Main PID: 3410497 (sshd)
      Tasks: 1 (limit: 38055)
     Memory: 1.4M
        CPU: 28ms
     CGroup: /system.slice/ssh.service
             └─3410497 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"

Jul 15 09:38:12 1S1K-G5-5587 systemd[1]: Starting ssh.service - OpenBSD Secure Shell server...
Jul 15 09:38:12 1S1K-G5-5587 sshd[3410497]: Server listening on :: port 22.
Jul 15 09:38:12 1S1K-G5-5587 systemd[1]: Started ssh.service - OpenBSD Secure Shell server.
```

Notice the Active status is `active (running) since Mon 2024-07-15 09:38:12 PDT; 4s ago`

You can see the daemon starting, listening on port 22, and then the status of the daemon changes to `Started ssh.service - OpenBSD Secure Shell server`

I don't use the `sudo systemctl enable ssh` command because I don't need SSH running all the time. I start and stop it as needed for added security.

----------------------------------------------------------------

### Edit the OpenSSH configuration file

The OpenSSH server configuration file is located at `/etc/ssh/ssh_config`. To edit the configuration file use the following command:

`sudo nano /etc/ssh/ssh_config` to edit in the terminal
or
`sudo gnome-text-editor /etc/ssh/ssh_config` if you want a GUI

Tip:
Before editing the configuration file, you should make a copy of the original /etc/ssh/sshd_config file and protect it from writing so you will have the original settings as a reference and to reuse as necessary. You can do this with the following commands:

```bash
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.original
    sudo chmod a-w /etc/ssh/sshd_config.original
```

----------------------------------------------------------------

### Check the OpenSSH server version

To check the version of the OpenSSH daemon installed:

```text linenums="1" hl_lines="1"
sshd -V
OpenSSH_9.3, OpenSSL 3.0.10 1 Aug 2023
```

----------------------------------------------------------------

### Open the SSH port on the Firewall

If you need to have a switch connect to your laptop to copy files over SCP or you want to ssh back into the laptop you will need to allow SSH through the firewall.

The following command will allow SSH through the firewall from any IP address.
`sudo ufw allow 22/tcp comment 'Open port ssh tcp port 22'`

If you want to lock down to a specific IP and subnet, in this example the host 192.168.10.100 and subnet 192.168.20.0/24:

```c#
sudo ufw allow from 192.168.10.100 to any port 22
sudo ufw allow from 192.168.20.0/24 to any port 22 proto tcp
```

----------------------------------------------------------------

### Verify the UFW firewall configuration

```bash linenums="1" hl_lines="1"
sudo ufw status numbered
[sudo] password for mhubbard:
Status: active

     To                         Action      From
     --                         ------      ----
[ 1] 514/udp                    ALLOW IN    Anywhere
[ 2] 1716:1764/tcp              ALLOW IN    Anywhere
[ 3] 1716:1764/udp              ALLOW IN    Anywhere
[ 4] 514/udp (v6)               ALLOW IN    Anywhere (v6)
[ 5] 1716:1764/tcp (v6)         ALLOW IN    Anywhere (v6)
[ 6] 1716:1764/udp (v6)         ALLOW IN    Anywhere (v6)
```

You can see that I have an IPv6 stack running. I use IPv6 in my home lab. I also have the syslog daemon installed on port 514 and I use GSConnect to communicate with my iPhone and Android phone on ports 1716-1764. Obviously I don't have a rule for SSH so let's add a UFW rule allowing SSH from any address.

```bash linenums="1" hl_lines="1 5"
sudo ufw allow 22/tcp comment 'Open ssh tcp port 22'
Rule added
Rule added (v6)

sudo ufw status numbered
Status: active

     To                         Action      From
     --                         ------      ----
[ 1] 514/udp                    ALLOW IN    Anywhere
[ 2] 1716:1764/tcp              ALLOW IN    Anywhere
[ 3] 1716:1764/udp              ALLOW IN    Anywhere
[ 4] 22/tcp                     ALLOW IN    Anywhere                   # Open port ssh tcp port 22
[ 5] 514/udp (v6)               ALLOW IN    Anywhere (v6)
[ 6] 1716:1764/tcp (v6)         ALLOW IN    Anywhere (v6)
[ 7] 1716:1764/udp (v6)         ALLOW IN    Anywhere (v6)
[ 8] 22/tcp (v6)                ALLOW IN    Anywhere (v6)              # Open port ssh tcp port 22
```

----------------------------------------------------------------

### When finished with SSH

You can either disable SSH and remove the rule or just disable SSH if you use it on a regular basis.

From the output above ssh is on lines 4 and 8. Once rule 4 is deleted, rule 8 will become rule 7!

```bash linenums="1" hl_lines="1 7 13"
sudo ufw delete 4
Deleting:
 allow 22/tcp comment 'Open port ssh tcp port 22'
Proceed with operation (y|n)? y
Rule deleted

sudo ufw delete 7
Deleting:
 allow 22/tcp comment 'Open port ssh tcp port 22'
Proceed with operation (y|n)? y
Rule deleted (v6)

sudo ufw status numbered
Status: active

     To                         Action      From
     --                         ------      ----
[ 1] 514/udp                    ALLOW IN    Anywhere
[ 2] 1716:1764/tcp              ALLOW IN    Anywhere
[ 3] 1716:1764/udp              ALLOW IN    Anywhere
[ 4] 514/udp (v6)               ALLOW IN    Anywhere (v6)
[ 5] 1716:1764/tcp (v6)         ALLOW IN    Anywhere (v6)
[ 6] 1716:1764/udp (v6)         ALLOW IN    Anywhere (v6)
```

----------------------------------------------------------------

### An alias to start ssh and add the UFW rule

```bash linenums="1" hl_lines="2"
# start the ssh daemon and display the status
alias mw-ssh='sudo systemctl start ssh && sudo ufw allow 22/tcp comment "Open ssh tcp port 22" && sudo systemctl status ssh && sudo ufw status numbered'
```

Here is the output of the alias command:

```text linenums="1" hl_lines="1"
mw-ssh
Rule updated
Rule updated (v6)
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; disabled; preset: enabled)
    Drop-In: /etc/systemd/system/ssh.service.d
             └─00-socket.conf
     Active: active (running) since Mon 2024-07-15 09:38:12 PDT; 3h 53min ago
TriggeredBy: ● ssh.socket
       Docs: man:sshd(8)
             man:sshd_config(5)
    Process: 3410496 ExecStartPre=/usr/sbin/sshd -t (code=exited, status=0/SUCCESS)
   Main PID: 3410497 (sshd)
      Tasks: 1 (limit: 38055)
     Memory: 1.4M
        CPU: 28ms
     CGroup: /system.slice/ssh.service
             └─3410497 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"

Jul 15 09:38:12 1S1K-G5-5587 systemd[1]: Starting ssh.service - OpenBSD Secure Shell server...
Jul 15 09:38:12 1S1K-G5-5587 sshd[3410497]: Server listening on :: port 22.
Jul 15 09:38:12 1S1K-G5-5587 systemd[1]: Started ssh.service - OpenBSD Secure Shell server.
Status: active

     To                         Action      From
     --                         ------      ----
[ 1] 514/udp                    ALLOW IN    Anywhere
[ 2] 1716:1764/tcp              ALLOW IN    Anywhere
[ 3] 1716:1764/udp              ALLOW IN    Anywhere
[ 4] 22/tcp                     ALLOW IN    Anywhere                   # Open port ssh tcp port 22
[ 5] 514/udp (v6)               ALLOW IN    Anywhere (v6)
[ 6] 1716:1764/tcp (v6)         ALLOW IN    Anywhere (v6)
[ 7] 1716:1764/udp (v6)         ALLOW IN    Anywhere (v6)
[ 8] 22/tcp (v6)                ALLOW IN    Anywhere (v6)              # Open port ssh tcp port 22
```

----------------------------------------------------------------

### An alias to stop ssh and remove the ufw rule

```bash linenums="1" hl_lines="2"
# stop the ssh daemon and display the status
alias mw-ssh-stop='sudo systemctl stop ssh && sudo ufw delete allow 22/tcp && sudo systemctl status ssh && sudo ufw status numbered'
```

Here is the output of the alias command:

```text linenums="1" hl_lines="1"
mw-ssh-stop
Warning: Stopping ssh.service, but it can still be activated by:
  ssh.socket
Rule deleted
Rule deleted (v6)
○ ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; disabled; preset: enabled)
    Drop-In: /etc/systemd/system/ssh.service.d
             └─00-socket.conf
     Active: inactive (dead) since Mon 2024-07-15 13:37:02 PDT; 403ms ago
   Duration: 3h 58min 50.090s
TriggeredBy: ● ssh.socket
       Docs: man:sshd(8)
             man:sshd_config(5)
    Process: 3410496 ExecStartPre=/usr/sbin/sshd -t (code=exited, status=0/SUCCESS)
    Process: 3410497 ExecStart=/usr/sbin/sshd -D $SSHD_OPTS (code=exited, status=0/SUCCESS)
   Main PID: 3410497 (code=exited, status=0/SUCCESS)
        CPU: 30ms

Jul 15 09:38:12 1S1K-G5-5587 systemd[1]: Starting ssh.service - OpenBSD Secure Shell server...
Jul 15 09:38:12 1S1K-G5-5587 sshd[3410497]: Server listening on :: port 22.
Jul 15 09:38:12 1S1K-G5-5587 systemd[1]: Started ssh.service - OpenBSD Secure Shell server.
Jul 15 13:37:02 1S1K-G5-5587 sshd[3410497]: Received signal 15; terminating.
Jul 15 13:37:02 1S1K-G5-5587 systemd[1]: Stopping ssh.service - OpenBSD Secure Shell server...
Jul 15 13:37:02 1S1K-G5-5587 systemd[1]: ssh.service: Deactivated successfully.
Jul 15 13:37:02 1S1K-G5-5587 systemd[1]: Stopped ssh.service - OpenBSD Secure Shell server.
```

### References - OpenSSH Server

- [How to Set Up and Use SSH in Linux](https://www.maketecheasier.com/setup-enable-ssh-ubuntu/)
- [How to open ssh 22/TCP port using ufw on Ubuntu](https://www.cyberciti.biz/faq/ufw-allow-incoming-ssh-connections-from-a-specific-ip-address-subnet-on-ubuntu-debian/)
- [How to delete a UFW firewall rule on Ubuntu](https://www.cyberciti.biz/faq/how-to-delete-a-ufw-firewall-rule-on-ubuntu-debian-linux/)

----------------------------------------------------------------

## Yubico Authenticator

Yubico is one of the companies that makes Physical Security keys. These allow you to copy your private key to the Yubico and have access no matter what laptop you are on with just one key. It's beyond the scope of this guide but here are links to Yubico.

- [Highest assurance authentication that’s fast and easy](https://www.yubico.com/products/yubikey-5-overview/)
- [Securing SSH Authentication with FIDO2](https://developers.yubico.com/SSH/Securing_SSH_with_FIDO2.html)

----------------------------------------------------------------

## Brute Forcing SSH

I mentioned in the creating ssh keys section that usernames and passwords are easier to brute-force than keys are. You can use nmap to brute force ssh. In this example I created a file named users.lst and a file named pass.lst with valid user and passwords for the switch.

Obviously an attacker would be using a breach list or a social engineered list of names and passwords. But for demo purposes I didn't want to spend hours running nmap. I have a list of all the passwords that customers have given me over the years that I use in real situations.

I have had to use this method more than once at small school districts and other customers that don't have ISE or Clearpass and have used local creds. I also had to use this once at a Community College that had the network team arrested!

This should make it clear that you should set a limit on the number of login attempts!

```c# linenums="1" hl_lines="1"
nmap -p 22 --script ssh-brute --script-args userdb=./users.lst,passdb=./pass.lst 192.168.10.253
Starting Nmap 7.95 ( https://nmap.org ) at 2024-07-24 23:36 PDT
NSE: [ssh-brute] Trying username/password pair: mhubbard:R00tIsTheG0al
NSE: [ssh-brute] Trying username/password pair: thubbard:Sup3rS3cr3t
Nmap scan report for 3850.pu.pri (192.168.10.253)
Host is up (0.0046s latency).

PORT   STATE SERVICE
22/tcp open  ssh
| ssh-brute:
|   Accounts:
|     mhubbard:R00tIsTheG0al - Valid credentials
|     thubbard:Sup3rS3cr3t - Valid credentials
|_  Statistics: Performed 4 guesses in 9 seconds, average tps: 0.4

Nmap done: 1 IP address (1 host up) scanned in 11.07 seconds
```

----------------------------------------------------------------

## General SSH  References

- [Upgrade your SSH keys!](https://blog.g3rt.nl/upgrade-your-ssh-keys.html) - In this post I'll demonstrate how to transition to an Ed25519 type of key smoothly, why you would want this and show some tips and tricks on the way there.
- [Authenticating to Cisco devices using SSH and your RSA Public Key](https://mwhubbard.blogspot.com/2015/07/authenticating-to-cisco-devices-using_92.html) - Here is a blog post I did on setting up the network device to use ssh keys.
- [Why you should be using scrypt for Cisco Router Password Storage](https://community.cisco.com/t5/security-knowledge-base/why-you-should-be-using-scrypt-for-cisco-router-password-storage/ta-p/3157196)
- [SSH Command - Usage, Options, Configuration](https://www.ssh.com/academy/ssh/command) - SSH Academy tips and tricks
- [sshd_config - How to Configure the OpenSSH Server?](https://www.ssh.com/academy/ssh/sshd_config) SSH Academy Tutorial on SSH server configuration
- [Aruba CX ssh ciphers](https://www.arubanetworks.com/techdocs/AOS-CX/10.07/HTML/5200-7837/Content/Chp_SSH_serv/SSH_serv_cmds/ssh-cip.htm) - The Aruba CX platform supports state of the art crypto!
- [Arch wiki on ssh server](https://wiki.archlinux.org/title/OpenSSH) Good information on OpenSSH including configuring Google Authenticator
- [Arch wiki on ssh keys](https://wiki.archlinux.org/title/SSH_keys) - As always, the Arch wiki has a great page on ssh
- [The Ultimate Guide to SSH - Setting Up SSH Keys](https://www.freecodecamp.org/news/the-ultimate-guide-to-ssh-setting-up-ssh-keys/)

----------------------------------------------------------------

## Apendix A - IOS-XE CIPHERS

- From Cisco IOS XE Release 17.10, the Secure Shell Version 1.99 is not supported.
- From Cisco IOS XE Release 17.10, the minimum RSA key pair size must be 2048 bits.
- From Cisco IOS XE Release 17.11, if you want to continue using the weak RSA key, disable CSDL compliance on the device using the `crypto engine compliance shield disable` command, and reboot.

### Secure Shell Version 2

The configuration for the SSH Version 2 server is similar to the configuration for SSH Version 1. The ip ssh version command defines the SSH version to be configured. If you do not configure this command, SSH by default runs in compatibility mode; that is, both SSH Version 1 and SSH Version 2 connections are honored.

The `ip ssh rsa keypair-name` command enables an SSH connection using the Rivest, Shamir, and Adleman (RSA) keys that you have configured. Previously, SSH was linked to the first RSA keys that were generated (that is, SSH was enabled when the first RSA key pair was generated). This behavior still exists, but by using the `ip ssh rsa keypair-name` command, you can overcome this behavior.

If you configure the `ip ssh rsa keypair-name` command with a key pair name, SSH is enabled if the key pair exists or SSH will be enabled if the key pair is generated later. If you use this command to enable SSH, you are not forced to configure a hostname and a domain name, which was required in SSH Version 1 of the Cisco software.

----------------------------------------------------------------

| Supported Algorithms | Default                                                                                                                                                                                                                               |                Non-Default                |
|:--------------------:|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-----------------------------------------:|
| Encryption           | chacha20-poly1305@openssh.com <br> aes128-gcm@openssh.com aes256-gcm@openssh.com aes128-gcm aes256-gcm aes128-ctr aes192-ctr  aes256-ctr                                                                                    | aes128-cbc aes192-cbc aes256-cbc 3des-cbc |
| HMAC                 | * hmac-sha2-256-etm@openssh.com * hmac-sha2-512-etm@openssh.com                                                                                                                                                                       | hmac-sha1 hmac-sha2-256 hmac-sha2-512     |
| Host Key             | * rsa-sha2-512 * rsa-sha2-256 *ssh-rsa                                                                                                                                                                                                | x509v3-ssh-rsa                            |
| KEX DH Group         | * curve25519-sha256 * curve25519-sha256@libssh.org * ecdh-sha2-nistp256 * ecdh-sha2-nistp384 * ecdh-sha2-nistp521 * diffie-hellman-group14-sha256 * diffie-hellman-group16-sha512                                                     | diffie-hellman-group14-sha1               |
| Public Key           | * ssh-rsa * ecdsa-sha2-nistp256 * ecdsa-sha2-nistp384 * ecdsa-sha2-nistp521 * ssh-ed25519 * x509v3-ecdsa-sha2-nistp256 * x509v3-ecdsa-sha2-nistp384 * x509v3-ecdsa-sha2-nistp521 * rsa-sha2-256 * rsa-sha2-512 *x509v3-rsa2048-sha256 | x509v3-ssh-rsa                            |
