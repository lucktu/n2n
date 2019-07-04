##在斐讯N1上编译，系统为Armbian即debian linux内核5.0.0，架构ARM64即aarch64
Starting n2n edge 2.5.0 Jun 15 2019 13:50:04

Welcome to n2n v.2.5.0 for Debian 9.9

Built on Jun 15 2019 13:49:56
Copyright 2007-18 - ntop.org and contributors

edge <config file> (see edge.conf)
or
edge -d <tun device> -a [static:|dhcp:]<tun IP address> -c <community> [-k <encrypt key>]
    [-s <netmask>] [-u <uid> -g <gid>][-f][-m <MAC address>] -l <supernode host:port>
    [-p <local port>] [-M <mtu>] [-r] [-E] [-v] [-i <reg_interval>] [-t <mgmt port>] [-b] [-A] [-h]

-d <tun device>          | tun device name
-a <mode:address>        | Set interface address. For DHCP use '-r -a dhcp:0.0.0.0'
-c <community>           | n2n community name the edge belongs to.
-k <encrypt key>         | Encryption key (ASCII) - also N2N_KEY=<encrypt key>.
-s <netmask>             | Edge interface netmask in dotted decimal notation (255.255.255.0).
-l <supernode host:port> | Supernode IP:port
-i <reg_interval>        | Registration interval, for NAT hole punching (default 20 seconds)
-b                       | Periodically resolve supernode IP
                         | (when supernodes are running on dynamic IPs)
-p <local port>          | Fixed local UDP port.
-u <UID>                 | User ID (numeric) to use when privileges are dropped.
-g <GID>                 | Group ID (numeric) to use when privileges are dropped.
-f                       | Do not fork and run as a daemon; rather run in foreground.
-m <MAC address>         | Fix MAC address for the TAP interface (otherwise it may be random)
                         | eg. -m 01:02:03:04:05:06
-M <mtu>                 | Specify n2n MTU of edge interface (default 1400).
-r                       | Enable packet forwarding through n2n community.
-A                       | Use AES CBC for encryption (default=use twofish).
-E                       | Accept multicast MAC addresses (default=drop).
-v                       | Make more verbose. Repeat as required.
-t <port>                | Management UDP Port (for multiple edges on a machine).

Environment variables:
  N2N_KEY                | Encryption key (ASCII). Not with -k.

