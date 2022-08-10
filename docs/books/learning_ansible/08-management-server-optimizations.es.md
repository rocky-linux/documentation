---
title: Optimizaciones del servidor de administración
author: Antoine Le Morvan
contributors: Steven Spencer
update: 06-Dec-2021
---

# Optimizaciones del servidor de administración

En este capítulo revisaremos las opciones de configuración que pueden ser de interés para optimizar nuestro servidor de administración de Ansible.

## El archivo de configuración `ansible.cfg`

A continuación vamos a comentar algunas opciones de configuración interesantes de Ansible:

* `forks`: Establecido por defecto a 5, es el número de procesos que Ansible lanzará en paralelo para comunicarse con los hosts remotos. Cuanto más alto sea este número, más clientes podrá gestionar Ansible al mismo tiempo, y así acelerar los procesos. El valor que puede establecer depende de los límites de CPU/RAM de su servidor de administración. Observe que el valor por defecto, `5`, es muy pequeño, la documentación de Ansible indica que muchos usuarios lo establecen en 50, en 500 o incluso en valores más altos.

* `gathering`: Esta variable cambia la política de recogida de datos. Por defecto, el valor se establece a `implicit`, lo que implica que los datos se recopilarán sistemáticamente. El cambio de esta variable a `smart` permite recopilar las colecciones de datos sólo cuando no se han recogido con anterioridad. Si se combina con una caché de datos (véase más adelante), esta opción puede aumentar considerablemente el rendimiento.

* `host_key_checking`: ¡Cuidado con la seguridad de su servidor! Sin embargo, si tiene control de su entorno, puede ser interesante desactivar el control de llaves de sus servidores remotos y ahorrar algo de tiempo en la conexión. En servidores remotos, puede deshabilitar el uso de DNS en el servidor SSH (en `/etc/sshd_config`, medianrte la opción `UseDNS no`). Esta opción hace perder tiempo en la conexión y, la mayoría de las veces, sólo se utiliza para los registros de conexión.

* `ansible_managed`: Esta variable, que contiene el valor `Ansible managed` por defecto, se suele utilizar en plantillas de archivos que se despliegan en servidores remotos. Permite a un administrador especificar que el archivo se gestiona automáticamente y que potencialmente cualquier cambio que haga en él se perderá. Puede ser interesante que los administradores tengan mensajes más completos. Sin embargo, tenga cuidado, si cambia esta variable, puede hacer que los demonios se reinicien (a través de los handlers asociados a las plantillas).

* `ssh_args = -C -o ControlMaster=auto -o ControlPersist=300s -o PreferredAuthentications=publickey`: Especificar las opciones de conexión mediante ssh. Puede ahorrar mucho tiempo, si desactiva todos los métodos de autenticación que no sean de clave pública. También puede incrementar el valor del parámetro `ControlPersist` para mejorar el rendimiento (la documentación sugiere que un valor equivalente a 30 minutos puede ser apropiado). La conexión con un cliente permanecerá abierta durante más tiempo y podrá reutilizarse cuando se vuelva a conectar al mismo servidor, lo que supone un importante ahorro de tiempo.

* `control_path_dir`: Especifica la ruta de acceso a los sockets de conexión. Si la ruta es demasiado larga, puede provocar problemas. Valore la posibilidad de cambiarlo por algo más corto, como `/tmp/.cp`.

* `pipelining`: El establecer este valor a `True` aumenta el rendimiento al reducir el número de conexiones SSH necesarias cuando se ejecutan los módulos remotos. Primero debe asegurarse de que la opción `requiretty` está desactivada en las opciones de `sudoers` (vea la documentación).

## Almacenamiento de los datos

La recopilación de datos es un proceso que puede llevar algún tiempo. Puede resultar interesante desactivar la recopilación de datos para los playbooks que no la necesiten (mediante la opción `gather_facts`) o mantener estos datos en una memoria caché durante un periodo de tiempo determinado (por ejemplo 24H).

Estos datos se pueden almacenar fácilmente en una base de datos `redis`:

```
sudo yum install redis
sudo systemctl start redis
sudo systemctl enable redis
sudo pip3 install redis
```

No olvide modificar la configuración de ansible:

```
fact_caching = redis
fact_caching_timeout = 86400
fact_caching_connection = localhost:6379:0
```

