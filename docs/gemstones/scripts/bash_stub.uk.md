---
title: bash - Script Stub (заглушка сценарію)
author: Steven Spencer
contributors: Ezequiel Bruni
---

# bash - Script Stub (заглушка сценарію)

Там, де я раніше працював, у нас був досвідчений програміст, який знав купу мов. До нього також зверталися, коли у вас виникали запитання про те, як чогось досягти за допомогою сценарію. Нарешті він створив маленьку заглушку, файл, повний прикладів сценаріїв, які ви можете просто вирізати та редагувати за потреби. Згодом я достатньо добре навчився цим процедурам, тому мені не довелося дивитися на заглушку, але це був хороший інструмент для навчання та те, що інші можуть вважати корисними.

## The Actual Stub (Фактична заглушка)

Заглушка добре задокументована, але майте на увазі, що це аж ніяк не вичерпний сценарій! Є багато інших процедур, які можна додати. Якщо **у вас** є приклади, які чудово впишуться в цю заглушку, будь ласка, додайте деякі зміни:

```
#!/bin/sh

# By exporting the path, this keeps you from having to enter full paths for commands that exist in those paths:

export PATH="$PATH:/bin:/usr/bin:/usr/local/bin"

# Determine and save absolute path to program directory.
# Attention! In bash, the ' 'represents the string itself; But " " is a little different. $, ` `, and \ represent call variable values, reference commands, and escape characters, respectively
# When done will be in same directory as script:

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

## Висновок

Сценарій - друг системного адміністратора. Можливість швидкого виконання певних завдань у сценарії спрощує завершення процесу. Хоча це далеко не вичерпний набір підпрограм сценаріїв, ця заглушка пропонує деякі загальні приклади використання.
