---
title: Desktop Sharing via RDP
author: Ezequiel Bruni
contributors: Steven Spencer, Ganna Zhyrnova
---

## Introduzione

Se volete condividere il vostro desktop (Gnome) su Rocky Linux o accedere ad altri desktop condivisi, questa guida fa per voi.

Per i principianti, si utilizzerà RDP. RDP è l'acronimo di Remote Desktop Protocol (Protocollo Desktop Remoto) e fa esattamente ciò che implica: consente di visualizzare e interagire con i computer da lontano, il tutto con un'interfaccia grafica. Tuttavia, per configurarlo, è necessario immergersi rapidamente nella riga di comando.

!!! note "Nota"

```
Per impostazione predefinita, Rocky Linux consente di condividere il desktop tramite un altro protocollo VNC. VNC è abbastanza utile, ma RDP di solito offre un'esperienza molto più fluida e può gestire risoluzioni di monitor diverse.
```

## Prerequisiti

In questa guida si presuppone che siano già state configurate le seguenti operazioni:

 - Rocky Linux con Gnome
 - Flatpak e Flathub installati e funzionanti
 - Un account utente non root
 - Accesso come amministratore o sudo e disponibilità a incollare comandi nel terminale
 - Il server X (per condividere il desktop)

!!! info "Informazione"

```
Sono in corso alcuni progetti per rendere compatibili il display server Wayland e RDP, e le versioni più recenti di Gnome sono dotate di un server RDP integrato che fa il suo dovere. Tuttavia, la versione di Rocky Linux di Gnome non ha questa funzione, quindi è molto più semplice alimentare la sessione RDP con x11.
```

## Condividere il desktop Rocky Linux Gnome con RDP

È necessario un server RDP per rendere il desktop Rocky Linux accessibile da remoto. Per i nostri scopi, 'xrdp' sarà più che sufficiente. Tuttavia, è necessario utilizzare il terminale, perché si tratta di un programma solo CLI.

!!! info "Informazione"

````
Il pacchetto xrdp si trova in [EPEL repository](https://wiki.rockylinux.org/rocky/repo/#community-approved-repositories), che fornisce ricostruzioni di pacchetti Fedora per ogni Enterprise Linux supportato. Se non è stato abilitato, usare i seguenti comandi. Dovete anche abilitare il CRB](https://wiki.rockylinux.org/rocky/repo/#notes-on-epel) (chiamato 'PowerTools' in Rocky Linux 8) prima di aggiungere il repository EPEL.

In Rocky Linux 8, utilizzate questi comandi per aggiungere il repository EPEL:

```bash
sudo dnf config-manager --set-enabled powertools
sudo dnf install epel-release
```

In Rocky Linux 9, utilizzate questi comandi per aggiungere il repository EPEL:

```bash
sudo dnf config-manager --set-enabled crb
sudo dnf install epel-release
```
````

Dopo aver aggiunto il repository EPEL (o se lo avete già aggiunto), usate il seguente comando per installare xrdp:

```bash
sudo dnf install xrdp
```

Una volta installato, è necessario abilitare il servizio:

```bash
sudo systemctl enable --now xrdp
```

Se tutto va bene, il server RDP dovrebbe essere installato, abilitato e funzionante. Tuttavia, non è ancora possibile connettersi; prima è necessario aprire la porta giusta sul firewall.

Se volete saperne di più su come funziona l'applicazione firewall di Rocky Linux, `firewalld`, consultate la nostra [guida per principianti a `firewalld`](../../guides/security/firewalld-beginners.md). Se si vuole andare avanti, eseguire questi comandi:

```bash
sudo firewall-cmd --zone=public --add-port=3389/tcp --permanent
sudo firewall-cmd --reload
```

Per i principianti, questi comandi aprono la porta RDP nel firewall in modo da poter accettare le connessioni RDP in entrata. Quindi, riavviare il firewall per applicare le modifiche. Se lo desiderate, potete riavviare il PC per sicurezza.

Se non si desidera riavviare il sistema, è necessario disconnettersi. RDP utilizza le credenziali dell'account utente per la sicurezza. Non è possibile effettuare l'accesso da remoto mentre si è già connessi al desktop in locale. Almeno, non sullo stesso account utente.

!!! info "Informazione"

```
È anche possibile utilizzare l'applicazione Firewall per gestire `firewalld` e aprire tutte le porte desiderate. Controllate questo spazio per un link alla mia guida all'installazione e all'uso dell'applicazione Firewall.
```

## Accesso al desktop Rocky Linux e/o ad altri desktop con RDP

Si è visto come installare un server RDP e ora è necessaria un'applicazione client RDP. Su Windows, l'applicazione Connessione Desktop Remoto svolge egregiamente il suo compito. Se si desidera accedere alla macchina Rocky Linux da un'altra macchina Linux, è necessario installare un'opzione di terze parti.

Raccomando vivamente Remmina per Gnome. Non è complesso da usare, è stabile e generalmente funziona.

Se avete installato Flatpak/Flathub, potete aprire l'applicazione Software e cercare Remmina.

![The Gnome Software app on the Remmina page](images/rdp_images/01-remmina.png)

È sufficiente installarlo e avviarlo. Questa è la procedura per aggiungere una connessione RDP in Remmina, ma è simile a quella di quasi tutte le altre applicazioni client RDP.

Premete il pulsante più nell'angolo in alto a sinistra per aggiungere una connessione. Nel campo Nome, assegnare alla connessione un nome a piacere e inserire l'indirizzo IP del computer remoto, insieme al nome utente e alla password dell'account utente remoto. Ricordate che se i vostri computer sono sulla stessa rete, dovete usare il loro indirizzo IP locale, non quello che vedreste su un sito come "whatsmyip.com".

![The Remmina connection profile form](images/rdp_images/02-remmina-config.png)

Se i computer non sono sulla stessa rete, spero che sappiate come fare il port forwarding o che il computer remoto abbia un IP statico. Tuttavia, ciò esula dallo scopo di questo documento.

Scorrete verso il basso per scoprire opzioni come il supporto multi-monitor, le risoluzioni personalizzate e altro ancora. Inoltre, l'opzione "Tipo di connessione di rete" del client RDP consente di bilanciare l'utilizzo della larghezza di banda con la qualità dell'immagine.

Se i computer sono sulla stessa rete, utilizzare la rete LAN per ottenere la migliore qualità.

Quindi, fare clic su ++"Salva "++ e ++"Connetti "++.

Ecco come si presenta il client Windows Remote Desktop Connection. L'autore ha scritto questo documento sul suo server locale Rocky Linux con RDP.

![A screenshot of my docs-writing environment, at a 5120x1440p resolution](images/rdp_images/03-rdp-connection.jpg)

## Conclusione

È sufficiente sapere questo per eseguire RDP su Rocky Linux e condividerlo sul desktop. Questa soluzione funziona se avete bisogno di accedere solo ad alcuni file e applicazioni in remoto.
