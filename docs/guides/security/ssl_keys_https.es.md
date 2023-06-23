---
title: Generación de claves SSL
author: Steven Spencer
contributors: Ezequiel Bruni, Pedro Garcia
tested_with: 8.5
tags:
  - seguridad
  - ssl
  - openssl
---
  
# Generación de claves SSL

## Requisitos previos

* Una estación de trabajo y un servidor ejecutando Rocky Linux (OK...Linux, pero realmente deseas utilizar Rocky Linux, ¿Verdad?).
* _OpenSSL_ instalado en la máquina que se va a tuilizar para generar la clave privada y el CSR, así como en el servidor donde eventualmente se instalará su clave y los certificados.
* Capacidad para ejecutar comandos con comodidad desde la línea de comandos.
* De utilidad: conocimiento de los comandos SSL y OpenSSL.


## Introducción

A día de hoy, practicamente cada sitio web _debería_ estr funcionando con un certificado SSL (capa de socket segura). Este procedimiento le guiará a través del proceso de generación de la clave privada para su sitio web y a partir de ahí, la generación del CSR (solicitud de firma de certificados) que utilizará para comprar su nuevo certificado.

## Generar la clave privada

Para los no iniciados, las claves privadas SSL pueden tener diferentes tamaños, medidos en bits, lo que básicamente determina lo difícil que son de romper.

A partir del año 2021, el tamaño recomendado de la clave privada para un sitio web sigue siendo de 2048 bits. Puede escoger un valor más alto, pero duplicar el tamaño de la clave de 2048 bits a 4096 bits es sólo un 16% más seguro, consume más espacio para almacenar la clave, y provoca una mayor carga de CPU cuando se procesa la clave.

Ralentizando el rendimiento de su sitio web sinobtener una mejora de seguridad significativa. Quédese con el tamaño de clave de 2048 por ahora y mantengase siempre al tanto de lo que se recomienda actualmente.

Para empezar, asegurémonos de que OpenSSL esté instalado tanto ensu estación de trabajo como en el servidor:

`dnf install openssl`

Si no está instalado, su sistema lo instalará junto con las dependencias necesarias.

Nuestro dominio de ejemplo es example.com. Ten en cuenta que necesitará comprar y registrar su dominio con antelación. Usted puede comprar dominios a través del amplio número de proveedores de dominio.

Si no está ejecutando su propio DNS (Sistema de nombres de dominio), puede utilizar los mismos proveedores para el alojamiento DNS. DNS traduce el nombre de su dominio, a números (direcciones IP, ya sean IPv4 o IPv6) que Internet puede entender. Esas direcciones IP se corresponden con donde está realmente alojado el sitio web.

Vamos a generar la clave utilizando openssl:

`openssl genrsa -des3 -out example.com.key.pass 2048`

Tenga en cuenta que guardaremos la clave, con una extensión .pass. Esto es debido a que tan pronto como ejecutemos este comando, se le pedirá que introduzca una contraseña. Introduce una contraseña simple que pueda recordar ya que la vamos a eliminar en breve:

```
Enter pass phrase for example.com.key.pass:
Verifying - Enter pass phrase for example.com.key.pass:
```

A continuación, quitemos esa contraseña. La razón por la que esto es así es que si no la elimina, cada vez que reinicie su servidor web y cargue su clave, necesitará introducir esa contraseña.

Puede que ni siquiera esté ahí para introducirla, o peor aún, puede que no tenga una consola preparada para entrar en ella. Eliminela ahora para evitar todo eso:

`openssl rsa -in example.com.key.pass -out example.com.key`

Al ejecutar este comando se le solicitará que introduzca esa contraseña una vez más para eliminarla de la clave:

`Enter pass phrase for example.com.key.pass:`

Ahora que ha introducido la contraseña por tercera vez, se ha eliminado del archivo y se ha guardado con el nombre de example.com.key

## Generar el archivo CSR

A continuación, necesitamos generar la solicitud de firma de certificados (CSR) que utilizaremos para comprar nuestro certificado.

Durante la generación del CSR, se le pedirán diversa informacion, relativa al proceso. Esta información son los atributos X.509 del certificado.

Una de las preguntas será "Common Name (e.g., YOUR name)". Es importante que este campo se rellene con el nombre de dominio completo del servidor que será protegido por SSL. Si el sitio web a proteger es https://www.example.com, entonces introduzca a www.example.com en esta pregunta:

`openssl req -new -key example.com.key -out example.com.csr`

Esto abrirá el siguiente cuadro de diálogo:

`Country Name (2 letter code) [XX]:` Introduzca el código de país de dos caracteres donde reside su sitio, por ejemplo "US"

`State or Province Name (full name) [:` Introduzca el nombre completo y oficial de su estado o provincia, por ejemplo "Nebraska".

`Locality Name (eg, city) [Default City]:` Introduzca el nombre completo de la ciudad, por ejemplo "Omaha".

`Organization Name (eg, company) [Default Company Ltd]:` Si lo desea, puede introducir el nombre de la organización de la que forma parte este dominio, o simplemente pulse 'Entrar' para omitir este paso.

`Organizational Unit Name (eg, section) []:` Describiría la división de la organización a la que pertenece su dominio. De nuevo, sólo puede pulsar la tecla 'Enter' para omitir este paso.

`Common Name (eg, your name or your server's hostname) []:` Aquí, debemos introducir el nombre de nuestro sitio web, ejemplo "www.example.com"

`Email Address []:` Este campo es opcional, puede decidir rellenarlo o simplemente pulsar 'Entrar' para evitar introducir esta información.

A continuación, se le pedirá que introduzca atributos adicionales que se pueden omitir pulsando la tecla 'Enter':

```
Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

Ahora debería haber generado su CSR.

## Comprar el certificado

Cada proveedor de certificados tendrá básicamente el mismo procedimiento. Usted compra el certificado SSL y por un plazo determinado (1 o 2 años, etc.) y luego envíe su CSR. Para hacer esto, necesitará utilizar el comando `mmoreás`, y luego copiar el contenido de su archivo CSR.

`more example.com.csr`

Que le mostrará algo similar a esto:

```
-----BEGIN CERTIFICATE REQUEST-----
MIICrTCCAZUCAQAwaDELMAkGA1UEBhMCVVMxETAPBgNVBAgMCE5lYnJhc2thMQ4w
DAYDVQQHDAVPbWFoYTEcMBoGA1UECgwTRGVmYXVsdCBDb21wYW55IEx0ZDEYMBYG
A1UEAwwPd3d3Lm91cndpa2kuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEAzwN02erkv9JDhpR8NsJ9eNSm/bLW/jNsZxlxOS3BSOOfQDdUkX0rAt4G
nFyBAHRAyxyRvxag13O1rVdKtxUv96E+v76KaEBtXTIZOEZgV1visZoih6U44xGr
wcrNnotMB5F/T92zYsK2+GG8F1p9zA8UxO5VrKRL7RL3DtcUwJ8GSbuudAnBhueT
nLlPk2LB6g6jCaYbSF7RcK9OL304varo6Uk0zSFprrg/Cze8lxNAxbFzfhOBIsTo
PafcA1E8f6y522L9Vaen21XsHyUuZBpooopNqXsG62dcpLy7sOXeBnta4LbHsTLb
hOmLrK8RummygUB8NKErpXz3RCEn6wIDAQABoAAwDQYJKoZIhvcNAQELBQADggEB
ABMLz/omVg8BbbKYNZRevsSZ80leyV8TXpmP+KaSAWhMcGm/bzx8aVAyqOMLR+rC
V7B68BqOdBtkj9g3u8IerKNRwv00pu2O/LOsOznphFrRQUaarQwAvKQKaNEG/UPL
gArmKdlDilXBcUFaC2WxBWgxXI6tsE40v4y1zJNZSWsCbjZj4Xj41SB7FemB4SAR
RhuaGAOwZnzJBjX60OVzDCZHsfokNobHiAZhRWldVNct0jfFmoRXb4EvWVcbLHnS
E5feDUgu+YQ6ThliTrj2VJRLOAv0Qsum5Yl1uF+FZF9x6/nU/SurUhoSYHQ6Co93
HFOltYOnfvz6tOEP39T/wMo=
-----END CERTIFICATE REQUEST-----
```

Debe copiar todo, incluyendo las líneas "REQUEST CERTIFICATE BEGIN" y "END CERTIFICATE REQUEST". A continuación, péguelas en el campo CSR del sitio web en el que está comprando el certificado.

Es posible que tenga que realizar otros pasos de verificación, dependiendo de la propiedad del dominio, el proveedor de dominio que está utilizando, etc., antes de poder emitir su certificado. Cuando se emita, debe emitirse junto con un certificado intermedio del proveedor, que también se utilizará en la configuración.

## Conclusión

Generar todos los bits y piezas para la compra de un certificado de un sitio web no es terriblemente difícil y puede ser realizado por el administrador del sistema o el administrador del sitio web utilizando el procedimiento descrito en este documento.
