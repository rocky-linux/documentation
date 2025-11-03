---
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
title: Частина 3. Сервери додатків
tags:
  - web
  - php
  - php-fpm
  - сервери додатків
  - динамічна мова
---

## PHP та PHP-FPM

У цьому розділі ви дізнаєтеся про PHP і PHP-FPM.

**PHP** (**P**HP **H**ypertext **P**reprocessor) — вихідна мова сценаріїв, спеціально розроблена для розробки веб-додатків. У 2024 році PHP становив трохи менше 80% веб-сторінок, створених у світі. PHP є відкритим кодом і є ядром найвідоміших CMS (WordPress, Drupal, Joomla!, Magento тощо).

**PHP-FPM** (**F**astCGI **P**rocess **M**anager) інтегровано в PHP з версії 5.3.3. Версія PHP FastCGI надає додаткові функції.

****

**Цілі**: Ви дізнаєтеся, як:

:heavy_check_mark: встановити сервер додатків PHP  
:heavy_check_mark: налаштувати пул PHP-FPM  
:heavy_check_mark: оптимізувати сервер додатків PHP-FPM

:checkered_flag: **PHP**, **PHP-FPM**, **Application server**

**Знання**: :star: :star: :star:  
**Складність**: :star: :star: :star:

**Час читання**: 30 хвилин

****

### Загальні положення

**CGI** (**C**common **G**ateway **I**interface) і **FastCGI** дозволяють спілкуватися між веб-сервером (Apache або Nginx) і мовою розробки (PHP, Python) , Java):

- У випадку **CGI** кожен запит створює **новий процес**, який є менш ефективним у продуктивності.
- **FastCGI** покладається на **певну кількість процесів** для обробки запитів клієнтів.

PHP-FPM, **крім кращої продуктивності**, забезпечує:

- Можливість кращого **поділу програм**: запуск процесів з різними uid/gid, з персоналізованими файлами `php.ini`,
- Управління статистикою,
- Керування журналами,
- Динамічне керування процесами та перезапуск без переривання обслуговування («витончений»).

!!! Note "Примітка"

```
Оскільки Apache має модуль PHP, php-fpm частіше використовується на сервері Nginx.
```

### Версія PHP

У Rocky Linux 10, як і в його апстрімі, немає модулів. Це означає, що під час встановлення PHP ви отримаєте пакети з репозиторію Appstream. Щоб дізнатися, що це таке, скористайтеся цією командою:

```bash
dnf whatprovides php
Last metadata expiration check: 0:03:22 ago on Tue 21 Oct 2025 02:40:23 PM UTC.
php-8.3.19-1.el10_0.x86_64 : PHP scripting language for creating dynamic web sites
Repo        : appstream
Matched from:
Provide    : php = 8.3.19-1.el10_0
```

Ваша версія може відрізнятися, якщо у вас новіша версія 10.

### Установка режиму PHP CGI

Спочатку встановіть і використовуйте PHP у режимі CGI. Він може працювати лише з веб-сервером Apache та його модулем `mod_php`. У розділі FastCGI (php-fpm) цього документа пояснюється, як інтегрувати PHP з Nginx (а також Apache).

Встановлення PHP є відносно простим процесом. Він складається з встановлення основного пакета та кількох необхідних модулів.

У наведеному нижче прикладі встановлюється PHP з модулями, які зазвичай входять до комплекту.

```bash
sudo dnf install php php-cli php-gd php-curl php-zip php-mbstring
```

Перевірте свою версію за допомогою:

```bash
php -v
PHP 8.3.19 (cli) (built: Mar 12 2025 13:10:27) (NTS gcc x86_64)
Copyright (c) The PHP Group
Zend Engine v4.3.19, Copyright (c) Zend Technologies
    with Zend OPcache v8.3.19, Copyright (c), by Zend Technologies
```

### Інтеграція Apache

Щоб обслуговувати сторінки PHP у режимі CGI, ви повинні встановити сервер apache, налаштувати його, активувати та запустити.

- Встановлення:

```bash
sudo dnf install httpd
```

```
активація:
```

```bash
sudo systemctl enable --now httpd
sudo systemctl status httpd
```

- Не забудьте налаштувати брандмауер:

```bash
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --reload
```

