---
title: Хмарний сервер за допомогою Nextcloud
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - cloud
  - nextcloud
---

# Хмарний сервер за допомогою Nextcloud

!!! примітка "Примітка щодо Rocky Linux 9.0"

    Ця процедура має працювати для Rocky Linux 9.x. Різниця полягає в тому, що вам може знадобитися змінити посилання на версії для деяких репозиторіїв, щоб оновити їх до версії 9.  Якщо ви використовуєте Rocky Linux 9.x, майте на увазі, що це було протестовано як у 8.6, так і в 9.0, але спочатку було написано для 8.6.

## Передумови та припущення

- Сервер під керуванням Rocky Linux (ви можете встановити Nextcloud на будь-якому дистрибутиві Linux, але ця процедура передбачає, що ви використовуєте Rocky).
- Високий рівень комфорту роботи з командного рядка для встановлення та налаштування.
- Знання редактора командного рядка. У цьому прикладі ми використовуємо _vi_, але ви можете використовувати свій улюблений редактор, якщо він у вас є.
- Хоча Nextcloud можна встановити за допомогою програми snap, ми будемо документувати лише встановлення файлу .zip.
- Ми будемо застосовувати концепції з документа Apache _sites enabled_ (посилання на яке наведено нижче) для налаштування каталогу.
- Ми також будемо використовувати процедуру посилення _mariadb-server_ (посилання на яку також буде використано пізніше) для налаштування бази даних.
- У цьому документі ми будемо припускати, що ви є адміністратором або що ви можете бути ним за допомогою _sudo_.
- Ми використовуємо приклад домену <yourdomain.com>yourdomain.com</0> у конфігурації.

## Вступ

Якщо ви відповідаєте за серверне середовище великої (або навіть невеликої) компанії, вас можуть спокусити хмарні програми. Виконання завдань у хмарі може звільнити ваші власні ресурси для інших речей, але це має зворотну сторону, а саме втрату контролю над даними вашої компанії. Якщо хмарну програму зламано, можливо, і дані вашої компанії також.

Повернення хмари у ваше власне середовище – це спосіб відновити безпеку ваших даних за рахунок вашого часу та енергії. Іноді це вартість, яку варто заплатити.

Nextcloud пропонує хмару з відкритим вихідним кодом з урахуванням безпеки та гнучкості. Зауважте, що створення сервера Nextcloud є гарною вправою, навіть якщо ви зрештою вирішите перенести свою хмару за межі сайту. Наступна процедура стосується налаштування Nextcloud на Rocky Linux.

## Встановлення Nextcloud

### Встановлення та налаштування репозиторіїв і модулів

Для цієї інсталяції нам знадобляться два репозиторії. Нам потрібно встановити EPEL (додаткові пакети для Enterprise Linux) і репозиторій Remi для PHP 8.3

!!! note "Примітка"

    Потрібна мінімальна версія PHP 7.3 або 7.4, а версія Rocky Linux 7.4 не містить усіх пакетів, необхідних Nextcloud. Натомість ми збираємося використовувати PHP 8.3 із сховища Remi.

Щоб встановити EPEL запустіть:

```bash
dnf install epel-release
```

Щоб встановити репозиторій Remi, запустіть (зверніть увагу, якщо ви використовуєте Rocky Linux 9.x, замініть 9 поруч із `release-` нижче):

```bash
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
```

Потім знову запустіть `dnf upgrade`.

Виконайте наступне, щоб переглянути список модулів php, які можна ввімкнути:

```bash
dnf module list php
```

який дає вам такий вихід для Rocky Linux 8.x (подібний результат буде показано для Rocky Linux 9.x):

```bash
Rocky Linux 8 - AppStream
Name                    Stream                     Profiles                                     Summary                                 
php                     7.2 [d]                    common [d], devel, minimal                   PHP scripting language                  
php                     7.3                        common [d], devel, minimal                   PHP scripting language                  
php                     7.4                        common [d], devel, minimal                   PHP scripting language               
php                     7.4                        common [d], devel, minimal                   PHP scripting language                  
Remi's Modular repository for Enterprise Linux 8 - x86_64
Name                    Stream                     Profiles                                     Summary                                 
php                     remi-7.2                   common [d], devel, minimal                   PHP scripting language                  
php                     remi-7.3                   common [d], devel, minimal                   PHP scripting language                  
php                     remi-7.4                   common [d], devel, minimal                   PHP scripting language                  
php                     remi-8.0                   common [d], devel, minimal                   PHP scripting language                  
php                     remi-8.1                   common [d], devel, minimal                   PHP scripting language                  
php                     remi-8.2                   common [d], devel, minimal                   PHP scripting language                  
php                     remi-8.3                   common [d], devel, minimal                   PHP scripting language                  
Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
```

Ми хочемо взяти найновіший PHP, сумісний з Nextcloud, який на даний момент є 8.3, тому ми ввімкнемо цей модуль, виконавши:

```bash
dnf module enable php:remi-8.3
```

Щоб побачити, як це змінює вихід списку модулів, запустіть команду списку модулів знову, і ви побачите «[e]» поруч із 8.3:

```bash
dnf module list php
```

І результат знову той самий, за винятком цього рядка:

```bash
php                    remi-8.3 [e]                   common [d], devel, minimal                  PHP scripting language
```

### Встановлення пакетів

У нашому прикладі використовуються Apache і mariadb, тому, щоб встановити те, що нам потрібно, нам просто потрібно зробити наступне:

```bash
dnf install httpd mariadb-server vim wget zip unzip libxml2 openssl php83-php php83-php-ctype php83-php-curl php83-php-gd php83-php-iconv php83-php-json php83-php-libxml php83-php-mbstring php83-php-openssl php83-php-posix php83-php-session php83-php-xml php83-php-zip php83-php-zlib php83-php-pdo php83-php-mysqlnd php83-php-intl php83-php-bcmath php83-php-gmp
```

### Конфігурація

#### Конфігурація Apache

Налаштуйте _apache_ на запуск під час завантаження:

```bash
systemctl enable httpd
```

Потім запустіть:

```bash
systemctl start httpd
```

#### Створення конфігурації

У розділі _Переумови та припущення_ ми згадали, що для нашої конфігурації будемо використовувати процедуру [Apache Sites Enabled](../web/apache-sites-enabled.md). Перейдіть до цієї процедури та налаштуйте там основи, а потім поверніться до цього документа, щоб продовжити.

Для Nextcloud нам потрібно буде створити наступний файл конфігурації.

```bash
vi /etc/httpd/sites-available/com.yourdomain.nextcloud
```

Ваш файл конфігурації має виглядати приблизно так:

```bash
<VirtualHost *:80>
  DocumentRoot /var/www/sub-domains/com.yourdomain.nextcloud/html/
  ServerName  nextcloud.yourdomain.com
  <Directory /var/www/sub-domains/com.yourdomain.nextcloud/html/>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>
```

Після цього збережіть зміни (за допомогою ++shift+colon+"w"+"q"+exclam++ для _vi_).

Далі створіть посилання на цей файл у /etc/httpd/sites-enabled:

```bash
ln -s /etc/httpd/sites-available/com.yourdomain.nextcloud /etc/httpd/sites-enabled/
```

#### Створення Директорії

Як зазначено в конфігурації вище, необхідно створити _DocumentRoot_. Це можна зробити за допомогою:

```bash
mkdir -p /var/www/sub-domains/com.yourdomain.com/html
```

Тут буде встановлено наш екземпляр Nextcloud.

#### Налаштування PHP

Нам потрібно встановити часовий пояс для PHP. Для цього відкрийте php.ini за допомогою обраного вами текстового редактора:

```bash
vi /etc/opt/remi/php83/php.ini
```

Потім знайдіть рядок:

```php
;date.timezone =
```

Нам потрібно видалити примітку (++semicolon++) і встановити часовий пояс. Для нашого прикладу часового поясу ми б вказали:

```php
date.timezone = "America/Chicago"
```

Або

```php
date.timezone = "US/Central"
```

Потім збережіть і закрийте файл php.ini.

Зауважте, що для того, щоб все було незмінним, ваш часовий пояс у файлі _php.ini_ має відповідати налаштуванням часового поясу вашої машини. Ви можете дізнатися, що це означає, виконавши такі дії:

```bash
ls -al /etc/localtime
```

Це повинно показати вам щось на зразок цього, припускаючи, що ви встановили свій часовий пояс під час встановлення Rocky Linux і живете в центральному часовому поясі:

```bash
/etc/localtime -> /usr/share/zoneinfo/America/Chicago
```

#### Налаштування mariadb-сервера

Налаштуйте _mariadb-server_ для запуску під час завантаження:

```bash
systemctl enable mariadb
```

А потім почніть наступне:

```bash
systemctl restart mariadb
```

Знову ж таки, як зазначено раніше, ми будемо використовувати процедуру налаштування для посилення _mariadb-сервера_, знайдену [тут](../database/database_mariadb-server.md) для початкової конфігурації.

### Встановлення .zip

Наступні кілька кроків передбачають, що ви віддалено підключені до свого сервера Nextcloud через _ssh_ із відкритою віддаленою консоллю:

- Перейдіть на [веб-сайт Nextcloud](https://nextcloud.com/).
- Наведіть вказівник миші на `Get Nextcloud`, після чого відкриється спадне меню.
- Натисніть `Server Packages`.
- Клацніть правою кнопкою миші на `Download Nextcloud` і скопіюйте адресу посилання (точний синтаксис цього браузера різний).
- На віддаленій консолі на сервері Nextcloud введіть `wget`, а потім пробіл і вставте те, що ви щойно скопіювали. Ви повинні отримати щось на кшталт такого: `wget https://download.nextcloud.com/server/releases/nextcloud-21.0.1.zip` (зауважте, що версія може відрізнятися).
- Коли ви натиснете Enter, завантаження файлу .zip почнеться та завершиться досить швидко.

Після завершення завантаження розпакуйте zip-файл Nextcloud за допомогою:

```bash
unzip nextcloud-21.0.1.zip
```

### Копіювання вмісту та зміна дозволів

Після завершення етапу розпакування у вас має бути новий каталог у _/root_ під назвою «nextcloud». Перейдіть в цей каталог:

```bash
cd nextcloud
```

І скопіюйте або перемістіть вміст до нашого _DocumentRoot_:

```bash
cp -Rf * /var/www/sub-domains/com.yourdomain.nextcloud/html/
```

Або

```bash
mv * /var/www/sub-domains/com.yourdomain.nextcloud/html/
```

Тепер, коли все знаходиться там, де має бути, тепер ви маєте переконатися, що Аpache володіє каталогом. Для цього запустіть:

```bash
chown -Rf apache.apache /var/www/sub-domains/com.yourdomain.nextcloud/html
```

З міркувань безпеки ми також хочемо перемістити папку _data_ зсередини назовні _DocumentRoot_. Зробіть це за допомогою такої команди:

```bash
mv /var/www/sub-domains/com.yourdomain.nextcloud/html/data /var/www/sub-domains/com.yourdomain.nextcloud/
```

### Налаштування Nextcloud

Тепер саме цікаве! По-перше, переконайтеся, що ваші служби запущені. Якщо ви виконали наведені вище кроки, вони вже повинні бути запущені. У нас було кілька кроків між цими початковими запусками служби, тому давайте перезапустимо їх, щоб переконатися:

```bash
systemctl restart httpd
systemctl restart mariadb
```

Якщо все перезавантажиться і проблем немає, ви готові рухатися далі.

Щоб виконати початкову конфігурацію, ми хочемо фактично завантажити сайт у веб-браузер:

<http://your-server-hostname/> (замініть своїм справжнім іменем хоста)

Якщо припустити, що ви зробили все правильно, вам має відобразитися екран налаштування Nextcloud:

![екран входу в nextcloud](../images/nextcloud_screen.jpg)

Є кілька речей, які ми хочемо зробити інакше, ніж стандартні, які відображаються:

- У верхній частині веб-сторінки, де написано `Create an admin account`, встановіть користувача та пароль. Для цього документа ми вводимо `admin` і встановлюємо надійний пароль. Не забудьте зберегти це в безпечному місці (наприклад, у менеджері паролів), щоб не втратити! Навіть якщо ви ввели це поле, не натискайте ++enter++, доки ми не заповнимо всі поля налаштування!
- У розділі `Сховище та база даних` змініть розташування `Data folder` із кореня документа за замовчуванням на місце, куди ми перемістили папку даних раніше: `/var/www/sub-domains/com.yourdomain.nextcloud/data`.
- У розділі `Configure the database` змініть `SQLite` на `MySQL/MariaDB`, натиснувши цю кнопку.
- Введіть користувача та пароль root MariaDB, які ви встановили раніше, у поля `Database user` і `Database password`.
- У полі `Database name` введіть `nextcloud`.
- У полі `localhost` введіть <localhost:3306> (3306 — стандартний порт підключення _mariadb_).

Отримавши все це, натисніть `Finish Setup`, і ви повинні почати працювати.

Вікно браузера оновиться на деякий час, а потім зазвичай не перезавантажуватиме сайт. Введіть свою URL-адресу у вікні браузера ще раз, і ви повинні зіткнутися з першими сторінками за замовчуванням.

На даний момент ваш адміністратор уже ввійшов (або повинен бути) увійшов, і є кілька інформаційних сторінок, призначених для того, щоб пришвидшити роботу. «Інформаційна панель» — це те, що користувачі побачать під час першого входу. Адміністратор тепер може створювати інших користувачів, встановлювати інші програми та виконувати багато інших завдань.

Файл «Nextcloud Manual.pdf» є посібником користувача, щоб користувачі могли ознайомитися з наявними ресурсами. Адміністратор повинен прочитати або принаймні відсканувати основні моменти посібника адміністратора [На веб-сайті Nextcloud](https://docs.nextcloud.com/server/21/admin_manual/)

## Наступні кроки

На цьому етапі не забувайте, що це сервер, на якому ви зберігатимете дані компанії. Важливо заблокувати його за допомогою брандмауера, виконати [налаштування резервного копіювання](../backup/rsnapshot_backup.md), захистити сайт за допомогою [SSL](../security/generating_ssl_keys_lets_encrypt.md) і виконати будь-які інші обов’язки, необхідні для збереження ваших даних.

## Висновки

Рішення використовувати хмару компанії власними силами потребує ретельної оцінки. Для тих, хто вирішив, що локальне зберігання даних компанії краще, ніж зовнішній хмарний хост, Nextcloud є хорошою альтернативою.
