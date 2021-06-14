# Automatizar procesos con cron y crontab en

## Requisitos

* Un equipo con Rocky Linux.
* Cierta comodidad editando los archivos de configuración desde la linea de comandos con un editor de preferencia (aquí se usará _vi_).

## <a name="suposiciones"></a> Suposiciones

* Conocimientos básicos en bash, python u otras herramientas de scripting/programación, y poder hacer que el script se ejecute automáticamente.
* Que se esté como usuario root o cambiar a root con `sudo -s` **(Poder ejecutar ciertos scripts en sus propios directorios como usuario propietario. En este caso, no es necesario cambiar a root).**
* Suponemos que eres genial.

# Introducción

Linux proporciona el sistema _cron_, un planificador de trabajos basado en el tiempo, para automatizar procesos. Es simple y a su vez poderoso. ¿Quieres un script o programa que se ejecute todos los días a las 5 PM? Aquí es donde puedes configurarlo.

_Crontab_ es esencialmente una lista donde los usuario agregan sus tareas y trabajos para automatizarlos, y esto tiene serie opciones que podrían simplificar dichas tareas aún más. Este documento explorará algunas de ellas. Es un buen repaso para aquellos con algo de experiencia, y los nuevos usuarios podrán agregar al sistema cron a su repertorio.

## <a name="Comenzando con lo sencillo"></a> Comenzando con lo sencillo - El "cron."

Incorporado en todos los sistemas Linux incluido Rocky Linux, desde hace muchas versiones, los archivos "cron." ayudan a automatizar los procesos con agilidad. Estos aparecen como directorios que el sistema cron llama basándose en sus convenciones de nomenclatura.

Para hacer que algo se ejecute durante estos tiempos autodefinidos, todo lo que necesitas hacer es copiar tu archivo de script en el directorio en cuestión, y asegurarte de que es ejecutable. Aquí están los directorios, y los tiempos que se ejecutarán:

* `/etc/cron.hourly/` - Los scripts colocados aquí se ejecutarán a 1 minuto después de la hora, cada hora de cada día.
* `/etc/cron.daily` - Los scripts colocados aquí se ejecutarán a las 4:02 AM todos los días.
* `/etc/cron.weekly` - Los scripts colocados aquí se ejecutarán a las 4:22 AM del domingo de cada semana.
* `/etc/cron.monthly` - Los scripts colocados aquí se ejecutarán a las 4:42 AM del primer día del mes, cada mes.

Por lo tanto, siempre que estés de acuerdo con dejar que el sistema ejecute automáticamente tus scripts en uno de estos momentos predeterminados, esto te será de gran utilidad para automatizar tareas de una manera sencilla.

## Crear tu propio cron

Por supuesto, si los tiempos automatizados no te funcionan bien por cualquier razón, entonces puedes crear los tuyos propios. En este ejemplo, asumimos que usted está haciendo esto como root. Para hacer esto, escriba lo siguiente:

`crontab -e`

Esto abrirá el crontab del usuario root tal y como se encuentra en este momento con en el editor que hayas elegido, y puede tener un aspecto similar al siguiente. Siga leyendo esta versión comentada, ya que contiene descripciones de cada campo que usaremos a continuación:

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
# cron
# For example, you can run a backup of all your user accounts
# at 5 a.m every week with:
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
# 
# For more information see the manual pages of crontab(5) and cron(8)
# 
# m h  dom mon dow   command
```

Observe que este archivo crontab en particular tiene algo de su propia documentación incorporada. Este no es siempre el caso. Al modificar un crontab en un contenedor o sistema operativo minimalista, el crontab será un archivo vacío, a menos que ya se haya colocado una entrada en él.

Supongamos que tenemos un script de copia de seguridad que queremos ejecutar a las 10 de la noche. El crontab utiliza un reloj de 24 horas, por lo que sería a las 22:00. Supongamos que el script de copia de seguridad se llama "backup" y que está actualmente en el directorio _/usr/local/sbin_. 

Nota: Recuerde que este script debe ser también ejecutable (`chmod +x`) para que el cron lo ejecute. Para añadir el trabajo, lo haríamos:

`crontab -e`

"crontab" significa "tabla cron" y el formato del archivo es, de hecho, un diseño de tabla suelto. Ahora que estamos en el crontab, vaya al final del archivo y añada su nueva entrada. Si está usando vi como su editor de sistema por defecto, entonces esto se hace con las siguientes teclas:

`Shift : $`

Ahora que está en la parte inferior del archivo, inserte una línea y escriba un breve comentario para describir lo que sucede con su entrada. Esto se hace añadiendo un "#" al principio de la línea:

`# Backing up the system every night at 10PM`

