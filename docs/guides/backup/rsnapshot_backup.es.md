# Copias de Seguridad rsnapshot

## Requisitos

  * Saber cómo instalar repositorios e instantáneas adicionales desde la línea de comandos
  * Saber cómo montar sistemas de archivos externos a su máquina (disco duro externo, sistema de archivos remoto, etc.)
  * Saber usar un editor (aquí se usa vi, pero puedes usar tu editor favorito)
  * Saber un poco de BASH scripting 
  * Saber cómo modificar crontab para el usuario root
  * Conocimiento de las claves públicas y privadas de SSH (solo si planea ejecutar copias de seguridad remotas desde otro servidor)

# Introducción

_rsnapshot_ es una utilidad de copia de seguridad muy potente que se puede instalar en cualquier máquina basada en Linux. Puede hacer una copia de seguridad de una máquina localmente, o puede hacer una copia de seguridad de múltiples máquinas, digamos servidores por ejemplo, desde una sola máquina. 

rsnapshot usa _rsync_ y está escrito completamente en perl sin dependencias de librerías, así que no hay requerimientos extraños para instalarlo. En el caso de Rocky Linux, deberías poder instalar rsnapshot simplemente instalando el repositorio de software EPEL. 

Esta documentación cubre la instalación de rsnapshot sólo en Rocky Linux.

# Instalando rsnapshot

Todos los comandos mostrados aquí son de la línea de comandos en su servidor o estación de trabajo a menos que se indique lo contrario.

## Instalar el repositorio EPEL

Necesitamos el repositorio de software EPEL de Fedora para instalar rsnapshot. Para instalar el repositorio, simplemente usa este comando, si aún no lo has hecho:

`sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm`

El repositorio ahora debería estar activo.

## Instalar el paquete rsnapshot

A continuación, instalar rsnapshot propiamente:

`sudo dnf install rsnapshot`

En el caso en que faltaran dependencias, éstas se mostrarán y solo tendríamos que responder en el prompt para continuar. Por ejemplo:

```
dnf install rsnapshot
Last metadata expiration check: 0:00:16 ago on Mon Feb 22 00:12:45 2021.
Dependencies resolved.
========================================================================================================================================
 Package                           Architecture                 Version                              Repository                    Size
========================================================================================================================================
Installing:
 rsnapshot                         noarch                       1.4.3-1.el8                          epel                         121 k
Installing dependencies:
 perl-Lchown                       x86_64                       1.01-14.el8                          epel                          18 k
 rsync                             x86_64                       3.1.3-9.el8                          baseos                       404 k

Transaction Summary
========================================================================================================================================
Install  3 Packages

Total download size: 543 k
Installed size: 1.2 M
Is this ok [y/N]: y
```
## Montar la unidad o el sistema de archivos para copias de seguridad

En este paso, mostraremos cómo montar un disco duro, como así también una unidad extraible, que se utilizará para hacer una copia de seguridad del sistema.
Este paso en particular es necesario si se está realizando una copia de seguridad de un equipo o servidor, como se puede observar en nuestro primer ejemplo a continuación. 

