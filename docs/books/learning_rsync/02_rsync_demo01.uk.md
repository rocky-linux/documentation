---
title: rsync demo 01
author: tianci li
contributors: Steven Spencer
update: 2021-11-04
---

# Передмова

`rsync` має виконати автентифікацію користувача перед синхронізацією даних. **Існує два протоколи для автентифікації: протокол SSH і протокол rsync (порт протоколу rsync за замовчуванням — 873)**

* Метод перевірки протоколу SSH: використовуйте протокол SSH як основу для автентифікації користувача (тобто використовуйте для перевірки системного користувача та пароль самого GNU/Linux), а потім виконайте синхронізацію даних.
* Метод входу перевірки протоколу rsync: використовуйте протокол rsync для автентифікації користувача (користувачі системи не GNU/Linux, подібні до віртуальних користувачів vsftpd), а потім виконайте синхронізацію даних.

Перед конкретною демонстрацією синхронізації rsync вам потрібно використати команду `rsync`. У Rocky Linux 8 пакет rsync rpm встановлено за замовчуванням, а його версія — 3.1.3-12, як показано нижче:

```bash
[root@Rocky ~]# rpm -qa|grep rsync
rsync-3.1.3-12.el8.x86_64
```

```txt
Основний формат: rsync [параметри] оригінальне розташування цільове розташування
Часто використовувані варіанти:
-a: режим архіву, рекурсивний і зберігає атрибути об'єкта файлу, що еквівалентно -rlptgoD (без -H, -A, -X)
-v: відображає детальну інформацію про процес синхронізації
-z: стискає під час передачі файлів
-H: Зберігає файли жорстких посилань
-A: зберігає дозволи ACL
-X: зберігає дозволи chattr
-r: рекурсивний режим, включаючи всі файли в каталозі та підкаталогах
-l: усе ще зарезервовано для файлів символічних посилань
-p: дозвіл на збереження атрибутів файлів
-t: час для збереження атрибутів файлу
-g: зберігає групу, що належить атрибуту файлу (лише для суперкористувачів)
-o: зберігає власника атрибутів файлу (лише для суперкористувачів)
-D: зберігає файли пристрою та інші спеціальні файли
```

Особисте використання автором: `rsync -avz оригінальне розташування цільове розташування`

## Опис середовища

| Елемент               | Опис             |
| --------------------- | ---------------- |
| Rocky Linux 8(Server) | 192.168.100.4/24 |
| Fedora 34(client)     | 192.168.100.4/24 |

Ви можете використовувати Fedora 34 для завантаження та завантаження

```mermaid
graph LR;
RockyLinux8-->|pull/download|Fedora34;
Fedora34-->|push/upload|RockyLinux8;
```

graph LR; RockyLinux8-->|pull/download|Fedora34; Fedora34-->|push/upload|RockyLinux8

```mermaid
graph LR;
RockyLinux8-->|push/upload|Fedora34;
Fedora34-->|pull/download|RockyLinux8;
```

## Демонстрація на основі протоколу SSH

!!! підказка

    Тут і Rocky Linux 8, і Fedora 34 використовують користувача root для входу. Fedora 34 — це клієнт, а Rocky Linux 8 — сервер.

### витягти/завантажити

Оскільки він заснований на протоколі SSH, ми спочатку створюємо користувача на сервері:

```bash
[root@Rocky ~]# useradd testrsync
[root@Rocky ~]# passwd testrsync
```

На стороні клієнта ми витягуємо/завантажуємо його, а файл на сервері має назву /rsync/aabbcc

```bash
[root@fedora ~]# rsync -avz testrsync@192.168.100.4:/rsync/aabbcc /root
testrsync@192.168.100.4 ' s password:
receiving incremental file list
aabbcc
sent 43 bytes received 85 bytes 51.20 bytes/sec
total size is 0 speedup is 0.00
[root@fedora ~]# cd
[root@fedora ~]# ls
aabbcc
```
Передача пройшла успішно.

!!! підказка

    Якщо порт SSH сервера не є стандартним 22, ви можете вказати порт подібним чином ---`rsync -avz -e 'ssh -p [порт]' `.

### передати/відвантажити

```bash
[root@fedora ~]# touch fedora
[root@fedora ~]# rsync -avz /root/* testrsync@192.168.100.4:/rsync/
testrsync@192.168.100.4 ' s password:
sending incremental file list
anaconda-ks.cfg
fedora
rsync: mkstemp " /rsync/.anaconda-ks.cfg.KWf7JF " failed: Permission denied (13)
rsync: mkstemp " /rsync/.fedora.fL3zPC " failed: Permission denied (13)
sent 760 bytes received 211 bytes 277.43 bytes/sec
total size is 883 speedup is 0.91
rsync error: some files/attrs were not transferred (see previous errors) (code 23) at main.c(1330) [sender = 3.2.3]
```

**Відмовлено в дозволі підказки, як із цим впоратися?**

Спочатку перевірте права доступу до каталогу /rsync/. Очевидно, що дозволу "w" немає. Ми можемо використовувати `setfacl`, щоб надати дозвіл:

```bash
[root@Rocky ~ ] # ls -ld /rsync/
drwxr-xr-x 2 root root 4096 November 2 15:05 /rsync/
```

```bash
[root@Rocky ~ ] # setfacl -mu:testrsync:rwx /rsync/
[root@Rocky ~ ] # getfacl /rsync/
getfacl: Removing leading ' / ' from absolute path names
# file: rsync/
# owner: root
# group: root
user::rwx
user:testrsync:rwx
group::rx
mask::rwx
other::rx
```

Спробуйте ще раз, успіх!

```bash
[root@fedora ~ ] # rsync -avz /root/* testrsync@192.168.100.4:/rsync/
testrsync@192.168.100.4 ' s password:
sending incremental file list
anaconda-ks.cfg
fedora
sent 760 bytes received 54 bytes 180.89 bytes/sec
total size is 883 speedup is 1.08
```
