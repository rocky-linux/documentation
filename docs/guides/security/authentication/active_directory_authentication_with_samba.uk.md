---
title: Автентифікація Active Directory за допомогою Samba
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 9.4
---

## Передумови

- Деяке розуміння Active Directory
- Деяке розуміння LDAP

## Вступ

Microsoft Active Directory (AD) є системою автентифікації за замовчуванням для систем Windows і зовнішніх служб, підключених через LDAP, на більшості підприємств. Він дозволяє налаштовувати користувачів і групи, контролювати доступ, дозволи, автоматичне монтування тощо.

Хоча підключення Linux до кластера AD не може підтримувати _всі_ згадані функції, воно може працювати з користувачами, групами та контролем доступу. Розповсюджувати ключі SSH за допомогою AD можливо (хоча деякі налаштування конфігурації на стороні Linux і деякі додаткові параметри на стороні AD).

Стандартним способом використання Active Directory у Rocky Linux є використання SSSD, але Samba є більш повнофункціональною альтернативою. Наприклад, обмін файлами можна здійснювати за допомогою Samba, але не SSSD. Однак цей посібник охоплюватиме налаштування автентифікації для Active Directory за допомогою Samba та не міститиме жодних додаткових налаштувань на стороні Windows.

## Виявлення та приєднання до AD за допомогою Samba

!!! Note "Примітка"

```
Доменне ім’я ad.company.local у цьому посібнику представлятиме домен Active Directory. Щоб слідувати цьому посібнику, замініть його ім’ям свого домену AD.
```

Першим кроком до приєднання системи Linux до AD є виявлення вашого кластера AD, щоб переконатися, що конфігурація мережі правильна з обох сторін.

### Підготовка

- Переконайтеся, що такі порти відкриті для хосту Linux на контролері домену:

  | Служба   | Порт(и)           | Примітки                                                                       |
  | -------- | ------------------------------------ | ------------------------------------------------------------------------------ |
  | DNS      | 53 (TCP+UDP)      |                                                                                |
  | Kerberos | 88, 464 (TCP+UDP) | Використовується `kadmin` для встановлення та оновлення паролів                |
  | LDAP     | 389 (TCP+UDP)     |                                                                                |
  | LDAP-GC  | 3268 (TCP)        | Глобальний каталог LDAP – дозволяє отримувати ідентифікатори користувачів з AD |

- Переконайтеся, що ви налаштували контролер домену AD як DNS-сервер на хості Rocky Linux:

  **З NetworkManager:**

  ```sh
  # where your primary NetworkManager connection is 'System eth0' and your AD
  # server is accessible on the IP address 10.0.0.2.
  [root@host ~]$ nmcli con mod 'System eth0' ipv4.dns 10.0.0.2
  ```

- Переконайтеся, що час на обох сторонах (хост AD і система Linux) синхронізовано (див. Chronyd)

  **Щоб перевірити час у Rocky Linux:**

  ```sh
  [user@host ~]$ date
  Wed 22 Sep 17:11:35 BST 2021
  ```

- Встановіть необхідні пакети для підключення AD на стороні Linux:

  ```sh
  [user@host ~]$ sudo dnf install samba samba-winbind samba-client
  ```

### Відкриття

Тепер ви зможете виявити сервер(и) AD на хості Linux.

```sh
[user@host ~]$ realm discover ad.company.local
ad.company.local
  type: kerberos
  realm-name: AD.COMPANY.LOCAL
  domain-name: ad.company.local
  configured: no
  server-software: active-directory
  client-software: sssd
  required-package: oddjob
  required-package: oddjob-mkhomedir
  required-package: sssd
  required-package: adcli
  required-package: samba-common
```

Це буде виявлено за допомогою відповідних записів SRV, що зберігаються у вашій службі DNS Active Directory.

### Приєднання

Після того, як ви успішно виявите свою установку Active Directory на хості Linux, ви зможете використовувати `realmd`, щоб приєднатися до домену, який організує конфігурацію Samba за допомогою `adcli` та деяких інших подібних інструментів.

