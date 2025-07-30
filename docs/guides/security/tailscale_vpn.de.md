---
title: Tailscale VPN
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.3
tags:
  - Sicherheit
  - vpn
---

# Tailscale VPN

## Einleitung

[Tailscale](https://tailscale.com/) ist ein Zero-Config-, End-to-End-verschlüsseltes Peer-to-Peer-VPN basierend auf Wireguard. Tailscale unterstützt alle wichtigen Desktop- und mobilen Betriebssysteme.

Im Vergleich zu anderen VPN-Lösungen benötigt Tailscale keine offenen TCP/IP-Ports und kann hinter Network Address Translation oder einer Firewall arbeiten.

## Voraussetzungen

Für die Verwendung dieses Verfahrens gelten die folgenden Mindestanforderungen:

- Die Möglichkeit, Befehle als Root-Benutzer auszuführen oder `sudo` zu verwenden, um Berechtigungen zu erhöhen
- Ein `Tailscale`-Account

## `Tailscale`-Installation

Um Tailscale zu installieren, müssen wir zuerst das `dnf`-Repository hinzufügen (Hinweis: Wenn Sie Rocky Linux 8.x oder 10.x verwenden, ersetzen Sie es durch 8 bzw. 10):

```bash
dnf config-manager --add-repo https://pkgs.tailscale.com/stable/rhel/9/tailscale.repo
```

Dann `Tailscale` installieren:

```bash
dnf install tailscale
```

## `Tailscale`-Konfiguration

Wenn die Pakete installiert sind, müssen Sie Tailscale aktivieren und konfigurieren. So aktivieren Sie den Tailscale-Daemon:

```bash
systemctl enable --now tailscaled
```

Anschließend authentifizieren Sie sich bei Tailscale:

```bash
tailscale up
```

Sie erhalten eine URL zur Authentifizierung. Besuchen Sie die Seite in einem Browser und melden Sie sich bei Tailscale an:

![Tailscale login screen](../images/tailscale_1.png)

Als nächstes gewähren Sie Zugriff auf Ihren Server. Klicken Sie dazu auf **Connect**:

![Tailscale grant access dialog](../images/tailscale_2.png)

Wenn Sie den Zugriff gewährt haben, wird ein Erfolgsdialogfeld angezeigt:

![Tailscale login successful dialog](../images/tailscale_3.png)

Sobald Ihr Server bei Tailscale authentifiziert ist, erhält er eine Tailscale-IPv4-Adresse:

```bash
tailscale ip -4
```

Es bekommt außerdem eine RFC 4193 (Unique Local Address) Tailscale IPv6-Adresse:

```bash
tailscale ip -6
```

## Zusammenfassung

Herkömmliche VPN-Dienste, die ein VPN-Gateway verwenden, sind zentralisiert. Dies erfordert eine manuelle Konfiguration, das Aufsetzen Ihrer Firewall und die Einrichtung von Benutzerkonten. Tailscale löst dieses Problem durch sein Peer-to-Peer-Modell in Kombination mit Zugriffskontrolle auf Netzwerkebene.
