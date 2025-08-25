---
title: nmtui — Netzwerk-Management-Tool
author: tianci li
contributors: Steven Spencer, Neil Hanlon
update: 2021-10-23
---

# Einleitung

Für unerfahrene Benutzer, die GNU/Linux zum ersten Mal verwenden, besteht die erste Überlegung darin, wie der Computer nach der Installation des Betriebssystems mit dem Internet verbunden wird. In diesem Artikel erfahren Sie, wie Sie IP-Adresse, Subnetzmaske, Gateway und DNS konfigurieren. Mehrere Vorgehensweisen sind vorhanden. Ob Sie Anfänger oder erfahren sind, wrden Sie schnell loslegen können.

## nmtui

`NetworkManager` ist eine Standard-Linux-Netzwerkkonfigurationstoolsuite, die Server- und Desktop-Umgebungen unterstützt. Heutzutage wird es von den meisten gängigen Distributionen unterstützt. Dieser Satz von Netzwerkkonfigurationswerkzeugen ist für Rocky Linux 8 und höher geeignet. Wenn Sie Netzwerkeinstellungen grafisch konfigurieren möchten (z.B. mit dem Kommando `nmtui`) können Sie wie folgt vorgehen:

```bash
shell > dnf -y install NetworkManager NetworkManager-tui
shell > nmtui
```

| NetworkManager TUI (nmtui) |          |
| -------------------------- | -------- |
| Verbindung bearbeiten      |          |
| Verbindung aktivieren      |          |
| System-Hostname festlegen  |          |
| Beenden                    |          |
|                            | \<OK\> |

Sie können die Taste ++tab++ oder die Taste ++arrow-up++ ++arrow-down++ ++arrow-left++ ++arrow-right++ verwenden, um die spezifische Connection auszuwählen. Wenn Sie die Netzwerkinformationen ändern möchten, wählen Sie bitte **Edit a connection** und dann ++enter++. Wählen Sie eine andere Netzwerkkarte aus und wählen Sie **Edit..** für die Bearbeitung.

### DHCP IPv4

Wenn Sie für IPv4 Netzwerkinformationen mit DHCP abrufen möchten, müssen Sie nur *IPv4-CONFIGURATION* **&lt;Automatic&gt;** auswählen und in Ihrem Terminal `systemctl restart NetworkManager.service` ausführen. Dies funktioniert in den meisten Fällen. In seltenen Fällen müssen Sie die Netzwerkkarte deaktivieren und reaktivieren, damit die Änderung wirksam wird. Zum Beispiel: `nmcli connection down ens33`, `nmcli connection up ens33`

### Manuelle Korrektur der Netzwerkinformationen

Wenn Sie alle IPv4-Netzwerkinformationen manuell korrigieren möchten, müssen Sie *IPv4-KONFIGURATION* auswählen und sie Zeile für Zeile hinzufügen. Der Autor, zum Beispiel, zieht folgende Vorgehensweise vor:

| Item       | Wert             |
| ---------- | ---------------- |
| Adressen   | 192.168.100.4/24 |
| Gateway    | 192.168.100.1    |
| DNS-Server | 8.8.8.8          |

Klicken Sie dann auf `OK`, kehren Sie Schritt für Schritt zur Terminaloberfläche zurück und führen Sie `systemctl restart NetworkManager.service` aus. Ebenso muss in seltenen Fällen die Netzwerkkarte ein- und ausgeschaltet werden, damit die Änderung wirksam wird.

## Ändern Sie die Art der Konfigurationsdateien

