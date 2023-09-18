---
title: 4 Configurazione Del Firewall
author: Steven Spencer, Franco Colussi
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.8, 9.2
tags:
  - lxd
  - enterprise
  - sicurezza lxd
---

# Capitolo 4: configurazione del firewall

In questo capitolo è necessario essere root o poter fare `sudo` per diventare root.

Come per qualsiasi server, è necessario assicurarsi che sia sicuro sia dal mondo esterno che sulla propria LAN. Il server di esempio ha solo un'interfaccia LAN, ma è assolutamente possibile avere due interfacce, una per ciascuna delle reti LAN e WAN.

!!! warning "Una nota riguardante Rocky Linux 9.x e `iptables`"

    A partire da Rocky Linux 9.0, `iptables` e tutte le utility associate sono ufficialmente deprecate. Ciò significa che nelle future versioni del sistema operativo scompariranno del tutto. Una versione precedente di questo documento conteneva istruzioni per la configurazione di `iptables`, ma ora è stata rimossa. 
    
    Per tutte le versioni attuali di Rocky Linux, si raccomanda l'uso di `firewalld`.

## Configurazione del firewall - `firewalld`

Per le regole di _firewalld_, è necessario utilizzare [questa procedura di base](../../guides/security/firewalld.md) o avere familiarità con questi concetti. Le nostre ipotesi sono: Rete LAN 192.168.1.0/24 e un bridge chiamato lxdbr0. Per essere chiari, si potrebbero avere molte interfacce sul server LXD, con una magari rivolta verso la WAN. Si creerà anche una zona per le reti bridged e locali. Questo solo per chiarezza di zona. Gli altri nomi delle zone non sono applicabili. Questa procedura presuppone che si conoscano già le basi di _firewalld_.

```
firewall-cmd --new-zone=bridge --permanent
```

È necessario ricaricare il firewall dopo aver aggiunto una zona:

```
firewall-cmd --reload
```

Si vuole consentire tutto il traffico dal bridge. È sufficiente aggiungere l'interfaccia e modificare il target da "default" a "ACCEPT":

!!! warning "Attenzione"

    La modifica del target di una zona `firewalld` deve essere fatta con l'opzione `--permanent`, quindi tanto vale inserire questo flag anche negli altri comandi e rinunciare all'opzione `--runtime-to-permanent`.

!!! Note "Nota"

    Se si desidera creare una zona che consenta tutti gli accessi all'interfaccia o alla sorgente, ma non si vuole specificare alcun protocollo o servizio, è necessario cambiare l'obiettivo da "default" ad "ACCEPT". Lo stesso vale per "DROP" e "REJECT" per un particolare blocco IP per il quale sono state create zone personalizzate. Per essere chiari, la zona "drop" si occuperà di questo aspetto, a patto che non si utilizzi una zona personalizzata.

```
firewall-cmd --zone=bridge --add-interface=lxdbr0 --permanent
firewall-cmd --zone=bridge --set-target=ACCEPT --permanent
```
Supponendo che non ci siano errori e che tutto funzioni ancora, è sufficiente ricaricare:

```
firewall-cmd --reload
```
Se ora si elencano le regole con `firewall-cmd --zone=bridge --list-all` si vedrà:

```
bridge (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces: lxdbr0
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
Si noti che si desidera consentire anche l'interfaccia locale. Anche in questo caso, le zone incluse non hanno un nome appropriato. Creare una zona e utilizzare l'intervallo IP di origine per l'interfaccia locale per garantire l'accesso:

```
firewall-cmd --new-zone=local --permanent
firewall-cmd --reload
```
Aggiungere gli IP di origine per l'interfaccia locale e modificare la destinazione in "ACCEPT":

```
firewall-cmd --zone=local --add-source=127.0.0.1/8 --permanent
firewall-cmd --zone=local --set-target=ACCEPT --permanent
firewall-cmd --reload
```
Procedere con l'elenco della zona "local" per assicurarsi che le regole siano presenti con `firewall-cmd --zone=local --list all`, che visualizzerà:

```
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

Si vuole consentire SSH dalla nostra rete fidata. In questo caso utilizzeremo gli IP di origine e la zona "trusted" integrata. L'obiettivo di questa zona è già "ACCEPT" per impostazione predefinita.

```
firewall-cmd --zone=trusted --add-source=192.168.1.0/24
```
Aggiungere il servizio alla zona:

```
firewall-cmd --zone=trusted --add-service=ssh
```
Se tutto funziona, spostare le regole su permanente e ricaricarle:

```
firewall-cmd --runtime-to-permanent
firewall-cmd --reload
```
L'elenco della zona "fidata" visualizzerà:

```
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

Per impostazione predefinita, la zona "pubblica" è nello stato abilitato e ha SSH consentito. Per motivi di sicurezza, non si vuole che SSH sia consentito nella zona "pubblica". Assicurarsi che le zone siano corrette e che l'accesso al server avvenga tramite uno degli IP della LAN (nel nostro esempio). Se non lo verificate prima di continuare, potreste rimanere bloccati fuori dal server. Quando si è sicuri di avere accesso dall'interfaccia corretta, rimuovere SSH dalla zona "pubblica":

```
firewall-cmd --zone=public --remove-service=ssh
```

Verificate l'accesso e assicuratevi di non essere bloccati. In caso contrario, spostare le regole su permanenti, ricaricare ed eliminare la zona "pubblica" per garantire la rimozione di SSH:

```
firewall-cmd --runtime-to-permanent
firewall-cmd --reload
firewall-cmd --zone=public --list-all
```

Potrebbero esserci altre interfacce da considerare sul vostro server. È possibile utilizzare le zone integrate, ove opportuno, ma se i nomi non appaiono logici, è possibile aggiungere zone. Ricordate che se non ci sono servizi o protocolli che dovete consentire o rifiutare in modo specifico, dovrete cambiare il target di zona. Se è possibile utilizzare le interfacce, come nel caso del bridge, è possibile farlo. Se avete bisogno di un accesso più granulare ai servizi, utilizzate invece gli IP di origine.
