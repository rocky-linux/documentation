---
title: MediaWiki
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 10.0
tags:
  - cms
---

## Вступ

[MediaWiki](https://www.mediawiki.org/wiki/MediaWiki) — це популярний програмний движок з відкритим кодом для вікі-сайтів, який використовується, зокрема, на таких сайтах, як Вікіпедія, Fandom та wikiHow.

## Передумови та припущення

Нижче наведено мінімальні вимоги для використання цієї процедури:

- Можливість запускати команди від імені користувача root або використовувати `sudo` для підвищення привілеїв
- Знайомство з редактором командного рядка. Автор використовує `vi` або `vim` тут, але замініть у вашому улюбленому редакторі

## Встановлення Apache

Apache — це веб-сервер, який ви будете використовувати. Встановіть за допомогою:

```bash
dnf -y install httpd
```

Далі відкрийте відповідні порти брандмауера:

```bash
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload
```

## Встановлення PHP

!!! note

    Якщо ви використовуєте Rocky Linux 8.x або 9.x, замініть «8» або «9» поруч із версією в рядку інсталяції пакета Remi.

Щоб встановити PHP, спочатку потрібно встановити EPEL (додаткові пакети для Enterprise Linux):

```bash
dnf -y install epel-release && dnf -y update
```

Вам також знадобиться репозиторій Remi. Встановіть його за допомогою:

```bash
dnf install https://rpms.remirepo.net/enterprise/remi-release-10.rpm
```

Потім встановіть PHP і необхідні модулі:

```bash
dnf install -y dnf install php84-php-fpm php84-php-intl php84-php-mbstring php84-php-apcu php84-php-curl php84-php-mysql php84-php-xml
```

Увімкніть PHP за допомогою:

```bash
systemctl enable --now php84-php-fpm.service
```

## Встановлення MariaDB

Для бази даних вам потрібна MariaDB. Встановіть за допомогою:

```bash
dnf install mariadb-server
```

Далі увімкніть службу `systemd` і запустіть майстер налаштування:

```bash
systemctl enable --now mariadb
mysql_secure_installation
```

Коли буде запитано пароль root, натисніть ++enter++ :

```bash
Введіть поточний пароль для root (++enter++ для відсутності пароля):
```

Відповідь ++«n»++ на аутентифікацію `unix_socket`:

```bash
Перейти до автентифікації unix_socket [Y/n] n
```

Відповідайте ++«Y»++ на зміну пароля root і введіть необхідний пароль root:

```bash
Change the root password? [Y/n] Y
New password: 
Re-enter new password: 
```

Видаліть анонімних користувачів і забороніть віддалений вхід під обліковим записом `root`:

```bash
Remove anonymous users? [Y/n] Y
...
Disallow root login remotely? [Y/n] Y
```

Видаліть доступ до тестової бази даних і перезавантажте таблиці привілеїв:

```bash
Remove test database and access to it? [Y/n] Y
...
Reload privilege tables now? [Y/n] Y
```

Увійдіть в MariaDB за допомогою:

```bash
mysql -u root -p
```

Введіть пароль root, який ви створили раніше.

У консолі MariaDB створіть базу даних для MediaWiki:

```bash
MariaDB [(none)]> create database mediawiki;
```

Далі створіть користувача MediaWiki:

```bash
MariaDB [(none)]> create user 'mediawiki'@'localhost' identified by 'nchauhan11';
```

Надати привілеї в базі даних MediaWiki:

```bash
grant all privileges on mediawiki.* to 'mediawiki'@'localhost';
```

Нарешті, скиньте привілеї за допомогою:

```bash
MariaDB [(none)]> flush privileges;
```

## Встановлення MediaWiki

Перейдіть до каталогу `/var/www/` і завантажте MediaWiki:

```bash
cd /var/www/
wget https://releases.wikimedia.org/mediawiki/1.44/mediawiki-1.44.0.zip
```

Розпакуйте та перемістіть MediaWiki:

```bash
unzip mediawiki-1.44.0.zip
mv mediawiki-1.44.0/* html/
```

Встановіть правильні дозволи SELinux:

```bash
chown -R apache:apache /var/www/html
semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/html(/.*)?"
restorecon -Rv /var/www/html
```

Увімкнути Apache:

```bash
systemctl enable --now httpd
```

Далі відкрийте браузер і перейдіть за адресою `http://your_ip` (замість `your_ip` вкажіть свою IP-адресу):

![MediaWiki Initial Setup](../images/mediawiki_1.png)

Виберіть мову та натисніть **Continue**:

![MediaWiki Language Page](../images/mediawiki_2.png)

Перевірте, чи правильна конфігурація PHP, прокрутіть вниз і натисніть **Continue**:

![MediaWiki PHP Checks](../images/mediawiki_3.png)

Тепер введіть інформацію про базу даних наступним чином:

- **Хост бази даних**: `localhost`

- **Назва бази даних (без дефісів)**: `mediawiki` (або база даних, створена на кроці **MariaDB**)

- **Ім'я користувача бази даних:**: `mediawiki` (або користувач, створений на кроці **MariaDB**)

- **Пароль бази даних**: пароль, який ви створили на кроці **MariaDB**

![MediaWiki Database Information](../images/mediawiki_4.png)

Натисніть **Continue**:

![MediaWiki Database Access Settings](../images/mediawiki_5.png)

На сторінці **Встановлення версії MediaWiki** введіть наступне:

- **Ім'я хоста URL**: URL, який ви хочете

- **Назва вікі**: Назва вікі, яку ви хочете

- **Обліковий запис адміністратора**/**Ваше ім'я користувача**: Ім'я користувача адміністратора, яке ви хочете використовувати

- **Обліковий запис адміністратора**/**Пароль (ще раз)**: пароль адміністратора, який ви хочете використовувати

- **Обліковий запис адміністратора**/**Адреса електронної пошти**: Адреса електронної пошти адміністратора

За бажанням ви також можете вибрати **Запитайте мене більше питань**, щоб налаштувати Wiki. Для простоти виберіть **Мені вже нудно, просто встановіть вікі** і натисніть **Продовжити**:

![MediaWiki Wiki Information](../images/mediawiki_6.png)

Натисніть **Продовжити**, щоб встановити Wiki:

![MediaWiki Install Step Part 1](../images/mediawiki_7.png)

MediaWiki налаштує бази даних. Коли процес завершиться, натисніть **Продовжити**:

![MediaWiki Install Step Part 2](../images/mediawiki_8.png)

Ваш браузер завантажить файл `LocalSettings.php`. Ви завантажите це на свій сервер за допомогою `sftp`.

Як приклад, автор використає свій ноутбук Fedora 42 для завантаження цього файлу. Для цього:

```bash
sftp root@your_ip
(Enter password)
cd /var/www/html
put LocalSettings.php 
```

![MediaWiki LocalSettings.php Step](../images/mediawiki_9.png)

Нарешті, натисніть **увійдіть у свою вікі**:

![Fresh MediaWiki Wiki](../images/mediawiki_10.png)

Тепер у вас є свіжа інсталяція MediaWiki.

## Висновок

Хоча MediaWiki найбільш відома як платформа для Вікіпедії, вона також є корисною як система управління контентом, де користувачі мають можливість редагувати сторінки. MediaWiki — це хороша альтернатива SharePoint від Microsoft з відкритим кодом.
