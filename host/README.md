# Host configuration

## Debian

### Create VM (from local computer/workstation)
- `ssh-keygen -t ed25519 -f ~/.ssh/myhub`
- Create VM (however you need to) and use public key from `~/.ssh/myhub.pub`
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
- `sudo apt -y install docker.io nftables tcpdump mtr tor git python3-pip`
- `pip3 install docker-compose`

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

#### Enable docker service at boot
- `systemctl enable docker`
- `systemctl start docker`

#### Harden SSH daemon
- `cp ssh/sshd_config /etc/sshd_config`
- `chattr +i /etc/ssh/sshd_config`
- `echo "authorized access only" > /etc/issue.net`
- `chattr +i /etc/issue.net`
- `systemctl restart sshd`

### Boot network configuration
- This step ensures that the WAN interface name will match the pre-defined values in the provided nftables scripts
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

### *continued*
- `chattr +i /etc/systemd/network/50-WAN.link`
- `chattr +i /etc/systemd/network/51-WAN.network`
- `systemctl enable systemd-networkd`

#### Top-site nftables
- `cp nftables/nftables.top_site.rules /etc/nftables.conf`

#### Exterior-site nftables 
- `cp nftables/nftables.exterior.rules /etc/nftables.conf`

### *continued*
- `chattr +i /etc/nftables.conf`
- reboot (smoke test)

#### Verification
- Re-SSH the host
- Check that the interfaces are correctly configured

```
# ip addr show dev WAN
2: WAN: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq state UP group default qlen 1000
    link/ether 52:54:00:38:51:aa brd ff:ff:ff:ff:ff:ff
    inet 192.168.122.88/24 brd 192.168.122.255 scope global WAN
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:fe38:51aa/64 scope link 
       valid_lft forever preferred_lft forever
# ip addr show dev docker0
4: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:09:a7:68:60 brd ff:ff:ff:ff:ff:ff
    inet 100.64.63.129/25 brd 100.64.63.255 scope global docker0
       valid_lft forever preferred_lft forever
```

- `/sbin/nft list ruleset`
- `systemctl status tor`
- `systemctl status docker`

### Hardening 
#### SSH
- on the newly installed debian host `grep "." /var/lib/tor/ssh/hostname`
- change your local/workstation `~/.ssh/config` to match the following

```
Host hybrid
    ProxyCommand                 socat - 'SOCKS4A:127.0.0.1:%h:%p,socksport=9050'
    User                         toor
    HostName                     <the .onion address>
    IdentityFile                 ~/.ssh/myhub
    IdentitiesOnly               yes
    LogLevel                     DEBUG
    ControlMaster                auto
    ControlPersist               2h
    ControlPath                  ~/.ssh/ControlMaster-%r-%h.%p
    KbdInteractiveAuthentication no
```

- Verify that you can SSH the host, then in the `/etc/nftables.conf` remove the following line from the INPUT chain
- `chattr -i /etc/nftables.conf`

```
tcp dport 22                   counter accept                   comment "SSH to host";

```

- `chattr +i /etc/nftables.conf`
- `/sbin/nft -f /etc/nftables.conf`
