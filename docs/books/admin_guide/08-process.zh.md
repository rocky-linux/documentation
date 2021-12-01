---
title: Process Management
---

# Process Management

In this chapter you will learn how to work with processes.

****

**Objectives** : In this chapter, future Linux administrators will learn how to:

:heavy_check_mark: Recognize the `PID` and `PPID` of a process;   
:heavy_check_mark: View and search for processes;   
:heavy_check_mark: Manage processes.

:checkered_flag: **process**, **linux**

**Knowledge**: :star: :star:   
**Complexity**: :star:

**Reading time**: 20 minutes

****

## Generalities

An operating system consists of processes. These processes are executed in a specific order and are related to each other. There are two categories of processes, those focused on the user environment and those focused on the hardware environment.

When a program runs, the system will create a process by placing the program data and code in memory and creating a **runtime stack**. A process is therefore an instance of a program with an associated processor environment (ordinal counter, registers, etc...) and memory environment.

Each process has:

* a _PID_ : _**P**rocess **ID**entifier_, a unique process identifier;
* a _PPID_ : _**P**arent **P**rocess **ID**entifier_, unique identifier of parent process.

By successive filiations, the `init` process is the father of all processes.

* A process is always created by a parent process;
* A parent process can have multiple child processes.

There is a parent/child relationship between processes. A child process is the result of the parent process calling the _fork()_ primitive and duplicating its own code to create a child. The _PID_ of the child is returned to the parent process so that it can talk to it. Each child has its parent's identifier, the _PPID_.

The _PID_ number represents the process at the time of execution. When the process finishes, the number is available again for another process. Running the same command several times will produce a different _PID_ each time.<!-- TODO !\[Parent/child relationship between processes\](images/FON-050-001.png) -->!!! Note Processes are not to be confused with _threads_. Each process has its own memory context (resources and address space), while _threads_ from the same process share this same context.

## Viewing processes

The `ps` command displays the status of running processes.
```
ps [-e] [-f] [-u login]
```

Example:
```
# ps -fu root
```

| Option     | Description                      |
| ---------- | -------------------------------- |
| `-e`       | Displays all processes.          |
| `-f`       | Displays additional information. |
| `-u` login | Displays the user's processes.   |

Some additional options:

| Option                | Description                                       |
| --------------------- | ------------------------------------------------- |
| `-g`                  | Displays the processes in the group.              |
| `-t tty`              | Displays the processes running from the terminal. |
| `-p PID`              | Displays the process information.                 |
| `-H`                  | Displays the information in a tree structure.     |
| `-I`                  | Displays additional information.                  |
| `--sort COL`          | Sort the result according to a column.            |
| `--headers`           | Displays the header on each page of the terminal. |
| `--format "%a %b %c"` | Customize the output display format.              |

Without an option specified, the `ps` command only displays processes running from the current terminal.

The result is displayed in columns:

```
# ps -ef
UID  PID PPID C STIME  TTY TIME      CMD
root 1   0    0 Jan01  ?   00:00/03  /sbin/init
```

| Column  | Description                 |
| ------- | --------------------------- |
| `UID`   | Owner user.                 |
| `PID`   | Process identifier.         |
| `PPID`  | Parent process identifier.  |
| `C`     | Priority of the process.    |
| `STIME` | Date and time of execution. |
| `TTY`   | Execution terminal.         |
| `TIME`  | Processing duration.        |
| `CMD`   | Command executed.           |

The behaviour of the control can be fully customized:

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

* is started from a terminal associated with a user;
* accesses resources via requests or daemons.

The system process (_demon_):

* is started by the system;
* is not associated with any terminal, and is owned by a system user (often `root`);
* is loaded at boot time, resides in memory, and is waiting for a call;
* is usually identified by the letter `d` associated with the process name.

System processes are therefore called daemons (_**D**isk **A**nd **E**xecution **MON**itor_).

## Permissions and rights

When a command is executed, the user's credentials are passed to the created process.

By default, the actual `UID` and `GID` (of the process) are therefore identical to the **actual** `UID` and `GID` (the `UID` and `GID` of the user who executed the command).

When a `SUID` (and/or `SGID`) is set on a command, the actual `UID` (and/or `GID`) becomes that of the owner (and/or owner group) of the command and no longer that of the user or user group that issued the command. Effective and real **UIDs** are therefore **different**.

Each time a file is accessed, the system checks the rights of the process according to its effective identifiers.

## Process management

A process cannot be run indefinitely, as this would be to the detriment of other running processes and would prevent multitasking.

The total processing time available is therefore divided into small ranges, and each process (with a priority) accesses the processor in a sequenced manner. The process will take several states during its life among the states:

* ready: waiting for the availability of the process;
* in execution: accesses the processor;
* suspended: waiting for an I/O (input/output);
* stopped: waiting for a signal from another process;
* zombie: request for destruction;
* dead: the father of the process kills his son.

