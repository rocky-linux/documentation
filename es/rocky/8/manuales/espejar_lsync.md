# Rocky Linux - Solución para espejar lsycnd

## Requisitos

Esto es todo lo que necesitarás para entender y seguir esta guía:

* Un equipo con Rocky Linux
* Un nivel de comodidad editando archivos de configuración desde la línea de comandos
* Conocimiento en editores de línea de comando (aquí utilizaremos vi, pero puedes escoger el de tu preferencia)
* Necesitas acceso a la raíz, e idealmente iniciar sesión como usuario raíz en tu terminal
* Un par de claves SSH públicas y privadas
* Los repositorios EPEL de Fedora
* Necesitarás estar familiarizado con *inotify*, una interfaz de monitorización de eventos
* Opcional: familiaridad con *tail*

# Introducción

Si buscas una forma de sincronizar automáticamente archivos y carpetas entre ordenadores, lsyncd es una opción bastante buena. ¿El único problema para los principiantes? Tienes que configurarlo todo a través de la línea de comandos, y de archivos de texto.

Aun así, es un programa que vale la pena aprender para cualquier administrador de sistemas.

La mejor descripción de *lsyncd*, viene de su propia página man. Ligeramente parafraseado, lsyncd es una solución ligera para espejar en vivo, que es comparativamente fácil de instalar. No requiere de nuevos sistemas de archivos o dispositivos de bloqueo, y no obstaculiza el rendimiento del sistema de archivos local. En resumen, refleja los archivos.

lsyncd vigila una interfaz de monitorización de eventos de árboles de directorios locales (inotify).
Agrega y combina los eventos durante unos segundos, y luego genera uno (o más) proceso(s) para sincronizar los cambios. Por defecto es rsync.

Para los propósitos de esta guía, llamaremos al sistema con los archivos originales el "maestro", y el que estemos sincronizando será el "objetivo". En realidad, es posible reflejar completamente un servidor usando lsyncd especificando muy cuidadosamente los directorios y archivos que quieras sincronizar. ¡Es una maravilla!

Para la sincronización remota, también querrás configurar [Claves SSH públicas y privadas](claves_ssh_publicas_privadas.md). Estos ejemplos usan SSH (puerto 22).

# Instalación de lsyncd

En realidad hay dos formas de instalar lsyncd. Incluiremos ambas aquí, pero el método preferido es instalar desde el código fuente. Es relativamente fácil de hacer y hay pocas dependencias necesarias. El RPM tiende a ir un poco por detrás de los paquetes fuente. Dicho esto, queremos darte ambas opciones y dejarte elegir. 

## Instalación de lsycnd - Método RPM

La instalación de la versión RPM es relativamente fácil. Lo único que tendrá que instalar primero es el repositorio de software EPEL de Fedora. Esto se puede hacer con un solo comando:

`dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm`

Para instalar lsyncd, entonces, solo tenemos que instalarlo, y cualquier dependencia que falte se instalará junto con él:

`dnf install lsyncd`

¡Eso es todo!

## Instalación de lsycnd - Método desde el código fuente

Instalar desde el código fuente no es tan malo como parece. Solo tienes que seguir esta guía y estarás funcionando en un abrir y cerrar de ojos.

### Instalar dependencias

Necesitaremos algunas dependencias: unas pocas que son requeridas por el propio lsyncd, y otras que son necesarias para construir paquetes desde el código fuente. Usa este comando en tu máquina Rocky Linux para asegurarte de que tienes las dependencias que necesitas. Si vas a construir desde el código fuente, es una buena idea tener todas las herramientas de desarrollo instaladas:

`dnf install groupinstall 'Development Tools'`

Y aquí están las dependencias que necesitamos para el propio lsyncd, y su proceso de construcción:

`dnf install lua lua-libs lua-devel cmake unzip wget rsync`

### Descargar lsycnd y construirlo

A continuación necesitamos el código fuente:

`wget https://github.com/axkibe/lsyncd/archive/master.zip`

Ahora descomprime el archivo master.zip:

`unzip master.zip`

Esto creará un directorio llamado "lsyncd-master". Tenemos que cambiar a este directorio y crear un directorio llamado build:

`cd lsyncd-master`

Y luego:

`mkdir build`

Ahora cambia de nuevo de directorio para que estés en el directorio build:

`cd build`

Ahora ejecuta estos comandos:

```
cmake ..
make
make install
```

Una vez hecho esto, deberías tener el binario de lsyncd instalado y listo para usar en */usr/local/bin*.

# Servicio systemd de lsycnd

Ninguno de los métodos de instalación activará el servicio systemd para iniciar lsyncd al reiniciar. Queremos ser capaces de hacer eso, porque si está replicando archivos, no quiere que la réplica esté fuera de línea porque se olvidó de iniciar manualmente un servicio. 

Eso es muy embarazoso para cualquier administrador de sistemas. 

Crear el servicio systemd no es terriblemente difícil, sin embargo, y le ahorrará mucho tiempo a largo plazo. 

## Crear el archivo de servicio lsyncd

Este archivo puede ser creado en cualquier lugar, incluso en el directorio raíz de su servidor. Una vez creado, podemos moverlo fácilmente a la ubicación correcta. 

`vi /root/lsyncd.service`

El contenido de este archivo debe ser:

```
[Unit]
Description=Live Syncing (Mirror) Daemon
After=network.target

[Service]
Restart=always
Type=simple
Nice=19
ExecStart=/usr/local/bin/lsyncd -nodaemon -pidfile /run/lsyncd.pid /etc/lsyncd.conf
ExecReload=/bin/kill -HUP $MAINPID
PIDFile=/run/lsyncd.pid

[Install]
WantedBy=multi-user.target
```
Ahora vamos a instalar el archivo que acabas de hacer en la ubicación correcta:

`install -Dm0644 /root/lsyncd.service /usr/lib/systemd/system/lsyncd.service`

Finalmente, recargamos el demonio systemctl para que systemd "vea" el nuevo archivo de servicio:

`systemctl daemon-reload`

# Configuración de lsycnd

Sea cual sea el método que elija para instalar lsyncd, necesitará un fichero de configuración: */etc/lsyncd.conf*. La siguiente sección le dirá cómo construir un archivo de configuración simple, y probarlo. 

## Ejemplo de configuración para pruebas

Aquí hay un ejemplo de un archivo de configuración simple que sincroniza */home* a otra máquina. Nuestra máquina objetivo va a ser una dirección IP local: *192.168.1.40*

```
  settings {
   logfile = "/var/log/lsyncd.log",
   statusFile = "/var/log/lsyncd-status.log",
   statusInterval = 20
   maxProcesses = 1
   }

sync {
   default.rsyncssh,
   source="/home", 
   host="root@192.168.1.40",
   excludeFrom="/etc/lsyncd.exclude",
   targetdir="/home",
   rsync = {
     archive = true,
     compress = false,
     whole_file = false
   },
   ssh = {
     port = 22
   }
}
```

Desglosando un poco este archivo:

* El "logfile" y el "statusFile" se crearán automáticamente cuando se inicie el servicio.
* El "statusInterval" es el número de segundos que hay que esperar antes de escribir en el statusFile.
* El "maxProcesses" es el número de procesos que lsyncd puede generar. Honestamente, a menos que esté ejecutando esto en un equipo súper ocupado, 1 proceso es suficiente.
* En la sección de sincronización "default.rsyncssh" dice que se debe usar rsync sobre ssh
* El "source=" es la ruta del directorio desde el que estamos sincronizando.
* El "host=" es nuestro equipos destino a la que estamos sincronizando.
* El "excludeFrom=" le dice a lsyncd donde está el archivo de exclusiones. Debe existir, pero puede estar vacío.
* El "targetdir=" es el directorio destino al que estamos enviando los archivos. En la mayoría de los casos será igual al de origen, pero no siempre.
* Luego tenemos la sección "rsync =", y estas son las opciones con las que estamos ejecutando rsync.
* Finalmente tenemos la sección "ssh =", y esto especifica el puerto SSH que está escuchando en el equipo destino.

Si estás añadiendo más de un directorio para sincronizar, entonces necesitas repetir toda la sección "sync" incluyendo todos los paréntesis de apertura y cierre para cada directorio.

## El archivo lsyncd.exclude

Como se ha dicho antes, el archivo "excludeFrom" debe existir, así que vamos a crearlo ahora:

`touch /etc/lsyncd.exclude`

Si estuviéramos sincronizando la carpeta /etc de nuestra máquina, habría una serie de archivos y/o directorios que deberíamos dejar fuera. Cada archivo o directorio excluido simplemente se enumera en el archivo, uno por línea, así:

```
/etc/hostname
/etc/hosts
/etc/networks
/etc/fstab
```

## Prueba y puesta en marcha

Ahora que todo lo demás está configurado, podemos probarlo todo. Para empezar, vamos a asegurarnos de que nuestro systemd lsyncd.service se iniciará:

`systemctl start lsyncd`

Si no aparece ningún error después de ejecutar este comando, comprueba el estado del servicio, solo para asegurarte:

`systemctl status lsyncd`

Si muestra que el servicio se está ejecutando, usa tail para ver los extremos de los dos archivos de registro, y asegúrate de que todo aparece bien:

`tail /var/log/lsyncd.log`

Y luego:

`tail /var/log/lsyncd-status.log`

Asumiendo que todo parece correcto, navega al directorio `/home/[user]`, donde `[user]` es un usuario del equipo y crea un nuevo archivo allí con *touch*.

`touch /home/[user]/testfile`

Ahora vaya al equipo destino y vea si el archivo aparece. Si es así, todo está funcionando como debería. Configure el servicio lsyncd.service para que se inicie en el arranque con:

`systemctl enable lsyncd`

Y ya debería estar listo para funcionar.

## Recuerde ser cuidadoso

Siempre que vayas a sincronizar un conjunto de archivos o directorios a otra máquina, piensa cuidadosamente en el efecto que tendrá en el equipo destino. Si vuelves a **El archivo lsyncd.exclude** de nuestro ejemplo anterior, ¿te imaginas lo que podría pasar si se sincroniza */etc/fstab*? 

Para los novatos, *fstab* es el archivo que se utiliza para configurar las unidades de almacenamiento en cualquier máquina Linux. Es casi seguro que los discos y las etiquetas son diferentes. La próxima vez que se reinicie el equipo destino es probable que no arranque por completo. 

# Conclusiones y referencias

lsycnd es una potente herramienta para la sincronización de directorios entre ordenadores. Como has visto, no es difícil de instalar, y es fácil de mantener en el futuro. No se puede pedir más que eso.

Puedes encontrar más información sobre lsyncd en [El Sitio Oficial](https://github.com/axkibe/lsyncd)
