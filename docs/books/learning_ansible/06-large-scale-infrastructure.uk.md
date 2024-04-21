---
title: Великомасштабна інфраструктура
---

# Ansible - великомасштабна інфраструктура

У цьому розділі ви дізнаєтеся, як масштабувати систему керування конфігурацією.

****

**Цілі**: В цьому розділі ви дізнаєтеся як:

:heavy_check_mark: Організувати свій код для великої інфраструктури;  
:heavy_check_mark: Застосувати все або частину вашого керування конфігурацією до групи вузлів;

:checkered_flag: **ansible**, **керування конфігурацією**, **scale**

**Знання**: :star: :star: :star:  
**Складність**: :star: :star: :star: :star:

**Час читання**: 30 хвилин

****

У попередніх розділах ми бачили, як організувати наш код у формі ролей, а також як використовувати деякі ролі для керування оновленнями (керування виправленнями) або розгортання коду.

А як щодо керування конфігурацією? Як керувати конфігурацією десятків, сотень або навіть тисяч віртуальних машин за допомогою Ansible?

Поява хмари дещо змінила традиційні методи. Віртуальна машина налаштована під час розгортання. Якщо його конфігурація більше не відповідає вимогам, його знищують і замінюють новим.

Організація системи керування конфігурацією, представлена в цій главі, відповідатиме цим двом способам споживання ІТ: однократне використання або регулярне «повторне налаштування» пулу серверів.

Однак будьте обережні: використання Ansible для забезпечення відповідності пулу серверів вимагає зміни робочих звичок. Більше неможливо вручну змінити конфігурацію диспетчера служб, не побачивши, що ці зміни будуть перезаписані під час наступного запуску Ansible.

!!! Важливо

    Те, що ми збираємося встановити нижче, не є добрим для Ansible. Такі технології, як Puppet або Salt, будуть набагато кращими. Нагадаємо, що Ansible є швейцарським армійським ножем автоматизації і не використовує агентів, що пояснює відмінності в продуктивності.

!!! Примітка

    Більше інформації можна [знайти тут](https://docs.ansible.com/ansible/latest/user_guide/sample_setup.html)

## Зберігання змінних

Перше, що ми повинні обговорити, це поділ між даними та кодом Ansible.

Оскільки код стає більшим і складнішим, змінювати змінні, які він містить, буде дедалі складніше.

Щоб забезпечити підтримку вашого сайту, найголовніше – правильно відокремити змінні від коду Ansible.

Ми ще не обговорювали це тут, але ви повинні знати, що Ansible може автоматично завантажувати змінні, які він знаходить у певних папках залежно від інвентарного імені керованого вузла або його груп учасників.

Документація Ansible пропонує організувати наш код так:

```bash
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

Якщо цільовим вузлом є `hostname1` `group1`, змінні, що містяться у файлах `hostname1.yml` і `group1.yml` будуть автоматично завантажені. Це чудовий спосіб зберігати всі дані для всіх ваших ролей в одному місці.

Таким чином файл інвентаризації вашого сервера стає його ідентифікаційною карткою. Він містить усі змінні, які відрізняються від змінних за замовчуванням для вашого сервера.

З точки зору централізації змінних стає важливим організувати іменування її змінних у ролях, додаючи їм префікс, наприклад, імені ролі. Також рекомендується використовувати плоскі імена змінних, а не словники.

Наприклад, якщо ви хочете зробити значення `PermitRootLogin` у файлі `sshd_config` змінною, гарною назвою змінної може бути `sshd_config_permitrootlogin` (замість `sshd.config.permitrootlogin`, що також може бути хорошою назвою змінної).

## Про теги Ansible

Використання тегів Ansible дозволяє виконати або пропустити частину завдань у вашому коді.

!!! Примітка

    Більше інформації можна [знайти тут](https://docs.ansible.com/ansible/latest/user_guide/playbooks_tags.html)

Наприклад, давайте змінимо завдання створення користувачів:

```bash
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

Тепер ви можете відтворювати лише завдання з тегом `users` з опцією `ansible-playbook` `--tags`:

```bash
ansible-playbook -i inventories/production/hosts --tags users site.yml
```

Ви також можете використовувати параметр `--skip-tags`.

## Про оформлення каталогу

Зупинимося на пропозиції щодо організації файлів і каталогів, необхідних для належного функціонування CMS (системи управління вмістом).

Нашою відправною точкою буде файл `site.yml`. Цей файл трохи нагадує оркестровий диригент CMS, оскільки він міститиме необхідні ролі для цільових вузлів лише за потреби:

```bash
---
- name: "Config Management for {{ target }}"
  hosts: "{{ target }}"

  roles:

    - role: roles/functionality1

    - role: roles/functionality2
```

Звичайно, ці ролі мають бути створені в каталозі `roles` на тому ж рівні, що й файл `site.yml`.

Мені подобається керувати своїми глобальними змінними в `vars/global_vars.yml`, навіть якщо я можу зберігати їх у файлі, розташованому за адресою `inventories/production/group_vars/all.yml`

```bash
---
- name: "Config Management for {{ target }}"
  hosts: "{{ target }}"
  vars_files:
    - vars/global_vars.yml
  roles:

    - role: roles/functionality1

    - role: roles/functionality2
```

Мені також подобається зберегти можливість відключення функціональності. Тому я включаю свої ролі з умовою та значенням за замовчуванням, як це:

```bash
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

Не забувайте використовувати теги:

```bash
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

Ви повинні отримати щось на зразок цього:

```bash
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

!!! Примітка

    Ви можете вільно розробляти свої ролі в колекції

## Тести

Давайте запустимо playbook і проведемо кілька тестів:

```bash
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

Як бачите, за умовчанням відтворюються лише завдання ролі `functionality1`.

Давайте активуємо в інвентарі `functionality2` для нашого цільового вузла та повторно запустимо playbook:

```bash
$ vim inventories/production/host_vars/client1.yml
---
enable_functionality2: true
```

```bash
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

Спробуйте застосувати лише `functionality2`:

```bash
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

Давайте запустимо весь інвентар:

```bash
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

Як бачите, `functionality2` відтворюється лише на `client1`.

## Переваги

Дотримуючись порад, наданих у документації Ansible, ви швидко отримаєте:

* вихідний код, який легко підтримувати, навіть якщо він містить велику кількість ролей
* відносно швидку, повторювану систему відповідності, яку можна застосувати частково або повністю
* можна адаптувати в кожному конкретному випадку та серверами
* специфіка вашої інформаційної системи відокремлена від коду, легко перевіряється та централізована у файлах інвентаризації вашого керування конфігурацією.
