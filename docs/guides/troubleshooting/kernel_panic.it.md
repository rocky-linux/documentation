---
title: Come affrontare il kernel panic
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.4
tags:
  - kernel
  - kernel panic
  - rescue
---

## Introduzione

A volte l'installazione del kernel non va a buon fine e bisogna tornare indietro.

Questo può avvenire per varie ragioni, come lo spazio insufficiente nella partizione `/boot`, un'installazione interrotta o un problema con un'applicazione di terze parti.

Per fortuna è sempre possibile fare qualcosa per risolvere la situazione.

## Provare a riavviare con il kernel precedente

La prima cosa da provare è riavviare con il kernel precedente.

- Riavviare il sistema.
- Quando si ha raggiunto la schermata di boot GRUB 2, spostare la selezione alla voce del menù corrispondente al kernel precedente e premere il tasto `enter`.

Una volta che il sistema si è riavviato lo si può riparare.

Se il sistema non si avvia, provare la **rescue mode** (vedere sopra).

## Disinstallare il kernel danneggiato

Il modo più facile per fare questo è disinstallare la versione del kernel che non funziona e poi reinstallarla.

!!! Note

````
Non è possibile rimuovere un kernel in esecuzione. 

Per visualizzare la versione del kernel attualmente in esecuzione:

```bash
uname -r
```
````

Per vedere la lista dei kernel installati:

```bash
dnf list installed kernel\* | sort -V
```

Tuttavia il seguente comando potrebbe essere più pratico visto che restituisce i pacchetti con diverse versioni installate:

```bash
dnf repoquery --installed --installonly
```

Per rimuovere un kernel specifico si può usare `dnf` specificando la versione del kernel che si ha recuperato prima:

```bash
dnf remove kernel-core-<version>
```

Esempio:

```bash
dnf remove kernel-5.14.0-427.20.1.el9_4.x86_64
```

oppure utilizzare il comando `dnf repoquery`:

```bash
dnf remove $(dnf repoquery --installed --installonly --latest=1)
```

Ora si può aggiornare il sistema provando a reinstallare la versione più recente del kernel.

```bash
dnf update
```

Riavviare e vedere se il nuovo kernel funziona.

## Modalità Rescue

La modalità rescue corrisponde alla vecchia modalità a utente singolo.

!!! Note

```
Per accedere alla modalità rescue, è necessario fornire la password di root.
```

Per accedere alla modalità rescue, il modo più semplice è selezionare la riga che inizia con `0-rescue-*` nel menu di grub.

Un altro modo è quello di modificare una qualsiasi riga del menu di grub (premendo il tasto “e”) e aggiungere `systemd.unit=rescue.target` alla fine della riga che inizia con `linux` e poi premere `ctrl+x` per avviare il sistema in modalità rescue.

!!! Note

```
A questo punto ci si trova in modalità qwerty.
```

È possibile riparare il sistema una volta che si è in modalità rescue e si è inserita la password di root.

Per questo, potrebbe essere necessario configurare un indirizzo IP temporaneo usando `ip ad add ...` (vedere il capitolo sulla rete della nostra guida all'amministrazione).

## Ultima possibilità: Modalità Rescue di Anaconda

Se nessuno dei metodi sopra descritti funziona, è possibile avviare il sistema dalla ISO di installazione e ripararlo.

La presente documentazione non tratta questo metodo.

## Manutenzione di Sistema

### Ripulire le vecchie versioni del kernel

È possibile rimuovere i vecchi pacchetti del kernel installati, mantenendo solo l'ultima versione e la versione del kernel in esecuzione:

```bash
dnf remove --oldinstallonly
```

### Limitazione del numero di versioni del kernel installate

È possibile limitare il numero di versioni del kernel modificando il file \`/etc/yum.conf' e impostando la variabile **installonly_limit**:

```text
installonly_limit=3
```

!!! Note

```
È necessario conservare sempre almeno l'ultima versione del kernel e una versione di backup.
```
