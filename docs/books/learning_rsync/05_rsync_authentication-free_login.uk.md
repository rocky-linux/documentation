---
title: rsync автентифікація без пароля
author: tianci li
contributors: Steven Spencer
update: 2021-11-04
---

# Передмова

З короткого [опису rsync](01_rsync_overview.md) ми знаємо, що rsync — це інструмент інкрементної синхронізації. Кожного разу, коли виконується команда `rsync`, дані можуть бути синхронізовані один раз, але дані не можуть бути синхронізовані в реальному часі. Як це зробити?

За допомогою inotify-tools цей програмний інструмент може реалізувати односторонню синхронізацію в реальному часі. Оскільки це синхронізація даних у реальному часі, необхідною умовою є вхід без автентифікації за паролем.

**Незалежно від того, чи це протокол rsync чи протокол SSH, обидва можуть досягти входу без пароля.**

## Вхід для аутентифікації протоколу SSH без пароля

Спершу згенеруйте пару відкритого та закритого ключів на клієнті та продовжуйте натискати Enter після введення команди. Пара ключів зберігається в каталозі <font color=red>/root/.ssh/</font>.

```bash
[root@fedora ~]# ssh-keygen -t rsa -b 2048
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /root/.ssh/id_rsa
Your public key has been saved in /root/.ssh/id_rsa.pub
The key fingerprint is:
SHA256: TDA3tWeRhQIqzTORLaqy18nKnQOFNDhoAsNqRLo1TMg root@fedora
The key's randomart image is:
+---[RSA 2048]----+
|O+. +o+o. .+. |
|BEo oo*....o. |
|*o+o..*.. ..o |
|.+..o. = o |
|o o S |
|. o |
| o +. |
|....=. |
| .o.o. |
+----[SHA256]-----+
```

Потім скористайтеся командою `scp`, щоб завантажити файл відкритого ключа на сервер. Наприклад, я завантажую цей відкритий ключ користувачу **testrsync**

```bash
[root@fedora ~]# scp -P 22 /root/.ssh/id_rsa.pub root@192.168.100.4:/home/testrsync/
```

```bash
[root@Rocky ~]# cat /home/testrsync/id_rsa.pub >> /home/testrsync/.ssh/authorized_keys
```

Спробуйте увійти без секретної автентифікації, успіх!

```bash
[root@fedora ~]# ssh -p 22 testrsync@192.168.100.4
Last login: Tue Nov 2 21:42:44 2021 from 192.168.100.5
[testrsync@Rocky ~]$
```

!!! підказка

    Файл конфігурації сервера **/etc/ssh/sshd_config** має бути відкритий <font color=red>PubkeyAuthentication yes</font>

## протокол rsync автентифікація без пароля

На стороні клієнта служба rsync готує змінну середовища для системного **RSYNC_PASSWORD**, яка за замовчуванням порожня, як показано нижче:

```bash
[root@fedora ~]# echo "$RSYNC_PASSWORD"

[root@fedora ~]#
```

Якщо ви бажаєте отримати вхід із автентифікацією без пароля, вам потрібно лише призначити значення цій змінній. Призначене значення — це пароль, попередньо встановлений для віртуального користувача <font color=red>li</font>. Одночасно оголосите цю змінну як глобальну.

```bash
[root@Rocky ~]# cat /etc/rsyncd_users.db
li:13579
```

```bash
[root@fedora ~]# export RSYNC_PASSWORD=13579
```

Спробуйте, успіх! Тут не з’являються нові файли, тому список переданих файлів не відображається.

```bash
[root@fedora ~]# rsync -avz li@192.168.100.4::share /root/
receiving incremental file list
./

sent 30 bytes received 193 bytes 148.67 bytes/sec
total size is 883 speedup is 3.96
```

!!! підказка

    Ви можете записати цю змінну в **/etc/profile**, щоб вона стала чинною. Вміст: `export RSYNC_PASSWORD=13579`
