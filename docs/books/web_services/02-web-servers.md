---
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
---
# Part 2. Web Servers

## Generalities

### HTTP Protocol

**HTTP** (**H**yper**T**ext **T**ransfer **P**rotocol) has been the most widely used protocol on the Internet since 1990.

This protocol enables the transfer of files (mainly in HTML format, but also in CSS, JS, AVI...) localized by a character string called **URL** between a browser (the client) and a Web server (called `httpd` on UNIX machines).

HTTP is a "request-response" protocol operating on top of **TCP** (**T**ransmission **C**ontrol **P**rotocol).

1. The client opens a TCP connection to the server and sends a request.
2. The server analyzes the request and responds according to its configuration.

The HTTP protocol itself is called "**STATELESS**": it doesn't retain any information about the client's state from one request to the next. Dynamic languages such as php, python or java are used to store client session information in memory (as on an e-commerce site, for example).

The HTTP protocol is version 1.1. Version 2 is still currently being deployed.

An HTTP response is a set of lines sent to the browser by the server. It includes:

* A **status line**: this specifies the protocol version used and the processing status of the request, using a code and explanatory text. The line comprises three elements, which must be separated by a space:
  * The protocol version used ;
  * The status code ;
  * The meaning of the code.

* **Response header fields**: these are a set of optional lines providing additional information about the response and/or the server. Each of these lines consists of a name qualifying the header type, followed by a colon (:) and the header value.

* **The response body**: this contains the requested document.

Here's an example of an HTTP response:

```bash
$ curl --head --location https://docs.rockylinux.org
HTTP/2 200 
accept-ranges: bytes
access-control-allow-origin: *
age: 109725
cache-control: public, max-age=0, must-revalidate
content-disposition: inline
content-type: text/html; charset=utf-8
date: Fri, 21 Jun 2024 12:05:24 GMT
etag: "cba6b533f892339d3818dc59c3a5a69a"
server: Vercel
strict-transport-security: max-age=63072000
x-vercel-cache: HIT
x-vercel-id: cdg1::pdqbh-1718971524213-4892bf82d7b2
content-length: 154696
```

!!! NOTE

    Learning the `curl` command usages will be very helpfull for you to troubleshoot your servers in the futur.

The role of the web server is to translate a URL into a local resource. Consulting the http://docs.rockylinux.org/ page is like sending an HTTP request to this machine. The DNS service therefore plays an essential role.

### URLs

A **URL** (**U**niform **R**esource **L**ocator) is an ASCII character string used to designate resources on the Internet. It is informally referred to as a web address.

A URL is divided into three parts:

```
<protocol>://<host>:<port>/<path>
```

* **Protocol name**: this is the language used to communicate over the network, like for example HTTP, HTTPS, FTP, etc. The most widely used protocols are HTTP (HyperText TransferProtocol) and its secure version HTTPS, the protocol used to exchange Web pages in HTML format.

* **Login** and **password**: allows you to specify access parameters to a secure server. This option is not recommended, as the password is visible in the URL (for security purposes).

* **Host**: This is the name of the computer hosting the requested resource. Note that it is possible to use the server's IP address, which makes the URL less readable.

* **Port number**: this is a number associated with a service, enabling the server to know what type of resource is being requested. The default port associated with the HTTP protocol is port number 80 and 443 with HTTPS. Thus, when the protocol in use is HTTP or HTTPS, the port number is optional.

* Resource path: This last part lets the server know where the resource is located, i.e. generally the location (directory) and name of the requested file. If not specified, indicates the first page of the host. Otherwise, indicates the path to the page to be displayed.

### Ports

An HTTP request will arrive on port 80 (default port for http) of the server running on the host. However, the administrator is free to choose the server's listening port.

The http protocol is available in a secure version: the https protocol (port 443). This encrypted protocol is implemented using the `mod_ssl` module.

Other ports can also be used, such as port `8080` (Java EE application servers).

## Apache

In this chapter, you will learn about Apache, the web server.

****

**Objectives**: In this chapter, you will learn how to:

:heavy_check_mark: install and configure apache  

:checkered_flag: **apache**, **http**, **httpd**

**Knowledge**: :star: :star:  
**Complexity**: :star: :star:  

**Reading time**: 30 minutes

****

### Generalities

The Apache HTTP server is the work of a group of volunteers: The Apache Group. This group set out to build a Web server on the same level as commercial products, but as free software (its source code is available).

