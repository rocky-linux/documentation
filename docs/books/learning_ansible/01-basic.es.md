---
title: Conceptos básicos de Ansible
author: Antoine Le Morvan
contributors: Steven Spencer, tianci li, Pedro Garcia
update: 15-Dec-2021
---

# Conceptos básicos de Ansible

En este capítulo aprenderá cómo trabajar con Ansible.

****

**Objetivos**: En este capítulo aprenderá a:

:heavy_check_mark: Implementar Ansible;
:heavy_check_mark: Aplicar cambios sobre la configuración en un servidor;
:heavy_check_mark: Crear los primeros playbooks de Ansible;

:checkered_flag: **ansible**, **modulo**, **playbook**

**Conocimiento**: :star: :star: :star:
**Complejidad**: :star: :star:

**Tiempo de lectura**: 30 minutos

****

Ansible se encarga de centralizar y automatizar las tareas de administración. Es una herramienta:

* **sin agentes** (no es necesario hacer despliegues específicos en los clientes),
* **idempotente** (mismo resultado cada vez que se ejecuta)

Utiliza el protocolo **SSH** para configurar remotamente los clientes Linux o el protocolo **WinRM** para trabajar con clientes Windows. Si no se dispone de ninguno de estos protocolos, siempre es posible que Ansible utilice una API, lo que lo convierte en una auténtica navaja suiza para la configuración de servidores, estaciones de trabajo, servicios Docker, equipos de red, etc. (De hecho, casi todo).

!!! Warning

    La apertura de flujos SSH o WinRM a todos los clientes desde el servidor de Ansible, lo convierte en un elemento crítico de la arquitectura que debe ser cuidadosamente supervisado.

Como Ansible está basado en push, no mantendrá el estado de sus servidores entre cada una de sus ejecuciones. Todo lo contrario, Ansible realizará nuevas comprobaciones de estado cada vez que se ejecute. Se dice que no tiene estado.

Le ayudará con:

* el aprovisionamiento (despliegue de una nueva VM),
* el despliegue de aplicaciones,
* la gestión de la configuración,
* la automatización,
* la orquestación (cuando se utiliza más de un objetivo).

!!! Note

    Ansible fue escrito originalmente por Michael DeHaan, fundador de otras herramientas como Cobbler.

    ![Michael DeHaan](images/Michael_DeHaan01.jpg)

    La primera versión fue la 0.0.1, publicada el 9 de marzo de 2012.

    El 17 de octubre de 2015, AnsibleWorks (la empresa detrás de Ansible) fue adquirida por Red Hat por 150 millones de dólares.

![Características de Ansible](images/ansible-001.png)

Para ofrecer una interfaz gráfica a su uso diario de Ansible, puede instalar algunas herramientas como Ansible Tower (RedHat), que no es gratuita, su homólogo opensource Awx, también puede utilizar otros proyectos como Jenkins o el excelente Rundeck.

!!! Abstract

    Para seguir esta guia, necesitará al menos 2 servidores ejecutando Rocky8:

    * la primera será la **máquina de gestión**, en ella se instalará Ansible.
    * la segunda será el servidor a configurar y administrar (otro servidor con una versión de Linux distinta a Rocky Linux será igual de valida).

    En los ejemplos siguientes, la máquina de gestión tendrá la dirección IP 172.16.1.10 y la estación gestionada tendrá la 172.16.1.11. Es usted quien debe adaptar los ejemplos según su plan de direccionamiento IP.

## El vocabulario de Ansible

* La **máquina de gestión**: La máquina en la que está instalado Ansible. Dado que Ansible es una herramienta **sin agente**, no despliega ningún software en los servidores gestionados.
* El **inventario**: Es un archivo que contiene información sobre los servidores gestionados.
* Las **tareas**: una tarea es un bloque que define un procedimiento a ejecutar (por ejemplo, crear un usuario o un grupo, instalar un paquete de software, etc.).
* Un **módulo**: un módulo abstrae una tarea. Ansible le proporciona muchos módulos.
* Los ** libros de jugadas **: un archivo simple en formato yaml que define los servidores de destino y las tareas a realizar.
* Un **rol**: Un rol permite organizar los playbooks y todos los demás archivos necesarios (plantillas, scripts, etc.) para facilitar la compartición y reutilización del código.
* Una **colección**: Una colección es un conjunto lógico de playbooks, roles, módulos y plugins.
* Las **hechos**: Son variables globales que contienen información sobre el sistema (nombre de la máquina, versión del sistema, interfaz de red y configuración, etc.).
* Los **manejadores**: Se utilizan para hacer que un servicio se detenga o se reinicie en caso de cambio.

