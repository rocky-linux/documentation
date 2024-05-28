---
title: Bash - Uso delle variabili
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.5
tags:
  - education
  - bash scripting
  - bash
---

# Bash - Uso delle variabili

In questo capitolo imparerete a usare le variabili nei vostri script bash.

****

**Obiettivi**: In questo capitolo imparerete a:

:heavy_check_mark: Memorizzare le informazioni per un uso successivo;  
:heavy_check_mark: Cancellare e bloccare le variabili;  
:heavy_check_mark: Utilizzare le variabili d'ambiente;  
:heavy_check_mark: Sostituire i comandi;

:checkered_flag: **linux**, **script**, **bash**, **variabile**

**Conoscenza**: :star: :star:  
**Complessità**: :star:

**Tempo di lettura**: 10 minuti

****

## Memorizzazione delle informazioni per un uso successivo

Come in qualsiasi linguaggio di programmazione, lo script di shell utilizza le variabili. Vengono utilizzate per immagazzinare informazioni in memoria da riutilizzare quando necessario durante lo script.

Una variabile viene creata quando riceve il suo contenuto. Rimane valido fino al termine dell'esecuzione dello script o su richiesta esplicita dell'autore dello script. Poiché lo script viene eseguito in sequenza dall'inizio alla fine, è impossibile richiamare una variabile prima che sia stata creata.

Il contenuto di una variabile può essere modificato durante lo script, poiché la variabile continua a esistere fino al termine dello script. Se il contenuto viene cancellato, la variabile rimane attiva ma non contiene nulla.

La nozione di tipo di variabile in uno script di shell è possibile, ma viene utilizzata molto raramente. Il contenuto di una variabile è sempre un carattere o una stringa.

```bash
#!/usr/bin/env bash

#
# Author : Rocky Documentation Team
# Date: March 2022
# Version 1.0.0: Save in /root the files passwd, shadow, group, and gshadow
#

# Global variables
FILE1=/etc/passwd
FILE2=/etc/shadow
FILE3=/etc/group
FILE4=/etc/gshadow

# Destination folder
DESTINATION=/root

# Clear the screen
clear

# Launch the backup
echo "Starting the backup of $FILE1, $FILE2, $FILE3, $FILE4 to $DESTINATION:"

cp $FILE1 $FILE2 $FILE3 $FILE4 $DESTINATION

echo "Backup ended!"
```

Questo script fa uso di variabili. Il nome di una variabile deve iniziare con una lettera, ma può contenere qualsiasi sequenza di lettere o numeri. Ad eccezione del trattino basso "_", non è possibile utilizzare caratteri speciali.

Per convenzione, le variabili create da un utente hanno un nome in minuscolo. Questo nome deve essere scelto con cura per non essere troppo evasivo o troppo complicato. Tuttavia, una variabile può essere denominata con lettere maiuscole, come in questo caso, se si tratta di una variabile globale che non deve essere modificata dal programma.

Il carattere `=` assegna il contenuto a una variabile:

```bash
variable=value
rep_name="/home"
```

Non ci sono spazi prima o dopo il segno `=`.

Una volta creata la variabile, è possibile utilizzarla anteponendole un dollaro $.

```bash
file=file_name
touch $file
```

Si raccomanda vivamente di proteggere le variabili con le virgolette, come nell'esempio seguente:

```bash
file=file name
touch $file
touch "$file"
```

Poiché il contenuto della variabile contiene uno spazio, il primo `touch` creerà 2 file, mentre il secondo `creerà` un file il cui nome conterrà uno spazio.

Per isolare il nome della variabile dal resto del testo, è necessario utilizzare le virgolette o le parentesi graffe:

```bash
file=file_name
touch "$file"1
touch ${file}1
```

**Si raccomanda l'uso sistematico di parentesi graffe.**

L'uso degli apostrofi impedisce l'interpretazione dei caratteri speciali.

```bash
message="Hello"
echo "This is the content of the variable message: $message"
Here is the content of the variable message: Hello
echo 'Here is the content of the variable message: $message'
Here is the content of the variable message: $message
```

## Cancellare e bloccare le variabili

Il comando `unset` consente di cancellare una variabile.

Esempio:

```bash
name="NAME"
firstname="Firstname"
echo "$name $firstname"
NAME Firstname
unset firstname
echo "$name $firstname"
NAME
```

Il comando `readonly` o `typeset -r` blocca una variabile.

