---
title: Cluster de almacenamiento con GlusterFS
author: Antoine Le Morvan
contributors: Steven Spencer
update: 11-Feb-2022
---

# Clúster de alta disponibilidad con GlusterFS

## Requisitos previos

* Dominio de un editor de línea de comandos (en este ejemplo utilizamos _vi_)
* Un alto nivel de comodidad en la ejecución de comandos desde el terminal, la visualización de registros y otras tareas de caracter genérico dentro de la administración de sistemas
* Todos los comandos se ejecutan como el usuario root o sudo

## Introduction

GlusterFS es un sistema de archivos distribuido.

Permite almacenar gran cantidad de datos distribuidos entre clústeres de servidores con una disponibilidad muy alta.

Se compone de una parte del servidor que se instalará en todos los nodos de los clústeres del servidor.

Los clientes pueden acceder a los datos mediante el comando `glusterfs` o `mount`.

GlusterFS puede trabajar en dos modos diferentes:

  * Modo replicado: Cada nodo del cluster tiene todos los datos.
  * modo distribuido: no hay redundancia de datos. Si un nodo de almacenamiento falla, se perderán los datos almacenados en ese nodo.

Los dos modos pueden utilizarse conjuntamente para proporcionar un sistema de archivos replicado así como un sistema de archivos distribuido, siempre y cuando se disopnga del número correcto de servidores.

Los datos se almacenan dentro de los bloques.

> Un bloque es la unidad básica de almacenamiento en GlusterFS, representada por un directorio de exportación en un servidor dentro del grupo de almacenamiento de confianza.

## Plataforma de prueba

Nuestra plataforma ficticia está compuesta por dos servidores y un cliente, todos son servidores Rocky Linux.

* Primer nodo: node1.cluster.local - 192.168.1.10
* Segundo nodo: node2.cluster.local - 192.168.1.11
* Client1: client1.clients.local - 192.168.1.12

!!! Note

    Asegúrese de tener el ancho de banda necesario entre los servidores del clúster.

Cada servidor en el clúster tiene un segundo disco para el almacenamiento de datos.

## Preparación de los discos

Crearemos un nuevo volumen lógico LVM que será montado en `/data/glusterfs/vol0` en los dos servidores que forman parte del cluster:

```
$ sudo pvcreate /dev/sdb
$ sudo vgcreate vg_data /dev/sdb
$ sudo lvcreate -l 100%F-n lv_data vg_data
$ sudo mkfs. fs /dev/vg_data/lv_data
$ sudo mkdir -p /data/glusterfs/volume1
```

!!! Note

    Si LVM no está disponible en sus servidores, simplemente instalelo mediante el siguiente comando:

    ```
    $ sudo dnf install lvm2
    ```

Ahora podemos añadir ese volumen lógico al archivo `/etc/fstab`:

```
/dev/mapper/vg_data-lv_data /data/glusterfs/volume1        xfs     defaults        1 2
```

Y montarlo:

```
$ sudo mount -a
```

Como los datos se almacenan en un subvolumen llamado brick, podemos crear un directorio en este nuevo espacio de datos dedicado a él:

```
$ sudo mkdir /data/glusterfs/volume1/brick0
```

## Instalacion

En el momento de escribir esta documentación, el repositorio original de almacenamiento SIG de CentOS ya no está disponible y el repositorio de RockyLinux aún no está disponible.

Sin embargo, usaremos (por el momento) la versión archivada.

En primer lugar, es necesario añadir el repositorio dedicado a gluster (en versión 9) en ambos servidores:

```
sudo dnf install centos-release-gluster9
```

!!! Note

    Posteriormente, cuando esté preparado en el lado de Rocky, podemos cambiar el nombre de este paquete.

Puesto que la lista de repos y la url ya no están disponibles, cambiremos el contenido del archivo `/etc/yum.repos.d/CentOS-Gluster-9.repo`:

```
[centos-gluster9]
name=CentOS-$releasever - Gluster 9
#mirrorlist=http://mirrorlist.centos.org?arch=$basearch&release=$releasever&repo=storage-gluster-9
baseurl=https://dl.rockylinux.org/vault/centos/8.5.2111/storage/x86_64/gluster-9/
gpgcheck=1
enabled=1
gpgkey=file:///pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Storage
```

Ahora estamos listos para instalar el servidor de glusterfs:

```
$ sudo dnf install glusterfs glusterfs-libs glusterfs-server
```

## Reglas del firewall

Se necesitan algunas reglas para que el servicio funcione:

```
$ sudo firewall-cmd --zone=public --add-service=glusterfs --permanent
$ sudo firewall-cmd --reload
```

o:

```
$ sudo firewall-cmd --zone=public --add-port=24007-24008/tcp --permanent
$ sudo firewall-cmd --zone=public --add-port=49152/tcp --permanent
$ sudo firewall-cmd --reload
```

## Resolución de nombres

Puede dejar que el DNS se encargue de la resolución de nombres de los servidores de su cluster, o puede optar por liberar a los servidores de esta tarea insertando registros para cada uno de ellos en sus archivos `/etc/hosts`. Esto mantendrá las cosas funcionando incluso en el caso de un fallo de DNS.

```
192.168.10.10 node1.cluster.local
192.168.10.11 node2.cluster.local
```

## Iniciando el servicio

Sin más retrasos, vamos a iniciar el servicio:

```
$ sudo systemctl enable glusterfsd.service glusterd.service
$ sudo systemctl start glusterfsd.service glusterd.service
```

Estamos listos para unir los dos nodos al mismo grupo.

Este comando se debe realizar una única vez en un solo nodo (en el nodo 1):

