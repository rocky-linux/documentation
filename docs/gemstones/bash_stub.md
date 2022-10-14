---
title: bash - Script Stub
author: Steven Spencer
contributors: Ezequiel Bruni
---

# Bash - Script Stub

Where I was previously employed, we had an ace programmer who knew a bunch of languages. He was also the go-to guy when you had questions on how to accomplish something with a script. He finally created a little stub, a file full of scripting examples that you could just strip out and edit as needed. Eventually, I got good enough at these routines that I didn't have to look at the stub, but it was a good learning tool, and something that others may find useful.

## The Actual Stub

The stub is well documented, but keep in mind that this is by no means an exhaustive script! There are a lot more routines that could be added. If **you** have examples that would fit nicely into this stub, then please feel free to add some changes:

```
#!/bin/sh

# By exporting the path, this keeps you from having to enter full paths for commands that exist in those paths:

export PATH="$PATH:/bin:/usr/bin:/usr/local/bin"

# Determine and save absolute path to program directory.
# Attention! In bash, the ' 'represents the string itself; But " " is a little different. $, ` `, and \ represent call variable values, reference commands, and escape characters, respectively
# When done will be in same directory as script:

PGM=`basename $0`				# Name of the program
CDIR=`pwd`					# Save directory program was run from

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

Scripting is a System Administrator's friend. Being able to quickly do certain tasks in a script streamlines process completion. While by no means an exhaustive set of script routines, this stub offers some common usage examples.
