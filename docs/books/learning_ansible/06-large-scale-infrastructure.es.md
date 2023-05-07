---
title: Ansible - Infraestructura a gran escala
---

# Ansible - Infraestructura a gran escala

En este capítulo aprenderá a escalar su sistema de gestión de la configuración.

****

**Objetivos** : En este capítulo aprenderá a:

:heavy_check_mark: Organice su código para la gestión de una gran infraestructura;
:heavy_check_mark: Aplicar toda o una parte de la gestión de la configuración a un grupo de nodos;

:checkered_flag: **ansible**, **gestion de la configuración**, **escalado**

**Conocimiento**: :star: :star: :star:
**Complejidad**: :star: :star: :star: :star:

**Tiempo de lectura**: 30 minutos

****

En los capítulos anteriores hemos visto cómo organizar nuestro código en forma de roles, pero también cómo utilizar algunos roles para la gestión de actualizaciones (gestión de parches) o el despliegue de código.

Pero ¿Qué ocurre con la gestión de la configuración? ¿Cómo gestionar la configuración de decenas, cientos o incluso miles de máquinas virtuales con Ansible?

La llegada de la nube ha cambiado un poco los métodos de administración tradicionales. La máquina virtual se configura en el momento del despliegue. Si su configuración ya no es válida, se destruye y se sustituye por una nueva.

La organización del sistema de gestión de la configuración que se presenta en este capítulo responderá a estas dos formas de consumir TI: uso "puntual" o "reconfiguración" regular de una flota de servidores.

Sin embargo, hay que tener cuidado: el uso de Ansible para garantizar el cumplimiento del parque del parque de servidores equiere cambiar sus hábitos de trabajo. Ya no es posible modificar manualmente la configuración de un sistema gestor de servicios sin que estas modificaciones se sobrescriban la próxima vez que se ejecute Ansible.

!!! Note

    Lo que vamos a configurar a continuación no es el terreno favorito de Ansible. Tecnologías como Puppet o Salt lo harán mucho mejor. Recordemos que Ansible es una navaja suiza de la automatización y no tiene agentes, lo que explica las diferencias de rendimiento.

