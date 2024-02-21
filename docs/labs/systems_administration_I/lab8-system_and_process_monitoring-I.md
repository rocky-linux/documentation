---
author: Wale Soyinka 
contributors: Steven Spencer, Ganna Zhyrnova
tested on: All Versions
tags:
  - system monitoring
  - process monitoring
  - ps
  - pgrep
  - pidof
  - cgroups
  - pstree
  - top
  - kill
  - lsof
  - pkill
  - exec
---

# Lab 8: System and process monitoring

## Objectives

After completing this lab, you will be able to:

- view and manage processes
- kill errant processes
- change process priority

Estimated time to complete this lab: 60 minutes

## Introduction

These exercises cover a wide range of topics related to monitoring and managing processes on a Linux systems. Topics covered include process identification and control, process priority management, signal handling, resource monitoring, and "cgroups" management.

## Exercise 1

### `ps` and /proc exploration

#### To explore and identify the first system process

1. Log in to the system as any user.

2. Find the name of the process with a process ID of 1 using /proc.

    ```bash
    cat /proc/1/comm
    ```

    !!! question

        What is the name of the process with PID 1?

3. View the name and path to the executable behind the process with PID 1.

    ```bash
    ls -l /proc/1/exe
    ```

    !!! question
  
        What is the path to the executable behind PID 1?

4. Use the `ps` command to find out the name of the process or program behind PID 1.

    ```bash
    ps -p 1 -o comm=
    ```

    !!! question

        Does the `ps` command confirm the name of the process?

5. Use the `ps` command to view the full path and any command-line arguments of the process or program behind PID 1.

    ```bash
    ps -p 1 -o args=
    ```

    !!! question

        What is the full path and command-line arguments for the process with PID 1?

    !!! question

        Why is the process with PID 1 important on a Linux system?

#### To display detailed process information using `ps`

The following steps show how to use `ps` for displaying basic process information.

1. Use the `ps` command to display a list of all processes in a tree structure.

    ```bash
    ps auxf
    ```

    !!! question

        What is the structure of the process list, and what information is displayed?

2. Filter the list to only show processes associated with a specific user, e.g., the user "root."

    ```bash
    ps -U root
    ```

    Confirm that only the processes for the "root" user are displayed.

3. Show processes in a detailed format, including the process tree and threads. Type:

    ```bash
    ps -eH
    ```

    !!! question

        What additional details are shown in this format?

4. Display the processes sorted by CPU usage in descending order.

    ```bash
    ps aux --sort=-%cpu
    ```

    !!! question

        What process is consuming the most CPU?

## Exercise 2

### Managing processes with `kill`

#### To terminate a process using `kill`

1. Start a long running sleep process in the background and display the PID for the process on your terminal. Type:

    ```bash
    (sleep 3600 & MYPROC1=$! && echo PID is: $MYPROC1) 2>/dev/null
    ```

    OUTPUT:

    ```bash
    PID is: 1331933
    ```

    Make a note of the PID for the new process on your system. The PID is also saved in the $MYPROC1 variable.

2. Send a termination signal (SIGTERM) to the `sleep` process.

    ```bash
    kill $MYPROC1
    ```

    Replace $MYPROC1 with the actual PID from step 1.

3. Check if the process has been terminated using `ps` and `ps aux`.

    ```bash
    ps aux | grep -v grep | grep sleep
    ```

#### To terminate processes using `kill` signals

1. Start a new sleep process and make note of its PID. Type:

    ```bash
    (sleep 3600 & MYPROC2=$! && echo PID is: $MYPROC2) 2>/dev/null
    ```

    OUTPUT:

    ```bash
    PID is: 1333258
    ```

2. Send a different signal (e.g., SIGHUP) to the new sleep process. Type:

    ```bash
    kill -1 $MYPROC2
    ```

    Confirm that $MYPROC2 is no longer in the process table.

3. Start a new ping process and make note of its PID. Type:

    ```bash
    { ping localhost > /dev/null 2>&1 & MYPROC3=$!; } \
        2>/dev/null; echo "PID is: $MYPROC3"
    ```

