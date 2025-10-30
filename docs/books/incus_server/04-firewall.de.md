---
title: "Kapitel 4: Firewall—Setup"
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - Enterprise
  - incus-Sicherheit
---

In diesem Kapitel müssen Sie Root-Benutzer sein oder `sudo` verwenden können, um Root-Rechte
zu erhalten.

Wie bei jedem Server müssen Sie sicherstellen, dass er vor der Außenwelt und in Ihrem LAN geschützt ist. Ihr Beispielserver hat nur eine LAN-Schnittstelle, es ist aber möglich, zwei Schnittstellen zu haben, die jeweils zu Ihren LAN- und WAN-Netzwerken zeigen.

## Firewall Setup – `firewalld`

Für _Firewalld_-Regeln müssen Sie [dieses grundlegende Verfahren](../../guides/security/firewalld.md) verwenden oder mit diesen Konzepten vertraut sein. Die Voraussetzungen sind ein LAN-Netzwerk im IP-Bereich 192.168.1.0/24 und eine Brücke namens `incusbr0`. Um es zu verdeutlichen: Möglicherweise haben Sie auf Ihrem Incus-Server viele Schnittstellen, von denen eine auf Ihr WAN zeigt. You will also create a zone for the bridged and local networks. This is just for zone clarity's sake. The other zone names do not apply. This procedure assumes that you already know the basics of _firewalld_.

```bash
firewall-cmd --new-zone=bridge --permanent
```

Sie müssen die Firewall nach dem Hinzufügen einer Zone neu laden:

```bash
firewall-cmd --reload
```

Sie möchten den gesamten Datenverkehr von der Bridge zulassen. Fügen Sie einfach die Schnittstelle hinzu und ändern Sie das Ziel von `default` auf `ACCEPT`:

!!! warning "Warnhinweis"

```
Das Ändern des Ziels einer `firewalld`-Zone *muss* mit der Option `--permanent` erfolgen, daher können wir dieses Flag auch gleich in unsere anderen Befehle eingeben und auf die Option `--runtime-to-permanent` verzichten.
```

!!! note "Anmerkung"

```
Wenn Sie eine Zone erstellen möchten, in der Sie den Zugriff auf die Schnittstelle oder Quelle zulassen, aber keine Protokolle oder Dienste angeben möchten, *müssen* Sie das Ziel von `default` auf `ACCEPT` ändern. Dasselbe gilt für `REJECT` und `DROP` für einen bestimmten IP-Block, für den Sie benutzerdefinierte Zonen haben. Die `drop`-Zone übernimmt dies für Sie, sofern Sie keine benutzerdefinierte Zone verwenden.
```

```bash
firewall-cmd --zone=bridge --add-interface=incusbr0 --permanent
firewall-cmd --zone=bridge --set-target=ACCEPT --permanent
```

Vorausgesetzt, es sind keine Fehler aufgetreten und alles funktioniert noch, führen Sie einen Neuladen durch:

```bash
firewall-cmd --reload
```

Wenn Sie nun Ihre Regeln mit dem Befehl `firewall-cmd --zone=bridge --list-all` auflisten, sollten Sie Folgendes erhalten:

```bash
bridge (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces: incusbr0
  sources:
  services:
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

Beachten Sie, dass Sie auch Ihre lokale Schnittstelle zulassen müssen. Auch hier sind die enthaltenen Zonen nicht entsprechend benannt. Erstellen Sie eine Zone und verwenden Sie den Quell-IP-Bereich der lokalen Schnittstelle, um den Zugriff sicherzustellen:

```bash
firewall-cmd --new-zone=local --permanent
firewall-cmd --reload
```

Fügen Sie die Quell-IP-Adressen für die lokale Schnittstelle hinzu und ändern Sie das Ziel auf `ACCEPT`:

```bash
firewall-cmd --zone=local --add-source=127.0.0.1/8 --permanent
firewall-cmd --zone=local --set-target=ACCEPT --permanent
firewall-cmd --reload
```

Führen Sie nun den Befehl `firewall-cmd --zone=local --list all` aus, um die Regeln der Zone `local` anzuzeigen und sicherzustellen, dass Ihre Regeln vorhanden sind. Die Ausgabe sieht dann wie folgt aus:

```bash
local (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces:
  sources: 127.0.0.1/8
  services:
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

Sie möchten SSH-Verbindungen aus unserem vertrauenswürdigen Netzwerk zulassen. Dazu muss den Quell-IPs erlaubt werden, die integrierte `trusted`-Zone zu verwenden. Standardmäßig ist das Ziel dieser Zone `ACCEPT`.

```bash
firewall-cmd --zone=trusted --add-source=192.168.1.0/24
```

Fügen Sie den Dienst der Zone hinzu:

```bash
firewall-cmd --zone=trusted --add-service=ssh
```

Wenn alles funktioniert, verschieben Sie Ihre Regeln in den permanenten Zustand und laden Sie die Regeln neu:

```bash
firewall-cmd --runtime-to-permanent
firewall-cmd --reload
```

Wenn Sie Ihre `trusted` Zone auflisten, wird Folgendes angezeigt:

```bash
trusted (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.1.0/24
  services: ssh
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

Die Zone `public` ist standardmäßig aktiviert, und SSH ist zugelassen. Aus Sicherheitsgründen soll SSH in der Zone `public` nicht zugelassen werden. Stellen Sie sicher, dass Ihre Zonen korrekt eingerichtet sind und dass der Zugriff auf den Server über eine der LAN-IP-Adressen erfolgt (in unserem Beispiel). Sie könnten sich vom Server aussperren, wenn Sie dies nicht vorher überprüfen, bevor Sie fortfahren. Wenn Sie sicher sind, dass Sie über die richtige Schnittstelle Zugriff haben, entfernen Sie SSH aus der Zone `public`:

```bash
firewall-cmd --zone=public --remove-service=ssh
```

Testen Sie den Zugriff und stellen Sie sicher, dass Sie nicht ausgesperrt sind. Falls nicht, verschieben Sie Ihre Regeln auf `permanent`, laden Sie die Seite neu und listen Sie die Zone `public` auf, um sicherzustellen, dass SSH entfernt wird:

```bash
firewall-cmd --runtime-to-permanent
firewall-cmd --reload
firewall-cmd --zone=public --list-all
```

Möglicherweise gibt es andere Schnittstellen auf Ihrem Server, die Sie berücksichtigen sollten. Sie können gegebenenfalls die integrierten Zonen verwenden. Sollten Ihnen die Namen nicht aussagekräftig genug erscheinen, können Sie weitere Zonen hinzufügen. Denken Sie daran: Wenn Sie keine Dienste oder Protokolle haben, die Sie explizit zulassen oder ablehnen müssen, müssen Sie das Zonenziel ändern. Das ist möglich, wenn die Nutzung von Schnittstellen, wie bei der Bridge, möglich ist. Wenn Sie einen detaillierteren Zugriff auf Dienste benötigen, verwenden Sie stattdessen Quell-IPs.
