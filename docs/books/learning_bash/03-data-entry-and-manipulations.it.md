---
title: Bash - Inserimento e manipolazione dei dati
author: Antoine Le Morvan
contributors: Steven Spencer, Franco Colussi
tested_with: 8.5
tags:
  - education
  - bash scripting
  - bash
---

# Bash - Inserimento e manipolazione dei dati

In questo capitolo imparerete a far interagire i vostri script con gli utenti e a manipolare i dati.

****

**Obiettivi**: In questo capitolo imparerete a:

:heavy_check_mark: leggere l'input di un utente;     
:heavy_check_mark: manipolare voci di dati;     
:heavy_check_mark: utilizzare argomenti all'interno di uno script;     
:heavy_check_mark: gestire variabili posizionali;

:checkered_flag: **linux**, **script**, **bash**, **variable**

**Conoscenza**: :star: :star:  
**Complessità**: :star:

**Tempo di lettura**: 10 minuti

****

A seconda dello scopo dello script, può essere necessario inviargli informazioni quando viene lanciato o durante la sua esecuzione. Queste informazioni, non note al momento della scrittura dello script, possono essere estratte da file o inserite dall'utente. È anche possibile inviare queste informazioni sotto forma di argomenti quando viene immesso il comando di script. Questo è il modo in cui funzionano molti comandi di Linux.

## Il comando `read`

Il comando `read` consente di inserire una stringa di caratteri e di memorizzarla in una variabile.

Sintassi del comando read:

```
read [-n X] [-p] [-s] [variable]
```

Il primo esempio qui sotto richiede l'inserimento di due variabili: "name" e "firstname", ma poiché non c'è alcun prompt, bisogna sapere in anticipo che questo è il caso. Nel caso di questo particolare inserimento, ogni variabile immessa sarà separata da uno spazio.  Il secondo esempio richiede la variabile "name" con il testo di richiesta incluso:

```
read name firstname
read -p "Please type your name: " name
```

| Opzione | Funzionalità                               |
| ------- | ------------------------------------------ |
| `-p`    | Visualizza un messaggio di richiesta.      |
| `-n`    | Limita il numero di caratteri da inserire. |
| `-s`    | Nasconde l'input.                          |

Quando si utilizza l'opzione `-n`, la shell convalida automaticamente l'input dopo il numero di caratteri specificato. L'utente non deve premere il tasto <kbd>INVIO</kbd>.

```
read -n5 name
```

Il comando `read` consente di interrompere l'esecuzione dello script mentre l'utente inserisce le informazioni. L'input dell'utente viene scomposto in parole assegnate a una o più variabili predefinite. Le parole sono stringhe di caratteri separate dal separatore di campo.

La fine dell'immissione è determinata dalla pressione del tasto <kbd>INVIO</kbd>.

Una volta convalidato l'input, ogni parola viene memorizzata nella variabile predefinita.

La divisione delle parole è definita dal carattere separatore di campo. Questo separatore è memorizzato nella variabile di sistema `IFS`(**Internal Field Separator**).

```
set | grep IFS
IFS=$' \t\n'
```

Per impostazione predefinita, l'IFS contiene spazio, tabulazione e avanzamento riga.

Se utilizzato senza specificare una variabile, questo comando mette semplicemente in pausa lo script. Lo script continua la sua esecuzione quando l'input viene convalidato.

Viene utilizzato per mettere in pausa uno script durante il debug o per chiedere all'utente di premere <kbd>INVIO</kbd> per continuare.

```
echo -n "Press [ENTER] to continue..."
read
```

## Il comando `cut`

Il comando cut consente di isolare una colonna in un file o in un flusso.

Sintassi del comando cut:

```
cut [-cx] [-dy] [-fz] file
```

Esempio di utilizzo del comando cut:

```
cut -d: -f1 /etc/passwd
```

