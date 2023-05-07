---
title: Ansible Intermedio
---

# Ansible Intermedio

En este capítulo seguirá aprendiendo a trabajar con Ansible.

****

**Objetivos** : En este capítulo aprenderá a:

:heavy_check_mark: trabajar con variables;
:heavy_check_mark: utilizar loops;
:heavy_check_mark: gestionar cambios de estado y reaccionar ante ellos;
:heavy_check_mark: gestionar tareas asíncronas.

:checkered_flag: **ansible**, **modulo**, **playbook**

**Conocimiento**: :star: :star: :star:
**Complejidad**: :star: :star:

**Tiempo de lectura**: 30 minutos

****

En el capítulo anterior, aprendió a instalar Ansible, a utilizar en la línea de comandos o a escribir libros de jugadas para promover la reutilización de tu código.

En este capítulo, podemos empezar a descubrir algunas nociones más avanzadas sobre cómo utilizar Ansible, y descubrir algunas tareas interesantes que utilizará regularmente.

## Las variables

!!! Note

    Puede encontrar más información [aquí](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html).

En Ansible, hay diferentes tipos de variables primitivas:

* Cadenas de texto.
* Números enteros.
* Valores booleanos.

Estas variables pueden organizarse como:

* Diccionarios.
* Listas.

Una variable se puede definit en diferentes lugares, como un libro de jugadas, un rol o desde la línea de comandos por ejemplo.

Por ejemplo, desde un libro de jugadas:

```
---
- hosts: apache1
  vars:
    port_http: 80
    service:
      debian: apache2
      rhel: httpd
```

o desde la línea de comandos:

```
$ ansible-playbook deploy-http.yml --extra-vars "service=httpd"
```

Una vez definida, una variable puede utilizarse llamándola entre llaves dobles:

* `{{ port_http }}` fpara un valor simple,
* `{{ service['rhel'] }}` or `{{ service.rhel }}` para un diccionario.

Por ejemplo:

```
- name: make sure apache is started
  ansible.builtin.systemd:
    name: "{{ service['rhel'] }}"
    state: started
```

Por supuesto, también es posible acceder a las variables globales (los **hechos**) de Ansible (tipo de SO, direcciones IP, nombre de la VM, etc.).

### Externalización de variables

Las variables se pueden incluir en un archivo externo al libro de jugadas, en cuyo caso este archivo debe definirse en el libro de jugadas mediante la directiva `vars_files`:

```
---
- hosts: apache1
  vars_files:
    - myvariables.yml
```

El archivo `myvariables.yml`:

```
---
port_http: 80
ansible.builtin.systemd::
  debian: apache2
  rhel: httpd
```

También se pueden añadir dinámicamente mediante el uso del módulo `include_vars`:

```
- name: Include secrets.
  ansible.builtin.include_vars:
    file: vault.yml
```

### Mostrar una variable

Para visualizar una variable, hay que activar el módulo `debug` de la siguiente manera:

```
- ansible.builtin.debug:
    var: "{{ service['debian'] }}"
```

También puede utilizar la variable dentro de un texto:

```
- ansible.builtin.debug:
    msg: "Print a variable in a message : {{ service['debian'] }}"
```

### Guardar el retorno de una tarea

Para guardar el retorno de una tarea y poder acceder a ella posteriormente, hay que utilizar la palabra clave `register` dentro de la propia tarea.

Utilización de una variable almacenada:

```
- name: /home content
  shell: ls /home
  register: homes

- name: Print the first directory name
  ansible.builtin.debug:
    var: homes.stdout_lines[0]

- name: Print the first directory name
  ansible.builtin.debug:
    var: homes.stdout_lines[1]
```

!!! Note

    La variable `homes.stdout_lines` es una lista de variables de tipo string, una forma de organizar las variables que aún no habíamos encontrado.

Se puede acceder a las cadenas que componen la variable almacenada a través del valor `stdout` (lo que permite hacer cosas como `homes.stdout.find("core") != -1`), explotarlas mediante un bucle (ver `loop`), o simplemente por sus índices como se ha visto en el ejemplo anterior.

### Ejercicios

* Escriba un libro de jugadas `play-vars.yml` que imprima el nombre de distribución del objetivo con su versión principal, utilizando variables globales.

* Escriba un libro de jugadas utilizando el siguiente diccionario para mostrar los servicios que se instalarán:

```
service:
  web:
    name: apache
    rpm: httpd
  db:
    name: mariadb
    rpm: mariadb-server
```

El tipo por defecto debe ser "web".

* Anular la variable `type` utilizando la línea de comandos

* Externalizar variables en un archivo `vars.yml`

## Gestion de los bucles

Con la ayuda de los bucles, puede iterar una tarea sobre una lista, un hash, o diccionario, por ejemplo.

!!! Note

    Puede encontrar más información [aquí](https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html).

