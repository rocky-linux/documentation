---
title: bash - Ébauche de script
author: Steven Spencer
contributors: Ezequiel Bruni
---

# Bash - Ébauche de script

Là où l'auteur était précédemment employé, nous avions un programmeur as qui connaissait un tas de langages de programmation. Il était aussi le gars à consulter quand vous aviez eu des questions sur la façon d'accomplir quelque chose avec un script. Il a finalement créé une petite ébauche, un fichier plein d'exemples de scripts que vous pourriez tout simplement supprimer et éditer au besoin. Finalement, l'auteur est devenu assez expérimenté dans ces routines pour ne pas avoir à consulter l'exemple, mais c'était un bon outil d'apprentissage et quelque chose que d'autres pourraient trouver utile.

## L' ébauche

L'exemple est bien documenté, mais gardez à l'esprit qu'il ne s'agit en aucun cas d'un script exhaustif ! Il y a beaucoup de routines qui pourraient être ajoutées. Si **vous** avez des exemples qui s'intègreraient bien dans cette ébauche, alors n'hésitez pas à ajouter des modifications :

```bash
#!/bin/sh

# By exporting the path, this keeps you from having to enter full paths for commands that exist in those paths:

export PATH="$PATH:/bin:/usr/bin:/usr/local/bin"

# Determine and save absolute path to program directory.
# Attention ! En bash, le ' 'représente la chaîne elle-même; mais " " est un peu différent. $, ` `, and \ represent call variable values, reference commands, and escape characters, respectively
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

## Conclusion

Scripting is a System Administrator's friend. Être capable de faire rapidement certaines tâches dans un script rationalise la réalisation du processus. Bien qu'il ne s'agisse pas d'un ensemble exhaustif de routines de scripts, ce conteneur offre quelques exemples d'utilisation courante.
