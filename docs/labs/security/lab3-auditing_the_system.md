---
Title:  Lab 3 - Auditing the System
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
---

# Lab 3 - Auditing the System

## Objectives

After completing this lab, you will be able to:

- create a simple and custom auditing tool from scratch
- use and understand security auditing tools like Tripwire

Estimated time to complete this lab: 90 minutes

## A simple home grown integrity checker

Before installing and configuring Tripwire, we create a sample script that performs a similar function. This script will help in gaining a better understanding of how Tripwire and similar tools function.

The script relies heavily on the md5sum program. The md5sum program is used to compute a 128-bit checksum (or "fingerprint") for a specified FILE.

The script functions’ as summarized below:

1. Right after the base system has been installed, it will back up some of the system configuration files in the /etc directory, into a directory called  etc.bak in roots home directory.

    In particular it will back up all the files under /etc with the suffix “*.conf”

    It does this when run with the initialization option ( -- initialization| -i)

2. The script will then obtain the md5 checksums of the known suitable files (untainted files).

3. The list of MD5 sums will be stored in a file called “md5_good”.

4. When the script is run in a verify mode, the md5sum program will be called with the “ - -check” option to check the current MD5 sums against a given list (the md5_good file).

    The script will print the verification output to the standard output and send a copy of the result via e-mail to the superuser.

5. Whenever changes are made (legal or illegal) to the configuration files under /etc the script can be called with the `--rebuild| -r` option to approve the changes and rebuild the baseline pseudo database.

6. You can periodically run the script manually or create a cron job to automatically run the script.

The script below can be fine-tuned and scaled to do much more than it does. It is left to you and your imagination to make it do whatever you want.

If you just want a quick and dirty way to get the job done the script will suffice but for everything else there is Tripwire.  

## Exercise 1

1. Log in as root and launch your text editor of choice. Enter the text below:

```bash

#!/bin/sh
# This script checks for changes in the MD5 sums of files named "/etc/*.conf"

case $1 in
    -i|--initialize)
        # This section will run if the script is run in an initialization mode
        # Delete old directory, make directory, backup good files, and change directory to /root/etc.bak

        rm -rf /root/etc.bak
        mkdir /root/etc.bak
        cp /etc/*.conf /root/etc.bak
        cd /root/etc.bak

        # Create our baseline file containing a list of good MD5 sums

        for i in /etc/*.conf; do
            md5sum $i >> md5_good
        done
        echo -e "\nUntainted baseline file (~/etc.bak/md5_good) has been created !!\n"
        ;;

    -v|--verify)
        # This section will run if the script is called in a verify mode
        cd /root/etc.bak

        # Check if there is any file containing output from a previous run

        if [ -f md5_diffs ]; then
            rm -f md5_diffs # if it exists we delete it
        fi

        # We re-create the file with a pretty sub-heading and some advice

        echo -e "\n **** Possibly tainted File(s) ****\n" > md5_diffs

        # Run the md5sum program against a known good list i.e. "md5_good" file

        md5sum -c md5_good 2> /dev/null | grep FAILED >> md5_diffs
        if [ $? -ge 1 ]; then
            echo "Nothing wrong here."
        else
            # Append some helpful text to the md5_diffs file

            echo -e "\nUpdate the baseline file if you approve of the changes to the file(s) above \n" >> md5_diffs
            echo -e "Re-run the script with the re-build option (e.g. ./check.sh --rebuild) to approve \n" >> md5_diffs

            cat md5_diffs # print the md5_diffs file to the display
            if [ -x /usr/bin/mail ]; then
                mail -s "Changed Files" root < md5_diffs # also e-mail the md5_diffs file to root
            fi
        fi
        ;;

    -r|--rebuild)
        # This section is for re-building the Baseline file just in case
        # the changes to the configuration files are legal and sanctioned

        cd /root/etc.bak/
        mv md5_good md5_good.bak # make a backup copy of the current untainted baseline file

        for j in /etc/*.conf; do
            md5sum $j >> md5_good
        done
        echo -e "\nBaseline file updated with approved changes !!!\n"
        ;;

    *)
        echo "This script accepts: only ( -i|--initialize or -v|--verify or -r|--rebuild ) parameters"
        ;;
esac

```

