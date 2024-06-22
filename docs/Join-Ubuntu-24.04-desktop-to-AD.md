# Join Ubuntu 24.04 desktop to AD

The VM should be fully updated and running in VMware workstation

## Check the current host configuration

```bash
mhubbard@z420VM-2404:~$ hostnamectl
 Static hostname: z420VM-2404.pu.pri
       Icon name: computer-vm
         Chassis: vm 🖴
      Machine ID: c7fecbdab8ed4fdba09c3833e51fc616
         Boot ID: e71c80c79fb54e2b9e88ea1c77e005a9
  Virtualization: vmware
Operating System: Ubuntu 24.04 LTS
          Kernel: Linux 6.8.0-31-generic
    Architecture: x86-64
 Hardware Vendor: VMware, Inc.
  Hardware Model: VMware Virtual Platform
Firmware Version: 6.00
   Firmware Date: Thu 2020-11-12
    Firmware Age: 3y 6month 2w 3d
```

## If the host needs to have the FQDN configured.

```bash
mhubbard@z420VM-2404:~$ sudo hostnamectl set-hostname z420VM-2404.pu.pri
mhubbard@z420VM-2404:~$ hostname
z420VM-2404.pu.pri
```

## Verify that the host can be found in DNS

```bash
mhubbard@z420VM-2404:~$ host z420VM-2404
z420VM-2404.pu.pri has address 192.168.10.105
mhubbard@z420VM-2404:~$ host 192.168.10.105
105.10.168.192.in-addr.arpa domain name pointer ubuntu.pu.pri.
```

### Use dig to verify that DNS works

```bash
mhubbard@z420VM-2404:~$ dig -x 192.168.10.105

; <<>> DiG 9.18.24-0ubuntu5-Ubuntu <<>> -x 192.168.10.105
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 46458
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;105.10.168.192.in-addr.arpa.    IN   PTR

;; ANSWER SECTION:
105.10.168.192.in-addr.arpa. 3105 IN    PTR  ubuntu.pu.pri.

;; Query time: 1 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
;; WHEN: Thu May 30 14:54:19 PDT 2024
;; MSG SIZE  rcvd: 83
```

## Use dig with the hostname

```bash
mhubbard@z420VM-2404:~$ dig z420VM-2404

; <<>> DiG 9.18.24-0ubuntu5-Ubuntu <<>> z420VM-2404
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 19658
;; flags: qr aa rd ra ad; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;z420VM-2404.			IN	A

;; ANSWER SECTION:
z420VM-2404.		0	IN	A	192.168.10.105

;; Query time: 3 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
;; WHEN: Thu May 30 14:54:54 PDT 2024
;; MSG SIZE  rcvd: 56
```

### Verify that a DC (192.168.10.222) is the DNS resolver
```bash
mhubbard@z420VM-2404:~$ resolvectl status
Global
         Protocols: -LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
  resolv.conf mode: stub

Link 2 (ens33)
    Current Scopes: DNS
         Protocols: +DefaultRoute -LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
Current DNS Server: 192.168.10.222
       DNS Servers: 192.168.10.222
        DNS Domain: pu.pri
```

### Display the NTP server

`cat /etc/systemd/timesyncd.conf`

