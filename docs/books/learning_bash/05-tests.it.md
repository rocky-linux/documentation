---
title: Bash - Test
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.5
tags:
  - education
  - bash scripting
  - bash
---

# Bash - Test

****

**Obiettivi**: In questo capitolo imparerete a:

:heavy_check_mark: lavorare con il codice di ritorno;  
:heavy_check_mark: testare i file e confrontarli;  
:heavy_check_mark: testare variabili, stringhe e numeri interi;  
:heavy_check_mark: eseguire un'operazione con numeri interi;

:checkered_flag: **linux**, **script**, **bash**, **variable**

**Conoscenza**: :star: :star:  
**Complessità**: :star:

**Tempo di lettura**: 10 minuti

****

Una volta completati, tutti i comandi eseguiti dalla shell restituiscono un **codice di ritorno** (chiamato anche **codice** **di stato** o di **uscita**).

* Se il comando è stato eseguito correttamente, il codice di stato sarà pari a **zero**.
* Se il comando ha incontrato un problema durante la sua esecuzione, il suo codice di stato avrà un **valore diverso da zero**. I motivi possono essere molteplici: mancanza di diritti di accesso, file mancante, inserimento errato, ecc.

Si consiglia di consultare il manuale `man command` per conoscere i diversi valori del codice di ritorno forniti dagli sviluppatori.

Il codice di ritorno non è visibile direttamente, ma è memorizzato in una variabile speciale: `$?`

```
mkdir directory
echo $?
0
```

```
mkdir /directory
mkdir: unable to create directory
echo $?
1
```

```
command_that_does_not_exist
command_that_does_not_exist: command not found
echo $?
127
```


!!! note "Nota"

    La visualizzazione del contenuto della variabile `$?` con il comando `echo` è fatta subito dopo il comando che si vuole valutare, perché questa variabile viene aggiornata dopo ogni esecuzione di un comando, di una riga di comando o di uno script.

!!! tip "Suggerimento"

    Poiché il valore di `$?` cambia dopo l'esecuzione di ogni comando, è meglio inserire il suo valore in una variabile che verrà utilizzata in seguito, per un test o per visualizzare un messaggio.

    ```
    ls no_file
    ls: cannot access 'no_file': No such file or directory
    result=$?
    echo $?
    0
    echo $result
    2
    ```

È anche possibile creare codici di ritorno in uno script. Per farlo, è sufficiente aggiungere un argomento numerico al comando `exit`.

```
bash # to avoid being disconnected after the "exit 2
exit 123
echo $?
123
```

Oltre alla corretta esecuzione di un comando, la shell offre la possibilità di eseguire test su molti modelli:

* **File**: esistenza, tipo, diritti, confronto;
* **Stringhe**: lunghezza, confronto;
* **Numeri interi**: valore, confronto.

Il risultato del test:

* `$?=0`: il test è stato eseguito correttamente ed è vero;
* `$?=1`: il test è stato eseguito correttamente ed è falso;
* `$?=2`: il test non è stato eseguito correttamente.

## Verifica del tipo di file

Sintassi del comando di `test` per un file:

```
test [-d|-e|-f|-L] file
```

oppure:

```
[ -d-e|-f|-L file ]
```

!!! NOTE "Nota"

    Si noti che c'è uno spazio dopo il `[` e prima del `]`.

Opzioni del comando test sui file:

| Opzione | Osservazione                                                           |
| ------- | ---------------------------------------------------------------------- |
| `-e`    | Verifica se il file esiste                                             |
| `-f`    | Verifica se il file esiste ed è di tipo normale                        |
| `-d`    | Verifica se il file esiste ed è di tipo directory                      |
| `-L`    | Controlla se il file esiste e se è di tipo link simbolico              |
| `-b`    | Verifica se il file esiste e se è di tipo speciale in modalità blocco  |
| `-c`    | Controlla se il file esiste e se è di tipo speciale modalità carattere |
| `-p`    | Controlla se il file esiste ed è di tipo tube                          |
| `-S`    | Verifica se il file esiste ed è di tipo socket                         |
| `-t`    | Verifica se il file esiste ed è di tipo terminale                      |
| `-r`    | Verifica se il file esiste ed è leggibile                              |
| `-w`    | Controlla se il file esiste e se è scrivibile                          |
| `-x`    | Verifica se il file esiste ed è eseguibile                             |
| `-g`    | Controlla se il file esiste e ha un SGID impostato                     |
| `- u`   | Controlla se il file esiste e ha un SUID impostato                     |
| `-s`    | Verifica se il file esiste e non è vuoto (dimensione > 0 byte)         |

Esempio:

```
test -e /etc/passwd
echo $?
0
[ -w /etc/passwd ]
echo $?
1
```

È stato creato un comando interno ad alcune shell (tra cui bash) che è più moderno e fornisce più funzioni del comando esterno `test`.

```
[[ -s /etc/passwd ]]
echo $?
1
```

!!! NOTE "Nota"

    Per il resto di questo capitolo utilizzeremo quindi il comando interno.

## Confronto di due file

È anche possibile confrontare due file:

```
[[ file1 -nt|-ot|-ef file2 ]]
```