Save the text above in a text file and name the file “check.sh”

### To use the check.sh script

1. Create a directory under root’s home directory called “scripts”

2. Copy the script you created above into your scripts directory.

3. Make the script executable.

4. Run the script with the initialization option. Type:

    ```bash
    [root@localhost scripts]# ./check.sh -i

    Untainted baseline file (~/etc.bak/md5_good) has been created !!
    ```

5. Use the `ls` command to view contents of root’s home directory. You should have a new directory named `etc.bak` therein.
   Use the `cat` command to view the `/root/etc.bak/md5_good` file.

6. Run the script using the verify option. Type:

    ```bash
    [root@localhost scripts]# ./check.sh -v

    Nothing wrong here.
    ```

    You should get the output above if all is well.

7. You will deliberately alter the `/etc/kdump.conf` files under the `/etc` directory. Type:

    ```bash
    [root@localhost scripts]# echo "# This is just a test" >> /etc/kdump.conf
    ```

8. Now run the check.sh script again in verification mode. Type:

    ```bash
    [root@localhost scripts]# ./check.sh -v
    ****
    
    /etc/kdump.conf: FAILED
    
    Update the baseline file if you approve of the changes to the file(s) above
    
    Re-run the script with the re-build option (e.g. ./check.sh  --rebuild) to approve
    ```

9. Per the warning above, you should investigate further to see if the altered file meets your approval. If it does, you may run the script with a `--rebuild` option.
    To view only the differences between the “tainted” file and the “untainted” file you could type:

    ```bash
    [root@localhost scripts]# sdiff -s /etc/kdump.conf  /root/etc.bak/kdump.conf
    ```

## Tripwire

One of the first things you should do after building any new system is to get a snapshot of a known good state of the system before the system is “contaminated” or before deploying the system into production.

Several tools exist for doing this. One such tool is Tripwire. Tripwire is an advanced tool, so brace yourself for many options, syntax, quirks, and switches.

Tripwire can be regarded as a form of a host-based intrusion detection system (IDS). It performs intrusion detection functions by taking a snapshot of a "healthy system" and later comparing this healthy state with any other suspect states. It provides a means of knowing/monitoring whether certain sensitive files have been altered illegally. The system administrator of course decides what files are to be monitored.

The authors of Tripwire describe it as an Open Source Security, Intrusion Detection, Damage Assessment and Recovery, and Forensics software.

Tripwire compares a file’s new signature with the one taken when the database was created.

The steps involved in installing and configuring Tripwire are as listed below:

1. Install the software from the source or binary

2. Run the configuration script: (twinstall.sh). This script is used to:
a) Create the site key, local key, and prompts for passphrases for both
b) Sign the policy file and configuration file with the site key

3. Initialize the Tripwire database

4. Run the first integrity check.

5. Edit the configuration file (twcfg.txt)

6. Edit the policy file (twpol.txt)

Tripwire accepts the following command line options:

**Database Initialization mode:**

```bash

       -m i            --init
       -v              --verbose
       -s              --silent, --quiet
       -c cfgfile      --cfgfile cfgfile
       -p polfile      --polfile polfile
       -d database     --dbfile database
       -S sitekey      --site-keyfile sitekey
       -L localkey     --local-keyfile localkey
       -P passphrase   --local-passphrase passphrase
       -e              --no-encryption
```

**Integrity Checking mode:**

```bash

           -m c                  --check
           -I                    --interactive
           -v                    --verbose
           -s                    --silent, --quiet
           -c cfgfile            --cfgfile cfgfile
           -p polfile            --polfile polfile
           -d database           --dbfile database
           -r report             --twrfile report
           -S sitekey            --site-keyfile sitekey
           -L localkey           --local-keyfile localkey
           -P passphrase         --local-passphrase passphrase
           -n                    --no-tty-output
           -V editor             --visual editor
           -E                    --signed-report
           -i list               --ignore list
           -l { level | name }   --severity { level | name }
           -R rule               --rule-name rule
           -x section            --section section
           -M                    --email-report
           -t { 0|1|2|3|4 }      --email-report-level { 0|1|2|3|4 }
           -h                    --hexadecimal
           [ object1 [ object2... ]]
```