1. Conectar la unidad USB.
2. Escribir `dmesg | grep sd` debería mostrar la unidad que se desea utilizar. En este caso, se llamará _sda1_.
Ejemplo: `EXT4-fs (sda1): mounting ext2 file system using the ext4 subsystem`.
3. Desafortunadamente (o afortunadamente dependiendo de su opinion) la mayoría de los sistemas operativos de escritorio modernos de Linux montarán automáticamente la unidad cuando puedan. Esto significa que, dependiendo de varios factores, rsnapshot puede perder la ruta hacía la unidad. Lo que queremos es que la unidad se "monte" o que los archivos estén disponibles siempre allí. Para hacerlo, tomamos la información de la unidad revelada en el comando dmesg anterior y escribimos `mount | grep sda1`, lo que debería mostrar algo como esto:
`/dev/sda1 on /media/username/8ea89e5e-9291-45c1-961d-99c346a2628a`
4. Escribir `sudo umount /dev/sda1` para desmontar su unidad extraible.
5. A continuación, crear un nuevo punto de montaje para la copia de seguridad:`sudo mkdir /mnt/backup`
6. Ahora montar la unidad en la ubicación de su carpeta de copia de seguridad: `sudo mount /dev/sda1 /mnt/backup
7. Ahora escribir de nuevo `mount | grep sda1`, lo que debería mostrar algo así: `/dev/sda1 on /mnt/backup type ext2 (rw,relatime)`
8. A continuación, crear un directorio que debe existir para que la copia de seguridad persista en la unidad montada. En este ejemplo utilizaremos una carpeta llamada "storage": `sudo mkdir /mnt/backup/storage`

Tener en cuenta que para una sola máquina, tendrá que repetir los pasos de desmontaje y montaje cada vez que la unidad se conecte de nuevo, o cada vez que el sistema se reinicie, o bien puede automatizar estos comandos con un script.

Recomendamos la automatización. La automatización es el camino del administrador de sistemas.

# Configurar rsnapshot

Este es el paso más importante. Es fácil cometer errores al hacer cambios en archivo de configuración. La configuración de rsnapshot requiere tabulaciones para la separación entre elementos, y una advertencia a tal efecto se encuentra en la parte superior del archivo de configuración.

Un carácter de espacio causará que toda la configuración y su copia de seguridad fallen. Por ejemplo, cerca de la parte superior del archivo de configuración hay una sección para el `# SNAPSHOT ROOT DIRECTORY #`. Si se agregará esto desde cero se debería escribir `snapshot_root`, luego TAB y seguido `/whatever_the_path_to_the_snapshot_root_will_be/`

Lo mejor es que la configuración que viene por defecto con rsnapshot solo necesita pequeños cambios para funcionar como copia de seguridad en un equipo local. Sin embargo siempre es una buena idea realizar una copia de seguridad del archivo de configuración antes de comenzar a editarlo:

`cp /etc/rsnapshot.conf /etc/rsnapshot.conf.bak`

## Copia de seguridad sobre un único equipo o servidor

En este caso, rsnapshot será ejecutado localmente para respaldar un equipo en particular. En este ejemplo, desglosaremos el archivo de configuración, y te mostraremos exactamente lo que necesitas cambiar.

Necesitarás usar vi (o tu editor favorito) para abrir el archivo _/etc/rsnapshot.conf_.

Lo primero que se debe cambiar es la configuración de _snapshot_root_ que por defecto tiene el valor:

`snapshot_root   /.snapshots/`

Necesitamos cambiar estp en nuestro punto de montaje que creamos anteriormente más el agregado "storage.

`snapshot_root   /mnt/backup/storage/`

También queremos decirle a la copia de seguridad que NO se ejecute si la unidad no está montada. Para ello, se debe eliminar el signo "#" (también llamado símbolo numeral, almohadilla, comentario, hash, etc.) seguido de no_create_root para que se vea así:

`no_create_root 1`

A continuación, bajar a la sección titulada `# EXTERNAL PROGRAM DEPENDENCIES #` y eliminar el comentario (es decir, el signo "#") de esta linea:

`#cmd_cp         /usr/bin/cp`

Para que ahora se lea:

`cmd_cp         /usr/bin/cp`

Aunque no necesitemos cmd_ssh para esta configuración en particular, lo necesitaremos para nuestra otra opción a continuación y no estaría de más tenerlo activado. Por lo tanto una vez encontrada la linea que dice:

`#cmd_ssh        /usr/bin/ssh` 

Se eliminará el signo "#" tal que quede algo así:

`cmd_ssh        /usr/bin/ssh`

A continuación tendremos que saltar a la sección titulada `#     BACKUP LEVELS / INTERVALS         #`

