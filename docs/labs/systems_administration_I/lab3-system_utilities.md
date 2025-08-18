---
title: Lab 3 - Common System Utilities
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova, Franco Colussi
tested on: All Versions
tags:
  - lab exercise
  - system utilities
  - cli
---

## Objectives

After completing this lab, you will be able to

- Use the common system utilities found on most Linux Systems

Estimated time to complete this lab: 70 minutes

## Common system utilities found on Linux systems

### What is a System Utility?

In a Linux environment, *system utilities* are programs and commands that allow you to manage, monitor, and optimize the operation of the operating system. These tools are essential for system administrators, developers, and advanced users, as they simplify tasks such as file management, process control, network configuration, and much more.

Unlike graphical interfaces, many utilities are accessible via the command line, offering greater flexibility, automation, and control over the system.

The exercises in this lab cover the usage of some basic system utilities that users and administrators alike need to be familiar with. Most of the commands are used in navigating and manipulating the file system. The file system is made up of files and directories.

The exercises will cover the usage of –`pwd`, `cd`, `ls`, `rm`, `mv`, `ftp`, `cp`, `touch`, `mkdir`, `file`, `cat`, `find`, and `locate` utilities.

## Exercises

### 1. File system navigation with `cd`

The `cd` command (short for ==Change Directory==) is one of the most commonly used commands in Linux and Unix-like systems. It allows you to move between directories in the file system, enabling users to navigate between folders and access the files within them.  
The `cd` command is essential for working in the Linux shell, as it allows you to explore and organize the file system efficiently.

#### How to use `cd`

1. Log in to the computer as root

2. Change from your current directory to the `/etc` directory.

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

6. Change to the `/usr/local/` directory again. Type:

    ```bash
    [root@localhost root]# cd /usr/local
    ```

7. To change to the parent directory of the local directory type `cd ..`

    ```bash
    [root@localhost local]# cd ..
    ```

    !!! Question

        What is the parent directory of the `/usr/local/` directory?

8. To quickly change back to root’s home directory type `cd` without any argument.

    ```bash
    [root@localhost usr]# cd
    [root@localhost root]#
    ```

### 2. Display the path with `pwd`

The `pwd` (==Present Working Directory==) command shows the user the absolute path of the current directory within the file system. It is used to identify the current location when working in a terminal and you want to know exactly where you are.  
This command is essential for navigating the file system, especially when working with complex paths or automated scripts.

#### How to use `pwd`

1. To find out your current working directory type:

    ```bash
    [root@localhost root]# pwd
    /root
    ```

2. Change your directory to the `/usr/local/` directory using the `cd` command:

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
    [root@localhost root]# cd
    ```

### 3. Create folders with `mkdir`

The `mkdir` (==Make Directory==) command allows you to create new directories (folders) within the file system. In this exercise, you will create two folders named `folder1` and `folder2`.

#### How to use `mkdir`

1. Create the first directory called `folder1`

    ```bash
    [root@localhost root]# mkdir folder1
    ```

2. Create a second directory called `folder2`

    ```bash
    [root@localhost root]# mkdir folder2
    ```

3. Now change your working directory to the `folder1` directory you created above.

    ```bash
    [root@localhost root]# cd folder1
    ```

4. Display your current working directory.

    ```bash
    [root@localhost folder1]# pwd
    /root/folder1
    ```

    !!! question

        Without leaving your present directory, change to the `folder2` directory. What is the command to do this?

5. Return to root’s home directory.

### 4. Modify file metadata with `touch`

The touch command is a tool that allows you to create new empty files or modify the access/modification dates of existing files, as well as advanced uses in scripting and automation. The name ==touch== comes from the idea of “*touching*” the file's metadata without necessarily modifying its content.  
The files *file11*, *file12*, *file21*, and *file22* will be created in the folders created above.

#### How to use `touch`

1. Change directory  i.e. `cd` to `folder1` and create *file11*:

    ```bash
    [root@localhost folder1]# touch file11
    ```

2. While still in `folder1` create *file12*:

    ```bash
    [root@localhost folder1]# touch file12
    ```

3. Now return to root’s home directory.

4. `cd` to `folder2` and  create *file21* and *file22*

    ```bash
    [root@localhost folder2]# touch file21 file22
    ```

5. Return to root’s home directory.

### 5. List directories with `ls`

The ls (==List==) command is one of the most fundamental and widely used commands in Linux and Unix-like systems. It allows you to view the contents of a directory, displaying files and subdirectories with various formatting and sorting options.

#### To use `ls`

1. Type `ls` in root’s home directory:

    ```bash
    [root@localhost root]# ls
    ```

    !!! Question

        List the contents of the directory

2. Change to the `folder1` directory

3. List the contents of `folder1` directory. Type `ls`

    ```bash
    [root@localhost folder1]# ls
    file11  file12
    ```

4. Change to the `folder2` directory and list its contents here:

5. Change back to your home directory and list **all** the hidden files and folders:

    ```bash
    [root@localhost folder2]# cd
    [root@localhost root]# ls –a
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

