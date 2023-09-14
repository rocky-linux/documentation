---
title: https - Generación de claves RSA
author: Steven Spencer, Pedro Garcia
update: 27-01-2022
---

# https - Generación de claves RSA

He utilizado este script muchas veces. No importa la frecuencia con la que utilice la estructura de comandos de openssl, a veces tendrá que volver a consultar el procedimiento. Este script le permite automatizar la generación de claves para un sitio web utilizando RSA. Tenga en cuenta que este script está codificado para utilizar una longitud de clave de 2048 bits. Para aquellos usuarios que creen que la longitud mínima de la clave debería ser de 4096 bits, simplemente necesitan cambiar esa parte del script. Solo debe saber que hay que sopesar la memoria y la velocidad que necesita un sitio web para cargarse en un dispositivo determinado, frente a la seguridad que ofrece la utilización de una longitud de clave mayor.

## Script

Renombre este script como quiera, por ejemplo: `keygen.sh` y hágalo sea ejecutable (`chmod +x scriptname`) y colóquelo en un directorio que esté incluido dentro de su variable de entorno $PATH, por ejemplo: /usr/local/sbin

```
#!/bin/bash
if [ $1 ]
then
      echo "generating 2048 bit key - you'll need to enter a pass phrase and verify it"
      openssl genrsa -des3 -out $1.key.pass 2048
      echo "now we will create a pass-phrase less key for actual use, but you will need to enter your pass phrase a third time"
      openssl rsa -in $1.key.pass -out $1.key
      echo "next, we will generate the csr"
      openssl req -new -key $1.key -out $1.csr
      #cleanup
      rm -f $1.key.pass
else
      echo "requires keyname parameter"
      exit
fi
```

!!! Note

    Tendrá que introducir tres veces seguidas la contraseña para la clave.

## Breve descripción

* Este script de bash requiere que introduzca un parámetro ($1) que es el nombre del sitio sin www, etc. Por ejemplo, "misitioweb".
* El script crea la clave con una contraseña por defecto y una longitud de 2048 bits (puede editarlo, como se señaló anteriormente para que se utilice una longitud más larga de 4096 bits)
* La contraseña se elimina de la clave inmediatamente, el motivo se debe a que los reinicios que se produzcan en el servidor web requerirían que se introdujera la contraseña cada vez, lo que en la práctica puede ser algo problemático.
* A continuación, el script crea el archivo CSR (Certificate Signing Request), que se puede utilizar para adquirir un certificado SSL de un proveedor.
* Por último, el paso de limpieza elimina la clave creada anteriormente con la contraseña adjunta.
* Ejecutar el script sin el parámetro necesario provocará el error: "requires keyname parameter".
* Aquí se utiliza el parámetro posicional, es decir, $n. Donde $0 representa el comando en sí y de $1 a $9 representan los parámetros del primero al noveno. Cuando el número de parametros necesarios es mayor que 10, se debe utilizar llaves, por ejemplo ${10}.
