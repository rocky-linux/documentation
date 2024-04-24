---
author: Wale Soyinka 
contributors: Steven Spencer, Ganna Zhyrnova 
tested on: All Versions
tags:
  - lab exercise
  - system utilities
  - cli
---

# Lab 3: Common System Utilities

## Objectives

After completing this lab, you will be able to

- Use the common system utilities found on most Linux Systems

Estimated time to complete this lab: 70 minutes

## Common system utilities found on Linux systems

The exercises in this lab cover the usage of some basic system utilities that users and administrators alike need to be familiar with. Most of the commands are used in navigating and manipulating the file system. The file system is made up of files and directories.

The exercises will cover the usage of –`pwd`, `cd`, `ls`, `rm`, `mv`, `ftp`, `cp`, `touch`, `mkdir`, `file`, `cat`, `find`, and `locate` utilities.

## Exercise 1

### `cd`

The `cd` command stands for change directory. You will start these labs by changing to other directories on the file system.

#### To Use `cd`

1. Log in to the computer as root

2. Change from your current directory to the /etc directory.

    ```bash
    [root@localhost root]# cd /etc
    ```

3. Note that your prompt has changed from “[root@localhost root]# ” to : “[root@localhost etc]# “

4. Change to the `/usr/local/` directory

    ```bash
    [root@localhost etc]# cd /usr/local

    [root@localhost local]#
    ```

    !!! Question

        What has changed about your prompt?

5. Change back to root’s home directory

    ```bash
    [root@localhost local]# cd /root
    ```

6. Change to the /usr/local/ directory again. Type:

    ```bash
    [root@localhost root]# cd /usr/local
    ```

7. To change to the parent directory of the local directory type “cd ..”

    ```bash
    [root@localhost local]# cd ..
    ```

    !!! Question

        What is the parent directory of the /usr/local/ directory?

8. To quickly change back to root’s home directory type “cd” without any argument.

    ```bash
    [root@localhost usr]# cd

    [root@localhost root]#
    ```

## Exercise 2

### `pwd`

The `pwd` command stands for “present working directory”. It shows the location you are in on the file system.

#### To use `pwd`

1. To find out your current working directory type:

    ```bash
    [root@localhost root]# pwd
    /root
    ```

2. Change your directory to the /usr/local/ directory using the “cd” command:

    ```bash
    [root@localhost root]# cd /usr/local
    ```

3. Use `pwd` to find your present working directory:

    ```bash
    [root@localhost local]# pwd
    /usr/local
    ```

4. Return to root’s home directory:

    ```bash
    [root@localhost root]#  cd
    ```

## Exercise 3

### `mkdir`

The `mkdir` command is used to create directories. You will create two directories called “folder1” and “folder2.”

#### To use `mkdir`

1. Type:

    ```bash
    [root@localhost root]# mkdir folder1
    ```

2. Create a second directory called folder2

    ```bash
    [root@localhost root]# mkdir   folder2
    ```

3. Now change your working directory to the “folder1” directory you created above.

    ```bash
    [root@localhost root]# cd folder1
    ```

4. Display your current working directory.

    ```bash
    [root@localhost folder1]# pwd
    /root/folder1
    ```

    !!! question

        Without leaving your present directory, change to the “folder2” directory. What is the command to do this?

5. Return to root’s home directory.

## Exercise 4

### `touch`

The `touch` command can be used to create ordinary files. You will create “ file11, file12, file21, and file22 “ in the folders created above.

#### To use `touch`

1. Change directory  i.e. `cd` to folder1 and create "file11:"

    ```bash
    [root@localhost folder1]# touch file11
    ```

2. While still in folder1 create "file12:"

    ```bash
    [root@localhost folder1]# touch file12
    ```

3. Now return to root’s home directory.

4. `cd` to folder2 and  create “file21” and “file22”

    ```bash
    [root@localhost folder2]# Touch file21 file22
    ```

5. Return to root’s home directory.

## Exercise 5

### `ls`

The `ls` command stands for list. It lists the contents of a directory.

#### To use `ls`

1. Type `ls` in root’s home directory:

    ```bash
    [root@localhost root]# ls
    ```

    !!! Question

        List the contents of the directory

2. Change to the "folder1" directory

