---
title: Process Management
---

# Process Management

In this chapter, you will learn how to work with processes.

****

**Objectives**: In this chapter, future Linux administrators will learn how to:

:heavy_check_mark: Recognize the `PID` and `PPID` of a process;   
:heavy_check_mark: View and search for processes;   
:heavy_check_mark: Manage processes.

:checkered_flag: **process**, **linux**

**Knowledge**: :star: :star:   
**Complexity**: :star:

**Reading time**: 20 minutes

****

## Generalities

An operating system consists of processes. These processes are executed in a specific order and are related. There are two categories of processes, those focused on the user environment and those focused on the hardware environment.

When a program runs, the system will create a process by placing the program data and code in memory and creating a **runtime stack**. A process is an instance of a program with an associated processor environment (ordinal counter, registers, etc...) and memory environment.

Each process has:

* a _PID_: _**P**rocess **ID**entifier_, a unique process identifier
* a _PPID_: _**P**arent **P**rocess **ID**entifier_, unique identifier of parent process

By successive filiations, the `init` process is the father of all processes.

* A parent process always creates a process
* A parent process can have multiple child processes

There is a parent/child relationship between processes. A child process results from the parent calling the _fork()_ primitive and duplicating its code to create a child. The _PID_ of the child is returned to the parent process so that it can talk to it. Each child has its parent's identifier, the _PPID_.

The _PID_ number represents the process at the time of execution. When the process finishes, the number is available again for another process. Running the same command several times will produce a different _PID_ each time.

<!-- TODO ![Parent/child relationship between processes](images/FON-050-001.png) -->

!!! Note

    Processes are not to be confused with _threads_. Each process has its memory context (resources and address space), while _threads_ from the same process share this context.

## Viewing processes

The `ps` command displays the status of running processes.
```
ps [-e] [-f] [-u login]
```

Example:
```
# ps -fu root
```

|  Option    |  Description                     |
|------------|----------------------------------|
| `-e`       | Displays all processes.          |
| `-f`       | Displays additional information. |
| `-u` login | Displays the user's processes.   |

Some additional options:

|  Option               |  Description                                      |
|-----------------------|---------------------------------------------------|
| `-g`                  | Displays the processes in the group.              |
| `-t tty`              | Displays the processes running from the terminal. |
| `-p PID`              | Displays the process information.                 |
| `-H`                  | Displays the information in a tree structure.     |
| `-I`                  | Displays additional information.                  |
| `--sort COL`          | Sort the result according to a column.            |
| `--headers`           | Displays the header on each terminal page. |
| `--format "%a %b %c"` | Customize the output display format.              |

Without an option specified, the `ps` command only displays processes running from the current terminal.

The result is displayed in the following columns:

```
# ps -ef
UID  PID PPID C STIME  TTY TIME      CMD
root 1   0    0 Jan01  ?   00:00/03  /sbin/init
```

| Column  |  Description                |
|----------|-----------------------------|
| `UID`    | Owner user.                 |
| `PID`    | Process identifier.         |
| `PPID`   | Parent process identifier.  |
| `C`      | Priority of the process.    |
| `STIME`  | Date and time of execution. |
| `TTY`    | Execution terminal.         |
| `TIME`   | Processing duration.        |
| `CMD`    | Command executed.           |

The behavior of the control can be fully customized:

```
# ps -e --format "%P %p %c %n" --sort ppid --headers
 PPID   PID COMMAND          NI
    0     1 systemd           0
    0     2 kthreadd          0
    1   516 systemd-journal   0
    1   538 systemd-udevd     0
    1   598 lvmetad           0
    1   643 auditd           -4
    1   668 rtkit-daemon      1
    1   670 sssd              0
```

## Types of processes

The user process:

* is started from a terminal associated with a user
* accesses resources via requests or daemons

The system process (_daemon_):

* is started by the system
* is not associated with any terminal and is owned by a system user (often `root`)
* is loaded at boot time, resides in memory, and is waiting for a call
* is usually identified by the letter `d` associated with the process name

System processes are therefore called daemons (_**D**isk **A**nd **E**xecution **MON**itor_).

## Permissions and rights

The user's credentials are passed to the created process when a command is executed.

By default, the process's actual `UID` and `GID` (of the process) are identical to the **actual** `UID` and `GID` (the `UID` and `GID` of the user who executed the command).

When a `SUID` (and/or `SGID`) is set on a command, the actual `UID` (and/or `GID`) becomes that of the owner (and/or owner group) of the command and no longer that of the user or user group that issued the command. Effective and real **UIDs** are therefore **different**.

Each time a file is accessed, the system checks the rights of the process according to its effective identifiers.

## Process management

A process cannot be run indefinitely, as this would be to the detriment of other running processes and would prevent multitasking.

Therefore, the total processing time available is divided into small ranges, and each process (with a priority) accesses the processor sequentially. The process will take several states during its life among the states:

* ready: waiting for the availability of the process
* in execution: accesses the processor
* suspended: waiting for an I/O (input/output)
* stopped: waiting for a signal from another process
* zombie: request for destruction
* dead: the parent process ends the child process

The end-of-process sequencing is as follows:

1. Closing of the open files
2. Release of the used memory
3. Sending a signal to the parent and child processes

When a parent process dies, their children are said to be orphans. They are then adopted by the `init` process, which will destroy them.

### The priority of a process

GNU/Linux belongs to the family of time-sharing operating systems. Processors work in a time-sharing manner, and each process takes up some processor time. Processes are classified by priority:

* Real-time process: the process with priority of **0-99** is scheduled by real-time scheduling algorithm.
* Ordinary processes: processes with dynamic priorities of **100-139** are scheduled using a fully fair scheduling algorithm.
* Nice value: a parameter used to adjust the priority of a ordinary process. The range is **-20-19**.

The default priority of a process is **0**.

### Modes of operation

Processes can run in two ways:

* **synchronous**: the user loses access to the shell during command execution. The command prompt reappears at the end of the process execution.
* **asynchronous**: the process is processed in the background. The command prompt is displayed again immediately.

The constraints of the asynchronous mode:

* the command or script must not wait for keyboard input
* the command or script must not return any result on the screen
* quitting the shell ends the process

## Process management controls

### `kill` command

The `kill` command sends a stop signal to a process.

```
kill [-signal] PID
```

Example:

```
$ kill -9 1664
```

| Code | Signal    | Description                                            |
|------|-----------|--------------------------------------------------------|
| `2`  | _SIGINT_  | Immediate termination of the process                   |
| `9`  | _SIGKILL_ | Interrupt the process (<kbd>CTRL</kbd> + <kbd>D</kbd>) |
| `15` | _SIGTERM_ | Clean termination of the process                       |
| `18` | _SIGCONT_ | Resume the process                                     |
| `19` | _SIGSTOP_ | Suspend the process                                    |

Signals are the means of communication between processes. The `kill` command sends a signal to a process.

!!! Tip

    The complete list of signals taken into account by the `kill` command is available by typing the command:

    ```
    $ man 7 signal
    ```

### `nohup` command

`nohup` allows the launching of a process independently of a connection.

```
nohup command
```

Example:

```
$ nohup myprogram.sh 0</dev/null &
```

`nohup` ignores the `SIGHUP` signal sent when a user logs out.

!!! Note

    `nohup` handles standard output and error but not standard input, hence the redirection of this input to `/dev/null`.

### [CTRL] + [Z]

By pressing the <kbd>CTRL</kbd> + <kbd>Z</kbd> keys simultaneously, the synchronous process is temporarily suspended. Access to the prompt is restored after displaying the number of the process that has just been suspended.

### `&` instruction

The `&` statement executes the command asynchronously (the command is then called _job_) and displays the number of _job_. Access to the prompt is then returned.

Example:

```
$ time ls -lR / > list.ls 2> /dev/null &
[1] 15430
$
```

The _job_ number is obtained during background processing and is displayed in square brackets, followed by the `PID` number.

### `fg` and `bg` commands

The `fg` command puts the process in the foreground:

```
$ time ls -lR / > list.ls 2>/dev/null &
$ fg 1
time ls -lR / > list.ls 2/dev/null
```

while the command `bg` places it in the background:

```
[CTRL]+[Z]
^Z
[1]+ Stopped
$ bg 1
[1] 15430
$
```

Whether it was put in the background when it was created with the `&` argument or later with the <kbd>CTRL</kbd> +<kbd>Z</kbd> keys, a process can be brought back to the foreground with the `fg` command and its job number.

### `jobs` command

The `jobs` command displays the list of processes running in the background and specifies their job number.

Example:

```
$ jobs
[1]- Running    sleep 1000
[2]+ Running    find / > arbo.txt
```

The columns represent:

1. job number
2. the order that the processes run
- a `+` : The process selected by default for the `fg` and `bg` commands when no job number is specified
- a `-` : This process is the next process to take the `+`   
3.  _Running_ (running process) or _Stopped_ (suspended process)  
4. the command

### `nice` and `renice` commands

The command `nice` allows the execution of a command by specifying its priority.

```
nice priority command
```

Example:

```
$ nice -n+15 find / -name "file"
```

Unlike `root`, a standard user can only reduce the priority of a process. Only values between +0 and +19 will be accepted.

!!! Tip

    This last limitation can be lifted per-user or per-group by modifying the `/etc/security/limits.conf` file.

The `renice` command allows you to change the priority of a running process.

```
renice priority [-g GID] [-p PID] [-u UID]
```

Example:

```
$ renice +15 -p 1664
```
| Option | Description                       |
|--------|-----------------------------------|
| `-g`   | `GID` of the process owner group. |
| `-p`   | `PID` of the process.             |
| `-u`   | `UID` of the process owner.       |

