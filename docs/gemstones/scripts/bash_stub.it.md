---
title: bash - Script Stub
author: Steven Spencer
contributors: Ezequiel Bruni, Franco Colussi
---

# Bash - Script Stub

Dove lavoravo prima, avevamo un programmatore eccezionale che conosceva un sacco di linguaggi. Era anche l'uomo di riferimento quando si avevano domande su come realizzare qualcosa con uno script. Alla fine ha creato un piccolo stub, un file pieno di esempi di scripting da cui è possibile attingere e modificare a seconda delle necessità. Alla fine sono diventato abbastanza bravo in queste routine da non dover guardare lo stub, ma è stato un buon strumento di apprendimento e qualcosa che altri potrebbero trovare utile.

## Lo Stub Effettivo

Lo stub è ben documentato, ma si tenga presente che questo non è assolutamente uno script esaustivo! Si potrebbero aggiungere molte altre routine. Se **avete** esempi che si adattano bene a questo stub, sentitevi liberi di aggiungere qualche modifica:

```
#!/bin/sh

# By exporting the path, this keeps you from having to enter full paths for commands that exist in those paths:

export PATH="$PATH:/bin:/usr/bin:/usr/local/bin"

# Determine and save absolute path to program directory.
# Attention! In bash, ' ' rappresenta la stringa stessa; ma " " è un po' diverso. $, ` ` e \ rappresentano rispettivamente i valori delle variabili di chiamata, i comandi di riferimento e i caratteri di escape
# When done will be in same directory as script

PGM=`basename $0`               # Name of the program
CDIR=`pwd`                  # Save directory program was run from

PDIR=`dirname $0`
cd $PDIR
PDIR=`pwd`

# If a program accepts filenames as arguments, this will put us back where we started.
# (Needed so references to files using relative paths work.):

cd $CDIR

# Use this if script must be run by certain user:

runby="root"
iam=`/usr/bin/id -un`
if [ $iam != "$runby" ]
then
    echo "$PGM : program must be run by user \"$runby\""
    exit
fi

# Check for missing parameter.
# Display usage message and exit if it is missing:

if [ "$1" = "" ]
then
    echo "$PGM : parameter 1 is required"
    echo "Usage: $PGM param-one"
    exit
fi

# Prompt for data (in this case a yes/no response that defaults to "N"):

/bin/echo -n "Do you wish to continue? [y/N] "
read yn
if [ "$yn" != "y" ] && [ "$yn" != "Y" ]
then
    echo "Cancelling..."
    exit;
fi

# If only one copy of your script can run at a time, use this block of code.
# Check for lock file.  If it doesn't exist create it.
# If it does exist, display error message and exit:

LOCKF="/tmp/${PGM}.lock"
if [ ! -e $LOCKF ]
then
    touch $LOCKF
else
    echo "$PGM: cannot continue -- lock file exists"
    echo
    echo "To continue make sure this program is not already running, then delete the"
    echo "lock file:"
    echo
    echo "    rm -f $LOCKF"
    echo
    echo "Aborting..."
    exit 0
fi

script_list=`ls customer/*`

for script in $script_list
do
    if [ $script != $PGM ]
    then
        echo "./${script}"
    fi
done

# Remove the lock file

rm -f $LOCKF
```

## Conclusione

Lo scripting è un amico dell'amministratore di sistema. La possibilità di eseguire rapidamente determinate operazioni in uno script semplifica il completamento dei processi. Pur non essendo un insieme esaustivo di routine di script, questo stub offre alcuni esempi di utilizzo comune.
