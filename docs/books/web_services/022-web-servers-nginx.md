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

**Nginx** is a **free HTTP web server under BSD license**. It was first developed in Russia in 2002 by Igor Sysoev. In addition to the standard features of a web server, Nginx provides a **reverse proxy** for the **HTTP** protocol, and a proxy for the **POP** and **IMAP** messaging protocols.

The development of the Nginx server is a response to the **C10K** problem, which supports ten thousand concurrent connections (standard on the modern web). This is a real challenge for web servers.

Commercial support is available from Nginx Inc.

The server's internal architecture enables **very high performance** with **low memory consumption** compared to the Apache web server.

Modules complementing the essential functions of the Nginx kernel are compile-time bound. This means activation or deactivation cannot happen dynamically.

A master process controls server processes, making it possible to **modify configuration or update software without stopping the service**.

Nginx has a significant % market share of 28% on the busiest sites, just behind Apache (41%).

#### Features

Nginx offers the following basic functions:

* Hosting of static web pages
* Automatic index page generation
* Accelerated reverse proxy with cache
* Load balancing
* Fault tolerance
* Cached support for FastCGI, uWSGI, SCGI, and Memcached cache server
* Various filters for gzip, xslt, ssi, image transformation, and more
* Support for SSL/TLS and SNI
* HTTP/2 support

Other features:

* Hosting by name or IP address
* Keepalive management of client connections
* Log management: syslog, rotation, buffer
* URI rewriting
* Access control: by IP, password, and more
* FLV and MP4 streaming

### Installation

Nginx is available directly from the app stream repository, and more recent versions are available as a dnf module.

```bash
sudo dnf install nginx
sudo systemctl enable nginx --now
```

### Configuration

The location of the Nginx configuration is in `/etc/nginx/nginx.conf`.

This configuration file is a global server configuration file. Settings affect the entire server.

!!! NOTE

    The .htaccess file functionality known to Apache administrators does not exist in Nginx!

Provided here is the `nginx.conf` file, stripped of all comments:

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
| `worker_processes`          | Defines the number of processes. The optimum value depends on many factors, such as the number of CPU cores and hard disk specifications. In case of doubt, the Nginx documentation suggests a starting value equivalent to the number of CPU cores available (the auto value will try to determine this). |
| `pid`                       | Defines a file to store the PID value. |
| `worker_connections`        | Sets the maximum number of simultaneous connections a worker process can open (to the client and mandated servers). |
| `tcp_nopush`                | `tcp_nopush` is inseparable from the sendfile option. It is used to optimize the quantity of information sent simultaneously. Packets are only sent when they have reached their maximum size. |
| `tcp_nodelay`               | Activating `tcp_nodelay` forces data in the socket to be sent immediately, regardless of packet size, which is the opposite of what `tcp_nopush` does. |
| `sendfile`                  | Optimizes the sending of static files (this option is not required for a proxy-inverse configuration). If sendfile is enabled, Nginx ensures that all packets are completed before they are sent to the client (thanks to `tcp_nopush`). When the last packet arrives, Nginx disables `tcp_nopush` and forces data to be sent using `tcp_nodelay`. |
| `keepalive_timeout`         | The maximum time before closing an inactive connection.                                                |
| `types_hash_max_size`       | Nginx maintains hash tables containing static information. Set the maximum size of the hash table. |
| `include`                   | Includes another file or files that match the template provided in the configuration.               |
| `default_type`              | Default MIME type of a request.                                                                    |
| `ssl_protocols`             | Accepted TLS protocol versions.                                                                    |
| `ssl_prefer_server_ciphers` | Prefers server cipher suite to client cipher suite.                                                 |
| `access_log`                | Configures access logs (see “log management” paragraph).                                            |
| `error_log`                 | Configures error logs (see “log management” paragraph).                                             |
| `gzip`                      | The ngx_http_gzip_module is a filter that compresses data transmitted in gzip format.              |
| `gzip_disable`              | Disables gzip based on a regular expression.                                                        |

The structure of the Nginx configuration is:

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

To configure an HTTPS service, you must add a server block or modify an existing one. A server block can listen on both port 443 and port 80.

You can add this block, for example, to the new `/etc/nginx/conf.d/default_https.conf` file:

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

or you can modify the default server to support HTTPS:

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

You can configure the `error_log` directive for error logs.

Syntax of the `error_log` directive:

```bash
error_log file [level];
```

The first parameter defines a file to receive error logs.

The second parameter determines the log level: debug, info, notice, warn, error, crit, alert, or emerg (see syslog chapter of our admin guide).

The function of sending logs to syslog is with the “syslog:” prefix.

```bash
access_log syslog:server=192.168.1.100:5514,tag=nginx debug;
```

### Nginx as a reverse proxy

Reverse proxy functionality is with the `ngx_http_upstream_module`. It lets you define groups of servers which are then called by the `proxy_pass` or `fastcgi_pass` directives, `memcached_pass`, and more.

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

You can declare servers as backups:

```bash
    upstream frontservers {
        ...
        server front3.rockylinux.lan:8080   backup;
        server front4.rockylinux.lan:8080   backup;
    }
```

The server directive accepts many arguments:

* `max_fails=numberofattempts`: sets the number of connection attempts that must fail during the time period defined by the `fail_timeout` parameter for the server to be considered unavailable. The default value is 1; 0 disables functionality.
* `fail_timeout=time`: sets the time during which a defined number of connections will cause the server to be unavailable, and sets the period of time during which the server will be considered unavailable. The default value is 10 seconds.
