---
title: DokuWiki
author: Steven Spencer
contributors: Ezequiel Bruni
tested with: 8.5, 8.6, 9.0
tags:
  - wiki
  - documentación
---

# Servidor DokuWiki

## Requisitos previos y supuestos

* Una instancia de Rocky Linux instalada en un servidor, contenedor o máquina virtual.
* Comodidad para modificar los archivos de configuración desde la línea de comandos con un editor (nuestros ejemplos aquí utilizarán _vi_, pero puede sustituirlo por su editor favorito)
* Algunos conocimientos sobre aplicaciones web y su configuración.
* Nuestro ejemplo utilizará la rutina [Apache Sites Enabled](../web/apache-sites-enabled.md) para la configuración, por lo que es una buena idea revisar esa rutina si planea seguir adelante.
* Utilizaremos "wiki-doc.sudominio.com" como nombre de dominio a lo largo de este ejemplo.
* Asumiremos a lo largo de este documento que usted es el usuario root o puede llegar a él con _sudo_.
* Estamos asumiendo que está utilizando una instalación limpia del sistema operativo, sin embargo esto es **NO** un requisito.

## Introducción

La documentación puede adoptar muchas formas en una organización. Disponer de un repositorio en el que poder consultar esa documentación tiene un valor incalculable. Un wiki (que significa _rápido_ en hawaiano), es una forma de mantener la documentación, las notas de los procesos, las bases de conocimiento corporativas, e incluso los ejemplos de código, en una ubicación centralizada. Los profesionales de la informática que mantienen un wiki, aunque sea en secreto, tienen una póliza de seguro incorporada contra el olvido de una oscura rutina.

