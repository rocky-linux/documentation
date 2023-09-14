---
title: Variables - Use With Logs
author: Steven Spencer
contributors: Antoine Le Morvan, Ganna Zhyrnova
tested_with: 8.5
tags:
  - bash scripting
  - bash
  - variables example
---

# Using Variables - A Practical Application With Logs

## Introduction

In lesson two, "Bash - Using Variables", you've seen some ways to use variables and learned a lot about what variables can be used for. This is just one practical example of using variables within your bash scripts.

## Information

When a system administrator has to deal with log files, there are sometimes different formats that come into play. Let's say that you want to get some information out of the `dnf.log` (`/var/log/dnf.log`). Let's take a quick look at what that log file looks like using `tail /var/log/dnf.log`:


```
2022-05-04T09:02:18-0400 DEBUG extras: using metadata from Thu 28 Apr 2022 04:25:35 PM EDT.
2022-05-04T09:02:18-0400 DEBUG repo: using cache for: powertools
2022-05-04T09:02:18-0400 DEBUG powertools: using metadata from Thu 28 Apr 2022 04:25:36 PM EDT.
2022-05-04T09:02:18-0400 DEBUG repo: using cache for: epel
2022-05-04T09:02:18-0400 DEBUG epel: using metadata from Tue 03 May 2022 11:55:16 AM EDT.
2022-05-04T09:02:18-0400 DEBUG repo: using cache for: epel-modular
2022-05-04T09:02:18-0400 DEBUG epel-modular: using metadata from Sun 17 Apr 2022 07:09:16 PM EDT.
2022-05-04T09:02:18-0400 INFO Last metadata expiration check: 3:07:06 ago on Wed 04 May 2022 05:55:12 AM EDT.
2022-05-04T09:02:18-0400 DDEBUG timer: sack setup: 512 ms
2022-05-04T09:02:18-0400 DDEBUG Cleaning up.
```

Now take a look at the `messages` log file `tail /var/log/messages`:

```
May  4 08:47:19 localhost systemd[1]: Starting dnf makecache...
May  4 08:47:19 localhost dnf[108937]: Metadata cache refreshed recently.
May  4 08:47:19 localhost systemd[1]: dnf-makecache.service: Succeeded.
May  4 08:47:19 localhost systemd[1]: Started dnf makecache.
May  4 08:51:59 localhost NetworkManager[981]: <info>  [1651668719.5310] dhcp4 (eno1): state changed extended -> extended, address=192.168.1.141
May  4 08:51:59 localhost dbus-daemon[843]: [system] Activating via systemd: service name='org.freedesktop.nm_dispatcher' unit='dbus-org.freedesktop.nm-dispatcher.service' requested by ':1.10' (uid=0 pid=981 comm="/usr/sbin/NetworkManager --no-daemon " label="system_u:system_r:NetworkManager_t:s0")
May  4 08:51:59 localhost systemd[1]: Starting Network Manager Script Dispatcher Service...
May  4 08:51:59 localhost dbus-daemon[843]: [system] Successfully activated service 'org.freedesktop.nm_dispatcher'
May  4 08:51:59 localhost systemd[1]: Started Network Manager Script Dispatcher Service.
May  4 08:52:09 localhost systemd[1]: NetworkManager-dispatcher.service: Succeeded.
```

And finally let's take a look at the output of the `date` command:

```
Wed May  4 09:47:00 EDT 2022
```

## Findings and Goals

What we can see here is that the two log files, `dnf.log` and `messages` display the date in entirely different ways. If we wanted to grab the information from the `messages` log in a bash script using `date` we could do so without much trouble, but getting the same information out of the `dnf.log` would take some doing. Let's say that as a system administrator, you need to review the `dnf.log` daily to make sure that nothing was introduced to the system that you weren't aware of or that might cause problems. You want this information to be grabbed from the `dnf.log` file by date and then emailed to you daily. You will use a `cron` job to automate this, but first we need to get a script that will do what we want it to do.

## Script

To accomplish what we want, we are going to use a variable in our script called "today" that will format the date according to the date displayed in the `dnf.log`.  To get the correct `date` format, we are using the `+%F` which will get us the yyyy-mm-dd format we are looking for. Since all we are concerned with is the day, not the times or any other information, that's all we will need to get the correct information out of the `dnf.log`. Try just this much of the script:

```
#!/usr/bin/env bash
# script to grab dnf.log data and send it to administrator daily

today=`date +%F`
echo $today
```

Here we are using the `echo` command to see if we have been successful with our date formatting. When you run the script, you should get an output with today's date that looks something like this:

```
2022-05-04
```

If so then great, we can remove our "debug" line and continue. Let's add another variable called "logfile" that we will set to `/var/log/dnf.log` and then let's see if we can `grep` that using our "today" variable. For now, let's just let it run to standard output:

```
!/usr/bin/env bash
# script to grab dnf.log data and send it to administrator daily

today=`date +%F`
logfile=/var/log/dnf.log

/bin/grep $today $logfile
```

The `dnf.log` has a lot of information in it every day, so we are not posting that to the screen here, but you should see output that has only today's data in it. Give the script a try and if it works, then we can move on to the next step. After we've checked the output, the next step is that we want to do a pipe redirect to send the information to email.

!!! tip

    You need `mailx` and a mail daemon such as `postfix` installed to accomplish this next step. There's also some configuration that will *probably* be necessary for you to receive email from your server to your companies email address. Don't worry about those steps at this point, because you can check the `maillog` to see if the attempt was made and then work from there to get email from your server to your email address working. That's not something that this document is going to deal with. For now do:

    ```
    dnf install mailx postfix
    systemctl enable --now postfix
    ```

```
#!/usr/bin/env bash
# script to grab dnf.log data and send it to administrator daily

today=`date +%F`
logfile=/var/log/dnf.log

/bin/grep $today $logfile | /bin/mail -s "DNF logfile data for $today" systemadministrator@domain.ext
```

Let's take a look at the additions to the script here. We've added a pipe `|` to redirect output to `/bin/mail` set the subject of the email (`-s`) with what is in double quotes and set the recipient to be "systemadministrator@domain.ext". Replace that last bit with your email address and then try running the script again.

As noted, you probably won't get the email without some changes to your Postfix mail setup, but you should see the attempt in `/var/log/maillog`.

## Next Steps

The next thing you need to do is to get sending email from your server working. You can take a look at [Postfix for Reporting](../../../guides/email/postfix_reporting.md) to get you started on that front. We also need to automate this script to run daily, to do that we will use `cron`. There are multiple references here: [cron](../../../guides/automation/cron_jobs_howto.md), [anacron](../../../guides/automation/anacron.md), and [cronie](../../../guides/automation/cronie.md). For more information on date formatting, check out `man date` or [this link](https://man7.org/linux/man-pages/man1/date.1.html).
