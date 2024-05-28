---
title: Bash - Strutture condizionali if e case
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.5
tags:
  - education
  - bash scripting
  - bash
---

# Bash - Strutture condizionali if e case

****

**Obiettivi**: In questo capitolo imparerete a:

:heavy_check_mark: utilizzare la sintassi condizionale `if`;  
:heavy_check_mark: utilizzare la sintassi condizionale `case`;

:checkered_flag: **linux**, **script**, **bash**, **conditional structures**

**Conoscenza**: :star: :star:  
**Complessità**: :star:

**Tempo di lettura**: 20 minuti

****

## Strutture condizionali

Se la variabile `$?` viene utilizzata per conoscere il risultato di un test o l'esecuzione di un comando, può essere solo visualizzata e non ha alcun effetto sull'esecuzione di uno script.

Ma possiamo usarlo in una condizione. **Se** il test è positivo **allora** eseguo questa azione **altrimenti** eseguo quest'altra.

Sintassi dell'alternativa condizionale `if`:

```bash
if command
then
    command if $?=0
else
    command if $?!=0
fi
```

Il comando posto dopo la parola `if` può essere qualsiasi comando, poiché è il suo codice di ritorno (`$?`) a essere valutato. Spesso è conveniente usare il comando `test` per definire diverse azioni in base al risultato di questo test (file esistente, variabile non vuota, diritti di scrittura impostati).

L'uso di un comando classico`(mkdir`, `tar`, ...) consente di definire le azioni da eseguire in caso di successo o i messaggi di errore da visualizzare in caso di fallimento.

Esempi:

```bash
if [[ -e /etc/passwd ]]
then
    echo "The file exists"
else
    echo "The file does not exist"
fi

if mkdir rep
then
    cd rep
fi
```

Se il blocco `else` inizia con una nuova struttura `if`, è possibile unire `else` e `if` con `elif`, come mostrato di seguito:

```bash
[...]
else
  if [[ -e /etc/ ]]
[...]

[...]
# is equivalent to
elif [[ -e /etc ]]
[...]
```

!!! Nota "Sintesi"

    La struttura `if` / `then` / `else` / `fi` valuta il comando posto dopo if:

    * Se il codice di ritorno di questo comando è `0` (`vero`), la shell eseguirà i comandi `successivi`;
    * Se il codice di ritorno è diverso da `0` (`falso`), la shell eseguirà i comandi posti dopo `else`.

    Il blocco `else` è opzionale.

    Spesso è necessario eseguire alcune azioni solo se la valutazione del comando è vera e non fare nulla se è falsa.

    La parola `fi` chiude la struttura.

Quando c'è un solo comando da eseguire nel blocco `then`, è possibile utilizzare una sintassi più semplice.

Il comando da eseguire se `$?` è `vero` è posto dopo `&&` mentre il comando da eseguire se `$?` è `falso` è posto dopo `||` (opzionale).

Esempio:

```bash
[[ -e /etc/passwd ]] && echo "The file exists" || echo "The file does not exist"
mkdir dir && echo "The directory is created".
```

È anche possibile valutare e sostituire una variabile con una struttura più leggera di `if`.

Questa sintassi implementa le parentesi graffe:

* Visualizza un valore sostitutivo se la variabile è vuota:

    ```bash
    ${variable:-value}
    ```

* Visualizza un valore sostitutivo se la variabile non è vuota:

    ```bash
    ${variable:+value}
    ```

* Assegna un nuovo valore alla variabile se è vuota:

    ```bash
    ${variable:=value}
    ```

Esempi:

```bash
name=""
echo ${name:-linux}
linux
echo $name

echo ${name:=linux}
linux
echo $name
linux
echo ${name:+tux}
tux
echo $name
linux
```

!!! hint "Suggerimento"

    Quando si decide di usare `if`, `then`, `else`, `fi` o di usare gli esempi di sintassi più semplici descritti sopra, bisogna tenere a mente la leggibilità dello script. Se nessuno utilizzerà lo script oltre a voi stessi, potete usare quello che funziona meglio per voi. Se qualcun altro potrebbe aver bisogno di rivedere, debuggare o tracciare lo script che avete creato, usate la forma più autodocumentante (`if`, `then`, ecc.) o assicuratevi di documentare accuratamente il vostro script, in modo che la sintassi più semplice sia effettivamente compresa da coloro che potrebbero aver bisogno di modificare e usare lo script. Documentare lo script è *sempre* una buona cosa da fare in ogni caso, come già notato più volte in queste lezioni.

## Alternativa condizionale: struttura `case`

Una successione di strutture `if` può diventare rapidamente pesante e complessa. Quando si tratta della valutazione di una stessa variabile, è possibile utilizzare una struttura condizionale con più rami. I valori della variabile possono essere specificati o appartenere a un elenco di possibilità.

**È possibile utilizzare i caratteri jolly**.

La struttura `case ... in` / `esac` valuta la variabile posta dopo `case` e la confronta con i valori definiti.

Alla prima uguaglianza trovata, vengono eseguiti i comandi posti tra `)` e `;;`.

La variabile valutata e i valori proposti possono essere stringhe o risultati di sotto esecuzioni di comandi.

Collocata alla fine della struttura, la scelta `*` indica le azioni da eseguire per tutti i valori che non sono stati precedentemente testati.

Sintassi dell'alternativo condizionale case:

```bash
case $variable in
  value1)
    commands if $variable = value1
    ;;
  value2)
    commands if $variable = value2
    ;;
  [..]
  *)
    commands for all values of $variable != of value1 and value2
    ;;
esac
```

Quando il valore è soggetto a variazioni, è consigliabile utilizzare i caratteri jolly `[]` per specificare le possibilità:

```bash
[Yy][Ee][Ss])
  echo "yes"
  ;;
```

Il carattere `|` consente anche di specificare un valore o un altro:

```bash
"yes" | "YES")
  echo "yes"
  ;;
```