### 6. Moving files with `mv`

The `mv` (==Move==) command provides a tool for managing files in the system. Its main function is to move or rename files and directories within the file system. This command is particularly useful for reorganizing the directory structure, performing batch operations on groups of files, and managing backups efficiently.

#### How too use `mv`

1. Change directory to the `folder1` directory and list its contents:

    ```bash
    [root@localhost root]# cd folder1
    [root@localhost folder1] ls
    file11  file12
    ```

2. You will rename *file11* and *file12* in the `folder1` directory to *temp_file11* and *temp_file12* respectively:

    ```bash
    [root@localhost folder1]# mv file11 temp_file11
    ```

3. List the contents of `folder1` again.

    ```bash
    [root@localhost folder1]# ls
    ```

    !!! Question

        Write down the contents:

4. Rename the *file12* to *temp_file12*:

    ```bash
    [root@localhost folder1]# mv file12 temp_file12
    ```

5. Without changing directory rename the *file21* and *file22* in `folder2` to *temp_file21* and *temp_file22* respectively:

    ```bash
    [root@localhost folder1]# mv /root/folder2/file21 /root/folder2/temp_file21
    [root@localhost folder1]# mv /root/folder2/file22 /root/folder2/temp_file22
    ```

6. Without changing your current directory list the contents of `folder2`.

    !!! question

        What is the command to do this? Also list the output of the command?

### 7. Copying files with `cp`

The `cp` (==Copy==) command allows you to duplicate files and directories from one location to another in the file system, keeping the original file intact. Its ease of use and versatility make it indispensable for both everyday operations and more complex system administration tasks.  
Among the most useful features of the `cp` command is the ability to preserve the original attributes of files during copying, including *permissions*, *timestamps*, and *owner information*. This feature is particularly important when working with configuration files or when certain document properties need to be kept intact.

#### How to use `cp`

1. Change your directory to the `folder2` directory.

2. Copy the contents of `folder2` (*temp_file21* and *temp_file22*) to `folder1`:

    ```bash
    [root@localhost folder2]# cp temp_file21 temp_file22 ../folder1
    ```

3. List the contents of `folder1`.

    ```bash
    [root@localhost folder2]# ls ../folder1
    temp_file11  temp_file12  temp_file21  temp_file22
    ```

4. List the contents of `folder2`. Note that the original copies of *temp_file21* and *temp_file22*  remain in  `folder2`.

    ```bash
    [root@localhost folder2]# ls
    temp_file21  temp_file22
    ```

### 8. Determining the file type with `file`

The `file` command is a diagnostic tool that allows you to determine the type of a file by analyzing its contents. Unlike file extensions, which can be modified or misleading, this command examines the actual structure of the data to accurately identify its nature.  
One of the most important features of the `file` command is its ability to distinguish between different types of text files, identifying, for example, shell scripts, source code in various programming languages, XML or JSON files. For binary files, it can recognize executables, shared libraries, images in various formats, and many other types of structured data.

