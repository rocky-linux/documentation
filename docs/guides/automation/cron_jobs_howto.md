---
title: cron - Automating Commands
author: Steven Spencer
contributors: Ezequiel Bruni
tested on: 8.5
tags:
  - job automation
  - automation
  - cron
---

# Automating Processes with `cron` and `crontab`

## Prerequisites

* A computer running Rocky Linux
* Some comfort with modifying configuration files from the command-line by using your favorite editor (using `vi` here)

## <a name="assumptions"></a> Assumptions

* Basic knowledge of bash, python, or other scripting or programming tools, and you want to have a script run automatically
* That you are either running as the root user or have switched to root with `sudo -s`  
**(You can run certain scripts in your own directories as your own user. In this case, switching to root is not necessary.)**

## Introduction

Linux provides the _cron_ system, a time-based job scheduler, for automating processes. It is simplistic and yet quite powerful. Want a script or program to run every day at 5 PM? This is where you set that up.

The _crontab_ is essentially a list where users add their own automated tasks and jobs, and it has many options that can simplify things even further. This document will explore some of these. It is a good refresher for those with some experience, and new users can add the `cron` system to their repertoire.

`anacron` is discussed briefly here in reference to the `cron` "dot" directories. `anacron` is run by `cron`, and is helpful for machines that are not up all the time, such as workstations and laptops. The reason for this is that while `cron` runs jobs on a schedule, if the machine is off when the job is scheduled, the job does not run. With `anacron` the job is picked up and run when the machine is on again, even if the scheduled run was in the past. `anacron` though, uses a more randomized approach to running tasks where the timing is not exact. This makes sense for workstations and laptops, but not so much for servers. This can be a problem for things such as server backups, for instance, needing to run a job at a specific time. That is where `cron` provides the best solution for server administrators. Still, server administrators and workstation or notebook users can gain something from both approaches. You can mix and match based on your needs. For more on `anacron` see [anacron - Automating commands](anacron.md).

### <a name="starting-easy"></a>Starting Easy - The `cron` Dot Directories

Built into every Linux system for many versions now, the `cron` "dot" directories help to automate processes quickly. These show up as directories that the `cron` system calls based on their naming conventions. They are run differently, however, based on the process assigned to call them, `anacron` or `cron`. The default behavior is to use `anacron`, but this can be changed by a server, workstation or notebook administrator.

#### <a name="for_servers"></a>For Servers

As stated in the introduction, `cron` normally runs `anacron` these days to run scripts in these "dot" directories. You *may*, want to use these "dot" directories on servers as well, and if that is the case, there are two steps that you can take to verify that these "dot" directories run on a strict schedule. To do this, you need to install a package and remove another one:

`dnf install cronie-noanacron`

and

`dnf remove cronie-anacron`

As you might expect, this removes `anacron` from the server and reverts to running tasks within the "dot" directories on a strict schedule. This is defined by this file: `/etc/cron.d/dailyjobs`, which has the following contents:

```
# Run the daily, weekly, and monthly jobs if cronie-anacron is not installed
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root

# run-parts
02 4 * * * root [ ! -f /etc/cron.hourly/0anacron ] && run-parts /etc/cron.daily
22 4 * * 0 root [ ! -f /etc/cron.hourly/0anacron ] && run-parts /etc/cron.weekly
42 4 1 * * root [ ! -f /etc/cron.hourly/0anacron ] && run-parts /etc/cron.monthly
```

This translates to the following:

* run scripts in `cron.daily` at 04:02:00 every day.
* run scripts in `cron.weekly` at 04:22:00 on Sunday every week.
* run scripts in `cron.monthly` at 04:42:00 on the first day of every month.

#### <a name="for_workstations"></a>For Workstations

If you want to run scripts on a workstation or notebook in the `cron` "dot" directories, nothing special is needed. Just copy your script file into the directory in question, and make sure it is executable. Here are the directories:

* `/etc/cron.hourly` - Scripts placed here will run one minute past the hour every hour. (this is run by `cron` regardless of whether `anacron` is installed or not)
* `/etc/cron.daily` - Scripts placed here will run every day. `anacron` adjusts the timing of these. (see tip)
* `/etc/cron.weekly` - Scripts placed here will run every 7 days, based on the calendar day of the last run time. (see tip)
* `/etc/cron.monthly` - Scripts placed here will run monthly based on the calendar day of the last run time. (see tip)

!!! tip

    These are likely to be run at similar (but not exactly the same) times every day, week, and month. For more exact running times, see the @options below.

Provided you are good with just letting the system auto-run your scripts, and allowing them to run sometime during the specified time, it simplifies the automation of tasks.

!!! note

    There is no rule that says a server administrator cannot use the randomized run times which `anacron` uses to run scripts in the "dot" directories. The use case for this would be for a script that is not time sensitive.

### Create Your Own `cron`

