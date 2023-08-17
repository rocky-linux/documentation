---
title: Управління програмним забезпеченням
author: Antoine Le Morvan
contributors: Colussi Franco, Steven Spencer
tested version: 8.5
tags:
  - освіта
  - програмне забезпечення
  - управління програмним забезпеченням
---

# Управління програмним забезпеченням

## Загальні положення

У системі Linux програмне забезпечення можна встановити двома способами:

* Використовуючи інсталяційний пакет;
* Компіляцією з вихідних файлів.

!!! Примітка

    Встановлення з джерела тут не розглядається. Як правило, ви повинні використовувати пакетний метод, якщо потрібне програмне забезпечення недоступне через менеджер пакетів. Причиною цього є те, що залежностями зазвичай керує система пакунків, тоді як із вихідним кодом вам потрібно керувати залежностями вручну.

**Пакет**: це один файл, що містить усі дані, необхідні для встановлення програми. Його можна виконати безпосередньо в системі з репозиторію програмного забезпечення.

**Вихідні файли**: деяке програмне забезпечення надається не в пакетах, готових для встановлення, а в архіві, що містить вихідні файли. Адміністратор має підготувати ці файли та скомпілювати їх для встановлення програми.

## RPM: RedHat Package Manager

**RPM** (RedHat Package Manager) — система керування програмним забезпеченням. Можна встановити, видалити, оновити або перевірити програмне забезпечення, що міститься в пакетах.

**RPM** — це формат, який використовують усі дистрибутиви на основі RedHat (RockyLinux, Fedora, CentOS, SuSe, Mandriva тощо). Його еквівалентом у світі Debian є DPKG (пакет Debian).

Назва пакета RPM відповідає певній номенклатурі:

![Ілюстрація назви пакета](images/software-001.png)

### Команда `rpm`

Команда rpm дозволяє встановити пакет.

```bash
rpm [-i][-U] package.rpm [-e] package
```

Приклад (для пакета з назвою "пакет"):

```bash
rpm -ivh package.rpm
```

| Опція            | Опис                                |
| ---------------- | ----------------------------------- |
| `-i package.rpm` | Встановлює пакет.                   |
| `-U package.rpm` | Оновлює вже встановлений пакет.     |
| `-e package.rpm` | Видаляє пакет.                      |
| `-h`             | Відображає індикатор виконання.     |
| `-v`             | Інформує про хід операції.          |
| `--test`         | Перевіряє команду, не виконуючи її. |

Команда `rpm` також дозволяє запитувати базу даних пакетів системи, додавши параметр `-q`.

Існує можливість виконання кількох типів запитів для отримання різної інформації про встановлені пакети. База даних RPM знаходиться в каталозі `/var/lib/rpm`.

Приклад:

```bash
rpm -qa
```

Ця команда запитує всі пакети, встановлені в системі.

```bash
rpm -q [-a][-i][-l] package [-f] file
```

Приклад:

```bash
rpm -qil package
rpm -qf /path/to/file
```

| Опція            | Опис                                                                                           |
| ---------------- | ---------------------------------------------------------------------------------------------- |
| `-a`             | Перелічує всі пакети, встановлені в системі.                                                   |
| `-i __package__` | Відображає інформацію про пакет.                                                               |
| `-l __package__` | Перелічує файли, що містяться в пакеті.                                                        |
| `-f`             | Відображає назву пакета, що містить вказаний файл.                                             |
| `--last`         | Список пакетів подано за датою інсталяції (першими відображаються останні встановлені пакети). |

!!! Увага

    Після параметра "-q" ім'я пакета має бути точним. Метасимволи (знаки підстановки) не підтримуються.

!!! tip "Порада"

    Однак можна переглянути список усіх встановлених пакетів і відфільтрувати їх за допомогою команди grep.

Приклад: список останніх встановлених пакетів:

```bash
sudo rpm -qa --last | head
NetworkManager-config-server-1.26.0-13.el8.noarch Mon 24 May 2021 02:34:00 PM CEST
iwl2030-firmware-18.168.6.1-101.el8.1.noarch  Mon 24 May 2021 02:34:00 PM CEST
iwl2000-firmware-18.168.6.1-101.el8.1.noarch  Mon 24 May 2021 02:34:00 PM CEST
iwl135-firmware-18.168.6.1-101.el8.1.noarch   Mon 24 May 2021 02:34:00 PM CEST
iwl105-firmware-18.168.6.1-101.el8.1.noarch   Mon 24 May 2021 02:34:00 PM CEST
iwl100-firmware-39.31.5.1-101.el8.1.noarch    Mon 24 May 2021 02:34:00 PM CEST
iwl1000-firmware-39.31.5.1-101.el8.1.noarch   Mon 24 May 2021 02:34:00 PM CEST
alsa-sof-firmware-1.5-2.el8.noarch            Mon 24 May 2021 02:34:00 PM CEST
iwl7260-firmware-25.30.13.0-101.el8.1.noarch  Mon 24 May 2021 02:33:59 PM CEST
iwl6050-firmware-41.28.5.1-101.el8.1.noarch   Mon 24 May 2021 02:33:59 PM CEST
```

Приклад: список історії встановлення ядра:

```bash
sudo rpm -qa --last kernel
kernel-4.18.0-305.el8.x86_64                  Tue 25 May 2021 06:04:56 AM CEST
kernel-4.18.0-240.22.1.el8.x86_64             Mon 24 May 2021 02:33:35 PM CEST
```

