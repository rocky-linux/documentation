---
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
title: Part 2. Web Servers Introduction
---

## Introduction

### HTTP protocol

**HTTP** (**H**yper**T**ext **T**ransfer **P**rotocol) has been the most widely used protocol on the Internet since 1990.

This protocol enables the transfer of files (mainly in HTML format, but also in CSS, JS, AVI...) localized by a character string called **URL** between a browser (the client) and a Web server (called `httpd` on UNIX machines).

HTTP is a "request-response" protocol operating on top of **TCP** (**T**ransmission **C**ontrol **P**rotocol).

1. The client opens a TCP connection to the server and sends a request.
2. The server analyzes the request and responds according to its configuration.

The HTTP protocol is "**STATELESS**": it does not retain any information about the client's state from one request to the next. Dynamic languages such as php, python, or java store client session information in memory (as on an e-commerce site, for example).

The current HTTP protocols are version 1.1, used widely, and versions 2 and 3 which are gaining adoption.

An HTTP response is a set of lines sent to the browser by the server. It includes:

* A **status line**: this specifies the protocol version used and the processing status of the request, using a code and explanatory text. The line comprises three elements separated with a space:
    * The protocol version used
    * The status code
    * The meaning of the code

* **Response header fields**: these are a set of optional lines providing additional information about the response and/or the server. Each of these lines consists of a name qualifying the header type, followed by a colon (:) and the header value.

* **The response body**: this contains the requested document.

Here is an example of an HTTP response:

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

    Learning the `curl` command usage will be very helpfull for you to troubleshoot your servers in the future.

The role of the web server is to translate a URL into a local resource. Consulting the <https://docs.rockylinux.org/> page is like sending an HTTP request to this machine. The DNS service plays an essential role.

### URLs

A **URL** (**U**niform **R**esource **L**ocator) is an ASCII character string used to designate resources on the Internet. It is informally referred to as a web address.

A URL has three parts:

```text
<protocol>://<host>:<port>/<path>
```

* **Protocol name**: this is the language used to communicate over the network, for example HTTP, HTTPS, FTP, and so on. The most widely used protocols are HTTP (HyperText TransferProtocol) and its secure version HTTPS, the protocol used to exchange Web pages in HTML format.

* **Login** and **password**: allows you to specify access parameters to a secure server. This option is not recommended, as the password is visible in the URL (for security purposes).

* **Host**: This is the name of the computer hosting the requested resource. Note that it is possible to use the server's IP address, which makes the URL less readable.

* **Port number**: this is a number associated with a service, enabling the server to know the requested resource type. The default port associated with the HTTP protocol is port number 80 and 443 with HTTPS. So, when the protocol in use is HTTP or HTTPS
, the port number is optional.

* Resource path: This part lets the server know the location of the resource. Generally, the location (directory) and name of the requested file. If nothing in the address specifies a location, it indicates the first page of the host. Otherwise it indicates the path to the page to display.

### Ports

An HTTP request will arrive on port 80 (default port for http) of the server running on the host. However, the administrator is free to choose the server's listening port.

The http protocol is available in a secure version: the https protocol (port 443). Implement this encrypted protocol with the `mod_ssl` module.

Using other ports is also possible, such as port `8080` (Java EE application servers).

## Apache and Nginx

The two most common web servers for Linux are Apache and Nginx. These will be discussed in the following chapters.
