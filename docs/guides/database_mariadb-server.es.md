# Base de datos mariadb-server

## Pre-requisitos

* Un servidor con Rocky Linux.
* Estaremos usando _"vi"_ como editor de linea de comandos, por lo que es necesario saber usarlo
* Una gran facilidad para el uso de líneas de comando en la terminal, revisar los logs (registros de errores), y otros aspectos generales de un administrador de sistema
* Será útil algún conocimiento sobre _mariadb-server_
* Toma en consideración que todos los comandos deben ser ejecutados con super usuario o con _sudo_

## Introducción

La combinación de _mariadb-server_ y su cliente _mariadb_ son una buena alternativa open source para _mysql-server_ y _mysql_, ya que los mismos comparten las mismas estructuras de comando.

_mariadb-server_ es bastante popular y es usado en muchos servidores, debido a que es requerido por el CMS de [Wordpress](https://es.wordpress.org/). Aunque el mismo también se puede usar para otras cosas.

Si buscas aumentar aún más la seguridad por medio de otras herramientas, te aconsejo que leas la siguiente guía, [Apache Hardened Web Server guide](apache_hardened_webserver/index.md).

### Instalando mariadb-server

Necesitamos primero instalar _mariadb-server_:

> `dnf install mariadb-server`

### Asegurando mariadb-server

Para fortalecer la seguridad en _mariadb-server_ necesitamos primero habilitar el servicio:

> `systemctl enable mariadb`

Y luego inicializarlo:

> `systemctl start mariadb`

Para finalmente ingresar este comando:

> `mysql_secure_installation`

Del cual saldrá este dialogo:

```bash
NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user.  If you've just installed MariaDB, and
you haven't set the root password yet, the password will be blank,
so you should just press enter here.

Enter current password for root (enter for none): 
```

Al ser una instalación limpia, no hay una contraseña establecida: Por lo que tenés que presionar "Enter". Y te va a salir este dialogo:

```bash
OK, successfully used password, moving on...

Setting the root password ensures that nobody can log into the MariaDB
root user without the proper authorisation.

Set root password? [Y/n] 
```

Lo que sí, siempre _deberías_ tener un gestor de contraseñas. Donde podés guardarla y pedirla cuando sea necesario.
Teclea "Y" y luego presiona "Enter", después de eso ingresa la contraseña y verifícala.

```bash
New password: 
Re-enter new password:
```

Si todo está bien, te aparecerá este mensaje:

```bash
Password updated successfully!
Reloading privilege tables..
 ... Success!
```

El siguiente mensaje trata sobre los usuarios anónimos, del cual seleccionamos "Y" y tecleamos "Enter":

```bash
By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] 
```

El siguiente dialogo básicamente te está preguntando si querés que el usuario "root" pueda loguearse remotamente.

El usuario "root" solo debe ser usado de manera local. Así que presiona "Y" y luego "Enter".

```bash
... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n]
```

El dialogo siguiente indica que _mariadb-server_ inicia con la base de datos "test" automáticamente para usos de prueba, del cual seleccionamos "Y" y presionamos "Enter".

```bash
... Success!


By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] 
```

Finalmente, el último dialogo va pedirte si querés recargar los privilegios:

```bash
- Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] 
```

De nuevo, tecleamos "Y" y presionamos "Enter" y si todo va bien, deberías recibir este mensaje:

```bash
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```

Con esto, MariaDB debería estar listo para su uso.

## Conclusiones

Antes que arranquemos la base de datos en la etapa de producción, es una buena idea blindar la seguridad de la misma.

Un servidor de base de datos, como _mariadb-server_, puede ser usado para muchos propósitos. Más allá del uso que tiene debido al CMS de Wordpress. Antes de pasar a la etapa de producción, una buena práctica es fortalecer la seguridad de la base de datos.