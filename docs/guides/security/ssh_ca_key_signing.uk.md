---
title: Центри сертифікації SSH і підписування ключів
author: Julian Patocki
contributors: Steven Spencer
tags:
  - безпека
  - ssh
  - keygen
  - сертифікати
---

## Передумови

- Вміння використовувати засоби командного рядка
- Керування вмістом з командного рядка
- Попередній досвід створення ключів SSH корисний, але не обов’язковий
- Базове розуміння SSH та інфраструктури відкритих ключів корисне, але не обов’язкове
- Сервер, на якому працює демон sshd.

## Вступ

Початкове з’єднання SSH із віддаленим хостом є небезпечним, якщо ви не можете перевірити відбиток ключа віддаленого хосту. Використання центру сертифікації для підпису відкритих ключів віддалених хостів захищає початкове підключення для кожного користувача, який довіряє ЦС.

ЦС також можна використовувати для підпису SSH-ключів користувача. Замість розповсюдження ключа кожному віддаленому хосту достатньо одного підпису, щоб авторизувати користувача для входу на декілька серверів.

## Завдання

- Покращення безпеки підключень SSH.
- Покращення процесу реєстрації та управління ключами.

## Примітки

- Vim є текстовим редактором за вибором автора. Допускається використання інших текстових редакторів, наприклад nano або інших.
- Використання `sudo` або `root` передбачає підвищені привілеї.

## Початкове підключення

Щоб убезпечити початкове підключення, вам потрібно попередньо знати відбиток ключа. Ви можете оптимізувати та інтегрувати цей процес розгортання для нових хостів.

Відображення відбитка ключа на віддаленому хості:

```bash
user@rocky-vm ~]$ ssh-keygen -E sha256 -l -f /etc/ssh/ssh_host_ed25519_key.pub 
256 SHA256:bXWRZCpppNWxXs8o1MyqFlmfO8aSG+nlgJrBM4j4+gE no comment (ED25519)
```

Створення початкового підключення SSH від клієнта. Ключовий відбиток відображається, і його можна порівняти з попередньо отриманим:

```bash
[user@rocky ~]$ ssh user@rocky-vm.example.com
The authenticity of host 'rocky-vm.example (192.168.56.101)' can't be established.
ED25519 key fingerprint is SHA256:bXWRZCpppNWxXs8o1MyqFlmfO8aSG+nlgJrBM4j4+gE.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

## Створення центру сертифікації

Створення ЦС (приватного та відкритого ключів) і розміщення відкритого ключа у файлі `known_hosts` клієнта для ідентифікації всіх хостів, що належать до домену example.com:

```bash
[user@rocky ~]$ ssh-keygen -b 4096 -t ed25519 -f CA
[user@rocky ~]$ echo '@cert-authority *.example.com' $(cat CA.pub) >> ~/.ssh/known_hosts
```

Де:

- **-b**: довжина ключа в байтах
- **-t**: тип ключа: rsa, ed25519, ecdsa...
- **-f**: вихідний файл ключа

Крім того, ви можете вказати файл `known_hosts` для всієї системи, відредагувавши файл конфігурації SSH `/etc/ssh/ssh_config`:

```bash
Host *
    GlobalKnownHostsFile /etc/ssh/ssh_known_hosts
