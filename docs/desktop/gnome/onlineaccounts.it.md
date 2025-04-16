---
title: GNOME Online Accounts
author: Ezequiel Bruni
contributors: Spencer Steven
---

## Introduzione

A prima vista, la funzione Account online di GNOME sembra senza pretese, ma è piuttosto potente. Permette di accedere in pochi minuti alla posta elettronica, alle attività, ai file nel cloud storage, ai calendari online e molto altro ancora dalle applicazioni desktop.

In questa breve guida vedremo come iniziare.

## Presupposti

Questa guida presuppone che si disponga di quanto segue:

- Rocky Linux con l'ambiente desktop GNOME installato.

## Come aggiungere i vostri account online

Aprite la panoramica delle attività di GNOME nell'angolo in alto a sinistra (o con i tasti ++meta++ o ++win++) e cercate Account online. In alternativa, è possibile aprire il pannello Impostazioni e trovare Account online sul lato sinistro.

In ogni caso, finirete qui:

![a screenshot of the GNOME Online Accounts settings panel](images/onlineaccounts-01.png)

!!! note "Nota"

```
Potrebbe essere necessario fare clic su un'icona a tre puntini verticali per accedere a tutte le opzioni mostrate qui:

![a screenthot of the Online Accounts panel featuring the three-vertical-dots icon at the bottom](images/onlineaccounts-02.png)
```

Per aggiungere un account, fare clic su una delle opzioni. Per l'account Google, viene richiesto di accedere a Google con il browser e di autorizzare GNOME ad accedere a tutti i dati. Per servizi come Nextcloud, verrà visualizzato un modulo di accesso come quello riportato di seguito:

![a screenshot showing the login form for Nextcloud](images/onlineaccounts-03.png)

Completate le informazioni pertinenti e GNOME si occuperà del resto.

## Tipi di account supportati da GNOME

Come si può vedere nelle schermate, Google, Nextcloud, Microsoft, Microsoft Exchange, Fedora, IMAP/SMTP e Kerberos sono tutti in qualche modo supportati. Tuttavia, queste integrazioni non sono uguali.

Gli account Google sono i più funzionali, anche se Microsoft Exchange e Nextcloud non sono da meno.

Per facilitare la conoscenza di ciò che è supportato o meno, ecco una tabella che l'autore ha spudoratamente rubato dalla documentazione ufficiale di GNOME:

| **Provider**       | **Mail** | **Calendario** | **Contatti** | **Mappe** | **Foto** | **File** | **Ticketing** |
| ------------------ | -------- | -------------- | ------------ | --------- | -------- | -------- | ------------- |
| Google             | sì       | sì             | sì           |           | sì       | sì       |               |
| Microsoft          | sì       |                |              |           |          |          |               |
| Microsoft Exchange | sì       | sì             | sì           |           |          |          |               |
| Nextcloud          |          | sì             | sì           |           |          | sì       |               |
| IMAP e SMTP        | sì       |                |              |           |          |          |               |
| Kerberos           |          |                |              |           |          |          | sì            |

!!! note "Nota"

```
Sebbene i "compiti" non siano elencati nella tabella precedente, sembra che siano supportati, almeno per Google. I test per questa guida hanno rivelato che se si installa il to-do manager Endeavour (disponibile tramite Flathub) su Rocky Linux e si dispone già di un account Google collegato a GNOME, le attività verranno importate automaticamente.
```

## Conclusione

Anche se in alcuni casi è possibile utilizzare le versioni web app di alcuni di questi servizi o client di terze parti, GNOME consente di integrare facilmente molte delle funzionalità più importanti direttamente nel proprio desktop. Basta iscriversi e partire.

Se qualche servizio sembra essere mancante, si può consultare il [forum della comunità GNOME](https://discourse.gnome.org) e farglielo sapere.