#### How to use `file`

1. Change back to your home directory.

2. To see if `folder1` is a file or directory; type:

    ```bash
    [root@localhost root]# file folder1
    folder1: directory
    ```

3. Change to the `folder1` directory

4. Use the `file` utility to determine the file type for *temp_file11*:

    ```bash
    [root@localhost folder1]# file temp_file11
    temp_file11: empty
    ```

5. Use the `file` utility to find out the file type for all the files in the `folder1` directory. List here:

6. Change directory to the `/etc` directory:

    ```bash
    [root@localhost folder1]# cd /etc
    ```

7. Use the `file` utility to find out the file type for the *passwd* file.

    ```bash
    [root@localhost etc]# file passwd
    ```

    !!! Question

        What type of file is it?

### 9. List and concatenate files with `cat`

The `cat` command (short for ==Concatenate==) is an essential tool for managing text files in Linux. Its main function is to display the contents of one or more files directly in the terminal, but it can also be used to create, merge, or copy files.  
The cat command is particularly useful in combination with other tools (such as `grep` or `more`) for processing or filtering text directly from the terminal. Despite its simplicity, it is one of the most widely used commands for quick file manipulation.  
You will use `cat` along with the redirection symbol “>” to create a file.

#### To use `cat` to create a file

1. Change directory to the ``/root/folder1`` directory

2. Create a new text file called *first.txt*

    ```bash
    [root@localhost folder1]# cat > first.txt
    ```

3. Type in the phrase below at the blank prompt and press ++enter++.

    ```bash
    This is a line from first.txt !!
    ```

4. Press the ++ctrl+c++ simultaneously.

5. Type `cat first.txt` to read the text you just typed in:

    ```bash
    [root@localhost folder1]# cat first.txt
    This is a line from first.txt !!
    ```

6. Create another file called *second.txt* using `cat`. Type the following text into the file – “This is a line from second.txt !!”

    !!! Question

        What is the command to do this?

#### To use `cat` to concatenate files together

1. You will concatenate the files *first.txt* and *second.txt*. Type:

    ```bash
    [root@localhost folder1]# cat first.txt second.txt
    ```

    !!! Question

        What is your output?

### 10. Transferring files with `ftp`

The `ftp` (File Transfer Protocol) command is a command line tool for transferring files between remote and local systems. Although it has been partially replaced by more modern and secure protocols such as *SFTP* and *SCP*, it remains useful in legacy contexts or with servers that only support FTP.  
FTP transmits data in **clear text**, including credentials and content, so it is not recommended for sensitive transfers.  
Although FTP is still used in some environments, encrypted protocols are preferable for secure operations.  
In this exercise you will learn how to log on anonymously to an FTP server and download a file from the server using an *ftp client* program.

!!! note

    You will need to have completed the exercises in a previous lab to be able to follow along in this particular exercise that needs an available FTP server running somewhere reachable.

#### How to use `ftp`

1. Log on to your machine as root

2. Change directory to the ``/usr/local/src/`` directory

3. Create a new directory called `downloads` under the `/usr/local/src/` directory.

    !!! Question

        What is the command to do this?

4. Change directory to the newly created `downloads` directory

    ```bash
    [root@localhost src]# cd downloads
    ```

5. Type `ftp` to launch your *ftp client*:

    ```bash
    [root@localhost downloads]# ftp
    ftp>
    ```

6. To connect to the FTP server type:

    ```bash
    ftp> open  < server-address>    (Obtain the <server-address> from your instructor)
    ………
    220 localhost.localdomain FTP server (Version wu-2.6.2-5) ready.
    ………..
    ```

7. Log in as an anonymous user. Type “*anonymous*” at the prompt:

    ```bash
    Name (10.4.51.29:root):  anonymous
    ```

