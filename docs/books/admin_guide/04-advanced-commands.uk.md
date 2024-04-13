---
title: Розширені команди Linux
---

# Розширені команди для користувачів Linux

Розширені команди забезпечують більше налаштувань і елементів керування в більш спеціалізованих ситуаціях, коли ви ознайомитеся з основними командами.

****

**Цілі**: у цьому розділі майбутні адміністратори Linux дізнаються про:

:heavy_check_mark: деякі корисні команди, не висвітлені в попередньому розділі. :heavy_check_mark: деякі розширені команди.

:checkered_flag: **Команди користувача**, **Linux**

**Знання**: :star: **Складність**: :star: :star: :star:

**Час читання**: 20 хвилин

****

## Команда `uniq`

Команда `uniq` є дуже потужною командою, яка використовується з командою `sort`, особливо для аналізу файлів журналу. Це дозволяє сортувати та відображати записи, видаляючи дублікати.

Щоб проілюструвати, як працює команда `uniq`, скористаємося файлом `firstnames.txt`, який містить список імен:

```text
antoine
xavier
steven
patrick
xavier
antoine
antoine
steven
```

!!! Примітка

    `uniq` вимагає, щоб вхідний файл був відсортований перед запуском, оскільки він порівнює лише послідовні рядки.

Без аргументів команда `uniq` не відображатиме ідентичні рядки, які слідують один за одним у файлі `firstnames.txt`:

```bash
$ sort firstnames.txt | uniq
antoine
patrick
steven
xavier
```

Щоб відобразити лише ті рядки, які з’являються лише один раз, скористайтеся параметром `-u`:

```bash
$ sort firstnames.txt | uniq -u
patrick
```

І навпаки, щоб відобразити лише ті рядки, які з’являються у файлі щонайменше двічі, скористайтеся параметром `-d`:

```bash
$ sort firstnames.txt | uniq -d
antoine
steven
xavier
```

Щоб просто видалити рядки, які з’являються лише один раз, скористайтеся опцією `-D`:

```bash
$ sort firstnames.txt | uniq -D
antoine
antoine
antoine
steven
steven
xavier
xavier
```

Нарешті, щоб підрахувати кількість входжень кожного рядка, використовуйте параметр `-c`:

```bash
$ sort firstnames.txt | uniq -c
      3 antoine
      1 patrick
      2 steven
      2 xavier
```

```bash
$ sort firstnames.txt | uniq -cd
      3 antoine
      2 steven
      2 xavier
```

## Команда `xargs`

Команда `xargs` дозволяє створювати та виконувати командні рядки зі стандартного введення.

Команда `xargs` зчитує зі стандартного вводу аргументи, розділені пробілами або переводами рядків, і виконує команду (за замовчуванням `/bin/echo`) один або кілька разів, використовуючи початкові аргументи, за якими йдуть аргументи, прочитані зі стандартного введення.

Першим і найпростішим прикладом може бути наступне:

```bash
$ xargs
use
of
xargs
<CTRL+D>
use of xargs
```

Команда `xargs` очікує введення зі стандартного введення **stdin**. Введено три рядки. Кінець введення користувача вказується в `xargs` послідовністю натискань клавіш ++ctrl+d++. Потім `xargs` виконує команду за замовчуванням `echo`, за якою слідують три аргументи, що відповідають введеним користувачам, а саме:

```bash
$ echo "use" "of" "xargs"
use of xargs
```

Можна вказати команду, яку буде виконувати `xargs`.

У наступному прикладі `xargs` виконає команду `ls -ld` для набору папок, указаних у стандартному вводі:

```bash
$ xargs ls -ld
/home
/tmp
/root
<CTRL+D>
drwxr-xr-x. 9 root root 4096  5 avril 11:10 /home
dr-xr-x---. 2 root root 4096  5 avril 15:52 /root
drwxrwxrwt. 3 root root 4096  6 avril 10:25 /tmp
```

На практиці команда `xargs` виконала команду `ls -ld /home /tmp /root`.

