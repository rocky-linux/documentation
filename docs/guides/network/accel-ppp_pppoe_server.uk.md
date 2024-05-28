---
title: accel-ppp PPPoE Server
author: Neel Chauhan
contributors: null
tested_with: 9.3
tags:
  - мережа
---

# accel-ppp PPPoE Server

## Вступ

PPPoE — це протокол, який використовується в основному провайдерами DSL і оптоволокна до дому, де клієнти автентифікуються за допомогою комбінації імені користувача та пароля. PPPoE використовується в країнах, де від чинного провайдера потрібен спільний доступ до своєї мережі з іншими провайдерами, оскільки клієнти можуть бути маршрутизовані через доменне ім’я до потрібного провайдера.

[accel-ppp](https://accel-ppp.org/) — це прискорена реалізація PPPoE за допомогою ядра Linux і пов’язаних протоколів, таких як PPTP, L2TP та інші.

## Передумови

- Сервер з двома мережевими інтерфейсами
- Клієнтський маршрутизатор або машина, що розмовляє PPPoE

## Встановлення accel-ppp

Оскільки accel-ppp відсутній у сховищах Rocky або EPEL за замовчуванням, ми спочатку встановлюємо необхідні пакунки для його створення:

```bash
dnf install -y rpm-build make cmake gcc git openssl-devel pcre-devel kernel-modules-extra
```

Згодом клонуйте вихідний код accel-ppp до папки:

```bash
git clone https://github.com/accel-ppp/accel-ppp.git /opt/accel-ppp
mkdir /opt/accel-ppp/build
cd /opt/accel-ppp/build/
```

Далі нам потрібно створити accel-ppp (Примітка: якщо ви використовуєте Rocky Linux 8.x, замініть у `Centos8` `Centos9`):

```bash
cmake -DCMAKE_INSTALL_PREFIX=/usr -DCPACK_TYPE=Centos9 ..
make
```

Нарешті, ми створимо пакет `rpm` і встановимо його:

```bash
cpack -G RPM
rpm -ivh accel-ppp.rpm
```

## Налаштування accel-ppp

По-перше, нам потрібно ввімкнути IP-переадресацію:

```bash
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
sysctl -p
```

Потім додайте наступне до `/etc/accel-ppp.conf`:

```bash
[modules]
log_file
pppoe
auth_mschap_v2
auth_mschap_v1
auth_chap_md5
auth_pap
chap-secrets
ippool

[core]
log-error=/var/log/accel-ppp/core.log
thread-count=4

[ppp]
ipv4=require

[pppoe]
interface=YOUR_INTERFACE

[dns]
dns1=YOUR_DNS1
dns2=YOUR_DNS2

[ip-pool]
gw-ip-address=YOUR_GW
YOUR_IP_RANGE

[chap-secrets]
gw-ip-address=YOUR_GW
chap-secrets=/etc/chap-secrets
```

Замініть наступну інформацію:

- **YOUR_INTERFACE** з інтерфейсом, який прослуховує клієнтів PPPoE.
- **YOUR_DNS1** і **YOUR_DNS2** із DNS-серверами для передачі клієнтам.
- **YOUR_GW** – це IP-адреса сервера для клієнтів PPPoE. Це **повинно** відрізнятися від IP-адреси сервера WAN або шлюзу за замовчуванням.
- **YOUR_IP_RANGE** з діапазонами IP-адрес для роздачі клієнтам. Це може бути діапазон IP-адрес, наприклад X.X.X.Y-Z, або у форматі CDIR, наприклад X.X.X.X/MASK.

Згодом додамо файл barebone `/etc/chap-secrets`:

```bash
user	*	password	*
```

Ви можете додати більше користувачів за допомогою додаткових рядків, замінивши `user` і `password` на потрібне ім'я користувача та пароль.

## Налаштування клієнта PPPoE

Після налаштування сервера PPPoE ми можемо почати додавати клієнтів PPPoE. Автор любить використовувати [MikroTik CHR](https://help.mikrotik.com/docs/display/ROS/Cloud+Hosted+Router%2C+CHR) як свій клієнт PPPoE для тестування, тому ми будемо використовувати його.

Після встановлення MikroTik CHR на систему, підключену до тієї ж мережі Ethernet, що й інтерфейс прослуховування сервера PPPoE, ми налаштуємо PPPoE:

```bash
[admin@MikroTik] > /interface pppoe-client
[admin@MikroTik] > add add-default-route=yes disabled=no interface=ether1 name=pppoe-out1 \
    password=password user=user
```

Якщо все працює належним чином, ми повинні отримати адресу IPv4:

```bash
[admin@MikroTik] > /ip/address/print
Flags: D - DYNAMIC
Columns: ADDRESS, NETWORK, INTERFACE
#   ADDRESS      NETWORK   INTERFACE 
0 D 10.0.0.1/32  10.0.0.0  pppoe-out1
```

## Висновок

PPPoE часто отримує погану репутацію, і легко зрозуміти чому: вам потрібно налаштувати імена користувачів і паролі вручну. Незважаючи на це, він забезпечує безпеку під час підключення до широкомовного домену рівня 2 у сценаріях провайдера, де вимагати 802.1X або MACsec було б небажано, наприклад, щоб дозволити маршрутизатори, що належать клієнтам, або статичні IP-адреси. І тепер ви власний міні-провайдер, вітаємо!