Ejemplo sencillo de uso, creación de 4 usuarios:

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
```

En cada iteración del bucle, el valor de la lista utilizada se almacena en la variable `item`, accesible en el código del bucle.

Por supuesto, se puede definir una lista dentro de un archivo externo:

```
users:
  - antoine
  - patrick
  - steven
  - xavier
```

y utilizarla dentro de la tarea como ésta (después de haber incluido el archivo de variables):

```
- name: add users
  user:
    name: "{{ item }}"
    state: present
    groups: "users"
  loop: "{{ users }}"
```

Podemos utilizar el ejemplo visto durante el estudio de variables almacenadas para mejorarlo. Utilización de una variable almacenada:

```
- name: /home content
  shell: ls /home
  register: homes

- name: Print the directories name
  ansible.builtin.debug:
    msg: "Directory => {{ item }}"
  loop: "{{ homes.stdout_lines }}"
```

Un diccionario también se puede utilizar en un bucle.

En este caso, tendrá que transformar el diccionario en un elemento con lo que se llama **filtro jinja** (jinja es el motor de plantillas utilizado por Ansible): `| dict2items`.

En el bucle, es posible usar `item.key` que corresponde a la clave del diccionario, y `item.value` que corresponde a los valores de la clave.

Veámoslo a través de un ejemplo concreto, mostrando la gestión de los usuarios del sistema:

```
---
- hosts: rocky8
  become: true
  become_user: root
  vars:
    users:
      antoine:
        group: users
        state: present
      steven:
        group: users
        state: absent

  tasks:

  - name: Manage users
    user:
      name: "{{ item.key }}"
      group: "{{ item.value.group }}"
      state: "{{ item.value.state }}"
    loop: "{{ users | dict2items }}"
```

!!! Note

    Se pueden hacer muchas cosas con los bucles. Descubrirá las posibilidades que ofrecen los bucles cuando su uso de Ansible le empuja a utilizarlos de una manera más compleja.

### Ejercicios

* Mostrar el contenido de la variable `servicie` del ejercicio anterior utilizando un bucle.

!!! Note

    Tendrá que transformar su variable `service`, la cual es un diccionario, a una lista con la ayuda del filtro de jinja `list` como este:

    ```
    {{ service.values() | list }}
    ```

## Condicionales

!!! Note

    Puede encontrar más información [aquí](https://docs.ansible.com/ansible/latest/user_guide/playbooks_conditionals.html).

La sentencia `when` es muy útil en muchos casos: no realizar ciertas acciones en determinados tipos de servidores, si un fichero o un usuario no existe, etc.

!!! Note

    Detrás de la sentencia `when` las variables no necesitan dobles llaves (de hecho son expresiones Jinja2...).

```
- name: "Reboot only Debian servers"
  reboot:
  when: ansible_os_family == "Debian"
```

Las condiciones se pueden agrupar con paréntesis:

```
- name: "Reboot only CentOS version 6 and Debian version 7"
  reboot:
  when: (ansible_distribution == "CentOS" and ansible_distribution_major_version == "6") or
        (ansible_distribution == "Debian" and ansible_distribution_major_version == "7")
```

Las condiciones correspondientes a una lógica AND se pueden proporcionar como una lista:

```
- name: "Reboot only CentOS version 6"
  reboot:
  when:
    - ansible_distribution == "CentOS"
    - ansible_distribution_major_version == "6"
```

Puede comprobar el valor de un booleano y verificar que si es verdadero:

```
- name: check if directory exists
  stat:
    path: /home/ansible
  register: directory

- ansible.builtin.debug:
    var: directory

- ansible.builtin.debug:
    msg: The directory exists
  when:
    - directory.stat.exists
    - directory.stat.isdir
```

Tambien puede comprobar si no es verdadero:

```
  when:
    - file.stat.exists
    - not file.stat.isdir
```

Probablemente tendrá que comprobar que existe una variable para evitar errores de ejecución:

```
  when: myboolean is defined and myboolean
```

### Ejercicios

* Imprima el valor de `service.web` solo cuando `type` sea igual a `web`.

## Gestionar los cambios: los `manejadores`

!!! Note

    Puede encontrar más información [aquí](https://docs.ansible.com/ansible/latest/user_guide/playbooks_handlers.html).

Los manejadores permiten iniciar operaciones, como reiniciar un servicio, cuando ocurren cambios.

Un módulo, al ser idempotente, un libro de jugadas puede detectar que se ha producido un cambio significativo en un sistema remoto, y así desencadenar una operación en reacción a este cambio. Se envía una notificación al final de un bloque de tareas de un libro de jugadas, y la operación de reacción se desencadenará una sola vez aunque varias tareas envíen la misma notificación.

![Manejadores](images/handlers.png)

Por ejemplo, varias tareas pueden indicar que el servicio `httpd` necesita reiniciarse debido a un cambio en sus archivos de configuración. Pero el servicio sólo se reiniciará una vez para evitar múltiples inicios innecesarios.

```
- name: template configuration file
  template:
    src: template-site.j2
    dest: /etc/httpd/sites-availables/test-site.conf
  notify:
     - restart memcached
     - restart httpd