## Instalación en el servidor de gestión

Ansible está disponible en el repositorio _EPEL_ pero viene como versión 2.9.21, la cual es bastante antigua. Puede ver cómo se hace siguiendo este procedimiento, pero sáltese los pasos de instalación, ya que vamos a instalar la última versión. _EPEL_ es necesario para ambas versiones, así que puedes seguir adelante e instalarlo ahora:

* Instalación de EPEL:

```
$ sudo dnf install epel-release
```
Si estuviésemos instalando Ansible desde el _EPEL_ podríamos hacer lo siguiente:

```
$ sudo dnf install ansible
$ ansible --version
2.9.21
```
Como queremos utilizar una versión más reciente de Ansible, la instalaremos desde `python3-pip`:

!!! Note

    Elimine Ansible si lo ha instalado previamente desde _EPEL_.

```
$ sudo dnf install python38 python38-pip python38-wheel python3-argcomplete rust cargo curl
```

!!! Note

    `python3-argcomplete` es proporcionado por _EPEL_. Por favor, instale epel-release si aún no lo ha hecho.
    Este paquete le ayudará a completar los comandos Ansible.

Antes de instalar Ansible, necesitamos indicarle a Rocky Linux que queremos utilizar la nueva versión de Python. La razón es que si continuamos con la instalación sin hacer esta configuración, la versión por defecto de Python3 (versión 3.6 en el momento de escribir este documento), se utilizará en lugar de la nueva versión 3.8. Establezca la versión que desea utilizar introduciendo el siguiente comando:

```
sudo alternatives --set python /usr/bin/python3.8
sudo alternatives --set python3 /usr/bin/python3.8
```

Ahora podemos instalar Ansible:

```
$ sudo pip3 install ansible
$ sudo activate-global-python-argcomplete
```

Compruebe su versión de Ansible:

```
$ ansible --version
ansible [core 2.11.2]
  config file = None
  configured module search path = ['/home/ansible/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/lib/python3.8/site-packages/ansible
  ansible collection location = /home/ansible/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/local/bin/ansible
  python version = 3.8.6 (default, Jun 29 2021, 21:14:45) [GCC 8.4.1 20200928 (Red Hat 8.4.1-1)]
  jinja version = 3.0.1
  libyaml = True
```

## Archivos de configuración

La configuración del servidor se encuentra en `/etc/ansible`.

Hay dos archivos de configuración principales:

* El archivo de configuración principal `ansible.cfg` es donde residen los comandos, módulos, plugins y la configuración de ssh;
* El fichero de inventario de gestión de máquinas cliente `hosts` es el lugar donde se declaran los clientes y los grupos de clientes.

Como hemos instalado Ansible con `pip`, esos archivos no existen. Tendremos que crearlos a mano.

