# SSH

I highly recommend [SSH Mastery](https://mwl.io/nonfiction/tools#ssh) by Michael Lucas. It’s available at [SSH Mastery](https://mwlucas.gumroad.com/l/CngLH) or [Amazon](https://www.amazon.com/).

When I switched to Linux my only experience with SSH was Putty. There is so much more to SSH and Michael explains all of it.

----------------------------------------------------------------

## Connecting to Network Devices

To connect using ssh:

- Open the terminal
- Enter the following command.

`ssh mhubbard@192.168.10.253`

Change the username and IP address to fit your device.

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

You can also use shell commands to get just what you need. For example, let's say I want to know what `ip ssh` commands are in the running configuration.

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

One problem for a network engineer is that newer versions of the OpenSSH client don’t allow weak crypto by default and most network devices have weak ciphers by default. If you are connecting to network devices from a modern version of Mac/Linux you will probably get an error and the connection will fail. You will have to customize the `~/.ssh/config` file to add the ciphers needed.

This is an example trying to connect to a Cisco 3850 IOS XE switch running 16.12.3a:

```bash
Unable to negotiate with 192.168.10.253 port 22: no matching key exchange method found. Their offer: diffie-hellman-group14-sha1
```

Here is the entry I added to ~/.ssh/config:

```bash
nano ~/.ssh/config
Host 192.168.10.253
        KexAlgorithms diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1,diffie-hellman-group1-sha1
        MACs hmac-sha1,hmac-sha2-256,hmac-sha2-512
        HostKeyAlgorithms ssh-rsa
```

You can add an SSH key file if you have more than one and a custom port if needed:

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

I have run across  network devices that required the ancient `dss` HostKeyAlgorithm. Add that with:
`HostKeyAlgorithms ssh-dss`

### Using a wildcard in the config file

If you have 100s or 1000s of devices with legacy crypto it gets painful to create an entry in `~/.ssh/config` for every device. You can use a wildcard in the configuration file that will pass the same configuration to every connection. Keep in mind that the wildcard configuration applies to all devices, not just network devices.

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

### What crypto does my device support?

On most switches you can use something like `show ip ssh` to get a list of the current ssh ciphers.

Here is an example from the Cisco 3850 in my home lab:

```bash
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

### Checking ciphers with nmap

For devices that don't have `show ip ssh`, like IoT devices, you can use nmap with the built in `ssh-enum-algos` script. This is from the Ubiquiti Nano Station in my home lab.

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

This is an example of why you don't want to use the wildcard in the configuration file. depending on the client you could end up using sha1 instead of sha2 or ssh-dss instead of ssh-rsa.

nmap also has a similar script for checking SSL (TLS) crypto:

```bash
sudo nmap --script ssl-cert,ssl-enum-ciphers -p 443,465,993,995,3389 192.168.10.253
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
465/tcp  closed smtps
993/tcp  closed imaps
995/tcp  closed pop3s
3389/tcp closed ms-wbt-server
MAC Address: F8:7B:20:34:A3:C6 (Cisco Systems)

Nmap done: 1 IP address (1 host up) scanned in 1.53 seconds
```

For new deployments you should take the time to remove legacy crypto before installing the switches. Once you decide on the best setup, add it to your base template. This is a best practice and will save you some embarrassment if the customer has a security team. Don't ask me how I know this.

If you have written permission from the network owner, you can use these scripts to do a quick security assessment of the existing network devices. I have a python script that creates a menu of nmap commands for security testing. You can find it [here](https://github.com/rikosintie/nmap-python).

THe script is easy to use has a lot of nmap goodness for a network engineer.

----------------------------------------------------------------

## Creating SSH Keys

The OpenSSH client allows you to create custom SSH keys. You can create as many keys as you need. You should think about your security requirements and create SSH keys to fit the requirements. For example, if you work for a VAR or MSP, you may want to create unique keys for each customer.

My current recommended public-key signing algorithm is Bruce Schneier's ED25519. To create a set of keys using ed25519, run the following in the terminal from the ~/.ssh directory:

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

### Display the existing keys on Ubuntu

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
4096 SHA256:0WF9uxNBCPeeHzMAGsYJy2wrsOXNrhPxJ+3lp2PxI+E mhubbard@1S1K-G5-5587-2024-07-11 (RSA)
2048 SHA256:YRwfm94a26cfCQZK6mT3SO29XaLoAHWJgnixN2OZDM0 mhubbard@1S1K-G5-5587 (RSA)
```

You can see the comment on the first key.

You can print the file name out by adding a print statement:

```bash
for keyfile in ~/.ssh/id_*.pub; do ssh-keygen -l -f "${keyfile}"; print ${keyfile}; done | uniq
256 SHA256:2uWbzS9A/4dI+ZS+bM8f5q6wTqeb8vsBvylvQi5B9dE mhubbard@1S1K-G5-5587-2024-07-08 (ED25519)
/home/mhubbard/.ssh/id_custom_25519.pub
256 SHA256:2XtMiDbg64rBnUXOzcFFXqwzUbbAjAO2Y9RwrWvVTB4 michael.hubbard999@gmail.com (ED25519)
/home/mhubbard/.ssh/id_github.pub
4096 SHA256:0WF9uxNBCPeeHzMAGsYJy2wrsOXNrhPxJ+3lp2PxI+E mhubbard@1S1K-G5-5587-2024-07-11 (RSA)
/home/mhubbard/.ssh/id_rsa.pub
2048 SHA256:YRwfm94a26cfCQZK6mT3SO29XaLoAHWJgnixN2OZDM0 mhubbard@1S1K-G5-5587 (RSA)
/home/mhubbard/.ssh/id_rsa_pub_2096.pub


### SSH Key permissions

The private key should have rw permission to only the user. No other users or groups should have any permissions. Use the following to view/set the permissions:

```bash
ls -l
-rw-------    1 mhubbard  staff   464B Jul  8 15:54 id_custom_25519
-rw-r--r--    1 mhubbard  staff   108B Jul  8 15:54 id_custom_25519.pub

If the permissions are wrong, use the following:
chmod 600 ~/.ssh/id_custom_25519
```

Here is the output using keys with 0644 instead of 0600:

```bash
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

## Using the SSH keys

Once you have keys created what do you do with them? If you support Linux servers it's very easy to copy the public key to the server. Using a Public/Private key pair instead of a password to authenticate an SSH session is popular on Linux/Unix boxes.

Digital Ocean, a Virtual Private Server (VPS) provider, has this advice on how you should log into their Droplets:  "you should use public key authentication instead of passwords, if at all possible. This is because SSH keys provide a more secure way of logging in compared to using a password alone. While a password can eventually be cracked with a brute-force attack, SSH keys are nearly impossible to decipher by brute force alone." Plus, it means you never have to type C!$c0 again!

 Following along with our `id_custom_25519` example and an Ubuntu server at 192.168.10.223:

```bash
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
$ ssh '192.168.10.223'
Welcome to Ubuntu 24.04 LTS (GNU/Linux 6.8.0-35-generic x86_64)
```

Since we created a passphrase for key we are prompted for the passphrase, then logged in.

If you need to have automated login, you can create a key without a passphrase. The actual connection is still secure, but if you lose control of the private key anyone can use it. It's one of those religious arguments that exit in security circles.

## Using the keys with a Cisco IOS switch

Unfortunately it's not quite as easy to enable key based login on network devices but it's just a process. You can include it in your basic security template for example and automate it.

I'm using a WS-C3850-48U running 16.12.3a CAT3K_CAA-UNIVERSALK9 for this example.

### Configure a Time Server

Accurate time is required to use ssh keys. The first step is to configure a time server.

```bash
no ntp allow mode control 3
ntp server ip time-b.nist.gov
ntp server 192.168.10.222 prefer
```

The `no ntp allow mode control 3` is a Cisco recommended best practice to prevent DOS attacks.

- ntp allow mode control 3 --> causes the device to respond to mode 6 packet with a delay of 3 seconds, hence rate limiting and being considered not vulnerable (recommended)

#### Check NTP server config with nmap

nmap has two built in scripts for checking the NTP server configuration.

```bash
sudo nmap -sU -p 123 -n --script=ntp-monlist  192.168.10.253
sudo nmap -sU -p 123 --script ntp-info 192.168.10.253
```

The first one is for verifying that your ntp server doesn't support the "Monitor List" command that led to serious DDoS attacks back in 2014. Here I ran it against the ntp server on the Cisco 3850:

```bash
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

```bash
#Run the nmap ntp-info script. $1 is the ip of the ntp server.
alias mw-ntp='(){sudo nmap -sU -p 123 --script ntp-info $1}'
mw-ntp 192.168.10.253
```

Here I ran it against my Cisco 3850 after I configured it for time.

```bash
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

```bash
show ntp association

  address         ref clock       st   when   poll reach  delay  offset   disp
+~129.6.15.29     .NIST.           1    369   1024   377 68.998  -1.408  1.066
*~192.168.10.222  129.6.15.28      2    109   1024   377  0.989   0.619  1.037
 * sys.peer, # selected, + candidate, - outlyer, x falseticker, ~ configured
```

### Add a Domain Name, create the key, set SSH v2

To use ssh on the switch you have to create an SSH key pair. I used EC instead of RSA to enable SSH, but the key used to authenticate to the IOS XE device must be rsa. Again, most network devices have crap for crypto ciphers.

```bash
ip domain name pu.pri
crypto key generate ec keysize 384 exportable label EC-SSH-Key
ip ssh version 2
```

Note the "exportable" parameter. This isn't required but I wanted to point that out that you can make the keys exportable. It's not so important in this case but if you have setup GetVPN on a router you absolutely want to export the keys used for the tunnels. If you don't and the router fails you will have to touch EVERY tunnel once you replace the hardware. If you have exported the keys you just reload them on the new hardware and call it a day.

#### Display the key

```bash
show crypto key mypubkey ec EC-SSH-Key
% Key pair was generated at: 13:41:45 PDT Jul 11 2024
Key name: EC-SSH-Key
Key type: EC KEYS
 Storage Device: private-config
 Usage: Signature Key
 Key is exportable. Redundancy enabled.
 Key Data:
  30763010 06072A86 48CE3D02 0106052B 81040022 03620004 B1EB5A86 1C06FB4B
  4BE9C828 38A03D4C EF8BF634 EC796891 E6BD4082 7E47F9E2 B92AE813 464AC0B9
  588B716F 93866092 D8F097B0 984D5E98 36816223 57FB8FCC D06F7378 8218FFB0
  7FC83A93 718D4C08 400EE244 98045041 74F15237 02742339
```

#### Export the Key

```bash
(config)#crypto key export ec EC-SSH-Key pem terminal 3des Sup3rS3crt
% Key name: EC-SSH-Key
   Usage: Signature Key
   Key data:
-----BEGIN PUBLIC KEY-----
MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEsetahhwG+0tL6cgoOKA9TO+L9jTseWiR
5r1Agn5H+eK5KugTRkrAuViLcW+ThmCS2PCXsJhNXpg2gWIjV/uPzNBvc3iCGP+w
f8g6k3GNTAhADuJEmARQQXTxUjcCdCM5
-----END PUBLIC KEY-----
-----BEGIN EC PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: DES-CBC,F9622ABF564FFE99

vSH9tLuZsR1pAWGN/ojaa5x7Xguk/4IcQqOH5eVHJoCMZ7vAKTbFsnlmFqbS7zNS
YUn/cKmH59qFWvPjcQBqqQ1HF/gMEfCr3l8PBZ42nW0=
-----END EC PRIVATE KEY-----
```

Copy the key stating at `BEGIN PUBLIC KEY` until `END PRIVATE KEY`, save it to a file and store it in a secure place.

### Configure AAA authentication

The aaa new-model command causes the local username and password on the router to be used in the absence of other AAA statements. Once you enter "aaa new-model" you will not be able to enter "login local" on vty line configuration. If you had login local configured it will be removed.

When you create the username be sure to include a secret. I you don't anyone will be able to login with just the username. As always, create a strong secret and use a password manager to store it.

```bash
(config)#username mhubbard privilege 15 secret ^8(nn-!#who
(config)#aaa new-model
(config)#aaa authentication login default local
(config)#aaa authorization exec default local
(Authentication through the line password is not possible with SSH)
```

#### Configure the vty lines

```bash
(config)#line vty 0 4
(config-line)#transport input ssh
(config-line)#logging sync (prevents console messages from interfering with your inputs)
```

### Add your PUBLIC key to the device

Open the public key file you created earlier in text editor. Copy the text between the comments. If you generated a 2048/4096 bit key you will need to break it into smaller pieces or you may see "%SSH: Failed to decode the Key Value" when you exit. I break it into 100 characters per line.

```bash
gnome-text-editor id_rsa.pub
break the lines into lengths of 100 characters
copy the text after ssh-rsa till the comment begins.
close the key file but do not save it
```

**Paste the key into the device**

```bash
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

### Verify the ssh configuration

```bash
show run | sec ssh
ip ssh source-interface Vlan10
ip ssh rsa keypair-name SSH-KEYS
ip ssh version 2
ip ssh dh min size 4096
ip ssh pubkey-chain
  username mhubbard
   key-hash ssh-rsa 5D24EA1D261C1836E437F4E67E2CEBEB
ip ssh server algorithm mac hmac-sha2-256 hmac-sha2-512
ip ssh server algorithm encryption aes256-ctr aes192-ctr aes128-ctr
ip ssh server algorithm kex diffie-hellman-group14-sha1
 transport input ssh
 transport output ssh

```

Note - You can use the HASH instead of the key for the next devices you setup. Instead of using "Key-string" in the ip ssh pubkey-chain statement use `key-hash ssh-rsa 5D24EA1D261C1836E437F4E67E2CEBEB`.

If you need to remove a key use the `no` keyword with the key-hash keyword. I needed to remove the old 2096 bit RSA key after I changed the `ip ssh dh min key size` to 4096.

```bash
ip ssh pubkey-chain
username mhubbard
no key-hash ssh-rsa 4682578A0267D583568FCDCD1229B62C`
```

### Login using the SSH Keys

Continuing in the theme of network devices having crap crypto, you will have to add `PubkeyAcceptedKeyTypes +ssh-rsa` to the `~/.ssh/config` file for the host. Maybe by 2030 the network vendors will have decent crypto. But, by 2030, the current crypto will be deprecated!

`ssh -i ~/.ssh/id_rsa.pub 192.168.10.253`

Remember that you can add -vvvv to the command to get verbose debugging. I had to do that because the key was failing. In the debugs I saw `send_pubkey_test: no mutual signature algorithm` which reminded me to add  `PubkeyAcceptedKeyTypes +ssh-rsa` to the config file for this host.

You can also use `ssh 192.168.10.253` and the SSH client will try all the keys. I prefer to explicitly call the key, but it doesn't matter if you don't.

If you want to connect from a Windows computer with Putty I have a blog with a tutorial on how to create keys and connect using putty/puttygen - [Authenticating to Cisco devices using SSH and your RSA Public Key](https://mwhubbard.blogspot.com/2015/07/authenticating-to-cisco-devices-using_92.html).

#### Can users still login who don't have keys configured?

Yes, the key-chain must be configured for each user.

```bash
sh run | sec pubkey
ip ssh pubkey-chain
  username mhubbard
   key-hash ssh-rsa 5D24EA1D261C1836E437F4E67E2CEBEB
   key-hash ssh-rsa CCA79DBB37A7EA060C781DA2767509C0
```

Here are the users I have configured on this switch:

```bash
show run | sec user
username thubbard privilege 15 secret 9 $9$95tTO1OC4HNmIE$bt1Z4.7aw/EBUQHl3NmLUNMacw4hRPI.742Kbs2r4jA
username mhubbard privilege 15 secret 9 $9$y4j0lAgHcDtV3.$sH6LI79G3qmdpVdICokss8dzjGUC3u7we4.wcPnwNQ.
  username mhubbard
   key-hash ssh-rsa 5D24EA1D261C1836E437F4E67E2CEBEB
   key-hash ssh-rsa CCA79DBB37A7EA060C781DA2767509C0
```

You can see that `thubbard` has to use a password but `mhubbard` can use a password or SSH keys. User `mhubbard` has two keys listed because I generated keys on my Ubuntu machine and my M1 MacBook Air. I could have copiied my private key from Ubuntu to the MacBook but I wanted to show two keys.

Note that IOS XE only allows two keys in the key-chain.

You can see in the ouput the user's secret is hashed as type 9. In Cisco speak that is scrypt. Scrypt is a `memory` hard hash so having hardware GPUs doesn't speed up reversing the hash. To create a users with scrypt:

`username thubbard privilege 15 algorithm-type scrypt secret Sup3rS3cr3t`

## Using the keys with a JunOS switch

Setting up the JunOS switch is similar to setting up the Cisco switch.

```bash
ssh -i ~/.ssh/juniper_ed25519_key root@192.168.10.162
Authorized access only! Violators will be violated!
Enter passphrase for key '/home/mhubbard/.ssh/juniper_ed25519_key':
Last login: Fri Jul 12 14:01:28 2024 from 192.168.10.143
--- JUNOS 18.2R1.9 Kernel 64-bit  JNPR-11.0-20180614.6c3f819_buil
root@TEST-Router:~ #
```

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

```bash
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

```bash
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

----------------------------------------------------------------

### Check the OpenSSH server version

To check the version of the OpenSSH daemon installed:

```bash
sshd -V
OpenSSH_9.3, OpenSSL 3.0.10 1 Aug 2023
```

----------------------------------------------------------------

### Open the SSH port on the Firewall

If you need to have a switch connect to your laptop to copy files over SCP or you want to ssh back into the laptop you will need to allow SSH through the firewall.

The following command will allow SSH through the firewall from any IP address.
`sudo ufw allow 22/tcp comment 'Open port ssh tcp port 22'`

If you want to lock down to a specific IP and subnet, in this example the host 192.168.10.100 and subnet 192.168.20.0/24:

```bash
sudo ufw allow from 192.168.10.100 to any port 22
sudo ufw allow from 192.168.20.0/24 to any port 22 proto tcp
```

----------------------------------------------------------------

### Verify the UFW firewall configuration

```bash
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

```bash
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

```bash
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

```bash
# start the ssh daemon and display the status
alias mw-ssh='sudo systemctl start ssh && sudo ufw allow 22/tcp comment "Open ssh tcp port 22" && sudo systemctl status ssh && sudo ufw status numbered'
```

Here is the output of the alias command:

```bash
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

```bash
# stop the ssh daemon and display the status
alias mw-ssh-stop='sudo systemctl stop ssh && sudo ufw delete allow 22/tcp && sudo systemctl status ssh && sudo ufw status numbered'
```

Here is the output of the alias command:

```bash
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

References:

- [How to Set Up and Use SSH in Linux](https://www.maketecheasier.com/setup-enable-ssh-ubuntu/)
- [How to open ssh 22/TCP port using ufw on Ubuntu](https://www.cyberciti.biz/faq/ufw-allow-incoming-ssh-connections-from-a-specific-ip-address-subnet-on-ubuntu-debian/)
- [How to delete a UFW firewall rule on Ubuntu](https://www.cyberciti.biz/faq/how-to-delete-a-ufw-firewall-rule-on-ubuntu-debian-linux/)

----------------------------------------------------------------
## Yubico Authenticator

Yubico is one of the companies that makes Physical Security keys. These allow you to copy your private key to the Yubico and have access no matter what laptop you are on with just one key. It's beyond the scope of this guide but here are links to Yubico.

- [Highest assurance authentication that’s fast and easy](https://www.yubico.com/products/yubikey-5-overview/)
- [Securing SSH Authentication with FIDO2](https://developers.yubico.com/SSH/Securing_SSH_with_FIDO2.html)

## Reference

- [Upgrade your SSH keys!](https://blog.g3rt.nl/upgrade-your-ssh-keys.html) - In this post I'll demonstrate how to transition to an Ed25519 type of key smoothly, why you would want this and show some tips and tricks on the way there.
- [Authenticating to Cisco devices using SSH and your RSA Public Key](https://mwhubbard.blogspot.com/2015/07/authenticating-to-cisco-devices-using_92.html) - Here is a blog post I did on setting up the network device to use ssh keys.
- [Why you should be using scrypt for Cisco Router Password Storage](https://community.cisco.com/t5/security-knowledge-base/why-you-should-be-using-scrypt-for-cisco-router-password-storage/ta-p/3157196)
- [SSH Command - Usage, Options, Configuration](https://www.ssh.com/academy/ssh/command) - SSH Academy tips and tricks
- [sshd_config - How to Configure the OpenSSH Server?](https://www.ssh.com/academy/ssh/sshd_config) SSH Academy Tutorial on SSH server configuration
- [Aruba CX ssh ciphers](https://www.arubanetworks.com/techdocs/AOS-CX/10.07/HTML/5200-7837/Content/Chp_SSH_serv/SSH_serv_cmds/ssh-cip.htm) - The Aruba CX platform supports state of the art crypto!
- [Arch wiki on ssh server](https://wiki.archlinux.org/title/OpenSSH) Good information on OpenSSH including configuring Google Authenticator
- [Arch wiki on ssh keys](https://wiki.archlinux.org/title/SSH_keys) - As always, the Arch wiki has a great page on ssh
