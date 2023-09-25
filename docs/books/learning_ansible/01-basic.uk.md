---
title: Основи Ansible
author: Antoine Le Morvan
contributors: Steven Spencer, tianci li, Aditya Putta, Ganna Zhyrnova
update: 15 грудня 2021 р
---

# Основи Ansible

У цьому розділі ви дізнаєтеся, як працювати з Ansible.

****

**Цілі**: В цьому розділі ви дізнаєтеся як:

:heavy_check_mark: Реалізувати Ansible;       
:heavy_check_mark: Застосувати зміни конфігурації на сервері;   
:heavy_check_mark: Створити перші збірники ігор Ansible;

:checkered_flag: **ansible**, **module**, **playbook**

**Знання**: :star: :star: :star:     
**Складність**: :star: :star:

**Час читання**: 30 хвилин

****

Ansible централізує та автоматизує задачі адміністратора. Це є:

* **agentless** (не вимагає спеціального розгортання на клієнтах),
* **idempotent** (однаковий ефект під час кожного запуску).

Він використовує протокол **SSH** для віддаленого налаштування клієнтів Linux або протокол **WinRM** для роботи з клієнтами Windows. Якщо жоден із цих протоколів недоступний, Ansible завжди може використовувати API, що робить Ansible справжнім швейцарським ножем для конфігурації серверів, робочих станцій, служб докерів, мережевого обладнання тощо (фактично, майже всього).

!!! Warning "Важливо"

    Відкриття SSH або WinRM надходить до всіх клієнтів із сервера Ansible, що робить його критичним елементом архітектури, який потрібно ретельно контролювати.

Оскільки Ansible здебільшого базується на push-завантаженні, він не зберігатиме стан своїх цільових серверів між кожним своїм виконанням. Навпаки, він виконуватиме нові перевірки стану під час кожного виконання. Кажуть, без стану.

Це допоможе вам у:

* забезпеченні (розгортанні нової віртуальної машини),
* розгортанні додатків,
* управлінні конфігурацією,
* автоматизації,
* оркестровка (коли використовується більше ніж 1 target).

!!! Важливо

    Ansible спочатку був написаний Майклом Де Хааном, засновником інших інструментів, таких як Cobbler.
    
    ![Michael DeHaan](images/Michael_DeHaan01.jpg)
    
    Найраніша перша версія - 0.0.1, яка була випущена 9 березня 2012 року.
    
    17 жовтня 2015 року AnsibleWorks (компанія, що стоїть за Ansible) була придбана Red Hat за 150 мільйонів доларів.

![Особливості Ansible](images/ansible-001.png)

Щоб запропонувати графічний інтерфейс для щоденного використання Ansible, ви можете встановити деякі інструменти, наприклад Ansible Tower (RedHat), який не є безкоштовним, його відповідник з відкритим кодом Awx або інші проекти, такі як Jenkins і чудовий Rundeck, також можна використовувати.

!!! Abstract "Анотація"

    Щоб пройти цей тренінг, вам знадобляться принаймні 2 сервери під Rocky8:

    * першим буде **машина керування**, на ній буде встановлено Ansible.
    * другий буде сервером для налаштування та керування (інший Linux, ніж Rocky Linux, підійде так само добре).

    У наведених нижче прикладах станція адміністрування має IP-адресу 172.16.1.10, керована станція – 172.16.1.11. Ви повинні адаптувати приклади відповідно до свого плану IP-адресації.

## Терміни Ansible

