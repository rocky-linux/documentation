---
title: Claves SSH Públicas y Privadas
author: Steven Spencer
contributors: Ezequiel Bruni
tested with: 8.5
tags:
  - seguridad
  - ssh
  - keygen
---

# Claves SSH Públicas y Privadas

## Requisitos previos

* Comodidad operando desde la línea de comandos
* Servidores Linux y/o estaciones de trabajo con *openssh* instalado
    * De acuerdo, técnicamente, este proceso podría funcionar en cualquier sistema Linux con openssh instalado.
* Opcional: familiaridad con los permisos de archivos y directorios de Linux

## Introducción

SSH es un protocolo utilizado para acceder a una máquina desde otra, normalmente a través de la línea de comandos. Mediante SSH, puede ejecutar comandos en ordenadores y servidores remotos, enviar archivos y, en general, gestionar todo lo que hace desde un solo lugar.

Cuando está trabajando con múltiples servidores Rocky Linux en múltiples ubicaciones, o si simplemente está tratando de ahorrar algo de tiempo accediendo a estos servidores, querrá utilizar un par de claves públicas y privadas SSH. Básicamente, los pares de claves facilitan el acceso a las máquinas remotas y la ejecución de comandos en ellas.

Este documento le guiará a través del proceso de creación de las claves y de la configuración de sus servidores para facilitarle el acceso mediante esas claves.

## Procedimiento para la generación de claves

Los siguientes comandos se ejecutan desde la línea de comandos de su estación de trabajo Rocky Linux:

```
ssh-keygen -t rsa
```

Que mostrará lo siguiente:

```
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
```

Pulse Enter para aceptar la ubicación por defecto. A continuación el sistema mostrará:

`Enter passphrase (empty for no passphrase):`

Por lo tanto, solo tiene que pulsar Enter aquí. Por último, le pedirá que vuelva a introducir la frase de contraseña:

`Enter same passphrase again:`

Así que pulse Enter una última vez.

Ahora debería tener un par de claves pública y privada de tipo RSA en su directorio .ssh:

```
ls -a .ssh/
.  ..  id_rsa  id_rsa.pub
```

Ahora tenemos que enviar la clave pública (id_rsa.pub) a cada máquina a la que vayamos a acceder... pero antes de hacerlo, tenemos que asegurarnos de poder acceder por SSH a los servidores a los que vamos a enviar la clave. Para nuestro ejemplo, vamos a utilizar solo tres servidores.

Puede acceder a ellos a través de SSH mediante un nombre DNS o una dirección IP, pero para nuestro ejemplo vamos a utilizar el nombre DNS. Nuestros servidores de ejemplo son web, correo y portal. Para cada servidor, intentaremos conectar mediante SSH (a los nerds les encanta usar SSH como verbo) y dejaremos una ventana de terminal abierta para cada máquina:

`ssh -l root web.ourourdomain.com`

Suponiendo que podemos iniciar sesión sin problemas en las tres máquinas, el siguiente paso es enviar nuestra clave pública a cada servidor:

`ssh/id_rsa.pub root@web.ourourdomain.com:/root/`

Repita este paso con cada una de nuestras tres máquinas.

En cada una de las ventanas del terminal abiertas, debería poder ver *id_rsa.pub* al introducir el siguiente comando:

`ls -a | grep id_rsa.pub`

Si es así, ahora está listo para crear o añadir el archivo *authorized_keys* en el directorio *.ssh* de cada servidor. En cada uno de los servidores, introduzca este comando:

`ls -a .ssh`

!!! attention "¡Importante!"

    Asegúrese de leer cuidadosamente todo lo que se indica a continuación. Si no está seguro de que no vaya a romper nada, haga una copia de seguridad del archivo authorized_keys (si existe) de cada una de las máquinas antes de continuar.

Si no existe el archivo *authorized_keys* en la lista, entonces lo crearemos introduciendo este comando desde el directorio _/root_:

`cat id_rsa.pub > .ssh/authorized_keys`

Si el archivo _authorized_keys_ existe, entonces simplemente queremos añadir nuestra clave pública a las ya existentes:

`cat id_rsa.pub >> .ssh/authorized_keys`

Una vez añadida al archivo _authorized_keys_, o que el archivo _authorized_keys_ ha sido creado, intente conectar vía SSH desde su estación de trabajo Rocky Linux al servidor de nuevo. No debería pedírsele una contraseña.

Una vez que haya verificado que puede acceder vía SSH sin utilizar su contraseña, elimine el archivo id_rsa.pub del directorio _/root_ de cada máquina.

`rm id_rsa.pub`

## Directorio SSH y seguridad del archivo authorized_keys

En cada uno de los equipos de destino, asegúrese de que se aplican los siguientes permisos:

`chmod 700 .ssh/` `chmod 600 .ssh/authorized_keys`
