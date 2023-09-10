---
title: Apache з "mod_ssl"
author: Garthus
contributors: Steven Spencer, David Hensley
update: 20 січня 2022 р
---

# 'mod_ssl' на Rocky Linux у середовищі веб-сервера httpd Apache

Веб-сервер Apache використовується багато років; 'mod_ssl' забезпечує більшу безпеку для веб-сервера та може бути встановлено майже на будь-якій версії Linux, включаючи Rocky Linux. Встановлення 'mod_ssl' буде частиною створення Lamp-Server для Rocky Linux.

Ця процедура призначена для того, щоб почати роботу з Rocky Linux за допомогою 'mod_ssl' у середовищі веб-сервера Apache.

## Передумови

* Робоча станція або сервер, бажано з уже встановленим Rocky Linux.
* Ви повинні бути в кореневому середовищі або ввести `sudo` перед усіма введеними командами.

## Встановлення Rocky Linux Minimal

Під час встановлення Rocky Linux ми використовували наступні набори пакетів:

* Minimal
* Standard

## Запуск оновлення системи

Спочатку запустіть команду системного оновлення, щоб дозволити серверу перебудувати кеш сховища для розпізнавання доступних пакетів.

`dnf update`

## Увімкнення репозиторіїв

Усі необхідні репозиторії мають бути на місці зі звичайним встановленням сервера Rocky Linux.

## Перевірка доступних репозиторіїв

Щоб бути впевненим, перевірте свій список сховища за допомогою:

`dnf repolist`

Ви повинні отримати наступне, що показує всі ввімкнені сховища:

```
appstream                                                        Rocky Linux 8 - AppStream
baseos                                                           Rocky Linux 8 - BaseOS
extras                                                           Rocky Linux 8 - Extras
powertools                                                       Rocky Linux 8 - PowerTools
```

## Встановлення пакетів

Щоб встановити 'mod_ssl', запустіть:

`dnf install mod_ssl`

Щоб увімкнути модуль mod_ssl, виконайте:

`apachectl restart httpd` `apachectl -M | grep ssl`

Ви повинні побачити такий результат:

  `ssl_module (shared)`

## Відкриття порту TCP 443

Щоб дозволити вхідний трафік через HTTPS, виконайте:

```
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --reload
```

На цьому етапі ви повинні мати доступ до веб-сервера Apache через HTTPS. Введіть `https://your-server-ip` або `https://your-server-hostname`, щоб підтвердити конфігурацію mod_ssl.

## Створення SSL-сертифікату

Щоб створити новий самопідписаний сертифікат для Host rocky8 із терміном дії 365 днів, виконайте наступне:

`openssl req -newkey rsa:2048 -nodes -keyout /etc/pki/tls/private/httpd.key -x509 -days 365 -out /etc/pki/tls/certs/httpd.crt`

Ви побачите такий результат:

```
Generating a RSA private key
................+++++
..........+++++
writing new private key to '/etc/pki/tls/private/httpd.key'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:AU
State or Province Name (full name) []:
Locality Name (eg, city) [Default City]:
Organization Name (eg, company) [Default Company Ltd]:LinuxConfig.org
Organizational Unit Name (eg, section) []:
Common Name (eg, your name or your server's hostname) []:rocky8
Email Address []:
```
Після завершення виконання цієї команди буде створено наступні два файли SSL, запустіть:

```
ls -l /etc/pki/tls/private/httpd.key /etc/pki/tls/certs/httpd.crt

-rw-r--r--. 1 root root 1269 Jan 29 16:05 /etc/pki/tls/certs/httpd.crt
-rw-------. 1 root root 1704 Jan 29 16:05 /etc/pki/tls/private/httpd.key
```

## Налаштування веб-сервер Apache із новими сертифікатами SSL

Щоб включити щойно створений сертифікат SSL до конфігурації веб-сервера Apache, відкрийте файл ssl.conf, виконавши:

`nano /etc/httpd/conf.d/ssl.conf`

Потім змініть наступні рядки:

З:
```
SSLCertificateFile /etc/pki/tls/certs/localhost.crt
SSLCertificateKeyFile /etc/pki/tls/private/localhost.key
```
На:
```
SSLCertificateFile /etc/pki/tls/certs/httpd.crt
SSLCertificateKeyFile /etc/pki/tls/private/httpd.key
```

Потім перезавантажте веб-сервер Apache, виконавши:

`systemctl reload httpd`

## Перевірка конфігурації 'mod_ssl'

У веб-браузері введіть наступне:

`https://your-server-ip` або `https://your-server-hostname`

## Щоб перенаправити весь HTTP-трафік на HTTPS

Створіть новий файл, виконавши:

`nano /etc/httpd/conf.d/redirect_http.conf`

Вставте наведений нижче вміст і збережіть файл, замінивши «ім’я хоста-вашого-сервера» на ім’я хосту.

```
<VirtualHost _default_:80>

        Servername rocky8
        Redirect permanent / https://your-server-hostname/

</VirtualHost/>
```

Застосуйте зміни під час перезавантаження служби Apache, виконавши:

`systemctl reload httpd`

Тепер веб-сервер Apache буде налаштовано на перенаправлення будь-якого вхідного трафіку з `http://ім’я-хоста вашого-сервера` на URL-адресу `https://ім’я-хоста-вашого-сервера`.

## Останні кроки

Ми побачили, як встановити та налаштувати 'mod_ssl'. І створіть новий сертифікат SSL для запуску веб-сервера під послугою HTTPS.

## Висновок

Цей підручник буде частиною підручника, що розповідає про встановлення сервера LAMP (Linux, веб-сервер Apache, сервер бази даних Maria та мова сценаріїв PHP) на Rocky Linux версії 8.x. Згодом ми додамо зображення, щоб краще зрозуміти встановлення.
