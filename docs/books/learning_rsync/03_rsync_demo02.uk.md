---
title: rsync demo 02
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2021-11-04
---

# Демонстрація на основі протоколу rsync
У vsftpd є віртуальні користувачі (імітовані користувачі, налаштовані адміністратором), тому що використовувати анонімних і локальних користувачів небезпечно. Ми знаємо, що сервер, заснований на протоколі SSH, повинен забезпечувати наявність системи користувачів. Коли існує багато вимог до синхронізації, може знадобитися створити багато користувачів. Це, очевидно, не відповідає стандартам роботи та обслуговування GNU/Linux (чим більше користувачів, тим небезпечніше), у rsync з міркувань безпеки існує метод автентифікації протоколу rsync для входу в систему.

**Як це зробити?**

Просто запишіть відповідні параметри та значення у файл конфігурації. У Rocky Linux 8 вам потрібно вручну створити файл <font color=red>/etc/rsyncd.conf</font>.

```bash
[root@Rocky ~]# touch /etc/rsyncd.conf
[root@Rocky ~]# vim /etc/rsyncd.conf
```

Деякі параметри та значення цього файлу наведені нижче, ось [тут](04_rsync_configure.md) є інші описи параметрів:

| Елемент                                   | Опис                                                                                                                                                                                 |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| address = 192.168.100.4                   | IP-адреса, яку rsync прослуховує за замовчуванням                                                                                                                                    |
| port = 873                                | порт прослуховування за замовчуванням rsync                                                                                                                                          |
| pid file = /var/run/rsyncd.pid            | Розташування файлу процесу pid                                                                                                                                                       |
| log file = /var/log/rsyncd.log            | Розташування файлу журналу                                                                                                                                                           |
| [share]                                   | Назва спільного доступу                                                                                                                                                              |
| comment = rsync                           | Примітки або опис                                                                                                                                                                    |
| path = /rsync/                            | Розташування системного шляху, де він розташований                                                                                                                                   |
| read only = yes                           | yes означає лише читання, no означає читання та запис                                                                                                                                |
| dont compress = \*.gz \*.gz2 \*.zip | Які типи файлів не стискають його                                                                                                                                                    |
| auth users = li                           | Вмикає віртуальних користувачів і визначає назву віртуального користувача. Його потрібно створити самостійно                                                                         |
| secrets file = /etc/rsyncd_users.db       | Використовується для вказівки розташування файлу пароля віртуального користувача, який має закінчуватися на .db. Формат вмісту файлу: «Ім’я користувача: пароль», по одному на рядок |

!!! підказка

    Дозвіл доступу до файлу паролів має бути <font color=red>600</font>.

Запишіть деякий вміст файлу в <font color=red>/etc/rsyncd.conf</font>, а ім’я користувача та пароль – у /etc/rsyncd_users.db, дозвіл 600

```bash
[root@Rocky ~]# cat /etc/rsyncd.conf
address = 192.168.100.4
port = 873
pid file = /var/run/rsyncd.pid
log file = /var/log/rsyncd.log
[share]
comment = rsync
path = /rsync/
read 
dont compress = *.gz *.bz2 *.zip
auth users = li
secrets file = /etc/rsyncd_users.db
[root@Rocky ~]# ll /etc/rsyncd_users.db
-rw------- 1 root root 9 November 2 16:16 /etc/rsyncd_users.db
[root@Rocky ~]# cat /etc/rsyncd_users.db
li:13579
```

Можливо, вам знадобиться `dnf -y встановити rsync-daemon`, перш ніж ви зможете запустити службу: `systemctl start rsyncd.service`

```bash
[root@Rocky ~]# systemctl start rsyncd.service
[root@Rocky ~]# netstat -tulnp
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      691/sshd            
tcp        0      0 192.168.100.4:873       0.0.0.0:*               LISTEN      4607/rsync          
tcp6       0      0 :::22                   :::*                    LISTEN      691/sshd            
udp        0      0 127.0.0.1:323           0.0.0.0:*                           671/chronyd         
udp6       0      0 ::1:323                 :::*                                671/chronyd  
```

## витягти/завантажити

Створіть файл на сервері для перевірки: `[root@Rocky]# touch /rsync/rsynctest.txt`

Клієнт робить наступне:

```bash
[root@fedora ~]# rsync -avz li@192.168.100.4::share /root
Password:
receiving incremental file list
./
rsynctest.txt
sent 52 bytes received 195 bytes 7.16 bytes/sec
total size is 883 speedup is 3.57
[root@fedora ~]# ls
aabbcc anaconda-ks.cfg fedora rsynctest.txt
```

успіх! На додаток до написання вище на основі протоколу rsync, ви також можете написати так: `rsync://li@10.1.2.84/share`

## передати/відвантажити

```bash
[root@fedora ~]# touch /root/fedora.txt
[root@fedora ~]# rsync -avz /root/* li@192.168.100.4::share
Password:
sending incremental file list
rsync: [sender] read error: Connection reset by peer (104)
rsync error: error in socket IO (code 10) at io.c(784) [sender = 3.2.3]
```

Вам буде запропоновано, що помилка читання пов’язана з параметром «read only = yes» сервера. Змініть його на "no" та перезапустіть службу `[root@Rocky ~]# systemctl перезапустіть rsyncd.service`

Спробуйте ще раз, запитуючи дозвіл заборонено:

```bash
[root@fedora ~]# rsync -avz /root/* li@192.168.100.4::share
Password:
sending incremental file list
fedora.txt
rsync: mkstemp " /.fedora.txt.hxzBIQ " (in share) failed: Permission denied (13)
sent 206 bytes received 118 bytes 92.57 bytes/sec
total size is 883 speedup is 2.73
rsync error: some files/attrs were not transferred (see previous errors) (code 23) at main.c(1330) [sender = 3.2.3]
```

Наш віртуальний користувач тут <font color=red>li</font>, який за замовчуванням зіставлено з системним користувачем <font color=red>nobody</font>. Звичайно, ви можете змінити його на інших користувачів системи. In other words, nobody does not have write permission to the /rsync/ directory. Звичайно, ми можемо використати `[root@Rocky ~]# setfacl -mu:nobody:rwx /rsync/` , спробувати ще раз і вдасться.

```bash
[root@fedora ~]# rsync -avz /root/* li@192.168.100.4::share
Password:
sending incremental file list
fedora.txt
sent 206 bytes received 35 bytes 96.40 bytes/sec
total size is 883 speedup is 3.66
```
