---
title: Monitoring Rocky Linux nodes or clusters by Ganglia
---

# Monitoring Rocky Linux nodes or clusters by Ganglia

This guide walks through the detailed steps to install Ganglia packages in Rocky Linux distribution.

## Install Ganglia-web Interface

!!! General Overview
    Ganglia is a very good software package for monitoring the historical state of clusters or nodes. However, the current ganglia web interface (3.7.5) is based on php-5.6. If you are using a higher version php, such as that in the default environment of **Rocky Linux 8**, ganglia web interface will not be displayed normally. Therefore, configuring and using php-5.6 was the necessary option to run the ganglia web interface in Rocky linux. Docker can easily solve this problem. That is, **running Ganglia-web inside a centos7 container** in the Rocky linux 8 system, which container can easily run the php-5.6. It will **ensure the normal display of the ganglia-web interface**.

### Manually build the container image by Yourself

##### Downlaod this Dockerfile into your system

```
Wget https://raw.githubusercontent.com/berlin2123/ganglia-web-docker/main/ganglia-web-centos7/Dockerfile
```

##### Manually build this container:

```
podman build -t <name_of_the_container_image>  <Path_to_the_Dockerfile>
```

If the Dockerfile is saved to "/root/dockertest/cent7ganglia/", and you want to name this image as "mybuild/cent7ganglia", you can just run:  

```
podman build -t mybuild/cent7ganglia /root/dockertest/cent7ganglia/
```



### Run the container

1. In order to ensure the normal operation of init (systemd) inside container, the host machine needs to open the permission. (When SELinux is enabled)

   ```
   setsebool -P containermanagecgroup true
   ```
2. Run the container

   ```
   podman run -t -d --name ganglia -p 1380:80 --restart always --privileged localhost/mybuild/cent7ganglia
   ```

   You may need to use your own image name. 

   You can check the runing state by 

   ```
   docker logs --since 10m ganglia
   ```
   
3. Modify the internal configuration of the container

   ```
   # enter the container
   docker exec -u root -it ganglia /bin/bash
   # set time zone, to use your time zone, such as,
   timedatectl  set-timezone Asia/Shanghai
   
   # vi /etc/ganglia/gmetad.conf 
   # change the line:
   data_source "my cluster" localhost 
   # to
   data_source "cluster" 10.88.0.1:8649
   
   # After the modification is completed, exit from the container
   exit
   ```
   
4. Create a service (systemd) that automatically starts the ganglia container

   ```
   podman generate systemd --name ganglia > /etc/systemd/system/container-ganglia.service
   ```

   Enable and start this service now

   ```
   systemctl enable --now container-ganglia.service 
   ```

### Create a reverse proxy on the host machine

 to ensure access from other machine into the ganglia-web interface in the container.

1. Write a httpd configure file like this /etc/httpd/conf.d/ganglia.conf 

   ```
   [root@Host ~]# cat /etc/httpd/conf.d/ganglia.conf 
   #
   # Ganglia monitoring system php web frontend
   #
   
   <VirtualHost *:80>
   
   ServerName ganglia.your.servername.com
   
   ProxyPass           "/" "http://127.0.0.1:1380/ganglia/"
   ProxyPassReverse    "/" "http://127.0.0.1:1380/ganglia/"
   
   
   </virtualHost>
   
   ```
2. Open ports, enable permission.

   ```
   # ports:
   firewall-cmd --zone=public --add-service=http --permanent
   firewall-cmd --add-port=1380/tcp --permanent
   firewall-cmd --reload
   firewall-cmd --list-all
   
   # permission
   setsebool -P httpd_can_network_connect on
   ```
3. Restart services.

   ```
   systemctl restart container-ganglia
   systemctl restart httpd
   ```


## Install gmond in nodes to collect nodes status information

### Install

1. Install gmond in a node

   ```
   dnf install epel-release
   dnf install ganglia ganglia-gmond
   ```

2. Edit /etc/ganglia/gmond.conf

   ```
   # change the fellow part
   cluster {
     name = "cluster"               # be the same as that gmetad.conf inside your container
     owner = "unspecified"
     latlong = "unspecified"
     url = "unspecified"
   }
   ```

3. Open ports, enable permission.

   ```
   firewall-cmd --add-port=8649/udp --permanent
   firewall-cmd --add-port=8649/tcp --permanent
   firewall-cmd --reload
   firewall-cmd --list-all
   ```
4. Enable gmond service.

   ```
   systemctl enable --now gmond
   ```

##### You can monitor the nodes through http://ganglia.your.servername.com now.

