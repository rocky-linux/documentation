---
title: i2pd — Anonymous Netzwerk
author: Neel Chauhan
contributors: Steven Spencer
tags:
  - proxy
  - proxies
---

## Einleitung

[I2P](https://geti2p.net/en/) ist ein anonymes Overlay-Netzwerk und ein Konkurrent des bekannteren Tor-Netzwerks mit dem Schwerpunkt auf versteckten Websites, den sogenannten Eepsites. [`i2pd`](https://i2pd.website/) (I2P Daemon) ist eine leichtgewichtige C++-Implementierung des I2P-Protokolls.

## Voraussetzungen

Die Mindestanforderungen für die Anwendung dieses Verfahrens sind folgende:

- Eine öffentliche IPv4- oder IPv6-Adresse, entweder direkt auf dem Server, mit Portweiterleitung oder über UPnP/NAT-PMP

## `i2pd`-Installation

Um `i2pd` aufzusetzen, müssen Sie zunächst die EPEL- (Extra Packages for Enterprise Linux) und die `i2pd`-Copr-Repositories (Cool Other Package Repo) installieren:

```bash
curl -s https://copr.fedorainfracloud.org/coprs/supervillain/i2pd/repo/epel-10/supervillain-i2pd-epel-10.repo -o /etc/yum.repos.d/i2pd-epel-10.repo
dnf install -y epel-release
```

Dann `i2pd` installieren:

```bash
dnf install -y i2pd
```

## Konfiguration von `i2pd` (optional)

Nach der Installation der Pakete können Sie `i2pd` bei Bedarf konfigurieren. Der Autor verwendet dafür `vim`, aber wenn Sie `nano` oder etwas anderes bevorzugen, können Sie das gerne entsprechend anpassen:

```bash
vim /etc/i2pd/i2pd.conf
```

Die Standarddatei `i2pd.conf` ist recht ausführlich, kann aber lang werden. Wenn Sie nur eine Basiskonfiguration wünschen, können Sie sie unverändert lassen.

Wenn Sie jedoch IPv6 und UPnP aktivieren und den HTTP-Proxy-Port auf `12345` setzen möchten, ist folgende Konfiguration erforderlich:

```bash
ipv6 = true
[httpproxy]
port = 12345
[upnp]
enabled = true
```

Wenn Sie andere Optionen festlegen möchten, ist die Konfigurationsdatei hinsichtlich aller möglichen Optionen selbsterklärend.

## `i2pd` Aktivierung

Sie können jetzt `i2pd` aktivieren

```bash
systemctl enable --now i2pd
```

## Besuch von `I2P eepsites`

Dieses Beispiel verwendet Firefox unter Rocky Linux. Wenn Sie nicht Firefox verwenden, lesen Sie die Dokumentation Ihrer Anwendung, um einen HTTP-Proxy einzurichten.

Öffnen Sie Firefox, klicken Sie auf das Hamburger-Menüsymbol und gehen Sie dann zu den **Settings**:

![Firefox menu dropdown](../images/i2p_proxy_ff_1.png)

Scrollen Sie zu den **Network Settings** und drücken Sie anschließend auf **Settings**

![Firefox Network Settings section](../images/i2p_proxy_ff_2.png)

Wählen Sie dann **Manual proxy connection**, geben Sie `localhost` und `4444` (oder den von Ihnen gewählten Port) ein, aktivieren Sie **Also use this proxy for HTTPS** und wählen Sie **OK**.

![Firefox Connection Settings dialog](../images/i2p_proxy_ff_3.png)

Sie können nun I2P-Eepsites durchsuchen. Navigieren Sie beispielsweise zu `http://planet.i2p` (Hinweis: Das `http://` ist wichtig, damit Firefox nicht standardmäßig eine Suchmaschine verwendet):

![Firefox viewing planet.i2p](../images/i2p_proxy_ff_4.png)

## Zusammenfassung

Da so viele Internetnutzer um ihre Online-Privatsphäre besorgt sind, ist I2P eine Möglichkeit, sicher auf versteckte Websites zuzugreifen. `i2pd` ist eine leichtgewichtige Software, die das Surfen auf I2P-Websites ermöglicht und gleichzeitig die Nutzung Ihrer Verbindung als Relay erlaubt.