3. List the contents of “folder1” directory. Type `ls`

    ```bash
    [root@localhost folder1]# ls
    file11  file12
    ```

4. Change to the "folder2" directory and list its contents here:

5. Change back to your home directory and list “all” the hidden files and folders:

    ```bash
    [root@localhost folder2]# cd
    
    [root@localhost root]# ls   –a
    ..  .bash_history  .bash_logout  .bash_profile  .bashrc  folder1  folder2  .gtkrc  .kde   screenrc
    ```

6. To obtain a long or detailed list of all the files and folders in your home directory type:

    ```bash
    [root@localhost root]# ls –al
    total 44
    
    drwx------    5 root    root        4096 May  8 10:15 .
    
    drwxr-xr-x    8 root     root         4096 May  8 09:44 ..
    
    -rw-------    1 root    root          43 May  8 09:48 .bash_history
    
    -rw-r--r--    1 root    root          24 May  8 09:44 .bash_logout
    
    -rw-r--r--    1 root    root         191 May  8 09:44 .bash_profile
    
    -rw-r--r--    1 root    root         124 May  8 09:44 .bashrc
    
    drwxrwxr-x    2 root    root        4096 May  8 10:17 folder1
    
    drwxrwxr-x    2 root    root        4096 May  8 10:18 folder2
    
    ………………………..
    ```

## Exercise 6

### `mv`

The `mv` command stands for move. It renames files or directories. It can also move files.

#### To use `mv`

1. Change directory to the "folder1" directory and list its contents:

    ```bash
    [root@localhost root]# cd   folder1
    [root@localhost folder1] ls
    
    file11  file12
    ```

2. You will rename file11 and file12 in the "folder1" directory to temp_file11 and temp_file12 respectively:

    ```bash
    [root@localhost folder1]# mv file11 temp_file11
    ```

3. List the contents of folder1 again.

    ```bash
    [root@localhost folder1]# ls
    ```

    !!! Question

        Write down the contents:

4. Rename the file12 to temp_file12:

    ```bash
    [root@localhost folder1]# mv file12 temp_file12
    ```

5. Without changing directory rename the file21 and file22 in "folder2" to temp_file21 and temp_file22 respectively:

    ```bash
    [root@localhost folder1]# mv   /root/folder2/file21     /root/folder2/temp_file21
    
    [root@localhost folder1]# mv   /root/folder2/file22    /root/folder2/temp_file22
    ```

6. Without changing your current directory list the contents of folder2.

    !!! question

        What is the command to do this? Also list the output of the command?

## Exercise 7

### `cp`

The `cp` command stands for copy. It makes copies of files or directories.  

1. Change your directory to the "folder2" directory.

2. Copy the contents of "folder2" (temp_file21 and temp_file22) to "folder1:"

    ```bash
    [root@localhost folder2]# cp  temp_file21  temp_file22    ../folder1
    ```

3. List the contents of folder1.

    ```bash
    [root@localhost folder2]# ls  ../folder1
    temp_file11  temp_file12  temp_file21  temp_file22
    ```

4. List the contents of folder2. Note that the original copies of temp_file21 and temp_file22  remain in  folder2.

    ```bash
    [root@localhost folder2]# ls
    temp_file21  temp_file22
    ```

## Exercise 8

### `file`

The `file` utility is used to determine file or directory types.

#### To use `file`

1. Change back to your home directory.

2. To see if "folder1" is a file or directory; type:

    ```bash
    [root@localhost root]# file    folder1
    folder1: directory
    ```

3. Change to the folder1 directory

4. Use the `file` utility to determine the file type for temp_file11:

    ```bash
    [root@localhost folder1]# file     temp_file11
    temp_file11: empty
    ```

5. Use the `file` utility to find out the file type for all the files in the folder1 directory. List here:

6. Change directory to the /etc directory:

    ```bash
    [root@localhost folder1]# cd /etc
    ```

7. Use the `file` utility to find out the file type for the "passwd" file.

    ```bash
    [root@localhost etc]# file passwd
    ```

    !!! Question

        What type of file is it?

## Exercise 9

### `cat`

The `cat` command is short for concatenate, meaning it strings files together. The command `cat` will also display the contents of an entire file on the screen. You will use `cat` along with the redirection symbol “>” to create a file.

