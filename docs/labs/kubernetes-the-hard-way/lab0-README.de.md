---
title: Einleitung
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
---

# Kubernetes auf die harte Tour (Rocky Linux)

!!! info

    Dies ist ein Fork des ursprünglichen ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way), das ursprünglich von Kelsey Hightower geschrieben wurde (GitHub: kelseyhightower). Im Gegensatz zum Original, das auf Debian-ähnlichen Distributionen für die ARM64-Architektur basiert, zielt dieser Fork auf Enterprise-Linux-Distributionen wie Rocky Linux ab, das auf der x86_64-Architektur läuft.

Dieses Tutorial führt Sie durch die anspruchsvolle Einrichtung von Kubernetes. Es ist nicht für jemanden geeignet, der nach einem vollständig automatisierten Tool zum Einrichten eines Kubernetes-Clusters sucht. `Kubernetes The Hard Way` ist zum Lernen konzipiert. Sie müssen also den langen Weg gehen, um sicherzustellen, dass Sie jede Aufgabe verstehen, die zum Bootstrapping eines Kubernetes-Clusters erforderlich ist.

Betrachten Sie die Ergebnisse dieses Tutorials nicht als produktionsreif und es wird möglicherweise keine Unterstützung von der Community geben, aber lassen Sie sich dadurch nicht vom Lernen abhalten!<small>
<br/><br/>
🌐 Übersetzungen: 
<a href="https://crowdin.com/project/rockydocs/de">crowdin.com/project/rockydocs</a>
<br/>
🌍 Übersetzer:
<a href="https://crowdin.com/project/rockydocs/activity-stream">rockydocs/activity-stream</a>
, <a href="https://crowdin.com/project/rockylinuxorg/activity-stream">rockylinux.org</a>
<br/>
🖋 Mitmachen:
<a href="https://github.com/rocky-linux/documentation?tab=readme-ov-file#mattermost">github.com/rocky-linux</a>
</small>

## Copyright

![Creative Commons License](images/cc_by_sa.png)

Die Lizenzierung dieses Werks erfolgt unter einer [Creative Commons Attribution-NonCommercial-=ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-nc-sa/4.0/).

## Zielgruppe

Die Zielgruppe dieses Tutorials sind alle, die die Grundlagen von Kubernetes und die Zusammenarbeit der Kernkomponenten verstehen möchten.

## Cluster-Details

`Kubernetes The Hard Way` führt Sie durch das Bootstrapping eines einfachen Kubernetes-Clusters, bei dem alle Control-Plane-Komponenten auf einem einzelnen Knoten und zwei Worker-Knoten ausgeführt werden. Dies reicht aus, um die Kernkonzepte zu erlernen.

Komponenten-Versionen:

- [kubernetes](https://github.com/kubernetes/kubernetes) v1.32.x
- [containerd](https://github.com/containerd/containerd) v2.0.x
- [cni](https://github.com/containernetworking/cni) v1.6.x
- [etcd](https://github.com/etcd-io/etcd) v3.4.x

## Labs

Für dieses Tutorial sind vier (4) x86_64-basierte virtuelle oder physische Maschinen erforderlich, die mit demselben Netzwerk verbunden sind. Während im Tutorial x86_64-basierte Maschinen verwendet werden, können Sie die gewonnenen Erkenntnisse auf andere Plattformen anwenden.

- [Voraussetzungen](lab1-prerequisites.md)
- [Setup der Jumpbox](lab2-jumpbox.md)
- [Provisionierung der Rechner Ressourcen](lab3-compute-resources.md)
- [Provisionierung der CA und Generierung von TLS-Zertifikate](lab4-certificate-authority.md)
- [Generierung der Kubernetes Konfigurationsdateien für die Authentifizierung](lab5-kubernetes-configuration-files.md)
- [Generierung der Data Encryption Konfiguration und Schlüssel](lab6-data-encryption-keys.md)
- [Bootstrapping vom `etcd`-Cluster](lab7-bootstrapping-etcd.md)
- [Bootstrapping der Kubernetes Kontrollebene](lab8-bootstrapping-kubernetes-controllers.md)
- [Bootstrapping der Kubernetes Worker-Knoten](lab9-bootstrapping-kubernetes-workers.md)
- [Konfiguration von `kubectl` für Remote-Zugriff](lab10-configuring-kubectl.md)
- [Bereitstellung von Pod-Netzwerkrouten](lab11-pod-network-routes.md)
- [Smoke-Test](lab12-smoke-test.md)
- [Cleaning Up](lab13-cleanup.md)
