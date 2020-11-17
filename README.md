# Quickstart

## Overview
This collection of docker-compose files provides a collection of IRCd configurations and roles for establishing a reliable IRC network in which hubs are able to
maintain adequate discretion from discovery and DDoS attacks which would have a negative impact on the network overall. It also provides client-access roles which
discriminate against proxy and RBL blacklisted hosts/networks, but also provides a means in which access can be made available to these types of users without access
becoming unmanageable. There are three client access roles:

- General (RBL discrimination, proxy scanning using HOPM, auto-kills, port 6667/6697.) While hopm and proxy scanners only solve 90% of the problem, a lot of it
is relieved by allowing users who wish to use proxies and/or Tor to access the network an alternative means to do so

- Proxy DMZ (port 6668/6698, all users connecting via this leaf are given a masqueraded hostname, but the real IP address is available in the whois info. Thus gives
channel owners and maintainers the ability to shadow ban proxy clients at their own discretion, as well as the ability to make exceptions (with mode +e in
the b/e/I lists)

- Tor DMZ (port 6669/6699, all users connecting via this leaf are connecting to a .onion address, and thus they have to be masqueraded behind the same host mask
in all cases. There is also no IP address for origin clients, but are still all masqueraded by an indistinct hostname thus giving channel maintainers and owners
the same ability to shadow ban tor users. Channel maintainers can use modes such as +r to ensure that only registered users are able to join a channel if they
want to make exceptions to a shadow ban rule, eg: a channel which is +r and has a +e for the registered user: seroquel!*@* )

### Topology
![alt text](https://github.com/philoctetes409bc/docker-hybrid/blob/master/doc/Diagram1.png?raw=true)

### Caveats
Each site uses a Tor container for resolving DNS internally (in order to mitigate top site discovery as well as for various other optional purposes including
client access as well as up-linking to hubs (useful for uplinking a marginally trusted exterior site to the hub using the hb_tor_edge border roles, thus
mitigating a point for which a top-site hub can be discovered)

## Top site
Top sites shouldn't run services, SMTP for service registration, nor should they expose any direct client access. They are exclusively for inter-connecting
multiple sites at their border either by the hb_edge role or by hb_tor_edge

### Host configuration
This is dependent upon specific (minimized, reasonable) host specific configuration In order for this to work correctly. The host-specific instructions
are provided in https://github.com/philoctetes409bc/docker-hybrid/host/README.md

### Build images
```
for x in $(ls -1 | grep hb_); do                                                                                                                                    ─╯
  docker-compose -f $x/docker-compose.yml build;
done
```

### PKI
We need to use TLS for interconnecting the site internally, since the nature of the network that is used could be one that is established within a swarm and
the reliability of the network security between swarm hosts is unknown. The first step requires bootstrapping a certificate and intermediate authority.
- `./bin/initialize_certificate_authority`

Now certificates are created for each role, except for the tor hidden services roles because hidden services are already encrypted end-to-end. This step
also creates a volume for each container containing the certificates that are required for the service to work
- `./bin/generate_ssl_certificates`

### Containers
- `docker-compose -f hb_tor/docker-compose.yml up -d`
- `docker-compose -f hb_hub/docker-compose.yml up -d`

If you only want to allow exterior sites to up-link to the top-site through a Tor hidden service, then you only need to start the hb_tor_edge role
- `docker-compose -f hb_tor_edge/docker-compose.yml up -d`

If you intend to allow exterior sites the ability to up-link through the internet directly, then you may start the hb_edge role
- `docker-compose -f hb_edge/docker-compose.yml up -d`

For the top-site it is also fairly safe to establish Tor hidden service client access fairly safely without risk of exposing the location of the top-site on
the clearnet, but this step is completely optional, and reccomended against assuming you intend to actually establish exterior sites which which the same
can be accomplished without risk to exposing all or part of the top-site
- `docker-compose -f hb_tor_dmz/docker-compose.yml up -d`

## Exterior site
Exterior sites are considered the buffer zone between the client access space and the top-site hubs which link the network together with other exterior sites

### Host configuration
- The instructions are provided in https://github.com/philoctetes409bc/docker-hybrid/host/README.md

### Build images
Follow the same steps as the top-site instructions

### PKI
Follow the same steps as the top-site instructions

### Containers
- `docker-compose -f hb_tor/docker-compose.yml up -d`
- `docker-compose -f hb_mysql/docker-compose.yml up -d`
- `docker-compose -f hb_postfix/docker-compose.yml up -d`
- `docker-compose -f hb_hub/docker-compose.yml up -d`
- `docker-compose -f hb_tor_edge/docker-compose.yml up -d`

Provided that you have started the hb_mysql and hb_postfix roles, you can start anope serivce for nickname and channel registration
- `docker-compose -f hb_services/docker-compose.yml up -d`


# TODO
- finish adding in oper bouncer
- add `100.64.16.0/20` target for Tor DNS
- convert console to `100.64.16.0/20` targets (internally routed) make the console itself use a 100.64.16.0/20 segment as it's default network (update firewall
rules for host configuration to only allow forward from `100.64.16.0/20` to `100.64.16.0/20`
- add higher level topology diagram to illustrate top-site and exterior-site topology better (current illustrates full exterior site stack)
- add credit for lazy links and summarize the history of the idea
- finish adding hopm
- host configuration documentation (fix nftables and test, also iptables script)
- finish certificate generation (copy most of the ca generation script, generate certs for each internal connection. Use ssl volumes script from netwerk to
create certificate volumes for each service.

