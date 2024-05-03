---
title: PHP та PHP-FPM
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova, Joseph Brinkman
tested_with: 9.3, 8.9
tags:
  - web
  - php
  - php-fpm
---

# PHP та PHP-FPM

**PHP** (**P**HP **H**ypertext **P**reprocessor) — вихідна мова сценаріїв, спеціально розроблена для розробки веб-додатків. У 2024 році PHP становив трохи менше 80% веб-сторінок, створених у світі. PHP має відкритий код і є ядром найвідоміших CMS (WordPress, Drupal, Joomla!, Magento, ...).

**PHP-FPM** (**F**astCGI **P**rocess **M**anager) інтегровано в PHP з версії 5.3.3. Версія PHP FastCGI надає додаткові функції.

## Загальні положення

**CGI** (**C**common **G**ateway **I**interface) і **FastCGI** дозволяють спілкуватися між веб-сервером (Apache, Nginx, ...) і мовою розробки (Php, Python, Java):

* У випадку **CGI** кожен запит призводить до створення **нового процесу**, який менш ефективний в умовах виконання.
* **FastCGI** покладається на **певну кількість процесів** для обробки своїх клієнтських запитів.

PHP-FPM, **крім кращої продуктивності**, забезпечує:

* Можливість кращого **поділу програм**: запуск процесів з різними uid/gid, з персоналізованими файлами `php.ini`,
* Управління статистикою,
* Керування журналами,
* Динамічне керування процесами та перезапуск без переривання обслуговування («витончений»).

!!! Note "Примітка"

    Оскільки Apache має модуль PHP, php-fpm частіше використовується на сервері Nginx.

## Вибір версії PHP