8. Type in any *e-mail address* at the password prompt and press ++enter++

    ```bash
    Password: ***************
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

        What is the output of the binary command and what is the "binary mode"?

10. List the current directories on the ftp server. Type `ls` at the *ftp prompt*:

    ```bash
    ftp> ls
    227 Entering Passive Mode (10,0,4,5,16,103).
    125 Data connection already open; Transfer starting.
    11-23-43  10:23PM       <DIR>          images
    11-02-43  02:20PM       <DIR>          pub
    226 Transfer complete.
    ```

11. Change directory to the `pub` directory. Type:

    ```bash
    ftp> cd  pub
    ```

12. Use the `ls` command to list the files and directories in the `pub` directory

    !!! Question

        How many files and directories are in there now?

13. Download the file called “*hello-2.1.1.tar.gz*” to your local directory. Type “*yes*” at the prompt.

    ```bash
    ftp> mget hello-2.1.1.tar.gz
    mget hello-2.1.1.tar.gz? yes
    227 Entering Passive Mode (10,0,4,5,16,252).
    125 Data connection already open; Transfer starting.
    226 Transfer complete.
    389363 bytes received in 0.0745 secs (5.1e+03 Kbytes/sec)
    ```

14. Log off the FTP server and exit your *ftp client*. Type:

    ```bash
    ftp> bye
    ```

15. You will be thrown back into your local shell.

16. Ensure you are still in the local machine's `downloads` directory on your local machine.

    !!! question

        List the files in the downloads folder.

### 11. Using redirection

Most of the utilities and commands you use in Linux send their output to the screen. The screen is called the standard output (*stdout*). Redirection allows you to send the output somewhere else – maybe a file.

Every program started on a Linux system has three open file descriptors, *stdin* **(0)**, *stdout* **(1)** and *stderr* **(2)**. You may redirect or "*pipe*" them individually. The redirection symbols are ++greater++ and ++less++.

#### How to use redirection

1. Ensure you are still in the `folder1` directory.

2. You will use output redirection to redirect the output to an `ls` (*list*) command to a text file called *myredirects*:

    ```bash
    [root@localhost folder1]# ls > myredirects
    ```

3. Examine the contents of the new file (*myredirects*) created in the `folder1` directory.

    ```bash
    [root@localhost folder1] # cat myredirects
    temp_file11  temp_file12  temp_file21  temp_file22 myredirects
    ```

4. Now you will redirect the output of the file command into that same file. You want to find out the file type for the *temp_file11* in the `folder1` directory and send the output to your *myredirects* file:

    ```bash
    [root@localhost folder1]# file temp_file11 > myredirects
    ```

5. Examine the contents of the myredirects file.

    !!! question

        It has changed. What happened?

6. If you want to prevent what happened above from happening you will use the double redirection symbol ++">"+">"++. This will append (*add*) the new output to the file instead of replacing it. Try it:

    ```bash
    [root@localhost folder1]# ls >> myredirects
    ```

7. Now examine the contents of the file *myredirects* again using `cat`.

    !!! Question

        Write down its contents here:

#### Using redirection to suppress the output of a command

You will be using the concepts covered here a lot in Linux, so please pay particular attention to it. It can be a bit tricky.

There will be times when you do not want the user to see the output of a command - perhaps an error message. This will usually be because strange error messages often scare regular users. In this exercise you will send the output of your commands to the *null device* ( `/dev/null/` ). The *null device* is like a “*bit bucket*”. Anything you place inside disappears forever. You can also send (or redirect) regular command output to the *null device*.

Use the guidelines below:

| Redirector   | Function                                                  |
| ------------ | --------------------------------------------------------- |
| > file       | Directs standard output to file                            |
| < file       | Takes standard input from file                             |
| Cmd1 \| cmd2 | Pipe; takes standard out of cmd1 as standard input to cmd2 |
| n> file      | Directs file descriptor n to file                          |
| N< file      | Sets file as file descriptor n                             |
| >&n          | Duplicates standard output to file descriptor n            |
| <&n          | Duplicates standard input from file descriptor n           |
| &>file       | Directs standard output and standard error to file         |

1. Ensure you are still in the `folder1` directory. Use the long listing option of the `ls` command on *temp_file11*:

    ```bash
    [root@localhost folder1]# ls –l temp_file11
    -rw-r--r-- 1 root   root    0   Jul 26 18:26    temp_file11
    ```

2. You will redirect the output of the same command above (`ls –l  temp_file11`) to the null device.

    ```bash
    [root@localhost folder1]# ls –l temp_file11 > /dev/null
    ```

    You should have no output.

3. Now if you accidentally mis-spell the name of the file whose information you want to see; You will get:

    ```bash
    [root@localhost folder1]# ls –l te_file1
    ls: te_file1: No such file or directory
    ```

    The above is the result of the type of error the `ls` command was programmed to give.

4. Run the same command as the above with an incorrect spelling of the file name and redirect it to `/dev/null`

    ```bash
    [root@localhost folder1]# ls -l te_file1 > /dev/null
    ls: te_file1: No such file or directory
    ```

    !!! Question

        What happened here? How come the output still showed up on the screen (*stdout*)?

5. For various reasons you may want to suppress error messages such as the one above. To do this type:

    ```bash
    [root@localhost folder1]# ls –l te_file1 > /dev/null 2>&1
    ```

    You will not get any output. This time the standard output as well as the standard error is suppressed.

    The order of redirection is IMPORTANT!!

    Redirection is read from left to right on the command line. The left-most part of the redirection symbol - ++greater++ will send the standard output (*stdout*) to `/dev/null`. Then the right-most part of the redirection - `2>&1` will duplicate the standard error **(2)** to the standard output **(1)**.

    Hence the above command can be read as: *redirect stdout(1) to “/dev/null” and then copy stderr (2) to stdout*

6. To further demonstrate the importance of the order of redirection; Try:

    ```bash
    [root@localhost folder1]# ls –l tem_file 2>&1 > order.txt
    ```

    Use the `cat` command to examine the contents of the file “*order.txt*”

    The left-most part – `2>&1` will copy the standard error to the standard output. Then, the right-most part of the above – `> order.txt` redirects *stdout* to the file *order.txt*.

7. Try this variation of the above step:

    ```bash
    [root@localhost folder1]# ls –l hgh_ghz 2> order2.txt > order2.txt
    ```

    !!! question

        Examine the file “order2.txt” and explain what happened?

8. To send the standard output and standard error to separate files; Type:

    ```bash
    [root@localhost folder1]# ls –l tep_f > standard_out 2> standard_err
    ```

    !!! question

        Two new files were created. What are the names of the files and what are their contents?

9. You can similarly redirect both *stdout* and *stderr* to the same file by using:

    ```bash
    [root@localhost folder1]# ls –l te_fil &> standard_both
    ```

### 12. Deleting files with `rm`

The `rm` (Remove) command allows you to permanently delete one or more files, directories, and their contents, with no possibility of recovery unless you use external recovery solutions. It is a powerful command but potentially dangerous if used improperly, as it operates irreversibly. For this reason, it is important to use it with caution, always checking the paths and file names before performing the operation.  
You are going to use `rm` to delete some of the files you created in the earlier exercises.

#### How to use `rm`

1. While still in the `folder1` directory, delete the file *standard_err*. Type ++"y"++ at the confirmation prompt:

    ```bash
    [root@localhost folder1]# rm standard_err
    rm: remove `standard_err'? y
    ```

