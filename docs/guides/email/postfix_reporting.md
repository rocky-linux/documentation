---
title: Postfix Process Reporting
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5, 8.6, 9.0
tags:
  - email
  - reports
  - tools
---

# Using Postfix For Server Process Reporting

## Prerequisites

* Complete comfort operating from the command line on a Rocky Linux server
* Familiarity with an editor of your choice (this document uses the _vi_ editor, but you can substitute in your favorite editor)
* An understanding of DNS (the Domain Name System) and host names
* The ability to assign variables in a bash script
* Knowledge of what the _tail_, _more_, _grep_, and _date_ commands do

## Introduction

Many Rocky Linux server administrators write scripts to perform specific tasks, like backups or file synchronization, and many of these scripts generate logs that have useful and sometimes very important information. Just having the logs, though, is not enough. If a process fails and logs that failure, but the busy administrator does not review the log, then a catastrophe could be in the making.

This document shows you how to use the _postfix_ MTA (mail transfer agent) to grab log details from a particular process, and send them to you via email. It also touches on date formats in logs, and helps you identify which format you need to use in the reporting procedure.

Keep in mind, though, that this is just the tip of the iceberg as far as what can be done with reporting via postfix. Please note, too, that it is always a good security move to limit running processes to only those that you will need all the time.

This document shows you how to enable postfix only for the reporting you need it to do, and then shut it down again.

## Postfix Defined

postfix is a server daemon used for sending email. It is more secure and simpler than sendmail, another MTA that was the default go-to MTA for years. It can be used as part of a full-featured mail server.

## Installing postfix

Aside from postfix, we will need _mailx_ for testing our ability to send emails. To install both, and any dependencies required, enter the following on the Rocky Linux server command line:

`dnf install postfix mailx`

!!! warning "Rocky Linux 9.0 Changes"

    This procedure works perfectly fine in Rocky Linux 9.0. The difference here is where the `mailx` command comes from. While you can install it by name in 8.x, `mailx` comes from the appstream package `s-nail` in 9.0. To install the needed packages, you need to use:

    ```
    dnf install postfix s-nail
    ```

## Testing And Configuring Postfix

### Testing Mail First

Before we configure postfix, we need to find out how mail will look when it leaves the server, because we will probably want to change this. To do this, start postfix:

`systemctl start postfix`

Then test it using mail command that is installed with mailx:

`mail -s "Testing from server" myname@mydomain.com`

This will bring up a blank line. Simply type your testing message in here:

`testing from the server`

Now hit enter, and enter a single period:

`.`

The system will respond with:

`EOT`

Our purpose for doing this is to check to see how our mail looks to the outside world, which we can get a feel for from the maillog that goes active with the starting of postfix.

Use this command to see the output of the log file:

`tail /var/log/maillog`

You should see something like this, although the log file may have different domains for the email address, etc:

```
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
The "somehost.localdomain" shows us that we need to make some changes, so stop the postfix daemon first:

`systemctl stop postfix`

## Configuring Postfix

Since we aren't setting up a complete, fully functional mail server, the configuration options that we will be using are not as extensive. The first thing we need to do is to modify the _main.cf_ file (literally the main configuration file for postfix), so let's make a backup first:

`cp /etc/postfix/main.cf /etc/postfix/main.cf.bak`

Then edit it:

`vi /etc/postfix/main.cf`

In our example, our server name is going to be "bruno" and our domain name is going to be "ourdomain.com". Find the line in the file:

`#myhostname = host.domain.tld`

