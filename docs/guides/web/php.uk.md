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

**PHP** (**P**HP \*\*Hypertext **P**reprocessor) — це мова програмування вихідного коду, спеціально розроблена для розробки вебзастосунків. У 2024 році PHP становив трохи менше 80% веб-сторінок, створених у світі. PHP має відкритий код і є ядром найвідоміших CMS (WordPress, Drupal, Joomla!, Magento, ...).

**PHP-FPM** (**F**astCGI **P**process **M**anager) інтегровано в PHP, починаючи з версії 5.3.3. Версія PHP FastCGI надає додаткові функції.

## Загальні положення

**CGI** (\*\*Звичайний інтерфейс **Gateway**) та **FastCGI** дозволяють зв'язок між веб-сервером (Apache, Nginx та інші) та мовою розробки (PHP, Python, Java):

- У випадку **CGI** кожен запит призводить до створення **нового процесу**, який менш ефективний в умовах виконання.
- **FastCGI** покладається на **певну кількість процесів** для обробки своїх клієнтських запитів.

PHP-FPM, **крім кращої продуктивності**, забезпечує:

- Можливість кращого **поділу програм**: запуск процесів з різними uid/gid, з персоналізованими файлами `php.ini`,
- Управління статистикою,
- Керування журналами,
- Динамічне керування процесами та перезапуск без переривання обслуговування («витончений»).

!!! Note "Примітка"

    ```
    Оскільки Apache має модуль PHP, php-fpm частіше використовується на сервері Nginx.
    ```

## Вибір версії PHP

