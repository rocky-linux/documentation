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



This slows down your web site performance without gaining any significant security. Stick with the 2048 key size for now and always keep tabs on what is currently recommended.

To start with, let's make sure that OpenSSL is installed on both your workstation and server:

`dnf install openssl`

If it is not installed, your system will install it and any needed dependencies. 

Our example domain is ourownwiki.com. Keep in mind that you would need to purchase and register your domain ahead of time. You can purchase domains through a number of "Registrars". 

If you are not running your own DNS (Domain Name System), you can often use the same providers for DNS hosting. DNS translates your named domain, to numbers (IP addresses, either IPv4 or IPv6) that the Internet can understand. These IP addresses will be where the web site is actually hosted.

Let's generate the key using openssl:

`openssl genrsa -des3 -out ourownwiki.com.key.pass 2048`

Note that we named the key, with a .pass extension. That's because as soon as we execute this command, it requests that you enter a passphrase. Enter a simple passphrase that you can remember as we are going to be removing this shortly:

```
Enter pass phrase for ourownwiki.com.key.pass:
Verifying - Enter pass phrase for ourownwiki.com.key.pass:
```

Next, let's remove that passphrase. The reason for this is that if you don't remove it, each time your web server restarts and loads up your key, you will need to enter that passphrase. 

You might not even be around to enter it, or worse, might not have a console at the ready to enter it. Remove it now to avoid all of that:

`openssl rsa -in ourownwiki.com.key.pass -out ourownwiki.com.key`

This will request that passphrase once again to remove the passphrase from the key:

`Enter pass phrase for ourownwiki.com.key.pass:`

Now that you have entered the passphrase a third time, it has been removed from the key file and saved as ourownwiki.com.key

## Generate the CSR

Next, we need to generate the CSR (certificate signing request) that we will use to purchase our certificate. 

During the generation of the CSR, you will be prompted for several pieces of information. These are the X.509 attributes of the certificate. 

One of the prompts will be for "Common Name (e.g., YOUR name)". It is important that this field be filled in with the fully qualified domain name of the server to be protected by SSL. If the website to be protected will be https://www.ourownwiki.com, then enter www.ourownwiki.com at this prompt:

`openssl req -new -key ourownwiki.com.key -out ourownwiki.com.csr`

This opens up a dialog:

`Country Name (2 letter code) [XX]:` enter the two character country code where your site resides, example "US"
`State or Province Name (full name) []:` enter the full official name of your state or province, example "Nebraska"
`Locality Name (eg, city) [Default City]:` enter the full city name, example "Omaha"
`Organization Name (eg, company) [Default Company Ltd]:` If you want, you can enter an organization that this domain is a part of, or just hit 'Enter' to skip.
`Organizational Unit Name (eg, section) []:` This would describe the division of the organization that your domain falls under. Again, you can just hit 'Enter' to skip.
`Common Name (eg, your name or your server's hostname) []:` Here, we have to enter our site hostname, example "www.ourownwiki.com"
`Email Address []:` This field is optional, you can decide to fill it out or just hit 'Enter' to skip.

Next, you will be asked to enter extra attributes which can be skipped by hitting 'Enter' through both:

```
Please enter the following 'extra' attributes
to be sent with your certificate request
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