Приклад: список усіх встановлених пакетів із певною назвою за допомогою `grep`:

```bash
sudo dnf list installed | grep httpd
centos-logos-httpd.noarch           80.5-2.el8                              @baseos
httpd.x86_64                        2.4.37-30.module_el8.3.0+561+97fdbbcc   @appstream
httpd-filesystem.noarch             2.4.37-30.module_el8.3.0+561+97fdbbcc   @appstream
httpd-tools.x86_64                  2.4.37-30.module_el8.3.0+561+97fdbbcc   @appstream
```

## DNF: Dandified Yum

**DNF** (**Dandified Yum**) — менеджер пакетів програмного забезпечення, наступник **YUM** (**Y**yellow dog **U**pdater ** M**odified). Він працює з пакетами **RPM**, згрупованими в локальному чи віддаленому репозиторії (каталог для зберігання пакетів). Для найбільш поширених команд його використання ідентично використанню `yum`.

Команда `dnf` дозволяє керувати пакунками шляхом порівняння пакетів, встановлених у системі, з пакетами в сховищах, визначених на сервері. Він також автоматично встановлює залежності, якщо вони також присутні в сховищах.

`dnf` — це менеджер, який використовується багатьма дистрибутивами на основі RedHat (RockyLinux, Fedora, CentOS, ...). Його еквівалентом у світі Debian є **APT** (**A**advanced **P**ackaging **T**acking).

### Команда `dnf`

Команда `dnf` дозволяє встановити пакет, вказавши лише коротку назву.

```bash
dnf [install][remove][list all][search][info] package
```

Приклад:

```bash
dnf install tree
```

Потрібна лише коротка назва пакета.

| Опція                     | Опис                                                                |
| ------------------------- | ------------------------------------------------------------------- |
| `install`                 | Встановлює пакет.                                                   |
| `remove`                  | Видаляє пакет.                                                      |
| `list all`                | Перелічує пакети, які вже є в сховищі.                              |
| `search`                  | Шукає пакети у сховищі.                                             |
| `provides */command_name` | Шукає команди.                                                      |
| `info`                    | Відображає інформацію про пакет.                                    |
| `autoremove`              | Видаляє всі пакети, встановлені як залежні, але більше не потрібні. |


Команда `dnf install` дозволяє вам інсталювати потрібний пакет, не турбуючись про його залежності, які будуть вирішені безпосередньо самим `dnf`.

```bash
dnf install nginx
Last metadata expiration check: 3:13:41 ago on Wed 23 Mar 2022 07:19:24 AM CET.
Dependencies resolved.
Transaction Summary
============================================================================================================================
Install  7 Packages

Total download size: 816 k
Installed size: 2.2 M
Is this ok [y/N]:
```

Якщо ви не пам’ятаєте точну назву пакета, ви можете знайти його за допомогою команди `dnf search name`. Як ви бачите, є розділ, який містить точну назву, і інший, який містить листування пакета, усі вони виділені для полегшення пошуку.

```bash
dnf search nginx
Last metadata expiration check: 0:20:55 ago on Wed 23 Mar 2022 10:40:43 AM CET.
=============================================== Name Exactly Matched: nginx ================================================
nginx.aarch64 : A high performance web server and reverse proxy server
============================================== Name & Summary Matched: nginx ===============================================
collectd-nginx.aarch64 : Nginx plugin for collectd
munin-nginx.noarch : NGINX support for Munin resource monitoring
nginx-all-modules.noarch : A meta package that installs all available Nginx modules
nginx-filesystem.noarch : The basic directory layout for the Nginx server
nginx-mod-http-image-filter.aarch64 : Nginx HTTP image filter module
nginx-mod-http-perl.aarch64 : Nginx HTTP perl module
nginx-mod-http-xslt-filter.aarch64 : Nginx XSLT module
nginx-mod-mail.aarch64 : Nginx mail modules
nginx-mod-stream.aarch64 : Nginx stream modules
pagure-web-nginx.noarch : Nginx configuration for Pagure
pcp-pmda-nginx.aarch64 : Performance Co-Pilot (PCP) metrics for the Nginx Webserver
python3-certbot-nginx.noarch : The nginx plugin for certbot
```

Інший спосіб пошуку пакета шляхом введення додаткового ключа пошуку полягає в тому, щоб надіслати результат команди `dnf` через канал до команди grep з потрібним ключем.

```bash
dnf search nginx | grep mod
Last metadata expiration check: 3:44:49 ago on Wed 23 Mar 2022 06:16:47 PM CET.
nginx-all-modules.noarch : A meta package that installs all available Nginx modules
nginx-mod-http-image-filter.aarch64 : Nginx HTTP image filter module
nginx-mod-http-perl.aarch64 : Nginx HTTP perl module
nginx-mod-http-xslt-filter.aarch64 : Nginx XSLT module
nginx-mod-mail.aarch64 : Nginx mail modules
nginx-mod-stream.aarch64 : Nginx stream modules
```


Команда `dnf remove` видаляє пакет із системи та його залежності. Нижче наведено фрагмент команди **dnf remove httpd**.

