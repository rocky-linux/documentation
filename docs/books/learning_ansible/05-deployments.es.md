---
title: Despliegues con Ansistrano
---

# Despliegues de Ansible con Ansistrano

En este capítulo aprenderá a desplegar aplicaciones con el rol de Ansible [Ansistrano](https://ansistrano.com).

****

**Objetivos** : En este capítulo aprenderá a:

:heavy_check_mark: Implementar Ansistrano;       
:heavy_check_mark: Configurar Ansistrano;       
:heavy_check_mark: Utilizar carpetas compartidas y ficheros entre las versiones deplgadas;       
:heavy_check_mark: Desplegar versiones diferentes de un sitio web desde Git;        
:heavy_check_mark: Reaccionar entre los pasos de los despliegues.

:checkered_flag: **ansible**, **ansistrano**, **roles**, **despliegues**

**Conocimiento**: :star: :star:      
**Complejidad**: :star: :star: :star:

**Tiempo de lectura**: 40 minutos

****

Ansistrano es un rol de Ansible para desplegar fácilmente aplicaciones PHP, Python, etc. Se basa en la funcionalidad de [Capistrano](http://capistranorb.com/).

## Introducción

Ansistrano requiere las siguientes piezas para funcionar correctamente:

* Ansible en la máquina de despliegue,
* `rsync` o `git` la máquina cilente.

Puede descargar el código fuente desde `rsync`, `git`, `scp`, `http`, `S3`, ...

!!! Note

    Para nuestro despliegue de ejemplo, utilizaremos el protocolo `git`.

Ansistrano despliega las aplicaciones mediante los siguientes 5 pasos:

* **Setup**: crea la estructura de directorios para alojar los despliegues;
* **Update Code**: descargar la nueva versión a los equipos de destino;
* **Symlink Shared** y **Symlink**: después de desplegar la nueva versión, el enlace simbólico `current` se modifica para apuntar a esta nueva versión;
* **Clean Up**: para hacer algo de limpieza (eliminando versiones antiguas).

![Fases de un despliegue](images/ansistrano-001.png)

La estructura básica de un despliegue con Ansistrano tiene el siguiente aspecto:

```
/var/www/site/
├── current -> ./releases/20210718100000Z
├── releases
│   └── 20210718100000Z
│       ├── css -> ../../shared/css/
│       ├── img -> ../../shared/img/
│       └── REVISION
├── repo
└── shared
    ├── css/
    └── img/
```

Puede encontrar toda la documentación de Ansistrano en su [repositorio de Github](https://github.com/ansistrano/deploy).

## Laboratorios

Seguirá trabajando en sus 2 servidores:

El servidor de gestión:

* Ansible ya está instalado. Tendrá que instalar el rol `ansistrano.deploy`.

El servidor administrado:

* Tendrá que instalar Apache y desplegar el sitio del cliente.

### Desplegar el servidor web

Para una mayor eficiencia, utilizaremos el rol `geerlingguy.apache` para configurar el servidor:

```
$ ansible-galaxy role install geerlingguy.apache
Starting galaxy role install process
- downloading role 'apache', owned by geerlingguy
- downloading role from https://github.com/geerlingguy/ansible-role-apache/archive/3.1.4.tar.gz
- extracting geerlingguy.apache to /home/ansible/.ansible/roles/geerlingguy.apache
- geerlingguy.apache (3.1.4) was installed successfully
```

Probablemente necesitemos abrir algunas reglas de firewall, por lo que también instalaremos la colección `ansible.posix` para trabajr con su módulo `firewalld`:

```
$ ansible-galaxy collection install ansible.posix
Starting galaxy collection install process
Process install dependency map
Starting collection install process
Downloading https://galaxy.ansible.com/download/ansible-posix-1.2.0.tar.gz to /home/ansible/.ansible/tmp/ansible-local-519039bp65pwn/tmpsvuj1fw5/ansible-posix-1.2.0-bhjbfdpw
Installing 'ansible.posix:1.2.0' to '/home/ansible/.ansible/collections/ansible_collections/ansible/posix'
ansible.posix:1.2.0 was installed successfully
```

Una vez instalados el rol y la colección, podemos crear la primera parte de nuestro playbook, que será:

* Instalar Apache,
* Crear una carpeta de destino para nuestro `vhost`,
* Crear el `vhost` por defecto,
* Abrir el cortafuegos,
* Iniciar o reiniciar Apache.

Consideraciones técnicas:

* Desplegaremos nuestro sitio en la carpeta `/var/www/site/`.
* Como veremos más adelante, `ansistrano` creará un enlace simbólico `current` a la carpeta con la versión actual.
* El código fuente a desplegar contiene una carpeta `html` a la que debe apuntar el vhost. Su `DirectoryIndex` apunta al fichero `index.htm`.
* El despliegue se realiza mediante `git`, el paquete se instalará.

!!! Note

    Por lo tanto, el objetivo de nuestro vhost será `/var/www/site/current/html`.

Nuestro playbook para configurar el servidor: `playbook-config-server.yml`

```
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    apache_global_vhost_settings: |
      DirectoryIndex index.php index.htm
    apache_vhosts:
      - servername: "website"
        documentroot: "{{ dest }}current/html"

  tasks:

    - name: create directory for website
      file:
        path: /var/www/site/
        state: directory
        mode: 0755

    - name: install git
      package:
        name: git
        state: latest

    - name: permit traffic in default zone for http service
      ansible.posix.firewalld:
        service: http
        permanent: yes
        state: enabled
        immediate: yes

  roles:
    - { role: geerlingguy.apache }
```

El playbook se puede aplicar al servidor:

```
$ ansible-playbook playbook-config-server.yml
```

Observe la ejecución de las siguientes tareas:

```
TASK [geerlingguy.apache : Ensure Apache is installed on RHEL.] ****************
TASK [geerlingguy.apache : Configure Apache.] **********************************
TASK [geerlingguy.apache : Add apache vhosts configuration.] *******************
TASK [geerlingguy.apache : Ensure Apache has selected state and enabled on boot.] ***
TASK [permit traffic in default zone for http service] *************************
RUNNING HANDLER [geerlingguy.apache : restart apache] **************************
```

El rol `geerlingguy.apache` nos facilita mucho el trabajo al encargarse de la instalación y configuración de Apache.

Puede comprobar que todo funciona utilizando el comando `curl`:

```
$ curl -I http://192.168.1.11
HTTP/1.1 404 Not Found
Date: Mon, 05 Jul 2021 23:30:02 GMT
Server: Apache/2.4.37 (rocky) OpenSSL/1.1.1g
Content-Type: text/html; charset=iso-8859-1
```

!!! Note

    Todavía no hemos desplegado ningún código, por lo que es normal que la ejecución del comando `curl` devuelva un código HTTP `404`. Pero ya podemos confirmar que el servicio `httpd` está funcionando y que el firewall está abierto.

### Desplegar el software

Ahora que tenemos nuestro servidor configurado, podemos desplegar la aplicación.

Para ello, utilizaremos el rol `ansistrano.deploy` en un segundo playbook dedicado al despliegue de la aplicación (para mayor legibilidad).

```
$ ansible-galaxy role install ansistrano.deploy
Starting galaxy role install process
- downloading role 'deploy', owned by ansistrano
- downloading role from https://github.com/ansistrano/deploy/archive/3.10.0.tar.gz
- extracting ansistrano.deploy to /home/ansible/.ansible/roles/ansistrano.deploy
- ansistrano.deploy (3.10.0) was installed successfully

```

El código fuente del software se puede encontrar en el [repositorio de github](https://github.com/alemorvan/demo-ansible.git).

Crearemos un playbook `playbook-deploy.yml` para gestionar nuestro despliegue:

```
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    ansistrano_deploy_via: "git"
    ansistrano_git_repo: https://github.com/alemorvan/demo-ansible.git
    ansistrano_deploy_to: "{{ dest }}"

  roles:
     - { role: ansistrano.deploy }
```

```
$ ansible-playbook playbook-deploy.yml

PLAY [ansible_clients] *********************************************************

TASK [ansistrano.deploy : ANSISTRANO | Ensure deployment base path exists] *****
TASK [ansistrano.deploy : ANSISTRANO | Ensure releases folder exists]
TASK [ansistrano.deploy : ANSISTRANO | Ensure shared elements folder exists]
TASK [ansistrano.deploy : ANSISTRANO | Ensure shared paths exists]
TASK [ansistrano.deploy : ANSISTRANO | Ensure basedir shared files exists]
TASK [ansistrano.deploy : ANSISTRANO | Get release version] ********************
TASK [ansistrano.deploy : ANSISTRANO | Get release path]
TASK [ansistrano.deploy : ANSISTRANO | GIT | Register ansistrano_git_result variable]
TASK [ansistrano.deploy : ANSISTRANO | GIT | Set git_real_repo_tree]
TASK [ansistrano.deploy : ANSISTRANO | GIT | Create release folder]
TASK [ansistrano.deploy : ANSISTRANO | GIT | Sync repo subtree[""] to release path]
TASK [ansistrano.deploy : ANSISTRANO | Copy git released version into REVISION file]
TASK [ansistrano.deploy : ANSISTRANO | Ensure shared paths targets are absent]
TASK [ansistrano.deploy : ANSISTRANO | Create softlinks for shared paths and files]
TASK [ansistrano.deploy : ANSISTRANO | Ensure .rsync-filter is absent]
TASK [ansistrano.deploy : ANSISTRANO | Setup .rsync-filter with shared-folders]
TASK [ansistrano.deploy : ANSISTRANO | Get current folder]
TASK [ansistrano.deploy : ANSISTRANO | Remove current folder if it's a directory]
TASK [ansistrano.deploy : ANSISTRANO | Change softlink to new release]
TASK [ansistrano.deploy : ANSISTRANO | Clean up releases]

PLAY RECAP ********************************************************************************************************************************************************************************************************
192.168.1.11               : ok=25   changed=8    unreachable=0    failed=0    skipped=14   rescued=0    ignored=0   

```

¡Se pueden hacer muchas cosas con sólo 11 líneas de código!

```
$ curl http://192.168.1.11
<html>
<head>
<title>Demo Ansible</title>
</head>
<body>
<h1>Version Master</h1>
</body>
<html>
```

### Comprobaciones en el servidor

Ahora puede conectarse vía ssh a su máquina cliente.

* Ejecute el comando `tree` en el directorio`/var/www/site/`:

```
$ tree /var/www/site/
/var/www/site
├── current -> ./releases/20210722155312Z
├── releases
│   └── 20210722155312Z
│       ├── REVISION
│       └── html
│           └── index.htm
├── repo
│   └── html
│       └── index.htm
└── shared
```

Por favor, ten en cuenta:

* el enlace simbólico `current` a la versión `./releases/20210722155312Z`
* la presencia de un directorio llamado `shared`
* la repsencia de repositorios de git en `./repo/`

* Desde el servidor de Ansible, reinicie el despliegue **3** veces, y luego compruebe en el cliente.

```
$ tree /var/www/site/
var/www/site
├── current -> ./releases/20210722160048Z
├── releases
│   ├── 20210722155312Z
│   │   ├── REVISION
│   │   └── html
│   │       └── index.htm
│   ├── 20210722160032Z
│   │   ├── REVISION
│   │   └── html
│   │       └── index.htm
│   ├── 20210722160040Z
│   │   ├── REVISION
│   │   └── html
│   │       └── index.htm
│   └── 20210722160048Z
│       ├── REVISION
│       └── html
│           └── index.htm
├── repo
│   └── html
│       └── index.htm
└── shared
```

Por favor, ten en cuenta:

* `ansistrano` mantiene las 4 ultimas versiones,
* el enlace simbólico `current` ahora apunta a la última versión

### Limitar el número de versiones

La variable `ansistrano_keep_releases` se utiliza para especificar el número de versiones a mantener.

* Utilizando la variable `ansistrano_keep_releases`, mantén sólo 3 versiones del proyecto. Compruebe.

```
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    ansistrano_deploy_via: "git"
    ansistrano_git_repo: https://github.com/alemorvan/demo-ansible.git
    ansistrano_deploy_to: "{{ dest }}"
    ansistrano_keep_releases: 3

  roles:
     - { role: ansistrano.deploy }
```

```
---
$ ansible-playbook -i hosts playbook-deploy.yml
```

En la máquina cliente:

```
$ tree /var/www/site/
/var/www/site
├── current -> ./releases/20210722160318Z
├── releases
│   ├── 20210722160040Z
│   │   ├── REVISION
│   │   └── html
│   │       └── index.htm
│   ├── 20210722160048Z
│   │   ├── REVISION
│   │   └── html
│   │       └── index.htm
│   └── 20210722160318Z
│       ├── REVISION
│       └── html
│           └── index.htm
├── repo
│   └── html
│       └── index.htm
└── shared
```

### Uso de shared_paths y shared_files


```
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    ansistrano_deploy_via: "git"
    ansistrano_git_repo: https://github.com/alemorvan/demo-ansible.git
    ansistrano_deploy_to: "{{ dest }}"
    ansistrano_keep_releases: 3
    ansistrano_shared_paths:
      - "img"
      - "css"
    ansistrano_shared_files:
      - "logs"

  roles:
     - { role: ansistrano.deploy }
```

En el equipo cliente, cree el archivo `logs` en el directorio `shared`:

```
sudo touch /var/www/site/shared/logs
```

Despues ejecute el playbook:

```
TASK [ansistrano.deploy : ANSISTRANO | Ensure shared paths targets are absent] *******************************************************
ok: [192.168.10.11] => (item=img)
ok: [192.168.10.11] => (item=css)
ok: [192.168.10.11] => (item=logs/log)

TASK [ansistrano.deploy : ANSISTRANO | Create softlinks for shared paths and files] **************************************************
changed: [192.168.10.11] => (item=img)
changed: [192.168.10.11] => (item=css)
changed: [192.168.10.11] => (item=logs)
```

En la máquina cliente:

```
$  tree -F /var/www/site/
/var/www/site/
├── current -> ./releases/20210722160631Z/
├── releases/
│   ├── 20210722160048Z/
│   │   ├── REVISION
│   │   └── html/
│   │       └── index.htm
│   ├── 20210722160318Z/
│   │   ├── REVISION
│   │   └── html/
│   │       └── index.htm
│   └── 20210722160631Z/
│       ├── REVISION
│       ├── css -> ../../shared/css/
│       ├── html/
│       │   └── index.htm
│       ├── img -> ../../shared/img/
│       └── logs -> ../../shared/logs
├── repo/
│   └── html/
│       └── index.htm
└── shared/
    ├── css/
    ├── img/
    └── logs
```

Tenga en cuenta que la última versión contiene 3 enlaces:   `css`, `img`, and `logs`

* desde `/var/www/site/releases/css` al directorio `../../shared/css/`.
* desde `/var/www/site/releases/img` al directorio `../../shared/img/`.
* desde `/var/www/site/releases/logs` al archivo `../../shared/logs`.

Por lo tanto, los archivos contenidos en estas 2 carpetas y el archivo `logs` son siempre accesibles a través de las siguientes rutas:

* `/var/www/site/current/css/`,
* `/var/www/site/current/img/`,
* `/var/www/site/current/logs`,

pero sobre todo se mantendrán de un despliegue a otro.

### Utilizar un subdirectorio del repositorio para el despliegue

En nuestro caso, el repositorio contiene una carpeta `html`, que contiene los archivos del sitio.

* Para evitar este nivel extra de directorio, utilice la variable `ansistrano_git_repo_tree` especificando la ruta del subdirectorio a utilizar.

¡No olvide modificar la configuración de Apache para tener en cuenta este cambio!

Cambie el playbook para la configuración del servidor `playbook-config-server.yml`

```yaml
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    apache_global_vhost_settings: |
      DirectoryIndex index.php index.htm
    apache_vhosts:
      - servername: "website"
    documentroot: "{{ dest }}current/" # <1>

  tasks:

    - name: create directory for website
      file:
        path: /var/www/site/
        state: directory
        mode: 0755

    - name: install git
      package:
        name: git
        state: latest

  roles:
    - { role: geerlingguy.apache }
```

<1> Edite esta línea

Cambie el playbook para el despliegue `playbook-deploy.yml`

```
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    ansistrano_deploy_via: "git"
    ansistrano_git_repo: https://github.com/alemorvan/demo-ansible.git
    ansistrano_deploy_to: "{{ dest }}"
    ansistrano_keep_releases: 3
    ansistrano_shared_paths:
      - "img"
      - "css"
    ansistrano_shared_files:
      - "log"
    ansistrano_git_repo_tree: 'html' # <1>

  roles:
     - { role: ansistrano.deploy }
```

<1> Edite esta línea

* No se olvide de ejecutar los dos playbooks

* Compruebe en la máquina cliente:

```
$  tree -F /var/www/site/
/var/www/site/
├── current -> ./releases/20210722161542Z/
├── releases/
│   ├── 20210722160318Z/
│   │   ├── REVISION
│   │   └── html/
│   │       └── index.htm
│   ├── 20210722160631Z/
│   │   ├── REVISION
│   │   ├── css -> ../../shared/css/
│   │   ├── html/
│   │   │   └── index.htm
│   │   ├── img -> ../../shared/img/
│   │   └── logs -> ../../shared/logs
│   └── 20210722161542Z/
│       ├── REVISION
│       ├── css -> ../../shared/css/
│       ├── img -> ../../shared/img/
│       ├── index.htm
│       └── logs -> ../../shared/logs
├── repo/
│   └── html/
│       └── index.htm
└── shared/
    ├── css/
    ├── img/
    └── logs
```

<1> Obsérvese la ausencia de `html`

### Gestión de las ramas o de las etiquetas de Git

La variable `ansistrano_git_branch` se utiliza para especificar una `rama` o una `etiqueta` de Git a desplegar.

* Despliegue de la rama `releases/v1.1.0`:

```
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    ansistrano_deploy_via: "git"
    ansistrano_git_repo: https://github.com/alemorvan/demo-ansible.git
    ansistrano_deploy_to: "{{ dest }}"
    ansistrano_keep_releases: 3
    ansistrano_shared_paths:
      - "img"
      - "css"
    ansistrano_shared_files:
      - "log"
    ansistrano_git_repo_tree: 'html'
    ansistrano_git_branch: 'releases/v1.1.0'

  roles:
     - { role: ansistrano.deploy }
```

!!! Note

    Puede divertirse, durante el despliegue, refrescando su navegador, para ver el cambio en 'vivo'.

```
$ curl http://192.168.1.11
<html>
<head>
<title>Demo Ansible</title>
</head>
<body>
<h1>Version 1.0.1</h1>
</body>
<html>
```

* Despliegue de la etiqueta `v2.0.0`:

```
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    ansistrano_deploy_via: "git"
    ansistrano_git_repo: https://github.com/alemorvan/demo-ansible.git
    ansistrano_deploy_to: "{{ dest }}"
    ansistrano_keep_releases: 3
    ansistrano_shared_paths:
      - "img"
      - "css"
    ansistrano_shared_files:
      - "log"
    ansistrano_git_repo_tree: 'html'
    ansistrano_git_branch: 'v2.0.0'

  roles:
     - { role: ansistrano.deploy }
```

```
$ curl http://192.168.1.11
<html>
<head>
<title>Demo Ansible</title>
</head>
<body>
<h1>Version 2.0.0</h1>
</body>
<html>
```

### Acciones entre los pasos del despliegue

Un despliegue con Ansistrano respeta los siguientes pasos:

* `Setup`
* `Update Code`
* `Symlink Shared`
* `Symlink Shared`
* `Clean Up`

Es posible intervenir antes y después de cada uno de estos pasos.

![Fases de un despliegue](images/ansistrano-001.png)

Se puede incluir un playbook a través de las variables previstas para ello:

* `ansistrano_before_<task>_tasks_file`
* o `ansistrano_after_<task>_tasks_file`

* Ejemplo sencillo: Enviar un correo electrónico (o lo que quiera como una notificación de Slack) al comenzar el despliegue:


```
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    ansistrano_deploy_via: "git"
    ansistrano_git_repo: https://github.com/alemorvan/demo-ansible.git
    ansistrano_deploy_to: "{{ dest }}"
    ansistrano_keep_releases: 3
    ansistrano_shared_paths:
      - "img"
      - "css"
    ansistrano_shared_files:
      - "logs"
    ansistrano_git_repo_tree: 'html'
    ansistrano_git_branch: 'v2.0.0'
    ansistrano_before_setup_tasks_file: "{{ playbook_dir }}/deploy/before-setup-tasks.yml"

  roles:
     - { role: ansistrano.deploy }
```

Cree el fichero `deploy/before-setup-tasks.yml`:

```
---
- name: Send a mail
  mail:
    subject: Starting deployment on {{ ansible_hostname }}.
  delegate_to: localhost
```

```
TASK [ansistrano.deploy : include] *************************************************************************************
included: /home/ansible/deploy/before-setup-tasks.yml for 192.168.10.11

TASK [ansistrano.deploy : Send a mail] *************************************************************************************
ok: [192.168.10.11 -> localhost]
```

```
[root] # mailx
Heirloom Mail version 12.5 7/5/10.  Type ? for help.
"/var/spool/mail/root": 1 message 1 new
>N  1 root@localhost.local  Tue Aug 21 14:41  28/946   "Starting deployment on localhost."
```

* Probablemente tendrá que reiniciar algunos servicios al final del despliegue, para vaciar las cachés, por ejemplo. Vamos a reiniciar Apache al final del despliegue:

```
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    ansistrano_deploy_via: "git"
    ansistrano_git_repo: https://github.com/alemorvan/demo-ansible.git
    ansistrano_deploy_to: "{{ dest }}"
    ansistrano_keep_releases: 3
    ansistrano_shared_paths:
      - "img"
      - "css"
    ansistrano_shared_files:
      - "logs"
    ansistrano_git_repo_tree: 'html'
    ansistrano_git_branch: 'v2.0.0'
    ansistrano_before_setup_tasks_file: "{{ playbook_dir }}/deploy/before-setup-tasks.yml"
    ansistrano_after_symlink_tasks_file: "{{ playbook_dir }}/deploy/after-symlink-tasks.yml"

  roles:
     - { role: ansistrano.deploy }
```

Cree el fichero `deploy/after-symlink-tasks.yml`:

```
---
- name: restart apache
  systemd:
    name: httpd
    state: restarted
```

```
TASK [ansistrano.deploy : include] *************************************************************************************
included: /home/ansible/deploy/after-symlink-tasks.yml for 192.168.10.11

TASK [ansistrano.deploy : restart apache] **************************************************************************************
changed: [192.168.10.11]
```

Como ha visto durante este capítulo, Ansible puede mejorar mucho la vida del administrador de sistemas. Los roles muy inteligentes como Ansistrano se convierten rápidamente en indispensables.

El uso de Ansistrano garantiza el respeto de las buenas prácticas en los despliegues, reduce el tiempo necesario para poner un sistema nuevo en producción y evita el riesgo de posibles errores humanos. ¡Las máquinas funcionan rápidas, bien y rara vez cometen errores.!
