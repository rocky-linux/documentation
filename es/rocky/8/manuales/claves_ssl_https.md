# Cómo Generar Claves SSL

# Requisitos

* Una estación de trabajo y un servidor con Rocky Linux (OK, con Linux, pero realmente, quieres Rocky Linux, ¿no?)
* _OpenSSL_ instalado donde se van a generar la clave privada y CSR (Solicitud de Firma de Certificado), así como en el servidor donde se instalará la clave y los certificados.
* Un cierto nivel de comodidad operando desde la línea de comandos.
* Ayuda: conocimiento de SSL y comandos de OpenSSL.

# Introducción

Casi todos los servidores web actualmente _deberían_ operar con un certificado SSL (Capa de Conexiones Seguras). Este procedimiento le guiará a generar una clave privada para su sitio web y con él, a generar la CSR que usará para adquirir su nuevo certificado.

## Generar la Clave Privada

Para los no iniciados, las claves SSL pueden tener diferentes tamaños, medidos en bits, que básicamente determinan la dificultad en descifrarlas.

En 2021, el tamaño recomendado de la clave privada para un servidor web sigue siendo de 2048 bits. Puede ser mayor, pero doblar el tamaño de la clave de 2048 a 4096 sólo es 16% más seguro, ocupa más espacio almacenar la clave, requiere mayores cargas de la CPU cuando se procesa la clave.

Esto ralentiza el rendimiento de su sitio web sin mejoras significativas en seguridad. Utilize 2048 bits para el tamaño de su clave por ahora y manténgase informado en las recoemdaciones actuales.

Para empezar, asegúrese de que OpenSSL está instalado en su entación de trabajo y servidor:

`dnf install openssl`

Si no está instalado, su systema lo instalará con las necesarias depenciencias.

Nuestro dominio de ejemplo es nuestrowiki.com. Tenga en cuenta que tendrá que adquirir y registrar su dominio previamente. Puede adquirir dominios en multitud de "Registradores".

Si no tiene su propio DNS (Sistema de Nombre de Dominio), habitualmente se puede utilizar los mismos proveedores para alojamiento DNS. El DNS traduce su nombre de dominio a números (Direcciones IP, tanto IPv4 como IPv6) que se entiende en Internet. Estas direcciones IP serán donde el sitio web estará alojado realmente.

Generemos la clave usando openssl:

`openssl genrsa -des3 -out nuestrowiki.com.key.pass 2048`

Nótese que nombramos la clave con la extensión .pass. Esto es poque tan pronto ejecute este comando, le solicitará que introduca una contraseña. Utilice una contraseña simple que pueda recordar ya que la eliminaremos seguidamente:

```
Entre la contraseña para nuestrowiki.com.key.pass:
Verificando - Entre la contraseña para nuestrowiki.com.key.pass:
```

A continuación, eliminemos la contraseña. La razón de esto es que si no se elimina, tendrá que entrarla cada vez que se reinicie el servidor web y se cargue su clave.

Es posible que no esté presente, o peor todavía, que no disponga de una consola donde entrarla. Elimínela ahora para evitar todo esto:

`openssl rsa -in nuestrowiki.com.key.pass -out nuestrowiki.com.key`

Esto le solicitará la contraseña una vez más para eliminarla de la clave:

`Entre la contrasela para nuestrowiki.com.key.pass:`

Ahora que ha entrado la contraseña por tercera vez, se ha elinado de su clave y almacenado como nuentrowiki.com.key

## Generar la CSR

A continuación, necesitamos generar la CSR (Solicitud de Firma de Certificado) que usaremos para adquirir nuestro certificado. 

Durante la generación de la CSR, se le solicitará varios puntos de información. Estos son atributos X.509 del certificado.

Una de las cuestiones será por el "Nombre Común (p.e., SU NOMBRE)". Es importante que para este atributo se utilice el nombre de dominio completo del servidor a proteger con SSL. Si el sitio web será https://www.nuestrowiki.com, utilice www.nuestrowiki.com para esta cuestión.

`openssl req -new -key nuestrowiki.com.key -out nuestrowiki.com.csr`

Esto inicia el cuestionario:

`Nombre del país (código de 2 letras) [XX]:` entre el código del país de dos letras donde reside su sitio, por ejemplo "ES"
`Nombre del Estado o Provincia (Nombre completo) []:` entre el nombre oficial completo de su estado o provincia, por ejemplo "Córdoba"
`Población (ej, ciudad) [...]:` entre el nombre completo de la población, por ejemplo "Bilbao"
`Nombre de la Organicación (ej, Nombre de la empresa) [...]:` Si lo desea, puede entrar una organización ala que pertenezca el dominio, o pulse 'Enter' para saltar.
`Nombre de la unidad organizativa (por ejemplo una sección) []:` Esto indica la sección de la organización a la que pertenezca su dominio. De nuevo, puede pulsar 'Enter' para saltar.
`Nombre Común (ej, su nombre o el nombre de servidor) []:` Aquí tenemos que entrar el nombre del host, por ejemplo "www.nuestrowiki.com"
`Dirección de e-mail []:` Este campo es opcional, puede completarlo o simplemente pulsar 'Enter' para saltar este paso.

A continuación se le solicita que entre atributos extra que pueden evitarse pulsando 'Enter' para ambos:

```
Por favor entre los siguientes atributos 'extra' 
que srán enviados con su solicitud de certificado
A challenge password []:
An optional company name []:
```

Now you should have generated your CSR. 

## Purchasing The Certificate

Each certificate vendor will have basically the same procedure. You purchase the SSL and term (1 or 2 years, etc.) and then you submit your CSR. To do this, you will need to use the `more` command, and then copy the contents of your CSR file. 

`more ourownwiki.com.csr`

Which will show you something like this:

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

You want to copy everything including the "BEGIN CERTIFICATE REQUEST" and "END CERTIFICATE REQUEST" lines. Then paste these into the CSR field on the web site where you are purchasing the certificate. 

You may have to perform other verification steps, depending on ownership of the domain, the registrar you are using, etc., before your certificate is issued. When it is issued, it should be issued along with an intermediate certificate from the provider, which you will use in the configuration as well.

# Conclusion

Generating all of the bits and pieces for the purchase of a web site certificate is not terribly difficult and can be performed by the systems administrator or web site administrator using the above procedure.