```bash
dnf remove httpd
Dependencies resolved.
============================================================================================================================
 Package                        Architecture    Version                                            Repository          Size
============================================================================================================================
Removing:
 httpd                          aarch64         2.4.37-43.module+el8.5.0+727+743c5577.1            @appstream         8.9 M
Removing dependent packages:
 mod_ssl                        aarch64         1:2.4.37-43.module+el8.5.0+727+743c5577.1          @appstream         274 k
 php                            aarch64         7.4.19-1.module+el8.5.0+696+61e7c9ba               @appstream         4.4 M
 python3-certbot-apache         noarch          1.22.0-1.el8                                       @epel              539 k
Removing unused dependencies:
 apr                            aarch64         1.6.3-12.el8                                       @appstream         299 k
 apr-util                       aarch64         1.6.1-6.el8.1                                      @appstream         224 k
 apr-util-bdb                   aarch64         1.6.1-6.el8.1                                      @appstream          67 k
 apr-util-openssl               aarch64         1.6.1-6.el8.1                                      @appstream          68 k
 augeas-libs                    aarch64         1.12.0-6.el8                                       @baseos            1.4 M
 httpd-filesystem               noarch          2.4.37-43.module+el8.5.0+727+743c5577.1            @appstream         400
 httpd-tools                    aarch64         2.4.37-43.module+el8.5.0+727+743c5577.1
...
```

Команда `dnf list` містить список усіх пакетів, встановлених у системі та присутніх у сховищі. Вона приймає кілька параметрів:

| Параметр    | Опис                                                                  |
| ----------- | --------------------------------------------------------------------- |
| `all`       | Перелічує встановлені пакунки, а потім доступні у сховищах.           |
| `available` | Перелічує лише пакети, доступні для встановлення.                     |
| `updates`   | Перелічує пакети, які можна оновити.                                  |
| `obsoletes` | Перелічує пакети, які стали застарілими через доступні новіші версії. |
| `recent`    | Перелічує останні пакети, додані до сховища.                          |

Команда `dnf info`, як і можна було очікувати, надає детальну інформацію про пакет:

```bash
dnf info firewalld
Last metadata expiration check: 15:47:27 ago on Tue 22 Mar 2022 05:49:42 PM CET.
Installed Packages
Name         : firewalld
Version      : 0.9.3
Release      : 7.el8
Architecture : noarch
Size         : 2.0 M
Source       : firewalld-0.9.3-7.el8.src.rpm
Repository   : @System
From repo    : baseos
Summary      : A firewall daemon with D-Bus interface providing a dynamic firewall
URL          : http://www.firewalld.org
License      : GPLv2+
Description  : firewalld is a firewall service daemon that provides a dynamic customizable
             : firewall with a D-Bus interface.

Available Packages
Name         : firewalld
Version      : 0.9.3
Release      : 7.el8_5.1
Architecture : noarch
Size         : 501 k
Source       : firewalld-0.9.3-7.el8_5.1.src.rpm
Repository   : baseos
Summary      : A firewall daemon with D-Bus interface providing a dynamic firewall
URL          : http://www.firewalld.org
License      : GPLv2+
Description  : firewalld is a firewall service daemon that provides a dynamic customizable
             : firewall with a D-Bus interface.
```

Іноді ви знаєте лише виконуваний файл, який хочете використати, але не знаєте пакунок, який його містить. У цьому випадку ви можете використати команду `dnf provides */package_name`, яка шукатиме в базі даних для вас потрібний збіг.

Приклад пошуку команди `semanage`:

```bash
dnf provides */semanage
Last metadata expiration check: 1:12:29 ago on Wed 23 Mar 2022 10:40:43 AM CET.
libsemanage-devel-2.9-6.el8.aarch64 : Header files and libraries used to build policy manipulation tools
Repo        : powertools
Matched from:
Filename    : /usr/include/semanage

policycoreutils-python-utils-2.9-16.el8.noarch : SELinux policy core python utilities
Repo        : baseos
Matched from:
Filename    : /usr/sbin/semanage
Filename    : /usr/share/bash-completion/completions/semanage
```

Команда `dnf autoremove` не потребує параметрів. Dnf займається пошуком пакетів-кандидатів для видалення.

```bash
dnf autoremove
Last metadata expiration check: 0:24:40 ago on Wed 23 Mar 2022 06:16:47 PM CET.
Dependencies resolved.
Nothing to do.
Complete!
```

### Інші корисні параметри `dnf`

| Опція       | Опис                                      |
| ----------- | ----------------------------------------- |
| `repolist`  | Перелічує сховища, налаштовані в системі. |
| `grouplist` | Перелічує доступні колекції пакетів.      |
| `clean`     | Видаляє тимчасові файли.                  |

Команда `dnf repolist` містить список сховищ, налаштованих у системі. За замовчуванням він перераховує лише ввімкнені репозиторії, але його можна використовувати з такими параметрами:

| Параметр     | Опис                               |
| ------------ | ---------------------------------- |
| `--all`      | Перелічує всі сховища.             |
| `--enabled`  | За замовчуванням                   |
| `--disabled` | Перераховує лише вимкнені сховища. |

Приклад:

```bash
dnf repolist
repo id                                                  repo name
appstream                                                Rocky Linux 8 - AppStream
baseos                                                   Rocky Linux 8 - BaseOS
epel                                                     Extra Packages for Enterprise Linux 8 - aarch64
epel-modular                                             Extra Packages for Enterprise Linux Modular 8 - aarch64
extras                                                   Rocky Linux 8 - Extras
powertools                                               Rocky Linux 8 - PowerTools
rockyrpi                                                 Rocky Linux 8 - Rasperry Pi
```

І уривок команди з прапорцем `--all`.

