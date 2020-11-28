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
- `sysctl -f /etc/sysctl.conf`
- `cp default/docker /etc/default/docker`
- `chattr +i /etc/default/docker`
- `ip link add docker0 type bridge` 
- `ip link set docker0 up`
- `ip addr add 100.64.63.129/25 dev docker0`
- `systemctl enable docker`
- `systemctl start docker`
- `rm -rf /etc/nftables/*`
- `cp -rvp nftables/ /etc`