**Database Update mode:**

```bash
 -m u                --update
           -v                  --verbose
           -s                  --silent, --quiet
           -c cfgfile          --cfgfile cfgfile
           -p polfile          --polfile polfile
           -d database         --dbfile database
           -r report           --twrfile report
           -S sitekey          --site-keyfile sitekey
           -L localkey         --local-keyfile localkey
           -P passphrase       --local-passphrase passphrase
           -V editor           --visual editor
           -a                  --accept-all
           -Z { low | high }   --secure-mode { low | high }
```

**Policy Update mode:**

```bash
 -m p                --update-policy
           -v                  --verbose
           -s                  --silent, --quiet
           -c cfgfile          --cfgfile cfgfile
           -p polfile          --polfile polfile
           -d database         --dbfile database
           -S sitekey          --site-keyfile sitekey
           -L localkey         --local-keyfile localkey
           -P passphrase       --local-passphrase passphrase
           -Q passphrase       --site-passphrase passphrase
           -Z { low | high }   --secure-mode { low | high }
           policyfile.txt
```

**Summary Of Options for the `tripwire` command:**

```bash
SYNOPSIS
  Database Initialization:    tripwire { -m i | --init } [ options... ]
  Integrity Checking:    tripwire { -m c | --check } [ options... ]
            [ object1 [ object2... ]]
  Database Update:      tripwire { -m u | --update } [ options... ]
  Policy update:     tripwire { -m p | --update-policy } [ options... ]
            policyfile.txt
  Test:     tripwire { -m t | --test } [ options... ]

```

### `twadmin`

The `twadmin` utility performs administrative functions related to Tripwire files and configuration options. Specifically, `twadmin` allows encoding, decoding, signing, and verification of Tripwire files, and provides a means to generate and change local and site keys.

```bash
Create Configuration File:  twadmin [-m F|--create-cfgfile][options] cfgfile.txt
Print Configuration File:   twadmin [-m f|--print-cfgfile] [options]
Create Policy File:     twadmin [-m P|--create-polfile] [options] polfile.txt
Print Policy File:     twadmin [-m p|--print-polfile] [options]
Remove Encryption:     twadmin [-m R|--remove-encryption] [options] [file1...]
Encryption:       twadmin [-m E|--encrypt] [options] [file1...]
Examine Encryption:     twadmin [-m e|--examine] [options] [file1...]
Generate Keys:       twadmin [-m G|--generate-keys] [options]
```

### `twprint`

Prints Tripwire database and report files in plain text format.

**Print Report mode:**

```bash
-m r                     --print-report
-v                       --verbose
-s                       --silent, --quiet
-c cfgfile            --cfgfile cfgfile
-r report              --twrfile report
-L localkey            --local-keyfile localkey
-t { 0|1|2|3|4 }       --report-level { 0|1|2|3|4 }
```

**Print Database mode:**

```bash
-m d                   --print-dbfile
-v                       --verbose
-s                       --silent, --quiet
-c cfgfile             --cfgfile cfgfile
-d database            --dbfile database
-L localkey            --local-keyfile localkey
[object1 [object2 ...]
```

### `siggen`

`siggen` is a signature-gathering routine for Tripwire. It is a utility that displays the hash function values for the specified files.

```bash
OPTIONS
       ‐t, --terse
              Terse mode.  Prints requested hashes for a given file on one line, delimited by spaces, with no extraneous information.

       ‐h, --hexadecimal
              Display results in hexadecimal rather than base64 notation.

       ‐a, --all
              Display all hash function values (default).

       ‐C, --CRC32
              Display CRC-32, POSIX 1003.2 compliant 32-bit Cyclic Redundancy Check.

       ‐M, --MD5
              Display MD5, the RSA Data Security, Inc. Message Digest Algorithm.

       ‐S, --SHA
              Display SHA, Tripwire's implementation of the NIST Secure Hash Standard, SHS (NIST FIPS 180).

       ‐H, --HAVAL
              Display Haval value, a 128-bit hash code.

       file1 [ file2... ]
              List of filesystem objects for which to display values.
```

## Exercise 2

### To install Tripwire