```bash
dnf repolist --all...
repo id                                             repo name                                                                                       status
appstream                                           Rocky Linux 8 - AppStream                                                                       enabled
appstream-debug                                     Rocky Linux 8 - AppStream - Source                                                              disabled
appstream-source                                    Rocky Linux 8 - AppStream - Source                                                              disabled
baseos                                              Rocky Linux 8 - BaseOS                                                                          enabled
baseos-debug                                        Rocky Linux 8 - BaseOS - Source                                                                 disabled
baseos-source                                       Rocky Linux 8 - BaseOS - Source                                                                 disabled
devel                                               Rocky Linux 8 - Devel WARNING! FOR BUILDROOT AND KOJI USE                                       disabled
epel                                                Extra Packages for Enterprise Linux 8 - aarch64                                                 enabled
epel-debuginfo                                      Extra Packages for Enterprise Linux 8 - aarch64 - Debug                                         disabled
epel-modular                                        Extra Packages for Enterprise Linux Modular 8 - aarch64                                         enabled
epel-modular-debuginfo                              Extra Packages for Enterprise Linux Modular 8 - aarch64 - Debug                                 disabled
epel-modular-source                                 Extra Packages for Enterprise Linux Modular 8 - aarch64 - Source
...
```

Нижче наведено витяг зі списку вимкнених сховищ.

```bash
dnf repolist --disabled
repo id                                 repo name
appstream-debug                         Rocky Linux 8 - AppStream - Source
appstream-source                        Rocky Linux 8 - AppStream - Source
baseos-debug                            Rocky Linux 8 - BaseOS - Source
baseos-source                           Rocky Linux 8 - BaseOS - Source
devel                                   Rocky Linux 8 - Devel WARNING! FOR BUILDROOT AND KOJI USE
epel-debuginfo                          Extra Packages for Enterprise Linux 8 - aarch64 - Debug
epel-modular-debuginfo                  Extra Packages for Enterprise Linux Modular 8 - aarch64 - Debug
epel-modular-source                     Extra Packages for Enterprise Linux Modular 8 - aarch64 - Source
epel-source                             Extra Packages for Enterprise Linux 8 - aarch64 - Source
epel-testing                            Extra Packages for Enterprise Linux 8 - Testing - aarch64
...
```

Використання параметра `-v` розширює список великою кількістю додаткової інформації. Нижче ви можете побачити частину результату команди.

```bash
dnf repolist -v...
Repo-id            : powertools
Repo-name          : Rocky Linux 8 - PowerTools
Repo-revision      : 8.5
Repo-distro-tags      : [cpe:/o:rocky:rocky:8]:  ,  , 8, L, R, c, i, k, n, o, u, x, y
Repo-updated       : Wed 16 Mar 2022 10:07:49 PM CET
Repo-pkgs          : 1,650
Repo-available-pkgs: 1,107
Repo-size          : 6.4 G
Repo-mirrors       : https://mirrors.rockylinux.org/mirrorlist?arch=aarch64&repo=PowerTools-8
Repo-baseurl       : https://mirror2.sandyriver.net/pub/rocky/8.8/PowerTools/x86_64/os/ (30 more)
Repo-expire        : 172,800 second(s) (last: Tue 22 Mar 2022 05:49:24 PM CET)
Repo-filename      : /etc/yum.repos.d/Rocky-PowerTools.repo
...
```

!!! інформація з "Використання груп"

    Групи — це сукупність набору пакетів (ви можете розглядати їх як віртуальні пакунки), які логічно групують набір програм для досягнення мети (середовище робочого столу, сервер, засоби розробки тощо).

Команда `dnf grouplist` містить список усіх доступних груп.

```bash
dnf grouplist
Last metadata expiration check: 1:52:00 ago on Wed 23 Mar 2022 02:11:43 PM CET.
Available Environment Groups:
   Server with GUI
   Server
   Minimal Install
   KDE Plasma Workspaces
   Custom Operating System
Available Groups:
   Container Management
   .NET Core Development
   RPM Development Tools
   Development Tools
   Headless Management
   Legacy UNIX Compatibility
   Network Servers
   Scientific Support
   Security Tools
   Smart Card Support
   System Tools
   Fedora Packager
   Xfce
```

Команда `dnf groupinstall` дозволяє встановити одну з цих груп.

```bash
dnf groupinstall "Network Servers"
Last metadata expiration check: 2:33:26 ago on Wed 23 Mar 2022 02:11:43 PM CET.
Dependencies resolved.
================================================================================
 Package           Architecture     Version             Repository         Size
================================================================================
Installing Groups:
 Network Servers

Transaction Summary
================================================================================

Is this ok [y/N]:
```

Зауважте, що бажано брати назву групи в подвійні лапки, оскільки без команди вона виконуватиметься правильно, лише якщо назва групи не міститиме пробілів.

Отже, `dnf groupinstall Network Servers` створює таку помилку.

```bash
dnf groupinstall Network Servers
Last metadata expiration check: 3:05:45 ago on Wed 23 Mar 2022 02:11:43 PM CET.
Module or Group 'Network' is not available.
Module or Group 'Servers' is not available.
Error: Nothing to do.
```

Відповідною командою для видалення групи є `dnf groupremove "name group"`.

Команда `dnf clean` очищає всі кеші та тимчасові файли, створені `dnf`. Його можна використовувати з такими параметрами.

| Параметри      | Опис                                                                |
| -------------- | ------------------------------------------------------------------- |
| `all`          | Видаляє всі тимчасові файли, створені для активованих репозиторіїв. |
| `dbcache`      | Видаляє файли кешу для метаданих сховища.                           |
| `expire-cache` | Видаляє локальні файли cookie.                                      |
| `metadata`     | Видаляє всі метадані сховищ.                                        |
| `packages`     | Видаляє всі кешовані пакети.                                        |


