---
title: NSD Authoritative DNS
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.4
tags:
  - dns
---

Альтернативою BIND, [NSD](https://www.nlnetlabs.nl/projects/nsd/about/) (Name Server Daemon) є сучасний авторитетний сервер DNS, який підтримується [NLnet Labs](https:// www.nlnetlabs.nl/).

## Передумови та припущення

- Сервер під керуванням Rocky Linux
- Можливість використання `firewalld` для створення правил брандмауера
- Доменне ім’я або внутрішній рекурсивний DNS-сервер вказує на ваш авторитетний DNS-сервер

## Вступ

Зовнішні або загальнодоступні DNS-сервери відображають імена хостів на IP-адреси, а у випадку записів PTR (відомих як «вказівник» або «зворотний»), відображають IP-адреси в імені хоста. Це важлива частина Інтернету. Завдяки цьому ваш поштовий сервер, веб-сервер, FTP-сервер або багато інших серверів і служб працюють належним чином, незалежно від того, де ви знаходитесь.

## Встановлення та включення NSD

Спочатку встановіть EPEL:

```bash
dnf install epel-release
```

Далі встановіть NSD:

```bash
dnf install nsd
```

## Налаштування NSD

Перш ніж вносити зміни до будь-якого конфігураційного файлу, скопіюйте оригінальний встановлений робочий файл `nsd.conf`:

```bash
cp /etc/nsd/nsd.conf /etc/nsd/nsd.conf.orig
```

Це допоможе в майбутньому, якщо станеться введення помилок у файл конфігурації. _Завжди_ варто зробити резервну копію перед внесенням змін.

Відредагуйте файл _nsd.conf_. Автор використовує _vi_, але ви можете замінити свій улюблений редактор командного рядка:

```bash
vi /etc/nsd/nsd.conf
```

Перейдіть униз і вставте наступне:

```bash
zone:
    name: example.com
    zonefile: /etc/nsd/example.com.zone
```

Замініть `example.com` ім'ям домену, для якого ви запускаєте сервер імен.

Далі створіть файли зони:

```bash
vi /etc/nsd/example.com.zone
```

Файли зони DNS сумісні з BIND. У файл вставте:

```bash
$TTL    86400 ; How long should records last?
; $TTL used for all RRs without explicit TTL value
$ORIGIN example.com. ; Define our domain name
@  1D  IN  SOA ns1.example.com. hostmaster.example.com. (
                              2024061301 ; serial
                              3h ; refresh duration
                              15 ; retry duration
                              1w ; expiry duration
                              3h ; nxdomain error ttl
                             )
       IN  NS     ns1.example.com. ; in the domain
       IN  MX  10 mail.another.com. ; external mail provider
       IN  A      172.20.0.100 ; default A record
; server host definitions
ns1    IN  A      172.20.0.100 ; name server definition
www    IN  A      172.20.0.101 ; web server definition
mail   IN  A      172.20.0.102 ; mail server definition
```

Якщо вам потрібна допомога з налаштуванням файлів зон у стилі BIND, Oracle має [хороший вступ до файлів зон](https://docs.oracle.com/en-us/iaas/Content/DNS/Reference/formattingzonefile.htm).

Збережіть зміни.

## Включення NSD

Далі дозвольте порти DNS у `firewalld` і ввімкніть NSD:

```bash
firewall-cmd --add-service=dns --zone=public
firewall-cmd --runtime-to-permanent
systemctl enable --now nsd
```

Перевірте дозвіл DNS за допомогою команди `host`:

```bash
% host example.com 172.20.0.100
Using domain server:
Name: 172.20.0.100
Address: 172.20.0.100#53
Aliases:

example.com has address 172.20.0.100
example.com mail is handled by 10 mail.another.com.
%
```

## Висновок

Більшість людей використовують сторонні служби для DNS. Однак є сценарії, коли бажано самостійно розмістити DNS. Наприклад, телекомунікаційні, хостингові та соціальні медіа компанії розміщують багато записів DNS, де розміщені послуги є небажаними.

NSD є одним із багатьох інструментів з відкритим кодом, які роблять можливим розміщення DNS. Вітаємо, у вас є власний DNS-сервер!