Esempio:

```bash
name="NAME"
readonly name
name="OTHER NAME"
bash: name: read-only variable
unset name
bash: name: read-only variable
```

!!! Note "Nota"

    Un `set -u` all'inizio dello script interromperà l'esecuzione dello script se vengono utilizzate variabili non dichiarate.

## Utilizzare le variabili d'ambiente

Le**variabili d'ambiente** e di **sistema** sono variabili utilizzate dal sistema per il suo funzionamento. Per convenzione, i nomi sono indicati con lettere maiuscole.

Come tutte le variabili, possono essere visualizzate durante l'esecuzione di uno script. Anche se ciò è fortemente sconsigliato, possono essere modificati.

Il comando `env` visualizza tutte le variabili d'ambiente utilizzate.

Il comando `set` visualizza tutte le variabili di sistema utilizzate.

Tra le decine di variabili d'ambiente, alcune sono interessanti da usare in uno script di shell:

| Variabili                     | Descrizione                                                                 |
| ----------------------------- | --------------------------------------------------------------------------- |
| `HOSTNAME`                    | Nome host della macchina.                                                   |
| `USER`, `USERNAME`e `LOGNAME` | Nome dell'utente connesso alla sessione.                                    |
| `PATH`                        | Percorso per trovare i comandi.                                             |
| `PWD`                         | Directory corrente, aggiornata ogni volta che viene eseguito il comando cd. |
| `HOME`                        | Directory di accesso.                                                       |
| `$$`                          | Id del processo di esecuzione dello script.                                 |
| `$?`                          | Codice di ritorno dell'ultimo comando eseguito.                             |

Il comando `export` consente di esportare una variabile.

Una variabile è valida solo nell'ambiente del processo di script della shell. Affinché i **processi figli** dello script riconoscano le variabili e il loro contenuto, devono essere esportati.

La modifica di una variabile esportata in un processo figlio non può essere ricondotta al processo padre.

!!! note "Nota"

    Senza alcuna opzione, il comando `export` visualizza il nome e i valori delle variabili esportate nell'ambiente.

## Comandi sostitutivi

È possibile memorizzare il risultato di un comando in una variabile.

!!! Note "Nota"

    Questa operazione è valida solo per i comandi che restituiscono un messaggio al termine della loro esecuzione.

La sintassi per la sub-esecuzione di un comando è la seguente:

```bash
variable=`command`
variable=$(command) # Preferred syntax
```

Esempio:

```bash
day=`date +%d`
homedir=$(pwd)
```

Con tutto ciò che abbiamo appena visto, il nostro script di backup potrebbe assomigliare a questo:

```bash
#!/usr/bin/env bash

#
# Author : Rocky Documentation Team
# Date: March 2022
# Version 1.0.0: Save in /root the files passwd, shadow, group, and gshadow
# Version 1.0.1: Adding what we learned about variables
#

# Global variables
FILE1=/etc/passwd
FILE2=/etc/shadow
FILE3=/etc/group
FILE4=/etc/gshadow

# Destination folder
DESTINATION=/root

## Readonly variables
readonly FILE1 FILE2 FILE3 FILE4 DESTINATION

# A folder name with the day's number
dir="backup-$(date +%j)"

# Clear the screen
clear

# Launch the backup
echo "****************************************************************"
echo "     Backup Script - Backup on ${HOSTNAME}                      "
echo "****************************************************************"
echo "The backup will be made in the folder ${dir}."
echo "Creating the directory..."
mkdir -p ${DESTINATION}/${dir}

echo "Starting the backup of ${FILE1}, ${FILE2}, ${FILE3}, ${FILE4} to ${DESTINATION}/${dir}:"

cp ${FILE1} ${FILE2} ${FILE3} ${FILE4} ${DESTINATION}/${dir}

echo "Backup ended!"

# The backup is noted in the system event log:
logger "Backup of system files by ${USER} on ${HOSTNAME} in the folder ${DESTINATION}/${dir}."
```

Esecuzione dello script di backup:

```bash
sudo ./backup.sh
```

questo ci darà:

```bash
****************************************************************
     Backup Script - Backup on desktop                      
****************************************************************
The backup will be made in the folder backup-088.
Creating the directory...
Starting the backup of /etc/passwd, /etc/shadow, /etc/group, /etc/gshadow to /root/backup-088:
Backup ended!
```
