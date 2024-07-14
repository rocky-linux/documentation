---
title: Archivo de configuración de rsync
author: tianci li
update: 2021-11-04
---

# /etc/rsyncd.conf

En el artículo anterior [Demo de rsync 02](03_rsync_demo02.md) se introdujeron algunos parámetros básicos. Este artículo sirve cómocomplemento para la utilización de otros parámetros.

| Parámetros                          | Descripción                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| fake super = yes                    | Yes significa que no es necesario que el demonio se ejecute como root para almacenar los atributos completos del archivo.                                                                                                                                                                                                                                                                                                       |
| uid =                               |                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| gid =                               | Dos parámetros para especificar el usuario y el grupo utilizados para transferir los archivos cuando el demonio de rsync como se ejecuta root. El valor por defecto es nobody.                                                                                                                                                                                                                                                  |
| use chroot = yes                    | Si es necesario bloquear el directorio raíz antes de la transmisión. Para aumentar la seguridad, rsync estable este parametro de forma predeterminada a yes.                                                                                                                                                                                                                                                                    |
| max connections = 4                 | Número máximo de conexiones permitidas, el valor por defecto es 0, lo que significa que no hay ninguna restricción.                                                                                                                                                                                                                                                                                                             |
| lock file = /var/run/rsyncd.lock    | El archivo de bloqueo especificado, que se asocia con el parámetro "max connections".                                                                                                                                                                                                                                                                                                                                           |
| exclude = lost+found/               | Excluye los directorios que no necesitan ser transferidos.                                                                                                                                                                                                                                                                                                                                                                      |
| transfer logging = yes              | Si se activa el formato de registro tipo ftp para registrar las subidas y las descargas realizadas por rsync.                                                                                                                                                                                                                                                                                                                   |
| timeout = 900                       | Especifica el tiempo de espera. Si no se transmiten datos en el tiempo especificado, rsync terminará su ejecución. La unidad utilizada aqui son los segundos y el valor por defecto es 0 lo que significa que nunca se agota el tiempo de espera.                                                                                                                                                                               |
| ignore nonreadable = yes            | Si se ignoran o no los archivos sobre los que el usuario no tiene permisos.                                                                                                                                                                                                                                                                                                                                                     |
| motd file = /etc/rsyncd/rsyncd.motd | Se utiliza para especificar la ruta del archivo de mensajes. Por defecto, no hay ningún archivo motd. Un archivo motd contiene el mensaje de bienvenida que se muestra cuando el usuario realiza un inicio de sesión.                                                                                                                                                                                                           |
| hosts allow = 10.1.1.1/24           | Se utiliza para especificar a qué IP o segmento de red pueden acceder los clientes. Puede rellenar la ip, el segmento de red, el nombre del hostv o el dominio, y separar múltiples valores mediante espacios. Por defecto, permite el acceso a todo el mundo.                                                                                                                                                                  |
| hosts deny = 10.1.1.20              | A qué IP o segmento de red no pueden acceder los clientes especificados por el usuario. Si los hosts con acceso permitido y los hosts con el acceso denegado tienen el mismo nivel de coincidencia, eventualmente el cliente no tendrá acceso. Si la dirección del cliente no está ni en la lista de hosts permitidos ni en la de hosts denegados, el cliente tiene permitido el acceso. Por defecto, no existe este parámetro. |
| auth users = li                     | Permite habilitar los usuarios virtuales, se pueden definir diferentes usuarios separados mediante comas.                                                                                                                                                                                                                                                                                                                       |
| syslog facility = daemon            | Define el nivel de detalle en los archivos de registro. Se pueden los siguientes valores: auth, authpriv, cron, daemon, ftp, kern, lpr, mail, news, security, syslog, user, uucp, local0, local1, local2 local3, local4, local5, local6 y local7. El valor predeterminado es daemon.                                                                                                                                            |

## Configuración recomendada

```ini title="/etc/rsyncd.conf"
uid = nobody
gid = nobody
address = 192.168.100.4
use chroot = yes
max connections = 10
syslog facility = daemon
pid file = /var/run/rsyncd.pid
log file = /var/log/rsyncd.log
lock file = /var/run/rsyncd.lock
[file]
  comment = rsync
  path = /rsync/
  read only = no
  dont compress = *.gz *.bz2 *.zip
  auth users = li
  secrets file = /etc/rsyncd users.db
```