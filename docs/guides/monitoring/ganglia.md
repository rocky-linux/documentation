---
title: Monitoring Rocky Linux nodes or clusters by Ganglia
author: berlin2123
contributors: 
updated: 2022-1-10
---

# Monitoring Rocky Linux nodes or clusters by Ganglia

This guide walks through the detailed steps to install Ganglia packages in Rocky Linux distribution.

## Install Ganglia-web Interface

!!! General Overview
    Ganglia is a very good software package for monitoring the historical state of clusters or nodes. However, the current ganglia web interface (3.7.5) is based on php-5.6. If you are using a higher version php, such as that in the default environment of **Rocky Linux 8**, ganglia web interface will not be displayed normally. Therefore, configuring and using php-5.6 was the necessary option to run the ganglia web interface in Rocky linux. Docker can easily solve this problem. That is, **running Ganglia-web inside a centos7 container** in the Rocky linux 8 system, which container can easily run the php-5.6. It will **ensure the normal display of the ganglia-web interface**.

### Get the container image

#### Just simply Pull (recommended)
```
podman pull berlin2123/ganglia-web-centos7
```

#### Or build the container image by Yourself

##### Downlaod this `Dockerfile` and `run-services.sh` into your system

```
wget https://raw.githubusercontent.com/berlin2123/ganglia-web-docker/main/ganglia-web-centos7/Dockerfile
wget https://raw.githubusercontent.com/berlin2123/ganglia-web-docker/main/ganglia-web-centos7/run-services.sh
```

##### Manually build this container:

```
podman build -t <name_of_the_container_image>  <Path_to_the_Dockerfile>
```

If the `Dockerfile` and `run-services.sh` are saved to `/root/dockertest/cent7ganglia/`, and you want to name this image as `mybuild/cent7ganglia`, you can just run:  

```
podman build -t mybuild/cent7ganglia /root/dockertest/cent7ganglia/
```


### Run the container

1. You can run the container with the setting of timezone `-e TZ=timezone_code`
   ```
   podman run -t -d --name ganglia -e TZ=Europe/Berlin -p 1380:80 --restart always berlin2123/ganglia-web-centos7
   ```
   You may need to use your own image or timezone name. 

   You can check the runing state by 
   ```
   podman logs --since 10m ganglia
   ```
   
2. Create a service (systemd) that automatically starts the ganglia container

   ```
   podman generate systemd --name ganglia > /etc/systemd/system/container-ganglia.service
   ```

   Enable and start this service now

   ```
   systemctl enable --now container-ganglia.service 
   ```

3. Modify the internal configuration of the container  (If you want to use another cluster name)
   ```
   # enter the container
   podman exec -u root -it ganglia /bin/bash   
   # vi /etc/ganglia/gmetad.conf 
   # change the line:
   data_source "cluster" 10.88.0.1:8649 
   # to
   data_source "your_cluster_name" 10.88.0.1:8649
   
   # After the modification is completed, exit from the container
   exit
   ```
   Restart is required for the changes to take effect,
   ```
   systemctl restart container-ganglia.service 
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
   Or just http://<YOUR_IP>:1380/ganglia/, (do not through reverse proxy), such as http://192.168.1.100:1380/ganglia/