!!! Note

    Puede encontrar más información [aquí](https://docs.ansible.com/ansible/latest/user_guide/sample_setup.html)

## Almacenamiento de variables

Lo primero que tenemos que discutir es la separación entre los datos y el código de Ansible.

A medida que el código se hace más grande y complejo, cada vez será más complicado modificar las variables que contiene.

Para asegurar el mantenimiento de su sitio web, lo más importante es separar correctamente las variables del código de Ansible.

Todavía no lo hemos discutido aquí, pero debe saber que Ansible puede cargar automáticamente las variables que encuentra en carpetas específicas dependiendo del nombre de inventario del nodo gestionado, o de sus grupos de miembros.

La documentación de Ansible sugiere que organicemos nuestro código tal y como se indica a continuación:

```
inventories/
   production/
      hosts               # inventory file for production servers
      group_vars/
         group1.yml       # here we assign variables to particular groups
         group2.yml
      host_vars/
         hostname1.yml    # here we assign variables to particular systems
         hostname2.yml
```

Si el nodo objetivo es `hostname1` que pertenece a `group1`, las variables contenidas en los archivos `hostname1.yml` y en `group1.yml` se cargarán automáticamente. Es una buena manera de almacenar todos los datos de todos sus roles en el mismo lugar.

De esta manera, el archivo de inventario de su servidor se convierte en su tarjeta de identidad. Ya que contiene todas las variables que difieren de las variables por defecto de su servidor.

Desde el punto de vista de la centralización de las variables, se hace imprescindible utilizar una nomenclatura para las variables utilizadas en sus roles anteponiendo, por ejemplo, el nombre del rol. También se recomienda utilizar nombres de variables planos en lugar de diccionarios.

Por ejemplo, si quiere que el valor del parámetro `PermitRootLogin` en el archivo `sshd_config` sea configurable, un buen nombre de variable podría ser `sshd_config_permitrootlogin` (en lugar de `sshd.config.permitrootlogin` el cual también podría ser un buen nombre de variable).

## Acerca de las etiquetas Ansible

El uso de las etiquetas de Ansible le permite ejecutar u omitir un conjunto de las tareas definidas en su código.

!!! Note

    Puede encontrar más información [aquí](https://docs.ansible.com/ansible/latest/user_guide/playbooks_tags.html)

Por ejemplo, vamos a modificar nuestra tarea de creación de usuarios:

```
- name: add users
  user:
    name: "{{ item }}"
    state: present
    groups: "users"
  loop:
     - antoine
     - patrick
     - steven
     - xavier
  tags: users
```

Ahora puede reproducir sólo las tareas con la etiqueta `users` mediante la opción `--tags` de la herramienta `ansible-playbook`:

```
ansible-playbook -i inventories/production/hosts --tags users site.yml
```

También es posible utilizar la opción `--skip-tags`.

## Acerca del diseño de directorios

Vamos a centrarnos en una propuesta de organización de los archivos y directorios necesarios para el buen funcionamiento de un CMS (Sistema de Gestión de Contenidos).

Nuestro punto de partida será el archivo `site.yml`. Este archivo, es un poco como el director de orquesta del CMS, ya que sólo incluirá los roles necesarios para los nodos de destino si es necesario:

```
---
- name: "Config Management for {{ target }}"
  hosts: "{{ target }}"

  roles:

    - role: roles/functionality1

    - role: roles/functionality2
```

Por supuesto, esos roles deben ser creados bajo el directorio `roles` al mismo nivel que el archivo `site.yml`.

Me gusta manejar mis vars globales dentro del archivo `vars/global_vars.yml`, aunque tambien podría almacenarlos dentro de un archivo ubicado en `inventories/production/group_vars/all.yml`

```
---
- name: "Config Management for {{ target }}"
  hosts: "{{ target }}"
  vars_files:
    - vars/global_vars.yml
  roles:

    - role: roles/functionality1

    - role: roles/functionality2
```

Personalmente, también me gusta mantener la posibilidad de desactivar una funcionalidad. Por lo que incluyo en mis roles una condición y un valor por defecto como este:

```
---
- name: "Config Management for {{ target }}"
  hosts: "{{ target }}"
  vars_files:
    - vars/global_vars.yml
  roles:

    - role: roles/functionality1
      when:
        - enable_functionality1|default(true)

    - role: roles/functionality2
      when:
        - enable_functionality2|default(false)
```

No se olvide de utilizar las etiquetas:


```
- name: "Config Management for {{ target }}"
  hosts: "{{ target }}"
  vars_files:
    - vars/global_vars.yml
  roles:

    - role: roles/functionality1
      when:
        - enable_functionality1|default(true)
      tags:
        - functionality1

    - role: roles/functionality2
      when:
        - enable_functionality2|default(false)
      tags:
        - functionality2
```

Debería ver algo como esto:

```
$ tree cms
cms
├── inventories
│   └── production
│       ├── group_vars
│       │   └── plateform.yml
│       ├── hosts
│       └── host_vars
│           ├── client1.yml
│           └── client2.yml
├── roles
│   ├── functionality1
│   │   ├── defaults
│   │   │   └── main.yml
│   │   └── tasks
│   │       └── main.yml
│   └── functionality2
│       ├── defaults
│       │   └── main.yml
│       └── tasks
│           └── main.yml
├── site.yml
└── vars
    └── global_vars.yml
```

!!! Note

    Es libre de desarrollar sus roles dentro de una colección

## Pruebas

Vamos a ejecutar el playbook y a realizar algunas pruebas:

```
$ ansible-playbook -i inventories/production/hosts -e "target=client1" site.yml

PLAY [Config Management for client1] ****************************************************************************

TASK [Gathering Facts] ******************************************************************************************
ok: [client1]

TASK [roles/functionality1 : Task in functionality 1] *********************************************************
ok: [client1] => {
    "msg": "You are in functionality 1"
}

TASK [roles/functionality2 : Task in functionality 2] *********************************************************
skipping: [client1]

PLAY RECAP ******************************************************************************************************
client1                    : ok=2    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```

Como puede ver, por defecto, sólo se ejecutan las tareas del rol `functionality1`.

Activemos en el inventario la `functionality2` para nuestro nodo objetivo y volvamos a ejecutar el playbook:

```
$ vim inventories/production/host_vars/client1.yml
---
enable_functionality2: true
```


```
$ ansible-playbook -i inventories/production/hosts -e "target=client1" site.yml

PLAY [Config Management for client1] ****************************************************************************

TASK [Gathering Facts] ******************************************************************************************
ok: [client1]

TASK [roles/functionality1 : Task in functionality 1] *********************************************************
ok: [client1] => {
    "msg": "You are in functionality 1"
}

TASK [roles/functionality2 : Task in functionality 2] *********************************************************
ok: [client1] => {
    "msg": "You are in functionality 2"
}

PLAY RECAP ******************************************************************************************************
client1                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Intentamos aplicar únicamente la tarea `functionality2`:

```
$ ansible-playbook -i inventories/production/hosts -e "target=client1" --tags functionality2 site.yml

PLAY [Config Management for client1] ****************************************************************************

TASK [Gathering Facts] ******************************************************************************************
ok: [client1]

TASK [roles/functionality2 : Task in functionality 2] *********************************************************
ok: [client1] => {
    "msg": "You are in functionality 2"
}

PLAY RECAP ******************************************************************************************************
client1                    : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Vamos a ejecutar la tarea contra todo el inventario:

```
$ ansible-playbook -i inventories/production/hosts -e "target=plateform" site.yml

PLAY [Config Management for plateform] **************************************************************************

TASK [Gathering Facts] ******************************************************************************************
ok: [client1]
ok: [client2]

TASK [roles/functionality1 : Task in functionality 1] *********************************************************
ok: [client1] => {
    "msg": "You are in functionality 1"
}
ok: [client2] => {
    "msg": "You are in functionality 1"
}

TASK [roles/functionality2 : Task in functionality 2] *********************************************************
ok: [client1] => {
    "msg": "You are in functionality 2"
}
skipping: [client2]

PLAY RECAP ******************************************************************************************************
client1                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
client2                    : ok=2    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```

Como puede ver, `functionality2` sólo se ejecuta en el `cliente1`.

## Beneficios

Siguiendo los consejos incluidos en la documentación de Ansible, obtendrá rápidamente un:

* Un código fuente fácil de mantener aunque contenga un gran número de funciones.
* Un sistema de cumplimiento relativamente rápido y repetible que puede aplicar parcial o totalmente.
* Puede adaptarse en función de cada caso y del servidor.
* Los detalles de su sistema de información están separados del código, son fácilmente auditables y están centralizados en los archivos de inventario de su gestión de la configuración.
