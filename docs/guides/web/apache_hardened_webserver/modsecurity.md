---
title: Web-based Application Firewall (WAF)
author: Steven Spencer
contributors: Ezequiel Bruni
tested with: 8.5
tags:
  - web
  - security
  - apache
  - nginx
---
  
# Web-based application firewall (WAF)

## Prerequisites

* A Rocky Linux Web Server running Apache
* Proficiency with a command-line editor (using _vi_ in this example)
* A heavy comfort level with issuing commands from the command-line, viewing logs, and other general systems administrator duties
* An understanding that installing this tool also requires monitoring of actions and tuning to your environment
* An account on Comodo's WAF site
* The root user runs all commands or a regular user with sudo

## Introduction

`mod_security` is an open source web-based application firewall (WAF). It is just one possible piece of a hardened Apache web server setup. Use it with, or without, other tools.

If you want to use this along with other tools for hardening, refer back to the [Apache Hardened Web Server guide](index.md). This document also uses all of the assumptions and conventions outlined in that original document. It is a good idea to review it before continuing.

One thing that is missing with `mod_security` when installed from the generic Rocky Linux repositories, is that the rules installed are minimal at best. To get a more extensive package of no cost `mod_security` rules, we are using [Comodo's](https://www.comodo.com/) WAF installation procedure after installing the base package.

Note that Comodo is a business that sells tools to help secure networks. The no cost `mod_security` tools might not be no cost forever and they do require that you setup a login with Comodo to gain access to the rules.

## Installing `mod_security`

To install the base package, use this command. It will install any missing dependencies. You also need `wget` if you do not have it installed, do that also:

```
dnf install mod_security wget
```

## Setting up your Comodo account

To setup your no cost account, go to [Comodo's WAF site](https://waf.comodo.com/), and click the "Sign Up" link at the top of the page. This requires you to setup username and password information, but requires no credit-card or other billing.

The credentials that you use for signing on to the web site you will use in your setup of Comodo's software and for obtaining the rules. You will need to keep these safe in a password manager somewhere.

The "Terms and Conditions" section of the form that you need to fill out to use Comodo Web Application Firewall (CWAF) cover all of their products and services. That said, read this carefully before agreeing to the terms!

## Installing CWAF

Before you start, in order for the script to actually run after we download it, you are going to need some development tools. Install the package with:

```
dnf group install 'Development Tools'
```

In addition, you will need to have your web server running for Comodo to see `mod_security` correctly. Start it if it is not already running:

```
systemctl start httpd
```

After signing up with Comodo, you will get an email with instructions on what to do next. Essentially, what you need to do is to login to the web site with your credentials and download the client install script.

From the root directory of your server, use the `wget` command to download the installation program:

```
wget https://waf.comodo.com/cpanel/cwaf_client_install.sh
```

Run installation program by typing:

```
bash cwaf_client_install.sh
```

This will extract the installation program and start the process, echoing to the screen. You'll get a message part way down:

```
No web host management panel found, continue in 'standalone' mode? [y/n]:
```

Type "y" and the script will continue.

You might also get this notice:

```
Some required perl modules are missed. Install them? This can take a while. [y/n]:
```

If you do enter "y" and those missing modules will install.

```
Enter CWAF login: username@domain.com
Enter password for 'username@domain.com' (will not be shown): *************************
Confirm password for 'username@domain.com' (will not be shown): ************************
```

You will probably have to download the rules and install them in the correct location, because the password field requires a punctuation or special character, but the configuration file apparently has issues with this when sending it to Comodo's site from the installation program or update script.

These scripts will always fail with a credentials error. This probably does not affect administrators who have web servers running with a GUI front end (Cpanel or Plesk) but if you are running the program standalone as in our example, it does. [You can find the workaround below](#cwaf_fix).

```
Enter absolute CWAF installation path prefix (/cwaf will be appended): /usr/local
Install into '/usr/local/cwaf' ? [y/n]:
```

Just accept the path and enter "y" in the next field for the install path.

If you have a non-standard path to the configuration file for Apache or nginx, you can enter it here, otherwise just use <kbd>Enter</kbd> for no changes:

```
If you have non-standard Apache/nginx config path enter it here:
```

Here is where the failure comes in, and the only workaround is to manually download and install the rules. Answer the prompts as shown below:

```
Do you want to use HTTP GUI to manage CWAF rules? [y/n]: n
Do you want to protect your server with default rule set? [y/n]: y
```

Expect to get the next message also:

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

That is a little frustrating. You can go to your account on the Comodo web site and change your password and re-run the install script, but it will not change anything. The credentials will still fail.

### <a name="cwaf_fix"></a> CWAF rules file workaround

To fix this, you need to manually install the rules from the web site. This is done by logging into your account on https://waf.comodo.com and clicking on the "Download Full Rule Set" link. You will need to copy the rules to your web server with `scp'


Example:

```
scp cwaf_rules-1.233.tgz root@mywebserversdomainname.com:/root/
```

With this done move the file to the rules directory:


```
mv /root/cwaf_rules-1.233.tgz /usr/local/cwaf/rules/
```

then go to the rules directory:

```
cd /usr/local/cwaf/rules/
```

and extract the rules:

```
tar xzvf cwaf_rules-1.233.tgz
```

Handling future partial updates requires this same method.

This is where paying for rules and support can come in handy. It all depends on your budget.

### Configuring CWAF

When you installed `mod_security`, the default configuration file is here:  `/etc/httpd/conf.d/mod_security.conf`. The next thing you need to do is to change this in two places. Start by editing the file:


```
vi /etc/httpd/conf.d/mod_security.conf
```

At the top of the file, you will see:

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

Next go to the bottom of this configuration file. You need to tell `mod_security` where to load the rules. You should see this at the bottom of the file before you make changes:

```
    # ModSecurity Core Rules Set and Local configuration
	IncludeOptional modsecurity.d/*.conf
	IncludeOptional modsecurity.d/activated_rules/*.conf
	IncludeOptional modsecurity.d/local_rules/*.conf
</IfModule>
```

You need to add in one line at the bottom to add the CWAF configuration, which in turn loads the CWAF rules. That line is `Include "/usr/local/cwaf/etc/cwaf.conf"`. The bottom of this file now looks like this:

```
    # ModSecurity Core Rules Set and Local configuration
	IncludeOptional modsecurity.d/*.conf
	IncludeOptional modsecurity.d/activated_rules/*.conf
	IncludeOptional modsecurity.d/local_rules/*.conf
   	Include "/usr/local/cwaf/etc/cwaf.conf"
</IfModule>
```

Save your changes (with vi it is `SHIFT+:+wq!`) and restart httpd:

```
systemctl restart httpd
```

If httpd starts OK, you are ready to use `mod_security` with the CWAF.

## Conclusion

`mod_security` with CWAF is another tool to help in hardening an Apache web server. Because CWAF's passwords require punctuation and because the standalone installation does not send that punctuation correctly, managing CWAF rules requires logging into the CWAF site and downloading rules and changes.

`mod_security`, as with other hardening tools, has the potential of false-positive responses, so you must prepare to tune this tool to your installation.

Like other solutions mentioned in the [Apache Hardened Web Server guide](index.md), there are other no cost and fee-based solutions for `mod_security` rules, and for that matter, other WAF applications available. You can review one of these at [Atomicorp's _mod\_security_ site](https://atomicorp.com/atomic-modsecurity-rules/).