```

Un manejador es un tipo de tarea referenciada por un nombre global único:

* Se activa por una o más notificaciones.
* No se inicia inmediatamente, pero espera hasta que todas las tareas estén completas para ejecutarse.

Ejemplo de manejadores:

```
handlers:

  - name: restart memcached
    systemd:
      name: memcached
      state: restarted

  - name: restart httpd
    systemd:
      name: httpd
      state: restarted
```

Desde la versión 2.2 de Ansible, los manejadores también pueden escuchar directamente:

```
handlers:

  - name: restart memcached
    systemd:
      name: memcached
      state: restarted
    listen: "web services restart"

  - name: restart apache
    systemd:
      name: apache
      state: restarted
    listen: "web services restart"

tasks:
    - name: restart everything
      command: echo "this task will restart the web services"
      notify: "web services restart"
```

## Tareas asíncronas

!!! Note

    Puede encontrar más información [aquí](https://docs.ansible.com/ansible/latest/user_guide/playbooks_async.html).

Por defecto, las conexiones SSH a los hosts permanecen abiertas durante la ejecución de varias tareas en todos los nodos.

Esto puede provocar algunos problemas, especialmente:

* Si el tiempo de ejecución de la tarea es más largo que el tiempo de espera de la conexión SSH.
* Si la conexión es interrumpida durante la acción (por ejemplo por el reinicio de un servidor).

En este caso, tendrá que cambiar al modo asíncrono y especificar un tiempo máximo de ejecución así como la frecuencia (por defecto 10s) con la que comprobará el estado del host.

Al especificar un valor de 0, Ansible ejecutará la tarea y continuará sin preocuparse por el resultado.

Aquí hay un ejemplo que utiliza tareas asincrónicas, que permite reiniciar un servidor y esperar a que el puerto 22 esté accesible de nuevo:

```
# Wait 2s and launch the reboot
- name: Reboot system
  shell: sleep 2 && shutdown -r now "Ansible reboot triggered"
  async: 1
  poll: 0
  ignore_errors: true
  become: true
  changed_when: False

  # Wait the server is available
  - name: Waiting for server to restart (10 mins max)
    wait_for:
      host: "{{ inventory_hostname }}"
      port: 22
      delay: 30
      state: started
      timeout: 600
    delegate_to: localhost
```

También puede decidir si lanza una tarea de larga ejecución y olvidarse de ella (fire and forget) porque la ejecución no es relevante en el playbook.

## Resultados de los ejercicios

* Escriba un libro de jugadas `play-vars.yml` que imprima el nombre de la distribución de los objetivos con su versión principal, utilizando variables globales.

```
---
- hosts: ansible_clients

  tasks:

    - name: Print globales variables
      debug:
        msg: "The distribution is {{ ansible_distribution }} version {{ ansible_distribution_major_version }}"
```

```
$ ansible-playbook play-vars.yml

PLAY [ansible_clients] *********************************************************************************

TASK [Gathering Facts] *********************************************************************************
ok: [192.168.1.11]

TASK [Print globales variables] ************************************************************************
ok: [192.168.1.11] => {
    "msg": "The distribution is Rocky version 8"
}

PLAY RECAP *********************************************************************************************
192.168.1.11               : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

* Escriba un libro de jugadas utilizando el siguiente diccionario para mostrar los servicios que se instalarán:

```
service:
  web:
    name: apache
    rpm: httpd
  db:
    name: mariadb
    rpm: mariadb-server
```

El tipo por defecto debe ser "web".

```
---
- hosts: ansible_clients
  vars:
    type: web
    service:
      web:
        name: apache
        rpm: httpd
      db:
        name: mariadb
        rpm: mariadb-server

  tasks:

    - name: Print a specific entry of a dictionary
      debug:
        msg: "The {{ service[type]['name'] }} will be installed with the packages {{ service[type].rpm }}"
```

```
$ ansible-playbook display-dict.yml

PLAY [ansible_clients] *********************************************************************************

TASK [Gathering Facts] *********************************************************************************
ok: [192.168.1.11]

TASK [Print a specific entry of a dictionnaire] ********************************************************
ok: [192.168.1.11] => {
    "msg": "The apache will be installed with the packages httpd"
}

PLAY RECAP *********************************************************************************************
192.168.1.11               : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

* Anular la variable `type` utilizando la línea de comandos:

```
ansible-playbook --extra-vars "type=db" display-dict.yml

PLAY [ansible_clients] *********************************************************************************