1. Check to see if you already have Tripwire installed on your system. Type:

    ```bash
    [root@localhost root]# rpm -q tripwire
    tripwire-*
    ```

    If you get an output similar to the one above, you already have it installed. Skip the next step.

2. If you do not have it installed, obtain the Tripwire binary and install it. Type:

    ```bash
    [root@localhost root]# dnf -y install tripwire
    ```

### To configure Tripwire

Configuring Tripwire involves (if needed) customizing the Tripwire configuration file, the policy file, and then running the configuration script. The script will prompt you for a passphrase that will be used to sign/protect the configuration file, the policy file and the database file.

1. Change your pwd to Tripwire’s working directory: Type:

    ```bash
    [root@localhost  root]# cd /etc/tripwire/
    ```

2. List the contents of the directory.

3. Use any pager or text editor to view/study the files in the directory.

4. We will accept the settings that come with the default configuration. file (twcfg.txt) and the provided default policy file (twpol.txt) for now.

5. Execute the Tripwire configuration utility as root. You will be prompted (twice) for site keyfile passphrase. Select any passphrase that you WILL NOT  forget ( The site key is meant for the twcfg.txt file and the twpol.txt file) Type:

    ```bash
    [root@localhost tripwire]# tripwire-setup-keyfiles
    .....
    Enter the site keyfile passphrase:
    Verify the site keyfile passphrase:
    ......
    Generating key (this may take several minutes)...Key generation complete.
    ```

    Next you will be prompted for a local key. Again select another password YOU WILL not forget. (The local key signs the Tripwire database files and the reports files)

    ```bash
    Enter the local keyfile passphrase:
    Verify the local keyfile passphrase:
    ....
    Generating key (this may take several minutes)...Key generation complete.
    
    ```

    After choosing your passphrases the `tripwire-setup-keyfiles` program will then proceed with the actual creation/signing of the encrypted versions of the original plain text files ( i.e  tw.cfg and tw.pol will be created respectively). You will be prompted again for the passphrases you choose earlier. At this point just follow the prompts until the script exits.

    ```bash
    ----------------------------------------------
    Signing configuration file...
    Please enter your site passphrase: ********
    
    ----------------------------------------------
    Signing policy file...
    Please enter your site passphrase: ********
    ......
    
    Wrote policy file: /etc/tripwire/tw.pol
    ```

    !!! question "Lab task:"

        List the new contents of the /etc/tripwire directory.

6. Per the warning you got while the `tripwire-setup-keyfiles` utility was running, you will now move the plain text versions of the configuration file and policy files away from the local system. You could store them on an external removal medium or encrypt them in place (using a tool like GPG for example) OR completely delete them if you are feeling particularly daring. Type:

    ```bash
    [root@localhost tripwire]# mkdir /root/tripwire_stuff && mv twcfg.txt twpol.txt /root/tripwire_stuff
    ```

!!! note

    It may be useful to keep the plain text versions in safe place incase you forget your passphrases. You can then always re-run the `tripwire-setup-keyfiles` based on the configurations and policies you have fine-tuned over time.

### To initialize the database

Initializing the database is the Tripwire terminology for, taking an initial “untainted” snapshot of the files you have decided to monitor (based on the policy file). This generates the database and also signs the database with the local key. The database serves as the baseline for all future integrity checks.

1. While still logged in as root type:

    ```bash
    [root@localhost tripwire]# tripwire --init
    
    Please enter your local passphrase:
    Parsing policy file: /etc/tripwire/tw.pol
    Generating the database...
    *** Processing Unix File System ***
    
    ```

    Enter your local passphrase when prompted. The database creation will run to conclusion and you should get an output similar to the one below:

    **The database was successfully generated.**

2. Use the `ls` command to verify that the database was created under the stated location. Type:

    ```bash
    [root@localhost tripwire]# ls -lh /var/lib/tripwire/$(hostname).twd
    -rw-r--r--. 1 root root 3.3M Sep 27 18:35 /var/lib/tripwire/localhost.twd
    ```

## Exercise 3

### Integrity checking and viewing reports

In this exercise you will learn how to run an integrity check of the system and view the reports that Tripwire generates for you.

### To run an integrity check

