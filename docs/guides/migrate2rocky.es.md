---
title: Migrar a Rocky Linux
author: Ezequiel Bruni
contributors: tianci li, Steven Spencer, Pedro Garcia
update: 23-11-2021
---

# Cómo migrar a Rocky Linux desde CentOS Stream, CentOS, Alma Linux, RHEL u Oracle Linux

## Requisitos previos y supuestos

* CentOS Stream, CentOS, Alma Linux, RHEL u Oracle Linux ejecutándose correctamente en un servidor hardware o en un VPS. La versión actual soportada para cada uno de estos es la 8.5.
* Conocimiento práctico de la línea de comando.
* Conocimiento práctico de SSH para máquinas remotas.
* Una actitud ligeramente arriesgada.
* Todos los comandos deben ejecutarse como root. Inicie sesión como root o prepárese para utilizar "sudo" recurrentemente.

## Introducción

En esta guía, aprenderá cómo convertir todos los sistemas operativos enumerados anteriormente en instalaciones de Rocky Linux completamente funcionales. Esta es probablemente una de las formas más indirectas de instalar Rocky Linux, pero será útil para personas en una variedad de situaciones.

Por ejemplo, algunos proveedores de servidores no soportarán Rocky Linux por defecto durante un tiempo. O puede tener un servidor en producción que desee convertir a Rocky Linux sin tener que reinstalar todo.

Bueno, tenemos la herramienta para usted: [migrate2rocky](https://github.com/rocky-linux/rocky-tools/tree/main/migrate2rocky).

Es un script que, cuando se ejecute, cambiará todos sus repositorios por los de Rocky Linux. Los paquetes se instalarán y actualizarán o bajarán de versión según sea necesario, y el branding de su sistema operativo también cambiará.

No se preocupe, si es nuevo en la administración de sistemas, mantendré la explicación lo más amigable posible. Bueno, tan amigable como la línea de comando lo permita.

### Avisos y advertencias

1. Consulte la página README de migrate2rocky (cuyo enlace figura arriba), porque existe un conflicto conocido entre el script y los repositorios de Katello. Con el tiempo, es probable que descubramos (y eventualmente corrijamos) más conflictos e incompatibilidades, por lo que querrá saber sobre ellos, especialmente para servidores en producción.
2. Este script es más probable que funcione sin problemas en instalaciones completamente nuevas. _Si desea convertir un servidor en producción, por favor, **realice una copia de seguridad de los datos y un snapshot del sistema, o hágalo primero en un entorno de staging.**_

¿Todo claro? ̉¿Estamos listos? Continuemos.

## Prepare su servidor

Deberá obtener el archivo del script del repositorio. Esto puede realizarse de varios modos.

### El modo manual

Descargue los archivos comprimidos desde GitHub y extraiga el que necesite (es decir *migrate2rocky.sh*). Puede encontrar archivos zip para cualquier repositorio de GitHub en el lado derecho de la página principal del repositorio:

![El botón "Download Zip"](images/migrate2rocky-github-zip.png)

Luego, suba el ejecutable a su servidor via ssh al ejecutar este comando en su máquina local:

```
scp PATH/TO/FILE/migrate2rocky.sh root@yourdomain.com:/home/
```

Simplemente ajuste todas las rutas de los archivos y los dominios del servidor o las direcciones IP según sea necesario.

### El modo git

Instale git en su servidor con:

```
dnf install git
```

Luego clone el repositorio rocky-tools con:

```
git clone https://github.com/rocky-linux/rocky-tools.git
```

Nota: este método descargará todos los scripts y archivos del repositorio rocky-tools.

### El modo fácil

Este no es necesariamente el mejor modo de hacerlo, en términos de seguridad. Sólo necesita un cliente HTTP adecuado (curl, wget, lynx, etc.) instalado en el servidor.

Asumiendo que tiene la utilidad `curl` instalada, ejecute este comando para descargar el script en cualquier directorio que esté usando:

```
curl https://raw.githubusercontent.com/rocky-linux/rocky-tools/main/migrate2rocky/migrate2rocky.sh -o migrate2rocky.sh
```

Este comando descargará el archivo directamente a su servidor y *solamente* el archivo que desea. Pero nuevamente, hay preocupaciones de seguridad que sugieren que esta no es necesariamente la mejor práctica, así que téngalo en cuenta.

## Ejecución del script e instalación

Use el comando `cd` para cambiarse al directorio donde se encuentra el script, asegúrese de que el archivo sea ejecutable y otorgue permisos x al propietario del script.

```
chmod u+x migrate2rocky.sh
```

Y ahora, por fin, ejecute el script:

```
./migrate2rocky.sh -r
```

Esa opción "-r" le indica al script que siga adelante e instale todo.

Si ha hecho todo bien, la ventana de su terminal debería parecerse un poco a esto:

![un inicio de script exitoso](images/migrate2rocky-convert-01.png)

Ahora, el script tardará un tiempo en convertir todo, lo cual dependerá de la máquina/servidor y de la conexión a Internet disponibles.

Si ve el mensaje **¡Completado!** al final, entonces todo está correcto y puede reiniciar el servidor.

![un mensaje de migración del sistema operativo exitoso](images/migrate2rocky-convert-02.png)

Espere un tiempo, vuelva a iniciar sesión y debería tener un nuevo y elegante servidor Rocky Linux con el cual jugar... Es decir, con el cual trabajar muy en serio. Ejecute el comando `hostnamectl` para verificar que su sistema operativo haya sido migrado correctamente y que esté listo para continuar.

![Los resultados del comando hostnamectl](images/migrate2rocky-convert-03.png)
