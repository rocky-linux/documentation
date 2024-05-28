---
title: Керування файлами
---

# Ansible - Управління файлами

У цьому розділі ви дізнаєтесь, як керувати файлами за допомогою Ansible.

****

**Цілі**: В цьому розділі ви дізнаєтеся як:

:heavy_check_mark: змінити вміст файлу;  
:heavy_check_mark: завантажити файли на цільові сервери;  
:heavy_check_mark: отримати файли з цільових серверів.

:checkered_flag: **ansible**, **module**, **files**

**Знання**: :star: :star:  
**Складність**: :star:

**Час читання**: 20 хвилин

****

Залежно від ваших потреб вам доведеться використовувати різні модулі Ansible для зміни файлів конфігурації системи.

## Модуль `ini_file`

Якщо ви хочете змінити файл INI (розділ між парами `[]` і `key=value`), найпростішим способом є використання модуля `ini_file`.

!!! Важливо

    Більше інформації можна [знайти тут](https://docs.ansible.com/ansible/latest/collections/community/general/ini_file_module.html).

Модуль вимагає:

* Значення розділу
* Назву опції
* Нове значення

Приклад використання:

```bash
- name: change value on inifile
  community.general.ini_file:
    dest: /path/to/file.ini
    section: SECTIONNAME
    option: OPTIONNAME
    value: NEWVALUE
```

## Модуль `lineinfile`

Щоб переконатися, що рядок присутній у файлі, або коли один рядок у файлі потрібно додати або змінити, використовуйте модуль `linefile`.

!!! Важливо

    Більше інформації можна [знайти тут](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html).

У цьому випадку рядок у файлі, який потрібно змінити, буде знайдено за допомогою регулярного виразу.

Наприклад, щоб переконатися, що рядок, який починається з `SELINUX=` у файлі `/etc/selinux/config`, містить значення `enforcing`:

```bash
- ansible.builtin.lineinfile:
    path: /etc/selinux/config
    regexp: '^SELINUX='
    line: 'SELINUX=enforcing'
```

## Модуль `copy`

Якщо файл необхідно скопіювати з сервера Ansible на один чи більше хостів, краще використовувати модуль `copy`.

!!! Примітка

    Більше інформації можна [знайти тут](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html).

Тут ми копіюємо `myflile.conf` з одного місця в інше:

```bash
- ansible.builtin.copy:
    src: /data/ansible/sources/myfile.conf
    dest: /etc/myfile.conf
    owner: root
    group: root
    mode: 0644
```

## Модуль `fetch`

Якщо файл потрібно скопіювати з віддаленого сервера на локальний, найкраще використовувати модуль `fetch`.

!!! Примітка

    Більше інформації можна знайти [тут](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/fetch_module.html).

Цей модуль діє протилежно до модуля `copy`:

```bash
- ansible.builtin.fetch:
    src: /etc/myfile.conf
    dest: /data/ansible/backup/myfile-{{ inventory_hostname }}.conf
    flat: yes
```

## Модуль `template`

Ansible і його модуль `template` використовують систему шаблонів **Jinja2** (<http://jinja.pocoo.org/docs/>) для створення файлів на target hosts.

!!! Note "Примітка"

    Більше інформації можна [знайти тут](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html).

Наприклад:

```bash
- ansible.builtin.template:
    src: /data/ansible/templates/monfichier.j2
    dest: /etc/myfile.conf
    owner: root
    group: root
    mode: 0644
```

Можна додати крок перевірки, якщо це дозволяє цільова служба (наприклад, apache за допомогою команди `apachectl -t`):

```bash
- template:
    src: /data/ansible/templates/vhost.j2
    dest: /etc/httpd/sites-available/vhost.conf
    owner: root
    group: root
    mode: 0644
    validate: '/usr/sbin/apachectl -t'
```

## Модуль `get_url`

Щоб завантажити файли з веб-сайту чи ftp на один або кілька хостів, скористайтеся модулем `get_url`:

```bash
- get_url:
    url: http://site.com/archive.zip
    dest: /tmp/archive.zip
    mode: 0640
    checksum: sha256:f772bd36185515581aa9a2e4b38fb97940ff28764900ba708e68286121770e9a
```

Використовуючи checksum of file, файл не буде перезавантажено, якщо він є в повному обсязі на місцевому місці, і його checksum збираються вказівки.
