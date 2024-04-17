---
title: rpaste - Strumento Pastebin
author: Steven Spencer, Franco Colussi
contributors:
tags:
  - rpaste
  - Mattermost
  - pastebin
---

# Introduzione a `rpaste`

`rpaste` è uno strumento per condividere codice, output di log e altri testi molto lunghi. È un pastebin creato dagli sviluppatori di Rocky Linux. Questo strumento è utile quando si deve condividere qualcosa pubblicamente, ma non si vuole dominare il feed con il proprio testo. Questo è particolarmente importante quando si usa Mattermost, che ha collegamenti con altri servizi IRC. Lo strumento `rpaste` può essere installato su qualsiasi sistema Rocky Linux. Se il vostro computer desktop non è Rocky Linux o se semplicemente non volete installare lo strumento, potete usarlo manualmente, accedendo all'[URL](https://rpa.st) di [pinnwand](https://rpa.st) e incollando l'output del sistema o il testo che volete condividere. `rpaste` consente di creare automaticamente queste informazioni.

## Installazione

Installazione di `rpaste` su Rocky Linux:

```bash
sudo dnf --enablerepo=extras install rpaste
```

## Usi

Per i problemi di sistema più gravi, potrebbe essere necessario inviare tutte le informazioni del sistema in modo che possa essere esaminato per individuare eventuali problemi. Per farlo, eseguire:

```bash
rpaste --sysinfo
```

Che restituirà il link alla pagina del pinnwand:

```bash
Uploading...
Paste URL:   https://rpa.st/2GIQ
Raw URL:     https://rpa.st/raw/2GIQ
Removal URL: https://rpa.st/remove/YBWRFULDFCGTTJ4ASNLQ6UAQTA
```

È quindi possibile rivedere le informazioni in un browser e decidere se tenerle o rimuoverle e ricominciare da capo. Se volete conservarlo, potete copiare l'"Incolla URL" e condividerlo con chi state lavorando o nel feed di Mattermost. Per rimuoverlo, è sufficiente copiare l'"URL di rimozione" e aprirlo nel browser.

È possibile aggiungere contenuti al proprio pastebin inviando il contenuto. Ad esempio, se si volesse aggiungere il contenuto del file `/var/log/messages` del 10 marzo, si potrebbe procedere in questo modo:

```bash
sudo more /var/log/messages | grep 'Mar 10' | rpaste
```

## aiuto `rpaste`

Per ottenere aiuto con il comando, è sufficiente digitare:

```bash
rpaste --help
```

Il risultato è il seguente:

```bash
rpaste: A paste utility originally made for the Rocky paste service

Usage: rpaste [options] [filepath]
       command | rpaste [options]

This command can take a file or standard in as input

Options:
--life value, -x value      Sets the life time of a paste (1hour, 1day, 1week) (default: 1hour)
--type value, -t value      Sets the syntax highlighting (default: text)
--sysinfo, -s               Collects general system information (disables stdin and file input) (default: false)
--dry, -d                   Turns on dry mode, which doesn't paste the output, but shows the data to stdin (default: false)
--pastebin value, -p value  Sets the paste bin service to send to. Current supported: rpaste, fpaste (default: "rpaste")
--help, -h                  show help (default: false)
--version, -v               print the version (default: false)
```

## Conclusioni

A volte è importante condividere una grande quantità di testo quando si lavora su un problema, codice condiviso o testo, ecc. L'uso di `rpaste` eviterà agli altri di dover visualizzare grandi quantità di testo che non sono importanti per loro. È importante anche il galateo della chat di Rocky Linux.
