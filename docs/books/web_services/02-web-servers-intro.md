---
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
title: Part 2. Web Servers Introduction
---

## Introduction

### HTTP protocol

**HTTP** (**H**yper**T**ext **T**ransfer **P**rotocol) has been the most widely used protocol on the Internet since 1990.

This protocol enables the transfer of files (mainly in HTML format but also in CSS, JS, AVI, etc.) localized by a character string called **URL** between a browser (the client) and a Web server (called `httpd` on UNIX machines).

HTTP is a "request-response" protocol operating on top of **TCP** (**T**ransmission **C**ontrol **P**rotocol).

1. The client opens a TCP connection to the server and sends a request.
2. The server analyzes the request and responds according to its configuration.

The HTTP protocol is "**STATELESS**": it does not retain any information about the client's state from one request to the next. Dynamic languages such as PHP, Python, or Java store client session information in memory (as on an e-commerce site).

The current HTTP protocols are version 1.1, which is widely used, and versions 2 and 3, which are gaining adoption.

An HTTP response is a set of lines sent to the browser by the server. It includes:

* A **status line**: specifies the protocol version and the request's processing status using a code and explanatory text. The line comprises three elements separated by a space:
    * The protocol version used
    * The status code
    * The meaning of the code

* **Response header fields**: these optional lines provide additional information about the response and/or the server. Each line consists of a name qualifying the header type, followed by a colon (:) and the header value.

* **The response body**: contains the requested document.

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

    Learning how to use the `curl` command will be very helpful for troubleshooting your servers in the future.

The role of the web server is to translate a URL into a local resource. Consulting the <https://docs.rockylinux.org/> page is like sending an HTTP request to this machine. The DNS service plays an essential role.

### URLs

A **URL** (**U**niform **R**esource **L**ocator) is an ASCII character string used to designate resources on the Internet. It is informally referred to as a web address.

A URL has three parts:

```text
<protocol>://<host>:<port>/<path>
```

* **Protocol name**: This is the language used to communicate over the network, such as HTTP, HTTPS, FTP, etc. The most widely used protocols are HTTP (HyperText Transfer Protocol) and its secure version, HTTPS, which is used to exchange Web pages in HTML format.

* **Login** and **password**: This option allows you to specify access parameters to a secure server. It is not recommended, as the password is visible in the URL (for security purposes).

* **Host**: This is the computer's name hosting the requested resource. Note that the server's IP address can also be used, but it makes the URL less readable.

* **Port number**: This is associated with a service that enables the server to know the requested resource type. The HTTP protocol's default port is port 80 and 443 with HTTPS. So, the port number is optional when the protocol is HTTP or HTTPS.

* **Resource path**: This part lets the server know the location of the resource. Generally, it is the location (directory) and name of the requested file. If nothing in the address specifies a location, it indicates the host's first page. Otherwise, it indicates the path to the page to display.

### Ports

An HTTP request will arrive on port 80 (the default port for HTTP) of the server running on the host. However, the administrator is free to choose the server's listening port.

The HTTP protocol is available in a secure version: the HTTP protocol (port 443). Implement this encrypted protocol with the `mod_ssl` module.

Using other ports is also possible, such as port `8080` (Java EE application servers).

## Apache and Nginx

The two most common web servers for Linux are Apache and Nginx. We will discuss this in the following chapters.