The `renice` command acts on processes already running. It is therefore possible to change the priority of a specific process and several processes belonging to a user or a group.

!!! Tip

    The `pidof` command, coupled with the `xargs` command (see the Advanced Commands course), allows a new priority to be applied in a single command:

    ```
    $ pidof sleep | xargs renice 20
    ```

### `top` command

The `top` command displays the processes and their resource consumption.

```
$ top
PID  USER PR NI ... %CPU %MEM  TIME+    COMMAND
2514 root 20 0       15    5.5 0:01.14   top
```

| Column   | Description           |
|-----------|-----------------------|
| `PID`     | Process identifier.   |
| `USER`    | Owner user.           |
| `PR`      | Process priority.     |
| `NI`      | Nice value.           |
| `%CPU`    | Processor load.       |
| `%MEM`    | Memory load.          |
| `TIME+`   | Processor usage time. |
| `COMMAND` | Command executed.     |

The `top` command allows control of the processes in real-time and in interactive mode.

### `pgrep` and `pkill` commands

The `pgrep` command searches the running processes for a process name and displays the _PID_ matching the selection criteria on the standard output.

The `pkill` command will send each process the specified signal (by default _SIGTERM_).

```
pgrep process
pkill [option] [-signal] process
```

Examples:

* Get the process number from `sshd`:

  ```
  $ pgrep -u root sshd
  ```

* Kill all `tomcat` processes:

  ```
  $ pkill tomcat
  ```

!!! note

    Before you kill a process, it's best to know exactly what the process is for, otherwise it can lead to system crashes or other unpredictable problems.

In addition to sending signals to the relevant processes, the `pkill` command can also end the user's connection session according to the terminal number, such as:

```
$ pkill -t pts/1
```

### `killall` command

The function of this command is roughly the same as that of the `pkill` command. The usage is - `killall [option] [ -s SIGNAL | -SIGNAL ] NAME`. The default signal is _SIGTERM_.

| Options | Description |
| :--- | :--- |
| `-l` | list all known signal names |
| `-i` | ask for confirmation before killing |
| `-I` | case insensitive process name match |

Example:

```
$ killall tomcat
```

### `pstree` command

This command displays the progress in a tree style, and its usage is - `pstree [option]`.

| Option | Description |
| :--- | :--- |
| `-p` | Displays the PID of the process |
| `-n` | sort output by PID |
| `-h` | highlight current process and its ancestors |
| `-u` | show uid transitions |

```bash
$ pstree -pnhu
systemd(1)─┬─systemd-journal(595)
           ├─systemd-udevd(625)
           ├─auditd(671)───{auditd}(672)
           ├─dbus-daemon(714,dbus)
           ├─NetworkManager(715)─┬─{NetworkManager}(756)
           │                     └─{NetworkManager}(757)
           ├─systemd-logind(721)
           ├─chronyd(737,chrony)
           ├─sshd(758)───sshd(1398)───sshd(1410)───bash(1411)───pstree(1500)
           ├─tuned(759)─┬─{tuned}(1376)
           │            ├─{tuned}(1381)
           │            ├─{tuned}(1382)
           │            └─{tuned}(1384)
           ├─agetty(763)
           ├─crond(768)
           ├─polkitd(1375,polkitd)─┬─{polkitd}(1387)
           │                       ├─{polkitd}(1388)
           │                       ├─{polkitd}(1389)
           │                       ├─{polkitd}(1390)
           │                       └─{polkitd}(1392)
           └─systemd(1401)───(sd-pam)(1404)
```

### Orphan process and zombie process

**orphan process**: When a parent process dies, their children are said to be orphans. The init process adopts these special state processes, and status collection is completed until they are destroyed. Conceptually speaking, the orphanage process does not pose any harm.

**zombie process**: After a child process completes its work and is terminated, its parent process needs to call the signal processing function wait() or waitpid() to obtain the termination status of the child process. If the parent process does not do so, although the child process has already exited, it still retains some exit status information in the system process table. Because the parent process cannot obtain the status information of the child process, these processes will continue to occupy resources in the process table. We refer to processes in this state as zombies.

Hazard:

* Occupying system resources and causing a decrease in machine performance.
* Unable to generate new child processes.

How to check if there are any zombie processes in the current system?

```
$ ps -lef | awk '{print $2}' | grep Z
```

These characters may appear in this column:

* **D** - uninterruptible sleep (usually IO)
* **I** - Idle kernel thread
* **R** - running or runnable (on run queue)
* **S** - interruptible sleep (waiting for an event to complete)
* **T** - stopped by job control signal
* **t** - stopped by debugger during the tracing
* **W** - paging (not valid since the 2.6.xx kernel)
* **X** - dead (should never be seen)
* **Z** - defunct ("zombie") process, terminated but not reaped by its parent
