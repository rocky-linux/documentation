---
title: 4 Configurazione Del Firewall
author: Spencer Steven
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - enterprise
  - incus security
---

Nel corso di questo capitolo, è necessario essere l'utente root o essere in grado di eseguire con i privilegi di root con sudo.

Come per qualsiasi server, è necessario assicurarsi che sia sicuro dal mondo esterno e dalla LAN.
Il server di esempio ha solo un'interfaccia LAN, ma è possibile avere due interfacce, ciascuna rivolta verso le reti LAN e WAN.

## Impostazione del Firewall – `firewalld`

Per le regole del _firewalld_, è necessario utilizzare [questa procedura di base](../../guides/security/firewalld.md) o avere familiarità con questi concetti. I presupposti sono una rete LAN di 192.168.1.0/24 e un bridge chiamato incusbr0. Per essere chiari, si possono avere molte interfacce sul server Incus, di cui una rivolta verso la WAN. Verrà inoltre creata una zona per le reti bridged e local. Questo solo per chiarezza di zona. Gli altri nomi di zona non si applicano. Questa procedura presuppone che si conoscano già le basi di _firewalld_.

```bash
firewall-cmd --new-zone=bridge --permanent
```

È necessario ricaricare il firewall dopo aver aggiunto una zona:

```bash
firewall-cmd --reload
```

Si vuole consentire tutto il traffico dal bridge. È sufficiente aggiungere l'interfaccia e modificare il target da “default” a “ACCEPT”:

!!! warning "Attenzione"

```
La modifica del target di una zona `firewalld' deve essere fatta con l'opzione `--permanent', quindi è meglio inserire questo flag negli altri comandi e rinunciare all'opzione `--runtime-to-permanent'.
```

!!! note "Nota"

```
Se si deve creare una zona in cui si desidera consentire tutti gli accessi all'interfaccia o alla sorgente, ma non si vuole specificare alcun protocollo o servizio, è necessario modificare l'obiettivo da “default” ad “ACCEPT”. Lo stesso vale per “DROP” e “REJECT” per un particolare blocco IP per il quale si dispone di zone personalizzate. La zona “drop” se ne occuperà finché non si utilizza una zona personalizzata.
```

```bash
firewall-cmd --zone=bridge --add-interface=incusbr0 --permanent
firewall-cmd --zone=bridge --set-target=ACCEPT --permanent
```

Supponendo che non ci siano errori e che tutto funzioni ancora, riavviare il sistema:

```bash
firewall-cmd --reload
```

Se ora si elencano le regole con `firewall-cmd --zone=bridge --list-all` si vedrà:

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

Si noti che si desidera consentire anche l'interfaccia locale. Anche in questo caso, le zone incluse non hanno un nome appropriato. Creare una zona e utilizzare l'intervallo IP di origine per l'interfaccia locale per garantire l'accesso:

```bash
firewall-cmd --new-zone=local --permanent
firewall-cmd --reload
```

Aggiungere gli IP di origine per l'interfaccia locale e modificare la destinazione in "ACCEPT":

```bash
firewall-cmd --zone=local --add-source=127.0.0.1/8 --permanent
firewall-cmd --zone=local --set-target=ACCEPT --permanent
firewall-cmd --reload
```

Procedere con l'elenco della “local” zone per assicurarsi che le regole siano presenti con \`firewall-cmd --zone=local --list che mostrerà:

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

Si vuole consentire SSH dalla nostra rete fidata. A tal fine, consentire agli IP di origine di utilizzare la zona “trusted” integrata. Per impostazione predefinita, l'obiettivo di questa zona è “ACCEPT”.

```bash
firewall-cmd --zone=trusted --add-source=192.168.1.0/24
```

Aggiungere il servizio alla zona:

```bash
firewall-cmd --zone=trusted --add-service=ssh
```

Se tutto funziona, spostare le regole su permanente e ricaricarle:

```bash
firewall-cmd --runtime-to-permanent
firewall-cmd --reload
```

L'elenco della zona "fidata" visualizzerà:

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

La zona “public” è abilitata per impostazione predefinita e l'SSH è consentito. Per motivi di sicurezza, non si vuole che SSH sia consentito nella zona "pubblica". Assicurarsi che le zone siano corrette e che l'accesso al server avvenga tramite uno degli IP della LAN (nel nostro esempio). Se non lo verificate prima di continuare, potreste rimanere bloccati fuori dal server. Quando si è sicuri di avere accesso dall'interfaccia corretta, rimuovere SSH dalla zona "pubblica":

```bash
firewall-cmd --zone=public --remove-service=ssh
```

Verificate l'accesso e assicuratevi di non essere bloccati. In caso contrario, spostare le regole su permanenti, ricaricare ed eliminare la zona "pubblica" per garantire la rimozione di SSH:

```bash
firewall-cmd --runtime-to-permanent
firewall-cmd --reload
firewall-cmd --zone=public --list-all
```

Potrebbero esserci altre interfacce da considerare sul vostro server. È possibile utilizzare le zone integrate, ove opportuno, ma se i nomi non sembrano sufficienti, è possibile aggiungere zone.
Ricordate che se non ci sono servizi o protocolli che dovete consentire o rifiutare in modo specifico, dovrete cambiare il target di zona. È possibile farlo se funziona l'uso delle interfacce, come nel caso del bridge. Se avete bisogno di un accesso più granulare ai servizi, utilizzate invece gli IP di origine.
