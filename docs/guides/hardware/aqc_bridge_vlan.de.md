---
title: Aktivieren von VLAN-Passthrough auf NICs der Marvell AQC-Serie
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 9.6
tags:
  - Hardware
---

## Einleitung

Der Autor verwendet in seinem Heimserver eine auf Marvell AQC107 basierende Netzwerkkarte (NIC, Network Interface Card), die über eine virtuelle Maschine verfügt, die für eine virtualisierte Firewall verwendet wird. Leider entfernt der standardmäßige Rocky Linux Marvell AQC-Treiber VLANs auf Bridge-Schnittstellen. Dies ist mit der virtuellen OPNsense-Maschine des Autors passiert. Glücklicherweise lässt sich das Problem beheben.

## Voraussetzungen

Für die Verwendung dieses Verfahrens sind folgende Mindestanforderungen zu beachten:

- Ein Rocky Linux-Server mit einer NIC der Marvell AQC-Serie
- Verwenden von NetworkManager zum Konfigurieren vom Netzwerk

## Deaktivieren der VLAN-Filterung

Sie können die VLAN-Filterung mit einem Befehl deaktivieren:

    nmcli con modify enp1s0 ethtool.feature-rx-vlan-filter off

Ersetzen Sie `enp1s0` durch den Namen Ihrer AQC-basierten Netzwerkkarte.