If you see `#NTP` then you will need to edit the `/etc/systemd/timesyncd.conf file.

`sudo nano /etc/systemd/timesyncd.conf`

Set the DC as the NTP server
[Time]
NTP=192.168.10.222
FallbackNTP=time-b.nist.gov

Verify that the time matches the DC.
On the DC, cmd, time
mhubbard@z420VM-2404:~$ timedatectl status
               Local time: Thu 2024-05-30 14:58:08 PDT
           Universal time: Thu 2024-05-30 21:58:08 UTC
                 RTC time: Thu 2024-05-30 21:58:08
                Time zone: America/Los_Angeles (PDT, -0700)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no

mhubbard@z420VM-2404:~$ systemctl daemon-reload

sudo apt update

sudo apt install sssd-ad sssd-tools realmd adcli

mhubbard@z420VM-2404:~$ realm -v discover pu.pri
 * Resolving: _ldap._tcp.pu.pri
 * Performing LDAP DSE lookup on: 192.168.10.222
 * Successfully discovered: pu.pri
pu.pri
  type: kerberos
  realm-name: PU.PRI
  domain-name: pu.pri
  configured: no
  server-software: active-directory
  client-software: sssd
  required-package: sssd-tools
  required-package: sssd
  required-package: libnss-sss
  required-package: libpam-sss
  required-package: adcli
  required-package: samba-common-bin

mhubbard@z420VM-2404:~$ sudo touch /etc/krb5.conf

mhubbard@z420VM-2404:~$ sudo nano /etc/krb5.conf
[libdefaults]
    default_realm = PU.PRI
    rdns = false

mhubbard@z420VM-2404:~$ sudo cat /etc/krb5.conf
[libdefaults]
    default_realm = PU.PRI
    rdns = false

mhubbard@z420VM-2404:~$ apt policy sssd-ad sssd-tools realmd adcli
sssd-ad:
  Installed: 2.9.4-1.1ubuntu6
  Candidate: 2.9.4-1.1ubuntu6
  Version table:
 *** 2.9.4-1.1ubuntu6 500
        500 http://us.archive.ubuntu.com/ubuntu noble/main amd64 Packages
        100 /var/lib/dpkg/status
sssd-tools:
  Installed: 2.9.4-1.1ubuntu6
  Candidate: 2.9.4-1.1ubuntu6
  Version table:
 *** 2.9.4-1.1ubuntu6 500
        500 http://us.archive.ubuntu.com/ubuntu noble/main amd64 Packages
        100 /var/lib/dpkg/status
realmd:
  Installed: 0.17.1-3build2
  Candidate: 0.17.1-3build2
  Version table:
 *** 0.17.1-3build2 500
        500 http://us.archive.ubuntu.com/ubuntu noble/main amd64 Packages
        100 /var/lib/dpkg/status
adcli:
  Installed: 0.9.2-1ubuntu2
  Candidate: 0.9.2-1ubuntu2
  Version table:
 *** 0.9.2-1ubuntu2 500
        500 http://us.archive.ubuntu.com/ubuntu noble/main amd64 Packages
        100 /var/lib/dpkg/status

mhubbard@z420VM-2404:~$ realm discover randc02.pu.pri
pu.pri
  type: kerberos
  realm-name: PU.PRI
  domain-name: pu.pri
  configured: no
  server-software: active-directory
  client-software: sssd
  required-package: sssd-tools
  required-package: sssd
  required-package: libnss-sss
  required-package: libpam-sss
  required-package: adcli
  required-package: samba-common-bin
mhubbard@z420VM-2404:~$ realm join randc02.pu.pri
Password for Administrator:
mhubbard@z420VM-2404:~$ realm discover randc02.pu.pri
pu.pri
  type: kerberos
  realm-name: PU.PRI
  domain-name: pu.pri
  configured: kerberos-member
  server-software: active-directory
  client-software: sssd
  required-package: sssd-tools
  required-package: sssd
  required-package: libnss-sss
  required-package: libpam-sss
  required-package: adcli
  required-package: samba-common-bin
  login-formats: %U@pu.pri
  login-policy: allow-realm-logins

mhubbard@z420VM-2404:~$ sudo ls -l /etc/sssd
total 8
drwxr-xr-x 2 root root 4096 Apr 16 02:55 conf.d
-rw------- 1 root root  414 May 30 15:57 sssd.conf
mhubbard@z420VM-2404:~$ sudo cat /etc/sssd/sssd.conf

[sssd]
domains = pu.pri
config_file_version = 2
services = nss, pam

[domain/pu.pri]
default_shell = /bin/bash
ad_server = randc02.pu.pri
krb5_store_password_if_offline = True
cache_credentials = True
krb5_realm = PU.PRI
realmd_tags = manages-system joined-with-adcli
id_provider = ad
fallback_homedir = /home/%u@%d
ad_domain = pu.pri
use_fully_qualified_names = True
ldap_id_mapping = True
access_provider = ad

mhubbard@z420VM-2404:~$ sudo cat /etc/pam.d/common-session
#
# /etc/pam.d/common-session - session-related modules common to all services
#
# This file is included from other service-specific PAM config files,
# and should contain a list of modules that define tasks to be performed
# at the start and end of interactive sessions.
#
# As of pam 1.0.1-6, this file is managed by pam-auth-update by default.
# To take advantage of this, it is recommended that you configure any
# local modules either before or after the default block, and use
# pam-auth-update to manage selection of other modules.  See
# pam-auth-update(8) for details.

# here are the per-package modules (the "Primary" block)
session	[default=1]			pam_permit.so
# here's the fallback if no module succeeds
session	requisite			pam_deny.so
# prime the stack with a positive return value if there isn't one already;
# this avoids us returning an error just because nothing sets a success code
# since the modules above will each just jump around
session	required			pam_permit.so
# The pam_umask module will set the umask according to the system default in
# /etc/login.defs and user settings, solving the problem of different
# umask settings with different shells, display managers, remote sessions etc.
# See "man pam_umask".
session optional			pam_umask.so
# and here are more per-package modules (the "Additional" block)
session	required	pam_unix.so
session	optional			pam_sss.so
session	optional	pam_systemd.so
# end of pam-auth-update config
mhubbard@z420VM-2404:~$ sudo pam-auth-update --enable mkhomedir
mhubbard@z420VM-2404:~$ sudo cat /etc/pam.d/common-session
#
# /etc/pam.d/common-session - session-related modules common to all services
#
# This file is included from other service-specific PAM config files,
# and should contain a list of modules that define tasks to be performed
# at the start and end of interactive sessions.
#
# As of pam 1.0.1-6, this file is managed by pam-auth-update by default.
# To take advantage of this, it is recommended that you configure any
# local modules either before or after the default block, and use
# pam-auth-update to manage selection of other modules.  See
# pam-auth-update(8) for details.

# here are the per-package modules (the "Primary" block)
session	[default=1]			pam_permit.so
# here's the fallback if no module succeeds
session	requisite			pam_deny.so
# prime the stack with a positive return value if there isn't one already;
# this avoids us returning an error just because nothing sets a success code
# since the modules above will each just jump around
session	required			pam_permit.so
# The pam_umask module will set the umask according to the system default in
# /etc/login.defs and user settings, solving the problem of different
# umask settings with different shells, display managers, remote sessions etc.
# See "man pam_umask".
session optional			pam_umask.so
# and here are more per-package modules (the "Additional" block)
session	required	pam_unix.so
session	optional			pam_sss.so
session	optional	pam_systemd.so
session	optional			pam_mkhomedir.so
# end of pam-auth-update config

mhubbard@z420VM-2404:~$ realm list
pu.pri
  type: kerberos
  realm-name: PU.PRI
  domain-name: pu.pri
  configured: kerberos-member
  server-software: active-directory
  client-software: sssd
  required-package: sssd-tools
  required-package: sssd
  required-package: libnss-sss
  required-package: libpam-sss
  required-package: adcli
  required-package: samba-common-bin
  login-formats: %U@pu.pri
  login-policy: allow-realm-logins

mhubbard@z420VM-2404:~$ sudo sssctl domain-status pu.pri
Online status: Online

Active servers:
AD Global Catalog: not connected
AD Domain Controller: randc02.pu.pri

Discovered AD Global Catalog servers:
- randc02.pu.pri

Discovered AD Domain Controller servers:
- randc02.pu.pri

sudo sssctl user-checks ubuntu@pu.pri
user: ubuntu@pu.pri
action: acct
service: system-auth

SSSD nss user lookup result:
 - user name: ubuntu@pu.pri
 - user id: 1242401603
 - group id: 1242400513
 - gecos: ubuntu
 - home directory: /home/ubuntu@pu.pri
 - shell: /bin/bash

SSSD InfoPipe user lookup result:
 - name: ubuntu@pu.pri
 - uidNumber: 1242401603
 - gidNumber: 1242400513
 - gecos: ubuntu
 - homeDirectory: not set
 - loginShell: not set

testing pam_acct_mgmt

pam_acct_mgmt: Permission denied

PAM Environment:
 - no env -

mhubbard@z420VM-2404:~$ getent group "domain users"@pu.pri
domain users@pu.pri:*:1242400513:ubuntu@pu.pri

mhubbard@z420VM-2404:~$ getent passwd ubuntu@pu.pri
ubuntu@pu.pri:*:1242401603:1242400513:ubuntu:/home/ubuntu@pu.pri:/bin/bash