| Opzione | Osservazione                                                 |
| ------- | ------------------------------------------------------------ |
| `-c`    | Specifica i numeri in sequenza dei caratteri da selezionare. |
| `-d`    | Specifica il separatore di campo.                            |
| `-f`    | Specifica il numero d'ordine delle colonne da selezionare.   |

Il vantaggio principale di questo comando sarà la sua associazione con un flusso, ad esempio il comando `grep` e la pipe `|`.

* Il comando `grep` funziona "in verticale" (isolamento di una riga da tutte le righe del file).
* La combinazione dei due comandi consente di **isolare un campo specifico del file**.

Esempio:

```
grep "^root:" /etc/passwd | cut -d: -f3
0
```

!!! NOTE "Nota"

    I file di configurazione con un'unica struttura che utilizzano lo stesso separatore di campo sono i bersagli ideali per questa combinazione di comandi.

## Il comando `tr`

Il comando `tr` consente di convertire una stringa.

Sintassi del comando `tr`:

```
tr [-csd] string1 string2
```

| Opzione | Osservazione                                                                                                  |
| ------- | ------------------------------------------------------------------------------------------------------------- |
| `-c`    | Tutti i caratteri non specificati nella prima stringa vengono convertiti nei caratteri della seconda stringa. |
| `-d`    | Elimina il carattere specificato.                                                                             |
| `-s`    | Riduce il carattere specificato a una singola unità.                                                          |

Segue un esempio di utilizzo del comando `tr`. Se si usa `grep` per restituire la voce del file `passwd` di root, si ottiene questo risultato:

```
grep root /etc/passwd
```
restituisce:
```
root:x:0:0:root:/root:/bin/bash
```
Ora usiamo il comando `tr` e riduciamo le "o" nella riga:

```
grep root /etc/passwd | tr -s "o"
```
che restituisce questo:
```
rot:x:0:0:rot:/rot:/bin/bash
```
## Estrarre il nome e il percorso di un file

Il comando `basename` consente di estrarre il nome del file da un percorso.

Il comando `dirname` consente di estrarre il percorso padre di un file.

Esempi:

```
echo $FILE=/usr/bin/passwd
basename $FILE
```
Il che si tradurrebbe in "passwd"
```
dirname $FILE
```
Il risultato sarebbe: "/usr/bin"

## Argomenti di uno script

La richiesta di inserire informazioni con il comando di `read` interrompe l'esecuzione dello script finché l'utente non inserisce qualche informazione.

Questo metodo, sebbene sia molto semplice, ha i suoi limiti se lo script è programmato per essere eseguito di notte. Per superare questo problema, è possibile iniettare le informazioni desiderate tramite argomenti.

Molti comandi di Linux funzionano secondo questo principio.

Questo modo di procedere ha il vantaggio che, una volta eseguito, lo script non avrà bisogno di alcun intervento umano per essere completato.

Lo svantaggio principale è che l'utente dovrà essere avvisato della sintassi dello script per evitare errori.

Gli argomenti vengono inseriti quando si immette il comando di script. Sono separati da uno spazio.

```
./script argument1 argument2
```

Una volta eseguito, lo script salva gli argomenti inseriti in variabili predefinite: le `variabili posizionali`.

Queste variabili possono essere utilizzate nello script come qualsiasi altra variabile, ma non possono essere assegnate.

* Le variabili posizionali non utilizzate esistono ma sono vuote.
* Le variabili posizionali sono sempre definite nello stesso modo:

| Variabile   | Osservazione                                           |
| ----------- | ------------------------------------------------------ |
| `$0`        | contiene il nome dello script inserito.                |
| `$1` a `$9` | contengono i valori dal 1° al 9° argomento             |
| `${x}`      | contiene il valore dell'argomento `x`, superiore a 9.  |
| `$#`        | contiene il numero di argomenti passati.               |
| `$*` o `$@` | contiene in una variabile tutti gli argomenti passati. |