You can either remove the remark (#) or you can add a new line under this line. Based on our example, the line would read:

`myhostname = bruno.ourdomain.com`

Next, find the line for the domain name:

`#mydomain = domain.tld`

Either remove the remark and change it, or add a new line:

`mydomain = ourdomain.com`

Finally, go to the bottom of the file and add this line:

`smtp_generic_maps = hash:/etc/postfix/generic`

Save your changes (in vi, that will be `Shift : wq!`) and exit the file.

Before we continue editing the generic file, we need to see how email will look. Specifically, we want to create the "generic" file that we referenced in the _main.cf_ file above:

`vi /etc/postfix/generic`

This file tells postfix how any email coming from this server should look. Remember our test email and the log file? This is where we fix all of that:

```
root@somehost.localdomain       root@bruno.ourdomain.com
@somehost.localdomain           root@bruno.ourdomain.com
```
Now we need to tell postfix to use all of our changes. This is done with the postmap command:

`postmap /etc/postfix/generic`

Now start postfix and test your email again using the same procedure as above. You should now see that all of the "localdomain" instances have been changed to your actual domain.

### The date Command and a Variable Called today

Not every application will use the same logging format for the date. This means that you may have to get creative with any script you write for reporting by date.

Let's say that you want to look at your system log as an example and pull everything that has to do with dbus-daemon for today's date, and email it to yourself. (It's probably not the greatest example, but it will give you an idea of how we would do this.)

We need to use a a variable in our script that we will call "today" and we want it to relate to output from the "date" command and format it in a specific way, so that we can get the data we need from our system log (in _/var/log/messages_). To start with, let's do some investigative work.  

First, enter the date command in the command line:

`date`

This should give you the default system date output, which could be something like this:

`Thu Mar  4 18:52:28 UTC 2021`

Now let's check our system log and see how it records information. To do this, we will use the "more" and "grep" commands:

`more /var/log/messages | grep dbus-daemon`

Which should give you something like this:

```
Mar  4 18:23:53 hedgehogct dbus-daemon[60]: [system] Successfully activated service 'org.freedesktop.nm_dispatcher'
Mar  4 18:50:41 hedgehogct dbus-daemon[60]: [system] Activating via systemd: service name='org.freedesktop.nm_dispatcher' unit='dbus-org.freedesktop.nm-dispatcher.service' requested by ':1.1' (uid=0 pid=61 comm="/usr/sbin/NetworkManager --no-daemon " label="unconfined")
Mar  4 18:50:41 hedgehogct dbus-daemon[60]: [system] Successfully activated service 'org.freedesktop.nm_dispatcher
```

The date and log outputs need to be exactly the same in our script, so let's look at how to format the date using a variable called "today".

First, let's look at what we need to do with the date to get the same output as the system log. You can reference the [Linux man page](https://man7.org/linux/man-pages/man1/date.1.html) or type `man date` on the command line to pull up the date manual page to get the information you need.

What you will find is that in order to format the date the same way that _/var/log/messages_ has it, we need to use the %b and %e format strings, with %b being the 3 character month and %e being the space-padded day.

### The Script

For our bash script, we can see that we are going to use the date command and a variable called "today". (Keep in mind that "today" is arbitrary. You could call this variable "late_for_dinner" if you wanted!). We will call our script in this example, test.sh and place it in _/usr/local/sbin_:

`vi /usr/local/sbin/test.sh`

Let's start with, well, the beginning of our script. Note that even though the comment in our file says we are sending these messages to email, for now, we are just sending them to a standard log output so that we can verify that they are correct.

Also, in our first attempt, we are grabbing all of the messages for the current date, not just the dbus-daemon messages. We will deal with that shortly.

Another thing to be aware of is that the grep command will return the filename in the output, which we don't want in this case, so we have added the "-h" option to grep to remove the prefix of the filename. In addition, once the variable "today" is set, we need to look for the entire variable as a string, so we need it all in quotes:

```
#!/bin/bash

# set the date string to match /var/log/messages
today=`date +"%b %e"`

# grab the dbus-daemon messages and send them to email
grep -h "$today" /var/log/messages
```

That's it for now, so save your changes and then make the script executable:

`chmod +x /usr/local/sbin/test.sh`

And then let's test it:

`/usr/local/sbin/test.sh`

If all works correctly, you should get a long list of all of the messages in /var/log/messages from today, including but not limited to the dbus-daemon messages.  If so, then the next step is to limit the messages to the dbus-daemon messages. So let's modify our script again:

`vi /usr/local/sbin/test.sh`

```
#!/bin/bash

# set the date string to match /var/log/messages
today=`date +"%b %e"`

# grab the dbus-daemon messages and send them to email
grep -h "$today" /var/log/messages | grep dbus-daemon
```

Running the script again, should get you only the dbus-daemon messages and only the ones that occurred today (whenever you're following this guide).

There's one final step, however. Remember, we need to get this emailed to the administrator for review. Also, because we are only using _postfix_ on this server for reporting, we don't want to leave the service running, so we will start it at the beginning of the script and then stop it at the end. We'll introduce the _sleep_ command here to pause for 20 seconds to make sure that the email has been sent before shutting _postfix_ down again.  This final edit, adds the stop, start, and sleep issues just discussed, and also pipes the content to the administrator's email.

`vi /usr/local/sbin/test.sh`

And modify the script:

```
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

Run the script again, and you should now have an email from the server with the dbus-daemon message.

You can now use [a crontab](../automation/cron_jobs_howto.md) to schedule this to run at a specific time.

## Conclusion

Using postfix can help you keep track of process logs that you want to monitor. You can use it along with bash scripting to gain a firm grasp of your system processes and be informed if there is trouble.