Rocky Linux, як і його апстрім, пропонує багато версій мови. Деякі з них досягли кінця свого терміну служби, але продовжують розміщувати історичні програми, які ще не сумісні з новими версіями PHP. Будь ласка, зверніться до сторінки [підтримувані версії](https://www.php.net/supported-versions.php) на вебсайті php.net, щоб вибрати підтримувану версію.

Щоб отримати список доступних версій, просто введіть наступну команду:

## Визначення останньої версії PHP

Щоб визначити останню доступну версію PHP, використовуйте:

```bash
$ sudo dnf module list php
   
Last metadata expiration check: 1:57:32 ago on Wed 22 Oct 2025 11:49:06 AM UTC.
Rocky Linux 8 - AppStream
Name                 Stream                  Profiles                                   Summary                               
php                  7.2 [d]                 common [d], devel, minimal                 PHP scripting language                
php                  7.3                     common [d], devel, minimal                 PHP scripting language                
php                  7.4                     common [d], devel, minimal                 PHP scripting language                
php                  8.0                     common [d], devel, minimal                 PHP scripting language                
php                  8.2                     common [d], devel, minimal                 PHP scripting language                

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
```

Rocky надає зі свого репозиторію AppStream різні модулі PHP.

Ви помітите, що версія Rocky 8 за замовчуванням — 7.2, термін служби якої на момент написання цієї статті вже закінчився.

Ви можете активувати новіший модуль, ввівши таку команду:

```bash
sudo dnf module enable php:8.2
==============================================================================================
Package               Architecture         Version               Repository             Size
==============================================================================================
Enabling module streams:
httpd                                      2.4                                                                                                                              
nginx                                      1.14                                                                                                                             
php                                        8.2                                                                                                                              

Transaction Summary
==============================================================================================

Is this ok [y/N]: y
Complete!

```

Тепер можна переходити до встановлення движка PHP.

## Режим PHP cgi

Спочатку встановіть PHP у режимі CGI. Ви можете змусити його працювати лише за допомогою веб-сервера Apache та його модуля `mod_php`. Далі в цьому документі ви побачите, як інтегрувати PHP у Nginx та Apache.

### Встановлення PHP

Встановлення PHP є відносно тривіальним, оскільки воно складається з встановлення основного пакета та декількох модулів, які вам знадобляться.

У наведеному прикладі встановлюється PHP з модулями, які зазвичай встановлюються разом з ним:

```bash
sudo dnf install php php-cli php-gd php-curl php-zip php-mbstring
```

Ви можете перевірити, чи відповідає встановлена версія очікуваній:

```bash
php -v
PHP 8.2.28 (cli) (built: Mar 11 2025 17:58:12) (NTS gcc x86_64)
Copyright (c) The PHP Group
Zend Engine v4.2.28, Copyright (c) Zend Technologies
    with Zend OPcache v8.2.28, Copyright (c), by Zend Technologies
```

### Конфігурація

#### Інтеграція Apache

Щоб обслуговувати сторінки PHP у режимі CGI, ви повинні встановити сервер apache, налаштувати його, активувати та запустити.

- Встановлення:

 ```bash
 sudo dnf install httpd
 ```

    ```
    * Акттивація:
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

Vhost за замовчуванням має запрацювати одразу. PHP надає функцію `phpinfo()`, яка генерує зведену таблицю своєї конфігурації. Це дуже корисно для перевірки належної роботи PHP. Однак будьте обережні, щоб не залишати такі тестові файли на своїх серверах. Вони становлять величезний ризик для безпеки вашої інфраструктури.

Створіть файл `/var/www/html/info.php` (`/var/www/html` є каталогом vhost за замовчуванням конфігурації apache за замовчуванням):

```bash
<?php
phpinfo();
?>
```

Використовуйте веб-браузер, щоб перевірити, чи сервер працює належним чином, перейшовши на сторінку [http://your-server-ip/info.php ](http://your-server-ip/info.php).

!!! Warning "Увага"

    ```
    Не залишайте файл `info.php` на своєму сервері!
    ```

## PHP-FPM (FastCGI)

Як ми зазначали раніше в цьому документі, перехід веб-хостингу в режим PHP-FPM має багато переваг.

### Встановлення PHP-FPM

Щоб встановити пакет `php-fpm`, використовуйте:

```bash
sudo dnf install php-fpm
```

Оскільки `php-fpm` є сервісом з точки зору системи, ви повинні активувати та запустити його:

```bash
sudo systemctl enable --now php-fpm
sudo systemctl status php-fpm
```

### Конфігурація

Основний файл конфігурації знаходиться у файлі `/etc/php-fpm.conf`:

```bash
include=/etc/php-fpm.d/*.conf
[global]
pid = /run/php-fpm/php-fpm.pid
error_log = /var/log/php-fpm/error.log
daemonize = yes
```

!!! Note "Примітка"

    ```
    Файли конфігурації `php-fpm` широко коментуються. Зайдіть та подивіться!
    ```

Як бачите, файли в каталозі `/etc/php-fpm.d/` із розширенням `.conf` завжди включені.

За замовчуванням, `php-fpm` оголошує пул процесів PHP з назвою `www` у `/etc/php-fpm.d/www.conf`:

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

#### Налаштування способу доступу до процесів `php-fpm`

Є 2 способи підключення.

Через інтерфейс Інтернету, наприклад:

`listen = 127.0.0.1:9000`.

Або з Unix-сокетом:

`listen = /run/php-fpm/www.sock`.

!!! Note "Примітка"

    ```
    Використання сокета, коли веб-сервер і сервер PHP знаходяться на одній машині, усуває рівень TCP/IP і оптимізує продуктивність.
    ```

Під час роботи з інтерфейсом потрібно налаштувати `listen.owner`, `listen.group`, `listen.mode`, щоб вказати власника, групу власників та права Unix-сокета. **Попередження:** Обидва сервери (веб- і PHP) повинні мати права доступу до сокета.

Під час роботи з сокетом необхідно налаштувати `listen.allowed_clients`, щоб обмежити доступ до PHP-сервера певним IP-адресам.

Приклад: `listen.allowed_clients = 127.0.0.1`

#### Статична або динамічна конфігурація

Ви можете керувати процесами PHP-FPM статично або динамічно.

У статичному режимі значення `pm.max_children` встановлює кількість дочірніх процесів:

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

За замовчуванням значення `pm.max_requests` дорівнює 0, що означає, що процеси ніколи не перезавантажуються. Використання опції `pm.max_requests` може бути цікавим для програм з витоками пам'яті.

Існує третій режим роботи – режим «на вимогу». Цей режим запускає процес лише тоді, коли він отримує запит. Це не оптимальний режим для сайтів із сильним впливом, і вам слід зарезервувати його для конкретних потреб (сайти з дуже слабкими запитами, адміністраторська база даних тощо).

!!! Note "Примітка"

    ```
    Конфігурація режиму роботи PHP-FPM необхідна для забезпечення оптимальної роботи вашого веб-сервера.
    ```

#### Статус процесу

PHP-FPM пропонує, подібно до Apache та його модуля `mod_status`, сторінку, що вказує на стан процесу.

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

Директива `slowlog` вказує файл, який приймає логування занадто довгих запитів (наприклад, файлів, час яких перевищує значення директиви `request_slowlog_timeout`).

Розташування згенерованого файлу за замовчуванням — `/var/log/php-fpm/www-slow.log`.

```bash
request_slowlog_timeout = 5
slowlog = /var/log/php-fpm/www-slow.log
```

Значення 0 для `request_slowlog_timeout` вимикає журналювання.

### Інтеграція NGinx

Налаштування `nginx` за замовчуванням вже включає необхідну конфігурацію для роботи PHP з PHP-FPM.

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

Щоб `nginx` обробляв файли `.php`, потрібно додати такі директиви до файлу конфігурації сайту:

Якщо PHP-FPM прослуховує порт 9000:

```bash
location ~ \.php$ {
  include /etc/nginx/fastcgi_params;
  fastcgi_pass 127.0.0.1:9000;
}
```

Якщо `php-fpm` прослуховує сокет Unix:

```bash
location ~ \.php$ {
  include /etc/nginx/fastcgi_params;
  fastcgi_pass unix:/run/php-fpm/www.sock;
}
```

### Інтеграція Apache

Конфігурація Apache для використання пулу PHP досить проста. Ви повинні використовувати проксі-модулі з директивою `ProxyPassMatch`, наприклад:

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

Важливо оптимізувати кількість обслуговуваних запитів та проаналізувати пам'ять, що використовується PHP-скриптами, щоб оптимізувати максимальну кількість запущених потоків.

Налаштування за замовчуванням nginx уже включають необхідну конфігурацію, щоб PHP працював із PHP-FPM.

```bash
while true; do ps --no-headers -o "rss,cmd" -C php-fpm | grep "pool www" | awk '{ sum+=$1 } END { printf ("%d%s\n", sum/NR/1024,"Mb") }' >> avg_php_proc; sleep 60; done
```

Через деякий час це повинно дати нам досить точне уявлення про середній обсяг пам’яті процесу PHP на цьому сервері.

У решті цього документа показано обсяг пам'яті, що займає 120 мегабайт на процес при повному навантаженні.

Сервер з 8 гігабайтами оперативної пам'яті, залишаючи 1 гігабайт для системи та 1 гігабайт для OPCache (див. решту цього документа), залишає 6 гігабайт для обробки PHP-запитів від клієнтів.

Можна зробити висновок, що цей сервер може прийняти максимум **50 потоків** `((6*1024) / 120)`.

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

- `pm.start_servers` = 25% `max_children`
- `pm.min_spare_servers` = 25% `max_children`
- `pm.max_spare_servers` = 75% `max_children`

### Конфігурація Opcache

`opcache` (Optimizer Plus Cache) — це перший рівень кешу, на який ми можемо впливати.

Він зберігає скомпільовані сценарії PHP у пам’яті, що сильно впливає на виконання веб-сторінок (виключає читання сценарію на диску + час компіляції).

Щоб його налаштувати, потрібно попрацювати над:

- Розмір пам'яті, виділеної для `opcache`, відповідно до коефіцієнта влучань, за умови правильного налаштування
- кількість скриптів PHP для кешу (кількість ключів + максимальна кількість скриптів)
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

де:

- `opcache.memory_consumption` відповідає об'єму пам'яті, необхідному для `opcache` (ви збільшуєте його, доки не отримаєте правильний коефіцієнт влучань).
- `opcache.interned_strings_buffer` кількість рядків для кешу.
- `opcache.max_accelerated_files` близький до результату команди `find ./ -iname "*.php"|wc -l`.

Ви можете звернутися до сторінки `info.php` (включно з `phpinfo();`), щоб налаштувати `opcache` (див., наприклад, значення `Cached scripts` та `Cached strings`).

!!! Note "Примітка"

    ```
    Під час кожного нового розгортання нового коду необхідно буде очищати opcache (наприклад, перезапускаючи процес `php-fpm`).
    ```

!!! Note "Примітка"

    ```
    Не варто недооцінювати приріст швидкості, якого можна досягти, правильно налаштувавши та сконфігурувавши `opcache`.
    ```
