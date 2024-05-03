---
title: Ansible Galaxy
---

# Ansible Galaxy: Колекції та ролі

У цьому розділі ви дізнаєтеся, як використовувати, встановлювати та керувати ролями й колекціями Ansible.

****

**Цілі**: В цьому розділі ви дізнаєтеся як:

:heavy_check_mark: встановлювати та керувати колекціями.  
:heavy_check_mark: встановлювати ролі та керувати ними.

:checkered_flag: **ansible**, **ansible-galaxy**, **roles**, **collections**

**Знання**: :star: :star:  
**Складність**: :star: :star: :star:

**Час для читання**: 40 хвилин

****

[Ansible Galaxy](https://galaxy.ansible.com) надає ролі та колекції Ansible від спільноти Ansible.

На надані елементи можна посилатися в підручниках і використовувати їх із коробки

## Команда `ansible-galaxy`

Команда `ansible-galaxy` керує ролями та колекціями за допомогою [galaxy.ansible.com](http://galaxy.ansible.com).

* Щоб керувати ролями:

```bash
ansible-galaxy role [import|init|install|login|remove|...]
```

| Підкоманди | Функціональність                                  |
| ---------- | ------------------------------------------------- |
| `install`  | встановлює роль.                                  |
| `remove`   | видаляє одну або кілька ролей.                    |
| `list`     | відображає назву та версію встановлених ролей.    |
| `info`     | відображає інформацію про роль.                   |
| `init`     | створює скелет нової ролі.                        |
| `import`   | імпортує ролі з веб-сайту galaxy. Потрібен логін. |

* Щоб керувати колекціями:

```bash
ansible-galaxy collection [import|init|install|login|remove|...]
```

| Підкоманди | Функціональність                                  |
| ---------- | ------------------------------------------------- |
| `init`     | створює скелет нової колекції.                    |
| `install`  | встановлює колекцію.                              |
| `list`     | відображає назву та версію встановлених колекцій. |

## Ролі Ansible

Роль Ansible — це одиниця, яка сприяє багаторазовому використанню playbooks.

!!! Примітка

    Більше інформації можна [знайти тут](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html)

### Встановлення корисних ролей

Щоб підкреслити інтерес використання ролей, я пропоную вам використовувати роль `alemorvan/patchmanagement`, яка дозволить вам виконувати багато завдань (наприклад, до або після оновлення) під час вашого процесу оновлення лише за кілька рядків коду.

Ви можете перевірити код у репозиторії github ролі [тут](https://github.com/alemorvan/patchmanagement).

* Встановіть роль. Для цього потрібна лише одна команда:

```bash
ansible-galaxy role install alemorvan.patchmanagement
```

* Створіть playbook, щоб включити роль:

```bash
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

За допомогою цієї ролі ви можете додавати власні завдання для всього свого інвентарю або лише для цільового вузла.

Давайте створимо завдання, які будуть виконуватися до і після процесу оновлення:

* Створіть папку `custom_tasks`:

```bash
mkdir custom_tasks
```

* Створіть `custom_tasks/pm_before_update_tasks_file.yml` (ви можете змінити назву та вміст цього файлу)

```bash
---
- name: sample task before the update process
  debug:
    msg: "This is a sample tasks, feel free to add your own test task"
```

* Створіть `custom_tasks/pm_after_update_tasks_file.yml` (ви можете змінити назву та вміст цього файлу)

```bash
---
- name: sample task after the update process
  debug:
    msg: "This is a sample tasks, feel free to add your own test task"
```

І запустіть своє перше керування виправленнями (Patch Management):

```bash
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

Досить легко для такого складного процесу, чи не так?

Це лише один приклад того, що можна зробити, використовуючи ролі, надані спільнотою. Перегляньте [galaxy.ansible.com](https://galaxy.ansible.com/), щоб дізнатися про ролі, які можуть бути вам корисні!

Ви також можете створювати власні ролі для власних потреб і публікувати їх в Інтернеті, якщо бажаєте. Це те, що ми коротко розглянемо в наступному розділі.

### Вступ до Role Development

Скелет ролі, який служить відправною точкою для розробки власної ролі, може бути згенерований командою `ansible-galaxy`:

```bash
$ ansible-galaxy role init rocky8
- Role rocky8 was created successfully
```

Команда створить таку структуру дерева, яка містить роль `rocky8`:

```bash
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

Ролі дозволяють відмовитися від необхідності включати файли. Немає необхідності вказувати шляхи до файлів або директиви `include` у playbooks. Вам просто потрібно вказати завдання, і Ansible подбає про включення.

Структура ролі досить очевидна для розуміння.

Змінні просто зберігаються або в `vars/main.yml`, якщо змінні не потрібно перевизначати, або в `default/main.yml`, якщо ви бажаєте залишити можливість перевизначення змінного вмісту поза вашою роллю.

Обробники, файли та шаблони, необхідні для вашого коду, зберігаються в `handlers/main.yml`, `files` і `templates` відповідно.

Залишається лише визначити код для завдань вашої ролі в `tasks/main.yml`.

Коли все це запрацює добре, ви можете використовувати цю роль у своїх playbooks. Ви зможете використовувати свою роль, не турбуючись про технічний аспект її завдань, одночасно налаштовуючи її роботу за допомогою змінних.

### Практична робота: створити першу просту роль

Давайте реалізуємо це за допомогою ролі «go anywhere», яка створить користувача за замовчуванням і встановить пакети програмного забезпечення. Цю роль можна систематично застосовувати до всіх ваших серверів.

#### Змінні

Ми створимо користувача `rockstar` на всіх наших серверах. Оскільки ми не хочемо, щоб цей користувач був перевизначений, давайте визначимо його в `vars/main.yml`:

```bash
---
rocky8_default_group:
  name: rockstar
  gid: 1100
rocky8_default_user:
  name: rockstar
  uid: 1100
  group: rockstar
```

Тепер ми можемо використовувати ці змінні в нашому `tasks/main.yml` без жодного включення.

```bash
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

Щоб перевірити вашу нову роль, давайте створимо playbook `test-role.yml` у тому ж каталозі, що й ваша роль:

```bash
---
- name: Test my role
  hosts: localhost

  roles:

    - role: rocky8
      become: true
      become_user: root
```

і запустимо його:

```bash
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

Вітаємо! Тепер ви можете створювати чудові речі за допомогою playbook лише з кількох рядків.

Давайте розглянемо використання змінних за замовчуванням.

Створіть список пакетів для встановлення за замовчуванням на ваших серверах і порожній список пакетів для видалення. Відредагуйте файли `defaults/main.yml` і додайте ці два списки:

```bash
rocky8_default_packages:
  - tree
  - vim
rocky8_remove_packages: []
```

та використайте їх у своєму `tasks/main.yml`:

```bash
- name: Install default packages (can be overridden)
  package:
    name: "{{ rocky8_default_packages }}"
    state: present

- name: "Uninstall default packages (can be overridden) {{ rocky8_remove_packages }}"
  package:
    name: "{{ rocky8_remove_packages }}"
    state: absent
```

Перевірте свою роль за допомогою попередньо створеного посібника:

```bash
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

Тепер ви можете замінити `rocky8_remove_packages` у своєму playbook та видалити, наприклад, `cockpit`:

```bash
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

```bash
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

Очевидно, що немає обмежень щодо того, наскільки ви можете покращити свою роль. Уявіть, що для одного з ваших серверів вам потрібен пакет, який є у списку тих, які потрібно видалити. Тоді ви можете, наприклад, створити новий список, який можна перевизначити, а потім видалити зі списку пакунків, які потрібно видалити, ті зі списку конкретних пакунків, які потрібно встановити, використовуючи jinja `difference()` фільтр.

```bash
- name: "Uninstall default packages (can be overridden) {{ rocky8_remove_packages }}"
  package:
    name: "{{ rocky8_remove_packages | difference(rocky8_specifics_packages) }}"
    state: absent
```

## Колекції Ansible

Колекції — це формат розповсюдження вмісту Ansible, який може містити посібники, ролі, модулі та плагіни.

!!! Примітка

    Додаткову інформацію можна [знайти тут](https://docs.ansible.com/ansible/latest/user_guide/collections_using.html)

Щоб встановити або оновити колекцію:

```bash
ansible-galaxy collection install namespace.collection [--upgrade]
```

Потім ви можете використовувати щойно встановлену колекцію, використовуючи її простір імен та ім’я перед назвою модуля або назвою ролі:

```bash
- import_role:
    name: namespace.collection.rolename

- namespace.collection.modulename:
    option1: value
```

Ви можете знайти покажчик колекції [тут](https://docs.ansible.com/ansible/latest/collections/index.html).

Давайте встановимо колекцію `community.general`:

```bash
ansible-galaxy collection install community.general
Starting galaxy collection install process
Process install dependency map
Starting collection install process
Downloading https://galaxy.ansible.com/download/community-general-3.3.2.tar.gz to /home/ansible/.ansible/tmp/ansible-local-51384hsuhf3t5/tmpr_c9qrt1/community-general-3.3.2-f4q9u4dg
Installing 'community.general:3.3.2' to '/home/ansible/.ansible/collections/ansible_collections/community/general'
community.general:3.3.2 was installed successfully
```

Тепер ми можемо використовувати нещодавно доступний модуль `yum_versionlock`:

```bash
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

```bash
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

### Створення власної колекції

Як і у випадку з ролями, ви можете створити власну колекцію за допомогою команди `ansible-galaxy`:

```bash
ansible-galaxy collection init rocky8.rockstarcollection
- Collection rocky8.rockstarcollection was created successfully
```

```bash
tree rocky8/rockstarcollection/
rocky8/rockstarcollection/
├── docs
├── galaxy.yml
├── plugins
│   └── README.md
├── README.md
└── roles
```

Потім ви можете зберігати власні плагіни або ролі в цій новій колекції.
