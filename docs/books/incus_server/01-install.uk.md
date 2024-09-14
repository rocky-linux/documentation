---
title: 1 Встановлення та налаштування
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - enterprise
  - incus встановлення
---

У цьому розділі вам потрібно буде бути користувачем root або вміти користуватися _sudo_ для отримання root-прав.

## Встановлення репозиторіїв EPEL і OpenZFS

Для Incus потрібен репозиторій EPEL (додаткові пакети для Enterprise Linux), який легко встановити за допомогою:

```bash
dnf install epel-release -y
```

Після встановлення перевірте наявність оновлень:

```bash
dnf upgrade
```

Якщо під час процесу оновлення ядро було оновлено, перезавантажте сервер.

### Репозиторій OpenZFS

Встановіть репозиторій OpenZFS за допомогою:

```bash
dnf install https://zfsonlinux.org/epel/zfs-release-2-2$(rpm --eval "%{dist}").noarch.rpm
```

## Встановлення `dkms`, `vim` і `kernel-devel`

Встановіть кілька необхідних пакетів:

```bash
dnf install dkms vim kernel-devel bash-completion
```

## Встановлення Incus

Вам знадобиться репозиторій CRB, доступний для деяких спеціальних пакетів, і COPR Ніла Хенлона (Cool Other Package Repo):

```bash
dnf config-manager --enable crb
dnf copr enable neil/incus
dnf install incus incus-tools
```

Увімкніть і запустіть службу:

```bash
systemctl enable incus --now
```

Перш ніж продовжити, перезавантажте сервер.

## Встановлення OpenZFS

```bash
dnf install zfs
```

## Налаштування середовища

Більшості параметрів ядра сервера недостатньо для запуску великої кількості контейнерів. Якщо ми з самого початку припустимо, що будемо використовувати наш сервер у робочому стані, тоді нам потрібно внести ці зміни заздалегідь, щоб уникнути таких помилок, як «Забагато відкритих файлів».

На щастя, налаштувати параметри для Incus неважко за допомогою кількох змін файлів і перезавантаження.

### Зміна `limits.conf`

Перший файл, який ви повинні змінити, це файл `limits.conf`. Цей файл самодокументований. Перегляньте пояснення в коментарях до файлу, щоб зрозуміти, що робить цей файл. Щоб внести зміни, введіть:

```bash
vi /etc/security/limits.conf
```

Весь цей файл позначено/закоментовано, а внизу показано поточні налаштування за замовчуванням. У порожньому місці над маркером кінця файлу (#End of file) нам потрібно додати власні налаштування. Коли ви закінчите, кінець файлу виглядатиме як показано нижче:

```text
# Modifications made for LXD

*               soft    nofile           1048576
*               hard    nofile           1048576
root            soft    nofile           1048576
root            hard    nofile           1048576
*               soft    memlock          unlimited
*               hard    memlock          unlimited
```

Збережіть зміни та вийдіть (++shift+двокрапка+"w"+"q"+exclam++ для _vi_).

### Зміна `sysctl.conf` за допомогою `90-incus-override.conf`

За допомогою _systemd_ ви можете змінити загальну конфігурацію вашої системи та параметри ядра _без_ зміни основного файлу конфігурації. Замість цього ми розмістимо наші параметри в окремому файлі, який просто замінить потрібні нам налаштування.

Щоб внести ці зміни в ядро, ви створите файл під назвою `90-incus-override.conf` у `/etc/sysctl.d`. Щоб зробити це, впишіть:

```bash
vi /etc/sysctl.d/90-incus-override.conf
```

Розмістіть наступний вміст у цьому файлі. Зауважте, що якщо вам цікаво, що ви тут робите, вміст файлу є самодокументованим:

```bash
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

net.core.bpf_jit_limit = 1000000000

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

### Перевірка значень `sysctl.conf`

Після завершення перезавантаження знову увійдіть на сервер. Нам потрібно перевірити, чи справді наш файл заміни виконав роботу.

Це легко зробити. Немає необхідності перевіряти кожне налаштування, якщо ви цього не хочете, але перевірка кількох підтвердить, що налаштування було змінено. Зробіть це за допомогою команди `sysctl`:

```bash
sysctl net.core.bpf_jit_limit
```

Який повинен показати вам:

```bash
net.core.bpf_jit_limit = 1000000000 
```

Зробіть те саме з кількома іншими параметрами у файлі перевизначення (вище), щоб перевірити, чи внесено зміни.