```sh
[user@host ~]$ sudo realm join -v --membership-software=samba --client-software=winbind ad.company.local
```

Вам буде запропоновано ввести пароль адміністратора вашого домену, тому введіть його.

Якщо цей процес скаржиться на шифрування з повідомленням «KDC не підтримує тип шифрування», спробуйте оновити глобальну політику шифрування, щоб дозволити старіші алгоритми шифрування:

```sh
[user@host ~]$ sudo update-crypto-policies --set DEFAULT:AD-SUPPORT
```

Якщо цей процес завершиться успішно, тепер ви зможете отримати інформацію `passwd` для користувача Active Directory.

```sh
[user@host ~]$ sudo getent passwd administrator@ad.company.local
AD\administrator:*:1450400500:1450400513:Administrator:/home/administrator@ad.company.local:/bin/bash
```

!!! Note "Примітка"

```
`getent` отримує записи з бібліотек перемикання служб імен (NSS). Це означає, що, наприклад, на відміну від `passwd` або `dig`, він запитуватиме різні бази даних, зокрема `/etc/hosts` для `getent hosts` або з `samba` у випадку `getent passwd`.
```

`realm` надає кілька цікавих опцій, якими ви можете скористатися:

| Опція                                                                      | Функціональність                                |
| -------------------------------------------------------------------------- | ----------------------------------------------- |
| --computer-ou='OU=LINUX,OU=SERVERS,dc=ad,dc=company.local' | Підрозділ, де зберігати обліковий запис сервера |
| --os-name='rocky'                                                          | Укажіть назву ОС, яка зберігається в AD         |
| --os-version='8'                                                           | Укажіть версію ОС, яка зберігається в AD        |
| -U admin_username                                     | Вкажіть обліковий запис адміністратора          |

### Спроба автентифікації

Тепер ваші користувачі мають мати змогу автентифікуватися на вашому хості Linux у Active Directory.

**У Windows 10:** (яка надає власну копію OpenSSH)

```dos
C:\Users\John.Doe> ssh -l john.doe@ad.company.local linux.host
Password for john.doe@ad.company.local:

Activate the web console with: systemctl enable --now cockpit.socket

Last login: Wed Sep 15 17:37:03 2021 from 10.0.10.241
[john.doe@ad.company.local@host ~]$
```

Якщо це вдається, ви успішно налаштували Linux на використання Active Directory як джерела автентифікації.

### Видалення доменного імені в іменах користувачів

У налаштуваннях за замовчуванням вам потрібно буде ввійти за допомогою свого облікового запису AD, вказавши домен у своєму імені користувача (наприклад, `john.doe@ad.company.local`). Якщо це не бажана поведінка, і ви натомість хочете мати можливість пропустити ім’я домену за замовчуванням під час автентифікації, ви можете налаштувати Samba на певний домен за замовчуванням.

Це відносно простий процес, який потребує налаштування конфігурації у файлі конфігурації SSSD.

```sh
[user@host ~]$ sudo vi /etc/samba/smb.conf
[global]
...
winbind use default domain = yes
```

Додаючи `winbind use default domain`, ви наказуєте Samba зробити висновок, що користувач намагається автентифікуватися як користувач із домену `ad.company.local`. Це дозволяє вам автентифікуватись як щось на зразок `john.doe` замість `john.doe@ad.company.local`.

Щоб ця зміна конфігурації вступила в силу, потрібно перезапустити служби `smb` і `winbind` за допомогою `systemctl`.

```sh
[user@host ~]$ sudo systemctl restart smb winbind
```

Таким же чином, якщо ви не бажаєте, щоб ваші домашні каталоги суфіксувалися доменним іменем, ви можете додати ці параметри у свій файл конфігурації `/etc/samba/smb.conf`:

```bash
[global]
template homedir = /home/%U
```

Не забудьте перезапустити служби `smb` і `winbind`.