2. Delete the *standard_out* file. To prevent being prompted for confirmation before deleting a file use the `–f` option with the `rm` command:

    ```bash
    [root@localhost folder1]# rm -f standard_out
    ```

3. Change back to your home directory (`/root`) and delete the `folder2` directory. To use `rm` to delete a folder you need to use the `–r` switch:

    ```bash
    [root@localhost root]# rm -r folder2
    rm: descend into directory 'folder2'? y
    rm: remove 'folder2/temp_file21'? y
    rm: remove 'folder2/temp_file22'? y
    rm: remove directory 'folder2'? y
    ```

    !!! Question

        You were again prompted to confirm the removal of each file in the directory and the directory itself.  What option will you use with the `rm  –r` command to prevent this?

### 13. Learning `vi`

The `vi` editor is one of the most powerful and widely used text editors available on Linux and Unix-like systems. It is an essential tool for system administrators and developers thanks to its efficiency and versatility. Unlike many modern editors, `vi` operates primarily in text mode, offering quick commands and key combinations that allow you to edit files with extreme precision and speed.

Its learning curve may be steep at first, but once you master the basic features, it becomes an indispensable tool for editing configuration files, scripts, and source code directly from the terminal.

`vi` is a big fat monster that can do almost everything - including make your coffee or cocoa!!

