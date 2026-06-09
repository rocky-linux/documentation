---
title: Рішення для дзеркального відображення - lsyncd
author: Steven Spencer
contributors: Ezequiel Bruni, tianci li, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - lsyncd
  - синхронізація
  - mirroring
---

## Передумови

- Машина під керуванням Rocky Linux
- Комфортний рівень зі зміною файлів конфігурації з командного рядка
- Знання того, як користуватися редактором командного рядка (тут `vi`, але використовуйте свій улюблений редактор)
- Вам потрібен доступ root або привілеї `sudo` (використання `sudo -s` з самого початку є хорошою ідеєю)
- Пари відкритих і закритих ключів SSH
- Репозиторії EPEL (додаткові пакети для Enterprise Linux) від Fedora
- Вам потрібно буде ознайомитися з _inotify_, інтерфейсом монітора подій
- Додатково: знайомство з _tail_

## Вступ

Якщо ви хочете автоматично синхронізувати файли та папки між комп'ютерами, `lsyncd` — чудовий варіант. However, you must configure everything from the command line.

It is a program worth learning for any system administrator.

Найкращий опис `lsyncd` можна знайти на його сторінці довідки (man). Трохи перефразовано, `lsyncd` — це легке рішення для живого дзеркала, яке нескладно встановити. Він не потребує нових файлових систем або блокових пристроїв і не перешкоджає продуктивності локальної файлової системи. In short, it mirrors files.

`lsyncd` спостерігає за інтерфейсом монітора подій локального дерева каталогів (inotify). It aggregates and combines events for a few seconds and spawns one (or more) process(es) to synchronize the changes. За замовчуванням це `rsync`.

У цьому посібнику ви називатимете систему з оригінальними файлами «джерелом»; той, з яким ви синхронізуєтеся, буде «ціллю». Використовуючи `lsyncd`, ви можете повністю віддзеркалити сервер, ретельно вказавши каталоги та файли, які потрібно синхронізувати.

Вам також потрібно буде налаштувати [пари публічних закритих ключів Rocky Linux SSH] (../security/ssh_public_private_keys.md) для віддаленої синхронізації. The examples here use SSH (port 22).

## Встановлення `lsyncd`

Встановлення `lsyncd` відбувається двома способами. Включено описи кожного методу. RPM, як правило, трохи відстає від вихідних пакетів, але лише трохи. Версія, встановлена ​​методом RPM на момент написання цієї статті, — 2.2.3-5, тоді як версія вихідного коду зараз — 2.3.1. Виберіть спосіб, який вам зручніше.

## Встановлення `lsyncd` - метод RPM

Встановити версію RPM нескладно. Єдине, що вам потрібно спочатку встановити, це сховище програмного забезпечення EPEL від Fedora. Зробіть це за допомогою:

```bash
dnf install -y epel-release
```

Тепер встановіть `lsyncd` разом із усіма відсутніми залежностями:

```bash
dnf install lsyncd
```

Set up the service to start on boot, but do not start it just yet:

```bash
systemctl enable lsyncd
```

## Встановлення `lsyncd` - вихідний метод

Installing from the source is not difficult.

### Встановлення залежностей

Вам знадобляться деякі залежності для `lsyncd` та для збірки пакетів з вихідного коду. Використовуйте цю команду на своєму комп’ютері Rocky Linux, щоб переконатися, що у вас є потрібні залежності. Якщо ви збираєтеся створювати з вихідного коду, було б гарною ідеєю встановити всі інструменти розробки:

```bash
dnf groupinstall 'Development Tools'
```

!!! warning "Для Rocky Linux 9.0"

    `lsyncd` був повністю протестований у Rocky Linux 9.0 і працюватиме належним чином. Щоб установити всі необхідні залежності, вам потрібно буде ввімкнути додатковий репозиторій:
    
    `     dnf config-manager --enable crb     `

Виконання цих дев’яти кроків перед наступними дозволить вам завершити збірку без повернення назад.

Ось залежності, необхідні для `lsyncd`:

```bash
dnf install lua lua-libs lua-devel cmake unzip wget rsync
```

### Завантаження `lsyncd` і його збірка

Next, you need the source code:

```bash
wget https://github.com/axkibe/lsyncd/archive/master.zip
```

Розпакуйте файл `master.zip`:

`unzip master.zip`

Це створить каталог під назвою «lsyncd-master». Вам потрібно перейти до цього каталогу та створити каталог під назвою build:

```bash
cd lsyncd-master
```

Then:

```bash
mkdir build
```

Change directories to access the build directory:

```bash
cd build
```

Run these commands:

```bash
cmake ..
make
make install
```

Після завершення двійковий файл `lsyncd` буде встановлено та готовий до використання в _/usr/local/bin_

### `lsyncd` Служба Systemd

За допомогою методу встановлення RPM служба systemd встановиться за вас, але якщо ви встановлюєте з джерела, вам потрібно буде створити службу systemd. Хоча ви можете запустити бінарний файл без служби systemd, ви хочете переконатися, що він _дійсно_ запускається під час завантаження. If not, a server reboot will stop your synchronization effort. Якщо ви забудете знову запустити його вручну, це буде проблема!

Створення служби systemd відносно просте і заощадить ваш час у довгостроковій перспективі.

#### Створення службового файлу `lsyncd`