Що станеться, якщо команда, яку потрібно виконати, не приймає кілька аргументів, як команда `find`?

```bash
$ xargs find /var/log -name
*.old
*.log
find: paths must precede expression: *.log
```

Команда `xargs` намагалася виконати команду `find` із кількома аргументами за параметром `-name`, що спричинило `find` створення помилки:

```bash
$ find /var/log -name "*.old" "*.log"
find: paths must precede expression: *.log
```

У цьому випадку командою `xargs` потрібно примусово виконати команду `find` кілька разів (один раз на рядок, введений як стандартний ввід). Параметр `-L` із наступним **цілим числом** дозволяє вказати максимальну кількість записів, які потрібно обробити командою одночасно:

```bash
$ xargs -L 1 find /var/log -name
*.old
/var/log/dmesg.old
*.log
/var/log/boot.log
/var/log/anaconda.yum.log
/var/log/anaconda.storage.log
/var/log/anaconda.log
/var/log/yum.log
/var/log/audit/audit.log
/var/log/anaconda.ifcfg.log
/var/log/dracut.log
/var/log/anaconda.program.log
<CTRL+D>
```

Щоб вказати обидва аргументи в одному рядку, скористайтеся параметром `-n 1`:

```bash
$ xargs -n 1 find /var/log -name
*.old *.log
/var/log/dmesg.old
/var/log/boot.log
/var/log/anaconda.yum.log
/var/log/anaconda.storage.log
/var/log/anaconda.log
/var/log/yum.log
/var/log/audit/audit.log
/var/log/anaconda.ifcfg.log
/var/log/dracut.log
/var/log/anaconda.program.log
<CTRL+D>
```

Приклад резервного копіювання за допомогою `tar` на основі пошуку:

```bash
$ find /var/log/ -name "*.log" -mtime -1 | xargs tar cvfP /root/log.tar
$ tar tvfP /root/log.tar
-rw-r--r-- root/root      1720 2017-04-05 15:43 /var/log/boot.log
-rw-r--r-- root/root    499270 2017-04-06 11:01 /var/log/audit/audit.log
```

Особливістю команди `xargs` є те, що вона розміщує вхідний аргумент у кінці викликаної команди. Це дуже добре працює з наведеним вище прикладом, оскільки передані файли формуватимуть список файлів, які потрібно додати до архіву.

Використовуючи приклад команди `cp`, щоб скопіювати список файлів у каталозі, цей список файлів буде додано в кінці команди... але що команда `cp</ code> очікує в кінці команди призначення. Щоб зробити це, скористайтеся опцією <code>-I`, щоб розмістити вхідні аргументи не в кінці рядка.

```bash
find /var/log -type f -name "*.log" | xargs -I % cp % /root/backup
```

Параметр `-I` дозволяє вказати символ (символ `%` у наведеному вище прикладі), куди будуть розміщені вхідні файли для `xargs`.

## Пакет `yum-utils`

Пакет `yum-utils` — це набір утиліт, створених для `yum` різними авторами, які роблять його зручнішим і потужнішим у використанні.

!!! note "Примітка"

    Хоча `yum` було замінено на `dnf` у Rocky Linux 8, назва пакета залишилася `yum-utils`, хоча його також можна встановити як `dnf-utils`. Це класичні утиліти YUM, реалізовані як прокладки CLI поверх DNF для підтримки зворотної сумісності з `yum-3`.

Ось кілька прикладів цих утиліт.

### Команда `repoquery`

Команда `repoquery` використовується для запиту пакетів у сховищі.

Приклади використання:

* Відображення залежностей пакета (це може бути пакет програмного забезпечення, який було встановлено або не встановлено), еквівалентно `dnf deplist <package-name>`

```bash
repoquery --requires <package-name>
```

* Відображати файли, надані встановленим пакетом (не працює для пакетів, які не встановлено), еквівалентно `rpm -ql <package-name>`

