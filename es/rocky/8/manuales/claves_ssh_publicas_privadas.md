# Rocky Linux - Claves SSH Públicas y Privadas

## Requisitos

* Un cierto nivel de comodidad operando desde la línea de comandos
* Servidores Linux y/o estaciones de trabajo con *openssh* instalado
    * De acuerdo, técnicamente, este proceso podría funcionar en cualquier sistema Linux con openssh instalado.
* Opcional: familiaridad con los permisos de archivos y directorios de linux

# Introducción

SSH es un protocolo utilizado para acceder a una máquina desde otra, normalmente a través de la línea de comandos. Con SSH, puedes ejecutar comandos en ordenadores y servidores remotos, enviar archivos y, en general, gestionar todo lo que haces desde un solo lugar.

Cuando estás trabajando con múltiples servidores Rocky Linux en múltiples ubicaciones, o si simplemente estás tratando de ahorrar algo de tiempo accediendo a estos servidores, querrás usar un par de claves públicas y privadas SSH. Los pares de claves básicamente facilitan el acceso a máquinas remotas y la ejecución de comandos. 

Este documento le guiará a través del proceso de creación de las claves y la configuración de sus servidores para un fácil acceso, con dichas claves.

### Procedimiento para la generación de claves

Los siguientes comandos se ejecutan todos desde la línea de comandos en su estación de trabajo Rocky Linux:

`ssh-keygen -t rsa`

Que mostrará lo siguiente:

```
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
```

Pulsa Enter para aceptar la ubicación por defecto. A continuación el sistema mostrará:

`Enter passphrase (empty for no passphrase):`

Por lo tanto, solo tienes que pulsar Enter aquí. Por último, le pedirá que vuelva a introducir la frase de contraseña:

`Enter same passphrase again:`

Así que pulsa Enter una última vez.

Ahora deberías tener un par de claves públicas y privadas de tipo RSA en tu directorio .ssh:

```
ls -a .ssh/
.  ..  id_rsa  id_rsa.pub
```

Ahora tenemos que enviar la clave pública (id_rsa.pub) a cada máquina a la que vayamos a acceder... pero antes de hacerlo, tenemos que asegurarnos de que podemos acceder por SSH a los servidores a los que vamos a enviar la clave. Para nuestro ejemplo, vamos a utilizar solo tres servidores. 

Puedes acceder a ellos a través de SSH por un nombre DNS o una dirección IP, pero para nuestro ejemplo vamos a utilizar el nombre DNS. Nuestros servidores de ejemplo son web, correo y portal. Para cada servidor, intentaremos entrar por SSH (a los nerds les encanta usar SSH como verbo) y dejaremos una ventana de terminal abierta para cada máquina:

`ssh -l root web.ourourdomain.com` 

Suponiendo que podemos iniciar sesión sin problemas en las tres máquinas, el siguiente paso es enviar nuestra clave pública a cada servidor:

`scp .ssh/id_rsa.pub root@web.ourourdomain.com:/root/` 

Repita este paso con cada una de nuestras tres máquinas. 

En cada una de las ventanas de terminal abiertas, ahora debería poder ver *id_rsa.pub* al introducir el siguiente comando:

`ls -a | grep id_rsa.pub` 

Si es así, ahora estamos listos para crear o añadir el archivo *authorized_keys* en el directorio *.ssh* de cada servidor. En cada uno de los servidores, introduzca este comando:

`ls -a .ssh` 

**¡Importante! Asegúrese de leer cuidadosamente todo lo que se indica a continuación. Si no estás seguro de romper algo, entonces haz una copia de seguridad de authorized_keys (si existe) en cada una de las máquinas antes de continuar.**

Si no hay un archivo *authorized_keys* en la lista, entonces lo crearemos introduciendo este comando mientras estamos en nuestro directorio _/root_:

`cat id_rsa.pub > .ssh/authorized_keys`

Si _authorized_keys_ existe, entonces simplemente queremos añadir nuestra nueva clave pública a las que ya están allí:

`cat id_rsa.pub >> .ssh/authorized_keys`

Una vez que la clave ha sido añadida a _authorized_keys_, o el archivo _authorized_keys_ ha sido creado, intente SSH desde su estación de trabajo Rocky Linux al servidor de nuevo. No debería pedírsele una contraseña.

Una vez que haya verificado que puede acceder por SSH sin contraseña, elimine el archivo id_rsa.pub del directorio _/root_ de cada máquina.

`rm id_rsa.pub`

### SSH Directory and authorized_keys Security

En cada uno de sus equipos de destino, asegúrese de que se aplican los siguientes permisos:

`chmod 700 .ssh/`
`chmod 600 .ssh/authorized_keys`
