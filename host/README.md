# Host configuration
## Debian
### packages 
- `nftables docker`
### Configuration files
- `cp sysctl.conf /etc/`
- `rm -rf /etc/nftables/*`
- `cp -rvp nftables/ /etc`
