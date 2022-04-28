---
title: Web-based Application firewall (WAF)
author: Steven Spencer
contributors: Ezequiel Bruni
tested with: 8.5
tags:
  - web
  - security
  - apache
  - nginx
---
  
# Web-based Application Firewall (WAF)

## Prerequisites

* A Rocky Linux Web Server running Apache
* Proficiency with a command-line editor (we are using _vi_ in this example)
* A heavy comfort level with issuing commands from the command-line, viewing logs, and other general systems administrator duties
* An understanding that installing this tool also requires monitoring of actions and tuning to your environment
* An account on Comodo's WAF site
* All commands are run as the root user or sudo

## Introduction

_mod\_security_ is an open-source web-based application firewall (WAF). It is just one possible component of a hardened Apache web server setup and can be used with, or without, other tools.

If you'd like to use this along with other tools for hardening, refer back to the [Apache Hardened Web Server guide](index.md). This document also uses all of the assumptions and conventions outlined in that original document, so it is a good idea to review it before continuing.

One thing that is missing with _mod\_security_ when installed from the generic Rocky Linux repositories, is that the rules installed are minimal at best. To get a more extensive package of free mod_security rules, we are using [Comodo's](https://www.comodo.com/) WAF installation procedure after installing the base package.

Note that Comodo is a business that sells lots of tools to help secure networks. The free _mod\_security_ tools may not be free forever and they do require that you setup a login with Comodo in order to gain access to the rules.

## Installing mod_security

To install the base package, use this command which will install any missing dependencies. We also need _wget_ so if you haven't installed it, do that as well:

`dnf install mod_security wget`

## Setting Up Your Comodo account

To setup your free account, go to [Comodo's WAF site](https://waf.comodo.com/), and click the "Signup" link at the top of the page. You will be required to setup username and password information but no credit-card or other billing will be done.

The credentials that you use for signing on to the web site will be used in your setup of Comodo's software and also to obtain the rules, so you will need to keep these safe in a password manager somewhere.

Please note that the "Terms and Conditions" section of the form that you need to fill out to use Comodo Web Application Firewall (CWAF) is written to cover all of their products and services. That said, you should read this carefully before agreeing to the terms!

## Installing CWAF

Before you start, in order for the script to actually run after we download it, you are going to need some development tools. Install the package with:

`dnf group install 'Development Tools'`

In addition, you will need to have your web server running for Comodo to see _mod\_security_ correctly. So start it if it is not already running:

`systemctl start httpd`

After signing up with Comodo, you will get an email with instructions on what to do next. Essentially, what you need to do is to login to the web site with your new credentials and then download the client install script.

From the root directory of your server, use the wget command to download the installer:

`wget https://waf.comodo.com/cpanel/cwaf_client_install.sh`

Run the installer by typing:

`bash cwaf_client_install.sh`

This will extract the installer and start the process, echoing to the screen. You'll get a message part way down:

`No web host management panel found, continue in 'standalone' mode? [y/n]:`

Type "y" and let the script continue.

You may also get this notice:

`Some required perl modules are missed. Install them? This can take a while. [y/n]: `

If so type "y" and allow those missing modules to install.

```
Enter CWAF login: username@domain.com
Enter password for 'username@domain.com' (will not be shown): *************************
Confirm password for 'username@domain.com' (will not be shown): ************************
```

Please note here that you will probably have to download the rules and install them in the correct location, as the password field requires a punctuation or special character, but the configuration file apparently has issues with this when sending it to Comodo's site from the installer or update script.

These scripts will always fail with a credentials error. This probably doesn't affect administrators who have web servers running with a GUI front end (Cpanel / Plesk) but if you are running the program standalone as we are in our example, it does. [You can find the workaround below](#cwaf_fix).

```
Enter absolute CWAF installation path prefix (/cwaf will be appended): /usr/local
Install into '/usr/local/cwaf' ? [y/n]:
```

Just accept the path as given and then type "y" in the next field for the install path.

If you have a non-standard path to the configuration file for Apache/nginx, you would enter it here, otherwise just hit 'Enter' for no changes:

`If you have non-standard Apache/nginx config path enter it here:`

Here is where the failure comes in, and the only workaround is to manually download and install the rules. Answer the prompts as shown below:

```
Do you want to use HTTP GUI to manage CWAF rules? [y/n]: n
Do you want to protect your server with default rule set? [y/n]: y
```

But expect to get the next message as well:

```
 Warning! Rules have not been updated. Check your credentials and try again later manually
+------------------------------------------------------
| LOG : Warning! Rules have not been updated. Check your credentials and try again later manually
+------------------------------------------------------
| Installation complete!
| Please add the line:
|   Include "/usr/local/cwaf/etc/modsec2_standalone.conf"
| to Apache config file.
| To update ModSecurity ruleset run
|   /usr/local/cwaf/scripts/updater.pl
| Restart Apache after that.
| You may find useful utility /usr/local/cwaf/scripts/cwaf-cli.pl
| Also you may examine file
|   /usr/local/cwaf/INFO.TXT
| for some useful software information.
+------------------------------------------------------
| LOG : All Done!
| LOG : Exiting
```

That's a little frustrating. You can go to your account on the Comodo web site and change your password and re-run the install script, BUT, it won't change anything. The credentials will still fail.

### <a name="cwaf_fix"></a> CWAF Rules File Workaround

To fix this, we need to manually install the rules from the web site. This is done by logging into your account on https://waf.comodo.com and clicking on the the "Download Full Rule Set" link. You'll then need to copy the rules to your web server using scp'

Example: `scp cwaf_rules-1.233.tgz root@mywebserversdomainname.com:/root/`

Once the tar gzip file has been copied over, move the file to the rules directory:

`mv /root/cwaf_rules-1.233.tgz /usr/local/cwaf/rules/`

Then navigate to the rules directory:

`cd /usr/local/cwaf/rules/`

And uncompress the rules:

`tar xzvf cwaf_rules-1.233.tgz`

Any partial updates to the rules will have to be handled in the same way.

This is where paying for rules and support can come in handy. It all depends on your budget.

### Configuring CWAF

When we installed _mod\_security_, the default configuration file was installed in `/etc/httpd/conf.d/mod_security.conf`. The next thing we need to do is to modify this in two places. Start by editing the file:

`vi /etc/httpd/conf.d/mod_security.conf`

At the very top of the file, you will see:

```
<IfModule mod_security2.c>
    # Default recommended configuration
    SecRuleEngine On
```

Beneath the `SecRuleEngine On` line add `SecStatusEngine On` so that the top of the file will now look like this:

```
<IfModule mod_security2.c>
    # Default recommended configuration
    SecRuleEngine On
    SecStatusEngine On
```

Next go to the bottom of this configuration file. We need to tell _mod\_security_ where to load the rules. You should see this at the bottom of the file before you make changes:

```
    # ModSecurity Core Rules Set and Local configuration
	IncludeOptional modsecurity.d/*.conf
	IncludeOptional modsecurity.d/activated_rules/*.conf
	IncludeOptional modsecurity.d/local_rules/*.conf
</IfModule>
```

We need to add in one line at the bottom to add the CWAF configuration, which in turn loads the CWAF rules. That line is `Include "/usr/local/cwaf/etc/cwaf.conf"`. The bottom of this file should look like this when you are done:

```
    # ModSecurity Core Rules Set and Local configuration
	IncludeOptional modsecurity.d/*.conf
	IncludeOptional modsecurity.d/activated_rules/*.conf
	IncludeOptional modsecurity.d/local_rules/*.conf
   	Include "/usr/local/cwaf/etc/cwaf.conf"
</IfModule>
```

Now save your changes (with vi it's `SHIFT+:+wq!`) and restart httpd:

`systemctl restart httpd`

If httpd starts OK, then you are ready to start using _mod\_security_ with the CWAF.

## Conclusion

_mod\_security_ with CWAF is another tool that can be used to help harden an Apache web server. Because CWAF's passwords require punctuation and because the standalone installation does not send that punctuation correctly, managing CWAF rules requires logging into the CWAF site and downloading rules and changes.

_mod\_security_, like other hardening tools, has the potential of false-positive responses, so you must be prepared to tune this tool to your installation.

Like other solutions mentioned in the [Apache Hardened Web Server guide](index.md), there are other free and fee-based solutions for _mod\_security_ rules, and for that matter, other WAF applications available. You can take a look at one of these at [Atomicorp's _mod\_security_ site](https://atomicorp.com/atomic-modsecurity-rules/).