Instead of trying to teach you `vi`, this exercise will point you to a tool that can better familiarize you with `vi`. Please take the time to go through the online `vi` (more precisely `vim`) tutorial. Just follow the instructions.

#### To learn `vi`

1. While logged into the system, type:

    [root@localhost root]# vimtutor

### 14. Searching files with `find` and `locate`

This exercise will discuss two of the most popular utilities used for searching for files and directories on the file system. They are the `find` command and the `locate` commands.

#### `find`

The `find` command allows you to search for files and directories within the filesystem based on a wide range of criteria, such as name, type, size, modification date, permissions, and much more.
Its ability to perform actions on the results found, such as deleting, moving, or processing files, makes it an indispensable tool for system administrators and advanced users.

The general syntax for `find` is:

```bash
find   [path]    [options]   [criterion]    [action]
```

If you do not specify any directory or path, `find` will search the current directory. If you do not specify a criterion, this is equivalent to "*true*", thus all files will be found. The `find` utility has many options for doing just about any type of search for a file. Only a few of the options, criteria and actions are listed below.

| OPTIONS | DESCRIPTION |
| -- | -- |
| -xdev | does not search on directories located on other filesystems |
| -mindepth `<n>` | descends at least `<n>` levels below the specified directory before searching for files |
| -maxdepth `<n>` | searches for files located at most `<n>` levels below the specified directory |
| -follow | follows symbolic links if they link to directories |
| -daystart | when using tests related to time (see below), it takes the beginning of the current day as a timestamp instead of the default (24 hours before the current time) |

| CRITERION | DESCRIPTION |
| -- | -- |
|-type `<type>` | searches for a given type of file; `<type>` can be one of: **f** (*regular file*), **d** (*directory*) **l** (*symbolic link*), **s** (*socket*), **b** (*block mode file*), **c** (*character mode file*) or **p** (*named pipe*) |
| -name `<pattern>` | finds files whose names match the given `<pattern>` |
| -iname `<pattern>` | like *-name*, but ignores case |
| -atime `<n>`, -amin `<n>` | finds files which have last been accessed `<n>` days ago (*-atime*) or `<n>` minutes ago (*-amin*). You can also specify `+<n>` or `-<n>`, in which case the search will be done for files accessed respectively at *most* or at *least* `<n>` days/minutes ago |
| -anewer `<file>` | finds files which have been accessed more recently than file `<file>` |
| -ctime `<n>`, -cmin `<n>`, -cnewer `<file>` | same as for *-atime*, *-amin* and *-anewer*, but applies to the last time when the contents of the file have been modified |
| -regex `<pattern>` | same as *-name*, but pattern is treated as a regular expression |
| -iregex `<pattern>` | same as *-regex*, but ignores case |