```bash
$ repoquery -l yum-utils
/etc/bash_completion.d
/etc/bash_completion.d/yum-utils.bash
/usr/bin/debuginfo-install
/usr/bin/find-repos-of-install
/usr/bin/needs-restarting
/usr/bin/package-cleanup
/usr/bin/repo-graph
/usr/bin/repo-rss
/usr/bin/repoclosure
/usr/bin/repodiff
/usr/bin/repomanage
/usr/bin/repoquery
/usr/bin/reposync
/usr/bin/repotrack
/usr/bin/show-changed-rco
/usr/bin/show-installed
/usr/bin/verifytree
/usr/bin/yum-builddep
/usr/bin/yum-config-manager
/usr/bin/yum-debug-dump
/usr/bin/yum-debug-restore
/usr/bin/yum-groups-manager
/usr/bin/yumdownloader
…
```

### Команда `yumdownloader`

Команда `yumdownloader` завантажує пакети RPM зі сховищ.  Еквівалент `dnf download --downloadonly --downloaddir ./ package-name`

!!! note "Примітка"

    Ця команда дуже корисна для швидкого створення локального сховища з кількома обертами за хвилину!

Приклад: `yumdownloader` завантажить пакет rpm _samba_ та всі його залежності:

```bash
$ yumdownloader --destdir /var/tmp --resolve samba
or
$ dnf download --downloadonly --downloaddir /var/tmp  --resolve  samba
```

| Опції       | Коментарі                                             |
| ----------- | ----------------------------------------------------- |
| `--destdir` | Завантажені пакети будуть збережені у вказаній папці. |
| `--resolve` | Також завантажує залежності пакетів.                  |

## Пакети `psmisc`

Пакет `psmisc` містить утиліти для керування системними процесами:

* `pstree`: команда `pstree` відображає поточні процеси в системі у вигляді дерева.
* `killall`: команда `killall` надсилає сигнал завершення всім процесам, визначеним за назвою.
* `fuser`: команда `fuser` визначає `PID` процесів, які використовують вказані файли або файлові системи.

Приклади:

```bash
$ pstree
systemd─┬─NetworkManager───2*[{NetworkManager}]
        ├─agetty
        ├─auditd───{auditd}
        ├─crond
        ├─dbus-daemon───{dbus-daemon}
        ├─firewalld───{firewalld}
        ├─lvmetad
        ├─master─┬─pickup
        │        └─qmgr
        ├─polkitd───5*[{polkitd}]
        ├─rsyslogd───2*[{rsyslogd}]
        ├─sshd───sshd───bash───pstree
        ├─systemd-journal
        ├─systemd-logind
        ├─systemd-udevd
        └─tuned───4*[{tuned}]
```

```bash
# killall httpd
```

Kill процеси (параметр `-k`), які мають доступ до файлу `/etc/httpd/conf/httpd.conf`:

```bash
# fuser -k /etc/httpd/conf/httpd.conf
```

## Команда `watch`

Команда `watch` регулярно виконує команду та відображає результат у терміналі на весь екран.

Параметр `-n` дозволяє вказати кількість секунд між кожним виконанням команди.

!!! note "Примітка"

    Щоб вийти з команди `watch`, ви повинні ввести клавіші: ++control+c++ для зупинки процесу.

Приклади:

* Відображати кінець файлу `/etc/passwd` кожні 5 секунд:

```bash
watch -n 5 tail -n 3 /etc/passwd
```

Результат:

```bash
Every 5.0s: tail -n 3 /etc/passwd                                                                                                                                rockstar.rockylinux.lan: Thu Jul  1 15:43:59 2021

sssd:x:996:993:User for sssd:/:/sbin/nologin
chrony:x:995:992::/var/lib/chrony:/sbin/nologin
sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin
```

* Контроль кількості файлів у папці:

```bash
watch -n 1 'ls -l | wc -l'
```

* Показати годинник:

```bash
watch -t -n 1 date
```

## Команда `install`

На відміну від назви, команда `install` не використовується для встановлення нових пакетів.

