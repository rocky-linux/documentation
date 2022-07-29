---
title: Comandos avanzados de Linux
---

# Comandos avanzados para usuarios de Linux

En este capítulo aprenderá algunos comandos avanzados para Linux.

****

**Objetivos** : En este capítulo, los futuros administradores de Linux aprenderán como:

:heavy_check_mark: utilizar algunos comandos útiles no cubiertos en el capítulo anterior;   
:heavy_check_mark: utilizar algunos comandos avanzados.

:checkered_flag: **comandos de usuario**, **Linux**

**Conocimiento**: :star:   
**Complejidad**: :star: :star: :star:

**Tiempo de lectura**: 20 minutos

****

## Comando `uniq`

El comando `uniq` es un comando muy potente, utilizado en conjunto con el comando `sort`, especialmente para análisis de archivos de registro. Le permite ordenar y mostrar las entradas de los registros eliminando duplicados.

Para ilustrar cómo funciona el comando `uniq`, vamos a utilizar un archivo llamado `firstnames.txt` que contiene una lista con nombres:

```
antoine
xavier
steven
patrick
xavier
antoine
antoine
steven
```

!!! Note

    `uniq` requiere que el archivo de entrada sea ordenado porque solo compara líneas consecutivas.

Sin utilizar ningún argumento, el comando `uniq` no mostrará las líneas idénticas continuas dentro del archivo `firstnames.txt`:

```
$ sort firstnames.txt | uniq
antoine
patrick
steven
xavier
```

Para mostrar sólo las filas que aparecen una única vez, utilice la opción `-u`:

```
$ sort firstnames.txt | uniq -u
patrick
```

Al contrario, para mostrar únicamente las líneas que aparecen como mínimo dos veces en el archivo, debe utilizar la opción `-d`:

```
$ sort firstnames.txt | uniq -d
antoine
steven
xavier
```

Para eliminar las líneas que aparecen solo una vez, utilice la opción `-D`:

```
$ sort firstnames.txt | uniq -D
antoine
antoine
antoine
steven
steven
xavier

```

Finalmente, para contar el número de ocurrencias de cada línea, utilice la opción `-c`:

```
$ sort firstnames.txt | uniq -c
      3 antoina
      1 patrick
      2 steven
      2 xavier
```

```
$ sort firstnames.txt | uniq -cd
      3 antoina
      2 steven
      2 xavier
```

## Comandos `xargs`

El comando `xargs` le permite la construcción y ejecución de líneas de comando desde la entrada estándar.

El comando `xargs` lee espacios en blanco o argumentos delimitados desde la entrada estándar, y ejecuta el comando (`/bin/echo` por defecto) una o más veces utilizando los argumentos iniciales seguidos por los argumentos leídos desde la entrada estándar.

Un primer y simple ejemplo sería el siguiente:

```
$ xargs
uso
de
xargs
<CTRL+D>
uso de xargs
```

El comando `xargs` espera una entrada desde la entrada estándar **stdin**. Se introducen tres líneas. El fin de la entrada del usuario para `xargs` se especifica a mediante la secuencia de teclas <kbd>CTRL</kbd>+<kbd>D</kbd>. Entonces `xargs` ejecuta el comando por defecto `echo` seguido de los tres argumentos correspondientes a la entrada del usuario, a saber:

```
$ echo "uso" "de" "xargs"
uso de xargs
```

Es posible especificar un comando a ejecutar por `xargs`.

En el siguiente ejemplo, `xargs` ejecutará el comando `ls -ld` en el conjunto de carpetas especificado en la entrada estándar:

```
$ xargs ls -ld
/home
/tmp
/root
<CTRL+D>
drwxr-xr-x. 9 root root 4096  5 avril 11:10 /home
dr-xr-x---. 2 raíz 4096 5 avril 15:52 /root
drwxrwxrwt. 3 root root 4096  6 avril 10:25 /tmp
```

En la práctica, el comando `xargs` ejecutó el comando `ls -ld /home /tmp /root`.