The end of process sequencing is as follows:

1. Closing of the open files;
2. Release of the used memory;
3. Sending a signal to the parent and child processes.

When a parent process dies, its children are said to be orphans. They are then adopted by the `init` process which will destroy them.

### The priority of a process

The processor works in time sharing with each process occupying a quantity of processor time.

The processes are classified by priority whose value varies from **-20** (the highest priority) to **+19** (the lowest priority).

The default priority of a process is **0**.

### Modes of operation

Processes can run in two ways:

* **synchronous**: the user loses access to the shell during command execution. The command prompt reappears at the end of the process execution.
* **asynchronous**: the process is processed in the background. The command prompt is displayed again immediately.

The constraints of the asynchronous mode:

* the command or script must not wait for keyboard input;
* the command or script must not return any result on the screen;
* quitting the shell ends the process.

## Process management controls

### `kill` command

The `kill` command sends a stop signal to a process.

```
kill [-signal] PID
```

Example:
```
$ kill -9 1664
```Interrupt the process (<kbd>CTRL</kdb> + <kdb>D</kdb>)</td> </tr> 

<tr>
  <td>
    <code>15</code>
  </td>
  
  <td>
    <em x-id="4">SIGTERM</em>
  </td>
  
  <td>
    Clean termination of the process
  </td>
</tr>

<tr>
  <td>
    <code>18</code>
  </td>
  
  <td>
    <em x-id="4">SIGCONT</em>
  </td>
  
  <td>
    Resume the process
  </td>
</tr>

<tr>
  <td>
    <code>19</code>
  </td>
  
  <td>
    <em x-id="4">SIGSTOP</em>
  </td>
  
  <td>
    Suspend the process
  </td>
</tr></tbody> </table> 

<p spaces-before="0">
  Signals are the means of communication between processes. The <code>kill</code> command sends a signal to a process.
</p>

<p spaces-before="0">
  !!! Tip The complete list of signals taken into account by the <code>kill</code> command is available by typing the command :
</p>

<pre><code>$ man 7 signal
</code></pre>



<h3 spaces-before="0">
  <code>nohup</code> command
</h3>

<p spaces-before="0">
  <code>nohup</code> allows the launching of a process independently of a connection.
</p>

<pre><code>nohup command
</code></pre>

<p spaces-before="0">
  Example:
</p>

<pre><code>$ nohup myprogram.sh 0&lt;/dev/null &
</code></pre>

<p spaces-before="0">
  <code>nohup</code> ignores the <code>SIGHUP</code> signal sent when a user logs out.
</p>

<p spaces-before="0">
  !!! Note "Question" <code>nohup</code> handles standard output and error, but not standard input, hence the redirection of this input to <code>/dev/null</code>.
</p>



<h3 spaces-before="0">
  [CTRL] + [Z]
</h3>

<p spaces-before="0">
  By pressing the <kbd>CTRL</kbd> + <kbd>Z</kbd> keys simultaneously, the synchronous process is temporarily suspended. Access to the prompt is restored after displaying the number of the process that has just been suspended.
</p>



<h3 spaces-before="0">
  <code>&</code> instruction
</h3>

<p spaces-before="0">
  The <code>&</code> statement executes the command asynchronously (the command is then called <em x-id="4">job</em>) and displays the number of <em x-id="4">job</em>. Access to the prompt is then returned.
</p>

<p spaces-before="0">
  Example:
</p>

<pre><code>$ time ls -lR / &gt; list.ls 2&gt; /dev/null &
[1] 15430
$
</code></pre>

<p spaces-before="0">
  The <em x-id="4">job</em> number is obtained during background processing and is displayed in square brackets, followed by the <code>PID</code> number.
</p>



<h3 spaces-before="0">
  <code>fg</code> and <code>bg</code> commands
</h3>

<p spaces-before="0">
  The <code>fg</code> command puts the process in the foreground:
</p>

<pre><code>$ time ls -lR / &gt; list.ls 2&gt;/dev/null &
$ fg 1
time ls -lR / &gt; list.ls 2/dev/null
</code></pre>

<p spaces-before="0">
  while the command <code>bg</code> places it in the background:
</p>

<pre><code>[CTRL]+[Z]
^Z
[1]+ Stopped
$ bg 1
[1] 15430
$
</code></pre>

<p spaces-before="0">
  Whether it was put in the background when it was created with the <code>&</code> argument or later with the <kbd>CTRL</kbd> +<kbd>Z</kbd> keys, a process can be brought back to the foreground with the <code>fg</code> command and its job number.
</p>



<h3 spaces-before="0">
  <code>jobs</code> command
</h3>

<p spaces-before="0">
  The <code>jobs</code> command displays the list of processes running in the background and specifies their job number.
</p>

<p spaces-before="0">
  Example:
</p>

<pre><code>$ jobs
[1]- Running    sleep 1000
[2]+ Running    find / &gt; arbo.txt
</code></pre>

<p spaces-before="0">
  The columns represent:
</p>

<ol start="1">
  <li>
    job number;
  </li>
  
  <li>
    the order in which the processes run
  </li>
</ol>

<ul>
  <li>
    a <code>+</code> : this process is the next process to run by default with <code>fg</code> or <code>bg</code> ;
  </li>
  <li>
    a <code>-</code> : this process is the next process to take the <code>+</code> ;
  </li>
</ul>

<ol start="3">
  <li>
    <em x-id="4">Running</em> (running process) or <em x-id="4">Stopped</em> (suspended process).
  </li>
  
  <li>
    the command
  </li>
</ol>



<h3 spaces-before="0">
  <code>nice</code> and <code>renice</code> commands
</h3>

<p spaces-before="0">
  The command <code>nice</code> allows the execution of a command by specifying its priority.
</p>

<pre><code>nice priority command
</code></pre>

<p spaces-before="0">
  Example:
</p>

<pre><code>$ nice -n+15 find / -name "file"
</code></pre>

<p spaces-before="0">
  Unlike <code>root</code>, a standard user can only reduce the priority of a process. Only values between +0 and +19 will be accepted.
</p>

<p spaces-before="0">
  !!! Tip This last limitation can be lifted on a per-user or per-group basis by modifying the <code>/etc/security/limits.conf</code> file.
</p>

<p spaces-before="0">
  The <code>renice</code> command allows you to change the priority of a running process.
</p>

<pre><code>renice priority [-g GID] [-p PID] [-u UID]
</code></pre>

<p spaces-before="0">
  Example:
</p>

<pre><code>$ renice +15 -p 1664
</code></pre>
<table spaces-before="0">
  <tr>
    <th>
      Option
    </th>
    
    <th>
      Description
    </th>
  </tr>
  
  <tr>
    <td>
      <code>-g</code>
    </td>
    
    <td>
      <code>GID</code> of the process owner group.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>-p</code>
    </td>
    
    <td>
      <code>PID</code> of the process.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>-u</code>
    </td>
    
    <td>
      <code>UID</code> of the process owner.
    </td>
  </tr>
</table>

<p spaces-before="0">
  The <code>renice</code> command acts on processes already running. It is therefore possible to change the priority of a specific process, but also of several processes belonging to a user or a group.
</p>

<p spaces-before="0">
  !!! Tip The <code>pidof</code> command, coupled with the <code>xargs</code> command (see the Advanced Commands course), allows a new priority to be applied in a single command:
</p>

<pre><code>$ pidof sleep | xargs renice 20
</code></pre>



<h3 spaces-before="0">
  <code>top</code> command
</h3>

<p spaces-before="0">
  The <code>top</code> command displays the processes and their resource consumption.
</p>

<pre><code>$ top
PID  USER PR NI ... %CPU %MEM  TIME+    COMMAND
2514 root 20 0       15    5.5 0:01.14   top
</code></pre>

<table spaces-before="0">
  <tr>
    <th>
      Column
    </th>
    
    <th>
      Description
    </th>
  </tr>
  
  <tr>
    <td>
      <code>PID</code>
    </td>
    
    <td>
      Process identifier.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>USER</code>
    </td>
    
    <td>
      Owner user.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>PR</code>
    </td>
    
    <td>
      Process priority.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>NI</code>
    </td>
    
    <td>
      Nice value.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>%CPU</code>
    </td>
    
    <td>
      Processor load.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>%MEM</code>
    </td>
    
    <td>
      Memory load.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>TIME+</code>
    </td>
    
    <td>
      Processor usage time.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>COMMAND</code>
    </td>
    
    <td>
      Command executed.
    </td>
  </tr>
</table>

<p spaces-before="0">
  The <code>top</code> command allows control of the processes in real time and in interactive mode.
</p>



<h3 spaces-before="0">
  <code>pgrep</code> and <code>pkill</code> commands
</h3>

<p spaces-before="0">
  The <code>pgrep</code> command searches the running processes for a process name and displays the <em x-id="4">PID</em> matching the selection criteria on the standard output.
</p>

<p spaces-before="0">
  The <code>pkill</code> command will send the specified signal (by default <em x-id="4">SIGTERM</em>) to each process.
</p>

<pre><code>pgrep process
pkill [-signal] process
</code></pre>

<p spaces-before="0">
  Examples:
</p>

<ul>
  <li>
    Get the process number from <code>sshd</code>:
  </li>
</ul>

<pre><code>$ pgrep -u root sshd
</code></pre>

<ul>
  <li>
    Kill all <code>tomcat</code> processes:
  </li>
</ul>

<pre><code>$ pkill tomcat
</code></pre>