Ця команда поєднує копіювання файлів (`cp`) і створення каталогу (`mkdir`) із керуванням правами (`chmod`, `chown`) та інші корисні функції (наприклад, резервне копіювання).

```bash
install source dest
install -t directory source [...]
install -d directory
```

Опції:

| Опції                        | Зауваження                                                       |
| ---------------------------- | ---------------------------------------------------------------- |
| `-b` або `--backup[=suffix]` | створює резервну копію цільового файлу.                          |
| `-d`                         | розглядає аргументи як імена каталогів.                          |
| `-D`                         | створює всі провідні компоненти перед копіюванням SOURCE у DEST. |
| `-g` та `-o`                 | встановлює право власності.                                      |
| `-m`                         | встановлює дозволи.                                              |
| `-p`                         | зберігає мітки часу вихідних файлів.                             |
| `-t`                         | копіює всі вихідні аргументи до каталогу.                        |

!!! note "Примітка"

    Існують параметри для керування контекстом SELinux (див. сторінку підручника).

Приклади:

Створення каталогу за допомогою параметра `-d`:

```bash
install -d ~/samples
```

Скопіюйте файл із вихідного розташування до каталогу:

```bash
install src/sample.txt ~/samples/
```

Ці два накази можна було виконати за допомогою однієї команди:

```bash
$ install -v -D -t ~/samples/ src/sample.txt
install: creating directory '~/samples'
'src/sample.txt' -> '~/samples/sample.txt'
```

Ця команда вже економить час. Поєднайте його з власником, групою власників і керуванням правами, щоб покращити економію часу:

```bash
sudo install -v -o rocky -g users -m 644 -D -t ~/samples/ src/sample.txt
```

!!! note "Примітка"

     `sudo` потрібен у цьому випадку, щоб змінити властивість.

Ви також можете створити резервну копію існуючих файлів завдяки опції `-b`:

```bash
$ install -v -b -D -t ~/samples/ src/sample.txt
'src/sample.txt' -> '~/samples/sample.txt' (archive: '~/samples/sample.txt~')
```

Як бачите, команда `install` створює файл резервної копії з тильдою `~`, доданою до оригінального імені файлу.

Суфікс можна вказати за допомогою параметра `-S`:

```bash
$ install -v -b -S ".bak" -D -t ~/samples/ src/sample.txt
'src/sample.txt' -> '~/samples/sample.txt' (archive: '~/samples/sample.txt.bak')
```

## Команда `tree`

Розгорніть файли або каталоги в каталозі у вигляді дерева.

| опції | опис                                           |
|:----- |:---------------------------------------------- |
| `-a`  | Усі файли перераховані                         |
| `-h`  | Друкує розмір у більш зрозумілий спосіб        |
| `-u`  | Відображає власника файлу або номер UID        |
| `-g`  | Відображає власника групи файлів або номер GID |
| `-p`  | Друкує захист для кожного файлу                |

Наприклад:

```bash
$ tree -hugp /etc/yum.repos.d/
/etc/yum.repos.d/
├── [-rw-r--r-- root     root      1.6K]  epel-modular.repo
├── [-rw-r--r-- root     root      1.3K]  epel.repo
├── [-rw-r--r-- root     root      1.7K]  epel-testing-modular.repo
├── [-rw-r--r-- root     root      1.4K]  epel-testing.repo
├── [-rw-r--r-- root     root       710]  Rocky-AppStream.repo
├── [-rw-r--r-- root     root       695]  Rocky-BaseOS.repo
├── [-rw-r--r-- root     root      1.7K]  Rocky-Debuginfo.repo
├── [-rw-r--r-- root     root       360]  Rocky-Devel.repo
├── [-rw-r--r-- root     root       695]  Rocky-Extras.repo
├── [-rw-r--r-- root     root       731]  Rocky-HighAvailability.repo
├── [-rw-r--r-- root     root       680]  Rocky-Media.repo
├── [-rw-r--r-- root     root       680]  Rocky-NFV.repo
├── [-rw-r--r-- root     root       690]  Rocky-Plus.repo
├── [-rw-r--r-- root     root       715]  Rocky-PowerTools.repo
├── [-rw-r--r-- root     root       746]  Rocky-ResilientStorage.repo
├── [-rw-r--r-- root     root       681]  Rocky-RT.repo
└── [-rw-r--r-- root     root      2.3K]  Rocky-Sources.repo

0 directories, 17 files
```