* **Машина керування (management machine)**: машина, на якій встановлено Ansible. Оскільки Ansible **безагентний (agentless)**, програмне забезпечення не розгортається на керованих серверах.
* **Керовані вузли**: цільові пристрої, якими керує Ansible, також називаються «хостами». Це можуть бути сервери, мережеві пристрої або будь-який інший комп’ютер.
* **Інвентар**: файл, що містить інформацію про керовані сервери.
* **Завдання**: завдання – це блок, що визначає процедуру, яку потрібно виконати (наприклад, створити користувача або групу, встановити програмний пакет тощо).
* **Модуль**: модуль реферує завдання. Ansible надає багато модулів.
* **Playbooks**: простий файл у форматі yaml із визначенням цільових серверів і завдань, які потрібно виконати.
* **Роль**: роль дозволяє вам упорядковувати підручники та всі інші необхідні файли (шаблони, сценарії тощо), щоб полегшити спільний доступ до коду та його повторне використання.
* **Колекція**: колекція включає логічний набір посібників, ролей, модулів і плагінів.
* **Факти**: це глобальні змінні, що містять інформацію про систему (назва машини, версія системи, мережевий інтерфейс і конфігурація тощо).
* **Обробники**: вони використовуються для зупинки або перезапуску служби у разі зміни.

## Установка на сервер управління

Ansible доступний у сховищі _EPEL_, але інколи він може бути застарим для поточної версії, і ви захочете працювати з новішою версією.

Тому ми розглянемо два види установки:

* той, що базується на репозиторіях EPEL
* один на основі менеджера пакунків Python `pip`

_EPEL_ потрібен для обох версій, тому ви можете встановити його зараз:

* Установка EPEL:

```
$ sudo dnf install epel-release
```

### Установка від EPEL

Якщо ми встановимо Ansible з _EPEL_, ми зможемо зробити наступне:

```
$ sudo dnf install ansible
```

А потім перевірте встановлення:

```
$ ansible --version
ansible [core 2.14.2]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/rocky/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3.11/site-packages/ansible  ansible collection location = /home/rocky/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.11.2 (main, Jun 22 2023, 04:35:24) [GCC 8.5.0 20210514 
(Red Hat 8.5.0-18)] (/usr/bin/python3.11)
  jinja version = 3.1.2
  libyaml = True

$ python3 --version
Python 3.6.8
```

Зверніть увагу, що ansible постачається зі своєю власною версією python, відмінною від системної версії Python (тут 3.11.2 проти 3.6.8). Вам потрібно врахувати це під час інсталяції модулів Python за допомогою pip, необхідних для інсталяції (наприклад, `pip3.11 install PyVMomi`).

### Встановлення з python pip

Оскільки ми хочемо використовувати новішу версію Ansible, ми встановимо її з `python3-pip`:

!!! Note "Примітка"

    Видаліть Ansible, якщо ви встановили його раніше з _EPEL_.

На цьому етапі ми можемо встановити ansible з потрібною версією python.

```
$ sudo dnf install python38 python38-pip python38-wheel python3-argcomplete rust cargo curl
```

!!! Note "Примітка"

    `python3-argcomplete` надається _EPEL_. Будь ласка, встановіть epel-release, якщо це ще не зроблено.
    Цей пакет допоможе вам виконати команди Ansible.

Тепер ми можемо встановити Ansible:

```
$ pip3.8 install --user ansible
$ activate-global-python-argcomplete --user
```

Перевірте свою версію Ansible:

```
$ ansible --version
ansible [core 2.13.11]
  config file = None
  configured module search path = ['/home/rocky/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/rocky/.local/lib/python3.8/site-packages/ansible
  ansible collection location = /home/rocky/.ansible/collections:/usr/share/ansible/collections
  executable location = /home/rocky/.local/bin/ansible
  python version = 3.8.16 (default, Jun 25 2023, 05:53:51) [GCC 8.5.0 20210514 (Red Hat 8.5.0-18)]
  jinja version = 3.1.2
  libyaml = True
```

!!! NOTE "Примітка"

    Версія, встановлена вручну, у нашому випадку старша за версію, запаковану RPM, оскільки ми використовували старішу версію python. Це спостереження змінюватиметься залежно від часу та віку дистрибутива та версії python, звичайно.

## Файли конфігурації

Конфігурація сервера знаходиться в `/etc/ansible`.

Існує два основних файли конфігурації:

* Основний конфігураційний файл `ansible.cfg`, де знаходяться команди, модулі, плагіни та конфігурація ssh;
* Файл інвентаризації керування клієнтською машиною `hosts`, де оголошено клієнтів і групи клієнтів.

