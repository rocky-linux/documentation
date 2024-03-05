---
title: Web-based Application Firewall (WAF)
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.8, 9.2
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
* The root user runs all commands or a regular user with `sudo`

## Introduction

`mod_security` is an open source web-based application firewall (WAF). It is just one possible piece of a hardened Apache web server setup. Use it with, or without, other tools.

If you want to use this and other hardening tools, refer back to the [Apache Hardened Web Server guide](index.md). This document also uses all of the assumptions and conventions outlined in that original document. It is a good idea to review it before continuing.

One thing missing with `mod_security` when installed from the generic Rocky Linux repositories, is that the rules installed are minimal. To get a more extensive package of no cost `mod_security` rules, this procedure uses [OWASP `mod_security` rules found here](https://coreruleset.org/). OWASP stands for the Open Web Application Security Project. You can [find out more about OWASP here](https://owasp.org/).

!!! tip

    As stated, this procedure uses the OWASP `mod_security` rules. What is not used is the configuration provided by that site. That site also provides great tutorials on using `mod_security` and other security-related tools. The document you are working through mow does nothing but help you install the tools and rules needed for hardening with `mod_security` on a Rocky Linux web server. Netnea is a team of technical professionals that provides security courses on their website. Much of this content is available at no cost, but they *do* have options for in-house or group training.

## Installing `mod_security`

To install the base package, use this command. It will install any missing dependencies. You also need `wget` if you do not have it installed:

```bash
dnf install mod_security wget
```

## Installing the `mod_security` rules

!!! note

    It is important to follow this procedure carefully. The configuration from Netnea has been changed to fit Rocky Linux. 

1. Access the current OWASP rules by [going to their GitHub site](https://github.com/coreruleset/coreruleset).

2. On the right hand side of the page, search for the releases and click on the tag for the latest release.

3. Under "Assets" on the next page, right-click on the "Source Code (tar.gz)" link and copy the link.

4. On your server, go to the Apache configuration directory:

    ```bash
    cd /etc/httpd/conf
    ```

5. Enter `wget` and paste your link. Example:

    ```bash
    wget https://github.com/coreruleset/coreruleset/archive/refs/tags/v3.3.5.tar.gz
    ```

6. Decompress the file:

    ```bash
    tar xzvf v3.3.5.tar.gz
    ```

    This creates a directory with the release information in the name. Example: "coreruleset-3.3.5"

7. Create a symbolic link called "crs" linking to the directory of the release. Example:

    ```bash
    ln -s coreruleset-3.3.5/ /etc/httpd/conf/crs
    ```

8. Remove the `tar.gz` file. Example:

    ```bash
    rm -f v3.3.5.tar.gz
    ```

9. Copy the temporary configuration so that it will load when started:

    ```bash
    cp crs/crs-setup.conf.example crs/crs-setup.conf
    ```

    This file is editable, but you probably will not need to make any changes.

The `mod_security` rules are now in place.

## Configuration

With the rules in place, the next step is configuring these rules to load and run when `httpd` and `mod_security` run.

`mod_security` already has a configuration file located in `/etc/httpd/conf.d/mod_security.conf`. You will need to modify this file to include the OWASP rules. To do this, edit that configuration file:

```bash
vi /etc/httpd/conf.d/mod_security.conf
```

Add the following content just before the end tag (`</IfModule`):

```bash
    Include    /etc/httpd/conf/crs/crs-setup.conf

    SecAction "id:900110,phase:1,pass,nolog,\
        setvar:tx.inbound_anomaly_score_threshold=10000,\
        setvar:tx.outbound_anomaly_score_threshold=10000"

    SecAction "id:900000,phase:1,pass,nolog,\
         setvar:tx.paranoia_level=1"


    # === ModSec Core Rule Set: Runtime Exclusion Rules (ids: 10000-49999)

    # ...


    # === ModSecurity Core Rule Set Inclusion

    Include    /etc/httpd/conf/crs/rules/*.conf


    # === ModSec Core Rule Set: Startup Time Rules Exclusions

    # ...
```

Use ++esc++ to get out of insert mode, and ++shift+colon+"wq"++ to save your changes, and quit.

## Restart `httpd` and verify `mod_security`

All you need to do at this point is to restart `httpd`:

```bash
systemctl restart httpd
```

Verify that the service started as expected:

```bash
systemctl status httpd
```

Entries like this in `/var/log/httpd/error_log` will show that `mod_security` is loading correctly:

```bash
[Thu Jun 08 20:31:50.259935 2023] [:notice] [pid 1971:tid 1971] ModSecurity: PCRE compiled version="8.44 "; loaded version="8.44 2020-02-12"
[Thu Jun 08 20:31:50.259936 2023] [:notice] [pid 1971:tid 1971] ModSecurity: LUA compiled version="Lua 5.4"
[Thu Jun 08 20:31:50.259937 2023] [:notice] [pid 1971:tid 1971] ModSecurity: YAJL compiled version="2.1.0"
[Thu Jun 08 20:31:50.259939 2023] [:notice] [pid 1971:tid 1971] ModSecurity: LIBXML compiled version="2.9.13"
```

If you access the web site on the server, you should receive an entry in the `/var/log/httpd/modsec_audit.log` that shows the loading of OWASP rules:

```bash
Apache-Handler: proxy:unix:/run/php-fpm/www.sock|fcgi://localhost
Stopwatch: 1686249687051191 2023 (- - -)
Stopwatch2: 1686249687051191 2023; combined=697, p1=145, p2=458, p3=14, p4=45, p5=35, sr=22, sw=0, l=0, gc=0
Response-Body-Transformed: Dechunked
Producer: ModSecurity for Apache/2.9.6 (http://www.modsecurity.org/); OWASP_CRS/3.3.4.
Server: Apache/2.4.53 (Rocky Linux)
Engine-Mode: "ENABLED"
```

## Conclusion

`mod_security` with OWASP rules is another tool to help in hardening an Apache web server. Periodic checking of the [GitHub site for newer rules](https://github.com/coreruleset/coreruleset) and the latest official release is an ongoing maintenance step you need to make.

`mod_security`, as with other hardening tools, has the potential of false-positive responses, so you must prepare to tune this tool to your installation.

Like other solutions mentioned in the [Apache Hardened Web Server guide](index.md), there are other no cost and fee-based solutions for `mod_security` rules, and for that matter, other WAF applications available. You can review one of these at [Atomicorp's `mod_security` site](https://atomicorp.com/atomic-modsecurity-rules/).