[Aquí](https://github.com/ansible/ansible/blob/devel/examples/ansible.cfg) se proporciona un ejemplo del archivo `ansible.cfg` y un ejemplo del archivo `hosts` [aquí](https://github.com/ansible/ansible/blob/devel/examples/hosts).

```
$ sudo mkdir /etc/ansible
$ sudo curl -o /etc/ansible/ansible.cfg https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg
$ sudo curl -o /etc/ansible/hosts https://raw.githubusercontent.com/ansible/ansible/devel/examples/hosts
```

También puede utilizar el comando `ansible-config` para generar un nuevo archivo de configuración:

```
usage: ansible-config [-h] [--version] [-v] {list,dump,view,init} ...

Ver la configuración de Ansible.

positional arguments:
  {list,dump,view,init}
    list                Print all config options
    dump                Dump configuration
    view                View configuration file
    init                Create initial configuration
```

Ejemplo:

```
ansible-config init --disabled > /etc/ansible/ansible.cfg
```

La opción `--disabled` permite comentar un conjunto de opciones anteponiendo un `;`.

### El archivo de inventario `/etc/ansible/hosts`

Como Ansible tendrá que trabajar con todos sus equipos para ser configurado, es muy importante proporcionar uno (o más) archivos de inventario bien estructurados, que se ajusten perfectamente a su organización.

A veces es necesario pensar detenidamente en cómo construir este archivo.

Vaya al archivo de inventario por defecto, que se encuentra en `is/ansible/hosts`. En este fichero, se proporcionan y comentan algunos ejemplos:

```
# This is the default ansible 'hosts' file.
#
# It should live in /etc/ansible/hosts
#
#   - Comments begin with the '#' character
#   - Blank lines are ignored
#   - Groups of hosts are delimited by [header] elements
#   - You can enter hostnames or ip addresses
#   - A hostname/ip can be a member of multiple groups

# Ex 1: Ungrouped hosts, specify before any group headers:

## green.example.com
## blue.example.com
## 192.168.100.1
## 192.168.100.10

# Ex 2: A collection of hosts belonging to the 'webservers' group:

## [webservers]
## alpha.example.org
## beta.example.org
## 192.168.1.100
## 192.168.1.110

# If you have multiple hosts following a pattern, you can specify
# them like this:

## www[001:006].example.com

# Ex 3: A collection of database servers in the 'dbservers' group:

## [dbservers]
##
## db01.intranet.mydomain.net
## db02.intranet.mydomain.net
## 10.25.1.56
## 10.25.1.57

# Here's another example of host ranges, this time there are no
# leading 0s:

## db-[99:101]-node.example.com
```

Como puede ver, el archivo proporcionado como ejemplo utiliza el formato INI, que es bien conocido por los administradores de sistemas. Por favor, ten en cuenta que puede elegir otro formato de archivo (como yaml, por ejemplo), pero para las primeras pruebas, el formato INI se adapta bien a nuestros ejemplos.

Obviamente, en un entorno de producción, se puede generar automáticamente el inventario, especialmente si se dispone de un entorno de virtualización como VMware VSphere o un entorno de computación en la nube (Aws, Openstack u otros).

* Crear un grupo de hosts en `/etc/ansible/hosts`:

Como puede haber notado, los grupos se declaran entre corchetes. Luego vienen los elementos que pertenecen a los grupos. Puede crear, por ejemplo, un grupo `rocky8` insertando el siguiente bloque de código en este archivo:

```
[rocky8]
172.16.1.10
172.16.1.11
```

Los grupos se pueden utilizar dentro de otros grupos. En este caso, debe especificarse que el grupo principal está compuesto por subgrupos mediante el uso del atributo `:chidren` tal y como se muestra en el siguiente ejemplo:

```
[linux:children]
rocky8
debian9

[ansible:children]
ansible_management
ansible_clients

[ansible_management]
172.16.1.10

[ansible_clients]
172.16.1.10
```

Por el momento no vamos a ir más lejos en el tema del inventario, pero si está interesado, considere revisar el siguiente [enlace](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html).

Ahora que nuestro servidor de administración está instalado y nuestro inventario está listo, es hora de ejecutar nuestros primeros comandos `ansible`.

## Uso de la línea de comandos de `ansible`

El comando `ansible` lanza una tarea en uno o más hosts de destino.

```
ansible <host-pattern> [-m module_name] [-a args] [options]
```

Ejemplos:

!!! Warning

    Como todavía no hemos configurado la autenticación en nuestros 2 servidores de prueba, es posible que alguno de los ejemplos que se muestran a continuación no funcionen. Estos se dan como ejemplos para facilitar la comprensión, y serán completamente funcionales más adelante en este mismo capítulo.

* Enumera los hosts que pertenecen al grupo rocky8:

```
ansible rocky8 --list-hosts
```

* Hacer ping a un grupo de hosts con el módulo `ping`:

```
ansible rocky8 -m setup
```

* Mostrar los datos obtenidos desde un grupo de servidores utiliznaod el módulo `setup`:

```
ansible rocky8 -m setup
```

* Ejecutar un comando en un grupo de hosts invocando el módulo `command` con argumentos:

```
ansible rocky8 -m command -a 'uptime'
```

* Ejecutar un comando con permisos de administración:

```
ansible rocky8 -m command -a 'uptime'
```

* Ejecutar un comando utilizando un archivo de inventario personalizado:

```
ansible rocky8 -i ./local-inventory -m command -a 'date'
```

!!! Note

    Al igual que en este ejemplo, a veces es más sencillo separar la declaración de los dispositivos gestionados en varios archivos (por proyecto, por ejemplo) y proporcionar a Ansible la ruta a estos archivos, en lugar de mantener un único archivo de inventario.

| Opción                  | Información                                                                                          |
| ----------------------- | ---------------------------------------------------------------------------------------------------- |
| `-a 'argumentos'`       | Los argumentos que se pasan al módulo.                                                               |
| `-b -K`                 | Solicita una contraseña y ejecuta el comando con los privilegios más altos.                          |
| `--user=usuario`        | Utiliza el usuario indicado para conectarse al host de destino en vez de utilizar el usuario actual. |
| `--become-user=usuario` | Ejecuta la operación como el usuario indicado (por defecto: `root`).                                 |
| `-C`                    | Simulación. No realiza ningún cambio en el objetivo, sino que lo prueba para ver qué debe cambiar.   |
| `-m modulo`             | Ejecuta el módulo indicado.                                                                          |

### Preparando el cliente

Tanto en la máquina de gestión como en los clientes, crearemos un usuario `ansible` dedicado a las operaciones realizadas por Ansible. Este usuario tendrá que tener permisos de sudo, por lo que tendrá que ser añadido al grupo `wheel`.

Este usuario será usado:

* En la estación de administración: para ejecutar comandos`ansible` y ssh en los clientes administrados.
* En las estaciones administradas (aquí el servidor que sirve como estación de administración también sirve como cliente, para que sea administrado por sí mismo) para ejecutar los comandos lanzados desde la estación de administración: por lo tanto debe tener permisos de sudo.

En ambas máquinas, cree un usuario `ansible`:

```
$ sudo useradd ansible
$ sudo usermod -aG wheel ansible
```

Establecer una contraseña para este usuario:

```
$ sudo passwd ansible
```

Modifique la configuración de los sudoers para permitir a los miembros del grupo `wheel` hacer sudo sin la necesidad de introducir una contraseña:

```
$ sudo visudo
```

Nuestro objetivo es comentar el valor predeterminado, y descomentar la opción NOPASSWD para que estas líneas se vean así cuando hayamos terminado:

```
## Allows people in group wheel to run all commands
# %wheel  ALL=(ALL)       ALL

## Same thing without a password
%wheel        ALL=(ALL)       NOPASSWD: ALL
```

!!! Warning

    Si recibe el siguiente mensaje de error al introducir comandos de Ansible, probablemente significa que olvidó realizar este paso en uno de sus clientes:
    `"msg": "Missing sudo password`

Cuando utilice la gestión a partir de este momento, comience a trabajar con este nuevo usuario:

```
$ sudo su - ansible
```

### Probar con el módulo ping

Por defecto Ansible no permite el inicio de sesión con contraseña.

Descomente la siguiente línea situada en la sección `[defaults]` dentro del archivo de configuración `/etc/ansible/ansible.cfg` y establézcala a True:

```
ask_pass      = True
```

Ejecute el `ping` en cada servidor del grupo rocky8:

```
# ansible rocky8 -m ping
SSH password:
172.16.1.10 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
172.16.1.11 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

!!! Note

    Se le pide la contraseña `ansible` de los servidores remotos, lo cual es un problema de seguridad...

!!! Tip

    Si obtiene el error `"msg": "para utilizar el tipo de conexión 'ssh' con contraseña, debe instalar el programa sshpass"`, puede instalar `sshpass` en la estación de administración:

    ```
    $ sudo dnf install sshpass
    ```

!!! Abstract

    Ahora puede probar los comandos que no funcionaban previamente en este capítulo.

## Autenticación mediante claves

La autenticación por contraseña será reemplazada por una autenticación de clave privada/pública mucho más segura.

### Crear una clave SSH

La clave dual se generará con el comando `ssh-keygen` en la estación de gestión por el usuario `ansible`:

```
[ansible]$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/ansible/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/ansible/.ssh/id_rsa.
Your public key has been saved in /home/ansible/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:Oa1d2hYzzdO0e/K10XPad25TA1nrSVRPIuS4fnmKr9g ansible@localhost.localdomain
The key's randomart image is:
+---[RSA 3072]----+
|           .o . +|
|           o . =.|
|          . . + +|
|         o . = =.|
|        S o = B.o|
|         = + = =+|
|        . + = o+B|
|         o + o *@|
|        . Eoo .+B|
+----[SHA256]-----+

```

La clave pública se puede copiar a los servidores:

```
# ssh-copy-id ansible@172.16.1.10
# ssh-copy-id ansible@172.16.1.11
```

Vuelva a comentar la siguiente línea de la sección `[defaults]` en el archivo de configuración `/etc/ansible/ansible.cfg` para evitar la autenticación por contraseña:

```
#ask_pass      = True
```

### Prueba de autenticación mediante clave privada

Para la siguiente prueba, se utiliza el módulo `shell` , permitiendo la ejecución de comandos remotos:

```
# ansible rocky8 -m shell -a "uptime"
172.16.1.10 | SUCCESS | rc=0 >>
 12:36:18 up 57 min,  1 user,  load average: 0.00, 0.00, 0.00

172.16.1.11 | SUCCESS | rc=0 >>
 12:37:07 up 57 min,  1 user,  load average: 0.00, 0.00, 0.00
```

No se necesita contraseña, ¡la autenticación mediante clave privada/pública funciona!

!!! Note

    En el entorno de producción, ahora debe eliminar las contraseñas `ansible` establecidas anteriormente para reforzar su seguridad (ya que ahora no es necesaria una contraseña de autenticación).

## Utilizar Ansible

Puede utilizar Ansible desde el intérprete de comandos o a través de libros de jugadas.

### Los módulos

La lista de módulos clasificados por categoría puede encontrarse [aquí](https://docs.ansible.com/ansible/latest/collections/index_module.html). ¡Ansible ofrece más de 750!

Los módulos se agrupan ahora en colecciones, cuya lista puede [encontrarse aquí](https://docs.ansible.com/ansible/latest/collections/index.html).

Las colecciones son un formato de distribución para contenido de Ansible que puede incluir playbooks, roles, módulos y plugins.

Un módulo se invoca con la opción `-m` del comando `ansible`:

```
ansible <host-pattern> [-m module_name] [-a args] [options]
```

Hay un módulo para casi cualquier necesidad. Por lo tanto, en lugar de utilizar el módulo shell, se recomienda buscar un módulo adaptado a esta necesidad.

Cada categoría de necesidad tiene su propio módulo. Aquí hay una lista no exhaustiva:

| Tipo                             | Ejemplos                                                        |
| -------------------------------- | --------------------------------------------------------------- |
| Administración del sistema       | `user` (gestión de usuarios), `group` (gestión de grupos), etc. |
| Administración de software       | `dnf`,`yum`, `apt`, `pip`, `npm`                                |
| Gestión de archivos              | `copy`, `fetch`, `lineinfile`, `template`, `archive`            |
| Administración de bases de datos | `mysql`, `postgresql`, `redis`                                  |
| Gestión de la nube               | `amazon S3`, `cloudstack`, `openstack`                          |
| Gestión del clúster              | `consul`, `zookeeper`                                           |
| Enviar comandos                  | `shell`, `script`, `expect`                                     |
| Descargas                        | `get_url`                                                       |
| Gestión de código                | `git`, `gitlab`                                                 |

#### Ejemplo de instalación de software

El módulo `dnf` permite la instalación de software en los clientes de destino:

```
# ansible rocky8 --become -m dnf -a name="httpd"
172.16.1.10 | SUCCESS => {
    "changed": true,
    "msg": "",
    "rc": 0,
    "results": [
      ...
      \n\nComplete!\n"
    ]
}
172.16.1.11 | SUCCESS => {
    "changed": true,
    "msg": "",
    "rc": 0,
    "results": [
      ...
    \n\nComplete!\n"
    ]
}
```

Siendo el software instalado un servicio, ahora es necesario iniciarlo con el módulo `systemd`:

```
# ansible rocky8 --become  -m systemd -a "name=httpd state=started"
172.16.1.10 | SUCCESS => {
    "changed": true,
    "name": "httpd",
    "state": "started"
}
172.16.1.11 | SUCCESS => {
    "changed": true,
    "name": "httpd",
    "state": "started"
}
```

!!! Tip

    Intente ejecutar estos últimos dos comandos, dos veces. Observará que la primera vez, Ansible realizará acciones para alcanzar el estado establecido por el comando. La segunda vez, ¡no hará nada porque habrá detectado que ya se ha alcanzado el estado!

### Ejercicios

Para ayudarle a descubrir más sobre Ansible y acostumbrarse a buscar en su documentació, aquí encontrará algunos ejercicios que puede hacer antes de continuar:

* Crear los grupos París, Tokio, NewYork
* Crear el usuario `supervisor`
* Cambia el usuario para que tenga un uid de 10000
* Cambiar el usuario para que pertenezca al grupo París
* Instalar el software tree
* Detener el servicio de crond
* Crear un archivo vacío con permisos `0644`
* Actualizar su distribución
* Reinciar su cliente

!!! Warning

    No utilice el módulo shell. ¡Busque en la documentación los módulos apropiados!

#### Modulo `setup`: Introducción a los hechos

Los datos del sistema son variables recuperadas por Ansible a través de su módulo `setup`.

Eche un vistazo a los diferentes datos de sus clientes para hacerse una idea de la cantidad de información que se puede recuperar fácilmente a través de un simple comando.

Más adelante veremos cómo utilizar los datos obtenidos desde los clientes en nuestros playbooks y cómo crear nuestros propios datos.

```
# ansible ansible_clients -m setup | less
192.168.1.11 | SUCCESS => {
    "ansible_facts": {
        "ansible_all_ipv4_addresses": [
            "192.168.1.11"
        ],
        "ansible_all_ipv6_addresses": [
            "2001:861:3dc3:fcf0:a00:27ff:fef7:28be",
            "fe80::a00:27ff:fef7:28be"
        ],
        "ansible_apparmor": {
            "status": "disabled"
        },
        "ansible_architecture": "x86_64",
        "ansible_bios_date": "12/01/2006",
        "ansible_bios_vendor": "innotek GmbH",
        "ansible_bios_version": "VirtualBox",
        "ansible_board_asset_tag": "NA",
        "ansible_board_name": "VirtualBox",
        "ansible_board_serial": "NA",
        "ansible_board_vendor": "Oracle Corporation",
        ...
```

Ahora que hemos visto cómo configurar un servidor remoto con Ansible mediante la línea de comandos, podremos introducir el concepto de playbook. Los playbooks no son más que otra forma de utilizar Ansible, que no es mucho más compleja, pero que facilitará la reutilización del código.

## Playbooks

Los playbooks de Ansible describen una política que se aplica a los sistemas remotos, para forzar su configuración. Los playbooks se escriben en un formato de texto fácilmente comprensible que agrupa un conjunto de tareas: el formato `yaml`.

!!! Note

    Aprenda más sobre yaml [aquí](https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html)

```
ansible-playbook <file.yml> ... [options]
```

Las opciones son idénticas a las del comando `ansible`.

El comando devuelve los siguientes códigos de error:

| Código | Error                                  |
| ------ | -------------------------------------- |
| `0`    | OK o no hay servidores coincidentes    |
| `1`    | Error                                  |
| `2`    | Uno o más servidores estan fallando    |
| `3`    | Uno o más servidores son inalcanzables |
| `4`    | Error de análisis                      |
| `5`    | Opciones malas o incompletas           |
| `99`   | Ejecución interrumpida por el usuario  |
| `250`  | Error inesperado                       |

!!! Note

    ¡Tenga en cuenta que Ansible devolverá Ok cuando no haya ningún host que coincida con su objetivo, lo que podría inducirle a error!

### Ejemplo de playbook de Apache y MySQL

El siguiente playbook nos permite instalar Apache y MariaDB en nuestros servidores de destino.

Cree un archivo `test.yml` con el siguiente contenido:

```
---
- hosts: rocky8 <1>
  become: true <2>
  become_user: root

  tasks:

    - name: ensure apache is at the latest version
      dnf: name=httpd,php,php-mysqli state=latest

    - name: ensure httpd is started
      systemd: name=httpd state=started

    - name: ensure mariadb is at the latest version
      dnf: name=mariadb-server state=latest

    - name: ensure mariadb is started
      systemd: name=mariadb state=started
...
```

* <1> El grupo o el servidor en cuestión debe existir en el inventario
* <2> Una vez conectado, el usuario se convierte `root` (a través de `sudo` por defecto)

La ejecución del playbook se realiza mediante el comando `ansible-playbook`:

```
$ ansible-playbook test.yml

PLAY [rocky8] ****************************************************************

TASK [setup] ******************************************************************
ok: [172.16.1.10]
ok: [172.16.1.11]

TASK [ensure apache is at the latest version] *********************************
ok: [172.16.1.10]
ok: [172.16.1.11]

TASK [ensure httpd is started] ************************************************
changed: [172.16.1.10]
changed: [172.16.1.11]

TASK [ensure mariadb is at the latest version] **********************************
changed: [172.16.1.10]
changed: [172.16.1.11]

TASK [ensure mariadb is started] ***********************************************
changed: [172.16.1.10]
changed: [172.16.1.11]

PLAY RECAP *********************************************************************
172.16.1.10             : ok=5    changed=3    unreachable=0    failed=0
172.16.1.11             : ok=5    changed=3    unreachable=0    failed=0
```

Para una mayor legibilidad, se recomienda escribir los playbooks en formato yaml completo. En el ejemplo anterior, los argumentos se dan en la misma línea que el módulo, el valor del argumento siguiendo su nombre separado por un `=`. Mira el mismo playbook en yaml completo:

```
---
- hosts: rocky8
  become: true
  become_user: root

  tasks:

    - name: ensure apache is at the latest version
      dnf:
        name: httpd,php,php-mysqli
        state: latest

    - name: ensure httpd is started
      systemd:
        name: httpd
        state: started

    - name: ensure mariadb is at the latest version
      dnf:
        name: mariadb-server
        state: latest

    - name: ensure mariadb is started
      systemd:
        name: mariadb
        state: started
...
```

!!! Tip

    `dnf` es uno de los módulos que permiten pasarle una lista como argumento.

Nota sobre las colecciones: Ahora Ansible proporciona módulos en forma de colecciones. Algunos módulos se proporcionan por defecto dentro de la colección `ansible.builtin`, otros se deben instalar manualmente a través de la función:

```
ansible-galaxy collection install [collectionname]
```
donde [collectionname] es el nombre de la colección (aquí los corchetes se utilizan para resaltar la necesidad de reemplazar el texto contenido entre ellos por un nombre de colección real, NO son parte del comando).

El ejemplo anterior debería escribirse así:

```
- hosts: rocky8
  become: true
  become_user: root

  tasks:

    - name: ensure apache is at the latest version
      ansible.builtin.dnf:
        name: httpd,php,php-mysqli
        state: latest

    - name: ensure httpd is started
      ansible.builtin.systemd:
        name: httpd
        state: started

    - name: ensure mariadb is at the latest version
      ansible.builtin.dnf:
        name: mariadb-server
        state: latest

    - name: ensure mariadb is started
      ansible.builtin.systemd:
        name: mariadb
        state: started
...
```

Un playbook no se limita únicamente a un solo objetivo:

```
---
- hosts: webservers
  become: true
  become_user: root

  tasks:

    - name: ensure apache is at the latest version
      ansible.builtin.dnf:
        name: httpd,php,php-mysqli
        state: latest

    - name: ensure httpd is started
      ansible.builtin.systemd:
        name: httpd
        state: started

- hosts: databases
  become: true
  become_user: root

    - name: ensure mariadb is at the latest version
      ansible.builtin.dnf:
        name: mariadb-server
        state: latest

    - name: ensure mariadb is started
      ansible.builtin.systemd:
        name: mariadb
        state: started
...
```

Puede comprobar la sintaxis de su playbook:

```
$ ansible-playbook --syntax-check play.yml
```

También puedes utilizar un "linter" para el formato yaml:

```
$ dnf install -y yamllint
```

y despues comprobar la sintaxis yaml de sus playbooks:

```
$ yamllint test.yml
test.yml
  8:1       error    syntax error: could not find expected ':' (syntax)
```

## Resultados de los ejercicios

* Crear los grupos París, Tokio, NewYork
* Crear el usuario `supervisor`
* Cambiar el usuario para que tenga un uid de 10000
* Cambiar el usuario para que pertenezca al grupo París
* Instalar el software tree
* Detener el servicio de crond
* Crear un archivo vacío con permisos `0644`
* Actualizar su distribución
* Reinciar su cliente

```
ansible ansible_clients --become -m group -a "name=Paris"
ansible ansible_clients --become -m group -a "name=Tokio"
ansible ansible_clients --become -m group -a "name=NewYork"
ansible ansible_clients --become -m user -a "name=Supervisor"
ansible ansible_clients --become -m user -a "name=Supervisor uid=10000"
ansible ansible_clients --become -m user -a "name=Supervisor uid=10000 groups=Paris"
ansible ansible_clients --become -m dnf -a "name=tree"
ansible ansible_clients --become -m systemd -a "name=crond state=stopped"
ansible ansible_clients --become -m copy -a "content='' dest=/tmp/test force=no mode=0644"
ansible ansible_clients --become -m dnf -a "name=* state=latest"
ansible ansible_clients --become -m reboot
```