Конфігураційний файл буде створено автоматично, якщо Ansible було встановлено через пакет RPM. При встановленні `pip` цей файл не існує. Нам доведеться створити його вручну завдяки команді `ansible-config`:

```
$ ansible-config -h
usage: ansible-config [-h] [--version] [-v] {list,dump,view,init} ...

Перегляд доступної конфігурації.

позиційні аргументи:
   {list,dump,view,init}
     список Надрукувати всі параметри конфігурації
     dump Дамп конфігурації
     перегляд Переглянути файл конфігурації
     init Створити початкову конфігурацію
```

Приклад:

```
ansible-config init --disabled > /etc/ansible/ansible.cfg
```

Параметр `--disabled` дозволяє вам закоментувати набір параметрів, додавши до них префікс `;`.

!!! NOTE "Примітка"

    Ви також можете вбудувати конфігурацію Ansible у своє сховище коду, при цьому Ansible завантажуватиме файли конфігурації, які він знайде, у такому порядку (обробка першого файлу, який він зустріне, та ігнорування решти):

    * якщо встановлено змінну середовища `$ANSIBLE_CONFIG`, завантажте вказаний файл.
    * `ansible.cfg`, якщо існує в поточному каталозі.
    * `~/.ansible.cfg`, якщо існує (у домашньому каталозі користувача).

    Файл за замовчуванням завантажується, якщо жоден із цих трьох файлів не знайдено.

### Файл інвентаризації `/etc/ansible/hosts`

Оскільки Ansible доведеться працювати з усім вашим обладнанням, яке потрібно налаштувати, необхідно забезпечити його одним (чи кількома) добре структурованими файлами інвентаризації, які ідеально відповідають вашій організації.

Іноді необхідно добре подумати, як створити цей файл.

Перейдіть до файлу інвентаризації за умовчанням, який знаходиться під `/etc/ansible/hosts`. Деякі приклади наведено та прокоментовано:

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

Як бачимо, файл, наданий як приклад, використовує формат INI, добре відомий системним адміністраторам. Зверніть увагу, що ви можете вибрати інший формат файлу (наприклад, yaml), але для перших тестів формат INI добре адаптований для наших майбутніх прикладів.

Інвентаризація може бути створена автоматично у виробництві, особливо якщо у вас є середовище віртуалізації, наприклад VMware VSphere, або хмарне середовище (Aws, OpenStack або інше).

* Створення групи хостів у `/etc/ansible/hosts`:

Як ви могли помітити, групи оголошуються у квадратних дужках. Потім йдуть елементи, що належать до груп. Ви можете створити, наприклад, групу `rocky8`, вставивши наступний блок у цей файл:

```
[rocky8]
172.16.1.10
172.16.1.11
```

Групи можна використовувати в інших групах. У цьому випадку необхідно вказати, що батьківська група складається з підгруп з атрибутом `:children`, як це:

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

Ми не будемо зупинятися на інвентаризації, але якщо ви зацікавлені, перегляньте [це посилання](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html).

Тепер, коли наш сервер керування встановлено та наш інвентар готовий, настав час запустити наші перші команди `ansible`.

## `ansible` використання командного рядка

Команда `ansible` запускає завдання на одному чи кількох цільових хостах.

```
ansible <host-pattern> [-m module_name] [-a args] [options]
```

Приклади:

!!! Warning "Важливо"

    Оскільки ми ще не налаштували автентифікацію на наших 2 тестових серверах, не всі наступні приклади працюватимуть. Вони наведені як приклади, щоб полегшити розуміння, і будуть повністю функціональними пізніше в цьому розділі.

* Перелічіть хости, що належать до групи rocky8:

```
ansible rocky8 --list-hosts
```

* Виконайте тестування групи хостів за допомогою модуля `ping`:

```
ansible rocky8 -m ping
```

* Відображення фактів із групи хостів за допомогою модуля `setup`:

```
ansible rocky8 -m setup
```

* Виконайте команду в групі хостів, викликавши модуль `command` з аргументами:

