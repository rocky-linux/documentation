---
title: Demo de rsync 02
author: tianci li
contributors: Steven Spencer
update: 2021-11-04
---

# Demostración basada en el protocolo rsync
En vsftpd, hay usuarios virtuales (usuarios personalizados por el administrador) porque no es seguro utilizar usuarios anónimos y usuarios locales. Sabemos que un servidor basado en el protocolo SSH debe garantizar la existencia de un sistema de usuarios. Cuando hay muchos requisitos de sincronización, puede ser necesario la creación de muchos usuarios. Obviamente, esto no cumple con los estándares de operación y mantenimiento de GNU/Linux (mientras más usuarios, más inseguro), en rsync, por razones de seguridad, existe un método de inicio de sesión de autenticación del protocolo rsync.

**¿Cómo hacerlo?**

Simplemente escriba los parámetros y valores correspondientes en el archivo de configuración. En Rocky Linux 8, necesita crear manualmente el archivo <font color=red>/etc/rsyncd.conf</font>.

```bash
[root@Rocky ~]# touch /etc/rsyncd.conf
[root@Rocky ~]# vim /etc/rsyncd.conf
```

A continuación se muestran algunos parámetros y valores de configuraciónv para este archivo, [ aquí ](04_rsync_configure.md) encontrará más información sobre dichos parámetros:

| Elemento                                  | Descripción                                                                                                                                                                                      |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| address = 192.168.100.4                   | La dirección IP en la que rsync escucha por defecto.                                                                                                                                             |
| port = 873                                | Puerto de escucha por defecto de rsync.                                                                                                                                                          |
| pid file = /var/run/rsyncd.pid            | Ubicación del archivo con el pid del proceso.                                                                                                                                                    |
| log file = /var/log/rsyncd.log            | Ubicación del archivo de registro.                                                                                                                                                               |
| [share]                                   | Nombre de recurso a compartir.                                                                                                                                                                   |
| comment = rsync                           | Comentarios o información descriptiva.                                                                                                                                                           |
| path = /rsync/                            | La ubicación de la ruta del sistema donde se encuentra.                                                                                                                                          |
| read only = yes                           | Yes significa sólo lectura y No significa lectura y escritura.                                                                                                                                   |
| dont compress = \*.gz \*.gz2 \*.zip | Tipos de archivo que no se comprimen.                                                                                                                                                            |
| auth users = li                           | Habilita los usuarios virtuales y define cómo se llama un usuario virtual. Necesita crearlo usted mismo.                                                                                         |
| archivo secretos = mañana/rsyncd_users.db | Utilizado para especificar la ubicación del archivo de contraseñas del usuario virtual, debe terminar en .db. El formato del contenido del archivo debe ser "Username: Password", uno por línea. |

!!! tip "Consejo"

    Los permisos del archivo de contraseña deben ser <font color=red>600</font>

Escriba algo de contenido en el archivo a <font color=red>/etc/rsyncd.conf</font>, y escriba el nombre de usuario y la contraseña en el archivo /etc/rsyncd_users.db, los permisos necesarios para ese archivo son 600.

```bash
[root@Rocky ~]# cat /etc/rsyncd.conf
address = 192.168.100.4
port = 873
pid file = /var/run/rsyncd.pid
log file = /var/log/rsyncd.log
[share]
comment = rsync
path = /rsync/
read only = yes
dont compress = *.gz *.bz2 *.zip
auth users = li
secrets file = /etc/rsyncd_users.db
[root@Rocky ~]# ll /etc/rsyncd_users.db
-rw------- 1 root root 9 November 2 16:16 /etc/rsyncd_users.db
[root@Rocky ~]# cat /etc/rsyncd_users.db
li:13579
```

Puede necesitar ejecutar el comando `dnf -y install rsync-daemon` antes de poder iniciar el servicio: `systemctl start rsyncd.service`

```bash
[root@Rocky ~]# systemctl start rsyncd.service
[root@Rocky ~]# netstat -tulnp
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      691/sshd            
tcp        0      0 192.168.100.4:873       0.0.0.0:*               LISTEN      4607/rsync          
tcp6       0      0 :::22                   :::*                    LISTEN      691/sshd            
udp        0      0 127.0.0.1:323           0.0.0.0:*                           671/chronyd         
udp6       0      0 ::1:323                 :::*                                671/chronyd  
```

## Descarga de ficheros

Cree un archivo en el servidor para la verificación: `[root@Rocky]# touch /rsync/rsynctest.txt`

El cliente hace lo siguiente:

```bash
[root@fedora ~]# rsync -avz li@192.168.100.4::share /root
Contraseña:
recibiendo lista incremental de archivos
./
rsynctest. xt
envió 52 bytes recibidos 195 bytes 7.16 bytes/sec
tamaño total es 883 speedup es 3. 7
[root@fedora ~]# ls
aabbcc anaconda-ks.cfg fedora rsynctest.txt
```

¡Éxito! Además de la escritura anterior basada en el protocolo rsync, también se puede escribir así: `rsync://li@10.1.2.84/share`

## Subida de ficheros

```bash
[root@fedora ~]# touch /root/fedora.txt
[root@fedora ~]# rsync -avz /root/* li@192.168.100.4::share
Password:
sending incremental file list
rsync: [sender] read error: Connection reset by peer (104)
rsync error: error in socket IO (code 10) at io.c(784) [sender = 3.2.3]
```

Se le indica que el error de lectura esté relacionado con el parametro "read only = yes" del servidor . Cambielo a "no" y reinicie el servicio: `[root@Rocky ~]# systemctl restart rsyncd.service`

Inténtelo de nuevo, ya que rsyn está mostrandole el mensaje de permiso denegado:

```bash
[root@fedora ~]# rsync -avz /root/* li@192.168.100.4::share
Password:
sending incremental file list
fedora.txt
rsync: mkstemp " /.fedora.txt.hxzBIQ " (in share) failed: Permission denied (13)
sent 206 bytes received 118 bytes 92.57 bytes/sec
total size is 883 speedup is 2.73
rsync error: some files/attrs were not transferred (see previous errors) (code 23) at main.c(1330) [sender = 3.2.3]
```

Nuestro usuario virtual es <font color=red>li</font>, que está asignado al usuario del sistema <font color=red>nobody</font> por defecto. Por supuesto, puede cambiarlo a otros usuarios del sistema. En otras palabras, nadie tiene permiso de escritura en el directorio /rsync/ . Por supuesto, podemos utilizar `[root@Rocky ~]# setfacl -mu:nobody:rwx /rsync/` , inténtelo de nuevo.

```bash
[root@fedora ~]# rsync -avz /root/* li@192.168.100.4::share
Password:
sending incremental file list
fedora.txt
sent 206 bytes received 35 bytes 96.40 bytes/sec
total size is 883 speedup is 3.66
```
