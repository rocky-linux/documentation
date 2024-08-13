---
title: bash - Script Vorlage
author: Steven Spencer
contributors: Ezequiel Bruni
---

# bash - Skript Vorlage

Wo iwir zuvor beschäftigt waren, hatten wir einen Top-Programmierer, der eine Reihe von Sprachen kannte. Er war auch der go-to guy, wenn wir Fragen hatten, wie man etwas mit einem Skript erledigen kann. Er hat schließlich einen kleinen Stub, eine Datei voller Skriptbeispiele, die wir einfach nach Bedarf anpassen und bearbeiten konnten. Letztendlich haben wir diese Routinen gut genug gemacht, dass wir nicht mehr auf den Stub schauen mussten, aber es war ein gutes Lernwerkzeug, und etwas, das andere für nützlich halten könnten.

## Der Aktuelle Stub

Der Stub ist gut dokumentiert, aber beachten Sie, dass dies keineswegs ein vollständiges Skript ist! Es gibt noch viel mehr Routinen, die hinzugefügt werden könnten. Wenn **Sie** Beispiele haben, die gut in diesen Stub passen würden, dann fügen bitte Ihre Änderungen hinzu:

```bash
#!/bin/sh

# By exporting the path, this keeps you from having to enter full paths for commands that exist in those paths:

export PATH="$PATH:/bin:/usr/bin:/usr/local/bin"

# Determine and save absolute path to program directory.
# Achtung! In bash stellt die beiden Apostrophen ' ' die Zeichenkette selbst dar; aber " " ist etwas anders. $, ` `, and \ represent call variable values, reference commands, and escape characters, respectively
# When done will be in same directory as script:

PGM=`basename $0` # Name of the program
CDIR=`pwd` # Save directory program was run from

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

## Zusammenfassung

Scripting ist ein Freund des Systemadministrators. Mit einem Skript können bestimmte Aufgaben schnell erledigt werden, um die Bearbeitung von Prozessen zu vereinfachen. Dieser Stub bietet zwar keineswegs eine ausführliche Reihe von Skript-Routinen, aber einige gängige Anwendungsbeispiele.