```
ansible rocky8 -m command -a 'uptime'
```

* Виконайте команду з правами адміністратора:

```
ansible ansible_clients --become -m command -a 'reboot'
```

* Виконайте команду за допомогою спеціального файлу інвентаризації:

```
ansible rocky8 -i ./local-inventory -m command -a 'date'
```

!!! Note "Примітка"

    Як у цьому прикладі, іноді простіше розділити декларацію керованих пристроїв на кілька файлів (наприклад, за хмарним проектом) і надати Ansible шлях до цих файлів, а не підтримувати довгий файл інвентаризації.

| Опція                    | Опис                                                                                               |
| ------------------------ | -------------------------------------------------------------------------------------------------- |
| `-a 'arguments'`         | Аргументи для передачі в модуль.                                                                   |
| `-b -K`                  | Запитує пароль і виконує команду з вищими привілегіями.                                            |
| `--user=username`        | Використовує цього користувача для підключення до цільового хосту замість поточного користувача.   |
| `--become-user=username` | Виконує операцію від імені цього користувача (за замовчуванням: `root`).                           |
| `-C`                     | Симуляція. Не вносить жодних змін до target, але виконує перевірку, щоб побачити, що слід змінити. |
| `-m module`              | Запускає викликаний модуль                                                                         |

### Підготовка клієнта

На машинах керування та клієнтах ми створимо користувача `ansible`, призначеного для операцій, які виконує Ansible. Цей користувач має використовувати права sudo, тому його потрібно додати до групи `wheel`.

Цей користувач буде використовуватися:

* На стороні станції адміністрування: для виконання команд `ansible` і ssh для керованих клієнтів.
* На керованих станціях (тут сервер, який служить вашою станцією адміністрування, також служить клієнтом, тому ним керують самі по собі), для виконання команд, запущених із станції адміністрування: тому він повинен мати права sudo.

На обох машинах створіть користувача `ansible`, присвяченого ansible:

```
$ sudo useradd ansible
$ sudo usermod -aG wheel ansible
```

Встановіть пароль для цього користувача:

```
$ sudo passwd ansible
```

Змініть конфігурацію sudoers, щоб дозволити членам групи `wheel` використовувати sudo без пароля:

```
$ sudo visudo
```

Наша мета тут — закоментувати параметр за замовчуванням і розкоментувати параметр NOPASSWD, щоб ці рядки виглядали так, коли ми закінчимо:

```
## Allows people in group wheel to run all commands
# %wheel  ALL=(ALL)       ALL

## Same thing without a password
%wheel        ALL=(ALL)       NOPASSWD: ALL
```

!!! Warning "Важливо"

    Якщо ви отримуєте таке повідомлення про помилку під час введення команд Ansible, це, ймовірно, означає, що ви забули цей крок на одному зі своїх клієнтів:
    `"msg": "Missing sudo password`

Використовуючи керування з цього моменту, почніть працювати з цим новим користувачем:

```
$ sudo su - ansible
```

### Перевірка за допомогою модуля ping

За замовчуванням Ansible не дозволяє вхід із паролем.

Розкоментуйте наступний рядок із розділу `[defaults]` у файлі конфігурації `/etc/ansible/ansible.cfg` і встановіть для нього значення True:

```
ask_pass      = True
```

Запустіть `ping` на кожному сервері групи rocky8:

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

!!! Note "Примітка"

    Вас просять ввести `ansible` пароль віддалених серверів, що є проблемою безпеки...

!!! Tip "Порада"

    Якщо ви отримуєте цю помилку `"msg": to use the 'ssh' connection type with passwords, you must install the sshpass program"`, ви можете просто встановити `sshpass` на станції керування:

    ```
    $ sudo dnf install sshpass
    ```

!!! Abstract "анотація"

    Тепер ви можете перевірити команди, які раніше не працювали в цій главі.

## Аутентифікація за ключем

Автентифікацію за паролем буде замінено набагато більш безпечною автентифікацією за приватним/відкритим ключем.

### Створення ключа SSH

