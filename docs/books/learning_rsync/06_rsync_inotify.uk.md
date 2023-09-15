---
title: інсталяція та використання inotify-tools
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2021-11-04
---

# Компіляція та інсталяція

Виконайте наступні операції на сервері. У вашому середовищі можуть бути відсутні деякі залежні пакунки. Встановіть їх за допомогою: `dnf -y install autoconf automake libtool`

```bash
[root@Rocky ~]# wget -c https://github.com/inotify-tools/inotify-tools/archive/refs/tags/3.21.9.6.tar.gz
[root@Rocky ~]# tar -zvxf 3.21.9.6.tar.gz -C /usr/local/src/
[root@Rocky ~]# cd /usr/local/src/inotify-tools-3.21.9.6/
[root@Rocky /usr/local/src/inotify-tools-3.21.9.6]# ./autogen.sh && \
./configure --prefix=/usr/local/inotify-tools && \
make && \
make install
...
[root@Rocky ~]# ls /usr/local/inotify-tools/bin/
inotifywait inotifywatch
```

Додайте змінну середовища PATH, запишіть її у файл конфігурації та залиште її діяти постійно.

```bash
[root@Rocky ~]# vim /etc/profile
...
PATH=$PATH:/usr/local/inotify-tools/bin/
[root@Rocky ~]# . /etc/profile
```

**Чому б не використати пакет RPM inotify-tools зі сховища EPEL? А як використовувати вихідний код для компіляції та встановлення?**

Автор особисто вважає, що віддалена передача даних є питанням ефективності, особливо у виробничому середовищі, де існує велика кількість файлів, які потрібно синхронізувати, і один файл є особливо великим. Крім того, у новій версії буде виправлено деякі помилки та розширено функції, і, можливо, ефективність передачі нової версії буде вищою, тому я рекомендую встановлювати inotify-tools за вихідним кодом. Звичайно, це особиста пропозиція автора, не кожен користувач повинен її дотримуватися.

## Налаштування параметрів ядра

Ви можете налаштувати параметри ядра відповідно до потреб виробничого середовища. За замовчуванням у **/proc/sys/fs/inotity/** є три файли

```bash
[root@Rocky ~]# cd /proc/sys/fs/inotify/
[root@Rocky /proc/sys/fs/inotify]# cat max_queued_events ;cat max_user_instances ;cat max_user_watches
16384
128
28014
```

* max_queued_events-maximum розмір черги монітора, за замовчуванням 16384
* max_user_instances-the - максимальна кількість екземплярів моніторингу, за замовчуванням 128
* max_user_watches-the максимальна кількість файлів, що відстежуються на екземпляр, за замовчуванням 8192

Запишіть деякі параметри та значення в **/etc/sysctl.conf**, приклади наведені нижче. Потім скористайтеся `sysctl -p`, щоб файли набули чинності

```txt
fs.inotify.max_queued_events = 16384
fs.inotify.max_user_instances = 1024
fs.inotify.max_user_watches = 1048576
```

## Пов'язані команди

Інструмент inotify-tools має дві команди, а саме:
* **inotifywait** – для безперервного моніторингу, виведення результатів в реальному часі. Зазвичай він використовується з інструментом інкрементного резервного копіювання rsync. Оскільки це моніторинг файлової системи, його можна використовувати зі сценарієм. Пізніше ми представимо конкретне написання сценарію.
* **inotifywatch**- для короткострокового моніторингу, виведення результатів після виконання завдання.

`inotifywait` переважно має наступні параметри:

```txt
-m означає постійний моніторинг
-r Рекурсивний моніторинг
-q Спростити вихідну інформацію
-e вказує тип події даних моніторингу, кілька типів подій розділяються комами в статусі англійською мовою
```

Типи подій:

| Тип події     | Опис                                                                              |
| ------------- | --------------------------------------------------------------------------------- |
| access        | Доступ до вмісту файлу або каталогу                                               |
| modify        | Записується вміст файлу або каталогу                                              |
| attrib        | Атрибути файлу або каталогу змінено                                               |
| close_write   | Файл або каталог відкривається в режимі запису, а потім закривається              |
| close_nowrite | Файл або каталог закриваються після відкриття в режимі лише для читання           |
| close         | Незалежно від режиму читання/запису, файл або каталог закриваються                |
| open          | Файл або каталог відкрито                                                         |
| moved_to      | Файл або каталог переміщується до контрольованого каталогу                        |
| moved_from    | Файл або каталог переміщено з контрольованого каталогу                            |
| move          | Є файли або каталоги, які переміщуються до або видаляються з каталогу моніторингу |
| move_self     | Контрольований файл або каталог було переміщено                                   |
| create        | У контрольованому каталозі створено файли або каталоги                            |
| delete        | Файл або каталог у контрольованому каталозі видалено                              |
| delete_self   | Файл або каталог видалено                                                         |
| unmount       | Файлова система, що містить немонтовані файли або каталоги                        |

Приклад: `[root@Rocky ~]# inotifywait -mrq -e create,delete /rsync/`

## Демонстрація команди `inotifywait`

Введіть команду в перший термінал pts/0, і після натискання Enter вікно заблокується, вказуючи на те, що здійснюється моніторинг

```bash
[root@Rocky ~]# inotifywait -mrq -e create,delete /rsync/

```

У другому терміналі pts/1 перейдіть до каталогу /rsync/ і створіть файл.

```bash
[root@Rocky ~]# cd /rsync/
[root@Rocky /rsync]# touch inotify
```

Повернемося до першого терміналу pts/0, вихідна інформація така:

```bash
[root@Rocky ~]# inotifywait -mrq -e create,delete /rsync/
/rsync/ CREATE inotify
```

## Поєднання `inotifywait` і `rsync`

!!! підказка

    Ми працюємо на сервері Rocky Linux 8, використовуючи для демонстрації протокол SSH.

Для входу без пароля для автентифікації протоколу SSH зверніться до [rsync для входу без пароля](05_rsync_authentication-free_login.md), який тут не описано. Нижче наведено приклад вмісту сценарію bash. Ви можете додати різні параметри після команди відповідно до ваших потреб. Наприклад, ви також можете додати `--delete` після команди `rsync`.

```bash
#!/bin/bash
a="/usr/local/inotify-tools/bin/inotifywait -mrq -e modify,move,create,delete /rsync/"
b="/usr/bin/rsync -avz /rsync/* testfedora@192.168.100.5:/home/testfedora/"
$a | while read directory event file
    do
        $b &>> /tmp/rsync.log
    done
```

```bash
[root@Rocky ~]# chmod +x rsync_inotify.sh
[root@Rocky ~]# bash /root/rsync_inotify.sh &
```

!!! підказка

    Під час використання протоколу SSH для передачі даних синхронізації, якщо порт служби SSH цільової машини не 22, ви можете використовувати метод, подібний до цього——
    `b="/usr/bin/rsync -avz -e 'ssh -p [port-number]' /rsync/* testfedora@192.168.100.5:/home/testfedora/"`

!!! підказка

    Якщо ви хочете запустити цей сценарій під час завантаження
    `[root@Rocky ~]# echo "bash /root/rsync_inotify.sh &" >> /etc/rc.local`
    `[root@Rocky ~]# chmod +x /etc/rc.local`

Якщо ви використовуєте протокол rsync для синхронізації, вам потрібно налаштувати службу rsync цільової машини, будь ласка, зверніться до [demo rsync 02](03_rsync_demo02.md), [файл конфігурації rsync](04_rsync_configure.md), [rsync free Secret authentication login](05_rsync_authentication-free_login.md)
