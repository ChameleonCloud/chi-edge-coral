# This repo shows how to build needed kernel modules to run K3S + Calico on a google coral dev board on balena.


## Requirements

### K3s

https://docs.k3s.io/installation/requirements

To verify requirements, run `k3s check-config`

IP tables match based on mark and comment:
* `CONFIG_NETFILTER_XT_MARK`
* `CONFIG_NETFILTER_XT_MATCH_COMMENT`

### Calico additional requirements

https://docs.tigera.io/calico/latest/getting-started/kubernetes/requirements

* Linux kernel 3.10 or later
* IPtables match criterea including:
  * addrtype: `CONFIG_NETFILTER_XT_MATCH_ADDRTYPE`
  * comment
  * conntrack: `CONFIG_NETFILTER_XT_MATCH_CONNTRACK`
  * icmp
  * icmpv6
  * ipvs: `CONFIG_NETFILTER_XT_MATCH_IPVS`
  * mark: `CONFIG_NETFILTER_XT_MATCH_MARK`
  * multiport: `CONFIG_NETFILTER_XT_MATCH_MULTIPORT`
  * rpfilter
  * sctp
  * set
  * tcp
  * udp
* netfilter conntrack support: `CONFIG_NF_CT_NETLINK`
* IPIP kernel module and dependencies: `CONFIG_NET_IPIP`
  * Tunnel4 module: `tunnel4.ko`
  * ip_tunnel module: `ip_tunnel.ko`


### Wireguard requriements

## Per-Platform workarounds
