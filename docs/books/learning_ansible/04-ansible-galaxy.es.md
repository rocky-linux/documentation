---
title: Ansible Galaxy
---

# Ansible Galaxy: Colecciones y roles

En este capítulo aprenderá a utilizar, instalar y gestionar los roles y colecciones de Ansible.

****

**Objetivos** : En este capítulo aprenderá a:

:heavy_check_mark: instalar y gestionar colecciones;
:heavy_check_mark: instalar y gestionar roles;.

:checkered_flag: **ansible**, **ansible-galaxy**, **roles**, **colecciones**

**Conocimiento**: :star: :star:
**Complejidad**: :star: :star: :star:

**Tiempo de lectura**: 40 minutos

****

[Ansible Galaxy](https://galaxy.ansible.com) proporciona roles y colecciones de Ansible desde la comunidad Ansible.

Los elementos proporcionados se pueden referenciar en los playbooks y ser utilizados tal y como están

## Comando `ansible-galaxy`

El comando `ansible-galaxy` gestiona los roles y las colecciones utilizando [galaxy.ansible.com](http://galaxy.ansible.com).

* Para gestionar los roles:

```
ansible-galaxy role [import|init|install|login|remove|...]
```

| Sub-comandos | Observaciones                                                                   |
| ------------ | ------------------------------------------------------------------------------- |
| `install`    | instalar un rol.                                                                |
| `remove`     | elimina uno o más roles.                                                        |
| `lista`      | muestra el nombre y la versión de los roles instalados.                         |
| `info`       | muestra la información sobre un rol.                                            |
| `init`       | genera la estructura básica de un nuevo rol.                                    |
| `import`     | importa un rol desde el sitio web de Ansible Galaxy. Requiere inicio de sesión. |

* Para gestionar las colecciones:

```
ansible-galaxy collection [import|init|install|login|remove|...]
```

| Sub-comandos | Observaciones                                                 |
| ------------ | ------------------------------------------------------------- |
| `init`       | genera la estructura básica de una nueva colección.           |
| `install`    | instala una colección.                                        |
| `list`       | muestra el nombre y la versión de las colecciones instaladas. |

## Roles de Ansible

Un rol de Ansible es una unidad que promueve la reutilización de los playbooks.

!!! Note

    Puede encontrar más información [aquí](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html)

### Instalación de roles útiles

Para resaltar el interés del uso de roles, le sugiero que utilice el rol `alemorvan/patchmanagement`, que le permitirá realizar un montón de tareas (preactualización o postactualización, por ejemplo) durante su proceso de actualización, en sólo unas pocas líneas de código.

Puedes consultar el código en el repo de github del rol \[aquí\](https://github. com/alemorvan/patchmanagement).

* Instalar el rol. Para ello, sólo es necesario un comando:

```
ansible-galaxy role install alemorvan.patchmanagement
```

* Cree un playbook para incluir el rol:

```
- name: Start a Patch Management
  hosts: ansible_clients
  vars:
    pm_before_update_tasks_file: custom_tasks/pm_before_update_tasks_file.yml
    pm_after_update_tasks_file: custom_tasks/pm_after_update_tasks_file.yml

  tasks:
    - name: "Include patchmanagement"
      include_role:
        name: "alemorvan.patchmanagement"
```

Con este rol, puede añadir sus propias tareas para todo su inventario o sólo para su nodo objetivo.

Vamos a crear tareas que se ejecutarán antes y después del proceso de actualización:

* Cree la carpeta `custom_tasks`:

```
mkdir custom_tasks
```

* Cree el archivo `custom_tasks/pm_before_update_tasks_file.yml` (siéntase libre de cambiar el nombre y el contenido de este archivo)

```
---
- name: sample task before the update process
  debug:
    msg: "This is a sample tasks, feel free to add your own test task"
```

* Cree el archivo `custom_tasks/pm_after_update_tasks_file.yml` (siéntase libre de cambiar el nombre y el contenido de este archivo)

```
---
- name: sample task after the update process
  debug:
    msg: "This is a sample tasks, feel free to add your own test task"
```

Y lance su primera gestión de parches:

```
ansible-playbook patchmanagement.yml

PLAY [Start a Patch Management] *************************************************************************

TASK [Gathering Facts] **********************************************************************************
ok: [192.168.1.11]

TASK [Include patchmanagement] **************************************************************************

TASK [alemorvan.patchmanagement : MAIN | Linux Patch Management Job] ************************************
ok: [192.168.1.11] => {
    "msg": "Start 192 patch management"
}

...

TASK [alemorvan.patchmanagement : sample task before the update process] ********************************
ok: [192.168.1.11] => {
    "msg": "This is a sample tasks, feel free to add your own test task"
}

...

TASK [alemorvan.patchmanagement : MAIN | We can now patch] **********************************************
included: /home/ansible/.ansible/roles/alemorvan.patchmanagement/tasks/patch.yml for 192.168.1.11

TASK [alemorvan.patchmanagement : PATCH | Tasks depends on distribution] ********************************
ok: [192.168.1.11] => {
    "ansible_distribution": "Rocky"
}

TASK [alemorvan.patchmanagement : PATCH | Include tasks for CentOS & RedHat tasks] **********************
included: /home/ansible/.ansible/roles/alemorvan.patchmanagement/tasks/linux_tasks/redhat_centos.yml for 192.168.1.11

TASK [alemorvan.patchmanagement : RHEL CENTOS | yum clean all] ******************************************
changed: [192.168.1.11]

TASK [alemorvan.patchmanagement : RHEL CENTOS | Ensure yum-utils is installed] **************************
ok: [192.168.1.11]

TASK [alemorvan.patchmanagement : RHEL CENTOS | Remove old kernels] *************************************
skipping: [192.168.1.11]

TASK [alemorvan.patchmanagement : RHEL CENTOS | Update rpm package with yum] ****************************
ok: [192.168.1.11]

TASK [alemorvan.patchmanagement : PATCH | Inlude tasks for Debian & Ubuntu tasks] ***********************
skipping: [192.168.1.11]

TASK [alemorvan.patchmanagement : MAIN | We can now reboot] *********************************************
included: /home/ansible/.ansible/roles/alemorvan.patchmanagement/tasks/reboot.yml for 192.168.1.11

TASK [alemorvan.patchmanagement : REBOOT | Reboot triggered] ********************************************
ok: [192.168.1.11]

TASK [alemorvan.patchmanagement : REBOOT | Ensure we are not in rescue mode] ****************************
ok: [192.168.1.11]

...

TASK [alemorvan.patchmanagement : FACTS | Insert fact file] *********************************************
ok: [192.168.1.11]

TASK [alemorvan.patchmanagement : FACTS | Save date of last PM] *****************************************
ok: [192.168.1.11]

...

TASK [alemorvan.patchmanagement : sample task after the update process] *********************************
ok: [192.168.1.11] => {
    "msg": "This is a sample tasks, feel free to add your own test task"
}

PLAY RECAP **********************************************************************************************
192.168.1.11               : ok=31   changed=1    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0
```

Bastante fácil para un proceso tan complejo, ¿no?

Este es sólo un ejemplo de lo que se puede hacer utilizando los roles puestos a disposición por la comunidad. Eche un vistazo a [galaxy.ansible.com](https://galaxy.ansible.com/) para descubrir las funciones que podrían serle útiles.

También puede crear sus propios roles para cubrir sus propias necesidades y publicarlos en Internet si le apetece. Lo que trataremos brevemente en el próximo capítulo.

### Introducción al desarrollo de roles

La estructura básica de un rol, sirve como punto de partida para el desarrollo de roles personalizados, puede ser generada mediante el comando `ansible-galaxy`:

```
$ ansible-galaxy role init rocky8
- Role rocky8 was created successfully
```

El comando generará la siguiente estructura de árbol para contener el rol `rocky8`:

```
tree rocky8/
rocky8/
├── defaults
│   └── main.yml
├── files
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── README.md
├── tasks
│   └── main.yml
├── templates
├── tests
│   ├── inventory
│   └── test.yml
└── vars
    └── main.yml

8 directories, 8 files
```

Los roles le permiten prescindir de la necesidad de incluir archivos. No es necesario especificar rutas de archivos o directivas `include` en los playbooks. Sólo tiene que especificar una tarea, y Ansible se encarga de las inclusiones.

La estructura de un rol es bastante obvia de entender.

Simplemente las variables se almacenan en `vars/main.yml` si las variables no van a ser sobreescribir, o en `default/main.yml` si quiere dejar la posibilidad de sobreescribir el contenido de las variables desde fuera de su rol.

Los handlers, archivos y plantillas necesarios para su código se almacenan en `handlers/main.yml`, `files` y `templates` respectivamente.

Sólo queda definir el código de las tareas de su rol en `tasks/main.yml`.

Una vez que todo esto funciona correctamente, puede utilizar este rol en sus playbooks. Podrá utilizar su rol sin preocuparse por el aspecto técnico de sus tareas, mientras personaliza su funcionamiento con variables.

### Trabajo práctico: crear un primer rol sencillo

Implementemos esto con un rol que creará un usuario por defecto e instalará paquetes de software. Este rol puede aplicarse sistemáticamente a todos sus servidores.

#### Variables

Crearemos un usuario `rockstar` en todos nuestros servidores. Como no queremos que este usuario sea reemplazado, vamos a definirlo en el `vars/main.yml`:

```
---
rocky8_default_group:
  name: rockstar
  gid: 1100
rocky8_default_user:
  name: rockstar
  uid: 1100
  group: rockstar
```

Ahora podemos usar esas variables dentro de nuestro archivo `tasks/main.yml` sin ninguna inclusión.

```
---
- name: Create default group
  group:
    name: "{{ rocky8_default_group.name }}"
    gid: "{{ rocky8_default_group.gid }}"

- name: Create default user
  user:
    name: "{{ rocky8_default_user.name }}"
    uid: "{{ rocky8_default_user.uid }}"
    group: "{{ rocky8_default_user.group }}"
```

Para probar su nuevo rol, vamos a crear un playbook `test-role.yml` en el mismo directorio que su rol:

```
---
- name: Test my role
  hosts: localhost

  roles:

    - role: rocky8
      become: true
      become_user: root
```

y ejecútelo:

```
ansible-playbook test-role.yml

PLAY [Test my role] ************************************************************************************

TASK [Gathering Facts] *********************************************************************************
ok: [localhost]

TASK [rocky8 : Create default group] *******************************************************************
changed: [localhost]

TASK [rocky8 : Create default user] ********************************************************************
changed: [localhost]

PLAY RECAP *********************************************************************************************
localhost                  : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

¡Felicidades! Ahora es capaz de hacer grandes cosas con un playbook de unas pocas líneas.

Veamos el uso de las variables por defecto.

Cree una lista de paquetes para instalar por defecto en sus servidores y una lista vacía de paquetes para desinstalar. Edite los archivos `defaults/main.yml` y añada esas dos listas:

```
rocky8_default_packages:
  - tree
  - vim
rocky8_remove_packages: []
```

y utilícelos en tu archivo `tasks/main.yml`:

```
- name: Install default packages (can be overridden)
  package:
    name: "{{ rocky8_default_packages }}"
    state: present

- name: "Uninstall default packages (can be overridden) {{ rocky8_remove_packages }}"
  package:
    name: "{{ rocky8_remove_packages }}"
    state: absent
```

Pruebe su rol con la ayuda del playbook creado anteriormente:

```
ansible-playbook test-role.yml

PLAY [Test my role] ************************************************************************************

TASK [Gathering Facts] *********************************************************************************
ok: [localhost]

TASK [rocky8 : Create default group] *******************************************************************
ok: [localhost]

TASK [rocky8 : Create default user] ********************************************************************
ok: [localhost]

TASK [rocky8 : Install default packages (can be overridden)] ********************************************
ok: [localhost]

TASK [rocky8 : Uninstall default packages (can be overridden) []] ***************************************
ok: [localhost]

PLAY RECAP *********************************************************************************************
localhost                  : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Ahora puede anular el valor de la variable `rocky8_remove_packages` en su playbook y desinstalar por ejemplo `cockpit`:

```
---
- name: Test my role
  hosts: localhost
  vars:
    rocky8_remove_packages:
      - cockpit

  roles:

    - role: rocky8
      become: true
      become_user: root
```

```
ansible-playbook test-role.yml

PLAY [Test my role] ************************************************************************************

TASK [Gathering Facts] *********************************************************************************
ok: [localhost]

TASK [rocky8 : Create default group] *******************************************************************
ok: [localhost]

TASK [rocky8 : Create default user] ********************************************************************
ok: [localhost]

TASK [rocky8 : Install default packages (can be overridden)] ********************************************
ok: [localhost]

TASK [rocky8 : Uninstall default packages (can be overridden) ['cockpit']] ******************************
changed: [localhost]

PLAY RECAP *********************************************************************************************
localhost                  : ok=5    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Evidentemente, no hay límite a la hora de mejorar su rol. Imagine que para uno de sus servidores, necesita un paquete que está en la lista de los que hay que desinstalar. A continuación, podría, por ejemplo, crear una nueva lista que puede ser anulada y luego eliminar de la lista de paquetes a desinstalar los de la lista de paquetes específicos a instalar mediante el filtro de jinja `difference()`.

```
- name: "Uninstall default packages (can be overridden) {{ rocky8_remove_packages }}"
  package:
    name: "{{ rocky8_remove_packages | difference(rocky8_specifics_packages) }}"
    state: absent
```

## Colecciones de Ansible

Las colecciones son un formato de distribución para contenido de Ansible que puede incluir playbooks, roles, módulos y plugins.

!!! Note

    Puede encontrar más información [aquí](https://docs.ansible.com/ansible/latest/user_guide/collections_using.html)

Para instalar o actualizar una colección:

```
ansible-galaxy collection install namespace.collection [--upgrade]
```

A continuación, puede utilizar la colección recién instalada utilizando su espacio de nombres y su nombre antes del nombre del módulo o del rol:

```
- import_role:
    name: namespace.collection.rolename

- namespace.collection.modulename:
    option1: value
```

Puede encontrar un índice de la colección [aquí](https://docs.ansible.com/ansible/latest/collections/index.html).

Vamos a instalar la colección `community.general`:

```
ansible-galaxy collection install community.general
Starting galaxy collection install process
Process install dependency map
Starting collection install process
Downloading https://galaxy.ansible.com/download/community-general-3.3.2.tar.gz to /home/ansible/.ansible/tmp/ansible-local-51384hsuhf3t5/tmpr_c9qrt1/community-general-3.3.2-f4q9u4dg
Installing 'community.general:3.3.2' to '/home/ansible/.ansible/collections/ansible_collections/community/general'
community.general:3.3.2 was installed successfully
```

Ahora podemos utilizar el nuevo módulo disponible `yum_versionlock`:

```
- name: Start a Patch Management
  hosts: ansible_clients
  become: true
  become_user: root
  tasks:

    - name: Ensure yum-versionlock is installed
      package:
        name: python3-dnf-plugin-versionlock
        state: present

    - name: Prevent kernel from being updated
      community.general.yum_versionlock:
        state: present
        name: kernel
      register: locks

    - name: Display locks
      debug:
        var: locks.meta.packages
```

```
ansible-playbook versionlock.yml

PLAY [Start a Patch Management] *************************************************************************

TASK [Gathering Facts] **********************************************************************************
ok: [192.168.1.11]

TASK [Ensure yum-versionlock is installed] **************************************************************
changed: [192.168.1.11]

TASK [Prevent kernel from being updated] ****************************************************************
changed: [192.168.1.11]

TASK [Display locks] ************************************************************************************
ok: [192.168.1.11] => {
    "locks.meta.packages": [
        "kernel"
    ]
}

PLAY RECAP **********************************************************************************************
192.168.1.11               : ok=4    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

### Crea su propia colección

Al igual que con los roles, puede crear su propia colección con la ayuda del comando `ansible-galaxy`:

```
ansible-galaxy collection init rocky8.rockstarcollection
- Collection rocky8.rockstarcollection was created successfully
```

```
tree rocky8/rockstarcollection/
rocky8/rockstarcollection/
├── docs
├── galaxy.yml
├── plugins
│ └── README.md
├── README.md
└── roles
```

A continuación, puede almacenar sus propios plugins o roles dentro de esta nueva colección.
