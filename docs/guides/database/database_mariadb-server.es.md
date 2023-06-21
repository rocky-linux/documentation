---
title: Servidor de base de datos MariaDB
author: Steven Spencer
contributors: Ezequiel Bruni, William Perron, Pedro Garcia
tested_with: 8.5, 8.6, 9.0
tags:
  - base de datos
  - mariadb
---

# Servidor de base de datos MariaDB

## Requisitos previos

* Un servidor con Rocky Linux.
* Dominio de un editor de línea de comandos (en este ejemplo, utilizaremos _vi_)
* Un alto nivel de comodidad en la ejecución de comandos desde el terminal, la visualización de registros y otras tareas de caracter genérico dentro de la administración de sistemas
* Sería de gran utilidad poseer algún conocimiento sobre de bases de datos _mariadb-server_
* Todos los comandos se deben ejecutar como el usuario root o _sudo_

## Introducción

El servidor _mariadb-server_ y su cliente _mariadb_ son las alternativas de código abierto a _mysql-server_ y _mysql_, y comparten la misma estructura de comandos. _mariadb-server_ es muy popular y se utiliza en muchos servidores, debido a que es un requisito del CMS [Wordpress](https://es.wordpress.org/). Sin embargo, esta base de datos tiene muchos otros usos.

Si quieres aumentar aún más la seguridad por medio de otras herramientas, te aconsejo que leas la siguiente guía, [Apache Hardened Web Server guide](../web/apache_hardened_webserver/index.md).

## Instalar el servidor de MariaDB

Es necesario instalar _mariadb-server_:

`dnf install mariadb-server`

## Proteger el servidor de MariaDB

Para reforzar la seguridad de _mariadb-server_ necesitamos ejecutar un script, pero antes de hacerlo, necesitamos habilitar e iniciar mariadb:

`systemctl enable mariadb`

Y después:

`systemctl start mariadb`

A continuación, ejecuta el siguiente comando:

`mysql_secure_installation`

!!! tip

    La versión de mariadb-server que viene habilitada por defecto en Rocky Linux 8.5 es 10.3.32. Puede instalar la versión 10.5.13 activando el módulo:

    ```
    dnf module enable mariadb:10.5
    ```


    Y a continuación instalando `mariadb`. A partir de la versión 10.4.6 de MariaDB, hay comandos específicos de MariaDB disponibles que puedes utilizar en lugar de los antiguos comandos prefijados de `mysql`. Entre ellos se incluye también la anteriormente mencionada `mysql_secure_installation` que ahora se puede llamar con la versión de MariaDB `mariadb-secure-installation`.

Esto hace aparecer el siguiente cuadro de diálogo:

```
NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user.  If you've just installed MariaDB, and
you haven't set the root password yet, the password will be blank,
so you should just press enter here.

Enter current password for root (enter for none):
```

Puesto que se trata de una instalación totalmente nueva, no existe una contraseñas de root establecida. Así que aquí basta con pulsar la tecla 'Enter'.

La siguiente parte del diálogo continúa:

```
OK, successfully used password, moving on...

Setting the root password ensures that nobody can log into the MariaDB
root user without the proper authorisation.

Set root password? [Y/n]
```

Absolutamente _ necesitas tener_ una contraseña de root establecida. Deberás averiguar cuál quieres utilizar y guardarla en un gestor de contraseñas en algún sitio para que puedas recurrir a él si es necesario. Presiona la tecla 'Enter' para aceptar el valor predeterminado "Y". Esto mostrará el cuadro de diálogo de contraseñas:

```
New password:
Re-enter new password:
```

Teclea la contraseña que has elegido y confirmala la contraseña tecleando nuevamente. Si todo va bien, verá el siguiente diálogo:

```
Password updated successfully!
Reloading privilege tables..
 ... Success!
```

A continuación el diálogo trata sobre el usuario anónimo:

```
By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n]
```

La respuesta aquí es "Y", por lo que simplemente pulse la tecla 'Enter' para aceptar el valor por defecto.

El diálogo continúa a la sección que trata sobre permitir o no al usuario root iniciar sesión de forma remota:

```
... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n]
```

El usuario "root" solo se debe utilizar de manera local. Por lo tanto, puedes aceptar también este valor por defecto pulsando la tecla 'Enter'.

El diálogo se mueve a la base de datos 'test' que se instala automáticamente con _mariadb-server_:

```
... Success!


By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n]
```

Una vez más, la respuesta aquí es el valor por defecto, así que pulse la tecla 'Enter' para eliminarlo.

Finalmente, el diálogo le preguntará si quieres recargar los privilegios:

```
- Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] [Y/n]
```

Una vez más, basta con pulsar "Enter" para hacerlo. Si todo va bien, deberías recibir este mensaje:

```
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```

MariaDB debería estar listo para su uso.

### Cambios en Rocky Linux 9.0

Rocky Linux 9.0 utiliza `mariadb-server-10.5.13-2` como versión predeterminada del servidor mariadb. A partir de la versión 10.4.3, se activa automáticamente un nuevo plugin en el servidor que cambia el cuadro de diálogo `mariadb-secure-installation`. Este plugin permite la autenticación mediante `unix-socket`. En [este artículo](https://mariadb.com/kb/en/authentication-plugin-unix-socket/) se explica detalladamente esta nueva característica. Esencialmente, mediante la autenticación con `unix-socket` se utilizan las credenciales del usuario conectado para acceder a la base de datos. Esto lo que hace es que si el usuario root, por ejemplo, inicia sesión y luego utiliza `mysqladmin` para crear o eliminar una base de datos (o cualquier otra función) no se necesite una contraseña para acceder a ella. Esto tambien sirve para `mysql`. Lo que también significa que no hay contraseña que se pueda comprometer de manera remota. Esto depende de la seguridad de los usuarios configurados en el servidor para toda la protección de la base de datos.

El segundo diálogo que se muestra durante la instalación de `mariadb-secure-installation` después de configurar la contraseña para el usuario administrador es:

```
Switch to unix_socket authentication Y/n
```

Obviamente, el valor por defecto aquí es "Y", pero incluso si usted responde "n", con el plugin habilitado, no se solicitará la contraseña para el usuario, al menos no desde la interfaz de línea de comandos. Puede especificar o no la contraseña y ambas opciones funcionan:

```
mysql

MariaDB [(none)]>
```

```
mysql -p
Enter password:

MariaDB [(none)]>
```

Para obtener más información sobre esta función, consulte el enlace anterior. Hay una forma de desactivar este plugin y volver a tener la contraseña como un campo requerido, que también se detalla en ese enlace.

## Conclusión

Un servidor de base de datos, como _mariadb-server_, puede ser utilizado para muchos propósitos. Debido a la popularidad de Wordpress CMS, se encuentra a menudo en los servidores web. Sin embargo, antes de ejecutar la base de datos en producción, es una buena idea reforzar su seguridad.
