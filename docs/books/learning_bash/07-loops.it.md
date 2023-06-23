---
title: Bash - Loops
author: Antoine Le Morvan
contributors: Steven Spencer, Franco Colussi
tested_with: 8.5
tags:
  - education
  - bash scripting
  - bash
---

# Bash - Loops

****

**Obiettivi**: In questo capitolo imparerete a:

:heavy_check_mark: utilizzare i loop;

:checkered_flag: **linux**, **script**, **bash**, **loops**

**Conoscenza**: :star: :star:  
**Complessità**: :star: :star: :star:

**Tempo di lettura**: 20 minuti

****

La shell bash consente l'uso di **loops**. Queste strutture consentono l'esecuzione di **un blocco di comandi più volte** (da 0 a infinito) in base a un valore definito staticamente, dinamicamente o a condizione:

* `while`
* `until`
* `for`
* `select`

Qualunque sia il ciclo utilizzato, i comandi da ripetere sono collocati **tra le parole** `do` e `done`.

## La struttura del ciclo condizionale while

La struttura `while` / `do` / `done` valuta il comando posto dopo il `while`.

Se questo comando è vero (`$?  = 0`), i comandi posti tra `do` e `done` vengono eseguiti. Lo script torna quindi all'inizio per valutare nuovamente il comando.

Quando il comando valutato è falso (`$? != 0`), la shell riprende l'esecuzione dello script al primo comando dopo done.

Sintassi della struttura del ciclo condizionale `while`:

```
while command
do
  command if $? = 0
done
```

Esempio di utilizzo della struttura condizionale `while`:

```
while [[ -e /etc/passwd ]]
do
  echo "The file exists"
done
```

Se il comando valutato non varia, il ciclo sarà infinito e la shell non eseguirà mai i comandi posti dopo lo script. Questo può essere intenzionale, ma anche un errore. Quindi bisogna fare **molta attenzione ai comandi che gestiscono il loop e trovare un modo per uscirne**.

Per uscire da un ciclo `while`, bisogna assicurarsi che il comando valutato non sia più vero, il che non è sempre possibile.

Esistono comandi che consentono di modificare il comportamento di un ciclo:

* `exit`
* `break`
* `continue`

## Il comando exit

Il comando `exit` termina l'esecuzione dello script.

Sintassi del comando `exit`:

```
exit [n]
```

Esempio di utilizzo del comando `exit`:

```
bash # to avoid being disconnected after the "exit 1
exit 1
echo $?
1
```

Il comando `exit` termina immediatamente lo script. È possibile specificare il codice di ritorno dello script fornendolo come argomento (da `0` a `255`). Se non viene fornito alcun argomento, il codice di ritorno dell'ultimo comando dello script verrà passato alla variabile `$?`

## I comandi  `break` e `continue`

Il comando `break` consente di interrompere il ciclo passando al primo comando dopo `done`.

Il comando `continue` consente di riavviare il ciclo tornando al primo comando dopo `done`.

```
while [[ -d / ]]                                                   INT ✘  17s 
do
  echo "Do you want to continue? (yes/no)"
  read ans
  [[ $ans = "yes" ]] && continue
  [[ $ans = "no" ]] && break
done
```

## I comandi `true` / `false`

Il comando `true` restituisce sempre `vero`, mentre il comando `false` restituisce sempre `falso`.

```
true
echo $?
0
false
echo $?
1
```

Utilizzati come condizione di un ciclo, consentono l'esecuzione di un ciclo infinito o la sua disattivazione.

Esempio:

```
while true
do
  echo "Do you want to continue? (yes/no)"
  read ans
  [[ $ans = "yes" ]] && continue
  [[ $ans = "no" ]] && break
done
```

## La struttura del ciclo condizionale `until`

La struttura `until` / `do` / `done` valuta il comando posto dopo `until`.

Se questo comando è falso (`$? != 0`), i comandi posti tra `do` e `done` vengono eseguiti. Lo script torna quindi all'inizio per valutare nuovamente il comando.

Quando il comando valutato è vero (`$? = 0`), la shell riprende l'esecuzione dello script al primo comando dopo `done`.

Sintassi della struttura del ciclo condizionale `until`:

```
until command
do
  command if $? != 0
done
```

Esempio di utilizzo della struttura condizionale `until`:

```
until [[ -e test_until ]]
do
  echo "The file does not exist"
  touch test_until
done
```

## La struttura di scelta alternativa `select`

La struttura `select` / `do` / `done` consente di visualizzare un menu con diverse scelte e una richiesta di input.

Ogni voce dell'elenco ha una scelta numerata. Quando si inserisce una scelta, il valore scelto viene assegnato alla variabile posta dopo `select` (creata a questo scopo).

Esegue quindi i comandi posti tra `do` e `done` con questo valore.

* La variabile `PS3` contiene l'invito a inserire la scelta;
* La variabile `REPLY` restituirà il numero della scelta.

Per uscire dal ciclo è necessario un comando di `break`.

!!! Note "Nota"

    La struttura `select` è molto utile per menu piccoli e semplici. Per personalizzare una visualizzazione più completa, i comandi `echo` e `read` devono essere utilizzati in un ciclo `while`.

Sintassi della struttura del ciclo condizionale `select`:

```
PS3="Your choice:"
select variable in var1 var2 var3
do
  commands
done
```

Esempio di utilizzo della struttura condizionale `select`:

```
PS3="Your choice: "
select choice in coffee tea chocolate
do
  echo "You have chosen the $REPLY: $choice"
done
```

Se questo script viene eseguito, viene visualizzato qualcosa di simile a questo:

```
1) Coffee
2) Tea
3) Chocolate
Your choice : 2
You have chosen choice 2: Tea
Your choice:
```

## La struttura del ciclo `for` su un elenco di valori

La struttura `for` / `do` / `done` assegna il primo elemento dell'elenco alla variabile posta dopo `for` (creata in questa occasione). Esegue quindi i comandi posti tra `do` e `done` con questo valore. Lo script torna quindi all'inizio per assegnare l'elemento successivo dell'elenco alla variabile di lavoro. Quando l'ultimo elemento è stato utilizzato, la shell riprende l'esecuzione dal primo comando dopo `done`.

Sintassi della struttura del ciclo `for` su un elenco di valori:

```
for variable in list
do
  commands
done
```

Esempio di utilizzo della struttura condizionale `for`:

```
for file in /home /etc/passwd /root/fic.txt
do
  file $file
done
```

Qualsiasi comando che produca un elenco di valori può essere collocato dopo il comando `in` utilizzando una sotto esecuzione.

* Con la variabile `IFS` contenente `$' \t\n'`, il ciclo `for` prenderà **ogni parola** del risultato di questo comando come un elenco di elementi su cui eseguire il ciclo.
* Con la variabile `IFS` contenente `$'\t\n'` (cioè senza spazi), il ciclo `for` prenderà ogni riga del risultato di questo comando.

Questi possono essere i file di una directory. In questo caso, la variabile assumerà come valore ciascuna delle parole dei nomi dei file presenti:

```
for file in $(ls -d /tmp/*)
do
  echo $file
done
```

Può essere un file. In questo caso, la variabile assumerà come valore ogni parola contenuta nel file sfogliato, dall'inizio alla fine:

```
cat my_file.txt
first line
second line
third line
for LINE in $(cat my_file.txt); do echo $LINE; done
first
line
second
line
third line
line
```

Per leggere un file riga per riga, è necessario modificare il valore della variabile d'ambiente `IFS`.

```
IFS=$'\t\n'
for LINE in $(cat my_file.txt); do echo $LINE; done
first line
second line
third line
```