Vhost за замовчуванням має працювати з коробки. PHP надає функцію `phpinfo()`, яка створює зведену таблицю його конфігурації. Корисно перевірити ефективність PHP. Однак будьте обережні, щоб не залишати такі тестові файли на своїх серверах. Вони становлять величезний ризик для безпеки вашої інфраструктури.

Створіть файл `/var/www/html/info.php` (`/var/www/html` є каталогом vhost за замовчуванням конфігурації Apache за замовчуванням):

```bash
<?php
phpinfo();
?>
```

Скористайтеся веббраузером, щоб перевірити, чи сервер працює належним чином, відвідавши [http://your-server-ip/info.php](http://your-server-ip/info.php).

!!! Warning "Важливо"

```
Не залишайте файл `info.php` на своєму сервері!
```

### Встановлення режиму PHP CGI (PHP-FPM)

Як зазначалося раніше, існує багато переваг перемикання веб-хостингу в режим PHP-FPM.

Встановлення передбачає лише пакет php-fpm:

```bash
sudo dnf install php-fpm
```

Оскільки php-fpm є системною службою, її необхідно активувати та запустити:

```bash
sudo systemctl enable --now php-fpm
sudo systemctl status php-fpm
```

#### Конфігурація режиму PHP CGI

Основний файл конфігурації – `/etc/php-fpm.conf`.

```bash
include=/etc/php-fpm.d/*.conf
[global]
pid = /run/php-fpm/php-fpm.pid
error_log = /var/log/php-fpm/error.log
daemonize = yes
```

!!! Note "Примітка"

```
Конфігураційні файли php-fpm широко коментуються. Ідіть і подивіться!
```

Як бачите, файли в каталозі `/etc/php-fpm.d/` з розширенням `.conf` завжди включені.

Оголошення пулу процесів PHP із назвою `www` за замовчуванням міститься в `/etc/php-fpm.d/www.conf`.

```bash
[www]
user = apache
group = apache

listen = /run/php-fpm/www.sock
listen.acl_users = apache,nginx
listen.allowed_clients = 127.0.0.1

pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35

slowlog = /var/log/php-fpm/www-slow.log

php_admin_value[error_log] = /var/log/php-fpm/www-error.log
php_admin_flag[log_errors] = on
php_value[session.save_handler] = files
php_value[session.save_path]    = /var/lib/php/session
php_value[soap.wsdl_cache_dir]  = /var/lib/php/wsdlcache
```

| Інструкції | Опис                                                                                                                                                                        |
| ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `[pool]`   | Ім'я пулу процесів. Конфігураційний файл може містити декілька пулів процесів (ім’я пулу в дужках починає новий розділ). |
| `listen`   | Визначає інтерфейс прослуховування або використовуваний сокет Unix.                                                                                         |

#### Налаштування способу доступу до процесів php-fpm

Існує два способи підключення.

З «inet-інтерфейсом», наприклад:

`listen = 127.0.0.1:9000`.

Або з сокетом UNIX:

`listen = /run/php-fpm/www.sock`.

!!! Note "Примітка"

```
Використання сокета, коли веб-сервер і сервер PHP знаходяться на одній машині, усуває рівень TCP/IP і оптимізує продуктивність.
```

Під час роботи з інтерфейсом вам потрібно налаштувати `listen.owner`, `listen.group`, `listen.mode`, щоб вказати власника, групу власників і права сокета UNIX. **Попередження:** обидва сервери (веб і PHP) повинні мати права доступу до сокета.

Працюючи з сокетом, ви повинні налаштувати `listen.allowed_clients`, щоб обмежити доступ до сервера PHP певними IP-адресами.

Приклад: `listen.allowed_clients = 127.0.0.1`

#### Статична або динамічна конфігурація

Ви можете керувати процесами PHP-FPM статично або динамічно.

У статичному режимі `pm.max_children` встановлює обмеження на кількість дочірніх процесів:

```bash
pm = static
pm.max_children = 10
```

Ця конфігурація починається з 10 процесів.

In dynamic mode, PHP-FPM starts at _most_ the number of processes specified by the`pm.max_children` value. Спочатку він запускає деякі процеси, що відповідають `pm.start_servers`, зберігаючи принаймні значення `pm.min_spare_servers` для неактивних процесів і, щонайбільше, `pm.max_spare_servers` для неактивних процесів.

Приклад:

```bash
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```

PHP-FPM створить новий процес замість того, який обробив кілька запитів, еквівалентних `pm.max_requests`.

За замовчуванням значення `pm.max_requests` дорівнює 0, тобто процеси ніколи не повторюються. Параметр "pm.max_requests" може бути привабливим для програм з витоками пам'яті.

Третій режим роботи - це режим "ondemand". Цей режим запускає процес лише тоді, коли він отримує запит. Цей режим не є оптимальним для сайтів із сильним впливом і зарезервований для конкретних потреб (сайти зі слабкими запитами, сервер керування тощо).

!!! Note "Примітка"

```
Конфігурація режиму роботи PHP-FPM необхідна для забезпечення оптимальної роботи вашого веб-сервера.
```

#### Статус процесу

Подібно до Apache та його модуля `mod_status`, PHP-FPM пропонує сторінку, на якій вказується статус процесу.

Щоб активувати сторінку, встановіть її шлях доступу за допомогою директиви `pm.status_path`:

```bash
pm.status_path = /status
```

```bash
$ curl http://localhost/status_php
pool:                 www
process manager:      dynamic
start time:           03/Dec/2021:14:00:00 +0100
start since:          600
accepted conn:        548
listen queue:         0
max listen queue:     15
listen queue len:     128
idle processes:       3
active processes:     3
total processes:      5
max active processes: 5
max children reached: 0
slow requests:        0
```

#### Реєстрація довгих запитів

Директива `slowlog` визначає файл, який отримує занадто довгі запити на журналювання (наприклад, час яких перевищує значення директиви `request_slowlog_timeout`).

Розташування згенерованого файлу за замовчуванням – `/var/log/php-fpm/www-slow.log`.

```bash
request_slowlog_timeout = 5
slowlog = /var/log/php-fpm/www-slow.log
```

Значення 0 для `request_slowlog_timeout` вимикає журналювання.

### Інтеграція NGinx

Налаштування за замовчуванням nginx уже включають необхідну конфігурацію, щоб PHP працював із PHP-FPM.

Файл конфігурації `fastcgi.conf` (або `fastcgi_params`) знаходиться в `/etc/nginx/`:

```bash
fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
fastcgi_param  QUERY_STRING       $query_string;
fastcgi_param  REQUEST_METHOD     $request_method;
fastcgi_param  CONTENT_TYPE       $content_type;
fastcgi_param  CONTENT_LENGTH     $content_length;

fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;
fastcgi_param  REQUEST_URI        $request_uri;
fastcgi_param  DOCUMENT_URI       $document_uri;
fastcgi_param  DOCUMENT_ROOT      $document_root;
fastcgi_param  SERVER_PROTOCOL    $server_protocol;
fastcgi_param  REQUEST_SCHEME     $scheme;
fastcgi_param  HTTPS              $https if_not_empty;

fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
fastcgi_param  SERVER_SOFTWARE    nginx/$nginx_version;

fastcgi_param  REMOTE_ADDR        $remote_addr;
fastcgi_param  REMOTE_PORT        $remote_port;
fastcgi_param  SERVER_ADDR        $server_addr;
fastcgi_param  SERVER_PORT        $server_port;
fastcgi_param  SERVER_NAME        $server_name;

# PHP only, required if PHP was built with --enable-force-cgi-redirect
fastcgi_param  REDIRECT_STATUS    200;
```

Щоб nginx обробляв файли `.php`, додайте такі директиви до файлу конфігурації сайту:

Якщо PHP-FPM прослуховує порт 9000:

```bash
location ~ \.php$ {
  include /etc/nginx/fastcgi_params;
  fastcgi_pass 127.0.0.1:9000;
}
```

Якщо php-fpm прослуховує сокет UNIX:

```bash
location ~ \.php$ {
  include /etc/nginx/fastcgi_params;
  fastcgi_pass unix:/run/php-fpm/www.sock;
}
```

### Інтеграція Apache

Конфігурація apache для використання пулу PHP досить проста. Ви повинні використовувати проксі-модулі з директивою `ProxyPassMatch`, наприклад:

```bash
<VirtualHost *:80>
  ServerName web.rockylinux.org
  DocumentRoot "/var/www/html/current/public"

  <Directory "/var/www/html/current/public">
    AllowOverride All
    Options -Indexes +FollowSymLinks
    Require all granted
  </Directory>
  ProxyPassMatch ^/(.*\.php(/.*)?)$ "fcgi://127.0.0.1:9000/var/www/html/current/public"

</VirtualHost>

```

### Надійна конфігурація пулів PHP

Оптимізація кількості запитів, що обслуговуються, і аналіз пам’яті, яка використовується сценаріями PHP, необхідні для збільшення кількості запущених потоків.

Перш за все, вам потрібно знати середній обсяг пам’яті, який використовує процес PHP за допомогою команди:

```bash
while true; do ps --no-headers -o "rss,cmd" -C php-fpm | grep "pool www" | awk '{ sum+=$1 } END { printf ("%d%s\n", sum/NR/1024,"Mb") }' >> avg_php_proc; sleep 60; done
```

Це дасть вам досить точне уявлення про середній обсяг пам’яті процесу PHP на цьому сервері.

Решта цього документа призводить до використання пам’яті 120 Мб на процес при повному завантаженні.

На сервері з 8 Гб оперативної пам’яті, зберігаючи 1 Гб для системи та 1 Гб для OPCache (див. решту цього документа), залишається 6 Гб для обробки запитів PHP від клієнтів.

Ви можете зробити висновок, що цей сервер може приймати не більше **50 потоків** `((6*1024) / 120)`.

Хороша конфігурація `php-fpm`, специфічна для цього випадку використання:

```bash
pm = dynamic
pm.max_children = 50
pm.start_servers = 12
pm.min_spare_servers = 12
pm.max_spare_servers = 36
pm.max_requests = 500
```

з:

- `pm.start_servers` = 25% of `max_children`
- `pm.min_spare_servers` = 25% of `max_children`
- `pm.max_spare_servers` = 75% of `max_children`

### Конфігурація Opcache

`opcache` (Optimizer Plus Cache) — це перший рівень кешу, на який ви можете впливати.

Він зберігає скомпільовані сценарії PHP у пам’яті, що сильно впливає на виконання веб-сторінок (виключає читання сценарію на диску + час компіляції).

Щоб його налаштувати, необхідно попрацювати над:

- Розмір пам’яті, виділеної для opcache, відповідно до коефіцієнта звернення
- Кількість скриптів PHP для кешу (кількість ключів + максимальна кількість скриптів)
- кількість рядків для кешу

Щоб встановити його:

```bash
sudo dnf install php-opcache
```

Щоб налаштувати його, відредагуйте файл конфігурації `/etc/php.d/10-opcache.ini`:

```bash
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
```

Де:

- `opcache.memory_consumption` відповідає об’єму пам’яті, необхідному для opcache (збільшуйте це значення, доки не отримаєте правильний коефіцієнт звернення).
- `opcache.interned_strings_buffer` кількість рядків для кешу.
- `opcache.max_accelerated_files` близький до результату команди `find ./ -iname "*.php"|wc -l`.

Щоб налаштувати opcache, зверніться до сторінки `info.php` (включаючи `phpinfo();`) (див., наприклад, значення `Cached scripts` і `Cached strings`).

!!! Note "Примітка"

```
При кожному новому розгортанні нового коду необхідно буде очищати opcache (наприклад, перезапустивши процес php-fpm).
```

!!! Note "Примітка"

```
Не варто недооцінювати приріст швидкості, якого можна досягти шляхом правильного встановлення та конфігурації opcache.
```

<!---

### Workshop

#### Task 1 : XXX

#### Task 2 : XXX

#### Task 3 : XXX

#### Task 4 : XXX

### Check your Knowledge

:heavy_check_mark: Simple question? (3 answers)

:heavy_check_mark: Question with multiple answers?

* [ ] Answer 1
* [ ] Answer 2
* [ ] Answer 3
* [ ] Answer 4

## Python

In this chapter, you will learn about XXXXXXX.

****

**Objectives**: In this chapter, you will learn how to:

:heavy_check_mark: XXX
:heavy_check_mark: XXX

:checkered_flag: **XXX**, **XXX**

**Knowledge**: :star:
**Complexity**: :star:

**Reading time**: XX minutes

****

### Generalities

### Configuration

### Security

### Workshop

#### Task 1 : XXX

#### Task 2 : XXX

#### Task 3 : XXX

#### Task 4 : XXX

### Check your Knowledge

:heavy_check_mark: Simple question? (3 answers)

:heavy_check_mark: Question with multiple answers?

* [ ] Answer 1
* [ ] Answer 2
* [ ] Answer 3
* [ ] Answer 4

-->
