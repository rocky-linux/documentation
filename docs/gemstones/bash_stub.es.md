---
title: bash - Script Stub
author: Steven Spencer, Pedro Garcia
contributors: Ezequiel Bruni, Pedro Garcia
---

# Bash - Script Stub

En el lugar en el que trabajé anteriormente, teníamos un programador experto que conocía un montón de lenguajes. También era la persona a la que se recurría cuando se tenía alguna duda sobre cómo realizar algo con un script. Finalmente creó un pequeño <0>stub</0>, un archivo lleno de ejemplos de scripting que podías destripar y editar según la necesidad. Con el tiempo, llegué a ser lo suficientemente bueno en estas rutinas como para no tener que mirar el <0>stub</0>, pero fue una herramienta de aprendizaje buena, y algo que otros pueden encontrar útil.

## El Stub

¡El stub está bien documentado, pero ten en cuenta que no se trata en absoluto de un script exhaustivo! Se podrían añadir muchas más rutinas. Si **usted** tiene ejemplos que encajen bien en este stub siéntase libre de sugerir/añadir algunos cambios:

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

## Conclusión

El scripting es el amigo del administrador del sistema. La posibilidad de realizar rápidamente ciertas tareas en un script agiliza la finalización del proceso. Aunque no es en absoluto un conjunto exhaustivo de rutinas de script, este stub ofrece algunos ejemplos de uso común.