Running Tripwire in this mode (integrity check mode) compares the current file system objects with their properties in the Tripwire database. Discrepancies between the database and the current file system objects are printed to the standard output while Tripwire runs in this mode. After the check is complete Tripwire also generates a report file in the directory specified in the twcfg.txt file (/var/lib/tripwire/report/).

1. Run an integrity check. Type:

    ```bash
    [root@localhost tripwire]# tripwire --check
    ```

    You'll see some [expected] warnings stream by during this check.

    Check under the `/var/lib/tripwire/report` directory to see if a report was also created in there for you.

    !!! question "Lab task:"

        Write down the name of the report file that was created.
              
        FILE_NAME =

2. Run the integrity check again but manually specify a file name for the report file. Type:

    ```bash
    [root@localhost tripwire]# tripwire -m c -r /root/tripwire_report.twr
    ```

3. Ensure that a new file was created under root’s home directory. Type:

    ```bash
    [root@localhost tripwire]# ls -l /root/tripwire_report.twr
    ```

### To examine the report

Tripwire’s report files, are a collection of rule violations discovered during an integrity check.

There are several ways to view a Tripwire report file:

- during integrity check
- in the form of an email automatically sent to you
- using the `twprint` command provided with the Tripwire package

!!! note

    You probably noticed from the earlier exercise that Tripwire uses a combination of the systems FQDN name, the date, and the time to name the report files by default.

1. First change to the default report’s directory and view the default report created for you in step 1  above ( FILE_NAME). Type:

    ```bash
    [root@localhost report]# cd /var/lib/tripwire/report && twprint --print-report -r <FILE_NAME>
    ```

    Replace <FILE_NAME> above with the value you noted earlier.

    To use the short form of the above command type:

    ```bash
    [root@localhost report]# twprint -m r -r <FILE_NAME> | less
    ```

    We pipe the output to the less command because the report scrolls by quickly.

2. Now view the other report you created manually, under root’s home directory. Type:

    ```bash
    [root@localhost root]# cd && twprint --print-report -r /root/tripwire_report.twr | less
    ```

3. Brace yourself and study the output of the report file carefully.

4. You should have noticed again that Tripwire created binary/data forms of the report files. Create a text only version of the report file under roots home directory. Type:

    ```bash
    [root@localhost root]# twprint --print-report -r /root/tripwire_report.twr > tripwire_report.txt
    ```

### To view the reports via e-mail

Here you will test the e-mail functionality of Tripwire. Tripwire’s e-mail notification system uses the setting specified in the Tripwire configuration file. (twcfg.txt).

1. First view the configuration file and note the variable(s), that control Tripwire’s e-mail notification system. To view the configuration file type:

    ```bash
    [root@localhost report]# twadmin  -m f | less
    ```

    !!! question "Lab task:"

        Write down the relevant variable(s).

2. Next, ensure that your local mail system is up and running by checking the status of say postfix. Type:

    ```bash
    [root@localhost report]# systemctl -n 0 status postfix
    .......
         Active: active (running) since Thu 2023-08-31 16:21:26 UTC; 3 weeks 6 days ago
    .......
    ```

    Your output should be similar to the above. If  your mailing system is not running, troubleshoot that first and get it up and running before continuing.

3. Send a test message to root. Type:

    ```bash
    [root@localhost report]# tripwire --test --email root
    ```

4. Use the mail program to check root’s mail. Type:

    ```bash
    [root@localhost report]# mail
    ```

    The superuser should have a message with the subject "Test email message from Tripwire"

5. After you have confirmed that the e-mail functionality works you could try manually sending a copy of one of the reports to yourself.

    !!! question

        What was the command to do this?

### Fine-tuning Tripwire

After installing Tripwire, taking a snapshot of the system and then running the first integrity check you will more likely than not need to fine-tune Tripwire to suit the needs of your particular environment.
This is mostly because the default configuration and policy file that comes bundled with Tripwire may not exactly fit your needs or reflect the actual objects on your file system.

You need to ascertain if the file system violations reported in the report file during the integrity check are actual violations or legitimate/authorized changes to your file system objects.
Again Tripwire offers several ways of doing this.

### Updating the policy file