You can create this file anywhere, even in your server's root directory. Once created, you can move it to the right location.

```bash
vi /root/lsyncd.service`
```

The contents of this file will be:

```bash
[Unit]
Description=Live Syncing (Mirror) Daemon
After=network.target

[Service]
Restart=always
Type=simple
Nice=19
ExecStart=/usr/local/bin/lsyncd -nodaemon -pidfile /run/lsyncd.pid /etc/lsyncd.conf
ExecReload=/bin/kill -HUP $MAINPID
PIDFile=/run/lsyncd.pid

[Install]
WantedBy=multi-user.target
```

Встановіть щойно створений файл у правильне розташування:

```bash
install -Dm0644 /root/lsyncd.service /usr/lib/systemd/system/lsyncd.service
```

Нарешті, перезавантажте демон `systemctl`, щоб systemd «бачила» новий службовий файл:

```bash
systemctl daemon-reload
```

## Конфігурація `lsyncd`

Для будь-якого з методів встановлення `lsyncd` вам знадобиться файл конфігурації: _/etc/lsyncd.conf_. The following section will tell you how to build and test a configuration file.

### Зразок конфігурації для тестування

Ось приклад спрощеного файлу конфігурації, який синхронізує _/home_ з іншим комп'ютером. Наш цільовий комп'ютер матиме локальну IP-адресу: _192.168.1.40_

```bash
  settings {
   logfile = "/var/log/lsyncd.log",
   statusFile = "/var/log/lsyncd-status.log",
   statusInterval = 20,
   maxProcesses = 1
   }

sync {
   default.rsyncssh,
   source="/home",
   host="root@192.168.1.40",
   excludeFrom="/etc/lsyncd.exclude",
   targetdir="/home",
   rsync = {
     archive = true,
     compress = false,
     whole_file = false
   },
   ssh = {
     port = 22
   }
}
```

Breaking down this file a bit:

- `logfile` і `statusFile` будуть створені автоматично під час запуску служби.
- `statusInterval` - це кількість секунд, яку необхідно зачекати перед записом у файл statusFile.
- `maxProcesses` – це кількість процесів `lsyncd`, які дозволено запускати. Якщо ви не використовуєте це на завантаженому комп’ютері, достатньо 1 процесу.
- У розділі синхронізації `default.rsyncssh` говорить про використання `rsync` через SSH
- `source=` - це шлях до каталогу, з якого ми синхронізуємо
- `host=` - це наш цільовий комп'ютер, з яким ми синхронізуємо
- `excludeFrom=` повідомляє `lsyncd`, де знаходиться файл виключень. Він повинен існувати, але може бути порожнім.
- `targetdir=` – це каталог, куди ви надсилаєте файли. У більшості випадків це буде відповідати джерелу, але не завжди.
- Розділ `rsync =` та параметри, з якими ви запускаєте `rsync`
- Розділ `ssh =` вказує порт SSH, який прослуховує цільовий комп’ютер

If you add more than one directory to sync, you must repeat the entire "sync" section, including all the opening and closing brackets for each directory.

## Файл lsyncd.exclude

Розділ `rsync =` та параметри, з якими ви запускаєте `rsync`. Create that now:

```bash
touch /etc/lsyncd.exclude
```

Наприклад, якщо ви синхронізували папку `/etc` на своєму комп’ютері, то в процесі `lsyncd` потрібно було б виключити багато файлів і каталогів. Each excluded file or directory is in the file, one per line:

```bash
/etc/hostname
/etc/hosts
/etc/networks
/etc/fstab
```

## Перевірка

With everything set up, you can test it all. Переконайтеся, що наш системний `lsyncd.service` запуститься:

```bash
systemctl start lsyncd
```

If no errors appear after executing this command, check the status of the service just to ensure:

```bash
systemctl status lsyncd
```

Якщо він показує, що служба запущена, використовуйте tail, щоб побачити кінці двох файлів журналу та переконайтеся, що все відображається нормально:

```bash
tail /var/log/lsyncd.log
tail /var/log/lsyncd-status.log
```

Якщо припустити, що все виглядає правильно, перейдіть до каталогу `/home/[user]`, де `[user]` є користувачем комп’ютера, і створіть там файл із \* touch\*.

```bash
touch /home/[user]/testfile
```

Go to the target computer and see if the file shows up. If so, everything is working. Встановіть `lsyncd.service` для запуску під час завантаження за допомогою:

```bash
systemctl enable lsyncd
```

## Пам'ятайте про обережність

Anytime you synchronize a set of files or directories to another computer, think carefully about its effect on the target computer. Припустимо, що ви повертаєтеся до **Файлу lsyncd.exclude** у нашому прикладі вище. Чи можете ви уявити, що може статися, якщо ви не виключите _/etc/fstab_?

`fstab` — це файл, який налаштовує накопичувачі на будь-якому комп'ютері з Linux. The disks and labels are almost certainly different on different machines. The next reboot of the target computer would likely fail.

## Висновки та література

`lsyncd` — це потужний інструмент для синхронізації каталогів між комп'ютерами. Як ви бачите, його неважко встановити та не складно обслуговувати.

Ви можете дізнатися більше про `lsyncd`, відвідавши [Офіційний сайт](https://github.com/axkibe/lsyncd)