```

## Підписання відкритих ключів

Створення SSH-ключа користувача та його підписання:

```bash
[user@rocky ~]$ ssh-keygen -b 4096 -t ed2119
[user@rocky ~]$ ssh-keygen -s CA -I user -n user -V +55w  id_ed25519.pub
```

Отримання відкритого ключа сервера через `scp` і його підписання:

```bash
[user@rocky ~]$ scp user@rocky-vm.example.com:/etc/ssh/ssh_host_ed25519_key.pub .
[user@rocky ~]$ ssh-keygen -s CA -I rocky-vm -n rocky-vm.example.com -h -V +55w ssh_host_ed25519_key.pub
```

Де:

- **-s**: ключ підпису
- **-I**: ім'я, яке ідентифікує сертифікат для цілей реєстрації
- **-n**: ідентифікує ім’я (хост або користувач, один або кілька), пов’язане з сертифікатом (якщо не вказано, сертифікати дійсні для всіх користувачів або хостів)
- **-h**: визначає сертифікат як ключ хоста, на відміну від ключа клієнта
- **-V**: термін дії сертифіката

## Встановлення довіри

Копіювання сертифіката віддаленого хоста, щоб віддалений хост представив його разом із відкритим ключем під час підключення до:

```bash
[user@rocky ~]$ scp ssh_host_ed25519_key-cert.pub root@rocky-vm.example.com:/etc/ssh/
```

Копіювання відкритого ключа ЦС на віддалений хост, щоб він довіряв сертифікатам, підписаним ЦС:

```bash
[user@rocky ~]$ scp CA.pub root@rocky-vm.example.com:/etc/ssh/
```

Додайте наступні рядки до файлу `/etc/ssh/sshd_config`, щоб указати попередньо скопійований ключ і сертифікат для використання сервером і довірити ЦС для ідентифікації користувачів:

```bash
[user@rocky ~]$ ssh user@rocky-vm.example.com
[user@rocky-vm ~]$ sudo vim /etc/ssh/sshd_config
```

```bash
HostKey /etc/ssh/ssh_host_ed25519_key
HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub
TrustedUserCAKeys /etc/ssh/CA.pub
```

Перезапуск служби `sshd` на сервері:

```bash
[user@rocky-vm ~]$ systemctl restart sshd
```

## Тестування підключення

Видалення відбитка пальця віддаленого сервера з вашого файлу `known_hosts` і перевірка налаштувань шляхом встановлення з’єднання SSH:

```bash
[user@rocky ~]$ ssh-keygen -R rocky-vm.example.com
[user@rocky ~]$ ssh user@rocky-vm.example.com
```

## Відкликання ключа

Відкликання ключів хоста або користувача може мати вирішальне значення для безпеки всього середовища. Таким чином, важливо зберігати раніше підписані відкриті ключі, щоб ви могли відкликати їх пізніше.

Створення порожнього списку відкликань і відкликання відкритого ключа користувача2:

```bash
[user@rocky ~]$ sudo ssh-keygen -k -f /etc/ssh/revokation_list.krl
[user@rocky ~]$ sudo ssh-keygen -k -f /etc/ssh/revokation_list.krl -u /path/to/user2_id_ed25519.pub
```

Копіювання списку відкликань на віддалений хост і вказівка ​​його у файлі `sshd_config`:

```bash
[user@rocky ~]$ scp /etc/ssh/revokation_list.krl root@rocky-vm.example.com:/etc/ssh/
[user@rocky ~]$ ssh user@rocky-vm.example.com
[user@rocky ~]$ sudo vim /etc/ssh/sshd_config
```

У наступному рядку вказано список відкликань:

```bash
RevokedKeys /etc/ssh/revokation_list.krl
```

Для перезавантаження конфігурації потрібно перезапустити демон SSHD:

```bash
[user@rocky-vm ~]$ sudo systemctl restart sshd
```

Користувача 2 відхилено сервером:

```bash
[user2@rocky ~]$ ssh user2@rocky-vm.example.com
user2@rocky-vm.example.com: Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
```

Відкликати ключі сервера також можливо:

```bash
[user@rocky ~]$ sudo ssh-keygen -k -f /etc/ssh/revokation_list.krl -u /path/to/ssh_host_ed25519_key.pub
```

Наступні рядки в `/etc/ssh/ssh_config` застосовують список відкликаних хостів для всієї системи:

```bash
Host *
        RevokedHostKeys /etc/ssh/revokation_list.krl
```

Спроба підключитися до хосту призводить до наступного:

```bash
[user@rocky ~]$ ssh user@rocky-vm.example.com
Host key ED25519-CERT SHA256:bXWRZCpppNWxXs8o1MyqFlmfO8aSG+nlgJrBM4j4+gE revoked by file /etc/ssh/revokation_list.krl
```

Ведення та оновлення списків відкликань є важливим. Ви можете автоматизувати процес, щоб усі хости та користувачі мали доступ до останніх списків відкликань.

## Висновок

SSH є одним із найцінніших протоколів для керування віддаленими серверами. Запровадження центрів сертифікації може бути корисним, особливо у великих середовищах із великою кількістю серверів і користувачів.
Важливо вести списки відкликань. Він легко скасовує зламані ключі, не замінюючи всю критичну інфраструктуру.