Esempio:

```
#!/usr/bin/env bash
#
# Author : Damien dit LeDub
# Date : september 2019
# Version 1.0.0 : Display the value of the positional arguments
# From 1 to 3

# The field separator will be "," or space
# Important to see the difference in $* and $@
IFS=", "

# Display a text on the screen:
echo "The number of arguments (\$#) = $#"
echo "The name of the script  (\$0) = $0"
echo "The 1st argument        (\$1) = $1"
echo "The 2nd argument        (\$2) = $2"
echo "The 3rd argument        (\$3) = $3"
echo "All separated by IFS    (\$*) = $*"
echo "All without separation  (\$@) = $@"
```

questo ci darà:

```
$ ./arguments.sh one two "tree four"
The number of arguments ($#) = 3
The name of the script  ($0) = ./arguments.sh
The 1st argument        ($1) = one
The 2nd argument        ($2) = two
The 3rd argument        ($3) = tree four
All separated by IFS    ($*) = one,two,tree four
All without separation  ($@) = one two tree four
```

!!! warning "Attenzione"

    Attenzione alla differenza tra `$@` e `$*`. È nel formato di memorizzazione degli argomenti:

    * `$*`: Contiene gli argomenti nel formato `"$1 $2 $3 ..."`
    * `$@`: contiene argomenti nel formato `"$1" "$2" "$3" ..`.

    È modificando la variabile d'ambiente `IFS` che si nota la differenza.

### Il comando shift

Il comando shift consente di spostare le variabili posizionali.

Modifichiamo l'esempio precedente per illustrare l'impatto del comando shift sulle variabili posizionali:

```
#!/usr/bin/env bash
#
# Author : Damien dit LeDub
# Date : september 2019
# Version 1.0.0 : Display the value of the positional arguments
# From 1 to 3

# The field separator will be "," or space
# Important to see the difference in $* and $@
IFS=", "

# Display a text on the screen:
echo "The number of arguments (\$#) = $#"
echo "The 1st argument        (\$1) = $1"
echo "The 2nd argument        (\$2) = $2"
echo "The 3rd argument        (\$3) = $3"
echo "All separated by IFS    (\$*) = $*"
echo "All without separation  (\$@) = $@"

shift 2
echo ""
echo "-------- SHIFT 2 ----------------"
echo ""

echo "The number of arguments (\$#) = $#"
echo "The 1st argument        (\$1) = $1"
echo "The 2nd argument        (\$2) = $2"
echo "The 3rd argument        (\$3) = $3"
echo "All separated by IFS    (\$*) = $*"
echo "All without separation  (\$@) = $@"
```

questo ci darà:

```
./arguments.sh one two "tree four"
The number of arguments ($#) = 3
The 1st argument        ($1) = one
The 2nd argument        ($2) = two
The 3rd argument        ($3) = tree four
All separated by IFS    ($*) = one,two,tree four
All without separation  ($@) = one two tree four

-------- SHIFT 2 ----------------

The number of arguments ($#) = 1
The 1st argument        ($1) = tree four
The 2nd argument        ($2) =
The 3rd argument        ($3) =
All separated by IFS    ($*) = tree four
All without separation  ($@) = tree four
```

Come si può notare, il comando `shift` ha spostato il posto degli argomenti "a sinistra", rimuovendo i primi due.

!!! WARNING "Attenzione"

    Quando si usa il comando `shift`, le variabili `$#` e `$*` vengono modificate di conseguenza.

### Il comando `set`

Il comando `set` divide una stringa in variabili posizionali.

Sintassi del comando set:

```
set [value] [$variable]
```

Esempio:

```
$ set one two three
$ echo $1 $2 $3 $#
one two three 3
$ variable="four five six"
$ set $variable
$ echo $1 $2 $3 $#
four five six 3
```

È ora possibile utilizzare le variabili posizionali come visto in precedenza.
