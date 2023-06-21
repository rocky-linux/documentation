---
title: Pound
author: Steven Spencer
contributors:
tested_with: 8.5, 8.6
tags:
  - proxy
  - proxies
---

# Pound Proxy Server

!!! warning "Pound Missing from EPEL-9"

    As of this writing, on Rocky Linux 9.0, Pound cannot be installed from the EPEL repository. While there are sources out there for SRPM packages, we can't verify the integrity of these sources. For this reason, we do not recommend installing the Pound proxy server on Rocky Linux 9.0 at this time. This may change if the EPEL once again picks up Pound.  Use this procedure specifically for Rocky Linux 8.x versions.

## Introduction

Pound is a web server agnostic reverse proxy and load balancer that is very easy to setup and manage. It does not use a web service itself, but does listen on the web service ports (http, https). 

Now, there are a lot of proxy server options, some referenced in these documentation pages. There is a document on using [HAProxy here](haproxy_apache_lxd.md) and there have been references in other documents to using Nginx for a reverse proxy.

Load balancing services are quite useful for a busy web server environment. Many proxy servers, including the previously mentioned HAProxy, can be used for many service types. 

In the case of Pound, it can only be used for web services, but it's good at what it does.

## Prerequisites and Assumptions

The following are minimum requirements for using this procedure:

* A desire to load balance between a few websites, or a desire to learn a new tool do do the same.
* The ability to execute commands as the root user or use `sudo` to get there.
* Familiarity with a command-line editor. We are using `vi` or `vim` here, but feel free to substitute in your favorite editor.
* Comfort with changing the listen ports on a few types of web servers.
* We are assuming that both the Nginx and the Apache servers are already installed.
* We are assuming that you are using Rocky Linux servers or containers for everything here.
* While we make all kinds of statements regarding `https` below, this guide only deals with the `http` service. To properly do `https`, you'll need to configure your pound server with a real certificate from a real certificate authority.

!!! tip

    If you don't have either of these servers installed, you can do so on a container environment (LXD or Docker) or on bare metal, and get them up and running. For this procedure, you merely need to install them with their respective packages, and enable and start the services. We won't be modifying them significantly in any way.

    ```
    dnf -y install nginx && systemctl enable --now nginx
    ```

    or

    ```
    dnf -y install httpd && systemctl enable --now httpd
    ```

## Conventions

For this procedure, we are going to be using two web servers (known as back end servers), one running Nginx (192.168.1.111) and one running Apache (192.168.1.108). 

Our Pound server (192.168.1.103) will be considered the gateway. 

We will be switching our listen ports on both of the back end servers to 8080 for the Nginx server and 8081 for the Apache server. Everything will be detailed below as we go, so no need to worry about these for the moment.

!!! note

    Remember to change the associated IPs to whatever they are in your own environment and substitute them where applicable throughout this procedure.

## Installing the Pound Server

To install Pound, we need to first install the EPEL (Extra Packages for Enterprise Linux) and run updates in case there is something new with EPEL:

```
dnf -y install epel-release && dnf -y update
```

