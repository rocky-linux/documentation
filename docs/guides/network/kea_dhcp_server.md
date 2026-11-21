---
title: Kea DHCP server for IPv4 and IPv6
author: Saulo Brito
contributors:
tested_with: 10.3
tags:
  - dhcp
  - kea
  - IPv6
  - networking
---

## Introduction

Kea is the DHCP server for Rocky Linux 10, where it replaces the retired ISC DHCP server. On the client side, NetworkManager handles DHCP through its internal client. See the [Rocky Linux 10 release notes](../../releases/release_notes/10_0.md).

Follow this guide to serve IPv4 and IPv6 clients on a single LAN. After verifying that a client can obtain both leases, you can reserve addresses, delegate an IPv6 prefix to a downstream router, and query leases through the local Control Agent.

## Prerequisites and assumptions

- A Rocky Linux 10 server with Kea 3.x available from AppStream, root access, and an Ethernet interface connected to the LAN it will serve
- A Rocky Linux client on the same LAN and familiarity with [NetworkManager's command-line tool](../../gemstones/network/nmcli.md)
- `firewalld` running on the server
- A known gateway and DNS resolver for each protocol if clients need access to other networks or name resolution

Run the commands as root on the server unless the guide directs you to the client.

!!! note "Example network"

    The server uses `enp2s0` with `192.168.50.1/24` and `2001:db8:50::1/64`. The client uses `enp1s0`. Substitute your own interfaces and addresses. The IPv6 example uses the prefix reserved for documentation. See [RFC 3849](https://datatracker.ietf.org/doc/html/rfc3849).

    The DHCP options use the server's addresses as examples. Set the DNS options to a resolver clients can reach and the IPv4 `routers` option to the actual gateway. Configure the gateway and DNS services separately if the Kea host provides them.

## How DHCPv4 and DHCPv6 differ

DHCPv4 can give each client an address, a subnet mask, a default gateway, and DNS settings. A client identifies itself with a client identifier or its hardware address.

DHCPv6 can assign an individual address and deliver options such as DNS resolvers and a search domain. It identifies clients by DHCP Unique Identifier (DUID). IPv6 clients learn the default gateway and which prefixes are on-link from ICMPv6 Router Advertisements (RAs). These flags control how the client configures IPv6.

| Flag | Where it appears | Meaning |
| --- | --- | --- |
| M | RA header | Managed address configuration is available through DHCPv6 |
| O | RA header | Other settings, such as DNS, are available through DHCPv6 |
| A | Prefix information | Clients can create an address from this prefix using Stateless Address Autoconfiguration (SLAAC) |
| L | Prefix information | Clients can treat this prefix as on-link |

This guide uses stateful DHCPv6 for addresses. The router sets M and O, sets L for the LAN prefix, and clears A for that prefix. The client keeps its link-local address and obtains its global address from Kea. A positive router lifetime tells the client to use the advertising router as a default gateway. See [RFC 4861](https://datatracker.ietf.org/doc/html/rfc4861).

A LAN that uses SLAAC for addressing can set A and clear M. Setting O in that case lets clients obtain other settings through DHCPv6.

## Installing Kea

Install Kea from AppStream.

```bash
dnf install kea
```

| Service | Role |
| --- | --- |
| `kea-dhcp4` | Assigns IPv4 leases and sends DHCPv4 options |
| `kea-dhcp6` | Assigns IPv6 leases and sends DHCPv6 options |
| `kea-ctrl-agent` | Accepts HTTP management requests |
| `kea-dhcp-ddns` | Sends dynamic DNS updates |

The package keeps its JSON configuration under `/etc/kea/`. Save the packaged DHCP configurations for reference before editing them.

```bash
cp /etc/kea/kea-dhcp4.conf /etc/kea/kea-dhcp4.conf.orig
cp /etc/kea/kea-dhcp6.conf /etc/kea/kea-dhcp6.conf.orig
```

## Configuring the server interface

Assign a static address for each protocol on the interface facing the LAN. If the interface already has a NetworkManager profile, update that profile with the appropriate settings. To create a profile for the example LAN, use the following commands.

```bash
nmcli connection add type ethernet con-name dhcp-lan ifname enp2s0 \
  ipv4.method manual ipv4.addresses 192.168.50.1/24 \
  ipv6.method manual ipv6.addresses 2001:db8:50::1/64
nmcli connection up dhcp-lan
ip -br address show dev enp2s0
```

## Configuring DHCPv4

Save the following configuration in `/etc/kea/kea-dhcp4.conf`.

```json
{
  "Dhcp4": {
    "interfaces-config": {
      "interfaces": [ "enp2s0" ],
      "service-sockets-max-retries": 10,
      "service-sockets-retry-wait-time": 5000
    },
    "control-socket": {
      "socket-type": "unix",
      "socket-name": "kea4-ctrl-socket"
    },
    "lease-database": {
      "type": "memfile",
      "persist": true,
      "name": "/var/lib/kea/kea-leases4.csv",
      "lfc-interval": 3600
    },
    "valid-lifetime": 3600,
    "renew-timer": 900,
    "rebind-timer": 1800,
    "option-data": [
      { "name": "domain-name-servers", "data": "192.168.50.1" },
      { "name": "domain-name", "data": "example.internal" }
    ],
    "subnet4": [
      {
        "id": 1,
        "subnet": "192.168.50.0/24",
        "pools": [ { "pool": "192.168.50.100 - 192.168.50.200" } ],
        "option-data": [ { "name": "routers", "data": "192.168.50.1" } ]
      }
    ],
    "loggers": [
      {
        "name": "kea-dhcp4",
        "output-options": [ { "output": "stdout" } ],
        "severity": "INFO"
      }
    ]
  }
}
```

Kea listens on `enp2s0` and leases addresses from `192.168.50.100` through `192.168.50.200`. The subnet's `routers` option supplies the IPv4 gateway. The top-level `option-data` supplies the DNS resolver and domain name.

The lease lasts 3,600 seconds. The client starts trying to renew with its original server after 900 seconds and can try rebinding to any server after 1,800 seconds. The `memfile` backend persists leases to a CSV file in `/var/lib/kea/` and runs lease file cleanup every 3,600 seconds.

The `service-sockets-*` settings let Kea retry certain socket-opening failures. The Unix socket under `/run/kea/` carries management commands. Kea logs to standard output so systemd can collect the messages in the journal.

Give every subnet in each Kea 3.x configuration a unique `id`. Keep those IDs stable once the server starts issuing leases.

Check the file before starting the service.

```bash
kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
```

## Configuring Router Advertisements

If the LAN already has a router that sends RAs, configure it to advertise the flags and prefix described above. Otherwise, install `radvd` on the Kea host.

```bash
dnf install radvd
```

For an isolated LAN where clients only need to reach hosts on the same link, use the following `/etc/radvd.conf`. The zero router lifetime advertises the LAN prefix without installing a default route through the Kea host.

```text
interface enp2s0
{
    AdvSendAdvert on;
    AdvManagedFlag on;
    AdvOtherConfigFlag on;
    AdvDefaultLifetime 0;
    prefix 2001:db8:50::/64
    {
        AdvOnLink on;
        AdvAutonomous off;
    };
};
```

If the Kea host is also the IPv6 gateway, enable IPv6 forwarding, configure its upstream routing, and remove `AdvDefaultLifetime 0;` so `radvd` uses its positive default lifetime. See the [radvd.conf manual](https://github.com/radvd-project/radvd/blob/master/radvd.conf.5.man).

Check the configuration and start the service.

```bash
radvd -c -C /etc/radvd.conf
systemctl enable --now radvd
```

## Configuring DHCPv6

Save the following configuration in `/etc/kea/kea-dhcp6.conf`.

```json
{
  "Dhcp6": {
    "interfaces-config": {
      "interfaces": [ "enp2s0" ],
      "service-sockets-max-retries": 10,
      "service-sockets-retry-wait-time": 5000
    },
    "control-socket": {
      "socket-type": "unix",
      "socket-name": "kea6-ctrl-socket"
    },
    "lease-database": {
      "type": "memfile",
      "persist": true,
      "name": "/var/lib/kea/kea-leases6.csv",
      "lfc-interval": 3600
    },
    "preferred-lifetime": 3000,
    "valid-lifetime": 4000,
    "renew-timer": 1000,
    "rebind-timer": 2000,
    "option-data": [
      { "name": "dns-servers", "data": "2001:db8:50::1" },
      { "name": "domain-search", "data": "example.internal" }
    ],
    "subnet6": [
      {
        "id": 1,
        "subnet": "2001:db8:50::/64",
        "interface": "enp2s0",
        "pools": [ { "pool": "2001:db8:50::100 - 2001:db8:50::1ff" } ]
      }
    ],
    "loggers": [
      {
        "name": "kea-dhcp6",
        "output-options": [ { "output": "stdout" } ],
        "severity": "INFO"
      }
    ]
  }
}
```

The `interface` field in `subnet6` associates requests from clients directly attached to `enp2s0` with this subnet. Kea leases addresses from `2001:db8:50::100` through `2001:db8:50::1ff` and supplies the DNS resolver and search domain.

An address is preferred for 3,000 seconds and stays valid for 4,000 seconds. After the preferred lifetime expires, the client should avoid using that address for new connections. Once the valid lifetime expires, the client must stop using the address.

Check the file before starting the service.

```bash
kea-dhcp6 -t /etc/kea/kea-dhcp6.conf
```

## Opening the firewall

Find the active firewall zone for the LAN interface. In the commands below, replace `public` with that zone if it differs. If the interface has no explicit assignment, check the default zone with `firewall-cmd --get-default-zone`. These rules apply to the whole zone, including any other interfaces assigned to it.

```bash
firewall-cmd --get-active-zones
firewall-cmd --permanent --zone=public --add-service=dhcp --add-service=dhcpv6
firewall-cmd --reload
firewall-cmd --zone=public --list-services
```

The `dhcp` service opens UDP port 67 and `dhcpv6` opens UDP port 547. The similarly named `dhcpv6-client` service opens port 546 for clients. For directly connected IPv4 clients, Kea's default raw socket can receive requests even when the firewall lacks a DHCP rule. DHCPv6 requests reach Kea through UDP port 547. See the [Kea DHCPv4 server reference](https://kea.readthedocs.io/en/kea-3.0.3/arm/dhcp4-srv.html).

## Starting the services

Start both DHCP servers and enable them at boot.

```bash
systemctl enable --now kea-dhcp4 kea-dhcp6
systemctl status kea-dhcp4 kea-dhcp6
```

Check the journal for socket errors and inspect the sockets. A process can show as active even if it could not open a socket on the LAN.

```bash
journalctl -b -u kea-dhcp4 -u kea-dhcp6
ss -0ap | grep kea-dhcp4
ss -lunp 'sport = :547'
```

For DHCPv4, look for Kea's packet socket on the LAN interface. For DHCPv6, look for Kea's UDP sockets on the interface's link-local address and the `ff02::1:2` multicast group.

## Testing from a client

On the Rocky Linux client, use automatic IPv4 and IPv6 configuration. The following commands create a new NetworkManager profile.

```bash
nmcli connection add type ethernet con-name lab-client ifname enp1s0 \
  ipv4.method auto ipv6.method auto
nmcli connection up lab-client
```

Check the addresses, routes, and DNS settings.

```bash
ip -br address show dev enp1s0
ip -4 route show dev enp1s0
ip -6 route show dev enp1s0
nmcli -f IP4.ADDRESS,IP4.DNS,IP6.ADDRESS,IP6.DNS device show enp1s0
```

Expect an IPv4 address from the `/24` pool and a DHCPv6 address displayed as `/128`, alongside a link-local IPv6 address. The on-link route for `2001:db8:50::/64` should show `proto ra`. If a router advertises a positive lifetime, the IPv6 routing table should also show a default route through that router's link-local address.

On the server, confirm the assignments in the lease files or look for `LEASE_ALLOC` and `LEASE_RENEW` in the journal.

```bash
cat /var/lib/kea/kea-leases4.csv
cat /var/lib/kea/kea-leases6.csv
journalctl -b -u kea-dhcp4 -u kea-dhcp6 | grep -E 'LEASE_(ALLOC|RENEW)'
```

## Reserving addresses

Add a `reservations` field inside the relevant subnet object to give a device a predictable address. Pick an address within the subnet and outside its dynamic pool.

For IPv4, add this field to the object inside `subnet4` and substitute the client's MAC address.

```json
"reservations": [
  {
    "hw-address": "02:00:00:00:50:10",
    "ip-address": "192.168.50.10",
    "hostname": "client1"
  }
]
```

For IPv6, add this field to the object inside `subnet6`. Copy the client's actual DUID from the lease file or from a DHCPv6 lease message. A DUID can include fields beyond the MAC address.

```json
"reservations": [
  {
    "duid": "00:03:00:01:02:00:00:00:50:10",
    "ip-addresses": [ "2001:db8:50::10" ],
    "hostname": "client1"
  }
]
```

```bash
journalctl -b -u kea-dhcp6 | grep -E 'DHCP6_LEASE_(ALLOC|RENEW)'
```

Check the files and restart each service whose configuration changed. Reconnect the test client and verify that it receives the reserved addresses.

```bash
kea-dhcp4 -t /etc/kea/kea-dhcp4.conf && systemctl restart kea-dhcp4
kea-dhcp6 -t /etc/kea/kea-dhcp6.conf && systemctl restart kea-dhcp6
```

## Delegating IPv6 prefixes

Prefix delegation (IA_PD) gives a downstream router a block of IPv6 addresses to distribute across its own networks. Configure that router to request a delegated prefix. Add this `pd-pools` field inside the existing `subnet6` object to allocate `/56`s from `2001:db8:5100::/48`.

```json
"pd-pools": [
  {
    "prefix": "2001:db8:5100::",
    "prefix-len": 48,
    "delegated-len": 56
  }
]
```

Check the configuration and restart `kea-dhcp6` as shown in [Reserving addresses](#reserving-addresses). When the downstream router receives a prefix, it can assign a `/64` from that block to each of its LANs.

Kea records the delegation as a lease. Configure the router responsible for forwarding traffic to the delegated network with a route through the requesting router. For example, if the client has the reserved address `2001:db8:50::10` and receives `2001:db8:5100::/56`, add the following route on a Linux gateway connected to that client through `enp2s0`.

```bash
ip -6 route add 2001:db8:5100::/56 via 2001:db8:50::10 dev enp2s0
```

To keep the route across reboots, store it in the gateway's NetworkManager profile using `ipv6.routes`. Check that upstream routers also have a path back to the delegated block.

## Managing Kea with the Control Agent

The packaged Control Agent accepts HTTP requests and forwards commands through the DHCP servers' Unix sockets. Its configuration is in `/etc/kea/kea-ctrl-agent.conf`. For this example, keep the listener on `127.0.0.1:8000` and confirm that its `dhcp4` and `dhcp6` socket names match those in the server configurations.

The example uses the packaged HTTP Basic authentication account `kea-api`. Its generated password is in `/etc/kea/kea-api-password`. Kea 3.x also supports connecting directly to the DHCP servers over HTTP or HTTPS and deprecates the Control Agent. See the [Kea Control Agent documentation](https://kea.readthedocs.io/en/kea-3.0.3/arm/agent.html).

Install the library that provides the lease commands.

```bash
dnf install kea-hooks
```

Add the following field within both the `Dhcp4` and `Dhcp6` objects. If a `hooks-libraries` array already exists, append the library to it.

```json
"hooks-libraries": [
  { "library": "/usr/lib64/kea/hooks/libdhcp_lease_cmds.so" }
]
```

Check both configurations with `-T`, which also loads and tests the hook libraries. Then restart the DHCP services and start the Control Agent.

```bash
kea-dhcp4 -T /etc/kea/kea-dhcp4.conf && systemctl restart kea-dhcp4
kea-dhcp6 -T /etc/kea/kea-dhcp6.conf && systemctl restart kea-dhcp6
systemctl enable --now kea-ctrl-agent
```

Query the lease for an IPv4 address that the server has assigned. The example uses the reserved address from the earlier section.

```bash
curl -sS --user kea-api \
  -H 'Content-Type: application/json' \
  -d '{"command":"lease4-get","service":["dhcp4"],"arguments":{"ip-address":"192.168.50.10"}}' \
  http://127.0.0.1:8000/
```

Enter the password from `/etc/kea/kea-api-password` at the prompt. The next command lists IPv6 leases, including delegated prefixes.

```bash
curl -sS --user kea-api \
  -H 'Content-Type: application/json' \
  -d '{"command":"lease6-get-all","service":["dhcp6"]}' \
  http://127.0.0.1:8000/
```

If the response is HTTP 401, check the configured credentials. For a JSON response, inspect the `result` and `text` fields to see whether the command succeeded.

## SELinux

Keep SELinux in enforcing mode. On the Rocky Linux 10.3 test system, Kea ran in `unconfined_service_t` and `radvd` ran in `radvd_t`. Use the following command to check the process labels on your server.

```bash
ps -eZ | grep -E 'kea|radvd'
```

## Troubleshooting

Watch the journal and capture traffic on the LAN while reconnecting the client. Run each command in its own terminal. The last command displays Router Advertisements and their flags.

```bash
journalctl -f -u kea-dhcp4 -u kea-dhcp6
tcpdump -ni enp2s0 'udp port 67 or udp port 68 or udp port 546 or udp port 547'
tcpdump -ni enp2s0 -vv 'icmp6 and ip6[40] == 134'
```

### Kea reports that the interface does not exist

Compare the names in `interfaces-config` and `subnet6` with `ip link show`. Correct the names, rerun the configuration check, and start the affected service.

### Kea is active but reports socket errors

Messages such as `DHCPSRV_OPEN_SOCKET_FAIL` or `DHCPSRV_NO_SOCKETS_OPEN` can mean that Kea started before the interface was ready. For IPv6, run `ip -6 address show dev enp2s0 scope link` and check that the link-local address exists and is no longer marked `tentative`. Once it is ready, restart `kea-dhcp6` and check the sockets again.

If the issue recurs at boot, check whether `NetworkManager-wait-online` is enabled with `systemctl is-enabled NetworkManager-wait-online` and whether the LAN profile autoconnects.

### DHCPv6 requests arrive but Kea logs nothing

If you capture a client Solicit and Kea is listening on the right interface, check that the interface's firewall zone allows UDP port 547. See [Opening the firewall](#opening-the-firewall).

### The client never sends a DHCPv6 request

Check for RAs with the M flag set and verify that the client profile uses `ipv6.method auto`.

### The client has an IPv6 address but cannot reach other networks

Check the IPv6 default route on the client. Confirm that the LAN's gateway advertises a positive router lifetime and can forward traffic upstream. The isolated LAN example intentionally advertises a lifetime of zero.

### The client does not receive its reserved IPv6 address

Compare the reservation's DUID with the one Kea records for that client. A DUID based on the link-layer address and a timestamp differs from one based on the link-layer address alone. Use the complete value from the lease file or journal.

### The delegated prefix is unreachable

Compare the prefix in the lease with the route on the gateway and verify that the route's next hop reaches the requesting router. See [Delegating IPv6 prefixes](#delegating-ipv6-prefixes).

## Further reading

The [Kea Administrator Reference Manual](https://kea.readthedocs.io/en/kea-3.0.3/) covers dynamic DNS updates, high availability, and database backends. For an example of a local DNS service on Rocky Linux, see [Private DNS server using BIND](../dns/private_dns_server_using_bind.md).
