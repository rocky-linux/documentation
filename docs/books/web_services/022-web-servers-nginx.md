---
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
title: Part 2.2 Web Servers Nginx 
---

## Nginx web server

In this chapter, you will learn about the web server Nginx.

****

**Objectives**: You will learn how to:

:heavy_check_mark: install and configure Nginx

:checkered_flag: **nginx**, **http**

**Knowledge**: :star: :star:  
**Complexity**: :star: :star:  

**Reading time**: 15 minutes

****

### Generalities

**Nginx** is a **free HTTP web server under BSD license**. It was first developed in Russia in 2002 by Igor Sysoev. In addition to the standard features of a web server, Nginx provides a **reverse proxy** for the **HTTP** protocol, as well as a proxy for the **POP** and **IMAP** messaging protocols.

The development of the nginx server is a response to the **C10K** problem: supporting 10,000 concurrent connections (common on the modern web) is a real challenge for web servers.

Commercial support is available from Nginx Inc.

The server's internal architecture enables **very high performance** with **low memory consumption** compared to the Apache web server in particular.

Modules complementing the basic functions of the nginx kernel are compile-time bound: they cannot be activated/deactivated on the fly.

Server processes are controlled by a master process, making it possible to **modify configuration or update software without stopping service**.

Nginx has a significant market share of 28% on the busiest sites on the market, just behind Apache (41%).

#### Features

Nginx offers the following basic functions:

* Hosting of static web pages;
* Automatic index page generation;
* Accelerated reverse proxy with cache;
* Load balancing;
* Fault tolerance;
* Cached support for FastCGI, uWSGI, SCGI and memcached cache server;
* Various filters for gzip, xslt, ssi, image transformation, ...
* Support for SSL/TLS and SNI;
* HTTP/2 support.

Other features:

* Hosting by name or IP address;
* Keepalive management of client connections;
* Log management: syslog, rotation, buffer;
* URI rewriting;
* Access control: by IP, password, etc.
* FLV and MP4 streaming.

### Installation

Nginx is available directly from the appstream repository, and more recent versions are available as a dnf module.

```bash
sudo dnf install nginx
sudo systemctl enable nginx --now
```

### Configuration

Nginx configuration is located in `/etc/nginx`:

The `/etc/nginx/nginx.conf` file: global server configuration file. Settings affect the entire server.

!!! NOTE

    The .htaccess file functionality known to Apache administrators does not exist in nginx!

The `nginx.conf` file, stripped of all comments, is provided below for your information:

```bash
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;
include /usr/share/nginx/modules/*.conf;
events {
    worker_connections 1024;
}
http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    access_log  /var/log/nginx/access.log  main;
    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;
    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;
    include /etc/nginx/conf.d/*.conf;
    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;
        include /etc/nginx/default.d/*.conf;
        error_page 404 /404.html;
        location = /404.html {
        }
        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
}
```

Default configuration guidelines:

| Directive                   | Description |
|-----------------------------|-------------|
| `user`                      | Defines the process owner `user` and `group`. If the group is not specified, the group with the same name as the user is used. |
| `worker_processes`          | Defines the number of processes. The optimum value depends on many factors, such as the number of CPU cores, hard disk specifications, etc. In case of doubt, the nginx documentation suggests a starting value equivalent to the number of CPU cores available (the auto value will try to determine this). |
| `pid`                       | Defines a file to store the pid value. |
| `worker_connections`        | Sets the maximum number of simultaneous connections a worker process can open (to the client and to mandated servers). |
| `tcp_nopush`                | `tcp_nopush` is inseparable from the sendfile option. It is used to optimize the quantity of information sent at a single time. Packets are only sent when they have reached their maximum size. |
| `tcp_nodelay`               | Activating `tcp_nodelay` forces data contained in the socket to be sent immediately, regardless of packet size, which is the opposite of what `tcp_nopush` does. |
| `sendfile`                  | Optimize the sending of static files (this option is not required for a proxy-inverse configuration). If sendfile is enabled, nginx ensures that all packets are completed before they are sent to the client (thanks to `tcp_nopush`). When the last packet arrives, nginx disables `tcp_nopush` and forces data to be sent using `tcp_nodelay`. |
| `keepalive_timeout`         | maximum time before closing an inactive connection.                                                |
| `types_hash_max_size`       | Nginx maintains hash tables containing static information. Set the maximum size of the hash table. |
| `include`                   | Include another file or files that match the template provided in the configuration.               |
| `default_type`              | Default MIME type of a request.                                                                    |
| `ssl_protocols`             | Accepted TLS protocol versions.                                                                    |
| `ssl_prefer_server_ciphers` | Prefer server cipher suite to client cipher suite.                                                 |
| `access_log`                | Configure access logs (see “log management” paragraph).                                            |
| `error_log`                 | Configure error logs (see “log management” paragraph).                                             |
| `gzip`                      | The ngx_http_gzip_module is a filter that compresses data transmitted in gzip format.              |
| `gzip_disable`              | Disable gzip based on a regular expression.                                                        |