Подвійний ключ буде згенеровано за допомогою команди `ssh-keygen` на станції керування користувачем `ansible`:

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

Відкритий ключ можна скопіювати на сервери:

```
# ssh-copy-id ansible@172.16.1.10
# ssh-copy-id ansible@172.16.1.11
```

Повторно прокоментуйте наступний рядок із розділу `[defaults]` у файлі конфігурації `/etc/ansible/ansible.cfg`, щоб запобігти автентифікації паролем:

```
#ask_pass      = True
```

### Тест автентифікації закритого ключа

Для наступного тесту використовується модуль `shell`, що дозволяє віддалено виконувати команди:

```
# ansible rocky8 -m shell -a "uptime"
172.16.1.10 | SUCCESS | rc=0 >>
 12:36:18 up 57 min,  1 user,  load average: 0.00, 0.00, 0.00

172.16.1.11 | SUCCESS | rc=0 >>
 12:37:07 up 57 min,  1 user,  load average: 0.00, 0.00, 0.00
```

Пароль не потрібен, автентифікація приватного/відкритого ключа працює!

!!! Note "Примітка"

    У робочому середовищі тепер ви повинні видалити `ansible` паролі, встановлені раніше для забезпечення вашої безпеки (оскільки тепер пароль автентифікації не потрібен).

## Використання Ansible

Ansible можна використовувати з оболонки або playbooks.

### Модулі

