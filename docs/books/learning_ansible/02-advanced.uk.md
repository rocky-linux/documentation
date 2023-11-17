---
title: Ansible. Середній рівень
---

# Ansible. Середній рівень

У цьому розділі ви продовжите вивчати, як працювати з Ansible.

****

**Цілі**: В цьому розділі ви дізнаєтеся як:

:heavy_check_mark: працювати зі змінними;       
:heavy_check_mark: використовувати цикли;   
:heavy_check_mark: керувати змінами стану та реагувати на них;   
:heavy_check_mark: керувати асинхронними задачами.

:checkered_flag: **ansible**, **module**, **playbook**

**Знання**: :star: :star: :star:     
**Складність**: :star: :star:

**Час читання**: 30 хвилин

****

У попередньому розділі ви дізналися, як інсталювати Ansible, використовувати його в командному рядку або як писати playbooks, щоб сприяти повторному використанню вашого коду.

У цьому розділі ми можемо розпочати знайомство з деякими більш просунутими уявленнями про те, як використовувати Ansible, а також відкриємо кілька цікавих завдань, які ви будете регулярно використовувати.

## Змінні

!!! Note "Примітка"

    Більше інформації можна [знайти тут](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html).

В Ansible існують різні типи примітивних змінних:

* strings,
* integers,
* booleans.

Ці змінні можна організувати як:

* словники,
* списки.

Змінну можна визначити в різних місцях, наприклад, у підручнику, у ролі або, наприклад, з командного рядка.

Наприклад, із playbook:

```
---
- hosts: apache1
  vars:
    port_http: 80
    service:
      debian: apache2
      rhel: httpd
```

або з командного рядка:

```
$ ansible-playbook deploy-http.yml --extra-vars "service=httpd"
```

Після визначення змінну можна використовувати, викликавши її між подвійними дужками:

* `{{ port_http }}` for a simple value,
* `{{ service['rhel'] }}` or `{{ service.rhel }}` for a dictionary.

Наприклад:

```
- name: make sure apache is started
  ansible.builtin.systemd:
    name: "{{ service['rhel'] }}"
    state: started
```

Звичайно, також можна отримати доступ до глобальних змінних (**facts**) Ansible (тип ОС, IP-адреси, назва віртуальної машини тощо).

### Аутсорсинг змінних

Змінні можуть бути включені у зовнішній файл по відношенню до playbook, у такому випадку цей файл має бути визначений у playbook за допомогою директиви `vars_files`:

```
---
- hosts: apache1
  vars_files:
    - myvariables.yml
```

Файл `myvariables.yml`:

```
---
port_http: 80
ansible.builtin.systemd::
  debian: apache2
  rhel: httpd
```

Його також можна додавати динамічно за допомогою модуля `include_vars`:

```
- name: Include secrets.
  ansible.builtin.include_vars:
    file: vault.yml
```

### Відображення змінної

Щоб відобразити змінну, вам потрібно активувати модуль `debug` наступним чином:

```
- ansible.builtin.debug:
    var: service['debian']
```

Ви також можете використовувати змінну всередині тексту:

```
- ansible.builtin.debug:
    msg: "Print a variable in a message : {{ service['debian'] }}"
```

### Зберегти повернення задачі

Щоб зберегти повернення задачі та отримати до нєї доступ пізніше, потрібно використати ключове слово `register` у самій задачі.

Використання збереженої змінної:

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

!!! Note "Примітка"

    Змінна `homes.stdout_lines` — це список змінних типу string, спосіб організації змінних, з яким ми ще не стикалися.

Доступ до рядків, які складають збережену змінну, можна отримати за допомогою значення `stdout` (яке дозволяє виконувати такі дії, як `homes.stdout.find("core") != -1`), щоб використовувати їх за допомогою циклу (див. `loop`) або просто за їхніми індексами, як показано в попередньому прикладі.

### Вправи

* Напишіть playbook `play-vars.yml`, який друкує назву дистрибутива цільової програми з її основною версією, використовуючи глобальні змінні.

* Напишіть playbook, використовуючи такий словник, щоб відобразити служби, які буде встановлено:

```
service:
  web:
    name: apache
    rpm: httpd
  db:
    name: mariadb
    rpm: mariadb-server
```

Типом за замовчуванням має бути "web".

* Замініть змінну `type` за допомогою командного рядка

* Зовнішні змінні у файлі `vars.yml`

## Керування циклом

За допомогою циклу ви можете повторити завдання по списку, хешу або словнику, наприклад.

!!! Note "Примітка"

    Більше інформації можна [знайти тут](https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html).

Простий приклад використання, створення 4 користувачів:

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

На кожній ітерації циклу значення використаного списку зберігається в змінній `item`, доступній у коді циклу.

Звичайно, список можна визначити у зовнішньому файлі:

```
users:
  - antoine
  - patrick
  - steven
  - xavier
```

і використовувати всередині задачі таким чином (після включення файлу vars):

```
- name: add users
  user:
    name: "{{ item }}"
    state: present
    groups: "users"
  loop: "{{ users }}"
```

Ми можемо використати приклад, який ми побачили під час дослідження збережених змінних, щоб покращити його. Використання збереженої змінної:

```
- name: /home content
  shell: ls /home
  register: homes

- name: Print the directories name
  ansible.builtin.debug:
    msg: "Directory => {{ item }}"
  loop: "{{ homes.stdout_lines }}"
```

Словник також можна використовувати в циклі.

У цьому випадку вам доведеться перетворити словник на елемент за допомогою так званого **фільтра jinja** (jinja — це система шаблонів, яку використовує Ansible): `| dict2items`.

У циклі стає можливим використовувати `item.key`, який відповідає ключу словника, і `item.value`, який відповідає значенням ключа.