The nginx configuration is structured as follows:

```text
# global directives

events {
    # worker configuration
}

http {
    # http service configuration

    # Configure the first server listening on port 80
    server {
	    listen 80 default_server;
	    listen [::]:80 default_server;
	    root /var/www/html;
	    index index.html index.htm;
	    server_name _;
	    location / {
		    try_files $uri $uri/ =404;
	    }
    }
}

mail {
    # mail service configuration

# global mail service directives
   server {
        # A first server listening on the pop protocol
        listen     localhost:110;
        protocol   pop3;
        proxy      on;
   }


   server {
        # A second server listening on the imap protocol
       listen     localhost:143;
       protocol   imap;
       proxy      on;
   }
}
```

### https configuration

To configure an https service, you need to add a server block, or modify an existing server block (a server block can listen on both port 443 and port 80).

This block can, for example, be added to the new `/etc/nginx/conf.d/default_https.conf` file:

```bash
server {
    listen              443 ssl default_server;
    ssl_protocols       TLSv1.3 TLSv1.2 TLSv1.1
    ssl_certificate     /path/to/cert.pem;
    ssl_certificate_key /path/to/key.key;
    root                /var/www/html;
    index               index.html index.htm;
    server_name         _;
    location / {
        try_files       $uri $uri/ =404;
    }
}
```

or the default server can be modified to support https:

```bash
server {
    listen              80;
    listen              443 ssl;
    server_name         _;
    ssl_protocols       TLSv1.3 TLSv1.2 TLSv1.1
    ssl_certificate     /path/to/cert.pem;
    ssl_certificate_key /path/to/key.key;
    ...
}
```

### Log management

The `error_log` directive is used to configure error logs.

Syntax of the error_log directive:

```bash
error_log file [level];
```

The first parameter defines a file to receive error logs.

The second parameter determines the log level: debug, info, notice, warn, error, crit, alert or emerg (see syslog chapter of our admin guide).

Logs can be sent to syslog using the “syslog:” prefix.

```bash
access_log syslog:server=192.168.1.100:5514,tag=nginx debug;
```

### Nginx as a reverse proxy

Reverse proxy functionality is provided by the `ngx_http_upstream_module`. It lets you define groups of servers which are then called by the `proxy_pass` or `fastcgi_pass` directives, `memcached_pass`, etc.

Example of a basic configuration, which distributes the load 2/3 to the first server and 1/3 to the second application server:

```bash
    upstream frontservers {
        server front1.rockylinux.lan:8080       weight=2;
        server front2.rockylinux.lan:8080       weight=1;
    }

    server {
        location / {
            proxy_pass http://docs.rockylinux.lan;
        }
    }
```

Servers can be declared as backups:

```bash
    upstream frontservers {
        ...
        server front3.rockylinux.lan:8080   backup;
        server front4.rockylinux.lan:8080   backup;
    }
```

The server directive accepts a number of arguments:

* `max_fails=numberofattempts`: sets the number of connection attempts that must fail during the time period defined by the `fail_timeout` parameter for the server to be considered unavailable. Default value is 1, 0 disables functionality.
* `fail_timeout=time`: sets the time during which a defined number of connections will cause the server to be unavailable, and sets the period of time during which the server will be considered unavailable. The default value is 10 seconds.