| Opzione | Osservazione                                                      |
| ------- | ----------------------------------------------------------------- |
| `-nt`   | Verifica se il primo file è più recente del secondo               |
| `-ot`   | Verifica se il primo file è più vecchio del secondo               |
| `-ef`   | Verifica se il primo file è un collegamento fisico con il secondo |

## Testare le variabili

È possibile testare le variabili:

```
[[ -z|-n $variable ]]
```

| Opzione | Osservazione                         |
| ------- | ------------------------------------ |
| `-z`    | Verifica se la variabile è vuota     |
| `-n`    | Verifica se la variabile non è vuota |

## Test delle stringhe

È anche possibile confrontare due stringhe:

```
[[ string1 =|!=|<|> string2 ]]
```

Esempio:

```
[[ "$var" = "Rocky rocks!" ]]
echo $?
0
```

| Opzione | Osservazione                                                           |
| ------- | ---------------------------------------------------------------------- |
| `=`     | Verifica se la prima stringa è uguale alla seconda                     |
| `!=`    | Verifica se la prima stringa è diversa dalla seconda                   |
| `<`  | Verifica se la prima stringa è precedente alla seconda in ordine ASCII |
| `>`  | Verifica se la prima stringa è dopo la seconda in ordine ASCII         |

## Confronto tra numeri interi

Sintassi per il test dei numeri interi:

```
[[ "num1" -eq|-ne|-gt|-lt "num2" ]]
```

Esempio:

```
var=1
[[ "$var" -eq "1" ]]
echo $?
0
```

```
var=2
[[ "$var" -eq "1" ]]
echo $?
1
```

| Opzione | Osservazione                                       |
| ------- | -------------------------------------------------- |
| `-eq`   | Verifica se il primo numero è uguale al secondo    |
| `-ne`   | Verifica se il primo numero è diverso dal secondo  |
| `-gt`   | Verifica se il primo numero è maggiore del secondo |
| `-lt`   | Verifica se il primo numero è minore del secondo   |

!!! Note "Nota"

    Poiché i valori numerici sono trattati dalla shell come caratteri regolari (o stringhe), un test su un carattere può restituire lo stesso risultato sia che venga trattato come un carattere numerico o meno.

    ```
    test "1" = "1"
    echo $?
    0
    test "1" -eq "1"
    echo $?
    0
    ```


    Ma il risultato del test non avrà lo stesso significato:

    * Nel primo caso, significa che i due caratteri hanno lo stesso valore nella tabella ASCII.
    * Nel secondo caso, significa che i due numeri sono uguali.

## Test combinati

La combinazione di test consente di eseguire più test con un unico comando. È possibile testare più volte lo stesso argomento (file, stringa o numero) o argomenti diversi.

```
[ option1 argument1 [-a|-o] option2 argument 2 ]
```

```
ls -lad /etc
drwxr-xr-x 142 root root 12288 sept. 20 09:25 /etc
[ -d /etc -a -x /etc ]
echo $?
0
```

| Opzione | Osservazione                                         |
| ------- | ---------------------------------------------------- |
| `-a`    | AND: il test sarà vero se tutti i modelli sono veri. |
| `-o`    | OR: Il test sarà vero se almeno uno schema è vero.   |


Con il comando interno, è meglio utilizzare questa sintassi:

```
[[ -d "/etc" && -x "/etc" ]]
```

I test possono essere raggruppati con parentesi `(` `)` per dare loro una priorità.

```
(TEST1 -a TEST2) -a TEST3
```

Il carattere `!` viene utilizzato per eseguire il test inverso a quello richiesto dall'opzione:

```
test -e /file # true if file exists
! test -e /file # true if file does not exist
```

## Operazioni numeriche

Il comando `expr` esegue un'operazione con numeri interi.

```
expr num1 [+] [-] [\*] [/] [%] num2
```

Esempio:

```
expr 2 + 2
4
```

!!! Warning "Attenzione"

    Fare attenzione a circondare il segno di operazione con uno spazio. In caso di dimenticanza, verrà visualizzato un messaggio di errore.
    Nel caso di una moltiplicazione, il carattere jolly `*` è preceduto da `\` per evitare un'interpretazione errata.

| Opzione | Osservazione           |
| ------- | ---------------------- |
| `+`     | Addizione              |
| `-`     | Sottrazione            |
| `\*`  | Moltiplicazione        |
| `/`     | Quoziente di divisione |
| `%`     | Modulo della divisione |


## Il comando `typeset`

Il comando `typeset -i` dichiara una variabile come un numero intero.

Esempio:

```
typeset -i var1
var1=1+1
var2=1+1
echo $var1
2
echo $var2
1+1
```

## Il comando `let`

Il comando `let` verifica se un carattere è numerico.

Esempio:

```
var1="10"
var2="AA"
let $var1
echo $?
0
let $var2
echo $?
1
```

!!! Warning "Attenzione"

    Il comando `let` non restituisce un codice di ritorno coerente quando valuta il valore numerico `0`.

    ```
    let 0
    echo $?
    1
    ```

Il comando `let` consente anche di eseguire operazioni matematiche:

```
let var=5+5
echo $var
10
```

`può` essere sostituito da `$(( ))`.

```
echo $((5+2))
7
echo $((5*2))
10
var=$((5*3))
echo $var
15
```