TASK [Gathering Facts] *********************************************************************************
ok: [192.168.1.11]

TASK [Print a specific entry of a dictionary] ********************************************************
ok: [192.168.1.11] => {
    "msg": "The mariadb will be installed with the packages mariadb-server"
}

PLAY RECAP *********************************************************************************************
192.168.1.11               : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

* Externalizar variables en un archivo `vars.yml`

```
type: web
service:
  web:
    name: apache
    rpm: httpd
  db:
    name: mariadb
    rpm: mariadb-server
```

```
---
- hosts: ansible_clients
  vars_files:
    - vars.yml

  tasks:

    - name: Print a specific entry of a dictionary
      debug:
        msg: "The {{ service[type]['name'] }} will be installed with the packages {{ service[type].rpm }}"
```


* Mostrar el contenido de la variable `service` del ejercicio anterior utilizando un bucle.

!!! Note

    Tendrá que transformar su variable `service`, que es un diccionario, en un elemento o una lista con la ayuda de los filtros jinja `dict2items` o `list` como este:

    ```
    {{ service | dict2items }}
    ```

    ```
    {{ service.values() | list }}
    ```

Con `dict2items`:

```
---
- hosts: ansible_clients
  vars_files:
    - vars.yml

  tasks:

    - name: Print a dictionary variable with a loop
      debug:
        msg: "{{item.key }} | The {{ item.value.name }} will be installed with the packages {{ item.value.rpm }}"
      loop: "{{ service | dict2items }}"
```

```
$ ansible-playbook display-dict.yml

PLAY [ansible_clients] *********************************************************************************

TASK [Gathering Facts] *********************************************************************************
ok: [192.168.1.11]

TASK [Print a dictionary variable with a loop] ********************************************************
ok: [192.168.1.11] => (item={'key': 'web', 'value': {'name': 'apache', 'rpm': 'httpd'}}) => {
    "msg": "web | The apache will be installed with the packages httpd"
}
ok: [192.168.1.11] => (item={'key': 'db', 'value': {'name': 'mariadb', 'rpm': 'mariadb-server'}}) => {
    "msg": "db | The mariadb will be installed with the packages mariadb-server"
}

PLAY RECAP *********************************************************************************************
192.168.1.11               : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

Con `list`:

```
---
- hosts: ansible_clients
  vars_files:
    - vars.yml

  tasks:

    - name: Print a dictionary variable with a loop
      debug:
        msg: "The {{ item.name }} will be installed with the packages {{ item.rpm }}"
      loop: "{{ service.values() | list}}"
~
```

```
$ ansible-playbook display-dict.yml

PLAY [ansible_clients] *********************************************************************************

TASK [Gathering Facts] *********************************************************************************
ok: [192.168.1.11]

TASK [Print a dictionary variable with a loop] ********************************************************
ok: [192.168.1.11] => (item={'name': 'apache', 'rpm': 'httpd'}) => {
    "msg": "The apache will be installed with the packages httpd"
}
ok: [192.168.1.11] => (item={'name': 'mariadb', 'rpm': 'mariadb-server'}) => {
    "msg": "The mariadb will be installed with the packages mariadb-server"
}

PLAY RECAP *********************************************************************************************
192.168.1.11               : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

* Imprime el valor de `service.web` solo cuando `type` sea igual a `web`.

```
---
- hosts: ansible_clients
  vars_files:
    - vars.yml

  tasks:

    - name: Print a dictionary variable
      debug:
        msg: "The {{ service.web.name }} will be installed with the packages {{ service.web.rpm }}"
      when: type == "web"


    - name: Print a dictionary variable
      debug:
        msg: "The {{ service.db.name }} will be installed with the packages {{ service.db.rpm }}"
      when: type == "db"
```

```
$ ansible-playbook display-dict.yml

PLAY [ansible_clients] *********************************************************************************

TASK [Gathering Facts] *********************************************************************************
ok: [192.168.1.11]

TASK [Print a dictionary variable] ********************************************************************
ok: [192.168.1.11] => {
    "msg": "The apache will be installed with the packages httpd"
}

TASK [Print a dictionary variable] ********************************************************************
skipping: [192.168.1.11]

PLAY RECAP *********************************************************************************************
192.168.1.11               : ok=2    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

$ ansible-playbook --extra-vars "type=db" display-dict.yml

PLAY [ansible_clients] *********************************************************************************

TASK [Gathering Facts] *********************************************************************************
ok: [192.168.1.11]

TASK [Print a dictionary variable] ********************************************************************
skipping: [192.168.1.11]

TASK [Print a dictionary variable] ********************************************************************
ok: [192.168.1.11] => {
    "msg": "The mariadb will be installed with the packages mariadb-server"
}

PLAY RECAP *********************************************************************************************
192.168.1.11               : ok=2    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```
