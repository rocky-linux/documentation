---
title: Gestión de ficheros
---

# Ansible - Gestión de archivos

En este capítulo aprenderás a gestionar archivos con Ansible.

****

**Objetivos** : En este capítulo aprenderá a:

:heavy_check_mark: modificar el contenido de un archivo;
:heavy_check_mark: subir archivos a los servidores de destino;
:heavy_check_mark: descargar archivos desde los servidores de destino.

:checkered_flag: **ansible**, **module**, **files**

**Conocimiento**: :star: :star:
**Complejidad**: :star:

**Tiempo de lectura**: 20 minutos

****

Dependiendo de sus necesidades, tendrá que utilizar módulos de Ansible diferentes para modificar los archivos de configuración del sistema.

## Módulo `ini_file`

Cuando quiera modificar un archivo INI (la sección entre `[]` y los pares `clave=valor`), la forma más fácil es utilizar el módulo `ini_file`.

!!! Note

    Puede encontrar más información [aquí](https://docs.ansible.com/ansible/latest/collections/community/general/ini_file_module.html).

El módulo requiere:

* El valor de la sección
* El nombre de la opción
* El nuevo valor

Ejemplo de uso:

```
- name: change value on inifile
  community.general.ini_file:
    dest: /path/to/file.ini
    section: SECTIONNAME
    option: OPTIONNAME
    value: NEWVALUE
```

## Módulo `lineinfile`

Para asegurarse de que una línea está presente en un archivo, o cuando se necesita añadir o modificar una sola línea en un archivo, utilice el módulo `linefile`.

!!! Note

    Puede encontrar más información [aquí](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html).

En este caso, la línea a modificar en un archivo se encontrará mediante una regexp.

Por ejemplo, para garantizar que la línea que comienza con `SELINUX=` en el archivo `/etc/selinux/config` contiene el valor `enforcing`:

```
- ansible.builtin.lineinfile:
    path: /etc/selinux/config
    regexp: '^SELINUX='
    line: 'SELINUX=enforcing'
```

## Módulo `copy`

Cuando hay que copiar un archivo desde el servidor Ansible a uno o más hosts, es mejor utilizar el módulo `copy`.

!!! Note

    Puede encontrar más información [aquí](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html).

Aquí estamos copiando el archivo `myflile.conf` de una ubicación a otra:

```
- ansible.builtin.copy:
    src: /data/ansible/sources/myfile.conf
    dest: /etc/myfile.conf
    owner: root
    group: root
    mode: 0644
```

## Módulo `fetch`

Cuando hay que copiar un archivo de un servidor remoto a un servidor local, lo mejor es utilizar el módulo `fetch`.

!!! Note

    Puede encontrar más información [aquí](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/fetch_module.html).

Este módulo hace lo contrario que el módulo `copy`:

```
- ansible.builtin.fetch:
    src: /etc/myfile.conf
    dest: /data/ansible/backup/myfile-{{ inventory_hostname }}.conf
    flat: yes
```

## Módulo `template`

Ansible y su módulo `template` utilizan el sistema de plantillas **Jinja2** (http://jinja.pocoo.org/docs/) para generar archivos en los hosts de destino.

!!! Note

    Puede encontrar más información [aquí](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html).

Por ejemplo:

```
- ansible.builtin.template:
    src: /data/ansible/templates/monfichier.j2
    dest: /etc/myfile.conf
    owner: root
    group: root
    mode: 0644
```

Es posible añadir un paso de validación si el servicio de destino lo permite (por ejemplo Apache con el comando `apachectl -t`):

```
- template:
    src: /data/ansible/templates/vhost.j2
    dest: /etc/httpd/sites-available/vhost.conf
    owner: root
    group: root
    mode: 0644
    validate: '/usr/sbin/apachectl -t'
```

## Módulo `get_url`

Para subir archivos desde un sitio web o ftp a uno o más hosts, utilice el módulo `get_url`:

```
- get_url:
    url: http://site.com/archive.zip
    dest: /tmp/archive.zip
    mode: 0640
    checksum: sha256:f772bd36185515581aa9a2e4b38fb97940ff28764900ba708e68286121770e9a
```

Al proporcionar una suma de comprobación del archivo, éste no se volverá a descargar si ya está presente en la ubicación de destino y su suma de comprobación coincide con el valor proporcionado.