DokuWiki es un wiki maduro y rápido que se ejecuta sin base de datos, tiene características de seguridad incorporadas y es relativamente fácil de implementar. Para más información sobre lo que DokuWiki puede hacer, eche un vistazo a su [página web](https://www.dokuwiki.org/dokuwiki).

DokuWiki es sólo uno de los muchos wiki disponibles, aunque es bastante bueno. Una gran ventaja de DokuWiki es que es relativamente ligero y puede ejecutarse en un servidor que ya esté ejecutando otros servicios, siempre que se disponga de espacio y memoria.

## Instalar dependencias

La versión mínima de PHP para DokuWiki es 7.2, que es exactamente la misma que se incluye con Rocky Linux 8. Rocky Linux 9.0 viene con la versión 8.0 de PHP, que también es totalmente compatible. Aquí se especifican paquetes que pueden estar ya instalados:

`dnf install tar wget httpd php php-gd php-xml php-json php-mbstring`

Verá una lista de dependencias adicionales que se instalarán y este aviso:

`Is this ok [y/N]:`

Continue y responda con "y" y pulse 'Entrar' para instalar.

## Crear directorios y modificar la configuración

### Configuración de Apache

Si ha leído el procedimiento [Apache Sites Enabled](../web/apache-sites-enabled.md), sabe que necesitamos crear algunos directorios. Comenzaremos con las adiciones al directorio de configuración _httpd_:

`mkdir -p p/httpd/{sites-available,sites-enabled}`

Necesitamos editar el archivo httpd.conf:

`vi /etc/httpd/conf/httpd.conf`

Y añada esto al final del archivo:

`Include /etc/httpd/sites-enabled`

Cree el archivo de configuración del sitio en la carpeta sites-available:

`vi /etc/httpd/sites-available/com.yourdomain.wiki-doc`

Ese archivo de configuración debería ser algo así:

```
<VirtualHost *>
    ServerName    wiki-doc.yourdomain.com
    DocumentRoot  /var/www/sub-domains/com.yourdomain.wiki-doc/html

    <Directory ~ "/var/www/sub-domains/com.yourdomain.wiki-doc/html/(bin/|conf/|data/|inc/)">
        <IfModule mod_authz_core.c>
                AllowOverride All
            Require all denied
        </IfModule>
        <IfModule !mod_authz_core.c>
            Order allow,deny
            Deny from all
        </IfModule>
    </Directory>

    ErrorLog   /var/log/httpd/wiki-doc.yourdomain.com_error.log
    CustomLog  /var/log/httpd/wiki-doc.yourdomain_access.log combined
</VirtualHost>
```

Tenga en cuenta que la opción "AllowOverride All" incluido más arriba, permite que el archivo .htaccess (seguridad específica del directorio) funcione.

Continue y enlace el archivo de configuración en sites-enabled, pero todavía no inicie los servicios web:

`ln -s /etc/httpd/sites-available/com.yourdomain.wiki-doc /etc/httpd/sites-enabled/`

### Apache DocumentRoot

También necesitamos crear nuestro _DocumentRoot_. Para hacer esto:

`mkdir -p /var/www/sub-domains/com.yourdomain.wiki-doc/html`

## Instalar DokuWiki

En su servidor, cambie al directorio raíz.

`cd /root`

Ahora que tenemos nuestro entorno listo para empezar, vamos a obtener la última versión estable de DokuWiki. Puedes encontrarla yendo a [la página de descargas](https://download.dokuwiki.org/) y en la parte izquierda de la página en la sección "Version" podrá ver "Stable (Recommended) (direct link)."

Haga clic derecho en la parte "(direct link)" y copie la dirección del enlace. En la consola de su servidor DokuWiki, escribe "wget", un espacio y pégue el enlace que ha copiado en el terminal. Debería ver algo como esto:

`wget https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz`

Antes de descomprimir el archivo, eche un vistazo a su contenido utiliznado el comando `tar ztf` para ver el contenido del archivo:

`tar ztvf dokuwiki-stable.tgz`

¿Ve el directorio con la fecha delante de los demás archivos?

```
... (more above)
dokuwiki-2020-07-29/inc/lang/fr/resetpwd.txt
dokuwiki-2020-07-29/inc/lang/fr/draft.txt
dokuwiki-2020-07-29/inc/lang/fr/recent.txt
... (more below)
```
No queremos ese directorio con nombre inicial al descomprimir el archivo, así que vamos a utilizar algunas opciones de `tar` para excluirlo. La primera opción es "--strip-components=1" que elimina ese directorio inicial.

La segunda opción es la opción "-C", y que le indica al comando `tar` dónde queremos que se descomprima el archivo. Así que descomprima el archivo con siguiente comando:

`tar xzf dokuwiki-stable.tgz --strip-components=1 -C /var/www/sub-domains/com.yourdomain.wiki-doc/html/`

Una vez que hayamos ejecutado este comando, DokuWiki debería descomprimido estar en nuestro _DocumentRoot_.

Necesitamos hacer una copia del archivo_.htaccess.dist _ que viene con DokuWiki y mantener el antiguo allí también, en caso de que tengamos que volver al contenido original en un futuro.

En el proceso, cambiaremos el nombre de este archivo a _. htaccess_ que es lo que _Apache_ buscará. Para hacer esto:

`cp /var/www/sub-domains/com.yourdomain.wiki-doc/html/.htaccess{.dist,}`

Ahora necesitamos cambiar el propietario del nuevo directorio y sus archivos al usuario y grupo _apache_:

`chown -Rf apache.apache /var/www/sub-domains/com.yourdomain.wiki-doc/html`

## Configurar DNS o /etc/hosts

Antes de poder acceder a la interfaz de DokuWiki, necesitará establecer la resolución de nombres para este sitio. Con fines de prueba, puede utilizar su archivo _/etc/hosts_.

En este ejemplo, vamos a suponer que DokuWiki se ejecutará en la dirección IPv4 privada 10.56.233.179. Supongamos también que está modificando el archivo _/etc/hosts_ en una estación de trabajo Linux. Para hacer esto, ejecute:

`sudo vi /etc/hosts`

Y luego modifique su archivo de hosts para que se vea tal y como se muestra a continuación (vea la dirección IP anterior en el ejemplo que se muestra a continuación):

```
127.0.0.1   localhost
127.0.1.1   myworkstation-home
10.56.233.179   wiki-doc.yourdomain.com     wiki-doc

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

Una vez que ha terminado de probar y esté listo para poner docuwiki en producción y disponible para todos, necesitará agregar este host a un servidor DNS. Puede hacer esto utilizando un [servidor DNS privado](../dns/private_dns_server_using_bind.md)o un servidor DNS público.

## Iniciar httpd

Antes de comenzar _httpd_ vamos a probar para asegurarnos de que nuestra configuración está aceptada:

`httpd -t`

Debería obtener:

`Syntax OK`

Si es así, debería estar listo para iniciar _httpd_ y luego finalizar la configuración. Empecemos activando _httpd_ para que se inicie al arrancar el sistema:

`systemctl enable httpd`

Y luego iniciar el servicio:

`systemctl start httpd`

## Probar DokuWiki

Ahora que nuestro nombre de host está configurado para las pruebas y el servicio web se ha iniciado, el siguiente paso es abrir un navegador web y escribir la siguiente URL en la barra de direcciones:

`http://wiki-doc/install.php`

O

`http://wiki-doc.yourdomain.com/install.php`

Cualquiera de los dos debería funcionar si se configura el archivo de hosts como se indica más arriba. Esto le llevará a la pantalla de configuración para que pueda terminar la configuración:

* En el campo "Wiki Name", escriba el nombre del wiki. Por ejemplo, "Documentación Técnica"
* En el campo "Superuser", escriba el nombre de usuario administrador. Ejemplo "admin"
* En el campo "Nombre real", escriba el nombre real para el usuario administrativo.
* En el campo "E-Mail", escriba la dirección de correo electrónico del usuario administrador.
* En el campo "Password", escriba una contraseña segura para el usuario administrador.
* En el campo "una vez más", vuelva a escribir la misma contraseña.
* En el menú desplegable "Initial ACL Policy", elija la opción que mejor funcione para su entorno.
* Elija la casilla de verificación apropiada para la licencia bajo la que desea poner su contenido.
* Deje marcada (o desmarque si lo prefiere) la casilla "Once a month, send anonymous usage data to the DokuWiki developers"
* Haga clic en el botón "Guardar"

Ahora su wiki está preparado para que añada contenido.

## Asegurar DokuWiki

Además de la política ACL que acaba de crear, considere:

### Su cortafuegos

!!! note

    Ninguno de estos ejemplos de cortafuegos hace ningún tipo de suposición sobre qué otros servicios podrías necesitar permitir en tu servidor Dokuwiki. Estas reglas se basan en nuestro entorno de pruebas y **SOLO** se ocupan de permitir el acceso a un bloque ip de la red LOCAL. Necesitará más servicios permitidos para un servidor de producción.

Antes de decir que todo está hecho, hay que pensar en la seguridad. Primero, debería estar ejecutando un cortafuegos en el servidor. Supondremos que está utilizando uno de los cortafuegos indicado más abajo.

En lugar de permitir que todo el mundo tenga acceso al wiki, vamos a suponer que cualquier persona de la red 10.0.0.0/8 está en su red de área local privada, y que esas son las únicas personas que necesitan acceder al sitio.

#### Cortafuegos `iptables` (obsoleto)

!!! important

    El proceso de cortafuegos `iptables` ha quedado obsoleto en Rocky Linux 9.0 (todavía está disponible, pero es probable que desaparezca en futuras versiones, quizás ya en Rocky Linux 9.1). Por esta razón, le recomendamos saltar al procedimiento `firewalld` mas abajo si estás siguiendo esta docuemntación conRocky Linux 9.0 o posterior.

Tenga en cuenta que puede que necesite otras reglas para el resto de servicios en este servidor, y que en este ejemplo sólo se tienen en cuenta los servicios web.

En primer lugar, modifique o cree el archivo _/etc/firewall.conf_:

`vi /etc/firewall.conf`

```
#IPTABLES=/usr/sbin/iptables

#  Unless specified, the defaults for OUTPUT is ACCEPT
#    The default for FORWARD and INPUT is DROP
#
echo "   clearing any existing rules and setting default policy.."
iptables -F INPUT
iptables -P INPUT DROP
# web ports
iptables -A INPUT -p tcp -m tcp -s 10.0.0.0/8 --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp -s 10.0.0.0/8 --dport 443 -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable

/usr/sbin/service iptables save
```

Una vez que ha creado el script, asegúrese de que es ejecutable:

`chmod +x /firewall.conf`

Luego ejecuta el script:

`/etc/firewall.conf`

Esto ejecutará las reglas y las guardará para que sea recarguen en el próximo inicio de _iptables_ o al próximo arranque del sistema.

#### Cortafuegos `firewalld`

Si utiliza `firewalld` como cortafuegos (y a estas alturas, probablemente *debería*) puede aplicar los mismos conceptos utilizando la sintaxis de `firewalld's firewall-cmd`.

Vamos a duplicar las reglas `iptables` (arriba) con `firewalld` reglas:

```
firewall-cmd --zone=confiable --add-source=10.0.0.0/8 --permanent
firewall-cmd --zone=confiable --add-service=http --add-service=https --permanent
firewall-cmd --reload
```

Una vez que ha añadido las reglas anteriores y ha recargado el servicio firewalld, liste su zona para asegurarse de que todo lo que necesita está ahí:

```
firewall-cmd --zone=trusted --list-all
```

que debería mostrarte algo así si todo lo anterior ha funcionado correctamente:

```
trusted (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces: 
  sources: 10.0.0.0/8
  services: http https
  ports: 
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules:
```

### SSL

Para tener más seguridad, debería considerar el uso de un SSL para que todo el tráfico web esté cifrado. Puede comprar un certificado SSL directamente de un proveedor o utilizar [Let's Encrypt](../security/generating_ssl_keys_lets_encrypt.md)

## Conclusión

Ya sea que necesites documentar procesos, políticas de la empresa, códigos de programas o cualquier otra cosa, un wiki es una gran manera de hacerlo. DokuWiki es un producto seguro, flexible, fácil de usar, relativamente fácil de instalar y desplegar, y es un proyecto estable que ha existido durante muchos años.  