Esto ha sido cambiado de versiones anteriores de rsnapshot de `hourly, daily, monthly, yearly` a `alpha, beta, gamma, delta`. Lo cual es un poco confuso. Lo que necesitamos hacer es añadir un comentario a cualquier intervalo que no vayas a utilizar. En la configuración, delta ya estará comentado.

Para este ejemplo, no ejecutaremos ningún otro incremento que no sea una copia de seguridad nocturna, así que solo hay que añadir un comentario al alfa y gamma para que la configuración se vea así cuando haya terminado:

```
#retain  alpha   6
retain  beta    7
#retain  gamma   4
#retain delta   3
```

Ahora saltaremos a la linea del archivo de registro, que por defecto debería ser:

`#logfile        /var/log/rsnapshot`

Y lo habilitamos eliminando el comentario:

`logfile        /var/log/rsnapshot`

Finalmente, saltaremos a la sección `### BACKUP POINTS / SCRIPTS ###` y agregaremos los directorios que se deseen en la sección `# LOCALHOST`, ¡recuerde usar TAB en lugar de SPACE entre los elementos!

Por ahora debemos escribir sus cambios (`SHIFT :wq!` en vi) y saldremos del archivo de configuración.

### Comprobación de la configuración

Queremos asegurarnos de que no hemos agregado espacios o cualquier otro error evidente en nuestro archivo de configuración mientras lo editábamos. Para esto, ejecutamos rsnapshot contra nuestra configuración con la opción configtest:

`rsnapshot configtest` mostrará `Syntax OK` si no hay errores en la configuración.

Deberiamos acostumbrarnos a ejecutar el configtest contra una configuración en particular. La razón será más que evidente cuando entremos en la sección **Multiple Machine or Multiple Server Backups**.

Para ejecutar configtest contra un archivo de configuración en particular, ejecútelo con la opción -c para especificar la configuración:

`rsnapshot -c /etc/rsnapshot.conf configtest`

### Ejecutar la copia de seguridad por primera vez

Todo se ha comprobado, así que ahora podemos seguir adelante y ejecutar la copia de seguridad por primera vez. Puede ejecutar esto en modo de prueba primero si lo desea, para que pueda ver lo que el script de copia de seguridad va a realizar.

De nuevo, para realizar esto no tiene que especificar necesariamente la configuración en este caso, pero deberías acostumbrarte a hacerlo:

`rsnapshot -c /etc/rsnapshot.conf -t beta`

Esto debería devolver algo como lo siguiente, demostrando lo que ocurrirá cuando se ejecute la copia de seguridad:

```
echo 1441 > /var/run/rsnapshot.pid 
mkdir -m 0755 -p /mnt/backup/storage/beta.0/ 
/usr/bin/rsync -a --delete --numeric-ids --relative --delete-excluded \
    /home/ /mnt/backup/storage/beta.0/localhost/ 
mkdir -m 0755 -p /mnt/backup/storage/beta.0/ 
/usr/bin/rsync -a --delete --numeric-ids --relative --delete-excluded /etc/ \
    /mnt/backup/storage/beta.0/localhost/ 
mkdir -m 0755 -p /mnt/backup/storage/beta.0/ 
/usr/bin/rsync -a --delete --numeric-ids --relative --delete-excluded \
    /usr/local/ /mnt/backup/storage/beta.0/localhost/ 
touch /mnt/backup/storage/beta.0/
```

Una vez que estemos satisfechos con la prueba, seguiremos adelante y ejecutaremos manualmente la primera vez sin la prueba:

`rsnapshot -c /etc/rsnapshot.conf beta`

Cuando la copia de seguridad termine, podremos echar un vistazo a la estructura de directorios creada en /mnt/backup. Habrá un directorio `storage/beta.0/localhost` seguido por los directorios especificados para respaldar.

### Explicación adicional

