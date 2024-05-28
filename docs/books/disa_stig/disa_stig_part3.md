---
title: DISA Apache Web server STIG 
author: Scott Shinn
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.6
tags:
  - DISA
  - STIG
  - security
  - enterprise
---

# Introduction

In part 1 of this series we covered how to build our web server with the base RHEL8 DISA STIG applied, and in part 2 we learned how to test the STIG compliance with the OpenSCAP tool. Now we’re going to actually do something with the system, and build a simple web application and apply the DISA web server STIG: <https://www.stigviewer.com/stig/web_server/>

First lets compare what we’re getting into here, the RHEL 8 DISA STIG is targeted at a very specific platform so the controls are pretty easy to understand in that context, test, and apply.  Application STIGs have to be portable across multiple platforms, so the content here is generic in order to work on different linux distributions (RHEL, Ubuntu, SuSE, etc)**. This means that tools like OpenSCAP won’t help us audit/remediate the configuration, we’re going to have to do this manually. Those STIGs are:

* Apache 2.4 V2R5 - Server; which applies to the web server itself
* Apache 2.4 V2R5 - Site; Which applies to the web application / web site

For our guide, we’re going to create a simple web server that does nothing more than serve static content. We can use the changes we make here to make a base image and then use this base image when we build more complex web servers later.

## Apache 2.4 V2R5 Server Quickstart

Before you start, you'll need to refer back to Part 1 and apply the DISA STIG Security profile. Consider this step 0.

1.) Install `apache` and `mod_ssl`

```bash
dnf install httpd mod_ssl
```

2.) Configuration changes

```bash
sed -i 's/^\([^#].*\)**/# \1/g' /etc/httpd/conf.d/welcome.conf
dnf -y remove httpd-manual
dnf -y install mod_session
  
echo “MaxKeepAliveRequests 100” > /etc/httpd/conf.d/disa-apache-stig.conf
echo “SessionCookieName session path=/; HttpOnly; Secure;” >>  /etc/httpd/conf.d/disa-apache-stig.conf
echo “Session On” >>  /etc/httpd/conf.d/disa-apache-stig.conf
echo “SessionMaxAge 600” >>  /etc/httpd/conf.d/disa-apache-stig.conf
echo “SessionCryptoCipher aes256” >>  /etc/httpd/conf.d/disa-apache-stig.conf
echo “Timeout 10” >>  /etc/httpd/conf.d/disa-apache-stig.conf
echo “TraceEnable Off” >>  /etc/httpd/conf.d/disa-apache-stig.conf
echo “RequestReadTimeout 120” >> /etc/httpd/conf.d/disa-apache-stig.conf

sed -i “s/^#LoadModule usertrack_module/LoadModule usertrack_module/g” /etc/httpd/conf.modules.d/00-optional.conf
sed -i "s/proxy_module/#proxy_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_ajp_module/#proxy_ajp_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_balancer_module/#proxy_balancer_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_ftp_module/#proxy_ftp_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_http_module/#proxy_http_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_connect_module/#proxy_connect_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
```

  3.) Update Firewall policy and start `httpd`

```bash
firewall-cmd --zone=public --add-service=https --permanent
firewall-cmd --zone=public --add-service=https
firewall-cmd --reload
systemctl enable httpd
systemctl start httpd
```

## Detail Controls Overview

If you’ve gotten this far, you’re probably interested in knowing more about what the STIG wants us to do. It helps to understand the importance of the control, and then how it applies to the application. Sometimes the control is technical (change X setting to Y)  and other times it's operational (how you use it).  Generally speaking, a technical control is something you can change with code, and an operational control probably isn’t.

### Levels

* Cat I - (HIGH) - 5 Controls
* Cat II - (MEDIUM) - 41 Controls
* Cat III - (LOW) - 1 Controls

### Types

* Technical - 24  controls
* Operational  - 23 controls

We’re not going to cover the “why” for these changes in this article, just what needs to happen if it is a technical control.  If there is nothing we can change like in the case of an Operational control, the **Fix:** field will be none. The good news in a lot of these cases, this is already the default in Rocky Linux 8, so you don’t need to change anything at all.

## Apache 2.4 V2R5 - Server Details