The original team was joined by hundreds of users who, through their ideas, tests and lines of code, contributed to making Apache the most widely used Web server in the world.

Apache's ancestor is the free server developed by the National Center for Supercomputing Applications at the University of Illinois. The evolution of this server came to a halt when the person in charge left the NCSA in 1994. Users continued to fix bugs and create extensions, which they distributed as "patches", hence the name "a patchee server".

Apache version 1.0 was released on December 1, 1995 (over 30 years ago!).

The development team coordinates its work via a mailing list, where changes are proposed and changes to the software are discussed. Changes are put to the vote before being incorporated into the project. Anyone can join the development team: all you need to do to become a member of The Apache Group is make an active contribution to the project.

The Apache server has a very strong presence on the Internet, still accounting for around 50% of market share for all active sites.

The market share lost by Apache is taken by its biggest challenger: the nginx server. The latter is faster at delivering web pages, and less functionally complete than the giant Apache.

### Installation

Apache is **cross-platform**. It can be used on Linux, Windows, Mac...

The administrator will have to choose between two installation methods:

* **Package installation**: the distribution vendor supplies **stable, supported** (but sometimes older) versions;

* **Installation from source**: the Apache software is compiled, and the administrator can specify the options that interest him or her, thus optimizing the service. Since Apache has a modular architecture, it is generally not necessary to re-compile the apache software to add or remove additional functionalities (add/remove modules).

The package-based installation method is strongly recommended. Additional repositories can be used to install more recent versions of apache on older distributions, but nobody will not provide support in the event of problems.

On EnterpriseLinux distributions, the Apache server is provided by the `httpd` package.

In the future, you may have to install some extra modules. Here are some examples of modules and their respective roles:

* **mod_access**: filters client access by host name, IP address or other characteristic
* **mod_alias**: enables the creation of aliases or virtual directories
* **mod_auth**: authenticates clients
* **mod_cgi**: executes CGI scripts
* **mod_info**: provides information on server status
* **mod_mime**: associates file types with the corresponding action
* **mod_proxy**: proposes a proxy server
* **mod_rewrite**: rewrites URLs
* ...

```bash
sudo dnf install httpd
```

The version installed on RockyLinux 9 is 2.4.

Installing the package creates an `apache` system user and a corresponding `apache` system group.

```bash
$ grep apache /etc/passwd
apache:x:48:48:Apache:/usr/share/httpd:/sbin/nologin
$ grep apache /etc/group
apache:x:48:
```

Enable and start the service:

```bash
$ sudo systemctl enable httpd --now
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
```

You can check the service's status:

```bash
$ sudo systemctl status httpd 
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; preset: disabl>     Active: active (running) since Fri 2024-06-21 14:22:34 CEST; 8s ago
       Docs: man:httpd.service(8)
   Main PID: 4387 (httpd)
     Status: "Started, listening on: port 80"
      Tasks: 177 (limit: 11110)
     Memory: 24.0M
        CPU: 68ms
     CGroup: /system.slice/httpd.service
             ├─4387 /usr/sbin/httpd -DFOREGROUND
             ├─4389 /usr/sbin/httpd -DFOREGROUND
             ├─4390 /usr/sbin/httpd -DFOREGROUND
             ├─4391 /usr/sbin/httpd -DFOREGROUND
```

Don't forget to open your firewall (see Security section).

You can check now the availability of the service:

* from any web browser providing the IP address of your server (for example http://192.168.1.100/).
* directly from your server.

For that, you will have to install a text browser, for example elinks.

```bash
sudo dnf install elinks
```

Browse your server and check the default page:

```bash
elinks http://localhost
```

Installing the httpd package generates a complete tree structure that needs to be fully understood:

```text
/etc/httpd/
├── conf
│   ├── httpd.conf
│   └── magic
├── conf.d
│   ├── README
│   ├── autoindex.conf
│   ├── userdir.conf
│   └── welcome.conf
├── conf.modules.d
│   ├── 00-base.conf
│   ├── 00-brotli.conf
│   ├── 00-dav.conf
│   ├── 00-lua.conf
│   ├── 00-mpm.conf
│   ├── 00-optional.conf
│   ├── 00-proxy.conf
│   ├── 00-systemd.conf
│   ├── 01-cgi.conf
│   ├── 10-h2.conf
│   ├── 10-proxy_h2.conf
│   └── README
├── logs -> ../../var/log/httpd
├── modules -> ../../usr/lib64/httpd/modules
├── run -> /run/httpd
└── state -> ../../var/lib/httpd
/var/log/httpd/
├── access_log
└── error_log
/var/www/
├── cgi-bin
└── html
```

You'll notice that the `/etc/httpd/logs` folder is a symbolic link to the `/var/log/httpd` directory. Similarly, you'll notice that the files making up the default site are stored in the `/var/www/html` folder.

### Configuration

Initially, Apache server configuration was carried out in a single `/etc/httpd/conf/httpd.conf` file. Over time, this file has become increasingly large and less readable.

Modern distributions therefore tend to distribute Apache configuration over a series of `*.conf` files in the directories `/etc/httpd/conf.d` and `/etc/httpd/conf.modules.d`, attached to the main `/etc/httpd/conf/httpd.conf` file by the Include directive.

```bash
$ sudo grep "^Include" /etc/httpd/conf/httpd.conf
Include conf.modules.d/*.conf
IncludeOptional conf.d/*.conf
```

The `/etc/httpd/conf/httpd.conf` file is amply documented. In general, these comments are sufficient to clarify the administrator's options.

Global server configuration is carried out in `/etc/httpd/conf/httpd.conf`.

This file is divided into 3 sections for configuring:

* in **section 1**, the global environment;
* in **section 2**, the default site and default virtual site parameters;
* in **section 3**, the virtual hosts.

**Virtual hosting** lets you put **several virtual sites online** on the same server. The sites are then differentiated according to their domain names, IP addresses, etc.

Modifying a value in section 1 or 2 affects all hosted sites.

In a shared environment, modifications will therefore be made in section 3.

To facilitate future updates, we strongly recommend that you create a section 3 configuration file for each virtual site.

Here is a minimal version of the `httpd.conf` file:

```file
ServerRoot "/etc/httpd"
Listen 80
Include conf.modules.d/*.conf
User apache
Group apache
ServerAdmin root@localhost
<Directory />
    AllowOverride none
    Require all denied
</Directory>
DocumentRoot "/var/www/html"
<Directory "/var/www">
    AllowOverride None
    Require all granted
</Directory>
<Directory "/var/www/html">
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
<IfModule dir_module>
    DirectoryIndex index.html
</IfModule>
<Files ".ht*">
    Require all denied
</Files>
ErrorLog "logs/error_log"
LogLevel warn
<IfModule log_config_module>
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "%h %l %u %t \"%r\" %>s %b" common
    <IfModule logio_module>
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio  
    </IfModule>
    CustomLog "logs/access_log" combined
</IfModule>
<IfModule alias_module>
    ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"
</IfModule>
<Directory "/var/www/cgi-bin">
    AllowOverride None
    Options None
    Require all granted
</Directory>
<IfModule mime_module>
    TypesConfig /etc/mime.types
    AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz
    AddType text/html .shtml
    AddOutputFilter INCLUDES .shtml
</IfModule>
AddDefaultCharset UTF-8
<IfModule mime_magic_module>
    MIMEMagicFile conf/magic
</IfModule>
EnableSendfile on
IncludeOptional conf.d/*.conf
```

#### Section 1

The various directives encountered in section 1 are :

| Option                 | Information                                                                                |
| ---------------------- | ------------------------------------------------------------------------------------------ |
| `ServerTokens`         | This directive will be presented in a future chapter.                                      |
| `ServertRoot`          | Indicates the path to the directory containing all the files making up the Apache server.  |
| `Timeout`              | The number of seconds before the expiry time of a too long request (incoming or outgoing). |
| `KeepAlive`            | Persistent connection (several requests per TCP connection).                               |
| `MaxKeepAliveRequests` | Maximum number of persistent connections.                                                  |
| `KeepAliveTimeout`     | Number of seconds to wait for the next client request before closing the TCP connection.   |
| `Listen`               | Allow apache to listen on specific addresses or ports.                                     |
| `LoadModule`           | Load add-on modules (fewer modules = greater security).                                    |
| `Include`              | Include other server configuration files.                                                  |
| `ExtendedStatus`       | Display more information about the server in the server-status module.                     |
| `User` and `Group`     | Allows Apache processes to be launched with different users. Apache always starts as root, then changes its owner and group. |

##### Multi-Process Modules (MPM)

The Apache server was designed to be a powerful and flexible server, capable of running on a wide variety of platforms.

Different platforms and environments often mean different functionality, or the use of different methods to implement the same functionality as efficiently as possible.

Apache's modular design allows the administrator to choose which features will be included in the server, by selecting which modules to load either at compile-time or at run-time.

This modularity also includes the most basic web server functions.

Certain modules, the Multi-Process Modules (MPM), are responsible for associating with the machine's network ports, accepting requests and distributing them among the various child processes.

The MPM modules are configured in the `/etc/httpd/conf.modules.d/00-mpm.conf` config file:

```file
# Select the MPM module which should be used by uncommenting exactly
# one of the following LoadModule lines.  See the httpd.conf(5) man
# page for more information on changing the MPM.

# prefork MPM: Implements a non-threaded, pre-forking web server
# See: http://httpd.apache.org/docs/2.4/mod/prefork.html
#
# NOTE: If enabling prefork, the httpd_graceful_shutdown SELinux
# boolean should be enabled, to allow graceful stop/shutdown.
#
#LoadModule mpm_prefork_module modules/mod_mpm_prefork.so

# worker MPM: Multi-Processing Module implementing a hybrid
# multi-threaded multi-process web server
# See: http://httpd.apache.org/docs/2.4/mod/worker.html
#
#LoadModule mpm_worker_module modules/mod_mpm_worker.so

# event MPM: A variant of the worker MPM with the goal of consuming
# threads only for connections with active processing
# See: http://httpd.apache.org/docs/2.4/mod/event.html
#
LoadModule mpm_event_module modules/mod_mpm_event.so
```

As you can see, the default MPM is the `mpm_event`.

The performance and capabilities of your web server depend heavily on the choice of MPM.

Choosing one module over another is therefore a complex task, as is optimizing the chosen MPM module (number of clients, queries, etc.).

By default, Apache is configured for a moderately busy service (256 clients max).

##### About keepalive directives

With the `KeepAlive` directive disabled, every resource request on the server requires a TCP connection to be opened, which is time-consuming from a network point of view and requires a lot of system resources.

With the KeepAlive directive set to `On`, the server keeps the connection open with the client for the duration of the Keepalive.

Given that a web page is made up of several files (images, stylesheets, javascripts, etc.), this strategy is a quick winner.

However, it's important to set this value as precisely as possible:

* Too short a value penalizes the customer,
* Too long a value penalizes server resources.

Specific configuration requests may be made by shared hosting customers. In this case, KeepAlive values will be set directly in the customer's VirtualHost or at proxy level (`ProxyKeepalive` and `ProxyKeepaliveTimeout`).

#### Section 2

Section 2 sets the values used by the main server. The main server responds to all requests that are not handled by one of the Virtualhosts in section 3.

The values are also used as default values for virtual sites.

| Option              | Information                                                                                         |
| ------------------- | --------------------------------------------------------------------------------------------------- |
| `ServerAdmin`       | specifies an e-mail address which will appear on certain auto-generated pages, such as error pages. |
| `ServerName`        | specifies the name by which the server will be identified. Can be determined automatically, but it is recommended to specify it explicitly (IP address or DNS name). |
| `DocumentRoot`      | specifies the directory containing files to be served to clients. Default /var/www/html/.           |
| `ErrorLog`          | specifies the path to the error file.                                                               |
| `LogLevel`          | debug, info, notice, warn, error, crit, alert, emerg.                                               |
| `LogFormat`         | define a specific log format to be used with the CustomLog directive.                               |
| `CustomLog`         | specify path to access file.                                                                        |
| `ServerSignature`   | seen in the security part.                                                                          |
| `Alias`             | specifies a directory outside the tree and makes it accessible by context. The presence or absence of the last slash in the context is important. |
| `Directory`         | specifies behaviors and access rights by directory.                                                 |
| `AddDefaultCharset` | specifies the encoding format for pages sent (accented characters can be replaced by ?...).         |
| `ErrorDocument`     | customized error pages.                                                                             |
| `server-status`     | report on server status.                                                                            |
| `server-info`       | report on server configuration.                                                                     |

##### The `ErrorLog` directive

The `ErrorLog` directive is used to define the error log.

This directive defines the name of the file in which the server logs all errors it encounters. If the file path is not absolute, it is assumed to be relative to ServerRoot.

##### The `DirectoryIndex` directive

The DirectoryIndex directive is used to define the site's home page.

This directive specifies the name of the file to be loaded first, which will act as the site index or home page.

Syntax:

```file
DirectoryIndex display-page
```

The full path is not specified, as the file is searched for in the directory specified by DocumentRoot.

Example:

```file
DocumentRoot /var/www/html
DirectoryIndex index.php index.htm
```

This directive specifies the name of the website index file. The index is the default page that opens when the client types the site URL (without having to type the index name). This file must be located in the directory specified by the `DocumentRoot` directive.

The `DirectoryIndex` directive can specify several index file names separated by spaces. For example, a default index page with dynamic content and, as a second choice, a static page.

##### The `Directory` directive

The Directory tag is used to define directory-specific directives.

This tag is used to apply rights to one or more directories. The directory path is entered as an absolute.

Syntax:

```file
<Directory directory-path>
Defining user rights
</Directory>
```

Example:

```file
<Directory /var/www/html/public>
    Require all granted   # we allow everyone
</Directory>
```

The `Directory` section is used to define a block of directives applying to a part of the server's file system. The directives contained in this section will only apply to the specified directory (and its sub-directories).

The syntax of this block accepts wildcards, but it is preferable to use the DirectoryMatch block.

In the following example, we're going to deny access to the server's local hard disk, regardless of the client. The "/" directory represents the root of the hard disk.

```file
<Directory />
	Require all denied
</Directory>
```

In the following example, we're going to authorize access to the /var/www/html publishing directory for all clients.

```file
<Directory /var/www/html>
	Require all granted
</Directory>
```

When the server finds an `.htaccess` file, it needs to know which directives placed in this file are authorized to modify the pre-existing configuration. The handling of `.htaccess` files is controlled by the `AllowOverride` directive, which can only be used in `Directory` directives. When set to `none`, `.htaccess` files are completely ignored.

##### The `mod_status`

The `mod_status` displays a `/server-status` or `/server-info` page summarizing server status:

```file
<Location /server-status>
	SetHandler server-status
	Require local
</Location>

<Location /server-info>
	SetHandler server-info
    Require local
</Location>
```

Please note that this module provides information that should not be accessible to your users.

#### Shared hosting (section 3)

With shared hosting, the customer thinks he's visiting several servers. In reality, there's just one server and several virtual sites.

To set up shared hosting, you need to set up virtual hosts:

* declaring multiple listening ports;
* declaring multiple listening IP addresses (virtual hosting by IP);
* declaring multiple server names (virtual hosting by name);

Each virtual site corresponds to a different tree structure.

Section 3 of the `httpd.conf` file is used to declare these virtual hosts.

To facilitate future updates, we strongly recommend that you create a section 3 configuration file for each virtual site.

Choose virtual hosting "by IP" or "by name". For production use, it is not advisable to mix the two solutions.

* Each virtual site can be configured in an independent ;
* VirtualHosts are stored in `/etc/httpd/conf.d/`;
* The file extension is `.conf`.

##### The `VirtualHost` directive

The `VirtualHost` directive is used to define virtual hosts.

```file
<VirtualHost IP-address[:port]>
	# if the "NameVirtualHost" directive is present
	# then "address-IP" must match the one entered
	# under "NameVirtualHost" as well as for "port".
 ...
 </VirtualHost>
```

If we configure the Apache server with the basic directives seen above, we'll only be able to publish one site. Indeed, we can't publish multiple sites with the default settings: same IP address, same TCP port and no hostname or unique hostname.

The use of virtual sites will enable us to publish several websites on the same Apache server. We're going to define blocks, each of which will describe a website. In this way, each site will have its own configuration.

For ease of understanding, we often associate a website with a single machine. Virtual sites or virtual hosts are so called because they dematerialize the link between machine and website.

Example 1:

```file
Listen 192.168.0.10:8080
<VirtualHost 192.168.0.10:8080>
  DocumentRoot /var/www/site1/
  ErrorLog /var/log/httpd/site1-error.log
</VirtualHost>

Listen 192.168.0.11:9090
<VirtualHost 192.168.0.11:9090>
  DocumentRoot /var/www/site2/
  ErrorLog /var/log/httpd/site2-error.log
</VirtualHost>
```

IP-based virtual hosting is a method of applying certain guidelines based on the IP address and port on which the request is received. In general, this means serving different web sites on different ports or interfaces.

##### The `NameVirtualHost` directive

The `NameVirtualHost` directive is used to define name-based virtual hosts.

This directive is mandatory for setting up name-based virtual hosts. With this directive, we specify the IP address on which the server will receive requests from name-based virtual hosts.

Syntax:

```text
NameVirtualHost adresse-IP[:port]
```

Example:

```test
NameVirtualHost 160.210.169.6:80
```

The directive must be placed before the virtual site description blocks. It designates the IP addresses used to listen for client requests to virtual sites.

To listen for requests on all the server's IP addresses, use the * character.

#### Taking changes into account

For each configuration change, it is necessary to reload the configuration with the following command:

```bash
sudo systemctl reload httpd
```

#### Manual

There is a package containing a site that acts as an Apache user manual. It's called `httpd-manual`. 

```bash
sudo dnf install httpd-manual
sudo systemctl reload httpd
```

Once this package has been installed, you can access the manual with a web browser at http://127.0.0.1/manual.

```bash
$ elinks http://127.0.0.1/manual
```

#### The `apachectl` command

The `apachectl` is the server control interface for Apache httpd server. 

It is a very usefull command with the `-t` or `configtest` witch run a configuration file syntax test.

!!! NOTE

    Very usefull when used with ansible handlers to test the configuration.

### Security

If your server is protected by a firewall (which is a good thing), you may need to consider opening it.

```bash
sudo firewall-cmd --zone=public --add-service=http
sudo firewall-cmd --zone=public --add-service=https
sudo firewall-cmd --reload
```

#### SELinux

By default, if SELinux security is active, it prevents a site from being read from a directory other than `/var/www/`.

The directory containing the site must have the security context `httpd_sys_content_t`.

The current context is checked with the command :

```bash
* ls -Z /dir
```

Add context with the following command:

```bash
sudo chcon -vR --type=httpd_sys_content_t /dir
```

It also prevents the opening of a non-standard port. The port must be opened manually, using the `semanage` command (not installed by default).

```bash
sudo semanage port -a -t http_port_t -p tcp 1664
```

#### User and Group directives

the `User` and `Group` directives define an Apache management account and group.

Historically, Apache was run by root, which caused security problems. Apache is always run by root, but then changes its identity. Generally User `apache` and Group `apache`.

Never ROOT!

The Apache server (`httpd` process) is started by the `root` superuser account. Each client request triggers the creation of a "child" process. To limit risks, these child processes should be launched with a less privileged account.

The User and Group directives are used to declare the account and group used to create child processes.

This account and group must have been created in the system (by default, this is done during installation).

#### File permissions

As a general security rule, web server content must not belong to the process running the server. In our case, the files should not belong to the `apache` user and group, since he has write access to the folders.

We assign the contents to the unprivileged user or to the root user and the associated group. Incidentally, we also take the opportunity to restrict the group's access rights.

```bash
cd /var/www/html
sudo chown -R root:root ./*
sudo find ./ -type d -exec chmod 0755 "{}" \;
sudo find ./ -type f -exec chmod 0644 "{}" \;
```

### Workshop

#### Task 1 : XXX

#### Task 2 : XXX

#### Task 3 : XXX

#### Task 4 : XXX

### Check your Knowledge

:heavy_check_mark: Simple question? (3 answers)

:heavy_check_mark: Question with multiple answers?

* [ ] Answer 1  
* [ ] Answer 2  
* [ ] Answer 3  
* [ ] Answer 4  

## Nginx

In this chapter, you will learn about XXXXXXX.

****

**Objectives**: In this chapter, you will learn how to:

:heavy_check_mark: XXX  
:heavy_check_mark: XXX  

:checkered_flag: **XXX**, **XXX**

**Knowledge**: :star:  
**Complexity**: :star:  

**Reading time**: XX minutes

****

### Generalities

### Configuration

### Security

### Workshop

#### Task 1 : XXX

#### Task 2 : XXX

#### Task 3 : XXX

#### Task 4 : XXX

### Check your Knowledge

:heavy_check_mark: Simple question? (3 answers)

:heavy_check_mark: Question with multiple answers?

* [ ] Answer 1  
* [ ] Answer 2  
* [ ] Answer 3  
* [ ] Answer 4  