Cada vez que se ejecute la copia de seguridad, se creará un nuevo incremento beta, de 0 a 6, o de 7 días de copias de seguridad. La copia de seguridad más reciente siempre será beta.0, mientras que la copia de seguridad de ayer siempre será beta.1.

El tamaño de cada uno de estos respaldos parecerá ocupar la misma cantidad (o más) de espacio en disco, pero esto se debe al uso de enlaces duros por parte de rsnapshot. Para restaurar los archivos del respaldo de ayer, simplemente se debe copiar de vuelta desde la estructura de directorios de la beta.1.

Cada copia de seguridad es solo una copia de seguridad incremental de la ejecución anterior, PERO, debido al uso de enlaces duros, cada directorio dela copia de seguridad, contiene el archivo, o enlace duro al archivo en cualquier directorio en el que realmente fue respaldado. 

Así que para restaurar los archivos, usted no tiene que elegir qué directorios o incremento para restaurarlos, solo qué marca de tiempo debe tener la copia de seguridad. Es un gran sistema y utiliza mucho menos espacio en disco que muchas otras soluciones de copia de seguridad.

### Configurar la copia de seguridad para que se ejecute automáticamente

Una vez que ha sido probado y sabemos que las cosas funcionarán sin problemas el siguiente paso es configurar el crontab para el usuario root, para que todo esto se haga automáticamente cada día:

`sudo crontab -e`

Si no has ejecutado esto antes, elige vim.basic como tu editor o tu propia preferencia de editor cuando aparezca la linea `Select an editor`.

Vamos a configurar nuestra copia de seguridad para que se ejecute automáticamente a las 11 de la noche, así que agregaremos esto al crontab:

```
## Running the backup at 11 PM
00 23 *  *  *  /usr/bin/rsnapshot -c /etc/rsnapshot.conf beta`
```

## Copias de seguridad sobre múltiples equipos o servidores

Hacer copias de seguridad de varios equipos desde una maquina con una matriz RAID o con gran capacidad de almacenamiento, ya sea en las instalaciones o desde Internet, funciona muy bien.

Si ejecuta estos respaldos desde Internet, debe asegurarse de que ambas ubicaciones tengan el ancho de banda adecuado para que se realicen los respaldos. Pueden usar rsnapshot para sincronizar un servidor en el sitio con un arreglo o servidor de respaldo fuera del sitio para mejorar la redundancia de datos.

### Suposiciones

Asumimos que estás ejecutando rsnapshot desde un equipo remoto, en las instalaciones. Esta misma configuración puede ser duplicada, tal como se indica arriba, remotamente fuera de las instalaciones.

En este caso, querrás instalar rsnapshot en el equipo que está haciendo todos los respaldos. También lo asumimos.
* Que los servidores a los que vas a hacer las copias de seguridad, tienen una regla de firewall que permiten al equipo remoto entrar por SSH
* Que cada servidor que va a respaldar tiene una versión reciente de rsync instalada. Para los servidores Rocky Linux, ejecute `dnf install rsync` para actualizar la versión de rsync del sistema.
* Que te hayas conectado al equipo como usuario root, o que hayas ejecutado `sudo -s` para cambiar al usuario root.

### Claves SSH públicas y privadas

Para el servidor que ejecutará las copias de seguridad, necesitamos generar un par de claves SSH para utilizarlas durante las copias de seguridad. Para nuestro ejemplo crearemos claves RSA.

Si ya tienes un set de claves generado puedes averiguarlo haciendo un `ls -al .ssh` y buscando un par de claves id_rsa e id_rsa.pub. Si no existe ninguno puedes utilizar el siguiente enlace para configurar tus claves y servidores a los que quieres acceder:

[Claves SSH públicas y privadas](../security/ssh_public_private_keys.es.md)

### Configuración de rsnapshot

El archivo de configuración tiene que ser igual que el que creamos para el **Basic Machine or Single Server Backup** arriba, excepto que queremos cambiar algunas opciones.

La raíz de la instantánea puede ser revertida a la predeterminada de la siguiente manera:

`snapshot_root   /.snapshots/`

Y esta línea:

`no_create_root 1`

... puede ser comentada de nuevo:

`#no_create_root 1`