**(V-214248)** Apache web server application directories, libraries, and configuration files must only be accessible to privileged users.

**Severity:** Cat I High  
**Type:** Operational  
**Fix:**  None, check to make sure only privileged users can access webserver files  

**(V-214242)** The Apache web server must provide install options to exclude the installation of documentation, sample code, example applications, and tutorials.

**Severity:** Cat I High  
**Type:** Technical  
**Fix:**

```bash
sed -i 's/^\([^#].*\)/# \1/g' /etc/httpd/conf.d/welcome.conf
```

**(V-214253)** The Apache web server must generate a session ID using as much of the character set as possible to reduce the risk of brute force.

**Severity:** Cat I High  
**Type:** Technical  
**Fix:**  None, Fixed by default in Rocky Linux 8  

**(V-214273)** The Apache web server software must be a vendor-supported version.

**Severity:** Cat I High  
**Type:** Technical  
**Fix:** None, Fixed by default in Rocky Linux 8  

**(V-214271)** The account used to run the Apache web server must not have a valid login shell and password defined.

**Severity:** Cat I High  
**Type:** Technical  
**Fix:** None, Fixed by default in Rocky Linux 8  

**(V-214245)** The Apache web server must have Web Distributed Authoring (WebDAV) disabled.
**Severity:** Cat II Medium
**Type:** Technical
**Fix:**

```bash
sed -i 's/^\([^#].*\)/# \1/g' /etc/httpd/conf.d/welcome.conf
```

**(V-214264)** The Apache web server must be configured to integrate with an organization's security infrastructure.

**Severity:** Cat II Medium
**Type:** Operational
**Fix:** None, forward web server logs to SIEM

**(V-214243)** The Apache web server must have resource mappings set to disable the serving of certain file types.

**Severity:** Cat II Medium
**Type:** Technical
**Fix:** None,  Fixed by default in Rocky Linux 8

**(V-214240)** The Apache web server must only contain services and functions necessary for operation.

**Severity:** Cat II Medium
**Type:** Technical
**Fix:**

```bash
dnf remove httpd-manual
```

**(V-214238)** Expansion modules must be fully reviewed, tested, and signed before they can exist on a production Apache web server.

**Severity:** Cat II Medium
**Type:** Operational
**Fix:** None, disable all modules not required for the application

**(V-214268)** Cookies exchanged between the Apache web server and the client, such as session cookies, must have cookie properties set to prohibit client-side scripts from reading the cookie data.

**Severity:** Cat II Medium
**Type:** Technical
**Fix:**

```bash
dnf install mod_session
echo “SessionCookieName session path=/; HttpOnly; Secure;” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214269)** The Apache web server must remove all export ciphers to protect the confidentiality and integrity of transmitted information.

**Severity:** Cat II Medium
**Type:** Technical
**Fix:** None, Fixed by default in Rocky Linux 8 DISA STIG security Profile

**(V-214260)** The Apache web server must be configured to immediately disconnect or disable remote access to the hosted applications.

**Severity:** Cat II Medium
**Type:** Operational
**Fix:** None, this is a procedure to stop the web server

**(V-214249)** The Apache web server must separate the hosted applications from hosted Apache web server management functionality.

**Severity:** Cat II Medium
**Type:** Operational
**Fix:** None, this is related to the web applications rather than the server

**(V-214246)** The Apache web server must be configured to use a specified IP address and port.

**Severity:** Cat II Medium
**Type:** Operational
**Fix:** None, the web server should be configured to only listen on a specific IP / port

**(V-214247)** Apache web server accounts accessing the directory tree, the shell, or other operating system functions and utilities must only be administrative accounts.

**Severity:** Cat II Medium
**Type:** Operational
**Fix:** None, all files, and directories served by the web server need to be owned by administrative users, and not the web server user.

**(V-214244)** The Apache web server must allow the mappings to unused and vulnerable scripts to be removed.

**Severity:** Cat II Medium
**Type:** Operational
**Fix:** None, any cgi-bin or other Script/ScriptAlias mappings that are not used must be removed

**(V-214263)** The Apache web server must not impede the ability to write specified log record content to an audit log server.

**Severity:** Cat II Medium
**Type:** Operational
**Fix:** None, Work with the SIEM administrator to allow the ability to write specified log record content to an audit log server.

**(V-214228)** The Apache web server must limit the number of allowed simultaneous session requests.

**Severity:** Cat II Medium
**Type:** Technical
**Fix:**

```bash
echo “MaxKeepAliveRequests 100” > /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214229)** The Apache web server must perform server-side session management.