#### To use `cat` to create a file

1. Change directory to the /root/folder1 directory

2. Create a new text file called “first.txt”

    ```bash
    [root@localhost folder1]# cat > first.txt
    ```

3. Type in the phrase below at the blank prompt and press ++enter++.

    ```bash
    This is a line from first.txt !!
    ```

4. Press the ++ctrl+c++ simultaneously.

5. Type “cat first.txt” to read the text you just typed in:

    ```bash
    [root@localhost folder1]#  cat    first.txt
    This is a line from first.txt !!
    ```

6. Create another file called “second.txt” using `cat`. Type the following text into the file – “This is a line from second.txt !!”

    !!! Question

        What is the command to do this?

#### To use `cat` to concatenate files together

1. You will concatenate the files “first.txt” and “second.txt”. Type:

    ```bash
    [root@localhost folder1]#  cat     first.txt    second.txt
    ```

    !!! Question

        What is your output?

## Exercise 10

### `ftp`

`ftp` is a client program for using and connecting to FTP services via the File Transfer Protocol. The program allows users to transfer files to and from a remote network site. It is a utility you might need to use often.

In this exercise you will learn how to log on anonymously to an FTP server and download a file from the server using an `ftp` client program.

!!! note

    You will need to have completed the exercises in a previous lab to be able to follow along in this particular exercise that needs an available FTP server running somewhere reachable.

#### To use `ftp`

1. Log on to your machine as root

2. Change directory to the “/usr/local/src/” directory

3. Create a new directory called “downloads “ under the “/usr/local/src/” directory.

    !!! Question

        What is the command to do this?

4. Change directory to the newly created “downloads” directory

    ```bash
    [root@localhost src]# cd  downloads
    ```

5. Type “ftp” to launch your `ftp` client:

    ```bash
    [root@localhost downloads]#  ftp
    ftp>
    ```

6. To connect to the FTP server type:  

    ```bash
    ftp> open  < server-address>         (Obtain the <server-address> from your instructor)
    ………  
    
    220 localhost.localdomain FTP server (Version wu-2.6.2-5) ready.
    ………..
    ```

7. Log in as an anonymous user. Type “anonymous” at the prompt:

    ```bash
    Name (10.4.51.29:root):  anonymous
    ```

8. Type in any e-mail address at the password prompt and press enter

    ```bash
    Password:         ***************
    
    230 Guest login ok, access restrictions apply.
    
    Remote system type is UNIX.
    
    Using binary mode to transfer files.
    
    ftp>
    ```

9. Change to binary mode. Type:

    ```bash
    ftp> binary
    ```

    !!! Question

        What is the output of the binary command and what is binary mode "binary mode"?

10. List the current directories on the ftp server. Type “ls” at the ftp prompt (ftp>):

    ```bash
    ftp>  ls  
    227 Entering Passive Mode (10,0,4,5,16,103).
    125 Data connection already open; Transfer starting.
    11-23-43  10:23PM       <DIR>          images
    11-02-43  02:20PM       <DIR>          pub
    226 Transfer complete.
    ```

11. Change directory to the “pub” directory. Type:

    ```bash
    ftp> cd  pub
    ```

12. Use the “ls” command to list the files and directories in the “pub” directory

    !!! Question

        How many files and directories are in there now?

13. Download the file called “hello-2.1.1.tar.gz” to your local directory. Type “yes” at the prompt.

    ```bash
    ftp>  mget     hello-2.1.1.tar.gz
    mget hello-2.1.1.tar.gz?    yes
    
    227 Entering Passive Mode (10,0,4,5,16,252).
    
    125 Data connection already open; Transfer starting.
    
    226 Transfer complete.
    
    389363 bytes received in 0.0745 secs (5.1e+03 Kbytes/sec)
    ```

14. Log off the FTP server and exit your `ftp` client. Type:

    ```bash
    ftp> bye
    ```

15. You will be thrown back into your local shell.

16. Ensure you are still in the local machine's “downloads” directory on your local machine.

    !!! question

        List the files in the downloads folder.

## Exercise 11

### Using redirection

Most of the utilities and commands you use in Linux send their output to the screen. The screen is called the standard output (stdout). Redirection allows you to send the output somewhere else – maybe a file.