Давайте розглянемо це на конкретному прикладі, що показує керування користувачами системи:

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

!!! Note "Примітка"

    Багато чого можна робити з циклами. Ви відкриєте для себе можливості циклів, коли використання Ansible підштовхне вас використовувати їх у більш складний спосіб.

### Вправи

* Відобразити вміст змінної `service` з попередньої вправи за допомогою циклу.

!!! Note "Примітка"

    Вам доведеться перетворити вашу змінну `service`, яка є словником, на список за допомогою фільтра jinja `list`, а саме:

    ```
    {{ service.values() | list }}
    ```

## Умови

!!! Note "Примітка"

    Більше інформації можна знайти [тут](https://docs.ansible.com/ansible/latest/user_guide/playbooks_conditionals.html).

Оператор `when` дуже корисний в багатьох випадках: невиконання певних дій на певних типах серверів, якщо файл або користувач не існує тощо.

!!! Note "Примітка"

    За оператором `when` змінні не потребують подвійних дужок (насправді це вирази Jinja2...).

```
- name: "Reboot only Debian servers"
  reboot:
  when: ansible_os_family == "Debian"
```

Умови можна згрупувати в дужках:

```
- name: "Reboot only CentOS version 6 and Debian version 7"
  reboot:
  when: (ansible_distribution == "CentOS" and ansible_distribution_major_version == "6") or
        (ansible_distribution == "Debian" and ansible_distribution_major_version == "7")
```

Умови, що відповідають логічному AND, можна надати у вигляді списку:

```
- name: "Reboot only CentOS version 6"
  reboot:
  when:
    - ansible_distribution == "CentOS"
    - ansible_distribution_major_version == "6"
```

Ви можете перевірити значення логічного значення та переконатися, що воно істинне:

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

Ви також можете перевірити, що це не відповідає дійсності:

```
  when:
    - file.stat.exists
    - not file.stat.isdir
```

Ймовірно, вам доведеться перевірити, чи існує змінна, щоб уникнути помилок виконання:

```
  when: myboolean is defined and myboolean
```

### Вправи

* Роздрукувати значення `service.web` лише тоді, коли `type` дорівнює `web`.

## Керування змінами: `handlers`

!!! Note "Примітка"

    Додаткову інформацію можна [знайти тут](https://docs.ansible.com/ansible/latest/user_guide/playbooks_handlers.html).

Handlers дозволяють запускати операції, наприклад перезапуск служби, коли відбуваються зміни.

Модуль, будучи ідемпотентним, може виявити, що у віддаленій системі відбулася значна зміна, і таким чином запустити операцію у відповідь на цю зміну. Сповіщення надсилається в кінці блоку завдань з playbook, і операція реакції буде запущена лише один раз, навіть якщо кілька завдань надсилають одне й те саме сповіщення.

![Handlers](images/handlers.png)

Наприклад, кілька завдань можуть вказувати на те, що службу `httpd` потрібно перезапустити через зміну її конфігураційних файлів. Але службу буде перезапущено лише один раз, щоб уникнути багаторазових непотрібних запусків.

```
- name: template configuration file
  template:
    src: template-site.j2
    dest: /etc/httpd/sites-availables/test-site.conf
  notify:
     - restart memcached
     - restart httpd
```

Handler — це завдання, на яке посилається унікальне глобальне ім’я:

* Він активується одним або декількома нотифікаторами.
* Він не запускається відразу, а чекає, поки всі завдання будуть виконані, щоб запуститися.

Приклад handlers:

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

Починаючи з версії 2.2 Ansible, обробники також можуть безпосередньо слухати:

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

## Асинхронні завдання

!!! Note "Примітка"

    Більше інформації можна знайти [тут](https://docs.ansible.com/ansible/latest/user_guide/playbooks_async.html).

За замовчуванням SSH-з’єднання з хостами залишаються відкритими під час виконання різноманітних завдань на всіх вузлах.

Це може спричинити деякі проблеми, зокрема:

* якщо час виконання завдання перевищує тайм-аут підключення SSH
* якщо з'єднання перервано під час дії (наприклад, перезавантаження сервера)

У цьому випадку вам доведеться перейти в асинхронний режим і вказати максимальний час виконання, а також частоту (за замовчуванням 10 секунд), з якою ви будете перевіряти стан хоста.

Якщо вказати значення опитування 0, Ansible виконає завдання та продовжить, не турбуючись про результат.

Ось приклад використання асинхронних завдань, який дозволяє перезапустити сервер і чекати, поки порт 22 знову стане доступним:

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

Ви також можете вирішити запустити довгострокове завдання та забути його (запустити й забути), оскільки виконання не має значення в playbook.

## Результати вправ

* Напишіть playbook `play-vars.yml`, який друкує назву дистрибутива цільової програми з її основною версією, використовуючи глобальні змінні.

```
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

* Напишіть playbook, використовуючи такий словник, щоб відобразити служби, які буде встановлено:

```
service:
  web:
    name: apache
    rpm: httpd
  db:
    name: mariadb
    rpm: mariadb-server
```

Типом за замовчуванням має бути "web".

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

* Замініть змінну `type` за допомогою командного рядка:

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

* Зовнішні змінні у файлі `vars.yml`

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


* Відобразити вміст змінної `service` з попередньої вправи за допомогою циклу.

!!! Note "Примітка"

    Вам доведеться перетворити вашу змінну `service`, яка є словником, на елемент або список за допомогою фільтрів jinja `dict2items` або `list` як це:

    ```
    {{ service | dict2items }}
    ```

    ```
    {{ service.values() | list }}
    ```

З `dict2items`:

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

З `list`:

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

* Роздрукувати значення `service.web` лише тоді, коли `type` дорівнює `web`.

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
