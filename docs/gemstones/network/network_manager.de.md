---
title: NetworkManager
author: tianci li
contributors: Steven Spencer
tags:
  - NetworkManager
  - RL9
---

## Netzwerkkonfiguration-Tool-Suite

Im Jahr 2004 startete Red Hat das Projekt **NetworkManager**, dessen Ziel es ist, Linux-Benutzern die Erfüllung der Anforderungen der aktuellen Netzwerkverwaltung, insbesondere der Verwaltung drahtloser Netzwerke, zu erleichtern. Heute wird das Projekt von GNOME verwaltet. Die [Homepage für NetworkManager finden Sie hier](https://networkmanager.dev/).

Offizielle Einleitung – NetworkManager ist eine Suite von Standardtools für die Linux-Netzwerkkonfiguration. Es unterstützt verschiedene Netzwerkeinstellungen vom Desktop über Server bis hin zu mobilen Geräten und ist perfekt in gängige Desktop-Umgebungen und Tools zur Serverkonfiguration integriert.

Die Suite umfasst hauptsächlich zwei Befehlszeilentools:

- `nmtui`. Konfiguriert das Netzwerk in einer grafischen Oberfläche.

```bash
shell > dnf -y install NetworkManager NetworkManager-tui
shell > nmtui
```

| NetworkManager TUI        |    |
| ------------------------- | -- |
| Verbindung bearbeiten     |    |
| Verbindung aktivieren     |    |
| System-Hostname festlegen |    |
| Beenden                   |    |
|                           | Ok |

- `nmcli`. Verwendet die Befehlszeile zum Konfigurieren des Netzwerks, entweder eine reine Befehlszeile oder interaktiv.

```bash
Shell > nmcli connection show
NAME    UUID                                  TYPE      DEVICE
ens160  25106d13-ba04-37a8-8eb9-64daa05168c9  ethernet  ens160
```

Für Rocky Linux 8.x haben wir [in diesem Dokument](./nmtui.md) die Konfiguration des Netzwerks vorgestellt. Sie können `vim` verwenden, um die Konfigurationsdatei der Netzwerkkarte im Verzeichnis **/etc/sysconfig/network-script/** zu bearbeiten, oder Sie können `nmcli`/`nmtui` verwenden. Beide sind verwendbar.

## Benennungsregeln für den Device-Manager `udev`

Wenn Sie bei RockyLinux 9.x in das Verzeichnis **/etc/sysconfig/network-scripts/** gehen, wird ein Beschreibungstext **readme-ifcfg-rh.txt** angezeigt, der Sie auffordert, in das Verzeichnis **/etc/NetworkManager/system-connections/** zu gehen.

```bash
Shell > cd /etc/NetworkManager/system-connections/  && ls
ens160.nmconnection
```

`ens160` bezieht sich auf den Namen des Netzwerkadapters im System. Warum klingt der Name so seltsam? Dies liegt am Gerätemanager `udev`. Es unterstützt viele verschiedene Benennung-Schemata. Standardmäßig werden feste Namen entsprechend der Firmware-, Topologie- und Standortinformationen vergeben. Einige Vorteile:

- Gerätenamen sind vollständig vorhersehbar.
- Gerätenamen bleiben unverändert, auch wenn Sie Hardware hinzufügen oder entfernen, da keine erneute Aufzählung erfolgt.
- Defekte Hardware kann problemlos ausgetauscht werden.

In RHEL 9 und den der Community-Version entsprechenden Betriebssystemen ist die konsistente Gerätebenennung standardmäßig aktiviert. Der `udev` Device-Manager generiert Gerätenamen gemäß dem folgenden Schema:

| Schema | Beschreibung                                                                                                                                                                                                                  | Beispiel        |
| ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------- |
| 1      | Gerätenamen enthalten von der Firmware oder dem BIOS bereitgestellte Indexnummern für Onboard-Geräte. Wenn diese Information nicht verfügbar oder anwendbar ist, verwendet `udev` Schema 2.                                   | eno1            |
| 2      | Die Gerätenamen enthalten die von der Firmware oder dem BIOS bereitgestellten Indexnummern der PCI Express (PCIe)-Hot-Plug-Steckplätze. Wenn diese Information nicht verfügbar oder anwendbar ist, verwendet `udev` Schema 3. | ens1            |
| 3      | Die Gerätebezeichnungen enthalten die physische Location des Anschlusses der Hardware. Wenn diese Information nicht verfügbar oder anwendbar ist, verwendet `udev` Schema 5.                                                  | enp2s0          |
| 4      | Gerätenamen enthalten die MAC-Adresse. Red Hat Enterprise Linux verwendet dieses Schema nicht standardmäßig, Administratoren können es aber optional nutzen.                                                                  | enx525400d5e0fb |
| 5      | Das traditionelle, unvorhersehbare Benennungsschema für Kernel. Wenn `udev` keines der anderen Schemata anwenden kann, verwendet der Geräte-Manager dieses Schema.                                                            | eth0            |

`udev` Der Geräte-Manager benennt das Präfix der Netzwerkkarte basierend auf dem Schnittstellentyp:

- **en** für Ethernet.
- **wl** für Wireless-LAN (WLAN).
- **ww** wireless wide Area Network (WWAN).
- **ib**, InfiniBand–Netzwerk.
- **sl**, Serial Line Internet-Protokoll (slip)

Dem Präfix einige Suffixe hinzufügen, beispielsweise:

- **o** on-board_index_number
- **s** hot_plug_slot_index_number **[f]** Funktion **[d]** device_id
- **x** MAC_address
- **[P]** Domänen-Nummer **p** Bus **s** Slot **[f]** Funktion **[d]** device_id
- **[P]** Domänen-Nummer **p** Bus **s** Steckplatz **[f]** Funktion **[u]** USB-Anschluss **[c]** Konfiguration **[i]** Schnittstelle

Detailliertere Informationen erhalten Sie mit `man 7 systemd.net-naming-scheme`.

## `nmcli`-Befehl (empfohlen)

Benutzer können das Netzwerk nicht nur in einem reinen Befehlszeilenmodus konfigurieren, sondern auch interaktive Kommandos zur Konfiguration des Netzwerks verwenden.

### `nmcli connection`

Mit dem Befehl `nmcli connection` lassen sich anzeigen, löschen, hinzufügen, ändern, bearbeiten, nach oben, nach unten usw.

Informationen zur spezifischen Verwendung finden Sie unter `nmcli connection add --help`, `nmcli connection edit --help`, `nmcli connection modify --help` usw.

Um beispielsweise eine neue statische Ipv4-Verbindung mithilfe einer reinen Befehlszeile zu konfigurieren und automatisch zu starten, kann Folgendes verwendet werden:

```bash
Shell > nmcli  connection  add  type  ethernet  con-name   CONNECTION_NAME  ifname  NIC_DEVICE_NAME   \
ipv4.method  manual  ipv4.address "192.168.10.5/24"  ipv4.gateway "192.168.10.1"  ipv4.dns "8.8.8.8,114.114.114.114" \
ipv6.method  disabled  autoconnect yes
```

Wenn Sie DHCP zum Abrufen der IPv4-Adresse verwenden, kann diese wie folgt lauten:

```bash
Shell > nmcli  connection  add  type ethernet con-name CONNECTION_NAME  ifname  NIC_DEVICE_NAME \
ipv4.method  auto  ipv6.method  disabled  autoconnect  yes
```

Bei der oben beschriebenen Konfiguration wird die Verbindung nicht aktiviert. Sie müssen folgende Operation ausführen:

```bash
Shell > nmcli connection up  NIC_DEVICE_NAME
```

Rufen Sie die interaktive Schnittstelle über das Schlüsselwort `edit` auf Basis der bestehenden Verbindung auf und ändern Sie diese:

```bash
Shell > nmcli connection  edit  CONNECTION_NAME
nmcli > help
```

Sie können eine oder mehrere Eigenschaften der Verbindung auch direkt über die Befehlszeile mit dem Schlüsselwort `modify` ändern. Zum Beispiel:

```bash
Shell > nmcli connection modify CONNECTION_NAME autoconnect yes ipv6.method dhcp
```

!!! info "Info"

    Operationen, die über `nmcli` oder `nmtui` ausgeführt werden, werden dauerhaft und nicht nur temporär gespeichert.

#### Linksaggregation

Einige nutzen mehrere Netzwerkkarten zur Link-Aggregation. In den Anfangstagen gab es bei der Verwendung der **Bonding**-Technologie sieben Arbeitsmodi (0–6) und der Bond-Modus unterstützte höchstens zwei Netzwerkkarten. Später wird die **Teaming**-Technologie schrittweise als Alternative verwendet. Es gibt fünf Arbeitsmodi und der Teammodus kann bis zu acht Netzwerkkarten verwenden. Einen Vergleichslink zwischen Bonding und Teaming [finden Sie unter diesem Link](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/networking_guide/sec-comparison_of_network_teaming_to_bonding).

Zum Beispiel der 0-Modus der Bonding:

```bash
Shell > nmcli  connection  add  type  bond  con-name  BOND_CONNECTION_NAME   ifname  BOND_NIC_DEVICE_NAME  mode 0
Shell > nmcli  connection  add  type  bond-slave   ifname NIC_DEVICE_NAME1   master  BOND_NIC_DEVICE_NAME
Shell > nmcli  connection  add  type  bond-slave   ifname NIC_DEVICE_NAME2   master  BOND_NIC_DEVICE_NAME
```

## Konfiguration der Netzwerkkarte

!!! warning "Warnhinweis"

    Es wird nicht empfohlen, hier Änderungen mit `vim` oder anderen Editoren vorzunehmen.

Ausführlichere Informationen können Sie über `man 5 NetworkManager.conf` und `man 5 nm-settings-nmcli` anzeigen.

The content of the configuration file of the NetworkManager network card is an init-style key file. Zum Beispiel:

```bash
Shell > cat /etc/NetworkManager/system-connections/ens160.nmconnection
[connection]
id=ens160
uuid=5903ac99-e03f-46a8-8806-0a7a8424497e
type=ethernet
interface-name=ens160
timestamp=1670056998

[ethernet]
mac-address=00:0C:29:47:68:D0

[ipv4]
address1=192.168.100.4/24,192.168.100.1
dns=8.8.8.8;114.114.114.114;
method=manual

[ipv6]
addr-gen-mode=default
method=disabled

[proxy]
```

- Leer-Zeilen uns Zeilen, die mit # beginnen, gelten als Kommentare.
- Die Klammern `[` und `]` markieren den Abschnitt, in dem der Name deklariert werden soll, und unten sind die spezifischen Schlüssel-Wert-Paare aufgeführt. Jeder deklarierte Titel und sein Schlüssel-Wert-Paar bilden ein Syntaxsegment.
- Jede Datei mit dem Suffix `.nmconnection` kann vom **NetworkManager** verwendet werden.

**Verbindungs**‐Titlenamen können diese allgemeinen Schlüssel-Wert-Paare enthalten:

| Schlüssel      | Beschreibung                                                                                                                                                                 |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| id             | Der Alias ​​​​von `con-name`, dessen Wert eine Zeichenkette ist.                                                                                                           |
| uuid           | Universeller eindeutiger Bezeichner, dessen Wert eine Zeichenkette ist.                                                                                                      |
| type           | Die Art der Verbindung, deren Werte beispielsweise Ethernet, Bluetooth, VPN, VLAN usw. sein können. Mit dem Befehl `man nmcli` können Sie alle unterstützten Typen anzeigen. |
| interface-name | Der Name der Netzwerkschnittstelle, an die diese Verbindung gebunden ist, deren Wert eine Zeichenfolge ist.                                                                  |
| timestamp      | Unix-Zeitstempel in Sekunden. Der Wert hier ist die Anzahl der Sekunden seit dem 1. Januar 1970.                                                                             |
| autoconnect    | Gibt an, ob es beim Systemstart automatisch gestartet wird. Der Wert ist boolescher Typ.                                                                                     |

**Ethernet**-Titelnamen können diese gängigen Schlüssel-Wert-Paare enthalten:

| Schlüssel      | Beschreibung                                                                                                                                                                                                                                                                                                                                                                                                                      |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| mac-address    | Physische MAC-Adresse.                                                                                                                                                                                                                                                                                                                                                                                                            |
| mtu            | Maximum Transmission Unit.                                                                                                                                                                                                                                                                                                                                                                                                        |
| auto-negotiate | Automatische Konfiguration der Übertragung. Der Wert ist boolescher Typ.                                                                                                                                                                                                                                                                                                                                                          |
| duplex         | Die möglichen Werte sind `half` (half-duplex), `full` (full-duplex)                                                                                                                                                                                                                                                                                                                                                           |
| speed          | Definiert die Übertragungsrate der Netzwerkkarte an. 100 bedeutet 100Mbit/s. Wenn **auto-negotiate=false**, müssen die Schlüssel **speed** und **duplex** gesetzt sein; wenn **auto-negotiate=true**, wird die ausgehandelte Geschwindigkeit verwendet und das Schreiben hier hat keine Auswirkung (dies gilt nur für die 802.3 BASE-T-Spezifikation); wenn er ungleich Null ist, muss der Schlüssel **duplex** einen Wert haben. |

**ipv4**-Titelnamen können die folgenden gebräuchlichen Schlüsselwert-Paare enthalten:

| Schlüssel | Beschreibung                                                                                                                           |
| --------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| addresses | Zugewiesene IP-Adressen                                                                                                                |
| gateway   | Gateway (nächster Hop) für die Schnittstelle                                                                                           |
| dns       | Verwendete Domänennamenserver                                                                                                          |
| method    | Die Methode, die per IP abgerufen werden soll. Der Wert ist vom String-Typ. Mögliche Werte: auto, disabled, link-local, manual, shared |