Every program started on a Linux system has three open file descriptors, stdin (0), stdout (1) and stderr (2). You may redirect or pipe to "pipe" them individually. The redirection symbols are “>, < “

#### To use redirection

1. Ensure you are still in the folder1 directory.

2. You will use output redirection to redirect the out of a the ls (list) command to a text file called myredirects:

    ```bash
    [root@localhost folder1]# ls  > myredirects
    ```

3. Examine the contents of the new file (myredirects) created in the folder1 directory.

    ```bash
    [root@localhost folder1] # cat     myredirects
    temp_file11  temp_file12  temp_file21  temp_file22 myredirects
    ```

4. Now you will redirect the output of the file command into that same file. You want to find out the file type for the temp_file11 in the folder1 directory and send the output to your myredirects file:

    ```bash
    [root@localhost folder1]#  file    temp_file11   >   myredirects
    ```

5. Examine the contents of the myredirects file.

    !!! question

        It has changed. What happened?

6. If you want to prevent what happened above from happening you will use the double redirection symbol “>>”.  This will append (add) the new output to the file instead of replacing it. Try it:

    ```bash
    [root@localhost folder1]#  ls  >>  myredirects
    ```

7. Now examine the contents of the file myredirects again using `cat`.

    !!! Question

        Write down its contents here:

### Using redirection to suppress the output of a command

You will be using the concepts covered here a lot in Linux, so please pay particular attention to it. It can be a bit tricky.

There will be times when you don’t want the user to see the output of a command- perhaps an error message. This will usually be because strange error messages often scare regular users. In this exercises you will send the output of your commands to the null device ( /dev/null/ ). The null device is like a “bit bucket”. Anything you place inside disappears forever. You can also send (or redirect) regular command output to the null device "null device".

Use the guidelines below:

```bash
|Redirector|<p></p><p>Function</p>|
| :- | :- |
|> file|Direct standard output to file|
|< file|Take standard input from file|
|Cmd1 | cmd2|Pipe; take standard out of cmd1 as standard input to cmd2|
|n> file|Direct file descriptor n to file|
|N< file|Set file as file descriptor n|
|>&n|Duplicate standard output to file descriptor n|
|<&n|Duplicate standard input from file descriptor n|
|&>file|Direct standard output and standard error to file|

```

1. Ensure you are still in the folder1 directory. Use the long listing option of the ls command on temp_file11:

    ```bash
    [root@localhost folder1]#  ls   –l   temp_file11
    -rw-r--r--    1 root     root            0 Jul 26 18:26 temp_file11
    ```

2. You will redirect the output of the same command above (ls –l  temp_file11) to the null device.

    ```bash
    [root@localhost folder1]#  ls   –l temp_file11  > /dev/null
    ```

    You should have no output.

3. Now if you accidentally mis-spell the name of the file whose information you want to see; You will get:

    ```bash
    [root@localhost folder1]# ls –l te_file1
    ls: te_file1: No such file or directory
    ```

    The above is the result of the type of error the `ls` command was programmed to give.

4. Run the same command as the above with an incorrect spelling of the file name and redirect it to /dev/null

    ```bash
    [root@localhost folder1]# ls   -l   te_file1  >  /dev/null
    
    ls: te_file1: No such file or directory
    ```

    !!! Question

        What happened here? How come the output still showed up on the screen (stdout)?

5. For various reasons you may want to suppress error message such as the one above. To do this type:

    ```bash
    [root@localhost folder1]# ls –l te_file1 > /dev/null 2>&1
    ```

    You will not get any output.

    This time the standard output as well as the standard error is suppressed.

    The order of redirection is IMPORTANT!!

    Redirection is read from left to right on the command line.

    The left-most part of the redirection symbol - “>”: will send the standard output (stdout) to /dev/null. Then the right-most part of the redirection - “2>&1 “: will duplicate the standard error (2) to the standard output (1).

    Hence the above command can be read as: redirect stdout(1) to “/dev/null” and then copy stderr (2) to stdout