4. Use the `kill` command to send a `SIGTERM` signal to the ping process. Type:

    ```bash
    kill -15 $MYPROC3
    ```

    Replace MYPROC3 with the actual PID of the process on your system.

5. Start a long running process using the `cat` command. Type:

    ```bash
    { cat /dev/random > /dev/null 2>&1 & MYPROC4=$!; } \
     2>/dev/null; echo PID is: $MYPROC4
    ```

    Make a note of the PID for the process on your system.

6. Use `kill` to forcefully terminate the process by sending a SIGKILL signal.

    ```bash
    kill -9 $MYPROC4
    ```

    Confirm that the process is terminated.

    !!! question

        Explain the purpose of sending signals to processes using the `kill` command and the significance of different signal types.

## Exercise 3

### Monitoring System Resources with `top`

#### To monitor system resource usage with `top`

1. Launch the top command to view real-time system statistics.

    ```bash
    top
    ```

    !!! question

        What information is displayed in the top interface?

2. Observe the CPU and memory usage of processes in the top interface.

    !!! question

        What processes are consuming the most CPU and memory?

3. Sort the processes in top by CPU usage (press P) and by memory usage (press M).

    !!! question

        What are the top processes consuming CPU and memory after sorting?

#### To monitor CPU and memory usage of specific processes using `top`

1. Create an arbitrarily large 512MB file that contains random data.

    ```bash
    sudo fallocate -l 512M  ~/large-file.data
    ```

2. Start a resource-intensive process, such as a large file compression.

    ```bash
     tar -czf archive.tar.gz /path/to/large/directory
    ```

3. Open the `top` command to monitor the CPU and memory usage.

    ```bash
     top
    ```

4. Find and select the resource-intensive process in the top interface.

    !!! question

        What is the process ID and resource utilization of the intensive process?

5. Change the sorting order in top to display processes using the most CPU or memory (press P or M).

    !!! question

        What process is at the top of the list after sorting?

6. Exit top by pressing `q`.

#### To monitor processes and resource usage using `top`

1. Launch the `top` command in interactive mode.

    ```bash
    top
    ```

    !!! question

        What information is displayed on the top screen?

2. Use the 1 key to display a summary of individual CPU core usage.

    !!! question

        What is the CPU core usage breakdown for each core?

3. Press u to display processes for a specific user. Enter your username.

    !!! question

        Which processes are currently running for your user?

4. Sort the processes by memory usage (press M) and observe the processes consuming the most memory.

    !!! question

        What processes are using the most memory?

5. Exit top by pressing q.

    !!! question

        Explain the significance of monitoring system resources using the top command and how it can help in troubleshooting performance issues.

## Exercise 4

### Changing Process Priority with `nice` and `renice`

#### To adjust process priority using `nice`

1. Start a CPU-intensive process that runs with default/normal priority. Type:

    ```bash
    bash -c  'while true; do echo "Default priority: The PID is $$"; done'
    ```

    OUTPUT:

    ```bash
    Default priority: The PID is 2185209
    Default priority: The PID is 2185209
    Default priority: The PID is 2185209
    ....<SNIP>...
    ```

    From the output, the value of the PID on our sample system is `2185209`.

    The value of the PID will be different on your system.

    Make note of the value of PID being continuously displayed on the screen on your system.

2. In a different terminal, using your value of the PID, check the process' default priority using `ps`. Type:

    ```bash
    ps -p <PID> -o ni
    ```

    !!! question

        What is the default process priority (`nice` value) of the running process?

3. Using the PID of the process printed, end the process using the `kill` command.

4. Using the `nice` command, relaunch a similar process but with a lower niceness value (i.e. more favorable to the process OR higher priority). Use a `nice` value of `-20`. Type:

    ```bash
    nice -n -20 bash -c  'while true; do echo "High priority: The PID is $$"; done'
    ```

5. Using your own value of the PID, check the process' priority using `ps`. Type:

    ```bash
    ps -p <PID> -o ni
    ```

    !!! question

        Has the process priority been successfully set?

6. Simultaneously press the ++ctrl+c++ keys on your keyboard to `kill` the new high priority process.

