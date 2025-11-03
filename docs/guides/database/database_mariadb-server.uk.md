---
title: Сервер бази даних MariaDB
author: Steven Spencer
contributors: Ezequiel Bruni, William Perron, Ganna Zhyrnova, Joseph Brinkman
tested_with: 8.5, 8.6, 9.0, 9.2, 10.0
tags:
  - бази даних
  - mariadb
---

## Передумови

- Сервер Rocky Linux
- Вміння працювати з редактором командного рядка (у цьому прикладі ми використовуємо *vi*)
- Високий рівень комфорту з видачею команд із командного рядка, переглядом журналів та іншими загальними обов’язками системного адміністратора
- Розуміння баз даних *mariadb-server* є корисним
- Усі команди виконуються від імені користувача root або *sudo*

## Вступ

*Mariadb-сервер* і його клієнт *mariadb* є альтернативою *mysql-server* і *mysql* з відкритим вихідним кодом і мають спільну структуру команд. *mariadb-server* можна знайти запущеним на багатьох веб-серверах завдяки популярній

Wordpress CMS</1 > яка цього вимагає. Однак ця база даних має багато інших застосувань.</p> 

Якщо ви бажаєте використовувати це разом з іншими інструментами для посилення безпеки веб-сервера, поверніться до [посібника Apache Hardened Web Server](../web/apache_hardened_webserver/index.md).



## Встановлення mariadb-сервера

Вам потрібно встановити *mariadb-server*:



```bash
dnf install mariadb-server
```




## Захист mariadb-сервера

Щоб посилити безпеку *mariadb-сервера*, вам потрібно запустити сценарій, але перед тим, як це зробити, вам потрібно ввімкнути та запустити mariadb:



```bash
systemctl enable --now mariadb
```


Далі виконайте цю команду:



```bash
mysql_secure_installation
```


Це викликає діалогове вікно:



```text
NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user. If you've just installed MariaDB, and
haven't set the root password yet, you should just press enter here.

Enter current password for root (enter for none):
```


Оскільки це абсолютно нова інсталяція, пароль root не встановлено. Просто натисніть тут ++enter++.

Наступна частина діалогу продовжується:



```text
Setting the root password or using the unix_socket ensures that nobody
can log into the MariaDB root user without the proper authorisation.

Ви вже захищили свій root-акаунт, тому можете сміливо відповісти «н».

Switch to unix_socket authentication [Y/n]
```


Відповідь ++"n"++ та натискання ++enter++



```text
Ви вже захищили свій root-акаунт, тому можете сміливо відповісти «н».

Змінити пароль root? [Y/n]
```


Насправді, ви не встановили пароль для користувача root **АБО** використали автентифікацію `unix_socket`, тому дайте відповідь ++"Y"++ тут ​​і натисніть ++enter++.

Відкриється діалогове вікно пароля:



```text
New password:
Re-enter new password:
```


Введіть вибраний пароль, а потім підтвердіть його, ввівши ще раз. Якщо це буде успішно, ви отримаєте таке діалогове вікно:



```text
Password updated successfully!
Reloading privilege tables..
 ... Success!
```


Збережіть цей пароль у менеджері паролів або безпечному місці зберігання.

Далі діалогове вікно має справу з анонімним користувачем:



```text
By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them. This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n]
```


Відповідь тут "Y", тому просто натисніть ++enter++, щоб прийняти значення за умовчанням.

Діалогове вікно переходить до розділу, що стосується дозволу користувача root входити віддалено:



```text
... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n]
```


root потрібен лише локально на машині. Тому також прийміть це значення за замовчуванням, натиснувши ++enter++.

Потім діалогове вікно переходить до «тестової» бази даних, яка автоматично встановлюється за допомогою *mariadb-server*:



```text
... Success!


By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n]
```


Знову ж таки, відповідь є типовою, тому просто натисніть ++enter++, щоб видалити її.

Нарешті, діалогове вікно запитає вас, чи бажаєте ви перезавантажити привілеї:



```text
- Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n]
```


Знову ж таки, просто натисніть ++enter++, щоб зробити це. Якщо все піде добре, ви повинні отримати це повідомлення:



```text
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```


Тепер MariaDB має бути готова до використання.



## Висновок

Сервер бази даних, такий як *mariadb-server*, можна використовувати для багатьох цілей. Через популярність [CMS Wordpress](https://wordpress.org) її часто можна знайти на веб-серверах. Однак перед тим, як запускати базу даних у виробництві, доцільно посилити її захист.
