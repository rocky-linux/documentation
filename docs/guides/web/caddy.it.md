---
title: Server Web Caddy
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 9.3
tags:
  - web
---

# Come installare il server web Caddy più recente su Rocky Linux

## Introduzione

_Caddy_ è un server web progettato per le applicazioni web moderne. Caddy è semplice da configurare e dispone della funzione Let's Encrypt automatica, in modo che i vostri siti web siano sempre sicuri per impostazione predefinita. È il server web preferito dall'autore.

Ecco una breve panoramica delle caratteristiche di Caddy:

- Un server web di base
- Un reverse proxy per dirigere il traffico verso più siti
- Moduli per molti carichi di lavoro, tra cui TCP, SSH e altro ancora
- Un bilanciatore di carico integrato per gestire il traffico verso più siti web
- Supporto a Let's Encrypt integrato e automatizzato
- Un'API per riconfigurare il server in modo programmatico
- Supporto a PHP FastCGI
- E IPv6

## Prerequisiti e presupposti

Sono necessari:

- Una macchina o un server Rocky Linux connesso a internet.
- Una familiarità di base con la riga di comando.
- La possibilità di eseguire comandi come utente root o con `sudo`.
- Un editor di testo a tua scelta, sia grafico che a riga di comando. Per questo tutorial, l'autore utilizza `vim`.
- Un nome di dominio o un altro hostname che punta all'indirizzo IP pubblico del server.

## Installazione di Caddy

Innanzitutto, assicuratevi che il vostro computer disponga degli ultimi aggiornamenti:

```bash
sudo dnf update
```

Quindi, installare il repository software `epel-release`:

```bash
sudo dnf install -y epel-release
```

Quindi, installare il server web `caddy`:

```bash
sudo dnf install -y caddy
```

## Configurare il firewall

Se si tenta di visualizzare una pagina Web con l'indirizzo IP o il nome di dominio della propria macchina da un altro computer, probabilmente non si otterrà nulla. Questo sarà il caso se avete un firewall attivo e funzionante.

Per aprire le porte necessarie a "vedere" le pagine web, si utilizzerà il firewall integrato di Rocky Linux, `firewalld`. Il comando di `firewalld` per farlo è `firewall-cmd`.

Per aprire i servizi `http` e `https`, i servizi che gestiscono le pagine web, eseguire:

```bash
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --permanent --zone=public --add-service=https
```

Per capire meglio:

- L'opzione `--permanent` indica al firewall di applicare questa configurazione a ogni riavvio del firewall e al riavvio del server.
- `--zone=public` indica al firewall di consentire le connessioni in entrata a questa porta da parte di tutti.
- Infine, `--add-service=http` e `--add-service=https` indicano a `firewalld` di passare tutto il traffico HTTP e HTTPS al server.

Queste configurazioni non avranno effetto finché non forzerete la questione. Per farlo, occorre indicare a `firewalld` di ricaricare le sue configurazioni:

```bash
sudo firewall-cmd --reload
```

!!! Note "Nota"

````
Ora, c'è una piccolissima possibilità che questo non funzioni. In questi rari casi, fate in modo che `firewalld` esegua i vostri ordini con il vecchio spegnimento-e-riaccensione.

```bash
systemctl restart firewalld
```
````

Per garantire l'autorizzazione delle porte, eseguire `firewall-cmd --list-all`. Un firewall correttamente configurato avrà un aspetto simile a questo:

```bash
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp9s0
  sources:
  services: cockpit dhcpv6-client ssh http https
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

Dovrebbe essere tutto ciò di cui avete bisogno, a livello di firewall.

## Configurare Caddy

A differenza dei server web tradizionali come Apache e Nginx, il formato di configurazione di Caddy è molto più semplice. Sono finiti i tempi in cui si dovevano configurare i dettagli, come il modello di threading del server web o i certificati SSL, a meno che non si volesse farlo.

Per modificare il file di configurazione di Caddy:

```bash
vim /etc/caddy/Caddyfile
```

Una configurazione statica minima del server web può essere simile a questa:

```bash
example.com {
    root * /usr/share/caddy/example.com
    file_server
}
```

Sostituire "example.com" con un nome di host che punta al proprio server.

È inoltre necessario aggiungere un sito web nella cartella della directory "root" di Caddy. Per semplicità, aggiungete un sito web statico di una pagina:

```bash
mkdir -p /usr/share/caddy/example.com
echo "<h1>Hi!</h1>" >> /usr/share/caddy/example.com/index.html
```

Successivamente, attivare il servizio systemd di Caddy:

```bash
systemctl enable --now caddy
```

Entro un minuto, Caddy otterrà i certificati SSL da Let's Encrypt. A questo punto, è possibile visualizzare il sito web appena impostato in un browser:

![Caddy serve il nostro sito web dimostrativo](../images/caddy_esempio.png)

Dovrebbe avere un lucchetto SSL che dovrebbe funzionare in ogni browser moderno, e non solo, anche una valutazione A+ al [Qualys SSL Server Test](https://www.ssllabs.com/ssltest/).

## Opzionale: PHP FastCGI

Come accennato in precedenza, Caddy supporta il supporto FastCGI per PHP. La buona notizia è che, a differenza di Apache e Nginx, Caddy gestisce automaticamente le estensioni dei file PHP.

Per installare PHP, aggiungere prima il repository Remi (nota: se si utilizza Rocky Linux 8.x, si deve sostituire 8 dopo "release-"):

```bash
dnf install https://rpms.remirepo.net/enterprise/remi-release-9.rpm
```

Successivamente, occorre installare PHP (nota: se si utilizza un'altra versione di PHP, sostituire la versione desiderata al posto di php81):

```bash
dnf install -y php81-php-fpm
```

Se sono necessari altri moduli PHP (ad esempio, GD), aggiungerli al comando precedente.

Quindi, occorre configurare PHP per l'ascolto su un socket TCP:

```bash
vim /etc/opt/remi/php81/php-fpm.d/www.conf
```

Quindi, trovare la riga:

```bash
listen = /var/opt/remi/php81/run/php-fpm/www.sock
```

Sostituirla con questa:

```bash
listen = 127.0.0.1:9000
```

Quindi salvare e uscire dal file www\.conf e aprire il file Caddy:

```bash
vim /etc/caddy/Caddyfile
```

Passare al blocco server creato in precedenza:

```bash
example.com {
    root * /usr/share/caddy/example.com
    file_server
}
```

Aggiungere la seguente riga dopo la riga "file_server":

```bash
    php_fastcgi 127.0.0.1:9000
```

Il blocco del server abilitato a PHP avrà questo aspetto:

```bash
example.com {
    root * /usr/share/caddy/example.com
    file_server
    php_fastcgi 127.0.0.1:9000
}
```

Quindi salvare e uscire dal Caddyfile e riavviare Caddy:

```bash
systemctl restart caddy
```

Per verificare se PHP funziona, aggiungiamo un semplice file PHP:

```bash
echo "<?php phpinfo(); ?>" >> /usr/share/caddy/rockyexample.duckdns.org/phpinfo.php
```

Aprite il vostro browser sul file creato e vi verranno presentate le informazioni su PHP:

![Caddy serve il nostro file PHP](../images/caddy_php.png)

## Conclusione

L'installazione e configurazione di base di Caddy è incredibilmente facile. Sono finiti i tempi in cui si passavano ore a configurare Apache. Sì, Nginx è certamente un miglioramento, ma manca ancora di funzionalità moderne ma essenziali come Let's Encrypt e il supporto per Kubernetes ingress che Caddy integra, mentre su Nginx (e Apache) è necessario aggiungerle separatamente.

Uso Caddy dal 2019 come server web di riferimento ed è davvero ottimo. In effetti, ogni volta che ho a che fare con Apache, Nginx o IIS, è quasi come prendere una macchina del tempo e tornare al 2010 o prima.