Ahora pulsa enter. Aún deberías estar en el modo de inserción, así que el siguiente paso es añadir tu entrada. Como se muestra en nuestro crontab vacío comentado (arriba), esto es **m** para los minutos, **h** para las horas, **dom** para el día del mes, **mon** para el mes y **dow** para el día de la semana. 

Para ejecutar nuestro script de copia de seguridad todos los días a las 10:00, la entrada tendría el siguiente aspecto:

`00  22  *  *  *   /usr/local/sbin/backup`

Esto dice que se ejecute el script a las 10 PM, cada día del mes, cada mes y cada día de la semana. Obviamente, este es un ejemplo bastante simple y las cosas pueden complicarse bastante cuando se necesitan datos específicos.

### Las @opciones de crontab

Como se indica en la parte de [Comenzando con lo sencillo](##-comenzando-con-lo-sencillo) de este documento, los scripts de los directorios cron dot se ejecutan a horas muy concretas. Las @opciones ofrecen la posibilidad de utilizar una sincronización más natural. Las @opciones consisten en:

* `@hourly` ejecuta el script cada hora de cada día a las 0 minutos de la hora.
* `@daily` ejecuta el script cada día a medianoche.
* `@weekly` ejecuta el script cada semana a la medianoche del domingo.
* `@monthly` ejecuta el script cada mes a medianoche del primer día del mes.
* `@yearly` ejecuta el script cada año a medianoche del primer día de enero.
* `@reboot` ejecuta el script sólo al iniciar el sistema.

Para nuestro ejemplo de script de copia de seguridad, si utilizamos la opción @daily para ejecutar el script de copia de seguridad a medianoche, la entrada tendría este aspecto:

`@daily  /usr/local/sbin/backup`

### Opciones más complejas

Hasta ahora, todo lo que hemos dicho ha tenido opciones bastante simples, pero ¿qué pasa con los tiempos de las tareas más complejas? Supongamos que quieres ejecutar tu script de copia de seguridad cada 10 minutos durante el día (probablemente no sea algo muy práctico, pero bueno, ¡es un ejemplo!). Para hacer esto usted escribiría:

`*/10  *   *   *   *   /usr/local/sbin/backup`

¿Y si quisieras ejecutar la copia de seguridad cada 10 minutos, pero sólo los lunes, miércoles y viernes?

`*/10  *   1,3,5   *   *   /usr/local/sbin/backup`

¿Y cada 10 minutos todos los días excepto el sábado y el domingo?

`*/10  *   1-5   *    *    /usr/local/sbin/backup`

En la tabla, las comas le permiten especificar entradas individuales dentro de un campo, mientras que el guión le permite especificar un rango de valores dentro de un campo. Esto puede ocurrir en cualquiera de los campos, y en varios campos al mismo tiempo. Como puede ver, las cosas pueden complicarse bastante. 

Al determinar cuándo ejecutar un script, debe tomarse el tiempo necesario y planificarlo, especialmente si los criterios son complejos.

# Conclusiones

El sistema cron/crontab es una herramienta muy poderosa para el usuario de escritorio o el administrador de sistemas de Rocky Linux. Puede permitirte automatizar tareas y scripts para que no tengas que acordarte de ejecutarlos manualmente. 

Aunque lo básico es bastante fácil, puede volverse mucho más complejo. Para obtener más información sobre crontab dirígete a la [página del manual de crontab](https://man7.org/linux/man-pages/man5/crontab.5.html). También puedes hacer una búsqueda en la web de "crontab" que te dará una gran cantidad de resultados para ayudarte a pulír tus habilidades con crontab.