## Команда `stat`

Команда `stat` відображає стан файлу або файлової системи.

```bash
$ stat /root/anaconda-ks.cfg
  File: /root/anaconda-ks.cfg
  Size: 1352            Blocks: 8          IO Block: 4096   regular file
Device: 10302h/66306d   Inode: 2757097     Links: 1
Access: (0755/-rwxr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2024-01-20 13:04:57.012033583 +0800
Modify: 2023-09-25 14:04:48.524760784 +0800
Change: 2024-01-24 16:37:34.315995221 +0800
 Birth: 2
```

* `File` - Відображає шлях до файлу.
* `Size` - Відображає розмір файлу в байтах. Якщо це каталог, він відображає фіксовані 4096 байт, зайняті назвою каталогу.
* `Blocks` - Відображає кількість виділених блоків. Увага, будь ласка! Розмір кожного блоку в цій команді становить 512 байт. Стандартний розмір кожного блоку в `ls -ls` становить 1024 байти.
* `Device` - Номер пристрою в десятковій або шістнадцятковій системі числення.
* `Inode` - Inode — це унікальний ідентифікаційний номер, який ядро Linux призначає файлу або каталогу.
* `Links` - Кількість жорстких посилань. Жорсткі посилання іноді називають фізичними посиланнями.
* `Access` - Час останнього доступу до файлів і каталогів, тобто `atime` у GNU/Linux.
* `Modify` - Час останньої модифікації файлів і каталогів, тобто `mtime` у GNU/Linux.
* `Change` - Востаннє властивість змінено, наприклад, `ctime` у GNU/Linux.
* `Birth` - Час народження (час створення). У деяких документах він скорочується як `btime` або `crtime`. Для відображення часу створення вам потрібна файлова система та версія ядра, яка перевищує певну версію.

Для файлів:

**atime** – після доступу до вмісту файлу за допомогою таких команд, як `cat`, `less`, `more` і `head`, `atime` файл можна оновити. Будь ласка, зверніть увагу! `atime` файлу не оновлюється в реальному часі, і з міркувань продуктивності йому потрібно зачекати деякий час, перш ніж його можна буде відобразити. **mtime** – зміна вмісту файлу може оновити `mtime` файлу (наприклад, додавати або перезаписувати вміст файлу за допомогою переспрямування), оскільки розмір файлу є властивістю файлу, `ctime` також буде оновлено одночасно. **ctime**. Зміна власника, групи, дозволів, розміру файлу та посилань (м’яких і жорстких посилань) файлу призведе до оновлення ctime.

Для каталогів:

**atime** – після використання команди `cd` для входу в новий каталог, доступу до якого раніше не було, ви можете оновити та виправити `atime ` цього каталогу. **mtime** – виконання таких операцій, як створення, видалення та перейменування файлів у цьому каталозі, оновить `mtime` і `ctime` довідника. **ctime** – коли дозволи, власник, група тощо каталогу змінюються, `ctime` каталогу буде оновлено.

!!! tip "Підказка"

    * Якщо ви створюєте новий файл або каталог, його `atime`, `mtime` і `ctime` точно збігаються
    * Якщо вміст файлу змінено, `mtime` та `ctime` файлу неминуче буде оновлено.
    * Якщо в каталозі створюється абсолютно новий файл, `atime`, `ctime` і `mtime` цього каталогу буде оновлено одночасно.
    * Якщо `mtime` каталогу оновлюється, то `ctime` цього каталогу має бути оновлено.