```
sudo gluster peer probe node2.cluster.local
peer probe: success
```

Verificación:

```
node1 $ sudo gluster peer status
Number of Peers: 1

Hostname: node2.cluster.local
Uuid: c4ff108d-0682-43b2-bc0c-311a0417fae2
State: Peer in Cluster (Connected)
Other names:
192.168.10.11

```

```
node2 $ sudo gluster peer status
Number of Peers: 1

Hostname: node1.cluster.local
Uuid: 6375e3c2-4f25-42de-bbb6-ab6a859bf55f
State: Peer in Cluster (Connected)
Other names:
192.168.10.10
```

Ahora podemos crear un volumen con 2 réplicas:

```
$ sudo gluster volume create volume1 replica 2 node1.cluster.local:/data/glusterfs/volume1/brick0/ node2.cluster.local:/data/glusterfs/volume1/brick0/
Replica 2 volúmenes son propensos a dividir cero. Use Arbiter or Replica 3 to avoid this. See: http://docs.gluster.org/en/latest/Administrator%20Guide/Split%20brain%20and%20ways%20to%20deal%20with%20it/.
Do you still want to continue?
 (y/n) y
volume create: volume1: success: please start the volume to access data
```

!!! Note

    Como se indica en la salida del comando, un clúster de 2 nodos no es la mejor idea del mundo para evitar un escenario Split Brain. Pero será suficiente para el propósito de nuestra plataforma de pruebas.

Ahora podemos iniciar el volumen para acceder a los datos:

```
$ sudo gluster volume start volume1

volume start: volume1: success
```

Compruebe el estado del volumen:

```
$ sudo gluster volume status
Status of volume: volume1
Gluster process                             TCP Port  RDMA Port  Online  Pid
------------------------------------------------------------------------------
Brick node1.cluster.local:/data/glusterfs/v
olume1/brick0                               49152     0          Y       1210
Brick node2.cluster.local:/data/glusterfs/v
olume1/brick0                               49152     0          Y       1135
Self-heal Daemon on localhost               N/A       N/A        Y       1227
Self-heal Daemon on node2.cluster.local     N/A       N/A        Y       1152

Task Status of Volume volume1
------------------------------------------------------------------------------
There are no active volume tasks
```

```
$ sudo gluster volume info

Volume Name: volume1
Type: Replicate
Volume ID: f51ca783-e815-4474-b256-3444af2c40c4
Status: Started
Snapshot Count: 0
Number of Bricks: 1 x 2 = 2
Transport-type: tcp
Bricks:
Brick1: node1.cluster.local:/data/glusterfs/volume1/brick0
Brick2: node2.cluster.local:/data/glusterfs/volume1/brick0
Options Reconfigured:
cluster.granular-entry-heal: on
storage.fips-mode-rchecksum: on
transport.address-family: inet
nfs.disable: on
performance.client-io-threads: off
```

El estado debe ser "Started".

Ahora podemos restringir un poco el acceso al volumen:

```
$ sudo gluster volume set volume1 auth.allow 192.168.10.*
```

Así de fácil

## Acceso desde los clientes

Hay varias formas de acceder a nuestros datos desde un cliente.

El método preferido:

```
$ sudo dnf install glusterfs-client
$ sudo mkdir /data
$ sudo mount.glusterfs node1.cluster.local:/volume1 /data
```

No hay repositorios adicionales para configurar. El cliente ya está presente en los repositorios base.

Cree un archivo y compruebe que esté presente en todos los nodos del cluster:

En el cliente:

```
sudo touch /data/test
```

En ambos servidores:

```
$ ll /data/glusterfs/volume1/brick0/
total 0
-rw-r--r--. 2 root root 0 Feb 3 19:21 test
```

¡Suena bien! Pero, ¿qué pasa si el nodo 1 falla? Es el nodo que se especificó al montar el acceso remoto.

Vamos a detener el nodo 1:

```
$ sudo shutdown -h now
```

Comprobar el estado en el nodo 2:

```
$ sudo gluster peer status
Number of Peers: 1

Hostname: node1.cluster.local
Uuid: 6375e3c2-4f25-42de-bbb6-ab6a859bf55f
State: Peer in Cluster (Disconnected)
Other names:
192.168.10.10
[antoine@node2 ~]$ sudo gluster volume status
Status of volume: volume1
Gluster process                             TCP Port  RDMA Port  Online  Pid
------------------------------------------------------------------------------
Brick node2.cluster.local:/data/glusterfs/v
olume1/brick0                               49152     0          Y       1135
Self-heal Daemon on localhost               N/A       N/A        Y       1152

Task Status of Volume volume1
------------------------------------------------------------------------------
There are no active volume tasks
```

El node1 está ausente.

Y en el cliente:

```
$ ll /data/test
-rw-r--r--. 1 root root 0 Feb 4 16:41 /data/test
```

El archivo ya está ahí.

Tras la conexión, el cliente de glusterfs recibe una lista con los nodos a los que se puede dirigir, lo que explica el cambio transparente que acabamos de ver.

## Conclusión

Aunque no hay repositorios actuales, el uso de los repositorios archivados de tenía para GlusterFS seguirá funcionando. Como se describe, GlusterFS es bastante fácil de instalar y mantener. Utilizar las herramientas de línea de comandos es un proceso bastante sencillo. GlusterFS le ayudará a crear y mantener clústeres de alta disponibilidad para almacenamiento de datos y redundancia. Puede obtener más información sobre GlusterFS y el uso de herramientas en las [páginas oficiales de documentación.](https://docs.gluster.org/en/latest/)
