---
title: Apache з "mod_ssl"
author: Garthus
contributors: Steven Spencer, David Hensley
update: 20 січня 2022 р
---

# `mod_ssl` на Rocky Linux у середовищі веб-сервера Apache

Веб-сервер Apache існує вже багато років. `mod_ssl` забезпечує більшу безпеку для веб-сервера та його можна встановити майже на будь-якій версії Linux.

Ця процедура допоможе вам почати працювати з Rocky Linux і `mod_ssl` у середовищі веб-сервера Apache.

## Передумови

* Робоча станція або сервер, бажано з уже встановленим Rocky Linux.
* Можливість запускати команди як *root* або `sudo` для підвищення привілеїв.

## Встановлення Rocky Linux Minimal

Під час встановлення Rocky Linux ми використовували наступні набори пакетів:

* Minimal
* Standard

## Запуск оновлення системи

Спочатку запустіть команду системного оновлення, щоб дозволити серверу перебудувати кеш сховища для розпізнавання доступних пакетів.

`dnf update`

## Увімкнення репозиторіїв

Усі необхідні репозиторії будуть на місці зі звичайним встановленням сервера Rocky Linux.

## Перевірка доступних репозиторіїв

Щоб бути впевненим, перевірте свій список сховища за допомогою:

`dnf repolist`

Ви отримаєте наступне:

```
appstream                                                        Rocky Linux 8 - AppStream
baseos                                                           Rocky Linux 8 - BaseOS
extras                                                           Rocky Linux 8 - Extras
powertools                                                       Rocky Linux 8 - PowerTools
```

## Встановлення пакетів

Щоб встановити `mod_ssl`, запустіть:

`dnf install mod_ssl`

Щоб увімкнути модуль `mod_ssl`, виконайте:

`apachectl restart httpd` `apachectl -M | grep ssl`

Ви побачите:

  `ssl_module (shared)`

## Відкриття порту TCP 443

Щоб дозволити вхідний трафік через HTTPS, виконайте:

```
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --reload
```

Переконайтеся, що ви прагнете відкрити веб-сайт для світу, додаючи це правило! Якщо ні, змініть зону або налаштуйте брандмауер, щоб це виправити.

Ви повинні мати доступ до веб-сервера Apache через HTTPS. Введіть `https://your-server-ip` або `https://your-server-hostname`, щоб підтвердити конфігурацію `mod_ssl`.

## Створення SSL/TLS сертифікату

Щоб створити самопідписаний сертифікат для хосту rocky8 із терміном дії 365 днів, виконайте:

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
Після виконання цієї команди з’являться наступні два файли SSL/TLS:

```
ls -l /etc/pki/tls/private/httpd.key /etc/pki/tls/certs/httpd.crt

-rw-r--r--. 1 root root 1269 Jan 29 16:05 /etc/pki/tls/certs/httpd.crt
-rw-------. 1 root root 1704 Jan 29 16:05 /etc/pki/tls/private/httpd.key
```

## Налаштування веб-сервер Apache із новими сертифікатами SSL/TLS

Щоб включити щойно створений сертифікат SSL/TLS до конфігурації веб-сервера Apache, відкрийте файл `ssl.conf`, виконавши:

`nano /etc/httpd/conf.d/ssl.conf`

Змініть наступні рядки:

З:
```
SSLCertificateFile /etc/pki/tls/certs/localhost.crt
SSLCertificateKeyFile /etc/pki/tls/private/localhost.key
```
НА:
```
SSLCertificateFile /etc/pki/tls/certs/httpd.crt
SSLCertificateKeyFile /etc/pki/tls/private/httpd.key
```

Перезавантажте веб-сервер Apache, виконавши:

`systemctl reload httpd`

## Перевірка конфігурації `mod_ssl`

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

Застосуйте зміни, виконавши:

`systemctl reload httpd`

Веб-сервер Apache перенаправлятиме будь-який вхідний трафік із URL-адреси `http://hostname-вашого-сервера` на URL-адресу `https://ім’я-хоста-вашого-сервера`.

## Останні кроки

Ви бачили, як встановити та налаштувати `mod_ssl`, а також створити новий сертифікат SSL/TLS для запуску веб-сервера під послугою HTTPS.

## Висновок

У цьому підручнику показано базове встановлення та використання `mod_ssl`.
