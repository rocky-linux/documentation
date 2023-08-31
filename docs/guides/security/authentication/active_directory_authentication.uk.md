---
author: Hayden Young
contributors: Steven Spencer, Sambhav Saggi, Antoine Le Morvan, Krista Burdine
---

# Аутентифікація Active Directory

## Передумови

- Деяке розуміння Active Directory
- Деяке розуміння LDAP

## Вступ

Microsoft Active Directory (AD) є системою автентифікації за замовчуванням для систем Windows і зовнішніх служб, підключених через LDAP, на більшості підприємств. Він дозволяє налаштовувати користувачів і групи, контролювати доступ, дозволи, автоматичне монтування тощо.

Тепер, хоча підключення Linux до кластера AD не може підтримувати _усі_ згадані функції, воно може працювати з користувачами, групами та контролем доступу. Розповсюджувати ключі SSH за допомогою AD можливо (хоча деякі налаштування конфігурації на стороні Linux і деякі додаткові параметри на стороні AD).

Однак у цьому посібнику йдеться лише про налаштування автентифікації для Active Directory і не включатиме жодних додаткових налаштувань для Windows.

## Виявлення та приєднання до AD за допомогою SSSD

!!! Note "Примітка"

    Доменне ім’я ad.company.local у цьому посібнику представлятиме домен Active Directory. Щоб слідувати цьому посібнику, замініть його ім’ям свого домену AD.

Першим кроком до приєднання системи Linux до AD є виявлення вашого кластера AD, щоб переконатися, що конфігурація мережі правильна з обох сторін.

### Підготовка

- Переконайтеся, що такі порти відкриті для хосту Linux на контролері домену:

  | Служба   | Порт(и)           | Примітки                                                                       |
  | -------- | ----------------- | ------------------------------------------------------------------------------ |
  | DNS      | 53 (TCP+UDP)      |                                                                                |
  | Kerberos | 88, 464 (TCP+UDP) | Використовується `kadmin` для налаштування та оновлення паролів                |
  | LDAP     | 389 (TCP+UDP)     |                                                                                |
  | LDAP-GC  | 3268 (TCP)        | Глобальний каталог LDAP – дозволяє отримувати ідентифікатори користувачів з AD |

- Переконайтеся, що ви налаштували контролер домену AD як DNS-сервер на хості Rocky Linux:

  **З NetworkManager:**

  ```sh
  # де основним підключенням NetworkManager є «System eth0», а AD
   # сервер доступний за IP-адресою 10.0.0.2.
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
  [user@host ~]$ sudo dnf install realmd oddjob oddjob-mkhomedir sssd adcli krb5-workstation
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

Після того, як ви успішно виявите свою інсталяцію Active Directory на хості Linux, ви зможете використовувати `realmd` для приєднання до домену, який організує конфігурацію `sssd` за допомогою `adcli` та деякі інші подібні інструменти.

```sh
[user@host ~]$ sudo realm join ad.company.local
```

Якщо цей процес скаржиться на шифрування з `KDC не підтримує тип шифрування`, спробуйте оновити глобальну політику шифрування, щоб дозволити старі алгоритми шифрування:

```sh
[user@host ~]$ sudo update-crypto-policies --set DEFAULT:AD-SUPPORT
```

Якщо цей процес завершиться успішно, тепер ви зможете отримати інформацію `passwd` для користувача Active Directory.

```sh
[user@host ~]$ sudo getent passwd administrator@ad.company.local
administrator@ad.company.local:*:1450400500:1450400513:Administrator:/home/administrator@ad.company.local:/bin/bash
```

!!! Note "Примітка" 

    `getent` отримує записи з бібліотек перемикання служб імен (NSS). Це означає, що, наприклад, на відміну від `passwd` або `dig`, він запитуватиме різні бази даних, у тому числі `/etc/hosts` для `getent hosts` або з `sssd` у випадку `getent passwd`.

`realm` надає кілька цікавих параметрів, якими можна скористатися:

| Опція                                                      | Функціональність                                |
| ---------------------------------------------------------- | ----------------------------------------------- |
| --computer-ou='OU=LINUX,OU=SERVERS,dc=ad,dc=company.local' | Підрозділ, де зберігати обліковий запис сервера |
| --os-name='rocky'                                          | Укажіть назву ОС, яка зберігається в AD         |
| --os-version='8'                                           | Укажіть версію ОС, яка зберігається в AD        |
| -U admin_username                                          | Вкажіть обліковий запис адміністратора          |

### Спроба автентифікації

Тепер ваші користувачі мають мати змогу автентифікуватися на вашому хості Linux у Active Directory.

**У Windows 10:** (яка надає власну копію OpenSSH)

```
C:\Users\John.Doe> ssh -l john.doe@ad.company.local linux.host
Password for john.doe@ad.company.local:

Activate the web console with: systemctl enable --now cockpit.socket

