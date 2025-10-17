---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - Laborübung
  - runc
  - containerd
  - etcd
  - kubectl
---

# Übung 11: Bereitstellung von Pod-Netzwerkrouten

!!! info

    Dies ist ein Fork des ursprünglichen ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way), das ursprünglich von Kelsey Hightower geschrieben wurde (GitHub: kelseyhightower). Im Gegensatz zum Original, das auf Debian-ähnlichen Distributionen für die ARM64-Architektur basiert, zielt dieser Fork auf Enterprise-Linux-Distributionen wie Rocky Linux ab, das auf der x86_64-Architektur läuft.

Für einen Knoten geplante Pods erhalten eine IP-Adresse aus dem Pod-CIDR-Bereich des Knotens. Derzeit können Pods aufgrund fehlender [Netzwerkrouten] (https://cloud.google.com/compute/docs/vpc/routes) nicht mit anderen Pods kommunizieren, die auf anderen Knoten ausgeführt werden.

In diesem Labor erstellen Sie für jeden Worker-Knoten eine Route, die den Pod-CIDR-Bereich des Knotens der internen IP-Adresse des Knotens zuordnet.

> Es gibt auch [andere Möglichkeiten](https://kubernetes.io/docs/concepts/cluster-administration/networking/#how-to-achieve-this), das Kubernetes-Netzwerkmodell zu implementieren.

## Routing-Tabelle

In diesem Abschnitt sammeln Sie die erforderlichen Informationen zum Erstellen von Routen im VPC-Netzwerk `kubernetes-the-hard-way`.

Drucken Sie die interne IP-Adresse und den Pod-CIDR-Bereich für jede Worker-Instanz:

```bash
{
  SERVER_IP=$(grep server machines.txt | cut -d " " -f 1)
  NODE_0_IP=$(grep node-0 machines.txt | cut -d " " -f 1)
  NODE_0_SUBNET=$(grep node-0 machines.txt | cut -d " " -f 5)
  NODE_1_IP=$(grep node-1 machines.txt | cut -d " " -f 1)
  NODE_1_SUBNET=$(grep node-1 machines.txt | cut -d " " -f 5)
}
```

```bash
ssh root@server <<EOF
  ip route add ${NODE_0_SUBNET} via ${NODE_0_IP}
  ip route add ${NODE_1_SUBNET} via ${NODE_1_IP}
EOF
```

```bash
ssh root@node-0 <<EOF
  ip route add ${NODE_1_SUBNET} via ${NODE_1_IP}
EOF
```

```bash
ssh root@node-1 <<EOF
  ip route add ${NODE_0_SUBNET} via ${NODE_0_IP}
EOF
```

## Verifizierung

```bash
ssh root@server ip route
```

```text
default via XXX.XXX.XXX.XXX dev ens160 
10.200.0.0/24 via XXX.XXX.XXX.XXX dev ens160 
10.200.1.0/24 via XXX.XXX.XXX.XXX dev ens160 
XXX.XXX.XXX.0/24 dev ens160 proto kernel scope link src XXX.XXX.XXX.XXX 
```

```bash
ssh root@node-0 ip route
```

```text
default via XXX.XXX.XXX.XXX dev ens160 
10.200.1.0/24 via XXX.XXX.XXX.XXX dev ens160 
XXX.XXX.XXX.0/24 dev ens160 proto kernel scope link src XXX.XXX.XXX.XXX 
```

```bash
ssh root@node-1 ip route
```

```text
default via XXX.XXX.XXX.XXX dev ens160 
10.200.0.0/24 via XXX.XXX.XXX.XXX dev ens160 
XXX.XXX.XXX.0/24 dev ens160 proto kernel scope link src XXX.XXX.XXX.XXX 
```

Next: [Smoke Test](lab12-smoke-test.md)