Rocky Linux, як і його вихідна версія, пропонує багато версій мови. Деякі з них досягли кінця свого життя, але зберігаються для розміщення історичних програм, які ще несумісні з новими версіями PHP. Перегляньте сторінку [підтримуваних версій](https://www.php.net/supported-versions.php) веб-сайту php.net, щоб вибрати підтримувану версію.

Щоб отримати список доступних версій, просто введіть наступну команду:

=== "9.3 Список модулів PHP"

    ```bash
    $ sudo dnf module list php

    Rocky Linux 9 - AppStream
    Name                                                 Stream                                                  Profiles                                                                   Summary                                                         
    php                                                  8.1 [d]                                                 common [d], devel, minimal                                 

    Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
    ```


    Репозиторій Remi пропонує новіші версії PHP, ніж репозиторій Appstream, включаючи версії 8.2 і 8.3. 
    
    Щоб установити репозиторій Remi, виконайте таку команду:

    ```bash
    sudo dnf install https://rpms.remirepo.net/enterprise/remi-release-9.rpm
    ```


    Після встановлення репозиторію Remi увімкніть його, виконавши таку команду.

    ```bash
    sudo dnf config-manager --set-enabled remi
    ```


    Тепер ви можете активувати новіший модуль (PHP 8.3), ввівши таку команду:

    ```bash
    sudo dnf module enable php:remi-8.3
    ```

=== "8.9 Список модулів PHP"

    ```bash
    $ sudo dnf module list php

    Rocky Linux 8 - AppStream
    Name                                                 Stream                                                  Profiles                                                                   Summary                                                         
    php                                                  7.2 [d]                                                 common [d], devel, minimal                                                 PHP scripting language                                          
    php                                                  7.3                                                     common [d], devel, minimal                                                 PHP scripting language                                          
    php                                                  7.4                                                     common [d], devel, minimal                                                 PHP scripting language                                          
    php                                                  8.0                                                     common [d], devel, minimal                                                 PHP scripting language                                          

    Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
    ```


    Rocky надає зі свого репозиторію AppStream різні модулі PHP.
    
    Ви зауважите, що стандартною версією Rocky 8.9 є 7.2, термін служби якої вже закінчився на момент написання статті.
    
    Ви можете активувати новіший модуль, ввівши таку команду:

    ```bash
    sudo dnf module enable php:8.0
    ==============================================================================================
    Package               Architecture         Version               Repository             Size
    ==============================================================================================
    Enabling module streams:
    httpd                                      2.4                                                                                                                              
    nginx                                      1.14                                                                                                                             
    php                                        8.0                                                                                                                              

    Transaction Summary
    ==============================================================================================

    Is this ok [y/N]:

    Transaction Summary
    ==============================================================================================

    Is this ok [y/N]: y
    Complete!
    ```

Тепер можна переходити до встановлення движка PHP.

## Режим PHP cgi

Спочатку давайте подивимося, як встановити та використовувати PHP у режимі CGI. Ми можемо змусити його працювати лише з веб-сервером Apache та його модулем `mod_php`. Далі в цьому документі, у частині FastCGI (php-fpm), ми побачимо, як інтегрувати PHP у Nginx (але також Apache).

### Встановлення

Встановлення PHP є відносно тривіальним, оскільки воно складається з встановлення основного пакета та декількох модулів, які вам знадобляться.

У наведеному нижче прикладі встановлюється PHP із модулями, які зазвичай встановлюються разом із ним.

=== "9.3 встановлення PHP"

    ```bash
    sudo dnf install php php-cli php-gd php-curl php-zip php-mbstring
    ```


    Вам буде запропоновано імпортувати ключі GPG для сховищ epel9 (додаткові пакети для Enterprise Linux 9) і Remi під час встановлення. Введіть y, щоб імпортувати ключі:

    ```bash
    Extra Packages for Enterprise Linux 9 - x86_64                                                                        
    Importing GPG key 0x3228467C:
    Userid     : "Fedora (epel9) <epel@fedoraproject.org>"
    Fingerprint: FF8A D134 4597 106E CE81 3B91 8A38 72BF 3228 467C
    From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-9
    Is this ok [y/N]: y
    Key imported successfully
    Remi's RPM repository for Enterprise Linux 9 - x86_64                                                         
    Importing GPG key 0x478F8947:
    Userid     : "Remi's RPM repository (https://rpms.remirepo.net/) <remi@remirepo.net>"
    Fingerprint: B1AB F71E 14C9 D748 97E1 98A8 B195 27F1 478F 8947
    From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-remi.el9
    Is this ok [y/N]: y
    Key imported successfully
    Running transaction check
    Transaction check succeeded.
    Running transaction test
    Transaction test succeeded.

    Complete!
    ```

=== "8.9 встановлення PHP"

    ```bash
    sudo dnf install php php-cli php-gd php-curl php-zip php-mbstring
    ```

Ви можете перевірити, чи відповідає встановлена версія очікуваній:

=== "9.3 перевірка версії PHP"

    ```bash
    $ php -v
    PHP 8.3.2 (cli) (built: Jan 16 2024 13:46:41) (NTS gcc x86_64)
    Copyright (c) The PHP Group
    Zend Engine v4.3.2, Copyright (c) Zend Technologies
    with Zend OPcache v8.3.2, Copyright (c), by Zend Technologies
    ```

=== "8.9 перевірка версії PHP"

    ```bash
    $ php -v
    PHP 7.4.19 (cli) (built: May  4 2021 11:06:37) ( NTS )
    Copyright (c) The PHP Group
    Zend Engine v3.4.0, Copyright (c) Zend Technologies
    with Zend OPcache v7.4.19, Copyright (c), by Zend Technologies
    ```

### Конфігурація

#### Інтеграція Apache

Щоб обслуговувати сторінки PHP у режимі CGI, ви повинні встановити сервер apache, налаштувати його, активувати та запустити.

* Встановлення:

    ```bash
    sudo dnf install httpd
    ```

    * Активація:

    ```bash
    sudo systemctl enable --now httpd
    sudo systemctl status httpd
    ```

* Не забудьте налаштувати брандмауер:

    ```bash
    sudo firewall-cmd --add-service=http --permanent
    sudo firewall-cmd --reload
    ```

Vhost за замовчуванням має працювати з коробки. PHP надає функцію `phpinfo()`, яка генерує зведену таблицю його конфігурації. Дуже корисно перевірити ефективність PHP. Однак будьте обережні, щоб не залишати такі тестові файли на своїх серверах. Вони становлять величезний ризик для безпеки вашої інфраструктури.

Створіть файл `/var/www/html/info.php` (`/var/www/html` є каталогом vhost за замовчуванням конфігурації apache за замовчуванням):

```bash
<?php
phpinfo();
?>
```

Використовуйте веб-браузер, щоб перевірити, чи сервер працює належним чином, перейшовши на сторінку [http://your-server-ip/info.php ](http://your-server-ip/info.php).

!!! Warning "Важливо"

    Не залишайте файл info.php на своєму сервері!

## PHP-FPM (FastCGI)

Як ми зазначали раніше в цьому документі, перехід веб-хостингу в режим PHP-FPM має багато переваг.

### Встановлення

Встановлення обмежено пакетом php-fpm:

```bash
sudo dnf install php-fpm
```

Оскільки php-fpm є системною службою, її необхідно активувати та запустити:

```bash
sudo systemctl enable --now php-fpm
sudo systemctl status php-fpm
```

### Конфігурація

Основний файл конфігурації зберігається в `/etc/php-fpm.conf`.

```bash
include=/etc/php-fpm.d/*.conf
[global]
pid = /run/php-fpm/php-fpm.pid
error_log = /var/log/php-fpm/error.log
daemonize = yes
```

!!! Note "Примітка"

    Конфігураційні файли php-fpm широко коментуються. Ідіть і подивіться!

Як бачите, файли в каталозі `/etc/php-fpm.d/` із розширенням `.conf` завжди включені.

За замовчуванням пул процесів PHP під назвою `www` оголошено в `/etc/php-fpm.d/www.conf`.

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

| Інструкції | Опис                                                                                                                     |
| ---------- | ------------------------------------------------------------------------------------------------------------------------ |
| `[pool]`   | Ім'я пулу процесів. Конфігураційний файл може містити декілька пулів процесів (ім’я пулу в дужках починає новий розділ). |
| `listen`   | Визначає інтерфейс прослуховування або використовуваний сокет Unix.                                                      |

#### Налаштування способу доступу до процесів php-fpm

Є 2 способи підключення.

Через інтерфейс Інтернету, наприклад:

`listen = 127.0.0.1:9000`.

Або через сокет Unix:

`listen = /run/php-fpm/www.sock`.

!!! Note "Примітка"

    Використання сокета, коли веб-сервер і сервер PHP знаходяться на одній машині, усуває рівень TCP/IP і оптимізує продуктивність.

Під час роботи через інтерфейс вам потрібно налаштувати `listen.owner`, `listen.group`, `listen.mode`, щоб указати власника, групу власників і права на сокет Unix. **Попередження:** обидва сервери (веб і PHP) повинні мати права доступу до сокета.

Під час роботи через сокет вам потрібно налаштувати `listen.allowed_clients`, щоб обмежити доступ до сервера PHP певними IP-адресами.

Приклад: `listen.allowed_clients = 127.0.0.1`

#### Статична або динамічна конфігурація

Процесами PHP-FPM можна керувати статично або динамічно.

У статичному режимі кількість дочірніх процесів встановлюється значенням `pm.max_children`;

```bash
pm = static
pm.max_children = 10
```

Ця конфігурація запустить 10 процесів.

У динамічному режимі PHP-FPM запускатиме не більше кількості процесів, визначених значенням `pm.max_children`, починаючи із запуску певної кількості процесів, що відповідають `pm.start_servers` , і збереження принаймні значення `pm.min_spare_servers` неактивних процесів і для `більшості pm.max_spare_servers` неактивних процесів.

Приклад:

```bash
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```

PHP-FPM створить новий процес замість того, який обробив кількість запитів, еквівалентну `pm.max_requests`.

За замовчуванням `pm.max_requests` встановлено на 0, що означає, що процеси ніколи не повторюються. Використання параметра `pm.max_requests` може бути цікавим для програм із витоками пам’яті.

Існує третій режим роботи, режим `ondemand`. Цей режим запускає процес лише тоді, коли він отримує запит. Цей режим не є оптимальним для сайтів із сильним впливом і має бути зарезервований для конкретних потреб (сайти зі слабкими запитами, сервер керування тощо).

!!! Note "Примітка"

    Конфігурація режиму роботи PHP-FPM необхідна для забезпечення оптимальної роботи вашого веб-сервера.

#### Статус процесу

PHP-FPM пропонує, як і Apache та його модуль `mod_status`, сторінку, яка вказує на статус процесу.

Щоб активувати сторінку, налаштуйте її шлях доступу за допомогою директиви `pm.status_path`:

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

Директива slowlog вказує файл, який отримує надто довгі запити (тобто час яких перевищує значення директиви `request_slowlog_timeout`).

Розташування згенерованого файлу за замовчуванням — `/var/log/php-fpm/www-slow.log`.

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

Щоб nginx міг обробляти файли `.php`, у файл конфігурації сайту потрібно додати такі директиви:

Якщо PHP-FPM прослуховує порт 9000:

```bash
location ~ \.php$ {
  include /etc/nginx/fastcgi_params;
  fastcgi_pass 127.0.0.1:9000;
}
```

Якщо php-fpm прослуховує сокет Unix:

```bash
location ~ \.php$ {
  include /etc/nginx/fastcgi_params;
  fastcgi_pass unix:/run/php-fpm/www.sock;
}
```

### Інтеграція Apache

Конфігурація apache для використання пулу PHP досить проста. Вам просто потрібно використовувати проксі-модулі з директивою `ProxyPassMatch`, наприклад:

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

Важливо оптимізувати кількість запитів, які можна буде обслуговувати, і проаналізувати пам’ять, яку використовують скрипти PHP, щоб оптимізувати максимальну кількість запущених потоків.

Перш за все, нам потрібно знати середній обсяг пам’яті, який використовується процесом PHP за допомогою команди:

```bash
while true; do ps --no-headers -o "rss,cmd" -C php-fpm | grep "pool www" | awk '{ sum+=$1 } END { printf ("%d%s\n", sum/NR/1024,"Mb") }' >> avg_php_proc; sleep 60; done
```

Через деякий час це повинно дати нам досить точне уявлення про середній обсяг пам’яті процесу PHP на цьому сервері.

У решті цього документа скажемо, що результатом є відбиток пам’яті 120 МБ на процес при повному завантаженні.

На сервері з 8 Гб оперативної пам’яті, зберігаючи 1 Гб для системи та 1 Гб для OPCache (див. решту цього документа), залишається 6 Гб для обробки запитів PHP від клієнтів.

Ми можемо легко зробити висновок, що цей сервер може приймати щонайбільше **50 потоків** `((6*1024) / 120)`.

Хорошою конфігурацією `php-fpm` для цього випадку використання буде:

```bash
pm = dynamic
pm.max_children = 50
pm.start_servers = 12
pm.min_spare_servers = 12
pm.max_spare_servers = 36
pm.max_requests = 500
```

з:

* `pm.start_servers` = 25% `max_children`
* `pm.min_spare_servers` = 25% `max_children`
* `pm.max_spare_servers` = 75% `max_children`

### Конфігурація Opcache

`opcache` (Optimizer Plus Cache) — це перший рівень кешу, на який ми можемо впливати.

Він зберігає скомпільовані сценарії PHP у пам’яті, що сильно впливає на виконання веб-сторінок (виключає читання сценарію на диску + час компіляції).

Щоб налаштувати його, ми повинні попрацювати над:

* Розмір пам’яті, виділеної для opcache, відповідно до коефіцієнта звернення
* кількість скриптів PHP для кешу (кількість ключів + максимальна кількість скриптів)
* кількість рядків для кешу

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

де:

* `opcache.memory_consumption` відповідає об’єму пам’яті, необхідному для opcache (потрібно збільшувати, доки не буде отримано правильне співвідношення відвідувань).
* `opcache.interned_strings_buffer` кількість рядків для кешу.
* `opcache.max_accelerated_files` близький до результату команди `find ./ -iname "*.php"|wc -l`.

Ви можете звернутися до сторінки `info.php` (включаючи `phpinfo();`), щоб налаштувати opcache (перегляньте, наприклад, значення `Cached scripts` > і `Кешовані рядки`).

!!! Note "Примітка"

    При кожному новому розгортанні нового коду необхідно буде очищати opcache (наприклад, перезапустивши процес php-fpm).

!!! Note "Примітка"

    Не варто недооцінювати збільшення швидкості, досягнуте правильним налаштуванням opcache.