If the automated, randomized times do not work well in [For Workstations above](#for-workstations), and the scheduled times in the [For Servers above](#for-servers), then you can create your own. In this example, we are assuming you are doing this as root. [see Assumptions](#assumptions) To do this, type the following:

`crontab -e`

This will pull up root user's `crontab` as it exists at this moment in your chosen editor, and may look something like this. Go ahead and read through this commented version, as it contains descriptions of each field that we will be using next:

```
# Edit this file to introduce tasks to be run by cron.
#
# Each task to run has to be defined through a single line
# indicating with different fields when the task will be run
# and what command to run for the task
#
# To define the time you can provide concrete values for
# minute (m), hour (h), day of month (dom), month (mon),
# and day of week (dow) or use '*' in these fields (for 'any').
#
# Notice that tasks will be started based on the cron's system
# daemon's notion of time and timezones.
#
# Output of the crontab jobs (including errors) is sent through
# email to the user the crontab file belongs to (unless redirected).
# cron
# For example, you can run a backup of all your user accounts
# at 5 a.m every week with:
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
#
# For more information see the manual pages of crontab(5) and cron(8)
#
# m h  dom mon dow   command
```

Notice that this particular `crontab` file has some of its own documentation built-in. That is not always the case. When modifying a `crontab` on a container or minimalist operating system, the `crontab` will be an empty file unless an entry is in it.

Assume that you have a backup script that you want to run at 10 PM at night. The `crontab` uses a 24 hour clock, this would be 22:00. Assume that the backup script is called "backup" and that it is currently in the _/usr/local/sbin_ directory.

!!! note

    Remember that this script needs to also be executable (`chmod +x`) in order for the `cron` to run it.

To add the job, you:

`crontab -e`

`crontab` stands for "cron table" and the format of the file is, in fact, a loose table layout. Now that you are in the `crontab`, go to the bottom of the file and add your new entry. If you are using `vi` as your default system editor, then this is done with the following keys:

`Shift : $`

Now that you are at the bottom of the file, insert a line and type a brief comment to describe what is going on with your entry. This is done by adding a "#" to the beginning of the line:

`# Backing up the system every night at 10PM`

Now hit enter. You should still be in the insert mode, so the next step is to add your entry. As shown in our empty commented `crontab` (above) this is **m** for minutes, **h** for hours, **dom** for day of month, **mon** for month, and **dow** for day of week.

To run our backup script every day at 10:00, the entry would look like this:

`00  22  *  *  *   /usr/local/sbin/backup`

This says run the script at 10 PM, every day of the month, every month, and every day of the week. This is a simplistic example and things can get quite complicated when you need specifics.

### The @options for `crontab`

Another way to run jobs at a strictly scheduled time (i.e., day, week, month, year, and so on.) is to use the @options, which offer the ability to use more natural timing. The @options consist of:

* `@hourly` runs the script every hour of every day at 0 minutes past the hour. (this is exactly the result of placing your script in `/etc/cron.hourly` too)
* `@daily` runs the script every day at midnight.
* `@weekly` runs the script every week at midnight on Sunday.
* `@monthly` runs the script every month at midnight on the first day of the month.
* `@yearly` runs the script every year at midnight on the first day of January.
* `@reboot` runs the script on system startup only.

!!! note

    Using these `crontab` entries bypasses the `anacron` system and reverts to the `crond.service` whether `anacron` is installed or not.

For our backup script example, if we use the @daily option to run the backup script at midnight, the entry would look like this:

`@daily  /usr/local/sbin/backup`

### More Complex Options

So far, everything we have talked about has had pretty simplistic options, but what about the more complex task timings? Say that you want to run your backup script every 10 minutes during the day (probably not a practical thing to do, but hey, this is an example!). To do this you would write:

`*/10  *   *   *   *   /usr/local/sbin/backup`

What if you wanted to run the backup every 10 minutes, but only on Monday, Wednesday, and Friday?:

`*/10  *   *   *   1,3,5   /usr/local/sbin/backup`

What about every 10 minutes every day except Saturday and Sunday?:

`*/10  *   *   *    1-5    /usr/local/sbin/backup`

In the table, the commas lets you specify individual entries within a field,  and the dash lets you specify a range of values within a field. This can happen in any of the fields, and on many fields at the same time. As you can see, things can get pretty complicated.

When determining when to run a script, you need to take time and plan it out, particularly if the criteria are complex.

## Conclusions

The _cron/crontab_ system is a powerful tool for the Rocky Linux systems administrator or desktop user. It allows you to automate tasks and scripts so that you do not have to remember to run them manually. There are more examples provided here:

* For machines that are **not** on 24 hours a day, explore [anacron - Automating commands](anacron.md).
* For a concise description of `cron` processes, check out [cronie - Timed Tasks](cronie.md)

While the basics are pretty easy, you can get more complex. For more information on `crontab` head up to the [crontab manual page](https://man7.org/linux/man-pages/man5/crontab.5.html). On most systems, you can also enter `man crontab` for additional command details. You can also do a web search for "crontab" which will give you a wealth of results to help you fine-tune your `crontab` skills.
