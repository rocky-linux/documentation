---
title: WordPress на LAMP
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.2
---

## Передумови

 - Система Rocky Linux 9.x
 - привілеї sudo

## Вступ

WordPress — це система керування вмістом (CMS) із відкритим вихідним кодом, яка відома своєю [відомою 5-хвилинною установкою](https://developer.wordpress.org/advanced-administration/before-install/howto-install/). Зазвичай його розгортають у стеку LAMP (Linux, Apache, MySQL, PHP). Хоча ефективні локальні засоби розробки, такі як [XAMPP](https://www.apachefriends.org/), [Vagrant](https://www.vagrantup.com/) і [wp-env](https:// developer.wordpress.org/block-editor/reference-guides/packages/packages-env/) широко доступні, ручне встановлення WordPress на LAMP для локальної розробки забезпечує цінний практичний підхід для початківців, які прагнуть глибшого розуміння.

Цей посібник припускає, що у вас уже встановлено Rocky Linux 9.x, таким чином охоплюючи частину «L» стеку LAMP.

У цьому посібнику описано, як вручну встановити WordPress зі стеком LAMP на комп’ютері Rocky Linux 9. Це не посібник, готовий до виробництва, а відправна точка для розвитку. Налаштування LAMP, включене в цей посібник, не рекомендоване для будь-чого, окрім локальної розробки, без попереднього вжиття належних заходів безпеки, які вимагають додаткового налаштування.

## Оновлення системних пакетів

Переконайтеся, що пакети вашої системи оновлені:

```bash
    sudo dnf upgrade -y
```

## Встановлення Apache

Apache — це веб-сервер, який обслуговуватиме ваш сайт WordPress. Встановіть його за допомогою:

```bash
    sudo dnf install httpd -y
```

## Увімкніть Apache для запуску під час завантаження

Після встановлення Apache увімкніть його, щоб він запускався автоматично під час завантаження:

```bash
    sudo systemctl enable --now httpd
```

## Встановлення MariaDB

WordPress зберігає динамічний вміст у базі даних MySQL. MariaDB — це розгалуження MySQL з відкритим кодом. Встановіть його за допомогою:

```bash
    sudo dnf install mariadb-server -y
```

## Увімкніть сервер MariaDB

Після встановлення MariaDB увімкніть його, щоб він запускався автоматично під час завантаження:

```bash
    sudo systemctl enable --now mariadb
```

## Безпека MariaDB

Запустіть сценарій mysql_secure_installation:

```bash
    sudo mysql_secure_installation --use-default
```

Цей сценарій виконує наступне:

1. Встановлює пароль root, якщо його ще не встановлено

2. Видаляє анонімних користувачів

3. Забороняє віддалений вхід root

4. Прибирає доступ до тестової бази даних

5. Перезавантажує привілеї

## Встановлення PHP

PHP — це програмування, яке використовується для взаємодії з базою даних MySQL і виконання динамічних дій. Він широко використовується в ядрі, темах і плагінах WordPress.

Встановіть PHP і необхідні пакети для підключення до MySQL:

```bash
    sudo dnf install php php-mysqlnd php-gd php-xml php-mbstring
```

Після інсталяції PHP необхідно перезавантажити Apache, щоб інсталювати його як модуль Apache, і прочитати файли конфігурації:

## Перезапустіть Apache

```bash
    sudo systemctl restart httpd
```

## Отримайте та розпакуйте WordPress

Використовуйте `curl`, щоб завантажити останню версію WordPress:

```bash
    curl -O https://wordpress.org/latest.tar.gz
```

Користувач `tar`, щоб розпакувати завантажений архів:

```bash
    tar -xzvf latest.tar.gz
```

Скопіюйте файли WordPress у загальнодоступний каталог Apache за замовчуванням:

```bash
   sudo cp -r wordpress/* /var/www/html 
```

## Встановіть власника

Зробити Apache власником файлів:

```bash
    sudo chown -R apache:apache /var/www/html/
```

Встановіть дозволи для файлів WordPress:

## Встановити дозволи

```bash
    sudo chmod -R 755 /var/www/html/
```

Увійдіть до MySQL CLI:

## Налаштувати базу даних

```bash
    sudo mysql -u root -p
```

Створіть нову базу даних для свого сайту WordPress:

## Створіть нову базу даних

```bash
    CREATE DATABASE LOCALDEVELOPMENTENV;
```

Створіть користувача з паролем для вашої бази даних:

!!! note "Примітка"

```
Настійно рекомендується використовувати надійний пароль.
```

## Створіть нового користувача та пароль

```bash
    CREATE USER 'admin'@'localhost' IDENTIFIED BY 'password';
```

Надайте всі привілеї вашої бази даних WordPress щойно створеному користувачеві:

```bash
    GRANT ALL PRIVILEGES ON LOCALDEVELOPMENTENV.* TO 'admin'@'localhost';
```

Очищення привілеїв для забезпечення застосування змін:

```bash
    FLUSH PRIVILEGES;
```

Вийдіть із MySQL CLI:

```bash
    EXIT;
```

## Налаштування WordPress

Скопіюйте шаблон `wp-config-sample.php` і перейменуйте його:

```bash
    sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
```

Відкрийте файл `wp-config.php` за допомогою вибраного вами текстового редактора:

```bash
    sudo vi /var/www/html/wp-config.php
```

## Замінити налаштування бази даних

Ви повинні визначити такі константи у своєму файлі `wp-config.php`:

```bash
    define ('DB_NAME', 'LOCALDEVELOPMENTENV');
    define ('DB_USER', 'admin');
    define ('DB_PASSWORD', 'password');
```

## Налаштування брандмауера

Відкрийте служби HTTP та HTTPS у своєму брандмауері:

```bash
    sudo firewall-cmd --add-service=http --add-service=https
```

Перезавантажте `firewalld`, щоб переконатися, що зміни набули чинності:

```bash
    sudo systemctl reload firewalld
```

## Налаштування SELinux

Щоб дозволити Apache читати та записувати ваші файли WordPress, виконайте цю команду:

```bash
   chcon -R -t httpd_sys_rw_content_t /var/www/html/ 
```

Щоб дозволити Apache створювати мережеві підключення, виконайте цю команду:

!!! Note "Примітка"

```
Прапорець `-P` робить цю конфігурацію постійною під час перезавантаження
```

```bash
    setsebool -P httpd_can_network_connect true
```

## Висновок

Щоб завершити інсталяцію, тепер ви зможете підключитися до WordPress через мережу за допомогою імені хоста сервера або приватної IP-адреси. Пам’ятайте, що це налаштування насамперед призначено для цілей місцевого розвитку. Для використання у виробництві вам потрібно налаштувати наступне: встановити доменне ім’я, установити сертифікат SSL, посилити сервер Apache, точно налаштувати конфігурацію SELinux і створити резервні копії. Тим не менш, дотримання цього посібника створило надійну відправну точку для розробки WordPress на стеку LAMP.