6. To further demonstrate the importance of the order of redirection; Try:

    ```bash
    [root@localhost folder1]# ls   –l    tem_file  2>&1   > order.txt
    ```

    Use the `cat` command to examine the contents of the file “order.txt”

    The left-most part – “2>&1” will copy the standard error to the standard output. Then, the right-most part of the above – “ > order.txt” redirects stdout to the file order.txt.

7. Try this variation of the above step:

    ```bash
    [root@localhost folder1]# ls  –l   hgh_ghz  2>  order2.txt   > order2.txt
    ```

    !!! question

        Examine the file “order2.txt” and explain what happened?

8. To send the standard output and standard error to separate files; Type:

    ```bash
    [root@localhost folder1]# ls  –l  tep_f   > standard_out  2> standard_err
    ```

    !!! question

        Two new files were created. What are the names of the files and what are their contents?

9. You can similarly redirect both stdout and stderr to the same file by using:

    ```bash
    [root@localhost folder1]# ls  –l   te_fil   &>   standard_both
    ```

## Exercise 12

### `rm`

The `rm` command is used to delete files or directories. You are going to use `rm` to delete some of the files you created in the earlier exercises.

#### To use `rm`

1. While still in the "folder1" directory, delete the file standard_err. Type “y” at the confirmation prompt:

    ```bash
    [root@localhost folder1]# rm   standard_err
    rm: remove `standard_err'? y
    ```

2. Delete the “standard_out” file. To prevent being prompted for confirmation before deleting a file use the “–f “ option with the `rm` command:

    ```bash
    [root@localhost folder1]# rm   -f   standard_out
    ```

3. Change back to your home directory (/root) and delete the “folder2” directory. To use `rm` to delete a folder you need to use the “–r” switch:

    ```bash
    [root@localhost root]# rm  -r   folder2
    
    rm: descend into directory `folder2'? y
    
    rm: remove `folder2/temp_file21'? y
    
    rm: remove `folder2/temp_file22'? y
    
    rm: remove directory `folder2'? y
    ```

    !!! Question

        You were again prompted to confirm the removal of each file in the directory and the directory itself.  What option will you use with the `rm  –r` command to prevent this?

## Exercise 13

### Learning `vi`

`vi` is a text editor. It can be used to edit all kinds of plain text. It is especially useful for editing programs.

`vi` is a big fat monster that can do almost everything - including make your coffee or cocoa!!

Instead of trying to teach you `vi`, this exercise will point you to a tool that can better familiarize you with `vi`.

Please take the time to go through the online `vi` (more precisely `vim`) tutorial. Just follow the instructions.

#### To learn `vi`

1. While logged into the system, type:

    [root@localhost root]# vimtutor

## Exercise 14

### Searching for files: (`find` and `locate`)

This exercise will discuss two of the most popular utilities used for searching for files and directories on the file system. They are the `find` command and the `locate` commands.

#### `find`

The `find` utility has been around for along time. It recursively scans directories to find files that match a given criterion.

The general syntax for `find` is:

```bash
find   [path]    [options]   [criterion]    [action]
```

If you do not specify any directory or path, find will search the current directory. If you do not specify a criterion, this is equivalent to "true", thus all files will be found. The `find` utility has many options for doing just about any type of search for a file. Only a few of the options, criteria and actions are listed below.

```bash
OPTIONS:

-xdev: do not search on directories located on other filesystems;

-mindepth <n> descend at least <n> levels below the specified directory before

searching for files;

-maxdepth <n>: search for files located at most n levels below the specified directory;

-follow: follow symbolic links if they link to directories.

-daystart: when using tests related to time (see below), take the beginning of current day as a timestamp instead of the default (24 hours before current time).
```

```bash
CRITERION

-type <type>: search for a given type of file; <type> can be one of: f (regular file), d (directory),

l (symbolic link), s (socket), b (block mode file), c (character mode file) or

p (named pipe);

-name <pattern>: find files whose names match the given <pattern>;

-iname <pattern>: like -name, but ignore case;

-atime <n>, -amin <n>:find files which have last been accessed <n> days ago (-atime) or <n> minutes ago (-amin). You can also specify +<n> or -<n>, in which case the search will be done for files accessed respectively at most or at least <n> days/minutes ago;

-anewer <file>: find files which have been accessed more recently than file <file>;