**Severity:** Cat II Medium
**Type:** Technical
**Fix:**

```bash
sed -i “s/^#LoadModule usertrack_module/LoadModule usertrack_module/g” /etc/httpd/conf.modules.d/00-optional.conf
```

**(V-214266)** The Apache web server must prohibit or restrict the use of nonsecure or unnecessary ports, protocols, modules, and/or services.

**Severity:** Cat II Medium
**Type:** Operational
**Fix:** None, Ensure the website enforces the use of IANA well-known ports for HTTP and HTTPS.

**(V-214241)** The Apache web server must not be a proxy server.

**Severity:** Cat II Medium
**Type:** Technical
**Fix:**

```bash
sed -i "s/proxy_module/#proxy_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_ajp_module/#proxy_ajp_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_balancer_module/#proxy_balancer_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_ftp_module/#proxy_ftp_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_http_module/#proxy_http_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_connect_module/#proxy_connect_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
```

**(V-214265)** The Apache web server must generate log records that can be mapped to Coordinated Universal Time (UTC)** or Greenwich Mean Time (GMT) which are stamped at a minimum granularity of one second.

**Severity:** Cat II Medium
**Type:** Technical
**Fix:** None, Fixed by default in Rocky Linux 8

**(V-214256)** Warning and error messages displayed to clients must be modified to minimize the identity of the Apache web server, patches, loaded modules, and directory paths.

**Severity:** Cat II Medium
**Type:** Operational
**Fix:** Use the "ErrorDocument" directive to enable custom error pages for 4xx or 5xx HTTP status codes.

**(V-214237)** The log data and records from the Apache web server must be backed up onto a different system or media.

**Severity:** Cat II Medium
**Type:** Operational
**Fix:** None, document the web server backup procedures

**(V-214236)** The log information from the Apache web server must be protected from unauthorized modification or deletion.

**Severity:** Cat II Medium
**Type:** Operational
**Fix:** None, document the web server backup procedures

**(V-214261)** Non-privileged accounts on the hosting system must only access Apache web server security-relevant information and functions through a distinct administrative account.
**Severity:** Cat II Medium
**Type:** Operational
**Fix:** None,  Restrict access to the web administration tool to only the System Administrator, Web Manager, or the Web Manager designees.

**(V-214235)** The Apache web server log files must only be accessible by privileged users.

**Severity:** Cat II Medium
**Type:** Operational
**Fix:** None, To protect the integrity of the data that is being captured in the log files, ensure that only the members of the Auditors group, Administrators, and the user assigned to run the web server software is granted permissions to read the log files.

**(V-214234)** The Apache web server must use a logging mechanism that is configured to alert the Information System Security Officer (ISSO) and System Administrator (SA) in the event of a processing failure.

**Severity:** Cat II Medium
**Type:** Operational
**Fix:** None, Work with the SIEM administrator to configure an alert when no audit data is received from Apache based on the defined schedule of connections.

**(V-214233)** An Apache web server, behind a load balancer or proxy server, must produce log records containing the client IP information as the source and destination and not the load balancer or proxy IP information with each event.

**Severity:** Cat II Medium
**Type:** Operational
**Fix:** None, Access the proxy server through which inbound web traffic is passed and configure settings to pass web traffic to the Apache web server transparently.

Refer to <https://httpd.apache.org/docs/2.4/mod/mod_remoteip.html> for additional information on logging options based on your proxy/load balancing setup.

**(V-214231)** The Apache web server must have system logging enabled.

**Severity:** Cat II Medium
**Type:** Technical
**Fix:** None, Fixed by default in Rocky Linux 8

**(V-214232)** The Apache web server must generate, at a minimum, log records for system startup and shutdown, system access, and system authentication events.

**Severity:** Cat II Medium
**Type:** Technical
**Fix:** None, Fixed by default in Rocky Linux 8

