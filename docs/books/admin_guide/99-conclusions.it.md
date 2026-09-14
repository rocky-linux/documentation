---
title: Conclusione
author: Antoine Le Morvan
contributors: Steven Spencer
tags:
  - tips and tricks
  - command line
---

## Ora siete pronti

Finita la lettura di questa guida per amministratori dall'inizio alla fine, si è
pronti per gestire i server Linux senza timori.

In queste pagine è stato possibile conoscere molti comandi avanzati e
trucchi. Abbiamo deciso di raccoglierne alcuni in questa guida, insieme ad alcuni dei nostri consigli preferiti come bonus.

Sono proprio queste cose a fare la differenza tra un comune amministratore di Linux e un Linux Administrator.

!!! note

    Nessuno dei suggerimenti riportati di seguito è indispensabile, ed è possibile gestire un server alla perfezione anche senza di essi. Si tratta semplicemente di piccoli miglioramenti che,
    nel corso degli anni, rendono più piacevole l'uso quotidiano della riga di comando.

## Il marcatore end-of-options `--`

Il simbolo `--` indica la fine delle opzioni di un comando. Ciò significa che tutto ciò che segue questo marcatore è un argomento del comando, anche se inizia con un trattino. Nel comando seguente, `--hard` non è un'opzione lunga, bensì il nome della directory da creare:

```bash
mkdir -p -- --hard
```

Questa funzione è utile quando si ha a che fare con un file il cui nome inizia con un trattino (`-file`), che altrimenti il comando scambierebbe per un'opzione.

## Cambiare il gruppo primario con `newgrp`

Il comando `newgrp` avvia una sub-shell in cui il gruppo primario diventa uno dei gruppi secondari. Ad esempio, se fai parte del gruppo `support`:

```bash
newgrp support
```

avvia una sub-shell in cui il tuo GID effettivo è quello del gruppo `support`.
Per uscire e tornare al tuo GID predefinito, basta chiudere la sub-shell
(++ctrl+d++ o `exit`). Sebbene poco conosciuto, questo comando è comunque molto utile per assicurarsi che i file creati appartengano al gruppo corretto.

## Assegnare una password a un gruppo con `gpasswd`

Il comando `gpasswd` consente di assegnare una password a un gruppo. Ci si potrebbe chiedere: a cosa potrebbe mai servire? Chiunque conosca la password del gruppo può utilizzare il comando `newgrp` per entrare in quel gruppo senza esserne membro. `gpasswd` consente inoltre la designazione di amministratori di gruppo (`gpasswd -A`) che possono aggiungere o rimuovere membri senza bisogno dei privilegi di root.

## Mai eseguire `chmod -R 644` su un directory tree

Un errore comune nell'amministrazione consiste nell'eseguire:

```bash
chmod -R 644 /target
```

che rimuove il permesso di esecuzione (`x`) da ogni sottodirectory e impedisce quindi a chiunque di accedervi. È meglio selezionare solo i file, utilizzando il comando `find`:

```bash
find /target -type f -exec chmod 644 '{}' \;
```

!!! warning

    Il carattere `\;` finale è obbligatorio. In alternativa, è possibile utilizzare `+`, che raggruppa
    le chiamate in un unico batch e garantisce un'esecuzione più veloce:
    
    `bash     find /target -type f -exec chmod 644 ‘{}’ +     `

Ancora più elegante, il carattere maiuscolo `X` imposta il bit di esecuzione solo sulle directory (e sui file che lo possiedono già), con un unico comando:

```bash
chmod -R u=rwX,go=rX /target
```

## `tar` utilizza chiavi, non opzioni

Il comando `tar`, storicamente, utilizza chiavi anziché opzioni. In pratica, il comando `tar xvf` funziona laddove `tar -xvf` non funziona necessariamente sui sistemi meno recenti.
Allo stesso modo, in passato era necessario specificare il formato di decompressione (una `j` per bzip2, una `z` per gzip), mentre le versioni moderne lo rilevano automaticamente.

## I due numeri interi alla fine delle righe di `/etc/fstab`