¿Qué ocurre si el comando a ejecutar no acepta múltiples argumentos como es el caso del comando `find`?

```
$ xargs find /var/log -name
*.old
*.log
find: paths must precede expression: *.log
```

El comando `xargs` intentó ejecutar el comando `find` con múltiples argumentos después de la opción `-name`, lo que provocó que `find` generase un error:

```
$ find /var/log -name "*.old" "*.log"
find: paths must precede expression: *.log
```

En este caso, se debe forzar al comando `xargs` a ejecutar el comando `find` varias veces (una vez por línea introducida mediante la entrada estándar). La opción `-L` seguida por un **entero** le permite especificar el número máximo de entradas para ser procesadas con el comando en un momento:

```
$ xargs -L 1 find /var/log -name
*.old
/var/log/dmesg.old
*.log
/var/log/boot.log
/var/log/anaconda.yum.log
/var/log/anaconda.storage.log
/var/log/anaconda. og
/var/log/yum.log
/var/log/audit/audit.log
/var/log/anaconda.ifcfg.log
/var/log/dracut.log
/var/log/anaconda.program.log
<CTRL+D>
```

Si queremos ser capaces de especificar ambos argumentos en la misma línea, tendríamos que usar la opción `-n 1`:

```
$ xargs -n 1 find /var/log -name
*.old *.log
/var/log/dmesg.old
/var/log/boot.log
/var/log/anaconda.yum.log
/var/log/anaconda.storage.log
/var/log/anaconda.log
/var/log/yum.log
/var/log/audit/audit.log
/var/log/anaconda.ifcfg.log
/var/log/dracut.log
/var/log/anaconda.program.log
<CTRL+D>
```

Caso de estudio de una de seguridad con el comando `tar` basado en una búsqueda:

```
$ find /var/log/ -name "*.log" -mtime -1 | xargs tar cvfP /root/log.tar
$ tar tvfP /root/log. ar
-rw-r--r-- root/root 1720 2017-04-05 15:43 /var/log/boot.log
-rw-r--r-- root/root 499270 2017-04-06 11:01 /var/log/audit/audit.log
```

La característica especial del comando `xargs` es que coloca el argumento de entrada al final del comando llamado. Esto funciona muy bien con el ejemplo anterior, ya que los archivos pasados formarán la lista de archivos que se añadirán al archivo.

Ahora, si tomamos el ejemplo del comando `cp` y queremos copiar una lista de archivos en un directorio, esta lista de archivos se añadirá al final del comando... pero lo que el comando `cp` espera al final del comando es el destino. Para hacer esto, utilizamos la opción `-I` que permite poner los argumentos de entrada en otro lugar diferente al final de la línea.

```
$ find /var/log -type f -name "*.log" | xargs -I % cp % /root/backup
```

La opción `-I` le permite especificar un carácter (en nuestro ejemplo el carácter `%`) donde se colocarán los archivos de entrada para `xargs`.

## El paquete `yum-utils`

El paquete `yum-utils` es una colección de utilidades de diferentes autores para `yum`, que hacen que sea más fácil y más potente de usar.

!!! Note

    Aunque `yum` ha sido reemplazado por `dnf` en Rocky Linux 8, el nombre del paquete sigue siendo `yum-utils`, también puede instalarlo como `dnf-utils`. Estas son utilidades clásicas de YUM implementadas como CLI sobre DNF para mantener la compatibilidad hacia atrás con `yum-3`.

Aquí se muestran algunos ejemplos de uso:

* Comando `repoquery`:

El comando `repoquery` se utiliza para consultar los paquetes en el repositorio.

