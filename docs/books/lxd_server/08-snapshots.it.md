---
title: 8 Istantanee del contenitore
author: Steven Spencer
contributors: Ezequiel Bruni, Franco Colussi
tested_with: 8.8, 9.2
tags:
  - lxd
  - enterprise
  - lxd snapshots
---

# Capitolo 8: istantanee del contenitore

Nel corso di questo capitolo sarà necessario eseguire i comandi come utente non privilegiato ("lxdadmin" se si è seguito dall'inizio di questo libro).

Le istantanee dei container, insieme a un server di istantanee (di cui si parlerà più avanti), sono probabilmente l'aspetto più importante dell'esecuzione di un server LXD di produzione. Le istantanee garantiscono un ripristino rapido. È una buona idea usarli come sicurezza quando si aggiorna il software principale che gira su un particolare contenitore. Se durante l'aggiornamento accade qualcosa che interrompe l'applicazione, è sufficiente ripristinare l'istantanea per tornare operativi con un tempo di inattività di pochi secondi.

L'autore ha utilizzato i container LXD per i server PowerDNS rivolti al pubblico e il processo di aggiornamento di queste applicazioni è diventato meno preoccupante, grazie alla creazione di istantanee prima di ogni aggiornamento.

È possibile eseguire lo snapshot di un contenitore anche quando è in esecuzione.

## Il processo di snapshot

Iniziate ottenendo un'istantanea del container ubuntu-test con questo comando:

```
lxc snapshot ubuntu-test ubuntu-test-1
```

Qui lo snapshot viene chiamato "ubuntu-test-1", ma si può chiamare in qualsiasi modo. Per assicurarsi di uno snapshot, eseguire un'`lxc info` del container:

```
lxc info ubuntu-test
```

Avete già guardato una schermata informativa. Se si scorre fino in fondo, ora si vede:

```
Snapshots:
  ubuntu-test-1 (taken at 2021/04/29 15:57 UTC) (stateless)
```

Riuscito! Il nostro snapshot è in posizione.

Entrate nel container ubuntu-test:

```
lxc exec ubuntu-test bash
```

Creare un file vuoto con il comando _touch_:

```
touch this_file.txt
```

Uscite dal container.

Prima di ripristinare il container com'era prima della creazione del file, il modo più sicuro per ripristinare un container, in particolare se ci sono state molte modifiche, è quello di fermarlo prima:

```
lxc stop ubuntu-test
```

Ripristino:

```
lxc restore ubuntu-test ubuntu-test-1
```

Avviare nuovamente il container:

```
lxc start ubuntu-test
```

Se si torna di nuovo nel container e si guarda, il "this_file.txt" creato non c'è più.

Quando non si ha più bisogno di uno snapshot, è possibile eliminarlo:

```
lxc delete ubuntu-test/ubuntu-test-1
```

!!! warning "Attenzione"

    È sempre consigliabile eliminare gli snapshot con il container in esecuzione. Perché? Il comando _lxc delete_ funziona anche per eliminare l'intero contenitore. Se avessimo accidentalmente premuto invio dopo "ubuntu-test" nel comando precedente, E, se il container fosse stato fermato, il container sarebbe stato cancellato. Non viene dato alcun avviso, fa semplicemente quello che gli si chiede.
    
    Se il container è in esecuzione, tuttavia, viene visualizzato questo messaggio:

    ```
    Error: The instance is currently running, stop it first or pass --force
    ```


    Pertanto, eliminare sempre gli snapshot con il container in funzione.

Nei capitoli che seguono, vi saranno:

* impostare il processo di creazione automatica degli snapshot
* impostare la scadenza di uno snapshot in modo che scompaia dopo un certo periodo di tempo
* impostare l'aggiornamento automatico degli snapshot al server snapshot
