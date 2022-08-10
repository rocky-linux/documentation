---
title: Demo de rsync 01
author: tianci li
contributors: Steven Spencer
update: 2021-11-04
---

# Prefacio

`rsync` necesita realizar autenticación de usuario antes de sincronizar datos. **Hay dos protocolos para la autenticación: el protocolo SSH y el protocolo rsync (el puerto predeterminado del protocolo rsync es 873)**

* Método de verificación del protocolo SSH: Utiliza el protocolo SSH como base para la autenticación de la identidad del usuario (es decir, utiliza el usuario del sistema y la contraseña de GNU/Linux para la verificación), y posteriormente realiza la sincronización de datos.
* Método de verificación de inicio de sesión de protocolo rsync: Utiliza el protocolo rsync para la autenticación de la identidad del usuario(usuarios del sistema que no son de GNU/Linux, similar a los usuarios virtuales de vsftpd), y posteriormente realiza la sincronización de datos.

Antes de la demostración específica de sincronización mediante rsync, necesita utilizar el comando `rsync`. En Rocky Linux 8, el paquete rpm se instala por defecto y la versión es 3.1.3-12, de la siguiente manera:

```bash
[root@Rocky ~]# rpm -qa|grep rsync
rsync-3.1.3-12.el8.x86_64
```

```txt
Basic format: rsync [options] original location target location
Commonly used options:
-a: archive mode, recursive and preserves the attributes of the file object, which is equivalent to -rlptgoD (without -H, -A, -X)
-v: Display detailed information about the synchronization process
-z: compress when transferring files
-H: Keep hard link files
-A: retain ACL permissions
-X: retain chattr permissions
-r: Recursive mode, including all files in the directory and subdirectories
-l: still reserved for symbolic link files
-p: Permission to retain file attributes
-t: time to retain file attributes
-g: retain the group belonging to the file attribute (only for super users)
-o: retain the owner of the file attributes (only for super users)
-D: Keep device files and other special files
```

Uso personal del autor: `rsync -avz original location target location`

## Descripción del entorno

| Elemento                | Descripción      |
| ----------------------- | ---------------- |
| Rocky Linux 8(Servidor) | 192.168.100.4/24 |
| Fedora 34(Cliente)      | 192.168.100.5/24 |

Puede utilizar Fedora 34 para subir y descargar ficheros

```mermaid
graph LR;
RockyLinux8-->|pull/download|Fedora34;
Fedora34-->|push/upload|RockyLinux8;
```

También puede utilizar Rocky Linux 8 para subir y descargar ficheros

```mermaid
graph LR;
RockyLinux8-->|push/upload|Fedora34;
Fedora34-->|pull/download|RockyLinux8;
```

## Demostración basada en protocolo SSH

!!! tip "Consejo"

    En este caso, tanto Rocky Linux 8 como Fedora 34 utilizan el usuario root para iniciar la sesión. Fedora 34 es el cliente y Rocky Linux 8 es el servidor.

### Descarga de ficheros

Puesto que rsync se basa en el protocolo SSH, primero debemos crear un usuario en el servidor:

```bash
[root@Rocky ~]# useradd testrsync
[root@Rocky ~]# passwd testrsync
```

En el lado del cliente, lo descargamos/descargamos, y el archivo en el servidor es /rsync/aabbcc

```bash
[root@fedora ~]# rsync -avz testrsync@192.168.100.4:/rsync/aabbcc /root
testrsync@192.168.100.4 ' s password:
receiving incremental file list
aabbcc
sent 43 bytes received 85 bytes 51.20 bytes/sec
total size is 0 speedup is 0.00
[root@fedora ~]# cd
[root@fedora ~]# ls
aabbcc
```
La transferencia se ha realizado con éxito.

!!! tip "Consejo"

    Si el puerto SSH del servidor no es el 22 por defecto, puede especificar el puerto de forma similar---`rsync -avz -e 'ssh -p [port]'`.

### Subida de ficheros

```bash
[root@fedora ~]# touch fedora
[root@fedora ~]# rsync -avz /root/* testrsync@192.168.100.4:/rsync/
testrsync@192.168.100.4 ' s password:
sending incremental file list
anaconda-ks.cfg
fedora
rsync: mkstemp " /rsync/.anaconda-ks.cfg.KWf7JF " failed: Permission denied (13)
rsync: mkstemp " /rsync/.fedora.fL3zPC " failed: Permission denied (13)
sent 760 bytes received 211 bytes 277.43 bytes/sec
total size is 883 speedup is 0.91
rsync error: some files/attrs were not transferred (see previous errors) (code 23) at main.c(1330) [sender = 3.2.3]
```

**Permiso denegado, ¿cómo se soluciona?**

Primero compruebe los permisos del directorio /rsync/ . Obviamente, no hay permiso "w". Podemos utilizar la herramienta `setfacl` para dar permisos:

```bash
[root@Rocky ~ ] # ls -ld /rsync/
drwxr-xr-x 2 root root 4096 November 2 15:05 /rsync/
```

```bash
[root@Rocky ~ ] # setfacl -mu:testrsync:rwx /rsync/
[root@Rocky ~ ] # getfacl /rsync/
getfacl: Removing leading ' / ' from absolute path names
# file: rsync/
# owner: root
# group: root
user::rwx
user:testrsync:rwx
group::rx
mask::rwx
other::rx
```

Inténtelo de nuevo, ¡éxito!

```bash
[root@fedora ~ ] # rsync -avz /root/* testrsync@192.168.100.4:/rsync/
testrsync@192.168.100.4 ' s password:
sending incremental file list
anaconda-ks.cfg
fedora
sent 760 bytes received 54 bytes 180.89 bytes/sec
total size is 883 speedup is 1.08
```
