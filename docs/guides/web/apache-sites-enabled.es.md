# Configuración del servidor web Apache para múltiples sitios

Rocky Linux tiene muchas maneras de configurar un sitio web. Este es sólo un método de varios, utilizando Apache, y está diseñado para configurar múltiples sitios en un solo servidor. Aunque este método está diseñado para servidores multisitio, también puede servir como una configuración base para un servidor de un solo sitio.  

Este tipo de configuración parece haber empezado en sistemas basados en Debian, pero se puede adaptar a cualquier sistema operativo basado en Linux que ejecute Apache.

## Lo que se necesita

* Un servidor con Rocky Linux.
* Conocimiento de la línea de comandos y de editores de texto (Este ejemplo utiliza *vi*, pero puede usar su editor favorito).
    * Si quieres aprender sobre el editor de texto vi, [aquí hay un tutorial práctico](https://www.tutorialspoint.com/unix/unix-vi-editor.htm).
* Conocimientos básicos sobre la instalación y ejecución de servicios web.

## Instalar Apache

Muy probablemente se necesiten otros componentes para tu sitio web. Por ejemplo, es casi seguro que necesitarás alguna versión de PHP, y tal vez también una base de datos u otro componente. Instalando PHP junto con httpd obtendrás la última versión de ambos desde los repositorios de Rocky Linux.

Sólo recuerda que puedes necesitar otros módulos también, como quizás php-bcmath o php-mysqlind. Las especificaciones de tu aplicación web deberían detallar lo que se necesita. Estos pueden ser instalados en cualquier momento. Por ahora, instalaremos httpd y PHP:

* Desde la línea de comandos, corre `dnf install httpd php`

## Crear directorios adicionales

Este método require crear un par de directorios adicionales que actualmente no existen en el sistema. Necesitamos añadir dos directorios en */etc/httpd/* llamados "sites-available" y "sites-enabled".

* Desde la línea de comandos, escribe `mkdir /etc/httpd/sites-available` y luego `mkdir /etc/httpd/sites-enabled`.

* También necesitamos crear un directorio donde nuestros sitios van a residir. Esto puede ser en cualquier lugar, pero una buena manera de mantener las cosas organizadas es crear un directorio llamado "sub-domains". Para mantener las cosas simples, el directorio va a residir en /var/www: `mkdir /var/www/sub-domains/`.

## Configuración

También tenemos que añadir una línea al final del archivo httpd.conf. Para ello, corre `vi /etc/httpd/conf/httpd.conf` y al final del archivo añade `Include /etc/httpd/sites-enabled`.

Nuestros archivos de configuración residirán en */etc/httpd/sites-available* y simplemente haremos un enlace simbólico a ellos en */etc/httpd/sites-enabled*.

**¿Por qué hacemos esto?**

La razón es muy simple. Digamos que tienes 10 sitios web que se ejecutan en el mismo servidor en diferentes direcciones IP. Digamos que el sitio B tiene algunas actualizaciones importantes y tienes que hacer cambios en la configuración para ese sitio. Digamos también, que hay algo mal con los cambios realizados, así que cuando reinicias httpd para leer los nuevos cambios, httpd no se inicia.

No sólo no se iniciará el sitio en el que se estaba trabajando, sino que tampoco lo harán los demás. Con este método, se puede eliminar el enlace simbólico para el sitio que causó el fallo, y reiniciar httpd. Todo comenzará a funcionar de nuevo, y luego se puede trabajar en arreglar la configuración del sitio roto.

Es un alivio saber que el teléfono no va a sonar con clientes o jefes enfadados, porque un servicio está desconectado.

### La configuración del sitio

El otro beneficio de este método es que nos permite especificar completamente todo fuera del archivo httpd.conf. Deja que el archivo httpd.conf por defecto cargue los valores predeterminados, y deja que las configuraciones de tu sitio hagan todo lo demás. Genial, ¿verdad? Además, de nuevo, hace que sea muy fácil solucionar un problema de una configuración rota de un sitio.

Ahora, digamos que tienes un sitio web que carga una wiki. Necesitarás un archivo de configuración, que haga que el sitio esté disponible a través del puerto 80. Si quieres servir el sitio web con SSL (y seamos sinceros, todos deberíamos de hacerlo ya) entonces necesitas añadir otra sección (casi idéntica) al mismo archivo, para habilitar el puerto 443.

Así que primero tenemos que crear este archivo de configuración en *sites-available*: `vi /etc/httpd/sites-available/com.wiki.www`

El contenido del archivo de configuración sería algo así:

```apache
<VirtualHost *:80>
        ServerName www.wiki.com 
        ServerAdmin username@rockylinux.org
        DocumentRoot /var/www/sub-domains/com.wiki.www/html
        DirectoryIndex index.php index.htm index.html
        Alias /icons/ /var/www/icons/
        # ScriptAlias /cgi-bin/ /var/www/sub-domains/com.wiki.www/cgi-bin/

        CustomLog "/var/log/httpd/com.wiki.www-access_log" combined
        ErrorLog  "/var/log/httpd/com.wiki.www-error_log"

        <Directory /var/www/sub-domains/com.wiki.www/html>
                Options -ExecCGI -Indexes
                AllowOverride None

                Order deny,allow
                Deny from all
                Allow from all

                Satisfy all
        </Directory>
</VirtualHost>
```

Una vez creado el archivo, tenemos que guardarlo con: `shift : wq`

En nuestro ejemplo anterior, el sitio se carga desde el subdirectorio html de com.wiki.www, lo que significa que nuestra ruta creada en /var/www (arriba) necesitará algunos directorios adicionales para satisfacer esto:

`mkdir -p /var/www/sub-domains/com.wiki.www/html`

... lo que creará la ruta completa con un solo comando. A continuación, queremos instalar nuestros archivos en este directorio que realmente ejecutará el sitio web. Esto podría ser algo creado por ti o una aplicación, en este caso una wiki, que hayas descargado. Copia los archivos a la ruta anterior:

`cp -Rf wiki_source/* /var/www/sub-domains/com.wiki.www/html/`

## Habilitar el sitio

Recuerda que nuestro archivo *httpd.conf* incluye */etc/httpd/sites-enabled* al final, así que cuando httpd se reinicie, cargará cualquier archivo de configuración que esté en el directorio *sites-enabled*. El asunto es que todos nuestros archivos de configuración están en *sites-available*.

Esto es por diseño, para que podamos eliminar fácilmente las cosas en caso de que httpd falle al reiniciar. Así que para habilitar nuestro archivo de configuración, necesitamos crear un enlace simbólico a ese archivo en *sites-enabled* y luego iniciar o reiniciar el servicio web. Para hacer esto, usamos este comando:

`ln -s /etc/httpd/sites-available/com.wiki.www /etc/httpd/sites-enabled/`

Esto creará el enlace al archivo de configuración en *sites-enabled*, tal y como queremos.

Ahora solo queda iniciar httpd con `systemctl start httpd` o reiniciarlo si ya se está ejecutando con `systemctl restart httpd`, y suponiendo que el servicio web se reinicia, ahora se puede ir y hacer pruebas en el nuevo sitio.
