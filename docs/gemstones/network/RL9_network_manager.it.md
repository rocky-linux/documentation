---
title: RL9 - network manager
author: tianci li
contributors: Steven Spencer
tags:
  - networkmanager
  - RL9
---

# NetworkManager Suite di strumenti per la configurazione della rete

Nel 2004, Red Hat ha lanciato il progetto **NetworkManager**, che mira a rendere più facile per gli utenti Linux soddisfare le esigenze di gestione delle reti attuali, in particolare la gestione delle reti wireless. Oggi il progetto è gestito da GNOME. La [homepage di NetworkManager si trova qui](https://networkmanager.dev/).

Introduzione ufficiale - NetworkManager è una suite di strumenti standard per la configurazione della rete Linux. Supporta diverse impostazioni di rete, dal desktop al server e ai dispositivi mobili, ed è perfettamente integrato con i più diffusi ambienti desktop e strumenti di gestione della configurazione dei server.

La suite comprende principalmente due strumenti a riga di comando:

* `nmtui`. Configurare la rete con un'interfaccia grafica.

```bash
shell > dnf -y install NetworkManager NetworkManager-tui
shell > nmtui
```

| NetworkManager TUI            |    |
| ----------------------------- | -- |
| Modifica di una connessione   |    |
| Attiva una connessione        |    |
| Imposta nome host del sistema |    |
| Esci                          |    |
|                               | OK |

* `nmcli`. Per configurare la rete, utilizzare la riga di comando pura o interattiva.

```bash
Shell > nmcli connection show
NAME    UUID                                  TYPE      DEVICE
ens160  25106d13-ba04-37a8-8eb9-64daa05168c9  ethernet  ens160
```

Per RockyLinux 8.x, abbiamo introdotto come configurare la rete [in questo documento](./nmtui.md). Si può usare `vim` per modificare il file di configurazione della scheda di rete nella directory **/etc/sysconfig/network-script/**, oppure si può usare `nmcli`/`nmtui`, entrambi utilizzabili.

## Regole di denominazione per udev device Manager

Per RockyLinux 9.x, se si va nella directory **/etc/sysconfig/network-scripts/**, ci sarà un testo di descrizione **readme-ifcfg-rh.txt** che richiede di andare nella directory **/etc/NetworkManager/system-connections/**.

```bash
Shell > cd /etc/NetworkManager/system-connections/  && ls 
ens160.nmconnection
```

`Ens160` si riferisce al nome della scheda di rete del sistema. Vi chiederete perché il nome sembra così strano? Questo è dovuto al gestore di dispositivi `udev`. Supporta diversi schemi di denominazione. Per impostazione predefinita, i nomi fissi vengono assegnati in base al firmware, alla topologia e alle informazioni sulla posizione. I suoi vantaggi includono:

* I nomi dei dispositivi sono completamente prevedibili.
* I nomi dei dispositivi rimangono fissi anche se si aggiunge o si rimuove hardware, perché non avviene una nuova enumerazione.
* L'hardware difettoso può essere sostituito senza problemi.

In RHEL 9 e nei sistemi operativi corrispondenti alla versione della comunità, la denominazione coerente dei dispositivi è abilitata per impostazione predefinita. Il gestore di dispositivi `udev` genera i nomi dei dispositivi secondo il seguente schema:

| Schema | Descrizione                                                                                                                                                                                                              | Esempio         |
| ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------- |
| 1      | I nomi dei dispositivi incorporano i numeri di indice forniti dal firmware o dal BIOS per i dispositivi onboard. Se questa informazione non è disponibile o non è applicabile, `udev` utilizza lo schema 2.              | eno1            |
| 2      | I nomi dei dispositivi incorporano i numeri di indice degli slot hot plug PCI Express (PCIe) forniti dal firmware o dal BIOS. Se questa informazione non è disponibile o non è applicabile, `udev` utilizza lo schema 3. | ens1            |
| 3      | I nomi dei dispositivi incorporano la posizione fisica del connettore dell'hardware. Se questa informazione non è disponibile o non è applicabile, `udev` utilizza lo schema 5.                                          | enp2s0          |
| 4      | I nomi dei dispositivi incorporano l'indirizzo MAC. Red Hat Enterprise Linux non utilizza questo schema per impostazione predefinita, ma gli amministratori possono utilizzarlo facoltativamente.                        | enx525400d5e0fb |
| 5      | Il tradizionale schema di denominazione del kernel non prevedibile. Se `udev` non può applicare nessuno degli altri schemi, il gestore di dispositivi utilizza questo schema.                                            | eth0            |

`udev` device Manager nomina il prefisso della NIC in base al tipo di interfaccia:

* **en** per Ethernet.
* **wl** per LAN senza fili (WLAN).
* **ww** per la rete wireless wide area (WWAN).
* **ib**, rete InfiniBand.
* **sl**, linea seriale Protocollo Internet (slip)

Aggiungere alcuni suffissi al prefisso, come ad esempio:

* **o** on-board_index_number
* **s** hot_plug_slot_index_number **[f]** function **[d]** device_id
* **x** MAC_address
* **[P]** domain number **p** bus **s** slot **[f]** function **[d]** device_id
* **[P]** domain number **p** buss **s** slot **[f]** function **[u]** usb port **[c]** config **[i]** interface

È possibile utilizzare `man 7 systemd.net-naming-scheme` per ottenere informazioni più dettagliate.

## comando `nmcli` (consigliato)

Gli utenti possono non solo configurare la rete in modalità puramente a riga di comando, ma anche utilizzare comandi interattivi per configurare la rete.

### `nmcli connection`

Il comando `nmcli connection` può mostrare, cancellare, aggiungere, modificare, editare, aumentare, diminuire e così via.

Per un utilizzo specifico, consultare `nmcli connection add --help`, `nmcli connection edit --help`, `nmcli connection modify --help` e così via.

Ad esempio, per configurare una nuova connessione ipv4 statica tramite una linea di comando pura e avviarla automaticamente, può essere:

```bash
Shell > nmcli  connection  add  type  ethernet  con-name   CONNECTION_NAME  ifname  NIC_DEVICE_NAME   \
ipv4.method  manual  ipv4.address "192.168.10.5/24"  ipv4.gateway "192.168.10.1"  ipv4.dns "8.8.8.8,114.114.114.114" \
ipv6.method  disabled  autoconnect yes
```

Se si utilizza il DHCP per ottenere l'indirizzo ipv4, può essere:

```bash
Shell > nmcli  connection  add  type ethernet con-name CONNECTION_NAME  ifname  NIC_DEVICE_NAME \
ipv4.method  auto  ipv6.method  disabled  autoconnect  yes
```

Con la configurazione precedente, la connessione non viene attivata. È necessario eseguire le seguenti operazioni:

```bash
Shell > nmcli connection up  NIC_DEVICE_NAME
```

Accedere all'interfaccia interattiva attraverso la parola chiave `edit` sulla base della connessione esistente e modificarla:

```bash
Shell > nmcli connection  edit  CONNECTION_NAME
nmcli > help
```

È anche possibile modificare una o più proprietà della connessione direttamente dalla riga di comando con la parola chiave `modify`. Per esempio:

```bash
Shell > nmcli connection modify CONNECTION_NAME autoconnect yes ipv6.method dhcp
```

!!! info "Informazione"

    Le operazioni effettuate tramite `nmcli` o `nmtui` vengono salvate in modo permanente, non temporaneo.

#### Aggregazione dei collegamenti

Alcuni utilizzano più schede di rete per l'aggregazione dei collegamenti. All'inizio, utilizzando la tecnologia **bonding**, c'erano sette modalità di lavoro (0~6) e la modalità bond supportava solo due schede di rete al massimo; in seguito, la tecnologia **teaming** è stata gradualmente utilizzata come alternativa, ci sono cinque modalità di lavoro e la modalità team può utilizzare fino a otto schede di rete. Il link di confronto tra bonding e teaming [può essere trovato a questo link](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/networking_guide/sec-comparison_of_network_teaming_to_bonding).

Ad esempio, la modalità 0 di bonding:

```bash
Shell > nmcli  connection  add  type  bond  con-name  BOND_CONNECTION_NAME   ifname  BOND_NIC_DEVICE_NAME  mode 0
Shell > nmcli  connection  add  type  bond-slave   ifname NIC_DEVICE_NAME1   master  BOND_NIC_DEVICE_NAME
Shell > nmcli  connection  add  type  bond-slave   ifname NIC_DEVICE_NAME2   master  BOND_NIC_DEVICE_NAME
```

## Configurazione della scheda di rete

!!! warning "Attenzione"

    Non è consigliabile apportare modifiche con `vim` o altri editor.

Informazioni più dettagliate sono disponibili in `man 5 NetworkManager.conf` e `man 5 nm-settings-nmcli`.

Il contenuto del file di configurazione della scheda di rete NetworkManager è un file chiave di tipo init. Per esempio:

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

* Le righe che iniziano con # e le righe vuote sono considerate commenti;
* Racchiusa tra [ e ] c'è la sezione che intende dichiarare il titolo e sotto di essa ci sono le coppie chiave-valore specifiche contenute. Ogni titolo dichiarato e la sua coppia chiave-valore formano un segmento di sintassi;
* Qualsiasi file con il suffisso .nmconnection può essere utilizzato da **NetworkManager**.

I nomi dei titoli di **connessione** possono contenere queste coppie chiave-valore comuni:

| nome della chiave | descrizione                                                                                                                                                                 |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| id                | L'alias di con-name, il cui valore è una stringa.                                                                                                                           |
| uuid              | Identificatore univoco universale, il cui valore è una stringa.                                                                                                             |
| type              | Il tipo di connessione, i cui valori possono essere ethernet, bluetooth, vpn, vlan e così via. È possibile utilizzare `man nmcli` per visualizzare tutti i tipi supportati. |
| interface-name    | Il nome dell'interfaccia di rete a cui è legata la connessione, il cui valore è una stringa.                                                                                |
| timestamp         | Timestamp Unix, in secondi. Il valore è il numero di secondi dal 1° gennaio 1970.                                                                                           |
| autoconnect       | Se si avvia automaticamente all'avvio del sistema. Il valore è di tipo Booleano.                                                                                            |

i nomi dei titoli **ethernet** possono contenere queste coppie chiave-valore comuni:

| nome della chiave | descrizione                                                                                                                                                                                                                                                                                                                                                                                                |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| mac-address       | Indirizzo fisico MAC.                                                                                                                                                                                                                                                                                                                                                                                      |
| mtu               | Maximum Transmission Unit.                                                                                                                                                                                                                                                                                                                                                                                 |
| auto-negotiate    | Se negoziare automaticamente. Il valore è di tipo Booleano.                                                                                                                                                                                                                                                                                                                                                |
| duplex            | I valori possono essere half (half-duplex), full (full-duplex)                                                                                                                                                                                                                                                                                                                                             |
| speed             | Specificare la velocità di trasmissione della scheda di rete. 100 è 100Mbit/s. Se **auto-negotiate=false**, devono essere impostate le chiavi **speed** e la chiave **duplex**; se **auto-negotiate=true**, la velocità utilizzata è quella negoziata e la scrittura qui non ha effetto (questo è applicabile solo alla specifica BASE-T 802.3); se non è zero, la chiave **duplex** deve avere un valore. |

i nomi dei titoli **ipv4** possono contenere queste coppie chiave-valore comuni:

| nome della chiave | descrizione                                                                                                                     |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| addresses         | Indirizzi IP assegnati                                                                                                          |
| gateway           | Gateway (next hop) dell'interfaccia                                                                                             |
| dns               | Server dei nomi di dominio in uso                                                                                               |
| method            | Il metodo da ottenere tramite IP. Il valore è di tipo stringa. Il valore può essere: auto, disabled, link-local, manual, shared |
