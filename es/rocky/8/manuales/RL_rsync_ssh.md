# Utilizando rsync para Mantener dos Equipos Sincronizados

## Requisitos

Esto es todo lo que necesitarás para comprender y seguir esta guía.

* Una máquina que ejecute Rocky Linux.
* Cierta comodidad editando archivos de configuración desde la linea de comandos.
* Cierto conocimiento en editores de línea de comandos (Aquí utilizaremos vi, sin embargo puedes utilizar el que prefieras).
* Necesitarás acceso root y también iniciar sesión como usuario root en tu terminal.
* Un juego de claves SSH públicas y privadas.
* Capacidad para crear un script simple, utilizando vi o el editor que prefieras, y probarlo.
* Capacidad para automatizar la ejecución del script con _crontab_.

# Introducción

Utilizar _rsync_ sobre SSH no es tan poderoso como [lsync](RL_espejar_lsync.md) (que permite monitorear un directorio o archivo en busca de cambios y mantenerlo sincronizado en tiempo real), ni tan flexible como [rsnapshot](RL_copias_de_seguridad_rsnapshot.md) (que permite hacer una copia de seguridad de múltiples objetivos desde un solo equipo fácilmente). Pero, ofrece la capacidad de mantener dos equipos actualizados en un horario definido.

rsync ha existido desde el principio de los tiempos (bueno, tal vez no tanto, pero si lleva su tiempo) así que cada distribución Linux lo tiene disponible, y todavía persiste en los paquetes base. rsync sobre SSH puede ser una solución si necesita mantener un conjunto de directorios actualizados en un equipo objetivo, sin embargo la sincronización en tiempo real no es realmente importante.

Para todo lo siguiente, vamos a utilizar el usuario root para realizar las cosas, así que o bien entra como root o utiliza el comando `sudo -s` para cambiar al usuario root en la terminal.

## Instalación de rsync

Es probable que rsync se encuentre instalado, sin embargo es una buena idea actualizar rsync a su última versión tanto en el equipo origen como en el destino. Para asegurarnos que rsync está instalado y actualizado se hará lo siguiente en ambos equipos:

`dnf install rsync`

Si el paquete no está instalado, dnf le pedirá que confirme la instalación y si está instalado, dnf buscará una actualización y nos dará la posibilidad de instalarla.

## Preparando el Entorno

Este ejemplo en específico utilizará rsync con el objetivo de extraer desde el origen, en lugar de realizar jalar desde el origen hacia el destino, por lo que necesitaremos configurar un [juego de claves SSH](RL_claves_ssh_públicas_privadas.md) para esto. Una vez creado el juego de claves SSH, y confirmado el acceso sin contraseña desde el equipo objetivo al origen, estamos listos para comenzar.

## Parámetros de rsync y Configuración del Script

Antes de comenzar con la configuración del script, debemos decidir qué parámetros queremos usar con rsync. Hay muchas posibilidades, así que echa un vistazo al [manual de rsync](https://linux.die.net/man/1/rsync). La forma más común de usar rsync es usar la opción -a, porque -a combina una serie de opciones en una sola y éstas son las más comunes. ¿Qué incluye -a?
* -r, recurrir a los directorios
* -l, mantener los enlaces simbólicos
* -p, preservar los permisos
* -t, preservar los tiempos de modificación
* -g, preservar los grupos
* -o, preservar al propietario
* -D, preservar archivos de dispositivos

Las únicas otras opciones que necesitamos especificar en este ejemplo son:

* -e, especifica el shell remoto a utilizar
* --delete, en el dado caso que el directorio de destino posea un archivo que no existe en el origen, lo eliminará

A continuación, debemos configurar un script creando dicho archivo. (Nuevamente, utilice el editor de su preferencia si no está familiarizado con vi). Para crear el archivo, simplemente utilice este comando:

`vi /usr/local/sbin/rsync_dirs`

Y luego hacerlo ejecutable:

`chmod +x /usr/local/sbin/rsync_dirs`

## Probando

Por ahora, vamos a hacerlo simple y seguro para que podamos probar sin problema alguno. Observe que abajo estamos usando la URL "source.domain.com". Remplazarlo por el dominio o dirección IP del propio equipo de origen. Recuerda también que en este caso estamos creando el script en la equipo "objetivo", ya que estamos sacando los archivos del equipo origen:

```
#!/bin/bash
/usr/bin/rsync -ae ssh --delete root@source.domain.com:/home/your_user /home
```
En este caso, asumimos que su directorio personal no existe en el destino. **Si existe, es posible que quieras hacer una copia de seguridad antes de ejecutar el script.**

Ahora ejecute el script:

`/usr/local/sbin/rsync_dirs`

Si todo va bien, debería obtener una copia completamente sincronizada de tu directorio personal en la máquina de destino. Comprueba que es así.

Asumiendo que todo esto ha funcionado como esperábamos, a continuación, debemos seguir adelante y crear un nuevo archivo en el directorio personal del equipo origen:

`touch /home/your_user/testfile.txt`

Ejecutar de nuevo el sript:

`/usr/local/sbin/rsync_dirs`

Y luego verificar que el equipo destino recibió el nuevo archivo. Si es así, el siguiente paso es comprobar el proceso de borrado. En el equipo origen, debemos eliminar el archivo que acabamos de crear:

`rm -f /home/your_user/testfile.txt`

Ejecutar de nuevo el script:

`/usr/local/sbin/rsync_dirs`

Verificar que el archivo ha desaparecido en el equipo destino.

Finalmente, vamos a crear un archivo en el equipo destino que no exista en el origen:

`touch /home/your_user/a_different_file.txt`

Ejecutar el script por última vez:

`/usr/local/sbin/rsync_dirs`

El archivo que creamos en el destino debería desaparecer ahora, esto debido a que no existe en el origen.

Asumiendo que todo esto ha funcionado como se esperaba, podemos seguir adelante y modificar el script para sincronizar todos los directorios que se deseen.

## Automatizar todo

Probablemente no queremos ejecutar este script manualmente cada vez que queramos sincronizar, así que el siguiente paso es automatizarlo. Digamos que quieres ejecutar este script cada noche a las 11 PM. Para automatizar esto con Rocky Linux, usamos crontab:

`crontab -e`

Esto mostrará el cron que puede verse algo así:

``` 
# Edit this file to introduce tasks to be run by cron.
# 
# Each task to run has to be defined through a single line
# indicating with different fields when the task will be run
# and what command to run for the task
# 
# To define the time you can provide concrete values for
# minute (m), hour (h), day of month (dom), month (mon),
# and day of week (dow) or use '*' in these fields (for 'any').
# 
# Notice that tasks will be started based on the cron's system
# daemon's notion of time and timezones.
# 
# Output of the crontab jobs (including errors) is sent through
# email to the user the crontab file belongs to (unless redirected).
# 
# For example, you can run a backup of all your user accounts
# at 5 a.m every week with:
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
# 
# For more information see the manual pages of crontab(5) and cron(8)
# 
# m h  dom mon dow   command
```
El cron está configurado en un reloj de 24 horas, así que lo que necesitaremos para nuestra entrada en la parte inferior de este archivo es:

`00 23   *  *  *    /usr/local/sbin/rsync_dirs`

Esto ejecutará el comando a las 00 minutos, 23 horas, cada día, cada mes y cada semana. Luego guardar la entrada cron con:

`Shift : wq!` 

... o el comando que su editor preferido utiliza para guardar los cambios.

# Conclusiones

Si bien rsync no puede ser tan flexible o poderoso como otras opciones, ofrece una simple sincronización de archivos. Y siempre hay un uso para eso.