Alla fine di ogni riga nel file `/etc/fstab` ci sono due numeri interi, solitamente `0 0`.
Il primo indicava se fosse necessario includere il filesystem nei backup (tramite l'utilità `dump`). La seconda opzione imposta l'ordine in cui `fsck` controlla i file system all'avvio, quando il controllo di un file system poteva richiedere molto tempo:

| valore | descrizione                                                  |
| ------ | ------------------------------------------------------------ |
| 0      | nessun controllo al boot                                     |
| 1      | controllare prima (riservato a `/`)       |
| 2      | controllare in seguito (altre partizioni) |

## Salvare e uscire da Vim con `:x`

In Vim, il comando `:x` consente di salvare e uscire con due tasti, invece dei tre necessari per il comando `:wq`. C'è una sottigliezza: a differenza di `:wq`, `:x` salva il file solo se è stato modificato, quindi non aggiorna inutilmente la data di modifica, cosa che può essere importante con `make` o con i file watcher. In modalità normale, ++shift+z++ ++shift+z++ fa esattamente la stessa cosa.

## Un pipe trasporta solo `stdout`

Il simbolo `|` collega semplicemente lo `stdout` di un comando allo `stdin` di quello successivo.
Per impostazione predefinita, il flusso `stderr` non passa attraverso il pipe. Ciò può risultare fastidioso per comandi come `ssh -V`, che visualizzano la propria versione sul canale `stderr` (canale 2).

Per far passare `stderr` attraverso il pipe, reindirizzare il canale 2 sul canale 1:

```bash
ssh -V 2>&1 | cut -d',' -f1
```

!!! tip

    Presta attenzione all'ordine dei reindirizzamenti. Il reindirizzamento dell'output deve essere effettuato **prima** del reindirizzamento di `stderr`, altrimenti non funzionerà come ci si aspetta. This does **not** work as intended:
    
    `bash     ssh -V 2>&1 1>test.txt     `
    
    and should be written like this:
    
    `bash     ssh -V 1>test.txt 2>&1     `

Lo stesso valeva in passato anche per `java -version` (con un solo trattino; si noti che il comando con doppio trattino `java --version`, introdotto in Java 9, visualizza l'output su `stdout`) o per `python2 --version`.

## Backup rapidi con espansione delle parentesi graffe

Invece di digitare nuovamente il nome di un file, fare in modo che la shell espanda `{,.bak}` in due stringhe (una vuota e poi `.bak`):

```bash
cp file.conf{,.bak}
```

In questo modo viene creato il file `file.conf.bak`. Lo stesso principio consente di creare un intero tree in una sola volta:

```bash
mkdir -p project/{src,bin,doc}
```

## Scorciatoie per l'ultimo argomento di history

Diverse scorciatoie evitano di dover digitare nuovamente l'ultimo argomento. `!$` reinserisce l'ultimo argomento del comando precedente:

```bash
mkdir -p /some/slightly/long/path && cd !$
```

\++alt+“.”++ svolge la stessa funzione in modalità interattiva e, se premuto più volte, permette di tornare indietro nella history degli argomenti. ++esc++ seguito da ++“_”++ genera la stessa funzione `readline` (`yank-last-arg`), dove ++esc++ funge da tasto Meta. Come per quanto riguarda il famoso:

```bash
sudo !!
```

esegue nuovamente il comando precedente precedendolo con `sudo`, la soluzione automatica per quando te ne sei dimenticato.

## Tornare indietro con `cd -`

Il comando `cd -` ti riporta alla directory precedente, il che è utile per spostarsi avanti e indietro tra due cartelle. E il comando `cd`, da solo, senza argomenti, vi riporta alla vostra home directory.

## `[` è in realtà un vero e proprio programma

Il `[ ... ]` test che scrivi all'interno di un `if` non fa parte della sintassi di Magic Shell: `[` è un
comando a tutti gli effetti (`/usr/bin/[`), proprio come `true` e `false`, che sono
anch'essi veri e propri file binari.

## Eredità di gruppo con il bit setgid

L'impostazione del bit setgid su una directory impone l'ereditarietà del gruppo:

```bash
chmod g+s /share
```

Da quel momento in poi, qualsiasi file creato nella directory `/share` appartiene al gruppo della directory anziché al gruppo primario di chi lo crea. Questo è il trucco fondamentale per le condivisioni di gruppo e integra perfettamente i suggerimenti su `newgrp` e `gpasswd` riportati sopra.

## Modifica la riga di comando corrente nel tuo editor

\++ctrl+x++ ++ctrl+e++ apre il comando che stai digitando in quel momento nell'editor.
È una vera manna dal cielo per le righe di comando che sfuggono di mano: la shell apre la riga corrente in `$EDITOR` e la esegue quando si chiude il file. È molto più comodo che modificare un comando di tre righe con i tasti freccia.

## Rendere un file immutabile con `chattr +i`

```bash
chattr +i /etc/resolv.conf
```

Non è più possibile modificare o eliminare il file, nemmeno con i privilegi di root, finché non si rimuove l'attributo (`chattr -i`). È la protezione perfetta contro un malaugurato comando `rm` o contro il servizio che riscrive il file `resolv.conf` ad ogni riavvio.

## Trasformare un elenco in argomenti con `xargs`

Il comando `xargs` trasforma un elenco ricevuto su `stdin` in argomenti per un altro comando. Con il segnaposto `-I{}`, si genera un comando per ogni riga ricevuta:

```bash
ls *.log | xargs -I{} mv {} {}.old
```

È possibile eseguire il lavoro in parallelo con l'opzione `-P` (in questo caso, quattro processi contemporaneamente):

```bash
cat urls.txt | xargs -P4 -I{} curl -sO {}
```

Per i nomi di file che contengono spazi, la combinazione sicura è `find -print0` abbinata a `xargs -0`, che separa le voci in base al byte nullo anziché agli spazi:

```bash
find /target -type f -print0 | xargs -0 -I{} cp {} /backup/
```

Come bonus quasi inutile, `xargs` senza alcun comando chiama `echo` per impostazione predefinita, trasformandosi così in una sorta di “trim” improvvisato: elimina gli spazi iniziali e finali e riduce gli spazi multipli a uno solo.

## Conclusione

Questa breve raccolta offre solo una infarinatura. Linux premia la curiosità e ogni amministratore finisce per sviluppare una serie di piccole abitudini che fanno sì che la riga di comando diventi un ambiente familiare. Speriamo che alcuni di questi trovino posto anche nella tua.