Para comprobar el correcto funcionamiento, basta con hacer una petición al servidor `redis`:

```
redis-cli
127.0.0.1:6379> keys *
127.0.0.1:6379> get ansible_facts_SERVERNAME
```

## Utilizar Vault

Las distintas contraseñas y secretos no e pueden almacenar en texto plano dentro del código de Ansible, ni localmente en el servidor de gestión ni en una posible herramienta de gestión de código fuente.

Ansible propone utilizar un gestor de encriptado: `ansible-vault`.

El principio es cifrar una variable o un archivo completo mediante el comando `ansible-vault`.

Ansible podrá descifrar este archivo en tiempo de ejecución recuperando la clave de cifrado del archivo (por ejemplo) `/etc/ansible/ansible.cfg`. Esto último también puede ser un script de python o cualquier otra cosa.

Edite el archivo `/etc/ansible/ansible.cfg`:

```
#vault_password_file = /path/to/vault_password_file
vault_password_file = /etc/ansible/vault_pass
```

Guarde la contraseña en el archivo `/etc/ansible/vault_pass` y asigne los permisos y las restricciones necesarias:

```
mysecretpassword
```

A continuación, puede encriptar sus archivos mediante el comando:

```
ansible-vault encrypt myfile.yml
```

Un archivo encriptado mediante `ansible-vault` se puede reconocer fácilmente por su cabecera:

```
$ANSIBLE_VAULT;1.1;AES256
35376532343663353330613133663834626136316234323964333735363333396136613266383966
6664322261633261356566383438393738386165333966660a343032663233343762633936313630
34373230124561663766306134656235386233323964336239336661653433663036633334366661
6434656630306261650a313364636261393931313739363931336664386536333766326264633330
6334
```

Una vez que un archivo está encriptado, todavía puede editarse mediante el comando:

```
ansible-vault edit myfile.yml
```

También puede delegar el almacenamiento de contraseñas a su gestor de contraseñas de confianza.

Por ejemplo, para recuperar una contraseña que estaría almacenada en la aplicación Rundeck:

```
#!/usr/bin/env python
# -*- coding: utf-8 -*-
import urllib.request
import io
import ssl

def get_password():
    '''
    :return: Vault password
    :return_type: str
    '''
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE

    url = 'https://rundeck.rockylinux.org/api/11/storage/keys/ansible/vault'
    req = urllib.request.Request(url, headers={
                          'Accept': '*/*',
                          'X-Rundeck-Auth-Token': '****token-rundeck****'
                          })
    response = urllib.request.urlopen(req, context=ctx)

    return response.read().decode('utf-8')

if __name__ == '__main__':
    print(get_password())
```

## Trabajar con servidores Windows

Será necesario instalar en el servidor de gestión varios paquetes:

* Mediante el gestor de paquetes:

```
sudo dnf install python38-devel krb5-devel krb5-libs krb5-workstation
```

y configure el archivo `/etc/krb5.conf` para especificar el valor correcto de los `realms`:

```
[realms]
ROCKYLINUX.ORG = {
    kdc = dc1.rockylinux.org
    kdc = dc2.rockylinux.org
}
[domain_realm]
  .rockylinux.org = ROCKYLINUX.ORG
```

* Mediante el gestor de paquetes de Python:

```
pip3 install pywinrm
pip3 install pywinrm[credssp]
pip3 install kerberos requests-kerberos
```

## Trabajar con módulos IP

Lo módulos de red normalmente requieren el uso del módulo de python `netaddr`:

```
sudo pip3 install netaddr
```

## Generación de una CMDB

Se ha desarrollado una herramienta, `ansible-cmdb` para generar una CMDB desde ansible.

```
pip3 install ansible-cmdb
```

Los "facts" se deben exportar mediante ansible con el siguiente comando:

```
ansible --become --become-user=root -o -m setup --tree /var/www/ansible/cmdb/out/
```

A continuación, puede generar un archivo `json` global:

```
ansible-cmdb -t json /var/www/ansible/cmdb/out/linux > /var/www/ansible/cmdb/cmdb-linux.json
```

Si prefiere una interfaz web:

```
ansible-cmdb -t html_fancy_split /var/www/ansible/cmdb/out/
```