La otra diferencia aquí es que cada equipo tendrá su propia configuración. Una vez que se acostumbre a esto, simplemente copiará uno de sus archivos de configuración existentes con un nuevo nombre y luego lo modificará para adaptarlo a cualquier equipo adicional que desee respaldar.

Por ahora, queremos modificar el archivo de configuración como lo hicimos anteriormente, y luego guardarlo. Luego copiamos ese archivo como plantilla para nuestro primer servidor:

`cp /etc/rsnapshot.conf /etc/rsnapshot_web.conf`

Queremos modificar el nuevo archivo de configuración y crear el archivo de registro y de bloqueo con el nombre de la máquina:

`logfile /var/log/rsnapshot_web.log`

`lockfile        /var/run/rsnapshot_web.pid`

Luego, queremos modificar rsnapshot_web.conf para que incluya los directorios que queremos respaldar. Lo único que es diferente es el objetivo.

Aquí hay un ejemplo de la configuración de web.ourdomain.com:

```
### BACKUP POINTS / SCRIPTS ###
backup  root@web.ourourdomain.com:/etc/     web.ourourdomain.com/
backup  root@web.ourourdomain.com:/var/www/     web.ourourdomain.com/
backup  root@web.ourdomain.com:/usr/local/     web.ourdomain.com/
backup  root@web.ourdomain.com:/home/     web.ourdomain.com/
backup  root@web.ourdomain.com:/root/     web.ourdomain.com/
```

### Comprobación de la configuración y ejecución de la copia de seguridad inicial

Al igual que antes, ahora podemos comprobar la configuración para asegurarnos de que es sintácticamente correcta:

`rsnapshot -c /etc/rsnapshot_web.conf configtest`

Y al igual que antes, buscamos el mensaje `Syntax OK`. Si todo está bien, podremos ejecutar la copia de seguridad manualmente:

`/usr/bin/rsnapshot -c /etc/rsnapshot_web.conf beta` 

Asumiendo que todo funciona bien, podemos entonces crear los archivos de configuración para el servidor de correo (rsnapshot_mail.conf) y el servidor de portal (rsnapshot_portal.conf), probarlos, y hacer un respaldo de prueba.

### Automatización de la copia de seguridad

La automatización de las copias de seguridad para la versión de múltiples equipos/servidores es ligeramente diferente. Queremos crear un script bash para llamar a las copias de seguridad en orden. Cuando uno termine, el siguiente se iniciará. Este script será algo así y se almacenará en /usr/local/sbin:

`vi /usr/local/sbin/backup_all`

Con el contenido:

```
#!/bin/bash
# script to run rsnapshot backups in succession
/usr/bin/rsnapshot -c /etc/rsnapshot_web.conf beta
/usr/bin/rsnapshot -c /etc/rsnapshot_mail.conf beta
/usr/bin/rsnapshot -c /etc/rsnapshot_portal.conf beta
```
Luego hacemos que el script sea ejecutable:

`chmod +x /usr/local/sbin/backup_all`

Luego creamos el crontab para que el root ejecute el script de backup:

`chrontab -e`

Y agregamos esta línea:

```
## Running the backup at 11 PM
00 23 *  *  *  /usr/local/sbin/backup_all
```

## Conclusiones y otros recursos

La configuración correcta de rsnapshot es un poco desalentadora al principio, pero puede ahorrarte mucho tiempo al respaldar tus equipos o servidores.

rsnapshot es muy poderoso, rápido y económico en el uso de espacio en disco. Puedes encontrar más información sobre rsnapshot, visitando [rsnapshot.org](https://rsnapshot.org/download.html)
