---
title: Lavorare con Rancher e Kubernetes
author: Antoine Le Morvan
contributors: Steven Spencer, Franco Colussi
update: 22-Feb-2024
tested_with: 9.3
tags:
  - rancher
  - kubernetes
  - containers
  - docker
---

# Lavorare con Rancher e Kubernetes

**Kubernetes** (**K8s**) è un sistema di orchestrazione di container open-source per gestire la distribuzione e la gestione di applicazioni containerizzate.

K8s si è fatto un nome sul mercato, quindi non c'è più bisogno di presentarlo.

I fornitori di cloud hanno reso semplice l'implementazione di piattaforme Kubernetes gestite, ma che dire della creazione e della gestione di un cluster on-premise?

Quanto è facile gestire più cluster, sia on-premise che multi-cloud?

La risposta alle ultime due domande è No. La creazione di un cluster on-premise è difficile e la gestione di un cluster multi-cloud può essere un vero mal di testa.

È qui che entra in gioco l'argomento di questa guida: **Rancher**! Rancher è anche un sistema open-source, che consente l'installazione e l'orchestrazione di diversi cluster multi-cloud o on-premise e fornisce caratteristiche interessanti come un catalogo di applicazioni e una pratica interfaccia web per la visualizzazione delle risorse.

Rancher vi consentirà di distribuire cluster Kubernetes gestiti dai cloud provider, di importare cluster Kubernetes esistenti o di distribuire cluster K3s (in breve, è una versione più leggera di K8s) o cluster K8s.

Questa guida vi aiuterà a scoprire Rancher, a installarlo e ad avviarlo, quindi a creare un cluster Kubernetes on-premise distribuito su server Rocky Linux.

## Impiego di Rancher

L'installazione di Rancher è abbastanza banale se avete installato Docker sul vostro server.

È possibile trovare l'installazione di Docker [qui in gemme](https://docs.rockylinux.org/gemstones/containers/docker/).

Per funzionare su una Rocky 9, Rancher richiede anche il caricamento di modules/run//run/

Un modo per assicurare il caricamento dei moduli necessari durante l'avvio del sistema è quello di creare un file \`/etc/modules-load.d/rancher.conf' con i seguenti contenuti:

```text
ip_tables
ip_conntrack
iptable_filter
ipt_state
```

Il modo più semplice per applicare le modifiche è riavviare il server: `sudo reboot`.

Una volta riavviato, è possibile assicurarsi del corretto caricamento dei moduli grazie al comando `lsmod | grep <module_name>`.

Ora abbiamo un sistema pronto a ricevere il contenitore Rancher:

```bash
docker pull rancher/rancher:latest
docker run -d --name=rancher --privileged --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher:latest
```

!!! NOTE "Nota"

    Se siete curiosi, guardate i log del nuovo container. Si vedrà che è stato appena creato un cluster K3s (con un singolo nodo)! Questo è il modo in cui Rancher funziona nella sua versione standalone.
    
    ![k3s local cluster](img/rancher_k3s_local_cluster.png)

Poiché Rancher è in ascolto sulla porta 443, aprire il firewall per consentire l'accesso dall'esterno:

```bash
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --zone=public --add-service=https
```

Se si accede all'interfaccia web di Rancher appena distribuita, un messaggio informa su come recuperare la password dell'amministratore nei registri del container.

A tal fine, lanciare il seguente comando:

```bash
docker logs rancher  2>&1 | grep "Bootstrap Password:"
```

Si è pronti a connettersi alla webUI di Rancher.

![rancher](img/rancher_login.png)

!!! NOTE "Nota"

    Questa soluzione non è assolutamente pronta per la produzione. Dovrete assicurarvi che il sistema sia altamente disponibile, ma è un buon inizio. Considerate la possibilità di distribuire Rancher su un cluster K8s esistente per ottenere un HA ottimale.

## Kubernetes su server Rocky Linux 9

Rancher offre la sua versione di Kubernetes basata su docker: RKE (Rancher Kubernetes Engine).

Tutto ciò che serve sono diversi server Rocky Linux e il [motore Docker](https://docs.rockylinux.org/gemstones/containers/docker/) installato su di essi.

Non dimenticate che uno dei requisiti di Kubernetes è avere un numero dispari di nodi master (1 o 3, per esempio). Per i nostri test, iniziamo con 3 nodi master e 2 nodi aggiuntivi con il solo ruolo di worker.

Una volta installato Docker sui server, fermare `firewalld` ed eseguire `nftables` su ogni server:

```bash
systemctl stop firewalld
systemctl disable firewalld
systemctl start nftables
systemctl enable nftables
```

Siamo pronti per la creazione del cluster.

### Creazione del cluster

Nell'area di gestione dei cluster, creare un nuovo cluster:

![create cluster](img/rancher_cluster_create.png)

Siete liberi di creare un cluster in un provider Kubernetes ospitato, di effettuare il provisioning di nuovi nodi e di creare un cluster utilizzando RKE2/K3s oppure, nel nostro caso, di utilizzare i nodi esistenti e di creare un cluster utilizzando RKE2/K3s.

Scegliere l'ultima opzione.

Inserire un nome e una descrizione del cluster.

Prendetevi il tempo necessario per scoprire le varie opzioni disponibili prima di avviare la creazione del cluster.

![cluster creation](img/rancher_create_custom_cluster.png)

Una volta creato il cluster, andare alla scheda Registrazione per aggiungere i nostri server:

![registring hosts](img/rancher_hosts_registration.png)

Per prima cosa, selezionare i vari ruoli del nodo che si sta aggiungendo e copiare la riga di comando necessaria. Se il cluster utilizza un certificato autofirmato, selezionare la casella appropriata.

Andare al nodo che si desidera aggiungere alla configurazione e incollare il comando copiato in precedenza.

Dopo qualche minuto, il server verrà aggiunto al cluster e, se è il primo server e ha tutti i ruoli, il cluster sarà disponibile nell'interfaccia web.

Una volta aggiunti i 5 server, si dovrebbe ottenere un risultato simile a questo:

![clusters hosts](img/rancher_cluster_ready.png)

## Conclusione

Congratulazioni! Avete installato il vostro primo cluster Kubernetes in pochi minuti/ore, grazie alle funzionalità di Rancher.

Se siete nuovi a Kubernetes, potete già essere orgogliosi di voi stessi: siete sulla strada giusta. Ora avete tutto ciò che vi serve per continuare a scoprire Kubernetes.
