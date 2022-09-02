---
title: Protocolo de inicio de sesión con autenticación sin contraseña de rsync
author: tianci li
contributors: Steven Spencer, Pedro Garcia
update: 2021-11-04
---

# Prefacio

Gracias al artículo [Breve descripción de rsync](01_rsync_overview.md) conocemos que rsync es una herramienta incremental de sincronización. Cada vez que se ejecuta el comando `rsync`, los datos se pueden sincronizar una vez pero no se pueden sincronizar en tiempo real. ¿Cómo solucionarlo?

Mediante la herramienta inotify-tools, puede realizar una sincronización en tiempo real. Debido a que se trata de una sincronización de datos en tiempo real, el prerrequisito es iniciar sesión sin autenticación de contraseña.

**Independientemente de si es protocolo utilizado es rsync o SSH, con ambos se puede lograr la autenticación sin contraseña.**

## Protocolo de inicio de sesión con autenticación sin contraseña de SSH

Primero, generar un par de claves públicas y privadas en el cliente, siga presionando Enter después de teclear el comando. El par de claves se guarda en el directorio <font color=red>/root/.ssh/</font>

```bash
[root@fedora ~]# ssh-keygen -t rsa -b 2048
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /root/.ssh/id_rsa
Your public key has been saved in /root/.ssh/id_rsa.pub
The key fingerprint is:
SHA256: TDA3tWeRhQIqzTORLaqy18nKnQOFNDhoAsNqRLo1TMg root@fedora
The key's randomart image is:
+---[RSA 2048]----+
|O+. +o+o. .+. |
|BEo oo*....o. |
|*o+o..*.. ..o |
|.+..o. = o |
|o o S |
|. o |
| o +. |
|....=. |
| .o.o. |
+----[SHA256]-----+
```

Luego, utiliza el comando `scp` para subir el archivo de clave pública al servidor. Por ejemplo, he subido esta clave pública al usuario **testrsync**

```bash
[root@fedora ~]# scp -P 22 /root/.ssh/id_rsa.pub root@192.168.100.4:/home/testrsync/
```

```bash
[root@Rocky ~]# cat /home/testrsync/id_rsa.pub >> /home/testrsync/.ssh/authorized_keys
```

Intente iniciar sesión sin autenticación, ¡éxito!

```bash
[root@fedora ~]# ssh -p 22 testrsync@192.168.100.4
Last login: Tue Nov 2 21:42:44 2021 from 192.168.100.5
[testrsync@Rocky ~]$
```

!!! tip "Consejo"

    Se deben editar el archivo de configuración **/etc/ssh/sshd_config** de la máquina y habilitar la opción <font color=red>PubkeyAuthentication sí</font>

## Protocolo de inicio de sesión con autenticación sin contraseña de rsync

En el lado del cliente, el servicio rsync configura una variable de entorno en el sistema-**RSYNC_PASSWORD**, que está vacía por defecto, como se muestra a continuación:

```bash
[root@fedora ~]# echo "$RSYNC_PASSWORD"

[root@fedora ~]#
```

Si desea conseguir el inicio de sesión sin contraseña, sólo necesita asignar un valor a esta variable. El valor asignado es la contraseña establecida para el usuario virtual <font color=red>li</font>. Al mismo tiempo, declare esta variable como una variable global.

```bash
[root@Rocky ~]# cat /etc/rsyncd_users.db
li:13579
```

```bash
[root@fedora ~]# exportar RSYNC_PASSWORD=13579
```

Inténtelo de nuevo, ¡éxito! No aparecen nuevos archivos, por lo que rsync no muestra la lista de archivos transferidos.

```bash
[root@fedora ~]# rsync -avz li@192.168.100.4::share /root/
receiving incremental file list
./

sent 30 bytes received 193 bytes 148.67 bytes/sec
total size is 883 speedup is 3.96
```

!!! tip "Consejo"

    Puede escribir esta variable en **/etc/profile** para que configurarla de manera permanente en el sistema. El contenido es: `export RSYNC_PASSWORD=13579`
