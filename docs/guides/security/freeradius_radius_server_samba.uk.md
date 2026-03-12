---
title: Сервер FreeRADIUS RADIUS із Samba Active Directory
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 10.1
tags:
  - security
---

## Вступ

RADIUS — це протокол AAA (аутентифікація, авторизація та облік) для керування доступом до мережі. [FreeRADIUS](https://www.freeradius.org/) – це фактичний RADIUS-сервер для Linux та інших Unix-подібних систем.

Ви можете налаштувати FreeRADIUS на роботу з Active Directory від Microsoft, скажімо, для автентифікації 802.1X, Wi-Fi або VPN.

## Передумови та припущення

Нижче наведено мінімальні вимоги для цієї процедури:

- Можливість виконувати команди від імені користувача root або використовувати `sudo` для підвищення привілеїв
- Сервер-член Active Directory, незалежно від того, чи використовує він домен Windows Server або Samba
- Клієнт RADIUS, такий як маршрутизатор, комутатор або точка доступу Wi-Fi

## Налаштування Samba

Вам потрібно буде налаштувати Active Directory за допомогою Samba. Зверніть увагу, що sssd не працюватиме.

## Встановлення FreeRADIUS

Ви можете встановити FreeRADIUS з репозиторіїв `dnf`:

```bash
dnf install -y freeradius
```

## Налаштування FreeRADIUS

Після встановлення пакетів спочатку потрібно згенерувати сертифікати шифрування TLS для FreeRADIUS:

```bash
cd /etc/raddb/certs
./bootstrap
```

Згодом вам потрібно буде ввімкнути `ntlm_auth`. Відредагуйте файл `/etc/raddb/sites-enabled/default` та вставте наступний код у блок `authenticate`:

```bash
authenticate {
...
    ntlm_auth
...
}
```

Вставте те саме в `/etc/raddb/sites-enabled/inner_tunnel`:

```bash
authenticate {
...
    ntlm_auth
...
}
```

Змініть рядок `program` у `/etc/raddb/mods-enabled/ntlm_auth` на цей:

```bash
    program = "/usr/bin/ntlm_auth --request-nt-key --domain=MYDOMAIN --username=%{mschap:User-Name} --password=%{User-Password}"
```

Замініть `MYDOMAIN` на ім'я вашого домену Active Directory.

Вам потрібно буде зробити `ntlm_auth` типом автентифікації за замовчуванням у `/etc/raddb/mods-config/files/authorize`. Додайте наступний рядок:

```bash
DEFAULT   Auth-Type = ntlm_auth
```

Вам також потрібно буде визначити клієнтів. Це зроблено для запобігання несанкціонованому доступу до нашого RADIUS-сервера. Відредагуйте файл `clients.conf`:

```bash
vi clients.conf
```

Вставте наступне:

```bash
client 172.20.0.254 {
        secret = secret123
}
```

Замініть `172.20.0.254` та `secret123` на IP-адресу та секретне значення, які використовуватимуть клієнти. Повторіть це для інших клієнтів.

## Увімкнення FreeRADIUS

Після початкового налаштування можна запустити `radiusd`:

```bash
systemctl enable --now radiusd
```

## Налаштування RADIUS на комутаторі

Після налаштування сервера FreeRADIUS вам потрібно налаштувати клієнт RADIUS на комутаторі MikroTik автора як дротовий клієнт 802.1X:

```bash
/radius
add address=172.20.0.12 secret=secret123 service=dot1x
/interface dot1x server
add interface=combo3
```

Замініть `172.20.0.12` на IP-адресу сервера FreeRADIUS, а `secret123` на секретний ключ, який ви встановили раніше.