Ejemplos de uso:

  * Mostrar las dependencias de un paquete (puede ser un paquete de software que ha sido instalado o no instalado), equivale a `dfn deplist <package-name>`.

    repoquery --requires <package-name>

  * Mostrar los archivos proporcionados por un paquete instalado (no funciona para paquetes que no están instalados), equivale a `rpm -ql <package-name>`

    ```
    $ repoquery -l yum-utils
    /etc/bash_completion.d
    /etc/bash_completion.d/yum-utils.bash
    /usr/bin/debuginfo-install
    /usr/bin/find-repos-of-install
    /usr/bin/needs-restarting
    /usr/bin/package-cleanup
    /usr/bin/repo-graph
    /usr/bin/repo-rss
    /usr/bin/repoclosure
    /usr/bin/repodiff
    /usr/bin/repomanage
    /usr/bin/repoquery
    /usr/bin/reposync
    /usr/bin/repotrack
    /usr/bin/show-changed-rco
    /usr/bin/show-installed
    /usr/bin/verifytree
    /usr/bin/yum-builddep
    /usr/bin/yum-config-manager
    /usr/bin/yum-debug-dump
    /usr/bin/yum-debug-restore
    /usr/bin/yum-groups-manager
    /usr/bin/yumdownloader
    …
    ```

* comando `yumdownloader`:

El comando `yumdownloader` descarga paquetes RPM de los repositorios.  Equivalente a `dnf download --downloadonly --downloaddir ./ package-name`

!!! Note

    ¡Este comando es muy útil para construir rápidamente un repositorio local con unos pocos rpms!

Ejemplo: `yumdownloader` descargará el paquete rpm _samba_ así cómo todas sus dependencias:

```
$ yumdownloader --destdir /var/tmp --resolve samba
or
$ dnf download --downloadonly --downloaddir /var/tmp  --resolve  samba
```

| Opciones    | Comentarios                                                         |
| ----------- | ------------------------------------------------------------------- |
| -`-destdir` | Los paquetes descargados se almacenarán en la carpeta especificada. |
| `--resolve` | También descarga las dependencias del paquete.                      |

## El paquete `psmisc`

El paquete `psmisc` contiene una serie de utilidades relacionadas con la gestion de procesos del sistema:

* `pstree`: El comando `pstree` muestra los procesos que se están ejecutando en el sistema con una estructura semejante a la de un árbol.
* `killall`: El comando `killall` envía una señal kill a todos los procesos identificados por su nombre.
* `fuser`: El comando `fuser` identifica el `PID` de los procesos que utilizan los archivos o sistemas de archivos especificados.

Ejemplos:

```
$ pstree
systemd─┬─NetworkManager───2*[{NetworkManager}]
        ├─agetty
        ├─auditd───{auditd}
        ├─crond
        ├─dbus-daemon───{dbus-daemon}
        ├─firewalld───{firewalld}
        ├─lvmetad
        ├─master─┬─pickup
        │        └─qmgr
        ├─polkitd───5*[{polkitd}]
        ├─rsyslogd───2*[{rsyslogd}]
        ├─sshd───sshd───bash───pstree
        ├─systemd-journal
        ├─systemd-logind
        ├─systemd-udevd
        └─tuned───4*[{tuned}]
```

```
# killall httpd
```

Cierra todos los (opción `-k`) que acceden al archivo `/etc/httpd/conf/httpd.conf`:

```
# fuser -k /etc/httpd/conf/httpd.conf
```

## Comando `watch`

El comando `watch` ejecuta regularmente un comando y muestra el resultado en el terminal a pantalla completa.

La opción `-n` le permite especificar el número de segundos entre cada ejecución del comando.

!!! Note

    Para salir del comando `watch`, debe pulsar las claves: <kbd>CTRL</kbd>+<kbd>C</kbd> para matar el proceso.

Ejemplos:

* Mostrar el final del archivo `/etc/passwd` cada 5 segundos:

```
$ watch -n 5 tail -n 3 /etc/passwd
```

Resultado:

```
Every 5,0s: tail -n 3 /etc/passwd                                                                                                                                rockstar.rockylinux.lan: Thu Jul  1 15:43:59 2021

sssd:x:996:993:User for sssd:/:/sbin/nologin
chrony:x:995:992::/var/lib/chrony:/sbin/nologin
sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin
```

* Monitorizar el número de archivos en una carpeta:

```
$ watch -n 1 'ls -l | wc -l'
```

* Mostrar un reloj:

```
$ watch -t -n 1 date
```