Using this method you will change or fine-tune what Tripwire considers violations to your file system objects by changing the rules in the policy file. The database can then be updated without a complete re-initialization. This saves time and preserves security by keeping the policy file synchronized with the database it uses.

You will use the report file you created earlier ( /root/tripwire_report.txt ) to fine-tune your policy file by first preventing Tripwire from reporting the absence of files that were never on the filesystem in the first place.

This will help to greatly reduce the length of the report file that you have to manage.

#### To fine-tune Tripwire

1. Use the grep command to filter out all lines in the report file that refers to missing files (i.e. Lines containing the word “Filename”). Redirect the output to another file - tripwire_diffs.txt. Type:

    ```bash
    [root@localhost root]# grep Filename  /root/tripwire_report.txt > tripwire_diffs.txt
    ```

2. View the contents of the file you created above. Type:

    ```bash
    [root@localhost root]# less tripwire_diffs.txt
    207:     Filename: /proc/scsi
    
    210:     Filename: /root/.esd_auth
    
    213:     Filename: /root/.gnome_private
    
    216:     Filename: /sbin/fsck.minix
    
    219:     Filename: /sbin/mkfs.bfs
    ..................................
    ```

3. Now you need to edit the Tripwire policy file and comment out or delete the entries in the file that should not be in there. For example, some files are not on your system, and some never will be. One of the files, for example, that the policy file is trying to monitor is the /proc/scsi file. If you do not have any SCSI devices on your system, then there is no sense in monitor this file.

    Another debatable example of what to monitor or not to monitor is the various lock files under the `/var/lock/subsys/` directory. Choosing to monitor these files should be a personal call.

    Re-create a text version of the policy file - just in case you removed it (as advised ) from the local system. Type:

    ```bash
    [root@localhost root]# twadmin --print-polfile  > twpol.txt
    ```

4. Edit the text file you created above using any text editor. Comment out references to objects that you do not want to monitor. You can use the tripwire_diffs.txt file you created earlier as a guideline. Type:

    ```bash
    [root@localhost  root]# vi twpol.txt
    ```

    Save your changes to the file and close it.

5. Run `tripwire` in policy file update mode. Type:
  
    ```bash
    [root@localhost root]# tripwire  --update-policy   /root/twpol.txt
    ```

    Enter your local and site passphrases when prompted.

    A new signed and encrypted policy file will be created for you under the `/etc/tripwire/` directory.

6. Delete or remove the text version of the policy file from your local system.

7. Running the command in step 5 above will also have created a report file for you under the `/var/lib/tripwire/report directory`.

    !!! Question "Lab task:"

        Write down the name of your latest report file.

        <LATEST_REPORT>

8. Run an integrity check of the system again until you are satisfied that you have a good baseline of the system, with which to make future decisions.

    !!! Question

        What is the command to do this?

### Updating the database

Running `tripwire` in the database update mode after an integrity check provides a quick and dirty way to fine tune Tripwire. This is because Database Update mode allows any differences between the database and the current system to be reconciled.  This will prevent the violations from showing up in future reports.

This update process saves time by enabling you to update the database without having to re-initialize it.

#### To update the database

1. Change your pwd to the location where Tripwire stores the report files on your system. Type:

    ```bash
    [root@localhost root]# cd /var/lib/tripwire/report/
    ```

2. You will first use the database update mode in an interactive manner. Type:

    ```bash
    [root@localhost report]# tripwire --update  -Z  low  -r  <LATEST_REPORT>
    ```

    Replace <LATEST_REPORT> with the report file name you noted earlier.

    The above command will also launch your default text editor (e.g. `vi`), which will present you with so-called “update ballot boxes”. You may need to scroll through the file.

    The entries marked with an “[x]” implies that the database should be updated with that particular object.

    Remove the "x" from the ballot box “[  ]”  to prevent updating the database with the new values for that object.

    Use your text editor’s usual key-strokes to save and exit the editor.

3. Next try using the database update mode in a non-interactive manner. i.e. you will accept all the entries in the report file will be accepted without prompting. Type:

    ```bash
    [root@localhost report]# tripwire --update -Z  low -a -r  <LATEST_REPORT>
    ```

### Tripwire configuration file

