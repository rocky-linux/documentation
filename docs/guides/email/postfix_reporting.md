---
title: Postfix Process Reporting
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - email
  - reports
  - tools
---

# Using `postfix` for server process reporting

## Prerequisites

- Complete comfort operating from the command line on a Rocky Linux server
- Familiarity with an editor of your choice (this document uses the `vi` editor, but you can substitute in your favorite editor)
- An understanding of DNS (the Domain Name System) and host names
- The ability to assign variables in a bash script
- Knowledge of what the `tail`, `more`, `grep`, and `date` commands do

## Introduction

Many Rocky Linux server administrators write scripts to perform specific tasks, like backups or file synchronization, and many of these scripts generate logs that have useful and sometimes very important information. Just having the logs, though, is not enough. If a process fails and logs that failure, but the busy administrator does not review the log, then a catastrophe could be in the making.

This document shows you how to use the `postfix` MTA (mail transfer agent) to grab log details from a particular process, and send them to you via email. It also touches on date formats in logs, and helps you identify which format you need to use in the reporting procedure.

Remember, this is just the tip of the iceberg regarding what you can do with reporting via `postfix`. Note that it is always a good security move to limit running processes to only those you will need all the time.

This document shows you how to enable postfix only for the reporting you need it to do, and then shut it down again.

## `postfix` defined

`postfix` is a server daemon used for sending email. It is more secure and simpler than sendmail, another MTA that was the default go-to MTA for years. You can use it as part of a full-featured mail server.

## Installing `postfix`

Aside from `postfix`, you will need `mailx` to test your ability to send emails. To install these and any dependencies required, enter the following on the Rocky Linux server command line:

`dnf install postfix mailx`

!!! warning "Rocky Linux 9.0 Changes"

    This procedure works perfectly fine in Rocky Linux 9.0. The difference here is where the `mailx` command comes from. While you can install it by name in 8.x, `mailx` comes from the appstream package `s-nail` in 9.0. To install the needed packages, you need to use:

    ```
    dnf install postfix s-nail
    ```

## Testing and configuring `postfix`

### Testing mail first

Before you configure `postfix`, you need to find out how mail will look when it leaves the server, as you will probably want to change this. To do this, start `postfix`:

`systemctl start postfix`

Test with the `mail` provided by `mailx` (or `s-nail`):

`mail -s "Testing from server" myname@mydomain.com`

This will display a blank line. Type your testing message in here:

`testing from the server`

Hit enter, and enter a single period:

`.`

The system will respond with the following:

`EOT`

The purpose for doing this is to see how our mail looks to the outside world. You can get a feel for this from the _maillog_ that goes active with the starting of `postfix`.

Use this command to see the output of the log file:

`tail /var/log/maillog`

You will see something like this, although the log file will have different domains for the email address, and other items:

```bash
Mar  4 16:51:40 hedgehogct postfix/postfix-script[735]: starting the Postfix mail system
Mar  4 16:51:40 hedgehogct postfix/master[737]: daemon started -- version 3.3.1, configuration /etc/postfix
Mar  4 16:52:04 hedgehogct postfix/pickup[738]: C9D42EC0ADD: uid=0 from=<root>
Mar  4 16:52:04 hedgehogct postfix/cleanup[743]: C9D42EC0ADD: message-id=<20210304165204.C9D42EC0ADD@somehost.localdomain>
Mar  4 16:52:04 hedgehogct postfix/qmgr[739]: C9D42EC0ADD: from=<root@somehost.localdomain>, size=457, nrcpt=1 (queue active)
Mar  4 16:52:05 hedgehogct postfix/smtp[745]: connect to gmail-smtp-in.l.google.com[2607:f8b0:4001:c03::1a]:25: Network is unreachable
Mar  4 16:52:06 hedgehogct postfix/smtp[745]: C9D42EC0ADD: to=<myname@mydomain.com>, relay=gmail-smtp-in.l.google.com[172.217.212.26]
:25, delay=1.4, delays=0.02/0.02/0.99/0.32, dsn=2.0.0, status=sent (250 2.0.0 OK  1614876726 z8si17418573ilq.142 - gsmtp)
Mar  4 16:52:06 hedgehogct postfix/qmgr[739]: C9D42EC0ADD: removed
```

The "somehost.localdomain" shows that you need to make some changes. Stop the `postfix` daemon first:

`systemctl stop postfix`

## Configuring `postfix`

Since you are not setting up a complete, fully functional mail server, the configuration options that you will use are not as extensive. The first thing to do is to modify the _main.cf_ file (literally the main configuration file for `postfix`). Make a backup first:

`cp /etc/postfix/main.cf /etc/postfix/main.cf.bak`

Edit it:

`vi /etc/postfix/main.cf`

In our example, our server name is "bruno" and our domain name is "ourdomain.com". Find the line in the file:

`#myhostname = host.domain.tld`