Last login: Wed Sep 15 17:37:03 2021 from 10.0.10.241
[john.doe@ad.company.local@host ~]$
```

Якщо це вдається, ви успішно налаштували Linux на використання Active Directory як джерела автентифікації.

### Встановлення домену за замовчуванням

У повному налаштуванні за замовчуванням вам потрібно буде ввійти за допомогою свого облікового запису AD, вказавши домен у своєму імені користувача (наприклад, `john.doe@ad.company.local`). Якщо це не бажана поведінка, і ви натомість хочете мати можливість опускати доменне ім’я під час автентифікації, ви можете налаштувати SSSD на певний домен за замовчуванням.

Це відносно простий процес, який потребує налаштування конфігурації у файлі конфігурації SSSD.

```sh
[user@host ~]$ sudo vi /etc/sssd/sssd.conf
[sssd]
...
default_domain_suffix = ad.company.local
```

Додавши `default_domain_suffix`, ви вказуєте SSSD (якщо не вказано інший домен) зробити висновок, що користувач намагається автентифікуватися як користувач із `ad.company.local` домен. Це дозволяє вам автентифікуватись як щось на зразок `john.doe` замість `john.doe@ad.company.local`.

Щоб ця зміна конфігурації набула чинності, потрібно перезапустити модуль `sssd.service` за допомогою `systemctl`.

```sh
[user@host ~]$ sudo systemctl restart sssd
```

Таким же чином, якщо ви не бажаєте, щоб ваші домашні каталоги суфіксувалися доменним іменем, ви можете додати ці параметри у свій файл конфігурації `/etc/sssd/sssd.conf`:

```
[domain/ad.company.local]
use_fully_qualified_names = False
override_homedir = /home/%u
```

Не забудьте перезапустити службу `sssd`.

### Обмеження для певних користувачів

Існують різні способи обмеження доступу до сервера для обмеженого списку користувачів, але цей, як випливає з назви, безперечно найпростіший:

Додайте ці параметри у свій файл конфігурації `/etc/sssd/sssd.conf` і перезапустіть службу:

```
access_provider = simple
simple_allow_groups = group1, group2
simple_allow_users = user1, user2
```

Тепер тільки користувачі з group1 і group2 або user1 і user2 зможуть підключитися до сервера за допомогою sssd!

## Взаємодія з AD за допомогою `adcli`

`adcli` — це CLI для виконання дій у домені Active Directory.

- Якщо ще не встановлено, встановіть необхідний пакет:

```sh
[user@host ~]$ sudo dnf install adcli
```

- Перевірте, чи приєднувалися ви коли-небудь до домену Active Directory:

```sh
[user@host ~]$ sudo adcli testjoin
Successfully validated join to domain ad.company.local
```

- Отримайте більш детальну інформацію про домен:

```sh
[user@host ~]$ adcli info ad.company.local
[domain]
domain-name = ad.company.local
domain-short = AD
domain-forest = ad.company.local
domain-controller = dc1.ad.company.local
domain-controller-site = site1
domain-controller-flags = gc ldap ds kdc timeserv closest writable full-secret ads-web
domain-controller-usable = yes
domain-controllers = dc1.ad.company.local dc2.ad.company.local
[computer]
computer-site = site1
```

- Ви можете використовувати adcli більше, ніж інструмент консультування, щоб взаємодіяти зі своїм доменом: керувати користувачами чи групами, змінювати пароль тощо.

Приклад: використовуйте `adcli`, щоб отримати інформацію про комп’ютер:

!!! Note "Примітка"

    Цього разу ми надамо ім’я користувача адміністратора завдяки параметру `-U`

```sh
[user@host ~]$ adcli show-computer pctest -U admin_username
Password for admin_username@AD: 
sAMAccountName:
 pctest$
userPrincipalName:
 - not set -
msDS-KeyVersionNumber:
 9
msDS-supportedEncryptionTypes:
 24
dNSHostName:
 pctest.ad.company.local
servicePrincipalName:
 RestrictedKrbHost/pctest.ad.company.local
 RestrictedKrbHost/pctest
 host/pctest.ad.company.local
 host/pctest
operatingSystem:
 Rocky
operatingSystemVersion:
 8
operatingSystemServicePack:
 - not set -
pwdLastSet:
 133189248188488832
userAccountControl:
 69632
description:
 - not set -
```

Приклад: використовуйте `adcli`, щоб змінити пароль користувача:

```sh
[user@host ~]$ adcli passwd-user user_test -U admin_username
Password for admin_username@AD: 
Password for user_test: 
[user@host ~]$ 
```

## Вирішення проблем

Іноді мережева служба запускається після SSSD, що спричиняє проблеми з автентифікацією.

Користувачі AD не зможуть підключитися, доки ви не перезапустите службу.

У такому випадку ви повинні змінити службовий файл systemd, щоб вирішити цю проблему.

Скопіюйте цей вміст у `/etc/systemd/system/sssd.service`:

```
[Unit]
Description=System Security Services Daemon
# SSSD must be running before we permit user sessions
Before=systemd-user-sessions.service nss-user-lookup.target
Wants=nss-user-lookup.target
After=network-online.target


[Service]
Environment=DEBUG_LOGGER=--logger=files
EnvironmentFile=-/etc/sysconfig/sssd
ExecStart=/usr/sbin/sssd -i ${DEBUG_LOGGER}
Type=notify
NotifyAccess=main
PIDFile=/var/run/sssd.pid

[Install]
WantedBy=multi-user.target
```

При наступному перезавантаженні служба запуститься відповідно до своїх вимог, і все пройде добре.

## Вихід з Active Directory

Іноді необхідно вийти з AD.

Ви можете ще раз продовжити з `realm`, а потім видалити пакети, які більше не потрібні:

```sh
[user@host ~]$ sudo realm leave ad.company.local
[user@host ~]$ sudo dnf remove realmd oddjob oddjob-mkhomedir sssd adcli krb5-workstation
```
