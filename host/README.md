# Host configuration

## Debian

### Create VM
- `ssh-keygen -t ed25519 -f ~/.ssh/myhub`
- Create VM and use public key from `~/.ssh/myhub.pub`
- `ssh-keyscan <ip_address_of_vm> >> ~/.ssh/known_hosts`
- create `~/.ssh/config` and add the following 

```
Host *
    ForwardAgent                 no
    ForwardX11                   no
    ForwardX11Trusted            no
    TCPKeepAlive                 yes
    VerifyHostKeyDNS             yes
    ServerAliveInterval          2
    ServerAliveCountMax          10
    Protocol                     2
    CheckHostIP                  yes
    Compression                  yes
    Ciphers                      aes256-ctr,aes256-gcm@openssh.com,chacha20-poly1305@openssh.com
    MACs                         hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com
    VisualHostKey                yes
    HostbasedAuthentication      no
    HashKnownHosts               yes
    ConnectTimeout               5
    ConnectionAttempts           9999
    StrictHostKeyChecking        yes
    
Host myhub
    User                         toor
    HostName                     <ip_address_of_vm>
    IdentityFile                 ~/.ssh/myhub
    IdentitiesOnly               yes
    LogLevel                     DEBUG
    ControlMaster                auto
    ControlPersist               2h
    ControlPath                  ~/.ssh/ControlMaster-%r-%h.%p
    KbdInteractiveAuthentication no

```

- `ssh myhub`

### Repo 
- `git clone https://github.com/philoctetes409bc/docker-hybrid.git`
- `cd docker-hybrid/host`

### Packages 
- `sudo apt -y install docker.io nftables tcpdump mtr tor git`

### Configuration files
- `cp tor/torrc /etc/tor/torrc`
- `chattr +i /etc/tor/torrc`
- `cp resolv.conf /etc/resolv.conf`
- `chattr +i /etc/resolv.conf`
- `/sbin/setcap CAP_NET_BIND_SERVICE=+eip $(which tor)`
- `systemctl enable tor`
- `systemctl start tor`
- `cp sysctl.conf /etc/`
- `chattr +i /etc/sysctl.conf`
- `/sbin/sysctl -f /etc/sysctl.conf`
- `cp default/docker /etc/default/docker`
- `chattr +i /etc/default/docker`
- `ip link add docker0 type bridge` 
- `ip link set docker0 up`
- `ip addr add 100.64.63.129/25 dev docker0`
- `systemctl enable docker`
- `systemctl start docker`
- create `/etc/systemd/network/50-WAN.link` and add the following

```
[Match]
MACAddress=<replace_this_with_the_MAC_address_of_your_WAN_interface>

[Link]
Description=WAN
MACAddressPolicy=persistent 
Name=WAN

```
#### systemd-networkd address configuration (DHCP)
- If you need to change this, visit https://www.freedesktop.org/software/systemd/man/systemd.network.html for more information

- create `/etc/systemd/network/51-WAN.network` and add the following

```
[Match]
Name=WAN

[Network]
Description=WAN
DHCP=yes
MulticastDNS=false
LinkLocalAddressing=fallback
IPv4LLRoute=true
LLDP=routers-only
IPv6AcceptRA=true
IPForward=true
IPMasquerade=true
LLMNR=false
```

#### systemd-networkd address configuration (static)
- If you need to change this, visit https://www.freedesktop.org/software/systemd/man/systemd.network.html for more information

- create `/etc/systemd/network/51-WAN.network` and add the following

```
[Match]
Name=WAN

[Network]
Description=WAN
DHCP=no
Address=192.168.122.88/24
Gateway=192.168.122.1
MulticastDNS=false
LinkLocalAddressing=fallback
IPv4LLRoute=true
LLDP=routers-only
IPv6AcceptRA=true
IPForward=true
IPMasquerade=true
LLMNR=false
```

- `chattr +i /etc/systemd/network/50-WAN.link`
- `chattr +i /etc/systemd/network/51-WAN.network`
- `systemctl enable systemd-networkd`
- `sync ; sync ; /sbin/reboot -f`
- Re-SSH the host, CWD to `docker-hybrid/host`
- `cp nftables/nftables.rules /etc/nftables.conf`
- `chattr +i /etc/nftables.conf`