Список модулів, класифікованих за категоріями, можна [знайти тут](https://docs.ansible.com/ansible/latest/collections/index_module.html). Ansible пропонує понад 750!

Тепер модулі згруповано в колекції модулів, список яких можна [знайти тут](https://docs.ansible.com/ansible/latest/collections/index.html).

Колекції — це формат розповсюдження вмісту Ansible, який може містити посібники, ролі, модулі та плагіни.

Модуль викликається за допомогою параметра `-m` команди `ansible`:

```
ansible <host-pattern> [-m module_name] [-a args] [options]
```

Практично для будь-якої потреби є модуль! Таким чином, замість використання модуля оболонки рекомендується шукати модуль, адаптований до потреб.

Кожна категорія потреби має свій модуль. Ось неповний список:

| Тип                                 | Приклади                                                            |
| ----------------------------------- | ------------------------------------------------------------------- |
| Управління системою                 | `user` (керування користувачами), `group` (керування групами) тощо. |
| Управління програмним забезпеченням | `dnf`,`yum`, `apt`, `pip`, `npm`                                    |
| Керування файлами                   | `copy`, `fetch`, `lineinfile`, `template`, `archive`                |
| Управління базами даних             | `mysql`, `postgresql`, `redis`                                      |
| Управління хмарою                   | `amazon S3`, `cloudstack`, `openstack`                              |
| Управління кластером                | `consul`, `zookeeper`                                               |
| Надсилання команд                   | `shell`, `script`, `expect`                                         |
| Завантаження                        | `get_url`                                                           |
| Керування джерелом                  | `git`, `gitlab`                                                     |

#### Приклад встановлення програмного забезпечення

Модуль `dnf` дозволяє інсталювати програмне забезпечення на цільових клієнтах:

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

Встановлене програмне забезпечення є службою, тепер необхідно запустити його за допомогою модуля `systemd`:

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

!!! Tip "Порада"

    Спробуйте двічі запустити останні 2 команди. Ви помітите, що перший раз Ansible виконає дії для досягнення стану, встановленого командою. Другого разу він нічого не зробить, оскільки виявить, що стан уже досягнуто!

### Вправи

Щоб дізнатися більше про Ansible і звикнути до пошуку документації Ansible, ось кілька вправ, які ви можете виконати, перш ніж продовжити:

* Створіть групи Paris, Tokio, NewYork
* Створіть користувача `supervisor`
* Змініть користувача, щоб мати uid 10000
* Змініть користувача так, щоб він належав до групи Paris
* Встановіть програмне забезпечення дерева
* Зупиніть службу crond
* Створіть порожній файл із правами `0644`
* Оновіть дистрибутив клієнта
* Перезапустіть клієнт

!!! Warning "Важливо"

    Не використовуйте модуль оболонки. Подивіться відповідні модулі в документації!

#### Модуль `setup`: вступ до фактів

Системні факти – це змінні, отримані Ansible через його модуль `setup`.

Подивіться на різні факти про своїх клієнтів, щоб отримати уявлення про кількість інформації, яку можна легко отримати за допомогою простої команди.

Пізніше ми побачимо, як використовувати факти в наших підручниках і створювати власні факти.

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

Тепер, коли ми побачили, як налаштувати віддалений сервер за допомогою Ansible у командному рядку, ми можемо представити поняття playbook. Playbooks — ще один спосіб використання Ansible, який не набагато складніший, але полегшить повторне використання вашого коду.

## Playbooks

Playbooks Ansible описують політику, яка буде застосована до віддалених систем, щоб примусово їх конфігурувати. Playbooks написані у зрозумілому текстовому форматі, який об’єднує набір завдань: формат `yaml`.

!!! Note "Примітка"

    Дізнайтеся більше про [yaml тут](https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html)

```
ansible-playbook <file.yml> ... [options]
```

Параметри ідентичні команді `ansible`.

Команда повертає такі коди помилок:

| Код   | Помилка                            |
| ----- | ---------------------------------- |
| `0`   | OK або немає відповідного хоста    |
| `1`   | Помилка                            |
| `2`   | Один або кілька хостів не працюють |
| `3`   | Один або кілька хостів недоступні  |
| `4`   | Analyze error                      |
| `5`   | Погані або неповні варіанти        |
| `99`  | Запуск перервано користувачем      |
| `250` | Неочікувана помилка                |

!!! Note "Примітка"

    Будь ласка, зверніть увагу, що `ansible` поверне Ok, якщо жоден хост не збігається з вашою метою, що може ввести вас в оману!

### Приклад посібника з Apache і MySQL

Наступний playbook дозволяє нам інсталювати Apache і MariaDB на наших цільових серверах.

Створіть файл `test.yml` із таким вмістом:

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

* <1> Цільова група або цільовий сервер повинні існувати в інвентарі
* <2> Після підключення користувач стає `root` (через `sudo` за замовчуванням)

Виконання playbook виконується командою `ansible-playbook`:

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

Для кращої читабельності рекомендовано писати ваші п’єси в повному форматі yaml. У попередньому прикладі аргументи подано в тому самому рядку, що й модуль, значення аргументу після його назви розділено `=`. Подивіться ту саму playbook на повному yaml:

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

!!! tip "Порада"

    `dnf` — це один із модулів, який дозволяє надати йому список як аргумент.

Примітка щодо колекцій: Ansible тепер надає модулі у формі колекцій. Деякі модулі надаються за замовчуванням у колекції `ansible.builtin`, інші потрібно встановити вручну за допомогою:

```
ansible-galaxy collection install [collectionname]
```
де [collectionname] — це назва колекції (квадратні дужки тут використовуються, щоб підкреслити необхідність заміни її фактичною назвою колекції, і НЕ є частиною команди).

Попередній приклад слід записати так:

```
---
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

Посібник не обмежується однією метою:

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

Ви можете перевірити синтаксис вашої playbook:

```
$ ansible-playbook --syntax-check play.yml
```

Ви також можете використовувати "лінтер" для yaml:

```
$ dnf install -y yamllint
```

потім перевірте синтаксис yaml своїх playbooks:

```
$ yamllint test.yml
test.yml
  8:1       error    syntax error: could not find expected ':' (syntax)
```

## Результати вправ

* Створіть групи Paris, Tokio, NewYork
* Створіть користувача `supervisor`
* Змініть користувача, щоб мати uid 10000
* Змініть користувача так, щоб він належав до групи Paris
* Встановіть програмне забезпечення дерева
* Зупиніть службу crond
* Створіть порожній файл із правами `0644`
* Оновіть дистрибутив клієнта
* Перезапустіть клієнт

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