Alle RHEL <font color="red">7.x</font> oder <font color="red">8.x</font> Distributionen, ob Upstream oder Downstream, werden auf die gleiche Weise konfiguriert. Die Konfigurationsdatei der Netzwerkinformationen wird im Verzeichnis **/etc/sysconfig/network-scripts/** gespeichert und eine Netzwerkkarte entspricht einer Konfigurationsdatei. Die Konfigurationsdatei enthält zahlreiche Parameter, wie folgenden Tabelle zeigt. Hinweis! Die Parameter müssen großgeschrieben werden.

!!! warning "Warnung"

    In den RHEL 9.x-Distributionen wurde der Ort des Verzeichnisses, in dem die NIC-Konfigurationsdatei gespeichert wird, geändert, d.h. **/etc/NetworkManager/system-connections/**. Siehe [hier](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html-single/configuring_and_managing_networking/index) für weitere Informationen.

```bash
shell > ls /etc/sysconfig/network-scripts/
ifcfg-ens33
```

| Parametername        | Bedeutung                                                                                                                                                                                                                                                                  | Beispiel                            |
| -------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| DEVICE               | System-Gerätename                                                                                                                                                                                                                                                          | DEVICE=ens33                        |
| ONBOOT               | Ob die Netzwerkkarte automatisch mit dem System startet oder nicht, können Sie yes oder no wählen                                                                                                                                                                          | ONBOOT=yes                          |
| TYPE                 | Netzwerkkartenschnittstellentyp, normalerweise Ethernet                                                                                                                                                                                                                    | TYPE=Ethernet                       |
| BOOTPROTO            | Die Methode zum Abrufen der IP-Adresse kann die dynamische DHCP-Abfrage oder die statische manuelle Konfiguration mit `static`                                                                                                                                           | BOOTPROTO=static                    |
| IPADDR               | Die IP-Adresse der Netzwerkkarte, wenn BOOTPROTO=static, wird dieser Parameter wirksam                                                                                                                                                                                     | IPADDR=192.168.100.4                |
| HWADDR               | Hardware-Adresse, i.e. MAC-Adresse                                                                                                                                                                                                                                         | HWADDR=00:0C:29:84:F6:9C            |
| NETMASK              | Subnet-Maske, dezimal                                                                                                                                                                                                                                                      | NETMASK=255.255.255.0               |
| PREFIX               | Subnetzmaske, als decimal Zahlen repräsentiert                                                                                                                                                                                                                             | PREFIX=24                           |
| GATEWAY              | Gateway, wenn mehrere Netzwerkkarten vorhanden sind, kann dieser Parameter nur einmal vorkommen                                                                                                                                                                            | GATEWAY=192.168.100.1               |
| PEERDNS              | Wenn die Option `yes` lautet, werden die hier definierten DNS-Parameter /etc/resolv.conf ändern; wenn die Option `no` lautet, wird /etc/resolv.conf nicht geändert. Wenn DHCP verwendet wird, ist die Standardeinstellung `yes`                                      | PEERDNS=yes                         |
| DNS1                 | Der primäre DNS ist ausgewählt, er wird nur wirksam, wenn `PEERDNS=no`                                                                                                                                                                                                   | DNS1=8.8.8.8                        |
| DNS2                 | Alternative DNS, nur wirksam, wenn `PEERDNS=no`                                                                                                                                                                                                                          | DNS2=114.114.114.114                |
| BROWSER_ONLY         | Ob nur Browser zugelassen werden sollen                                                                                                                                                                                                                                    | BROWSER_ONLY=no                     |
| USERCTL              | Ob normale Benutzer das Netzwerkkartengerät steuern dürfen, `yes` bedeutet erlauben                                                                                                                                                                                      | USERCTL=no                          |
| UUID                 | Universeller eindeutiger Identifikationscode, die Hauptfunktion ist es, die Hardware zu identifizieren, im Allgemeinen ist es nicht notwendig, dies auszufüllen                                                                                                            |                                     |
| PROXY_METHOD         | Proxy-Methode, normalerweise keine, kann leer bleiben                                                                                                                                                                                                                      |                                     |
| IPV4_FAILURE_FATAL | Wenn der Wert `yes` lautet, bedeutet dies, dass das Gerät deaktiviert wird, nachdem die IPv4-Konfiguration fehlschlägt. Wenn er `no` lautet, bedeutet dies, dass es nicht deaktiviert wird.                                                                            | IPV4_FAILURE_FATAL=no             |
| IPV6INIT             | Ob IPV6 aktiviert werden soll, ja aktivieren, nein inaktiv lassen. Wenn `IPV6INIT=yes`, können auch die beiden Parameter `IPV6ADDR` und `IPV6_DEFAULTGW` aktiviert werden. Erstere repräsentiert die IPV6-Adresse und letztere repräsentiert das designierte Gateway | IPV6INIT=yes                        |
| IPV6_AUTOCONF        | Ob die automatische IPV6-Konfiguration verwendet werden soll, bedeutet `yes` „verwenden“, `no` bedeutet „nicht verwenden“                                                                                                                                              | IPV6_AUTOCONF=yes                   |
| IPV6_DEFROUTE        | Gibt IPV6 als Standardroute an                                                                                                                                                                                                                                             | IPV6_DEFROUTE=yes                   |
| IPV6_FAILURE_FATAL | Falls die IPV6-Konfiguration fehlschlägt, ob das Gerät deaktiviert werden soll                                                                                                                                                                                             | IPV6_FAILURE_FATAL=no             |
| IPV6_ADDR_GEN_MODE | IPV6-Adressmodell generieren, optionale Werte sind `stable-privacy` und `eui64`                                                                                                                                                                                        | IPV6_ADDR_GEN_MODE=stable-privacy |

Nachdem die Konfigurationsdatei erfolgreich geändert wurde, vergessen Sie nicht, den Dienst neu zu starten; `systemctl restart NetworkManager.service`.

### Empfohlene Konfiguration für `IPV4`

```bash
TYPE=Ethernet
ONBOOT=yes
DEVICE=ens33
USERCTL=no
IPV4_FAILURE_FATAL=no
BROWSER_ONLY=no
BOOTPROTO=static
PEERDNS=no
IPADDR=192.168.100.4
PREFIX=24
GATEWAY=192.168.100.1
DNS1=8.8.8.8
DNS2=114.114.114.114
```

### Empfohlene Konfiguration für `IPV6`

```bash
TYPE=Ethernet
ONBOOT=yes
DEVICE=ens33
USERCTL=no
BROWSER_ONLY=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
```

## Netzwerkinformation anzeigen

`ip a` or `nmcli device show`