### Як працює DNF

Менеджер DNF покладається на один або декілька конфігураційних файлів для націлювання на репозиторії, що містять пакети RPM.

Ці файли розташовані в `/etc/yum.repos.d/` і мають закінчуватися на `.repo`, щоб використовувати їх DNF.

Приклад:

```bash
/etc/yum.repos.d/Rocky-BaseOS.repo
```

Кожен файл `.repo` містить принаймні таку інформацію, по одній директиві на рядок.

Приклад:

```
[baseos] # Short name of the repository
name=Rocky Linux $releasever - BaseOS # Short name of the repository #Detailed name
mirrorlist=http://mirrors.rockylinux.org/mirrorlist?arch=$basearch&repo=BaseOS-$releasever # http address of a list or mirror
#baseurl=http://dl.rockylinux.org/$contentdir/$releasever/BaseOS/$basearch/os/ # http address for direct access
gpgcheck=1 # Repository requiring a signature
enabled=1 # Activated =1, or not activated =0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial # GPG public key path
```

За замовчуванням директива `enabled` відсутня, що означає, що репозиторій увімкнено. Щоб вимкнути репозиторій, необхідно вказати директиву `enabled=0`.

## Модулі DNF

Модулі були введені в Rocky Linux 8 за допомогою апстріму. Щоб використовувати модулі, репозиторій AppStream має існувати та бути ввімкненим.

!!! підказка "Плутанина пакетів"

    Створення потоків модулів у репозиторії AppStream викликало багато збентеження. Оскільки модулі упаковані в потік (див. наші приклади нижче), певний пакет відображатиметься в наших RPM, але якщо буде зроблена спроба встановити його без увімкнення модуля, нічого не станеться. Не забувайте переглядати модулі, якщо ви намагаєтеся встановити пакет, але він не може його знайти.

### Що таке модулі

Модулі надходять із сховища AppStream і містять як потоки, так і профілі. Їх можна описати так:

* **потоки модулів:** потік модулів можна розглядати як окреме сховище в сховищі AppStream, яке містить різні версії програми. Ці репозиторії модулів містять RPM програми, залежності та документацію для цього конкретного потоку. Прикладом потоку модулів у Rocky Linux 8 може бути `postgresql`. Якщо ви встановите `postgresql` за допомогою стандартного `sudo dnf install postgresql`, ви отримаєте версію 10. Однак, використовуючи модулі, замість цього можна встановити версії 9.6, 12 або 13.

* **профілі модуля:** Профіль модуля враховує сценарій використання потоку модуля під час встановлення пакета. Застосування профілю налаштовує RPM пакета, залежності та документацію з урахуванням використання модуля. Використовуючи той самий потік `postgresql` у нашому прикладі, ви можете застосувати профіль «сервер» або «клієнт». Очевидно, що вам не потрібні ті самі пакунки, що встановлюються у вашій системі, якщо ви просто збираєтеся використовувати `postgresql` як клієнт для доступу до сервера.

### Лістинг модулів

Ви можете отримати список усіх модулів, виконавши таку команду:

```
dnf module list
```

Це дасть вам довгий список доступних модулів і профілів, які можна використовувати для них. Справа в тому, що ви, напевно, вже знаєте, який пакет вас цікавить, тому, щоб дізнатися, чи є модулі для певного пакета, додайте назву пакета після «списку». Тут ми знову використаємо наш приклад пакета `postgresql`:

```
dnf module list postgresql
```

Це дасть вам результат, який виглядає так:

```
Rocky Linux 8 - AppStream
Name                       Stream                 Profiles                           Summary                                            
postgresql                 9.6                    client, server [d]                 PostgreSQL server and client module                
postgresql                 10 [d]                 client, server [d]                 PostgreSQL server and client module                
postgresql                 12                     client, server [d]                 PostgreSQL server and client module                
postgresql                 13                     client, server [d]                 PostgreSQL server and client module
```

Зверніть увагу на "[d]" у списку. Це означає, що це значення за замовчуванням. Він показує, що версія за замовчуванням — 10 і незалежно від того, яку версію ви виберете, якщо ви не вкажете профіль, то профіль сервера буде використовуватися профілем, оскільки він також є профілем за замовчуванням.

### Активація модулів

Використовуючи наш приклад пакета `postgresql`, припустімо, що ми хочемо ввімкнути версію 12. Для цього ви просто використовуєте наступне:

```
dnf module enable postgresql:12
```

Тут для команди enable потрібно вказати назву модуля, за якою слідують «:» і назву потоку.

Щоб переконатися, що ви ввімкнули потік модуля `postgresql` версії 12, знову скористайтеся командою списку, яка має показати наступний результат:

```
Rocky Linux 8 - AppStream
Name                       Stream                 Profiles                           Summary                                            
postgresql                 9.6                    client, server [d]                 PostgreSQL server and client module                
postgresql                 10 [d]                 client, server [d]                 PostgreSQL server and client module                
postgresql                 12 [e]                 client, server [d]                 PostgreSQL server and client module                
postgresql                 13                     client, server [d]                 PostgreSQL server and client module
```

Тут ми можемо побачити «[e]» для «ввімкнено» поруч із потоком 12, тож ми знаємо, що версію 12 увімкнено.

