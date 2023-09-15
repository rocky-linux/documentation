---
title: Nextcloud на Podman
author: Ananda Kammampati
contributors: Ezequiel Bruni, Steven Spencer, Ganna Zhyrnova
tested_with: 8.5
tags:
  - podman
  - контейнери
  - nextcloud
---

# Запуск Nextcloud як контейнера Podman на Rocky Linux

## Вступ

У цьому документі пояснюються всі кроки, необхідні для створення та запуску примірника [Nextcloud](https://nextcloud.com) як контейнера Podman у Rocky Linux. Більше того, увесь цей посібник було протестовано на Raspberry Pi, тому він має бути сумісний із кожною архітектурою процесора, яку підтримує Rocky.

Процедура розбита на кілька кроків, кожен з яких має власні сценарії оболонки для автоматизації:

1. Встановлення пакетів `podman` і `buildah` для керування та створення наших контейнерів
2. Створення базового зображення, яке буде перепрофільовано для всіх контейнерів, які нам знадобляться
3. Створення образу контейнера `db-tools` із необхідними сценаріями оболонки для створення та запуску бази даних MariaDB
4. Створення та запуск MariaDB як контейнера Podman
5. Створення та запуск Nextcloud як контейнера Podman, використовуючи контейнер MariaDB Podman як серверну частину

Ви можете запустити більшість команд у посібнику вручну, але налаштування кількох сценаріїв bash значно полегшить ваше життя, особливо якщо ви хочете повторити ці кроки з іншими налаштуваннями, змінними чи назвами контейнерів.

!!! Note "Примітка для початківців:"

    Podman — це інструмент для керування контейнерами, зокрема контейнерами OCI (Open Containers Initiative). Його розроблено, щоб бути майже сумісним із Docker, оскільки більшість, якщо не всі, однакові команди працюватимуть для обох інструментів. Якщо «Docker» нічого не означає для вас або навіть якщо вам просто цікаво, ви можете прочитати більше про Podman і про те, як він працює на [власному веб-сайті Podman] (https://podman.io).
    
    `buildah` — це інструмент, який створює зображення контейнерів Podman на основі "DockerFiles".
    
    Цей посібник був розроблений як вправа, щоб допомогти людям ознайомитися з роботою контейнерів Podman загалом і зокрема на Rocky Linux.

## Передумови та припущення

Ось усе, що вам знадобиться або потрібно знати, щоб цей посібник працював:

* Знайомство з командним рядком, сценаріями bash та редагуванням конфігураційних файлів Linux.
* Доступ SSH при роботі на віддаленій машині.
* Текстовий редактор на основі командного рядка на ваш вибір. Для цього посібника ми будемо використовувати `vi`.
* Підключена до Інтернету машина Rocky Linux (Raspberry Pi чудово працюватиме).
* Багато з цих команд потрібно запускати від імені користувача root, тому на машині вам знадобиться користувач із підтримкою root або sudo.
* Знайомство з веб-серверами та MariaDB точно допоможе.
* Знайомство з контейнерами та, можливо, Docker було б *безсумнівним* плюсом, але це не обов’язково.

## Крок 01. Встановіть `podman` і `buildah`

По-перше, переконайтеся, що ваша система оновлена:

```bash
dnf update
```

Тоді ви захочете встановити репозиторій `epel-release` для всіх додаткових пакунків, які ми використовуватимемо.

```bash
dnf -y install epel-release 
```

Коли це буде зроблено, ви можете знову оновити (що інколи допомагає) або просто продовжити та встановити потрібні пакети:

```bash
dnf -y install podman buildah
```

Після їх встановлення запустіть `podman --version` і `buildah --version`, щоб переконатися, що все працює правильно.

Щоб отримати доступ до реєстру Red Hat для завантаження зображень контейнерів, потрібно виконати:

```bash
vi /etc/containers/registries.conf
```

Знайдіть розділ, схожий на те, що ви бачите нижче. Якщо він закоментований, розкоментуйте його.

```
[registries.insecure]
registries = ['registry.access.redhat.com', 'registry.redhat.io', 'docker.io'] 
insecure = true
```

## Крок 02: Створіть `базове` зображення контейнера

У цьому посібнику ми працюємо як користувач root, але ви можете робити це в будь-якому домашньому каталозі. Перейдіть до кореневого каталогу, якщо ви там ще не перебуваєте:

```bash
cd /root
```

Тепер створіть усі каталоги, які вам знадобляться для різних збірок контейнерів:

```bash
mkdir base db-tools mariadb nextcloud
```

Тепер змініть свій робочий каталог на папку для базового зображення:

```bash
cd /root/base
```

І створіть файл під назвою DockerFile. Так, Podman теж ними користується.

```bash
vi Dockerfile
```

Скопіюйте та вставте наступний текст у свій новий DockerFile.

```
FROM rockylinux/rockylinux:latest
ENV container docker
RUN yum -y install epel-release ; yum -y update
RUN dnf module enable -y php:7.4
RUN dnf install -y php
RUN yum install -y bzip2 unzip lsof wget traceroute nmap tcpdump bridge-utils ; yum -y update
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]
```

Збережіть і закрийте попередній файл і створіть новий файл сценарію bash:

```bash
vi build.sh
```

Потім вставте цей вміст:

```
#!/bin/bash
clear
buildah rmi `buildah images -q base` ;
buildah bud --no-cache -t base . ;
buildah images -a
```

Тепер зробіть свій скрипт збірки виконуваним за допомогою:

```bash
chmod +x build.sh
```

І запустіть його:

```bash
./build.sh
```

Зачекайте, поки це буде зроблено, і переходьте до наступного кроку.

## Крок 03: Створіть зображення контейнера `db-tools`

Для цілей цього посібника ми зробимо налаштування бази даних максимально простими. Ви захочете відстежувати наступне та змінювати їх за потреби:

* Ім'я бази даних: ncdb
* Користувач бази даних: nc-user
* Перехід бази даних: nc-pass
* IP-адреса вашого сервера (ми будемо використовувати приклад IP-адреси нижче)

Спочатку перейдіть до папки, де ви будете створювати образ db-tools:

```bash
cd /root/db-tools
```

Тепер налаштуйте кілька сценаріїв bash, які використовуватимуться всередині образу контейнера Podman. Спочатку створіть сценарій, який автоматично створить вашу базу даних для вас:

```bash
vi db-create.sh
```

Тепер скопіюйте та вставте наступний код у цей файл за допомогою вашого улюбленого текстового редактора:

```
#!/bin/bash
mysql -h 10.1.1.160 -u root -p rockylinux << eof
create database ncdb;
grant all on ncdb.* to 'nc-user'@'10.1.1.160' identified by 'nc-pass';
flush privileges;
eof
```

Збережіть і закрийте, а потім повторіть кроки зі сценарієм для видалення баз даних за потреби:

```bash
vi db-drop.sh
```

Скопіюйте та вставте цей код у новий файл:

```
#!/bin/bash
mysql -h 10.1.1.160 -u root -p rockylinux << eof
drop database ncdb;
flush privileges;
eof
```

Нарешті, давайте налаштуємо DockerFile для образу `db-tools`:

```bash
vi Dockerfile
```

Копіювати і вставити:

```
FROM localhost/base
RUN yum -y install mysql
WORKDIR /root
COPY db-drop.sh db-drop.sh
COPY db-create.sh db-create.sh
```

І останнє, але не менш важливе, створіть сценарій bash для створення вашого зображення за командою:

```bash
vi build.sh
```

Код, який вам потрібен:

```
#!/bin/bash
clear
buildah rmi `buildah images -q db-tools` ;
buildah bud --no-cache -t db-tools . ;
buildah images -a
```

Збережіть і закрийте, а потім зробіть файл виконуваним:

```bash
chmod +x build.sh
```

І запустіть його:

```bash
./build.sh
```

## Крок 04: Створіть образ контейнера MariaDB

Ви розумієте процес, чи не так? Настав час створити справжній контейнер бази даних. Змініть робочий каталог на `/root/mariadb`:

```bash
cd /root/mariadb
```

Створіть сценарій для (пере)складання контейнера, коли забажаєте:

```bash
vi db-init.sh
```

А ось код, який вам знадобиться:

!!! warning "Важливо"

    Для цілей цього посібника наступний сценарій видалить усі томи Podman. Якщо у вас є інші програми, що працюють із власними томами, змініть/закоментуйте рядок «podman volume rm --all»;

```
#!/bin/bash
clear
echo " "
echo "Deleting existing volumes if any...."
podman volume rm --all ;
echo " "
echo "Starting mariadb container....."
podman run --name mariadb --label mariadb -d --net host -e MYSQL_ROOT_PASSWORD=rockylinux -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v mariadb-data:/var/lib/mysql/data:Z mariadb ;

echo " "
echo "Initializing mariadb (takes 2 minutes)....."
sleep 120 ;

echo " "
echo "Creating ncdb Database for nextcloud ....."
podman run --rm --net host db-tools /root/db-create.sh ;

echo " "
echo "Listing podman volumes...."
podman volume ls
```

Тут ви можете створити сценарій для скидання бази даних у будь-який час:

```bash
vi db-reset.sh
```

А ось код:

```
#!/bin/bash
clear
echo " "
echo "Deleting ncdb Database for nextcloud ....."
podman run --rm --net host db-tools /root/db-drop.sh ;

echo " "
echo "Creating ncdb Database for nextcloud ....."
podman run --rm --net host db-tools /root/db-create.sh ;
```

І нарешті, ось ваш сценарій збірки, який об’єднає весь контейнер mariadb:

```bash
vi build.sh
```

З його кодом:

```
#!/bin/bash
clear
buildah rmi `buildah images -q mariadb` ;
buildah bud --no-cache -t mariadb . ;
buildah images -a
```

Тепер просто створіть свій DockferFile (`vi Dockerfile`) і вставте такий один рядок:

```
FROM arm64v8/mariadb
```

Тепер зробіть свій скрипт збірки виконуваним і запустіть його:

```bash
chmod +x *.sh

./build.sh
```

## Крок 05: Створіть і запустіть контейнер Nextcloud

Ми на останньому етапі, і процес майже повторюється. Перейдіть до каталогу зображень Nextcloud:

```bash
cd /root/nextcloud
```

Цього разу спочатку налаштуйте DockerFile для різноманітності:

```bash
vi Dockerfile
```

!!! note "Примітка"

    Цей наступний біт передбачає архітектуру ARM (для Raspberry Pi), тому, якщо ви використовуєте іншу архітектуру, не забудьте змінити це.

І вставте цей фрагмент:

```
FROM arm64v8/nextcloud
```

Тепер створіть свій сценарій збірки:

```bash
vi build.sh
```

І вставте цей код:

```
#!/bin/bash
clear
buildah rmi `buildah images -q nextcloud` ;
buildah bud --no-cache -t nextcloud . ;
buildah images -a
```

Тепер ми збираємося створити купу локальних папок на хост-сервері (*не* в жодному контейнері Podman), щоб ми могли перебудувати наші контейнери та бази даних, не боячись втратити всі наші файли:

```bash
mkdir -p /usr/local/nc/nextcloud /usr/local/nc/apps /usr/local/nc/config /usr/local/nc/data
```

Нарешті, ми збираємося створити сценарій, який побудує для нас контейнер Nextcloud:

```bash
vi run.sh
```

І ось увесь необхідний для цього код. Переконайтеся, що ви змінили IP-адресу `MYSQL_HOST` на контейнер докерів, у якому запущено ваш екземпляр MariaDB.

```
#!/bin/bash
clear
echo " "
echo "Starting nextloud container....."
podman run --name nextcloud --net host --privileged -d -p 80:80 \
-e MYSQL_HOST=10.1.1.160 \
-e MYSQL_DATABASE=ncdb \
-e MYSQL_USER=nc-user \
-e MYSQL_PASSWORD=nc-pass \
-e NEXTCLOUD_ADMIN_USER=admin \
-e NEXTCLOUD_ADMIN_PASSWORD=rockylinux \
-e NEXTCLOUD_DATA_DIR=/var/www/html/data \
-e NEXTCLOUD_TRUSTED_DOMAINS=10.1.1.160 \
-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
-v /usr/local/nc/nextcloud:/var/www/html \
-v /usr/local/nc/apps:/var/www/html/custom_apps \
-v /usr/local/nc/config:/var/www/html/config \
-v /usr/local/nc/data:/var/www/html/data \
nextcloud ;
```

Збережіть і закрийте це, зробіть усі свої сценарії виконуваними, а потім спочатку запустіть сценарій створення зображення:

```bash
chmod +x *.sh

./build.sh
```

Щоб переконатися, що всі ваші зображення створено правильно, запустіть `podman images`. Ви повинні побачити список, який виглядає так:

```
REPOSITORY                      TAG    IMAGE ID     CREATED      SIZE
localhost/db-tools              latest 8f7ccb04ecab 6 days ago   557 MB
localhost/base                  latest 03ae68ad2271 6 days ago   465 MB
docker.io/arm64v8/mariadb       latest 89a126188478 11 days ago  405 MB
docker.io/arm64v8/nextcloud     latest 579a44c1dc98 3 weeks ago  945 MB
```

Якщо все виглядає правильно, запустіть останній сценарій, щоб запустити Nextcloud:

```bash
./run.sh
```

Коли ви запускаєте `podman ps -a`, ви повинні побачити список запущених контейнерів, який виглядає так:

```
CONTAINER ID IMAGE                              COMMAND              CREATED        STATUS            PORTS    NAMES
9518756a259a docker.io/arm64v8/mariadb:latest   mariadbd             3 minutes  ago Up 3 minutes ago           mariadb
32534e5a5890 docker.io/arm64v8/nextcloud:latest apache2-foregroun... 12 seconds ago Up 12 seconds ago          nextcloud
```

Звідти ви зможете вказати свій браузер на IP-адресу вашого сервера. Якщо ви дотримуєтесь і маєте ту саму IP-адресу, що й у нашому прикладі, ви можете замінити її тут (наприклад, http://your-server-ip) і побачити, як Nextcloud працює.

## Висновок

Очевидно, що цей посібник потрібно було б дещо змінити на робочому сервері, особливо якщо екземпляр Nextcloud призначений для загального доступу. Тим не менш, це повинно дати вам основне уявлення про те, як працює Podman, і як ви можете налаштувати його за допомогою сценаріїв і кількох базових зображень, щоб полегшити відновлення.