You will begin these exercises by first fine-tuning your configuration file. In an earlier exercise you were advised to remove or delete all clear-text versions of Tripwire’s file from your system. You will create a slightly more secure Tripwire installation by editing some of the variables in the Tripwire configuration file. You will specify that Tripwire should always look for the binary versions of the policy and configuration files on removable media such as a floppy disk or CDROM.

1. Change your pwd to the /etc/tripwire directory.

2. Generate a clear-text version of the configuration file. Type:

    ```bash
    [root@localhost tripwire]# twadmin --print-cfgfile  > twcfg.txt
    ```

3. Open up the configuration file you created above in your text editor. Type:

    ```bash
    [root@localhost tripwire]# vi twcfg.txt
    ```

    Edit the file to look like the sample file below:

    (NOTE: The newly added and changed variables have been highlighted for you )

    ```bash
    1 ROOT                     =/usr/sbin
    
    2 POLFILE                  =/mnt/usbdrive/tw.pol
    
    3 DBFILE                   =/var/lib/tripwire/$(HOSTNAME).twd
    
    4 REPORTFILE             =/var/lib/tripwire/report/$(HOSTNAME)-$(DATE).twr
    
    5 SITEKEYFILE            =/mnt/usbdrive/site.key
    
    6 LOCALKEYFILE      =/mnt/usbdrive/$(HOSTNAME)-local.key
    
    7 EDITOR                   =/bin/vi
    
    8 LATEPROMPTING    =false
    
    9 LOOSEDIRECTORYCHECKING   =true
    
    10 GLOBALEMAIL                =root@localhost
    
    11 MAILNOVIOLATIONS           =true
    
    12 EMAILREPORTLEVEL         =3
    
    13 REPORTLEVEL                =3
    
    14 MAILMETHOD                 =SENDMAIL
    
    15 SYSLOGREPORTING         =true
    
    16 MAILPROGRAM                =/usr/sbin/sendmail -oi -t
    ```

    !!! question "Lab task:"

        Consult the man page for “twconfig” to find out what the following variables are meant for:

        ```txt
        LOOSEDIRECTORYCHECKING
    
        GLOBALEMAIL
    
        SYSLOGREPORTING
        ```

4. Mount the removal media to the /mnt/usbdrive directory. Type:

    ```bash
    [root@localhost tripwire]# mount /dev/usbdrive   /mnt/usbdrive
    ```

    !!! note  

        If you choose to store your files on a different location (e.g. a cdrom media) make the necessary adjustments to the commands.

5. Relocate the site key, local key, and binary files to the location specified in the new configuration file. Type:

    ```bash
    [root@localhost tripwire]# mv site.key tw.pol localhost.localdomain-local.key /mnt/usbdrive
    ```

6. Create a binary version of the clear-text configuration file. Type:

    ```bash
    [root@localhost tripwire]# twadmin --create-cfgfile -S /mnt/usbdrive/site.key twcfg.txt*
    ```

    The  `/etc/tripwire/tw.cfg`  file will be created for you.

7. Test your new set up. Un-mount the USB drive and eject it.

8. Try running one the `tripwire` commands that needs the files stored on the floppy drive. Type:

    ```bash
    [root@localhost tripwire]# twadmin --print-polfile
    
    ### Error: File could not be opened.
    
    ### Filename: /mnt/usbdrive/tw.pol
    
    ### No such file or directory
    
    ###
    
    ### Unable to print policy file.
    
    ### Exiting...
    ```

    You should get an error similar to the one above.

9. Mount the media where your Tripwire files are stored, and try the above command again.

    !!! question

        Did the command run successfully this time?

10. Search for and delete all the plain text versions of Tripwire’s configuration files you have created thus far from your system.

Having to mount and unmount a removable media each time you want to administer an aspect of Tripwire may end up being such a drag, but the payoff may be in the extra security. You definitely want to consider storing a pristine version of  Tripwire’s database on a read-only media such as a DVD.

### ADDITIONAL EXERCISES

1. Configure your Tripwire installation run an integrity check every day at 2 A.M and send out a report of the integrity check via e-mail to the super user on the system.

    !!! hint

        You may need to do this using a cron job.