### Встановлення пакетів з потоку модуля

Тепер, коли наш потік модулів увімкнено, наступним кроком є встановлення `postgresql`, клієнтської програми для сервера postgresql. Цього можна досягти, виконавши таку команду:

```
dnf install postgresql
```

Що повинно дати вам такий результат:

```
========================================================================================================================================
 Package                    Architecture           Version                                              Repository                 Size
========================================================================================================================================
Installing group/module packages:
 postgresql                 x86_64                 12.12-1.module+el8.6.0+1049+f8fc4c36                 appstream                 1.5 M
Installing dependencies:
 libpq                      x86_64                 13.5-1.el8                                           appstream                 197 k

Transaction Summary
========================================================================================================================================
Install  2 Packages
Total download size: 1.7 M
Installed size: 6.1 M
Is this ok [y/N]:
```

Після схвалення, ввівши "y", ви встановили програму.

### Встановлення пакетів із профілів потоку модуля

Також можна безпосередньо встановлювати пакети, навіть не вмикаючи потік модулів! У цьому прикладі припустимо, що ми хочемо лише застосувати профіль клієнта до нашої інсталяції. Для цього ми просто вводимо цю команду:

```
dnf install postgresql:12/client
```

Що повинно дати вам такий результат:

```
========================================================================================================================================
 Package                    Architecture           Version                                              Repository                 Size
========================================================================================================================================
Installing group/module packages:
 postgresql                 x86_64                 12.12-1.module+el8.6.0+1049+f8fc4c36                 appstream                 1.5 M
Installing dependencies:
 libpq                      x86_64                 13.5-1.el8                                           appstream                 197 k
Installing module profiles:
 postgresql/client
Enabling module streams:
 postgresql                                        12

Transaction Summary
========================================================================================================================================
Install  2 Packages

Total download size: 1.7 M
Installed size: 6.1 M
Is this ok [y/N]:
```

Відповідь «y» на запит інсталює все, що вам потрібно для використання postgresql версії 12 як клієнта.

### Видалення та скидання модуля або перемикання (Switch-To)

Після встановлення ви можете вирішити, що з будь-якої причини вам потрібна інша версія потоку. Першим кроком є видалення пакетів. Знову використовуючи наш приклад пакета `postgresql`, ми б зробили це за допомогою:

```
dnf remove postgresql
```

Це відобразить результат, подібний до процедури встановлення вище, за винятком видалення пакета та всіх його залежностей. Щоб видалити `postgresql`, дайте відповідь «y» на підказку та натисніть enter.

Після завершення цього кроку ви можете надати команду скидання для модуля за допомогою:

```
dnf module reset postgresql
```

Що дасть вам такий результат:

```
Dependencies resolved.
========================================================================================================================================
 Package                         Architecture                   Version                           Repository                       Size
========================================================================================================================================
Disabling module profiles:
 postgresql/client                                                                                                                     
Resetting modules:
 postgresql                                                                                                                            

Transaction Summary
========================================================================================================================================

Is this ok [y/N]:
```

Відповідь «y» на запит скине `postgresql` назад до потоку за замовчуванням, а потік, який ми ввімкнули (12 у нашому прикладі), більше не ввімкнено:

```
Rocky Linux 8 - AppStream
Name                       Stream                 Profiles                           Summary                                            
postgresql                 9.6                    client, server [d]                 PostgreSQL server and client module                
postgresql                 10 [d]                 client, server [d]                 PostgreSQL server and client module                
postgresql                 12                     client, server [d]                 PostgreSQL server and client module                
postgresql                 13                     client, server [d]                 PostgreSQL server and client module
```

Тепер ви можете використовувати значення за замовчуванням.

Ви також можете використовувати підкоманду switch to, щоб переключатися з одного активного потоку на інший. Використання цього методу не лише перемикає на новий потік, але й встановлює необхідні пакети (повернення або оновлення) без окремого кроку. Щоб використати цей метод для ввімкнення потоку `postgresql` версії 13 і використання профілю «клієнта», ви повинні використати:

```
dnf module switch-to postgresql:13/client
```

### Вимкнути потік модуля