Then just install Pound. (Yes, that's a capital "P"):

```
dnf -y install Pound
```

## Configuring Pound

Now that the packages are installed we need to configure Pound. We will be using `vi` to update this, but if you prefer `nano` or something else, go ahead and substitute that in:

```bash
vi /etc/pound.cfg
```

The file is set up with default information in it, which makes it easy to see most of the default components of Pound:

```bash
User "pound"
Group "pound"
Control "/var/lib/pound/pound.cfg"

ListenHTTP
    Address 0.0.0.0
    Port 80
End

ListenHTTPS
    Address 0.0.0.0
    Port    443
    Cert    "/etc/pki/tls/certs/pound.pem"
End

Service
    BackEnd
        Address 127.0.0.1
        Port    8000
    End

    BackEnd
        Address 127.0.0.1
        Port    8001
    End
End
```

### Taking a Closer Look

* The "User" and "Group" was taken care of when we did the install
* The "Control" file does not appear to be used anywhere.
* The "ListenHTTP" section represents the service `http` (Port 80) and the "Address" that the proxy will listen on. We will change this to the actual IP of our Pound server.
* The "ListenHTTPS" section represents the service `https` (Port 443) and the "Address" that the proxy will listen on. As with the above, we will change this to the IP to that of the Pound server. The "Cert" option is the self-signed certificate provided by the Pound install process. You would want to replace this in a production environment with a real certificate using either one of these procedures: [Generating SSL Keys](../security/ssl_keys_https.md) or [SSL Keys with Let's Encrypt](../security/generating_ssl_keys_lets_encrypt.md).
* The "Service" section is where the "BackEnd" servers are configured along with their listening ports. You can have as many "BackEnd" servers as you need.

### Changing The Configuration

* change the IP Address under both listen options to our Pound server IP, 192.168.1.103
* change the IP Addresses and ports under the "BackEnd" sections to match our configuration found in "Conventions" above (IPs and Ports)

When you are all done modifying the configuration you should have a changed file that looks something like this:

```bash
User "pound"
Group "pound"
Control "/var/lib/pound/pound.cfg"

ListenHTTP
    Address 192.168.1.103
    Port 80
End

ListenHTTPS
    Address 192.168.1.103
    Port    443
    Cert    "/etc/pki/tls/certs/pound.pem"
End

Service
    BackEnd
        Address 192.168.1.111
        Port    8080
    End

    BackEnd
        Address 192.168.1.108
        Port    8081
    End
End
```

## Configuring Nginx to Listen on 8080

Since we have set the listen port for Nginx in our Pound configuration to 8080, we need to also make that change on our running Nginx server. We do this by modifying the `nginx.conf`:

```bash
vi /etc/nginx/nginx.conf
```

You just want to change the "listen" line to the new port number:

```bash
listen       8080 default_server;
```

Save your changes and then restart the nginx service:

```
systemctl restart nginx
```

## Configuring Apache to listen on 8081

Since we have set the listen port for Apache in our Pound configuration to 8081, we need to also make that change on our running Apache server. We do this by modifying the `httpd.conf`:

```bash
vi /etc/httpd/conf/httpd.conf
```

You want to change the "Listen" line to the new port number:

```bash
Listen 8081
```

Save your changes and restart the httpd service:

```
systemctl restart httpd
```

## Test and Turn Up

Once you have your web services up and running and listening on the right ports on each of our servers, the next step is to turn up the pound service on the Pound server:

```
systemctl enable --now pound
```

!!! warning

    Using Nginx and Apache, as we are doing here for demonstration, will mean that the Nginx server will almost always respond first. For this reason, to test effectively, you will need to assign a low priority to the Nginx server so that you will be able to see both screens. This speaks volumes about the speed of Nginx over Apache. To change the priority for the Nginx server, you just need to add a priority (1-9, with 9 being the lowest priority) in the "BackEnd" section for the Nginx server like this:

    ```
    BackEnd
        Address 192.168.1.111
        Port    8080
        Priority 9
    End
    ```

When you open your proxy server ip in a web browser you should be faced with one of these two screens:

![Pound Nginx](images/pound_nginx.jpg)

Or

![Pound Apache](images/pound_apache.jpg)    

## Using Emergency

One thing that you may need to do when using a load balancer such as Pound, is to take the productions servers off-line for maintenance or to have a fall-back "BackEnd" for a complete outage. This is done with the "Emergency" declaration in the `pound.conf` file. You can only have one "Emergency" declaration per service. In our case, this would appear at the end of the "Service" section in our configuration file:

```
...
Service
    BackEnd
        Address 192.168.1.117
        Port    8080
	Priority 9
    End

    BackEnd
        Address 192.168.1.108
        Port    8081
    End
    Emergency
	   Address 192.168.1.104
	   Port	8000
   End
End
```

This server might only display a message that says, "Down For Maintenance".

## Security Considerations

Something that most documents dealing with load balancing proxy servers will not deal with are the security issues. For instance, if this is a public facing web server, you will need to have the `http` and `https` services open to the world on the load balancing proxy. But what about the "BackEnd" servers? 

Those should only need to be accessed by their ports from the Pound server itself, but since the Pound server is redirecting to 8080 or 8081 on the BackEnd servers, and since the BackEnd servers have `http` listening on those subsequent ports, you can just use the service names for the firewall commands on those BackEnd servers.

In this section we will deal with those concerns, and the `firewalld` commands needed to lock everything down.

!!! warning

    We are assuming that you have direct access to the servers in question and are not remote to them. If you are remote, take extreme caution when removing services from a `firewalld` zone!

    You could lock yourself out of your server by accident.

### Firewall - Pound Server

For the Pound server, as noted above, we want to allow `http` and `https` from the world. You will need to consider whether `ssh` needs to be allowed from the world or not. If you are local to the server, this is probably **NOT** the case. We are assuming that the server here is available via your local network and that you have direct access to it, so we will be locking down `ssh` to our LAN IPs.

To accomplish the above, we will use the built-in firewall for Rocky Linux, `firewalld` and the `firewall-cmd` command structure. For simplicity sake, we will also use two of the built-in zones, "public" and "trusted".

Let's start by adding our source IPs to the "trusted" zone. This is our LAN here (in our example: 192.168.1.0/24):

```
firewall-cmd --zone=trusted --add-source=192.168.1.0/24 --permanent
```

Then, let's add the `ssh` service to the zone:

```
firewall-cmd --zone=trusted --add-service=ssh --permanent
```

Once all of this is completed, reload the firewall with:

```
firewall-cmd --reload
```

And then list out the zone so that you can see everything with `firewall-cmd --zone=trusted --list-all` which should give you something like this:

```bash
trusted (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.1.0/24
  services: ssh
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:

```

Next we need to make changes to the "public" zone, which by default has the `ssh` service enabled. This needs to be carefully removed (again, we are assuming that you are **NOT** remote to the server here!) with the following:

```
firewall-cmd --zone=public --remove-service=ssh --permanent
```
We also need to add `http` and `https` services:

```
firewall-cmd --zone=public --add-service=http --add-service=https --permanent
```

Then we need to reload the firewall before you can see the changes:

```
firewall-cmd --reload
```

And then list out the public zone with `firewall-cmd --zone=public --list-all` which should show you something like this:

```bash
public
  target: default
  icmp-block-inversion: no
  interfaces:
  sources:
  services: cockpit dhcpv6-client http https
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

Within our lab environment, those are the only changes we need to make to our pound server load balancer.

### Firewall - Back End Servers

For the "BackEnd" servers, we do not need to allow access from the world for anything and definitely not for our listen ports that the load balancer will be using. We will need to allow `ssh` from the LAN IPs, and `http` and `https` from our pound load balancer. 

That's pretty much it. 

Again, we are going to add the `ssh` service to our "trusted" zone, with the essentially the same commands we used for our pound server. Then we are going to add a zone called "balance" that we will use for the remaining `http` and `https`, and set the source IPs to that of the load balancer. Are you having fun yet?

To be quick, let's use all of those commands that we used for the "trusted" zone in a single set of commands:

```
firewall-cmd --zone=trusted --add-source=192.168.1.0/24 --permanent
firewall-cmd --zone=trusted --add-service=ssh --permanent
firewall-cmd --reload
firewall-cmd --zone=trusted --list-all
```

After, the "trusted" zone should look like this:

```bash
trusted (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.1.0/24
  services: ssh
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

Again, test your `ssh` rule from an IP on the LAN, and then remove the `ssh` service from the "public" zone. **Remember our warning from above, and do this only if you have local access to the server!**

```
firewall-cmd --zone=public --remove-service=ssh --permanent
firewall-cmd --reload
firewall-cmd --zone=public --list-all
```

The public zone should now look like this:

```bash
public
  target: default
  icmp-block-inversion: no
  interfaces:
  sources:
  services: cockpit dhcpv6-client
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

Now let's add that new zone to deal with `http` and `https`. Remember that the source IP here needs to only be our load balancer (in our example: 192.168.1.103):

!!! note

    A new zone must be added with the `--permanent` option and cannot be used until the firewall is reloaded. Also, don't forget to `--set-target=ACCEPT` for this zone!

```
firewall-cmd --new-zone=balance --permanent
firewall-cmd --reload
firewall-cmd --zone=balance --set-target=ACCEPT
firewall-cmd --zone=balance --add-source=192.168.1.103 --permanent
firewall-cmd --zone=balance --add-service=http --add-service=https --permanent
firewall-cmd --reload
firewall-cmd --zone=balance --list-all
```

The result:

```bash
balance (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.1.103
  services: http https
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

Now repeat those steps on the other web server back end.

Once you have your firewall rules added to everything, test your pound server again from your workstation browser.

## Other Information

There are a *LOT* of options that can be included in your `pound.conf` file, including error message directives, logging options, time out values, etc. You can find more on what is available by [looking here.](https://linux.die.net/man/8/pound)

Conveniently, Pound automatically figures out if one of the "BackEnd" servers is off-line and disables it so that web services can continue without delay. It also automatically sees them again when they are back on-line.

## Conclusion

Pound offers another option for those who do not want to use HAProxy or Nginx as for load balancing. 

Pound as a load balancing server is very easy to install, set up and use. As noted here, Pound can also be used as a reverse proxy, and there are a lot of proxy and load balancing options available. 

And you should always remember to keep security in mind when setting up any service, including a load-balancing proxy server.
