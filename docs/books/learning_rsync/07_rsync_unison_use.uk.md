---
title: Використання unison
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2021-11-06
---

# Коротко

Як ми вже згадували раніше, одностороння синхронізація використовує rsync + inotify-tools. У деяких особливих сценаріях використання може знадобитися двостороння синхронізація, яка потребує inotify-tools + unison.

## Підготовка середовища

* І для Rocky Linux 8, і для Fedora 34 потрібна компіляція вихідного коду та інсталяція **inotify-tools**, яка тут спеціально не розкривається.
* Обидві машини повинні мати автентифікацію без пароля, тут ми використовуємо протокол SSH
* [ocaml](https://github.com/ocaml/ocaml/) використовує v4.12.0, [unison](https://github.com/bcpierce00/unison/) використовує v2.51.4.

Після того, як середовище готове, його можна перевірити:

```bash
[root@Rocky ~]# inotifywa
inotifywait inotifywatch
[root@Rocky ~]# ssh -p 22 testrsync@192.168.100.5
Last login: Thu Nov 4 13:13:42 2021 from 192.168.100.4
[testrsync@fedora ~]$
```

```bash
[root@fedora ~]# inotifywa
inotifywait inotifywatch
[root@fedora ~]# ssh -p 22 testrsync@192.168.100.4
Last login: Wed Nov 3 22:07:18 2021 from 192.168.100.5
[testrsync@Rocky ~]$
```

!!! підказка

    Конфігураційні файли двох машин **/etc/ssh/sshd_config** мають бути відкриті <font color=red>PubkeyAuthentication yes</font>

## Встановлення Rocky Linux 8 unison

Ocaml — це мова програмування, і нижній рівень unison залежить від неї.

```bash
[root@Rocky ~]# wget -c https://github.com/ocaml/ocaml/archive/refs/tags/4.12.0.tar.gz
[root@Rocky ~]# tar -zvxf 4.12.0.tar.gz -C /usr/local/src/
[root@Rocky ~]# cd /usr/local/src/ocaml-4.12.0
[root@Rocky /usr/local/src/ocaml-4.12.0]# ./configure --prefix=/usr/local/ocaml && make world opt && make install
...
[root@Rocky ~]# ls /usr/local/ocaml/
bin lib man
[root@Rocky ~]# echo PATH=$PATH:/usr/local/ocaml/bin >> /etc/profile
[root@Rocky ~]# . /etc/profile
```

```bash
[root@Rocky ~]# wget -c https://github.com/bcpierce00/unison/archive/refs/tags/v2.51.4.tar.gz
[root@Rocky ~]# tar -zvxf v2.51.4.tar.gz -C /usr/local/src/
[root@Rocky ~]# cd /usr/local/src/unison-2.51.4/
[root@Rocky /usr/local/src/unison-2.51.4]# make UISTYLE=txt
...
[root@Rocky /usr/local/src/unison-2.51.4]# ls src/unison
src/unison
[root@Rocky /usr/local/src/unison-2.51.4] cp -p src/unison /usr/local/bin
```

## Встановлення Fedora 34 unison

Така сама операція.

```bash
[root@fedora ~]# wget -c https://github.com/ocaml/ocaml/archive/refs/tags/4.12.0.tar.gz
[root@feodora ~]# tar -zvxf 4.12.0.tar.gz -C /usr/local/src/
[root@fedora ~]# cd /usr/local/src/ocaml-4.12.0
[root@fedora /usr/local/src/ocaml-4.12.0]# ./configure --prefix=/usr/local/ocaml && make world opt && make install
...
[root@fedora ~]# ls /usr/local/ocaml/
bin lib man
[root@fedora ~]# echo PATH=$PATH:/usr/local/ocaml/bin >> /etc/profile
[root@fedora ~]#. /etc/profile
```

```bash
[root@fedora ~]# wget -c https://github.com/bcpierce00/unison/archive/refs/tags/v2.51.4.tar.gz
[root@fedora ~]# tar -zvxf v2.51.4.tar.gz -C /usr/local/src/
[root@fedora ~]# cd /usr/local/src/unison-2.51.4/
[root@fedora /usr/local/src/unison-2.51.4]# make UISTYLE=txt
...
[root@fedora /usr/local/src/unison-2.51.4]# ls src/unison
src/unison
[root@fedora /usr/local/src/unison-2.51.4]# cp -p src/unison /usr/local/bin
```


## Demo

**Наша вимога: каталог /dir1/ Rocky Linux 8 автоматично синхронізується з каталогом /dir2/ Fedora 34; водночас каталог /dir2/ Fedora 34 автоматично синхронізується з каталогом /dir1/ Rocky Linux 8**

### Налаштування Roсky Linux 8

```bash
[root@Rocky ~]# mkdir /dir1
[root@Rocky ~]# setfacl -m u:testrsync:rwx /dir1/
[root@Rocky ~]# vim /root/unison1.sh
#!/bin/bash
a="/usr/local/inotify-tools/bin/inotifywait -mrq -e create,delete,modify,move /dir1/"
b="/usr/local/bin/unison -batch /dir1/ ssh://testrsync@192.168.100.5//dir2"
$a | while read directory event file
do
    $b &>> /tmp/unison1.log
done
[root@Rocky ~]# chmod +x /root/unison1.sh
[root@Rocky ~]# bash /root/unison1.sh &
[root@Rocky ~]# jobs -l
```

### Налаштування Fedora 34

```bash
[root@fedora ~]# mkdir /dir2
[root@fedora ~]# setfacl -m u:testrsync:rwx /dir2/
[root@fedora ~]# vim /root/unison2.sh
#!/bin/bash
a="/usr/local/inotify-tools/bin/inotifywait -mrq -e create,delete,modify,move /dir2/"
b="/usr/local/bin/unison -batch /dir2/ ssh://testrsync@192.168.100.4//dir1"
$a | while read directory event file
do
    $b &>> /tmp/unison2.log
done
[root@fedora ~]# chmod +x /root/unison2.sh
[root@fedora ~]# bash /root/unison2.sh &
[root@fedora ~]# jobs -l
```

!!! підказка

    Для двосторонньої синхронізації повинні бути запущені сценарії обох машин, інакше буде повідомлено про помилку.

!!! підказка

    Якщо ви хочете запустити цей сценарій під час завантаження
    `[root@Rocky ~]# echo "bash /root/unison1.sh &" >> /etc/rc.local`
    `[root@Rocky ~]# chmod +x /etc/rc.local`

!!! підказка

    Якщо ви хочете зупинити відповідний процес цього сценарію, ви можете знайти його в команді `htop`, а потім **kill**