7. Using the `nice` command again relaunch another process but this time with a higher niceness value (i.e. least favorable to the process OR lower priority). Use a `nice` value of `19` Type:

    ```bash
     nice -n 19 bash -c  'while true; do echo "Low priority: The PID is $$"; done'
    ```

    OUTPUT:

    ```bash
    Low priority: The PID is 2180254
    Low priority: The PID is 2180254
    ...<SNIP>...
    ```

8. Check the process's custom priority using `ps`. Type:

    ```bash
    ps -p <PID> -o ni
    ```

9. Simultaneously press the ++ctrl+c++ keys on your keyboard to kill the new low priority process.

10. Experiment with altering the priority of different processes to higher and lower values and observe the impact on the process's resource usage.

#### To adjust the priority of a running process using `renice`

1. Start a CPU-intensive process, such as a lengthy mathematical calculation using the md5sum utility. Type:

    ```bash
    find / -path '/proc/*' -prune -o -type f -exec md5sum {} \; > /dev/null
    ```

2. Use the `ps` command to figure out the PID of the previous `find/md5sum` process. Type:

    ```bash
    ps -C find -o pid=
    ```

    OUTPUT:

    ```bash
    2577072
    ```

    From the output, the value of the PID on our sample system is `2577072`.

    The value of the PID will be different on your system.

    Make note of the value of the PID on your system.

3. Use the `renice` command to adjust the priority of the running `find/md5sum` process to a lower niceness value (e.g., -10, higher priority). Type:

    ```bash
    renice  -n -10 -p $(ps -C find -o pid=)
    ```

    OUTPUT:

    ```bash
    <PID> (process ID) old priority 0, new priority -10
    ```

    Replace "<PID>" (above) with the actual PID of the running process.

4. Monitor the resource utilization for the `find/md5sum` process, using `top` (or `htop`).  Type:

    ```bash
    top -cp $(ps -C find -o pid=)
    ```

    !!! question

        Does the process now receive a higher share of CPU resources?

5. Change the priority of the `find/md5sum` process to a higher `nice` value (e.g., 10, lower priority). Type:

    ```bash
    renice  -n 10 -p <PID>
    ```

    OUTPUT:

    ```bash
    2338530 (process ID) old priority -10, new priority 10
    ```

    Replace the "<PID>" (above) with the actual PID of the running process.

    !!! question

        Explain how the `nice` command is used to adjust process priorities and how it affects system resource allocation.

6. Press the ++ctrl+c++ keys simultaneously on your keyboard to stop the `find/md5sum`  process. You can also use the `kill` command to accomplish the same thing.

## Exercise 5

### Identifying processes with `pgrep`

#### To find processes by name using `pgrep`

1. Use the `pgrep` command to identify all processes associated with a specific program or service, such as `sshd`.

    ```bash
    pgrep sshd
    ```

    !!! question

        What are the process IDs of the `sshd` processes?

2. Verify the existence of the identified processes using the `ps` command.

    ```bash
     ps -p <PID1,PID2,...>
    ```

    Replace "<PID1,PID2,...>" with the actual process IDs obtained from step 1.

3. Use the `pgrep` command to identify any processes with a specific name, e.g., "cron."

    ```bash
    pgrep cron
    ```

    !!! question

        Are there any processes with the name "cron"?

    !!! question

        Explain the difference between using `ps` and `pgrep` to identify and manage processes.

## Exercise 6

### Foreground and background processes

This exercise covers managing processes with `fg` and `bg`

#### To manage background and foreground processes using `bg` and `fg`

1. Start a long-running process in the foreground. For example, you can use a simple command like `sleep`. Type:

    ```bash
    sleep 300
    ```

2. Suspend the foreground process by pressing ++ctrl+z++ on your keyboard. This should return you to the shell prompt.

3. List the suspended job using the `jobs` command. Type:

    ```bash
    jobs
    ```

    !!! question

        What is the status of the suspended job?

4. Bring the suspended job back to the foreground using the `fg` command.

    ```bash
    fg
    ```

    !!! question

        What happens when you bring the job back to the foreground?