Бувають випадки, коли ви бажаєте вимкнути можливість інсталювати пакети з потоку модуля. У випадку нашого прикладу `postgresql` це може бути тому, що ви хочете використовувати репозиторій безпосередньо з [PostgreSQL](https://www.postgresql.org/download/linux/redhat/), щоб мати змогу використовувати новішу версію (на час написання цієї статті, версії 14 і 15 доступні з цього репозиторію). Вимкнення потоку модулів робить встановлення будь-якого з цих пакетів неможливим без попереднього їх повторного ввімкнення.

Щоб вимкнути потоки модулів для `postgresql`, просто виконайте:

```
dnf module disable postgresql
```

І якщо ви знову перерахуєте модулі `postgresql`, ви побачите наступне, де показано всі вимкнені версії модулів `postgresql`:

```
Rocky Linux 8 - AppStream
Name                       Stream                   Profiles                          Summary                                           
postgresql                 9.6 [x]                  client, server [d]                PostgreSQL server and client module               
postgresql                 10 [d][x]                client, server [d]                PostgreSQL server and client module               
postgresql                 12 [x]                   client, server [d]                PostgreSQL server and client module               
postgresql                 13 [x]                   client, server [d]                PostgreSQL server and client module
```

## Репозиторій EPEL

### Що таке EPEL і як він використовується?

**EPEL** (**E**extra **P**packages for **E**nterprise **L**inux) є відкритим -джерело та безкоштовне сховище на основі спільноти, яке підтримується [EPEL Fedora Special Interest Group](https://docs.fedoraproject.org/en-US/epel/), яке надає набір додаткових пакетів для RHEL (і CentOS, Rocky Linux та інших) із вихідних кодів Fedora.

Він надає пакети, які не входять до офіційних репозиторіїв RHEL. Вони не включені, оскільки вони не вважаються необхідними в корпоративному середовищі або виходять за рамки RHEL. Не можна забувати, що RHEL — це дистрибутив корпоративного класу, а настільні утиліти чи інше спеціалізоване програмне забезпечення можуть не бути пріоритетними для корпоративного проекту.

### Інсталяція

Інсталяцію необхідних файлів можна легко здійснити за допомогою пакета, наданого за замовчуванням від Rocky Linux.

Якщо ви використовуєте інтернет-проксі:

```bash
export http_proxy=http://172.16.1.10:8080
```

Тоді:

```bash
dnf install epel-release
```

Після встановлення ви можете перевірити правильність встановлення пакета за допомогою команди `dnf info`.

```bash
dnf info epel-release
Last metadata expiration check: 1:30:29 ago on Thu 24 Mar 2022 09:36:42 AM CET.
Installed Packages
Name         : epel-release
Version      : 8
Release      : 14.el8
Architecture : noarch
Size         : 32 k
Source       : epel-release-8-14.el8.src.rpm
Repository   : @System
From repo    : epel
Summary      : Extra Packages for Enterprise Linux repository configuration
URL          : http://download.fedoraproject.org/pub/epel
License      : GPLv2
Description  : This package contains the Extra Packages for Enterprise Linux
             : (EPEL) repository GPG key as well as configuration for yum.
```

Пакет, як ви можете бачити з опису пакета вище, не містить виконуваних файлів, бібліотек тощо, а лише файли конфігурації та ключі GPG для налаштування репозиторію.

Ще один спосіб перевірити правильність інсталяції — запитати базу даних rpm.

```bash
rpm -qa | grep epel
epel-release-8-14.el8.noarch
```

Тепер вам потрібно запустити оновлення, щоб дозволити `dnf` розпізнати репозиторій. Вам буде запропоновано прийняти ключі GPG репозиторіїв. Зрозуміло, що ви повинні відповісти YES, щоб ними скористатися.

```bash
dnf update
```

Після завершення оновлення ви можете перевірити, чи правильно налаштовано сховище за допомогою команди `dnf repolist`, яка тепер має перерахувати нові сховища.

```bash
dnf repolist
repo id            repo name
...
epel               Extra Packages for Enterprise Linux 8 - aarch64
epel-modular       Extra Packages for Enterprise Linux Modular 8 - aarch64...
```

Конфігураційні файли сховища знаходяться в `/etc/yum.repos.d/`.

```
ll /etc/yum.repos.d/ | grep epel
-rw-r--r--. 1 root root 1485 Jan 31 17:19 epel-modular.repo
-rw-r--r--. 1 root root 1422 Jan 31 17:19 epel.repo
-rw-r--r--. 1 root root 1584 Jan 31 17:19 epel-testing-modular.repo
-rw-r--r--. 1 root root 1521 Jan 31 17:19 epel-testing.repo
```

А нижче ми можемо побачити вміст файлу `epel.repo`.

```bash
[epel]
name=Extra Packages for Enterprise Linux $releasever - $basearch
# It is much more secure to use the metalink, but if you wish to use a local mirror
# place its address here.
#baseurl=https://download.example/pub/epel/$releasever/Everything/$basearch
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-$releasever&arch=$basearch&infra=$infra&content=$contentdir
enabled=1
gpgcheck=1
countme=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8

[epel-debuginfo]
name=Extra Packages for Enterprise Linux $releasever - $basearch - Debug
# It is much more secure to use the metalink, but if you wish to use a local mirror
# place its address here.
#baseurl=https://download.example/pub/epel/$releasever/Everything/$basearch/debug
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-debug-$releasever&arch=$basearch&infra=$infra&content=$contentdir
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8
gpgcheck=1

[epel-source]
name=Extra Packages for Enterprise Linux $releasever - $basearch - Source
# It is much more secure to use the metalink, but if you wish to use a local mirror
# place it's address here.
#baseurl=https://download.example/pub/epel/$releasever/Everything/source/tree/
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-source-$releasever&arch=$basearch&infra=$infra&content=$contentdir
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8
gpgcheck=1
```

### Використання EPEL

На цьому етапі, після налаштування, ми готові встановити пакети з EPEL. Для початку ми можемо переглянути список пакетів, доступних у сховищі, за допомогою команди:

```bash
dnf --disablerepo="*" --enablerepo="epel" list available
```

Фрагмент команди

```bash
dnf --disablerepo="*" --enablerepo="epel" list available | less
Last metadata expiration check: 1:58:22 ago on Fri 25 Mar 2022 09:23:29 AM CET.
Available Packages
3proxy.aarch64                                                    0.8.13-1.el8                                    epel
AMF-devel.noarch                                                  1.4.23-2.el8                                    epel
AMF-samples.noarch                                                1.4.23-2.el8                                    epel
AusweisApp2.aarch64                                               1.22.3-1.el8                                    epel
AusweisApp2-data.noarch                                           1.22.3-1.el8                                    epel
AusweisApp2-doc.noarch                                            1.22.3-1.el8                                    epel
BackupPC.aarch64                                                  4.4.0-1.el8                                     epel
BackupPC-XS.aarch64                                               0.62-1.el8                                      epel
BibTool.aarch64                                                   2.68-1.el8                                      epel
CCfits.aarch64                                                    2.5-14.el8                                      epel
CCfits-devel.aarch64                                              2.5-14.el8                                      epel
...
```

З команди ми бачимо, що для встановлення з EPEL ми повинні змусити **dnf** надсилати запит запитуваному репозиторію з параметрами `--disablerepo` та `--enablerepo</1 >, це тому, що інакше збіг, знайдений в інших додаткових репозиторіях (RPM Fusion, REMI, ERLepo тощо), може бути новішим і, отже, матиме пріоритет. Ці параметри не потрібні, якщо ви встановили EPEL лише як додатковий репозиторій, оскільки пакунки в репозиторії ніколи не будуть доступні в офіційних. Принаймні в одній і тій самій версії!</p>

<p spaces-before="0">!!! увага «Підтримати розгляд»</p>

<pre><code>Одним з аспектів підтримки (оновлення, виправлення помилок, патчі безпеки), який слід враховувати, є те, що пакунки EPEL не мають офіційної підтримки від RHEL, і технічно їх життя може тривати протягом розробки Fedora (шість місяців), а потім зникати. Це віддалена можливість, але її слід розглянути.
`</pre>

Отже, щоб встановити пакет із сховищ EPEL, ви повинні використати:

```bash
dnf --disablerepo="*" --enablerepo="epel" install nmon
Last metadata expiration check: 2:01:36 ago on Fri 25 Mar 2022 04:28:04 PM CET.
Dependencies resolved.
==============================================================================================================================================================
 Package                            Architecture                          Version                                    Repository                          Size
==============================================================================================================================================================
Installing:
 nmon                               aarch64                               16m-1.el8                                  epel                                71 k

Transaction Summary
==============================================================================================================================================================
Install  1 Package

Total download size: 71 k
Installed size: 214 k
Is this ok [y/N]:
```

### Висновок

EPEL не є офіційним репозиторієм для RHEL, але він може бути корисним для адміністраторів і розробників, які працюють з RHEL або похідними і потребують деяких утиліт, підготовлених для RHEL з джерела, в якому вони можуть бути впевнені.

## Плагіни DNF

Пакет `dnf-plugins-core` додає модулі до `dnf`, які будуть корисні для керування вашими репозиторіями.

!!! ВАЖЛИВО

    Дивіться більше інформації тут: https://dnf-plugins-core.readthedocs.io/en/latest/index.html

Встановлення пакету у вашій системі:

```
dnf install dnf-plugins-core
```

Не всі плагіни будуть представлені тут, але ви можете звернутися до документації пакета, щоб отримати повний список плагінів і детальну інформацію.

### Плагін `config-manager`

Керування параметрами DNF, додавання сховища або їх вимикання.

Приклади:

* Завантажте файл `.repo` та використовуйте його:

```
dnf config-manager --add-repo https://packages.centreon.com/ui/native/rpm-standard/23.04/el8/centreon-23.04.repo
```

* Ви також можете встановити Url-адресу як базову Url-адресу для репо:

```
dnf config-manager --add-repo https://repo.rocky.lan/repo
```

* Увімкнути або вимкнути одне або кілька сховищ:

```
dnf config-manager --set-enabled epel centreon
dnf config-manager --set-disabled epel centreon
```

* Додати проксі до вашого конфігураційного файлу:

```
dnf config-manager --save --setopt=*.proxy=http://proxy.rocky.lan:3128/
```

### Плагін `copr`

`copr` — це автоматична підробка rpm, яка надає репо зі вбудованими пакетами.

* Активація репозиторію copr:

```
copr enable xxxx
```

### Плагін `download`

Завантаження пакету rpm замість його встановлення:

```
dnf download ansible
```

Якщо ви просто хочете отримати Url-адресу віддаленого розташування пакета:

```
dnf download --url ansible
```

Або якщо ви хочете також завантажити залежності:

```
dnf download --resolv --alldeps ansible
```

### Плагін `needs-restarting`

Після запуску `dnf update` запущені процеси продовжуватимуть працювати, але зі старими двійковими файлами. Щоб врахувати зміни коду та особливо оновлення безпеки, їх потрібно перезапустити.

Плагін `needs-restarting` дозволить вам виявити процеси, які знаходяться в цьому випадку.

```
dnf needs-restarting [-u] [-r] [-s]
```

| Опції   | Опис                                                          |
| ------- | ------------------------------------------------------------- |
| `-u`    | Розглядає лише процеси, що належать запущеному користувачеві. |
| `-r`    | щоб перевірити, чи може знадобитися перезавантаження.         |
| `-s`    | щоб перевірити, чи потрібно перезапустити служби.             |
| `-s -r` | зробити обидва за один захід.                                 |

### Плагін `versionlock`

Іноді корисно захистити пакети від усіх оновлень або виключити певні версії пакета (наприклад, через відомі проблеми). Для цього дуже допоможе плагін versionlock.

Потрібно встановити додатковий пакет:

```
dnf install python3-dnf-plugin-versionlock
```

Приклади:

* Заблокувати версію ansible:

```
dnf versionlock add ansible
Adding versionlock on: ansible-0:6.3.0-2.el9.*
```

* Список заблокованих пакетів:

```
dnf versionlock list
ansible-0:6.3.0-2.el9.*
```