-ctime <n>, -cmin <n>, -cnewer <file>: same as for -atime, -amin and -anewer, but applies to the last time when the contents of the file have been modified;

-regex <pattern>: same as -name, but pattern is treated as a regular expression;

-iregex <pattern>: same as -regex, but ignore case.
```

```bash
ACTION:

-print: just prints the name of each file on standard output. This is the default action;

-ls: prints on the standard output the equivalent of ls -ilds for each file found;

-exec <command>: execute command <command> on each file found. The command line <command> must end with a ;, which you must escape so that the shell does not interpret it; the file position is marked with {}.

-ok <command>: same as -exec but ask confirmation for each command.
```

#### To use `find`

1. Ensure you are in your home directory.

2. You will use find to display all the files in your current directory (`pwd`). Type:

    ```bash
    [root@localhost root]# find
    
    
    ………..
    
    ./.bash_profile
    
    ./.bashrc
    
    ./.cshrc
    
    ./.tcshrc
    
    ./.viminfo
    
    ./folder1
    
    ./folder1/first.txt
    
    …………
    ```

    Your output shows the default behavior of find when used without any option.

    It displays all the files and directories (including hidden files) in the working directory recursively.

3. Now use `find` to find only the directories in your pwd. Type:

    ```bash
    [root@localhost root]# find   -type   d
    .
    ./folder1
    ./folder2
    ………
    ```

    !!! Question "Questions"

        From the above command “find  –type  d”; what is the “option”, what is the “path”, what is the “criterion” and finally what is the “action”?

4. Next you will search for all the files on your system that end with the suffix  “.txt”:

    ```bash
    [root@localhost root]# find    /   -maxdepth   3   -name   "*.txt"   -print
    /root/folder1/first.txt
    /root/folder1/second.txt
    /root/folder1/order.txt
    /root/folder1/order2.txt
    ```

    !!! Question "Questions"

        Again from the above command, what is the “option”, what is the “path”, what is the “criterion” and finally what is the “action”? (HINT: The action = “- print”)

    The search will only be performed 3 directories deep from the “/” directory.

    The asterisk used in the command above is one of the “wild card” characters in Linux.

    The use of wild-cards in Linux is called “globbing”.

5. Use the `find` command to find all files in your “pwd” that are “smaller” than 200 kilobytes in size. Type:

    ```bash
    [root@localhost root]# find   .   –size    -200k
    ```

6. Use the `find` command to find all the files in your pwd that are “larger” than 10 kilobytes and display their “file  type” as well. Type:

    ```bash
    [root@localhost root]#  find   .  –size  +10k   –exec    file     "{ }"      ";"
    ```

#### `locate`

The syntax for the `find` command can be rather difficult to use sometimes; and because of its extensive search, it can be slow. An alternative command is `locate`.

`locate` searches through a previously created database of all files on the file system.

It relies on the `updatedb` program.

```bash
search usage:

locate [-qi] [-d <path>] [--database=<path>] <search string>...

locate [-r <regexp>] [--regexp=<regexp>]

database usage: locate [-qv] [-o <file>] [--output=<file>]

locate [-e <dir1,dir2,...>] [-f <fs_type1,...> ] [-l <level>]

[-c] <[-U <path>] [-u]>

general usage: locate [-Vh] [--version] [--help]
```

#### To use `locate`

1. Change to the folder1 directory and create empty files temp1, temp2 and temp3:

    ```bash
    [root@localhost root]# cd   folder1;   touch temp1   temp2    temp3
    [root@localhost folder1]#
    ```

    The semi-colon (;) used in the command above, allows you issue multiple commands on a single line!!

2. Use `locate` to search for all the files in your pwd that have the suffix “temp”

    ```bash
    [root@localhost folder1]# locate  temp*
    /root/folder1/temp_file11
    /root/folder1/temp_file12
    /root/folder1/temp_file21
    /root/folder1/temp_file22
    ```

    Note that the three files you created in step 1 were NOT found.

3. You will force an update of the database using `updatedb` to enable it take cognizance of all newly created files. Type:

    ```bash
    [root@localhost folder1]# updatedb
    ```

4. Now try the search again. Type:

    ```bash
    [root@localhost folder1]# locate    temp
    ```

    !!! Question

        What happened this time?

5. All done with Lab 3.
