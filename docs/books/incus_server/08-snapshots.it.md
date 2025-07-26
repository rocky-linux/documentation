---
title: 8 Container Snapshots
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - enterprise
  - incus snapshots
---

In questo capitolo, i comandi devono essere eseguiti come utente non privilegiato (“incusadmin” se li avete seguiti dall'inizio di questo libro).

I container snapshot e un server snapshot (di cui si parlerà più avanti) sono gli aspetti più critici della gestione di un server Incus in produzione. Le snapshot garantiscono un ripristino rapido. È buona prassi usarli come misura salvavita quando si aggiorna il software principale che gira su un particolare container. Se durante l'aggiornamento accade qualcosa che interrompe l'applicazione, è sufficiente ripristinare lo snapshot per tornare operativi con pochi secondi di inattività.

L'autore ha utilizzato i container Incus per i server PowerDNS rivolti al pubblico e l'aggiornamento di queste applicazioni è diventato meno problematico, grazie alla creazione di snapshots prima di ogni aggiornamento.

È possibile eseguire lo snapshot di un container anche quando è in esecuzione.

## Il processo di snapshot

Iniziate ottenendo un'istantanea del container ubuntu-test con questo comando:

```bash
incus snapshot create ubuntu-test ubuntu-test-1
```

Qui si nomina lo snapshot “ubuntu-test-1”, ma si può nominarlo in qualsiasi modo. Per assicurarsi di avere uno snapshot, eseguire un `incus info` del container:

```bash
incus info ubuntu-test
```

Si è già vista una schermata informativa. Se si scorre fino in fondo, ora si vede:

```bash
Snapshots:
  ubuntu-test-1 (taken at 2021/04/29 15:57 UTC) (stateless)
```

Successo! Il nostro snapshot è in posizione.

Entrate nel container ubuntu-test:

```bash
incus shell ubuntu-test
```

Creare un file vuoto con il comando _touch_:

```bash
touch this_file.txt
```

Uscite dal container.

Prima di ripristinare il container com'era prima della creazione del file, il modo più sicuro per farlo, soprattutto se ci sono state molte modifiche, è quello di arrestarlo prima:

```bash
incus stop ubuntu-test
```

Ripristino:

```bash
incus snapshot restore ubuntu-test ubuntu-test-1
```

Avviare nuovamente il container:

```bash
incus start ubuntu-test
```

Se si ritorna al container e si controlla di nuovo, il “this_file.txt” creato non c'è più.

Quando non si ha più bisogno di uno snapshot, è possibile cancellarlo:

```bash
incus snapshot delete ubuntu-test ubuntu-test-1
```

!!! warning "Attenzione"

````
È necessario eliminare in modo permanente le snapshot mentre il container è in esecuzione. Perché? Il comando _incus delete_ funziona anche per cancellare l'intero container. Se per sbaglio si preme invio dopo “ubuntu-test” nel comando precedente, E se il container è stato arrestato, il container viene cancellato. Volevo solo informarvi che non viene fornito alcun avviso. Fa semplicemente quello che si chiede.

Se il contenitore è in esecuzione, tuttavia, verrà visualizzato questo messaggio:

```
Error: The instance is currently running, stop it first or pass --force
```

Pertanto, eliminare sempre le istantanee con il container in funzione.
````

Nei capitoli a seguire, si descriverà come:

- impostare il processo di creazione automatica degli snapshot
- Impostare la scadenza di un snapshot in modo che sia eliminato dopo un certo periodo di tempo.
- impostare l'aggiornamento automatico di snapshot sul server snapshot
