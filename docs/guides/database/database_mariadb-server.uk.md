---
title: Сервер бази даних MariaDB
author: Steven Spencer
contributors: Ezequiel Bruni, William Perron
tested_with: 8.5, 8.6, 9.0
tags:
  - бази даних
  - mariadb
---

# Сервер бази даних MariaDB

## Передумови

* Сервер Rocky Linux
* Вміння працювати з редактором командного рядка (у цьому прикладі ми використовуємо _vi_)
* Високий рівень комфорту з видачею команд із командного рядка, переглядом журналів та іншими загальними обов’язками системного адміністратора
* Розуміння баз даних _mariadb-server_ є корисним
* Усі команди виконуються від імені користувача root або _sudo_

## Вступ

_Mariadb-сервер_ і його клієнт _mariadb_ є альтернативою _mysql-server_ і _mysql_ з відкритим вихідним кодом і мають спільну структуру команд. _mariadb-server_ можна знайти запущеним на багатьох веб-серверах завдяки популярній [Wordpress CMS](https://wordpress.org/) яка цього вимагає. Однак ця база даних має багато інших застосувань.

Якщо ви бажаєте використовувати це разом з іншими інструментами для посилення безпеки веб-сервера, поверніться до [посібника Apache Hardened Web Server](../web/apache_hardened_webserver/index.md).

## Встановлення mariadb-сервера

Вам потрібно встановити _mariadb-server_:

`dnf install mariadb-server`

## Захист mariadb-сервера

Щоб посилити безпеку _mariadb-server_, нам потрібно запустити сценарій, але перед тим, як це зробити, нам потрібно ввімкнути та запустити mariadb:

`systemctl enable mariadb`

І потім:

`systemctl start mariadb`

Далі виконайте цю команду:

`mysql_secure_installation`

!!! tip "Підказка"

    Версія MariaDB-сервера, яка ввімкнена за замовчуванням у Rocky Linux 8.5, це 10.3.32. Ви можете встановити 10.5.13, увімкнувши модуль:

    ```
    dnf module enable mariadb:10.5
    ```


    Потім ми встановлюємо `mariadb`. Починаючи з версії 10.4.6 MariaDB, доступні спеціальні команди MariaDB, які можна використовувати замість старих команд із префіксом `mysql`. До них відноситься раніше згадана `mysql_secure_installation`, яку тепер можна викликати за допомогою версії MariaDB `mariadb-secure-installation`.

Це викликає діалогове вікно:

```
NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user.  If you've just installed MariaDB, and
you haven't set the root password yet, the password will be blank,
so you should just press enter here.

Enter current password for root (enter for none):
```

Оскільки це абсолютно нова інсталяція, пароль адміністратора не встановлено. Тож просто натисніть тут Enter.

Наступна частина діалогу продовжується:

```
OK, successfully used password, moving on...

Setting the root password ensures that nobody can log into the MariaDB
root user without the proper authorisation.

Set root password? [Y/n]
```

Ви абсолютно _обов'язково_ бажаєте встановити пароль root. Ви захочете з’ясувати, що це має бути, і задокументувати це десь у менеджері паролів, щоб за потреби можна було його відкрити. Почніть із натискання «Enter», щоб прийняти «Y» за умовчанням. Відкриється діалогове вікно пароля:

```
New password:
Re-enter new password:
```

Введіть вибраний пароль, а потім підтвердіть його, ввівши ще раз. Якщо це буде успішно, ви отримаєте таке діалогове вікно:

```
Password updated successfully!
Reloading privilege tables..
 ... Success!
```

Далі діалогове вікно має справу з анонімним користувачем:

```
By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n]
```

Відповідь тут "Y", тому просто натисніть "Enter", щоб прийняти значення за умовчанням.

Діалогове вікно переходить до розділу, що стосується дозволу користувача root входити віддалено:

```
... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n]
```

root потрібен лише локально на машині. Тому також прийміть це значення за замовчуванням, натиснувши «Enter».

Потім діалогове вікно переходить до «тестової» бази даних, яка автоматично встановлюється за допомогою _mariadb-server_:

```
... Success!


By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n]
```

Знову ж таки, відповідь є типовою, тому просто натисніть «Enter», щоб видалити її.

Нарешті, діалогове вікно запитає вас, чи бажаєте ви перезавантажити привілеї:

```
- Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n]
```

Знову ж таки, просто натисніть «Enter», щоб зробити це. Якщо все піде добре, ви повинні отримати це повідомлення:

```
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```

Тепер MariaDB має бути готова до використання.

### Зміни Rocky Linux 9.0

Rocky Linux 9.0 використовує `mariadb-server-10.5.13-2` як версію mariadb-server за умовчанням. Починаючи з версії 10.4.3, на сервері автоматично вмикається новий плагін, який змінює діалогове вікно `mariadb-secure-installation`. Цей плагін є автентифікацією `unix-socket`. [Ця стаття](https://mariadb.com/kb/en/authentication-plugin-unix-socket/) добре пояснює нову функцію. По суті, використання автентифікації `unix-socket` використовує облікові дані користувача, який увійшов у систему, для доступу до бази даних. Це робить так, що якщо користувач root, наприклад, увійшов, а потім використав `mysqladmin` для створення або видалення бази даних (або будь-якої іншої функції), для доступу не потрібен пароль. Те саме працює з `mysql`. Це також означає, що немає пароля для віддаленого зламу. Це залежить від безпеки користувачів, налаштованих на сервері для захисту всіх баз даних.

Друге діалогове вікно під час `mariadb-secure-installation` після встановлення пароля для адміністратора:

```
Switch to unix_socket authentication Y/n
```

За замовчуванням тут є «Y», але навіть якщо ви відповідаєте «n», коли плагін увімкнено, пароль для користувача не запитуватиметься, принаймні через інтерфейс командного рядка. Ви можете вказати пароль або не вказати пароль, і вони обидва працюють:

```
mysql

MariaDB [(none)]>
```

```
mysql -p
Enter password:

MariaDB [(none)]>
```

Щоб дізнатися більше про цю функцію, перейдіть за посиланням вище. Існує спосіб вимкнути цей плагін і повернути пароль як обов’язкове поле, яке також детально описано в цьому посиланні.

## Висновок

Сервер бази даних, такий як _mariadb-server_, можна використовувати для багатьох цілей. Через популярність CMS Wordpress її часто можна знайти на веб-серверах. Однак перед тим, як запускати базу даних у виробництві, доцільно посилити її захист.
