---
title: Active Directory-Authentifizierung
author: Hayden Young
contributors: Steven Spencer, Sambhav Saggi, Antoine Le Morvan, Krista Burdine, Ganna Zhyrnova, Neel Chauhan
tested_with: 9.4
---

## Voraussetzungen

- Grundverständnis von Active Directory
- Grundverständnis von LDAP

## Einleitung

Microsofts Active Directory (AD) ist in den meisten Unternehmen das de facto Authentifizierungssystem für Windows-Systeme und für externe LDAP-angeschlossene Dienste. Es erlaubt Ihnen, Benutzer und Gruppen zu konfigurieren, sowie Zugriffskontrolle, Berechtigungen, Auto-Mount und mehr.

Während Linux mit einem AD-Cluster verbunden wird, können _nicht alle_ der genannten Funktionen unterstützt werden, es kann jedoch Benutzer, Gruppen und Zugriffskontrolle verwalten. Es ist sogar möglich SSH-Schlüssel unter Verwendung von AD zu verteilen (durch einige Konfigurationseinstellungen auf der Linux-Seite und durch einige fortgeschrittene Optionen auf der AD-Seite).

Diese Anleitung deckt jedoch nur die Konfiguration der Authentifizierung gegen Active Directory ab und enthält keine zusätzliche Konfiguration auf der Windowsseite.

## AD mit Hilfe von SSSD finden und verbinden

!!! note "Hinweis"

    In dieser Anleitung wird der Domainname `ad.company.local` verwendet, um
    die Active Directory Domain zu simulieren. Um dieser Anleitung zu folgen, ersetzen Sie sie durch den aktuellen Domain-Namen, den Ihre AD-Domain verwendet.

Der erste Schritt auf dem Weg zu einem Linux-System in AD ist es, den AD-Cluster zu finden, um sicherzustellen, dass die Netzwerkkonfiguration auf beiden Seiten korrekt ist.

### Zubereitung

- Stellen Sie sicher, dass die folgenden Ports für Ihren Linux-Host auf Ihrem Domain Controller offen sind:

  | Dienst   | Port(s)           | Beschreibung                                                                    |
  | -------- | ----------------- | ------------------------------------------------------------------------------- |
  | DNS      | 53 (TCP+UDP)      |                                                                                 |
  | Kerberos | 88, 464 (TCP+UDP) | Verwendet von `kadmin` für die Einstellung & die Aktualisierung von Passwörtern |
  | LDAP     | 389 (TCP+UDP)     |                                                                                 |
  | LDAP-GC  | 3268 (TCP)        | LDAP Global Catalog - ermöglicht die Quell-Benutzer-IDs von AD zu übernehmen    |

- Stellen Sie sicher, dass Sie Ihren AD Domänencontroller als DNS-Server auf Ihrem Rocky Linux Host konfiguriert haben:

  **Mit dem NetworkManager:**

  ```sh
  # where your primary NetworkManager connection is 'System eth0' and your AD
  # server is accessible on the IP address 10.0.0.2.
  [root@host ~]$ nmcli con mod 'System eth0' ipv4.dns 10.0.0.2
  ```

- Stellen Sie sicher, dass die Zeit auf beiden Seiten (AD Host und Linux System) synchronisiert ist (siehe chronyd)

  **Um die Zeit auf Rocky Linux zu überprüfen:**

  ```sh
  [user@host ~]$ date
  Wed 22 Sep 17:11:35 BST 2021
  ```

- Installieren bitte Sie die benötigten Pakete für die AD-Verbindung auf der Linux-Seite:

  ```sh
  [user@host ~]$ sudo dnf install realmd oddjob oddjob-mkhomedir sssd adcli krb5-workstation
  ```


### Discovery

Jetzt sollten Sie in der Lage sein, Ihre AD-Server erfolgreich von Ihrem (Rocky) Linux-Host zu finden.

```sh
[user@host ~]$ realm discover ad.company.local
ad.company.local
  type: kerberos
  realm-name: AD.COMPANY.LOCAL
  domain-name: ad.company.local
  configured: no
  server-software: active-directory
  client-software: sssd
  required-package: oddjob
  required-package: oddjob-mkhomedir
  required-package: sssd
  required-package: adcli
  required-package: samba-common
```

Die relevanten SRV-Einträge, die in Ihrem Active Directory-DNS-Dienst gespeichert sind, ermöglichen die Erkennung.

### Verbindung

Sobald Sie Ihre Active Directory Installation vom Linux-Host gefunden haben, sollten Sie in der Lage sein mit `realmd` der Domain beizutreten, welche die Konfiguration von `sssd` unter Verwendung von `adcli` und anderen solchen Tools orchestriert.