| ACTION | DESCRIPTION |
| -- | -- |
| -print | just prints the name of each file on standard output. This is the default action |
| -ls | prints on the standard output the equivalent of `ls -ilds` for each file found |
| -exec `<command>` | executes command `<command>` on each file found. The command line `<command>` must end with a `;`, which you must escape so that the shell does not interpret it; the file position is marked with `{}` |
| -ok `<command>` | same as *-exec* but asks confirmation for each command |

#### How to use `find`

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
    It displays all the files and directories (*including hidden files*) in the working directory recursively.

3. Now use `find` to find only the directories in your *pwd*. Type:

    ```bash
    [root@localhost root]# find -type d
    ./folder1
    ./folder2
    ………
    ```

    !!! Question "Questions"

        From the above command `find –type d`; what is the “*option*”, what is the “*path*”, what is the “*criterion*” and finally what is the “*action*”?

4. Next you will search for all the files on your system that end with the suffix  “*.txt*”:

    ```bash
    [root@localhost root]# find / -maxdepth 3 -name "*.txt" -print
    /root/folder1/first.txt
    /root/folder1/second.txt
    /root/folder1/order.txt
    /root/folder1/order2.txt
    ```

    !!! Question "Questions"

        Again from the above command, what is the “*option*”, what is the “*path*”, what is the “*criterion*” and finally what is the “*action*”? (HINT: The action = “*-print*”)

    The search will only be performed 3 directories deep from the `/` directory. The asterisk used in the command above is one of the “*wild card*” characters in Linux.  
    The use of wild-cards in Linux is called “*globbing*”.

5. Use the `find` command to find all files in your “*pwd*” that are “smaller” than 200 kilobytes in size. Type:

    ```bash
    [root@localhost root]# find . –size -200k
    ```

6. Use the `find` command to find all the files in your *pwd* that are “larger” than 10 kilobytes and display their “*file type*” as well. Type:

    ```bash
    [root@localhost root]#  find . –size +10k –exec file "{ }" ";"
    ```

#### `locate`

The `locate` command allows you to search for files and directories within the system. Unlike other commands such as `find`, which perform a real-time search, `locate` is based on a precompiled database containing the paths of all files on the system, ensuring almost instant results. This database is usually updated periodically using the `updatedb` command, managed by a *cron job*. Thanks to its efficiency, `locate` is particularly useful for quickly finding files or folders without having to manually scan the entire file system.  
However, it is important to remember that the results may not always be up to date if the database has not been recently synchronized with the current state of the system.

| Search usage: |
| ------------- |
| locate [-qi] [-d `<path>`] [--database=`<path>`] `<search string>`... |
| locate [-r `<regexp>`] [--regexp=`<regexp>`] |

| Database usage: |
| --------------- |
| locate [-qv] [-o `<file>`] [--output=`<file>`] |
| locate [-e `<dir1,dir2,...>`] [-f `<fs_type1,...>`] [-l `<level>`] [-c] [-U `<path>`] [-u] [`pattern...`] |

| General usage: |
| -------------- |
| locate [-Vh] [--version] [--help] |

#### How to use `locate`

1. Change to the `folder1` directory and create empty files *temp1*, *temp2* and *temp3*:

    ```bash
    [root@localhost root]# cd folder1; touch temp1 temp2 temp3
    [root@localhost folder1]#
    ```

    The semicolon (;) used in the command above, allows you to issue multiple commands on a single line!!

2. Use `locate` to search for all the files in your *pwd* that have the suffix “temp”

    ```bash
    [root@localhost folder1]# locate temp*
    /root/folder1/temp_file11
    /root/folder1/temp_file12
    /root/folder1/temp_file21
    /root/folder1/temp_file22
    ```

    Note that the three files you created in step 1 were NOT found.

3. You will force an update of the database using `updatedb` to enable it to take cognizance of all newly created files. Type:

    ```bash
    [root@localhost folder1]# updatedb
    ```

4. Now try the search again. Type:

    ```bash
    [root@localhost folder1]# locate temp
    ```

    !!! Question

        What happened this time?

5. All done with Lab 3.