You can remove the remark (#) or add a line under this line. Based on our example, the line will read:

`myhostname = bruno.ourdomain.com`

Next, find the line for the domain name:

`#mydomain = domain.tld`

Again, remove the remark and change it, or add a line under it:

`mydomain = ourdomain.com`

Finally, go to the bottom of the file and add this line:

`smtp_generic_maps = hash:/etc/postfix/generic`

Save your changes (in `vi` it is `Shift : wq!`) and exit the file.

Before you continue editing the generic file, you need to see how the email will look. Specifically, you want to create the "generic" file that you referenced in the _main.cf_ file above:

`vi /etc/postfix/generic`

This file tells `postfix` how any email coming from this server will look. Remember our test email and the log file? This is where we fix all of that:

```bash
root@somehost.localdomain       root@bruno.ourdomain.com
@somehost.localdomain           root@bruno.ourdomain.com
```

Next, you need to tell `postfix` to use all of our changes. Do this with the postmap command:

`postmap /etc/postfix/generic`

Start `postfix` and test your email again with the same procedure used above. You will now see that all "localdomain" instances are now the actual domain.

### The `date` command and a variable called today

Not every application will use the same logging format for the date. You might have to get creative with any script you write for reporting by date.

Say that you want to see your system log as an example and pull everything that has to do with dbus-daemon for today's date, and email it to yourself. (It is probably not the greatest example, but it will give you an idea of how you might do this.)

You need to use a variable in your script. Call it "today". You want it to relate to output from the "date" command and format it in a specific way, so that you can get the data you need from our system log (in _/var/log/messages_). To start with, do some investigative work.  

First, enter the date command in the command line:

`date`

This will give you the default system date output, which might be something like this:

`Thu Mar  4 18:52:28 UTC 2021`

Check our system log and see how it records information. To do this, use the `more` and `grep` commands:

`more /var/log/messages | grep dbus-daemon`

Which will give you something like this:

```bash
Mar  4 18:23:53 hedgehogct dbus-daemon[60]: [system] Successfully activated service 'org.freedesktop.nm_dispatcher'
Mar  4 18:50:41 hedgehogct dbus-daemon[60]: [system] Activating via systemd: service name='org.freedesktop.nm_dispatcher' unit='dbus-org.freedesktop.nm-dispatcher.service' requested by ':1.1' (uid=0 pid=61 comm="/usr/sbin/NetworkManager --no-daemon " label="unconfined")
Mar  4 18:50:41 hedgehogct dbus-daemon[60]: [system] Successfully activated service 'org.freedesktop.nm_dispatcher
```

The date and log outputs need to be exactly the same in our script. Let us see how to format the date with a variable called "today".

Examine what you need to do with the date to get the same output as the system log. You can reference the [Linux man page](https://man7.org/linux/man-pages/man1/date.1.html) or type `man date` on the command line to pull up the date manual page to get the information you need.

What you will find is to format the date the same way as _/var/log/messages_ , you need to use the %b and %e format strings, with %b being the 3 character month and %e being the space-padded day.

### The script

For our bash script, you can see that you are going to use the `date` command and a variable called "today". (Remember that "today" is arbitrary. You can call this variable anything you like). You will call your script in this example, `test.sh` and place it in _/usr/local/sbin_:

`vi /usr/local/sbin/test.sh`

At the beginning, notice that even though the comment in our file says you are sending these messages to email, for now, you are just sending them to a standard log output to verify that they are correct.

Also, in our first run of the script, you are grabbing all of the messages for the current date not just the dbus-daemon messages. You will deal with that shortly.

Be aware that the `grep` command will return the filename in the output, which you will not want in this case. To remove this, add the "-h" option to grep. In addition, when you set the variable "today", you need to look for the entire variable as a string, which needs the string within quotes:

```bash
#!/bin/bash

# set the date string to match /var/log/messages
today=`date +"%b %e"`

# grab the dbus-daemon messages and send them to email
grep -h "$today" /var/log/messages
```

That is it for now. Save your changes and make the script executable:

`chmod +x /usr/local/sbin/test.sh`

Test it:

`/usr/local/sbin/test.sh`

If all works correctly, you will get a long list of all of the messages in _/var/log/messages_ from today, including but not limited to the dbus-daemon messages. The next step is to limit the messages to the dbus-daemon messages. Change your script again:

`vi /usr/local/sbin/test.sh`

```bash
#!/bin/bash

# set the date string to match /var/log/messages
today=`date +"%b %e"`

# grab the dbus-daemon messages and send them to email
grep -h "$today" /var/log/messages | grep dbus-daemon
```

Running the script again, will get you only the dbus-daemon messages and only the ones that occurred today.

One final step remains. Remember, you need to get this emailed to the administrator for review. Because you are only using `postfix` on this server for reporting, you do not want to leave the service running. Start it at the beginning of the script and stop it at the end. Here, the `sleep` command pauses for 20 seconds, ensuring sending the email before shutting `postfix` down again. This final edit, adds the stop, start, and sleep issues just discussed, and also pipes the content to the administrator's email.

`vi /usr/local/sbin/test.sh`

Change the script:

```bash
#!/bin/bash

# start postfix
/usr/bin/systemctl start postfix

# set the date string to match /var/log/messages
today=`date +"%b %e"`

# grab the dbus-daemon messages and send them to email
grep -h "$today" /var/log/messages | grep dbus-daemon | mail -s "dbus-daemon messages for today" myname@mydomain.com

# make sure the email has finished before continuing
sleep 20

# stop postfix
/usr/bin/systemctl stop postfix
```

Run the script again, and you will now have an email from the server with the dbus-daemon message.

You can now use [a crontab](../automation/cron_jobs_howto.md) to schedule this to run at a specific time.

## Conclusion

Using `postfix` can help you keep track of process logs that you want to monitor. You can use it along with bash scripting to gain a firm grasp of your system processes and be informed if there is trouble.