```sh
[user@host ~]$ sudo realm join ad.company.local
```

Wenn sich dieser Prozess über die Verschlüsselung mit folgender Meldung beschwert `KDC has no support for this encrption type`, versuchen Sie, die globalen Verschlüsselungsrichtlinien zu aktualisieren, um ältere Verschlüsselungsalgorithmen zu zulassen:

```sh
[user@host ~]$ sudo update-crypto-policies --set DEFAULT:AD-SUPPORT
```

Wenn dieser Prozess erfolgreich ist, sollten Sie jetzt in der Lage sein, `passwd` Informationen für einen Active Directory Benutzer zu bekommen.

```sh
[user@host ~]$ sudo getent passwd administrator@ad.company.local
administrator@ad.company.local:*:1450400500:1450400513:Administrator:/home/administrator@ad.company.local:/bin/bash
```

!!! note "Hinweis"

    `getent` liest Einträge von Name Service Switch Bibliotheken (NSS). Es bedeutet, dass es im Gegensatz zu `passwd` oder `dig` zum Beispiel verschiedene Datenbanken abgefragen werden inklusive `/etc/hosts` für `getent hosts` oder von `sssd` im `getent passwd` Fall.

`realm` bietet einige interessante Optionen, die Sie verwenden können:

| Option                                                     | Beschreibung                                        |
| ---------------------------------------------------------- | --------------------------------------------------- |
| --computer-ou='OU=LINUX,OU=SERVERS,dc=ad,dc=company.local' | Das OU, wo das Server-Konto gespeichert werden soll |
| --os-name='rocky'                                          | Gibt den OS-Namen an, der im AD gespeichert ist     |
| --os-version='8'                                           | Gibt die OS-Version an, die im AD gespeichert ist   |
| -U admin_username                                          | Admin-Konto                                         |

### Authentifizierungs-Versuch

Jetzt sollten Ihre Benutzer in der Lage sein, sich bei Ihrem Linux-Host gegen Active Directory zu authentifizieren.

**Unter Windows 10** (welches eine eigene Kopie von OpenSSH bereitstellen sollte</strong>):

```dos
C:\Users\John.Doe> ssh -l john.doe@ad.company.local linux.host
Password for john.doe@ad.company.local:

Activate the web console with: systemctl enable --now cockpit.socket

Last login: Wed Sep 15 17:37:03 2021 from 10.0.10.241
[john.doe@ad.company.local@host ~]$
```

Wenn dies gelingt, haben Sie Linux erfolgreich für die Verwendung von Active Directory als Authentifizierungsquelle konfiguriert.

### Einstellung der Standard-Domain

Bei einer vollständig standardmäßigen Einrichtung müssen Sie sich mit Ihrem AD-Konto anmelden, indem Sie die Domäne in Ihrem Benutzernamen angeben (z. B. `john.doe@ad.company.local`). Wenn dies nicht das gewünschte Verhalten ist und Sie stattdessen den Domänennamen bei der Authentifizierung weglassen möchten, können Sie SSSD so konfigurieren, dass standardmäßig eine bestimmte Domäne verwendet wird.

Dies ist ein relativ unkomplizierter Vorgang, der eine Konfigurationsoptimierung in Ihrer SSSD-Konfigurationsdatei erfordert.

```sh
[user@host ~]$ sudo vi /etc/sssd/sssd.conf
[sssd]
...
default_domain_suffix = ad.company.local
```

Durch Hinzufügen des `default_domain_suffix` weisen Sie SSSD an, (wenn keine andere Domäne angegeben ist) daraus zu folgern, dass der Benutzer versucht, sich als Benutzer aus der Domäne `ad.company.local` zu authentifizieren. Dadurch können Sie sich beispielsweise als `john.doe` statt als `john.doe@ad.company.local` authentifizieren.

Damit diese Konfigurationsänderung wirksam wird, müssen Sie die Einheit `sssd.service` mit `systemctl` neu starten.

```sh
[user@host ~]$ sudo systemctl restart sssd
```

Wenn Sie nicht möchten, dass Ihre Home-Verzeichnisse mit dem Domänennamen als Suffix versehen werden, können Sie diese Optionen auf die gleiche Weise in Ihre Konfigurationsdatei `/etc/sssd/sssd.conf` einfügen:

```
[domain/ad.company.local]
use_fully_qualified_names = False
override_homedir = /home/%u
```

Vergessen Sie nicht, den Dienst `sssd` neu zu starten.