5. Suspend the job again using ++ctrl+z++, and then move it to the background using the `bg` command.

    ```bash
    bg
    ```

    !!! question

        What is the status of the job now?

    !!! question

        Explain the purpose of foreground and background processes, and how they  are managed using `fg` and `bg` commands.

#### To start a process in the background

1. The `&` symbol can be used to launch a process that immediately runs in the background. For example to start off the `sleep` command in the background type:

    ```bash
    sleep 300 &
    ```

    Suspend the running process using ++ctrl+z++.

2. List the status of all active jobs. Type:

    ```bash
    jobs -l
    ```

    !!! question

        What is the status of the `sleep 300` process?

3. Bring the background process back to the foreground using the `fg` command.

    ```bash
    fg
    ```

4. Prematurely end the `sleep` process by sending it the SIGSTOP signal by pressing ++ctrl+c++.

#### To manage interactive processes using `bg` and `fg`

1. Start an interactive process such as the `vi` text editor to create and edit a sample file text file named "foobar.txt". Type:

    ```bash
    vi foobar1.txt
    ```

    Suspend the running process using `Ctrl` + `Z`.

    Use the `bg` command to move the suspended process to the background.

    ```bash
    bg
    ```

    !!! question

        Is the process now running in the background?

2. Enter the text "Hello" inside `foobar1.txt` in your `vi` editor.

3. Suspend the running `vi` text editing session by pressing ++ctrl+z++.

4. Launch another separate `vi` editor session to create another text file named "foobar2.txt". Type:

    ```bash
    vi foobar2.txt
    ```

5. Enter the sample text "Hi inside foobar2.txt" in the 2nd vi session.

6. Suspend the 2nd vi session using ++ctrl+z++.

7. List the status of all `jobs` on the current terminal. Type:

    ```bash
    jobs -l
    ```

    OUTPUT:

    ```bash
    [1]- 2977364 Stopped       vi foobar1.txt
    [2]+ 2977612 Stopped       vi foobar2.txt
    ```

    You should have at least 2 jobs listed in your output. The number in the 1st column of the output shows the job number - [1] and [2].

8. Resume ==and bring to the foreground== the 1st `vi` session by typing:

    ```bash
    fg %1
    ```

9. Suspend the 1st `vi` session again using ++ctrl+z++.

10. Resume ==and bring to the foreground== the 2nd `vi` session by typing:

    ```bash
    fg %2
    ```

11. Ungracefully terminate both `vi` editing sessions by sending the KILL signal to both  jobs. Follow the `kill` command with the jobs command. Type:

    ```bash
     kill -SIGKILL  %1 %2 && jobs
    ```

    OUTPUT:

    ```bash
    [1]-  Killed                  vi foobar1.txt
    [2]+  Killed                  vi foobar2.txt
    ```

## Exercise 7

### Process identification with `pidof`

#### To find the process ID of a running command using `pidof`

1. Let us pick a sample/common running process whose process ID we want to find. We will use `systemd` as our example.

2. Use the `pidof` command to find the process ID of the `systemd`. Type:

    ```bash
    pidof systemd
    ```

    Make a note of the process ID(s) of `systemd`.

3. Verify the existence of the identified process using the `ps` command.

    ```bash
    ps -p <PID>
    ```

    Replace <PID> with the actual process ID obtained from step 2.

    !!! question

        Explain the difference between `pgrep` and `pidof` for finding the process ID of a running command.

## Exercise 8

### Exploring /sys filesystem

#### To explore the /sys filesystem

1. List the contents of the /sys directory. Type:

    ```bash
    ls /sys
    ```

    !!! question

        What kind of information is stored in the /sys directory?

2. Navigate to a specific /sys entry, for example, the CPU information.

    ```bash
    cd /sys/devices/system/cpu
    ```

3. List the contents of the current directory to explore CPU-related information.

    ```bash
    ls
    ```

    !!! question

        What kind of CPU-related information is available in the /sys filesystem?

    !!! question

        Explain the purpose of the /sys filesystem in Linux and its role in managing system hardware and configuration.

## Exercise 9

### Killing processes by name with `pkill`

#### To terminate processes by name using `pkill`

