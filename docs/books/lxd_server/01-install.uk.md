---
title: 1 Встановлення та налаштування
author: Steven Spencer
contributors: Ezequiel Bruni
tested with: 8.5, 8.6, 9.0
tags:
  - lxd
  - enterprise
  - lxd install
---

# Розділ 1: Встановлення та налаштування

У цьому розділі вам потрібно буде бути користувачем root або вміти використовувати _sudo_ для отримання прав root.

## Встановлення репозиторіїв EPEL і OpenZFS

Для LXD потрібен репозиторій EPEL (Extra Packages for Enterprise Linux), який легко встановити за допомогою:

```
dnf install epel-release
```

Після встановлення перевірте наявність оновлень:

```
dnf upgrade
```

Якщо під час процесу оновлення ядро було оновлено, перезавантажте сервер.

### Репозиторій OpenZFS для 8 і 9

Встановіть репозиторій OpenZFS за допомогою:

```
dnf install https://zfsonlinux.org/epel/zfs-release-2-2$(rpm --eval "%{dist}").noarch.rpm
```

## Встановіть snapd, dkms, vim і kernel-devel

Для Rocky Linux LXD потрібно інсталювати з оснастки. З цієї причини нам потрібно встановити `snapd` (і кілька інших корисних програм) з:

```
dnf install snapd dkms vim kernel-devel
```

А тепер увімкніть і запустіть snapd:

```
systemctl enable snapd
```

А потім запустіть:

```
systemctl start snapd
```

Перш ніж продовжити, перезавантажте сервер.

## Встановлення LXD

Встановлення LXD вимагає використання команди snap. На даний момент ми просто встановлюємо його, ми не виконуємо налаштування:

```
snap install lxd
```

## Встановлення OpenZFS

```
dnf install zfs
```

## Налаштування середовища

Більшості параметрів ядра сервера недостатньо для запуску великої кількості контейнерів. Якщо ми з самого початку припустимо, що будемо використовувати наш сервер у робочому стані, тоді нам потрібно внести ці зміни заздалегідь, щоб уникнути таких помилок, як «Забагато відкритих файлів».

На щастя, налаштувати параметри для LXD легко за допомогою кількох змін файлів і перезавантаження.

### Модифікація limits.conf

Перший файл, який нам потрібно змінити, це файл limits.conf. Цей файл самодокументований, тому подивіться пояснення у файлі щодо того, що він робить. Щоб внести наші зміни, введіть:

```
vi /etc/security/limits.conf
```

Весь цей файл позначено/закоментовано, а внизу показано поточні налаштування за замовчуванням. У порожньому місці над маркером кінця файлу (#End of file) нам потрібно додати власні налаштування. Коли ви закінчите, кінець файлу виглядатиме як показано нижче:

```
# Modifications made for LXD

*               soft    nofile           1048576
*               hard    nofile           1048576
root            soft    nofile           1048576
root            hard    nofile           1048576
*               soft    memlock          unlimited
*               hard    memlock          unlimited
```

Збережіть зміни та вийдіть. (`SHIFT:wq!` для _vi_)

### Модифікація sysctl.conf за допомогою 90-lxd.override.conf

За допомогою _systemd_ ми можемо вносити зміни до загальної конфігурації нашої системи та параметрів ядра *без* зміни основного файлу конфігурації. Замість цього ми розмістимо наші параметри в окремому файлі, який просто замінить потрібні нам налаштування.

Щоб внести ці зміни в ядро, ми створимо файл під назвою _90-lxd-override.conf_ у /etc/sysctl.d. Щоб зробити цей тип:

```
vi /etc/sysctl.d/90-lxd-override.conf
```

!!! попередження "RL 9 і MAX значення `net.core.bpf_jit_limit`"

    Через останні оновлення безпеки ядра максимальне значення net.core.bpf_jit_limit становить 1000000000. Будь ласка, налаштуйте це значення у самодокументованому файлі нижче, якщо ви використовуєте Rocky Linux 9.x. Якщо ви встановите його вище цього ліміту **АБО**, якщо ви взагалі не встановите його, за умовчанням буде встановлено системне значення за замовчуванням 264241152, чого може бути недостатньо, якщо ви запускаєте велику кількість контейнерів.

Розмістіть наступний вміст у цьому файлі. Зверніть увагу: якщо вам цікаво, що ми тут робимо, вміст файлу нижче є самодокументованим:

```
## The following changes have been made for LXD ##

# fs.inotify.max_queued_events specifies an upper limit on the number of events that can be queued to the corresponding inotify instance
 - (default is 16384)

fs.inotify.max_queued_events = 1048576

# fs.inotify.max_user_instances This specifies an upper limit on the number of inotify instances that can be created per real user ID -
(default value is 128)

fs.inotify.max_user_instances = 1048576

# fs.inotify.max_user_watches specifies an upper limit on the number of watches that can be created per real user ID - (default is 8192)

fs.inotify.max_user_watches = 1048576

# vm.max_map_count contains the maximum number of memory map areas a process may have. Memory map areas are used as a side-effect of cal
ling malloc, directly by mmap and mprotect, and also when loading shared libraries - (default is 65530)

vm.max_map_count = 262144

# kernel.dmesg_restrict denies container access to the messages in the kernel ring buffer. Please note that this also will deny access t
o non-root users on the host system - (default is 0)

kernel.dmesg_restrict = 1

# This is the maximum number of entries in ARP table (IPv4). You should increase this if you create over 1024 containers.

net.ipv4.neigh.default.gc_thresh3 = 8192

# This is the maximum number of entries in ARP table (IPv6). You should increase this if you plan to create over 1024 containers.Not nee
ded if not using IPv6, but...

net.ipv6.neigh.default.gc_thresh3 = 8192

# This is a limit on the size of eBPF JIT allocations which is usually set to PAGE_SIZE * 40000. Set this to 1000000000 if you are running Rocky Linux 9.x

net.core.bpf_jit_limit = 3000000000

# This is the maximum number of keys a non-root user can use, should be higher than the number of containers

kernel.keys.maxkeys = 2000

# This is the maximum size of the keyring non-root users can use

kernel.keys.maxbytes = 2000000

# This is the maximum number of concurrent async I/O operations. You might need to increase it further if you have a lot of workloads th
at use the AIO subsystem (e.g. MySQL)

fs.aio-max-nr = 524288
```

Збережіть зміни та вийдіть.

На цьому етапі вам слід перезавантажити сервер.

### Перевірка значень _sysctl.conf_

Після завершення перезавантаження знову увійдіть на сервер. Нам потрібно перевірити, чи справді наш файл заміни виконав роботу.

Це легко зробити. Немає необхідності перевіряти кожне налаштування, якщо ви цього не хочете, але перевірка кількох підтвердить, що налаштування було змінено. Це робиться за допомогою команди _sysctl_:

```
sysctl net.core.bpf_jit_limit
```

Який повинен показати вам:

```
net.core.bpf_jit_limit = 3000000000
```

Зробіть те саме з кількома іншими параметрами у файлі перевизначення (вище), щоб перевірити, чи внесено зміни.