### Auf bestimmte Benutzer beschränken

Es gibt verschiedene Methoden, den Zugriff auf den Server auf eine begrenzte Anzahl von Benutzern zu beschränken, aber diese ist, wie der Name schon sagt, sicherlich die einfachste:

Fügen Sie diese Optionen in Ihre Konfigurationsdatei `/etc/sssd/sssd.conf` ein und starten Sie den Dienst neu:

```
access_provider = simple
simple_allow_groups = group1, group2
simple_allow_users = user1, user2
```

Jetzt können nur Benutzer aus `group1` und `group2` oder `user1` und `user2` über sssd eine Verbindung zum Server herstellen!

## Interagieren Sie mit dem AD über `adcli`

`adcli` ist eine CLI zum Ausführen von Aktionen in einer Active Directory-Domäne.

- Falls noch nicht geschehen, installieren Sie das erforderliche Paket:

```sh
[user@host ~]$ sudo dnf install adcli
```

- Testen Sie, ob Sie bereits einer Active Directory-Domäne beigetreten sind:

```sh
[user@host ~]$ sudo adcli testjoin
Successfully validated join to domain ad.company.local
```

- Erhalten Sie weitere Informationen zur Domäne:

```sh
[user@host ~]$ adcli info ad.company.local
[domain]
domain-name = ad.company.local
domain-short = AD
domain-forest = ad.company.local
domain-controller = dc1.ad.company.local
domain-controller-site = site1
domain-controller-flags = gc ldap ds kdc timeserv closest writable full-secret ads-web
domain-controller-usable = yes
domain-controllers = dc1.ad.company.local dc2.ad.company.local
[computer]
computer-site = site1
```

- `adcli` ist mehr als nur ein Anzeige-Tool. Sie können damit mit Ihrer Domäne interagieren: Benutzer oder Gruppen verwalten, Passwörter ändern usw.

Beispiel: Verwenden Sie `adcli`, um Informationen über einen Computer abzurufen:

!!! note "Hinweis"

    Dieses Mal geben Sie dank der Option `-U` einen Administrator-Benutzernamen an

```sh
[user@host ~]$ adcli show-computer pctest -U admin_username
Password for admin_username@AD: 
sAMAccountName:
 pctest$
userPrincipalName:
 - not set -
msDS-KeyVersionNumber:
 9
msDS-supportedEncryptionTypes:
 24
dNSHostName:
 pctest.ad.company.local
servicePrincipalName:
 RestrictedKrbHost/pctest.ad.company.local
 RestrictedKrbHost/pctest
 host/pctest.ad.company.local
 host/pctest
operatingSystem:
 Rocky
operatingSystemVersion:
 8
operatingSystemServicePack:
 - not set -
pwdLastSet:
 133189248188488832
userAccountControl:
 69632
description:
 - not set -
```

Beispiel: Verwenden Sie `adcli`, um das Passwort des Benutzers zu ändern:

```sh
[user@host ~]$ adcli passwd-user user_test -U admin_username
Password for admin_username@AD: 
Password for user_test: 
[user@host ~]$ 
```

## Problembehandlung

Manchmal wird der Netzwerkdienst nach SSSD gestartet, was zu Problemen bei der Authentifizierung führt.

Bis Sie den Dienst neu starten, können AD-Benutzer keine Verbindung herstellen.

In diesem Fall müssen Sie die Servicedatei von systemd überschreiben, um das Problem zu beheben.

Kopieren Sie diesen Inhalt in `/etc/systemd/system/sssd.service`:

```
[Unit]
Description=System Security Services Daemon
# SSSD must be running before we permit user sessions
Before=systemd-user-sessions.service nss-user-lookup.target
Wants=nss-user-lookup.target
After=network-online.target


[Service]
Environment=DEBUG_LOGGER=--logger=files
EnvironmentFile=-/etc/sysconfig/sssd
ExecStart=/usr/sbin/sssd -i ${DEBUG_LOGGER}
Type=notify
NotifyAccess=main
PIDFile=/var/run/sssd.pid

[Install]
WantedBy=multi-user.target
```

Beim nächsten Reboot wird der Dienst entsprechend seinen Anforderungen gestartet und alles wird gut gehen.

## Verlassen des Active Directory

Manchmal ist es notwendig, die Active Directory zu verlassen.

Sie können erneut mit `realm` fortfahren und dann die nicht mehr benötigten Pakete entfernen:

```sh
[user@host ~]$ sudo realm leave ad.company.local
[user@host ~]$ sudo dnf remove realmd oddjob oddjob-mkhomedir sssd adcli krb5-workstation
```