1. Identify processes with a specific name, such as "firefox."

    ```bash
    pkill firefox
    ```

    !!! question

        Have all processes with the name "firefox" been terminated?

2. Check the status of the processes you killed using `ps`.

    ```bash
     ps aux | grep firefox
    ```

    !!! question

        Are there any remaining processes with the name "firefox"?

    Use `pkill` to forcefully terminate all processes with a specific name.

    ```bash
    pkill -9 firefox
    ```

    Confirm that all processes with the name "firefox" are now terminated.

    !!! question

        What is the difference between using `kill` and `pkill` to terminate processes by name?

## Exercise 10

This exercise covers using the powerful `exec` command.

### Process control with `exec`

#### To replace the current shell with another command using `exec`

1. Start a new shell session. Type:

    ```bash
    bash
    ```

2. In the new shell, run a command that does not exit, such as a simple while loop.

    ```bash
     while true; do echo "Running..."; done
    ```

3. In the current shell, replace the running command with a different one using `exec`.

    ```bash
     exec echo "This replaces the previous command."
    ```

    Note that the previous command is terminated, and the new command is running.

4. Confirm that the old command is no longer running using `ps`.

    ```bash
    ps aux | grep "while true"
    ```

    !!! question

        Is the previous command still running?

    !!! question

        Explain how the `exec` command can be used to replace the current shell process with a different command.

## Exercise 11

### Process management with `killall`

Similar to `kill`, `killall` is a command to terminate processes by name. Some similarities can be observed between the usage of `killall` , `kill`, and `pkill` in process termination.

#### To terminate processes by name using `killall`

1. Identify processes with a specific name, such as "chrome."

    ```bash
     killall chrome
    ```

    !!! question

        Have all processes with the name "chrome" been terminated?

2. Check the status of the processes you killed using `ps`.

    ```bash
     ps aux | grep chrome
    ```

    !!! question

        Are there any remaining processes with the name "chrome"?

3. Use `killall` to forcefully terminate all processes with a specific name.

    ```bash
     killall -9 chrome
    ```

    Confirm that all processes with the name "chrome" are now terminated.

    !!! question

        How does `killall` differ from `pkill` and `kill` when it comes to terminating processes by name?

## Exercise 12

### `cgroups` management

#### To manage processes using `cgroups`

1. List the existing `cgroups` on your system.

    ```bash
    cat /proc/cgroups
    ```

    !!! question

        What are the `cgroup` controllers available on your system?

2. Create a new cgroup using the CPU controller. Name it "mygroup."

    ```bash
    sudo mkdir -p /sys/fs/cgroup/cpu/mygroup
    ```

3. Move a specific process (e.g., a running sleep command) into the "mygroup" `cgroup`.

    ```bash
    echo <PID> | sudo tee /sys/fs/cgroup/cpu/mygroup/cgroup.procs
    ```

    Replace <PID> with the actual PID of the process.

4. Check if the process has been moved to the "mygroup" `cgroup`.

    ```bash
    cat /sys/fs/cgroup/cpu/mygroup/cgroup.procs
    ```

    !!! question

        Is the process listed in the "mygroup" cgroup?

    !!! question

        Explain the concept of `cgroups` in Linux and how they can be used to manage and control resource allocation for processes.

## Exercise 13

### Managing processes with `renice`

#### To adjust the priority of a running process using `renice`

1. Identify a running process with a specific PID and priority using `ps`.

    ```bash
    ps -p <PID> -o ni
    ```

    !!! question

        What is the current priority (nice value) of the process?

2. Use the `renice` command to change the priority (nice value) of the running process.

    ```bash
    renice <PRIORITY> -p <PID>
    ```

    Replace <PRIORITY> with the new priority value you want to set, and <PID> with the actual PID of the process.

3. Verify that the priority of the process has been changed using `ps`.

    ```bash
    ps -p <PID> -o ni
    ```

    !!! question

        Is the priority now different?

4. Experiment with changing the priority to a higher and lower value and observe the impact on the process's resource usage.

    !!! question

        What happens to the process's resource consumption with different nice values?

    !!! question

        Explain how the renice command is used to adjust the priority of running processes and its effects on process resource utilization.
