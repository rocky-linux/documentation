---
title: WireGuard VPN
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.4
tags:
  - Sicherheit
  - vpn
---

## Einleitung

[WireGuard](https://www.wireguard.com/) ist ein freies und quelloffenes Peer-to-Peer (P2P) virtuelles privates Netzwerk (VPN). Es ist eine leichte und sichere moderne Ersatzlösung zu herkömmlichen VPNs mit großen Codebasen, die auf TCP-Verbindungen basieren. Da WireGuard ein P2P-VPN ist, kommuniziert jeder zum WireGuard-Netzwerk hinzugefügte Computer direkt miteinander. In dieser Anleitung wird ein `Hub-Spoke-Modell` verwendet, bei dem einem `WireGuard-Peer` eine öffentliche IP-Adresse als Gateway zur Weiterleitung des gesamten Datenverkehrs zugewiesen wird. Dadurch kann der WireGuard-Verkehr `Carrier Grade NAT` (CGNAT) umgehen, ohne dass die Portweiterleitung auf Ihrem Router aktiviert werden muss. Dies erfordert ein Rocky Linux-System mit einer öffentlichen IP-Adresse. Der einfachste Weg, dies zu erreichen, besteht darin, einen virtuellen privaten Server (VPS) über einen Cloud-Anbieter Ihrer Wahl einzurichten. Zum Zeitpunkt des Schreibens des Artikels bietet die Google Cloud Platform eine kostenlose Stufe für seine e2-Micro-Instanzen an.

## Voraussetzungen

Die Mindestanforderungen für dieses Verfahren sind folgende:

- Die Möglichkeit, Befehle als Root-Benutzer auszuführen oder `sudo` zu verwenden, um Privilegien entsprechend anzupassen
- Ein Rocky Linux-System mit einer öffentlich zugänglichen IP-Adresse

## WireGuard-Installation

Aktivieren Sie das EPEL-Repository (Extra Packages for Enterprise Linux):

```bash
sudo dnf install epel-release -y
```

Systempakete aktualisieren:

```bash
sudo dnf upgrade -y
```

WireGuard installieren:

```bash
sudo dnf install wireguard-tools -y
```

## WireGuard Server — Konfiguration

Erstellen Sie einen Ordner, in dem Sie Ihre WireGuard-Konfigurationsdateien und -Schlüssel ablegen können:

```bash
sudo mkdir -p /etc/wireguard
```

Erstellen Sie eine Konfigurationsdatei mit einem Namen Ihrer Wahl und der Erweiterung `.conf`:

!!! note "Anmerkung"

```
Sie können auf derselben Maschine mehrere WireGuard-VPN-Tunnel erstellen, die jeweils eine andere Konfigurationsdatei, Netzwerkadresse und einen anderen UDP-Port verwenden.
```

```bash
sudo touch /etc/wireguard/wg0.conf
```

Generieren Sie ein neues privates und öffentliches Schlüsselpaar für den WireGuard-Server:

```bash
wg genkey | sudo tee /etc/wireguard/wg0 | wg pubkey | sudo tee /etc/wireguard/wg0.pub
```

Bearbeiten Sie die Konfigurationsdatei mit einem Editor Ihrer Wahl.

```bash
sudo vi /etc/wireguard/wg0.conf
```

Bitte Folgendes einfügen:

```bash
[Interface]
PrivateKey = server_privatekey
Address = x.x.x.x/24
ListenPort = 51820
```

Sie müssen `server_privatekey` durch den zuvor generierten privaten Schlüssel ersetzen. Sie können Ihren privaten Schlüssel anzeigen mit:

```bash
sudo cat /etc/wireguard/wg0
```

Als Nächstes müssen Sie `x.x.x.x/24` durch eine Netzwerkadresse innerhalb des privaten IP-Adressbereichs ersetzen, der durch [RFC 1918](https://datatracker.ietf.org/doc/html/rfc1918) definiert ist. Die in dieser Anleitung verwendete Netzwerkadresse lautet `10.255.255.0/24`.

Schließlich können Sie jeden beliebigen UDP-Port auswählen, um Verbindungen mit WireGuard VPN zu akzeptieren. Für die Zwecke dieses Handbuchs wird der UDP-Port `51820` verwendet.

## IP Forwarding aktivieren

Durch IP-Weiterleitung können Pakete zwischen Netzwerken geroutet werden. Dadurch können interne Geräte über den WireGuard-Tunnel miteinander kommunizieren:

Aktivieren Sie die IP-Weiterleitung für IPv4 und IPv6:

```bash
sudo sysctl -w net.ipv4.ip_forward=1 && sudo sysctl -w net.ipv6.conf.all.forwarding=1
```

## `firewalld`-Konfiguration

Installieren Sie `firewalld`:

```bash
sudo dnf install firewalld -y
```

Aktivieren Sie `firewalld` nach der Installation:

```bash
sudo systemctl enable --now firewalld
```

Erstellen Sie eine permanente Firewall-Regel, die Datenverkehr auf UDP-Port 51820 in der öffentlichen Zone `public` zulässt:

```bash
sudo firewall-cmd --permanent --zone=public --add-port=51820/udp
```

Als Nächstes wird der Datenverkehr von der WireGuard-Schnittstelle zu anderen Schnittstellen in der internen Zone `internal` zugelassen.

```bash
sudo firewall-cmd --permanent --add-interface=wg0 --zone=internal
```

Fügen Sie eine Firewallregel hinzu, um IP-Masquerading für den internen Datenverkehr zu aktivieren. Dies bedeutet, dass zwischen Peers gesendete Pakete die Paket-IP-Adresse durch die IP-Adresse des Servers ersetzen:

```bash
sudo firewall-cmd --permanent --zone=internal --add-masquerade
```

Laden Sie abschließend `firewalld` neu:

```bash
sudo firewall-cmd --reload
```

## WireGuard-Peer Konfiguration

Da alle Computer in einem WireGuard-Netzwerk technisch gesehen Peers sind, ist dieser Vorgang nahezu identisch mit der Konfiguration des WireGuard-Servers, weist jedoch geringfügige Unterschiede auf.

Erstellen Sie einen Ordner, in dem Sie Ihre WireGuard-Konfigurationsdateien und -Schlüssel ablegen können:

```bash
sudo mkdir -p /etc/wireguard
```

Erstellen Sie eine Konfigurationsdatei und geben Sie ihr einen Namen Ihrer Wahl. Die Datei muss mit der Erweiterung `.conf` enden:

```bash
sudo touch /etc/wireguard/wg0.conf
```

Generieren Sie ein neues Paar aus privatem und öffentlichem Schlüssel:

```bash
wg genkey | sudo tee /etc/wireguard/wg0 | wg pubkey | sudo tee /etc/wireguard/wg0.pub
```

Bearbeiten Sie die Konfigurationsdatei mit einem Editor Ihrer Wahl und fügen Sie diesen Inhalt hinzu:

```bash
[Interface]
PrivateKey = peer_privatekey
Address = 10.255.255.2/24

[Peer]
PublicKey = server_publickey
AllowedIPs = 10.255.255.1/24
Endpoint = serverip:51820
PersistentKeepalive = 25
```

Ersetzen Sie `peer_privatekey` durch den privaten Schlüssel des Peers, der auf dem Peer in `/etc/wireguard/wg0` gespeichert ist.

Mit diesem Befehl können Sie sich den Schlüssel ausgeben lassen, um ihn zu kopieren:

```bash
sudo cat /etc/wireguard/wg0
```

Ersetzen Sie `server_publickey` durch den öffentlichen Schlüssel des Servers, der auf dem Server in `/etc/wireguard/wg0.pub` gespeichert ist.

Mit diesem Befehl können Sie sich den Schlüssel ausgeben lassen, um ihn zu kopieren:

```bash
sudo cat /etc/wireguard/wg0.pub
```

Ersetzen Sie `serverip` durch die öffentliche IP-Adresse des WireGuard-Server.

Sie können die öffentliche IP-Adresse des Servers mit dem folgenden Befehl auf dem Server ermitteln:

```bash
ip a | grep inet
```

Die Konfigurationsdatei des Peers enthält jetzt die Regel `PersistentKeepalive = 25`. Diese Regel weist den Peer an, alle 25 Sekunden einen Ping an den WireGuard-Server zu senden, um die Verbindung des VPN-Tunnels aufrechtzuerhalten. Ohne diese Einstellung kommt es zu einer Zeitüberschreitung nach Inaktivität des VPN-Tunnels.

## WireGuard VPN aktivieren

Um WireGuard zu aktivieren, führen Sie den folgenden Befehl sowohl auf dem Server als auch auf dem Peer aus:

```bash
sudo systemctl enable wg-quick@wg0
```

Starten Sie dann das VPN, indem Sie diesen Befehl sowohl auf dem Server als auch auf dem Peer ausführen:

```bash
sudo systemctl start wg-quick@wg0
```

## Fügen Sie den Client-Schlüssel zur WireGuard-Serverkonfiguration hinzu

Den öffentlichen Schlüssel des Peers ausgeben und kopieren:

```bash
sudo cat /etc/wireguard/wg0.pub
```

Führen Sie auf dem Server den folgenden Befehl aus und ersetzen Sie `peer_publickey` durch den öffentlichen Schlüssel des Peers:

```bash
sudo wg set wg0 peer peer_publickey allowed-ips 10.255.255.2
```

Die Verwendung von `wg set` nimmt nur vorübergehende Änderungen an der WireGuard-Schnittstelle vor. Für dauerhafte Konfigurationsänderungen können Sie die Konfigurationsdatei manuell bearbeiten und den Peer hinzufügen. Sie müssen die WireGuard-Schnittstelle neu laden, nachdem Sie dauerhafte Konfigurationsänderungen vorgenommen haben.

Bearbeiten Sie die Konfigurationsdatei des Servers mit einem Editor Ihrer Wahl.

```bash
sudo vi /etc/wireguard/wg0.conf
```

Fügen Sie den Peer zur Konfigurationsdatei hinzu. Der Inhalt sollte etwa wie folgt aussehen:

```bash
[Interface]
PrivateKey = +Eo5oVjt+d3XWvFWYcOChaLroGj5vapdXKH8UZ2T2Fc=
Address = 10.255.255.1/24
ListenPort = 51820

[Peer]
PublicKey = 1vSho8NvECkG1PVVk7avZWDmrd2VGZ2xTPaNe5+XKSg=
AllowedIps = 10.255.255.2/32
```

Interface herunterfahren:

```bash
sudo wg-quick down wg0
```

Interface hochfahren:

```bash
sudo wg-quick up wg0
```

## WireGuard-Schnittstellen anzeigen und Konnektivität testen

Sie können WireGuard-Informationen sowohl auf dem Server als auch auf dem Peer mit folgendem Befehl anzeigen:

```bash
sudo wg
```

Sie können die Konnektivität testen, indem Sie vom Peer aus einen Ping an den Server senden:

```bash
ping 10.255.255.1
```

## Zusammenfassung

Mit dieser Anleitung haben Sie erfolgreich ein WireGuard-VPN mit dem `Hub-Spoke-Modell` eingerichtet. Diese Konfiguration bietet eine sichere, moderne und effiziente Möglichkeit, mehrere Geräte über das Internet zu verbinden. Schauen Sie auf der [offiziellen WireGuard-Website](https://www.wireguard.com/) nach.