V-214251 Cookies exchanged between the Apache web server and client, such as session cookies, must have security settings that disallow cookie access outside the originating Apache web server and hosted application.

**Severity:** Cat II Medium
**Type:** Technical
**Fix:**

```bash
echo “Session On” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214250)** The Apache web server must invalidate session identifiers upon hosted application user logout or other session termination.

**Severity:** Cat II Medium
**Type:** Technical
**Fix:**

```bash
echo “SessionMaxAge 600” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214252)** The Apache web server must generate a session ID long enough that it cannot be guessed through brute force.

**Severity:** Cat II Medium
**Type:** Technical
**Fix:**

```bash
echo “SessionCryptoCipher aes256” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214255)** The Apache web server must be tuned to handle the operational requirements of the hosted application.

**Severity:** Cat II Medium
**Type:** Technical
**Fix:**

```bash
echo “Timeout 10” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214254)** The Apache web server must be built to fail to a known safe state if system initialization fails, shutdown fails, or aborts fail.

**Severity:** Cat II Medium
**Type:** Operational
**Fix:** None, Prepare documentation for disaster recovery methods for the Apache 2.4 web server in the event of the necessity for rollback.

**(V-214257)** Debugging and trace information used to diagnose the Apache web server must be disabled.

**Severity:** Cat II Medium
**Type:** Technical
**Fix:**

```bash
echo “TraceEnable Off” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214230)** The Apache web server must use cryptography to protect the integrity of remote sessions.

**Severity:** Cat II Medium
**Type:** Technical
**Fix:**

```bash
sed -i "s/^#SSLProtocol.*/SSLProtocol -ALL +TLSv1.2/g" /etc/httpd/conf.d/ssl.conf
```

**(V-214258)** The Apache web server must set an inactive timeout for sessions.

**Severity:** Cat II Medium
**Type:** Technical
**Fix:**

```bash
echo “RequestReadTimeout 120” >> /etc/httpd/conf.d/disa-stig-apache.conf
```

**(V-214270)** The Apache web server must install security-relevant software updates within the configured time period directed by an authoritative source (e.g., IAVM, CTOs, DTMs, and STIGs).

**Severity:** Cat II Medium
**Type:** Operational
**Fix:** None, Install the current version of the web server software and maintain appropriate service packs and patches.

**(V-214239)** The Apache web server must not perform user management for hosted applications.

**Severity:** Cat II Medium
**Type:** Technical
**Fix:**  None, Fixed by default in Rocky Linux 8

**(V-214274)** The Apache web server htpasswd files (if present) must reflect proper ownership and permissions.

**Severity:** Cat II Medium
**Type:** Operational
**Fix:** None, Ensure the SA or Web Manager account owns the "htpasswd" file.  Ensure permissions are set to "550".

**(V-214259)** The Apache web server must restrict inbound connections from nonsecure zones.

**Severity:** Cat II Medium
**Type:** Operational
**Fix:** None, Configure the "http.conf" file to include restrictions.
 Example:

```bash
Require not ip 192.168.205
Require not host phishers.example.com
```

**(V-214267)** The Apache web server must be protected from being stopped by a non-privileged user.

**Severity:** Cat II Medium
**Type:** Technical
**Fix:** None, Fixed by Rocky Linux 8 by default

**(V-214262)** The Apache web server must use a logging mechanism that is configured to allocate log record storage capacity large enough to accommodate the logging requirements of the Apache web server.

**Severity:** Cat II Medium
**Type:** Operational
**Fix:** none, Work with the SIEM administrator to determine if the SIEM is configured to allocate log record storage capacity large enough to accommodate the logging requirements of the Apache web server.

**(V-214272)** The Apache web server must be configured in accordance with the security configuration settings based on DoD security configuration or implementation guidance, including STIGs, NSA configuration guides, CTOs, and DTMs.

**Severity:** Cat III Low
**Type:** Operational
**Fix:**  None

## About The Author

Scott Shinn is the CTO for Atomicorp, and part of the Rocky Linux Security team. He has been involved with federal information systems at the White House, Department of Defense, and Intelligence Community since 1995. Part of that was creating STIG’s and the requirement th
at you use them and I am so very sorry about that.
