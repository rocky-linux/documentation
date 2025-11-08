---
title: Рішення для резервного копіювання - rsnapshot
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - резервне копіювання
  - rsnapshot
---

## Передумови

- Знати, як інсталювати додаткові репозиторії та снепшоти з командного рядка
- Дізнатися про монтування файлових систем, зовнішніх по відношенню до вашої машини (зовнішній диск, віддалена файлова система тощо).
- Знати, як користуватися редактором (використовуючи `vi` тут, але ви можете використовувати свій улюблений редактор)
- Трохи знати сценарії BASH
- Знати, як змінити `crontab` для користувача root
- Знання відкритих і закритих ключів SSH (тільки якщо ви плануєте запускати віддалене резервне копіювання з іншого сервера)

## Вступ

`rsnapshot` — це потужна утиліта для резервного копіювання з опціями встановлення на будь-який комп'ютер на базі Linux. Він може створити резервну копію машини локально, або ви можете створити резервну копію кількох машин, скажімо, серверів, з однієї машини.

`rsnapshot` використовує `rsync` та повністю написаний на Perl без залежностей від бібліотек. Жодних незвичайних вимог до встановлення не існує. У випадку Rocky Linux ви можете встановити `rnapshot` за допомогою репозиторію EPEL. Після першого випуску Rocky Linux 9.0, був час, коли EPEL не містив пакета `rsnapshot`. Це вже не так, але ці інструкції містять метод встановлення з джерела на випадок, якщо це повториться.

Ця документація стосується лише встановлення `rsnapshot` у Rocky Linux.

\=== "EPEL Install"

    ````
    ## Installing `rsnapshot`
    
    Calling all commands here from the command line unless otherwise noted.
    
    ### Installing The EPEL repository
    
    You need the EPEL software repository from Fedora. To install the repository, just use this command:
    
    ```
    sudo dnf install epel-release -y
    ```
    
    The repository will now be active.
    
    ### Install the `rsnapshot` package
    
    Install `rsnapshot` and some other needed tools:
    
    ``` 
    sudo dnf install rsnapshot openssh-server rsync
    ```
    
    If there are any missing dependencies, those will show up and you simply need to answer the prompt to continue. For example:
    
    ```
    dnf install rsnapshot
    Last metadata expiration check: 0:00:16 ago on Mon Feb 22 00:12:45 2021.
    Dependencies resolved.
    ========================================================================================================================================
    Package                           Architecture                 Version                              Repository                    Size
    ========================================================================================================================================
    Installing:
    rsnapshot                         noarch                       1.4.3-1.el8                          epel                         121 k
    Installing dependencies:
    perl-Lchown                       x86_64                       1.01-14.el8                          epel                          18 k
    rsync                             x86_64                       3.1.3-9.el8                          baseos                       404 k
    
    Transaction Summary
    ========================================================================================================================================
    Install  3 Packages
    
    Total download size: 543 k
    Installed size: 1.2 M
    Is this ok [y/N]: y
    ```
    ````

\=== "Source Install"

    ````
    ## Installing `rsnapshot` from source
    
    Installing `rsnapshot` from source is not difficult. It does come with a downside, however, in that if there is a new version released, it will require a fresh install from source to update the version, whereas the EPEL installation method would keep you up-to-date with a simple `dnf upgrade`. 
    
    ### Installing Development Tools and downloading the source
    
    As stated, the first step here is to install the 'Development Tools' group:
    
    ```
    dnf groupinstall 'Development Tools'
    ```
    
    You also need a few other packages:
    
    ```
    dnf install wget unzip rsync openssh-server
    ```
    
    Next you will need to download the source files from the GitHub repository. You can do this multiple ways, but the easiest in this case is probably just to download the ZIP file from the repository.
    
    1. Go to https://github.com/rsnapshot/rsnapshot
    2. Click on the Green "Code" button on the right
    ![Code](images/code.png)
    3. Right-click on the "Download ZIP" and copy the link location
    ![Zip](images/zip.png)
    4. Use `wget` or `curl` to download the copied link. Example:
    ```
    wget https://github.com/rsnapshot/rsnapshot/archive/refs/heads/master.zip
    ```
    5. Unzip the `master.zip` file
    ```
    unzip master.zip
    ```
    
    ### Building the source
    
    Now that you have got everything on our machine, the next step is to build. When you unzipped the `master.zip` file, you ended up with an `rsnapshot-master` directory. You will need to change into this for our build procedure. Note that your build is using all of the package defaults, so if you want something else, you will need to do a little investigation. Also, these steps are directly taken from the [GitHub Installation](https://github.com/rsnapshot/rsnapshot/blob/master/INSTALL.md) page:
    
    ```bash
    cd rsnapshot-master
    ```
    
    Run the `authogen.sh` script to generate the configure script:
    
    ```bash
    ./autogen.sh
    ```
    
    !!! tip
    
        You may get several lines that look like this:
    
        ```bash
        fatal: not a git repository (or any of the parent directories): .git
        ```
    
        These are not fatal.
    
    Next, you need to run `configure` with the configuration directory set:
    
    ```bash
    ./configure --sysconfdir=/etc
    ```
    
    Finally, run `make install`:
    
    ```bash
    sudo make install
    ```
    
    During all of this, the `rsnapshot.conf` file will be created as `rsnapshot.conf.default`. You need to copy this over to `rsnapshot.conf` and then edit it to fit what you need on our system.
    
    ```bash
    sudo cp /etc/rsnapshot.conf.default /etc/rsnapshot.conf
    ```
    
    This covers copying the configuration file over. The section below on "Configuring rsnapshot" will cover the changes needed in this configuration file.
    ````

## Монтування диска або файлової системи для резервного копіювання

У цьому кроці ми покажемо, як підключити диск, наприклад зовнішній USB-накопичувач, який використовується для резервного копіювання вашої системи. Цей конкретний крок необхідний, лише якщо ви створюєте резервну копію однієї машини або сервера, як показано в нашому першому прикладі.

1. Підключіть USB-накопичувач.
2. Введіть `dmesg | grep sd`, яка покаже вам диск, який ви хочете використовувати. У цьому випадку це _sda1_.  
   Приклад: `EXT4-fs (sda1): монтування файлової системи ext2 за допомогою підсистеми ext4`.
3. На жаль (або на щастя, залежно від вашої думки), більшість сучасних настільних операційних систем Linux автоматично монтують диск, якщо можуть. Приклад: `Ext4-fs (sda1): монтування файлової системи ext2 за допомогою підсистеми ext4`. Ви хочете, щоб диск "монтувався" або робив свої файли доступними в одному й тому ж місці щоразу.  
   Для цього візьміть інформацію про диск, отриману в команді `dmesg`, та введіть `mount | grep sda1`, що покаже таке: `/dev/sda1 on /media/username/8ea89e5e-9291-45c1-961d-99c346a2628a`
4. Введіть `sudo umount /dev/sda1`, щоб відключити зовнішній диск.
5. Далі створіть точку підключення для резервної копії: `sudo mkdir /mnt/backup`
6. Підключіть диск до папки резервної копії: `sudo mount /dev/sda1 /mnt/backup`
7. Введіть `mount | grep sda1` знову, і ви побачите це: `/dev/sda1 на /mnt/backup type ext2 (rw,relatime)`
8. Далі створіть каталог, який повинен існувати для продовження резервного копіювання на підключеному диску. У цьому прикладі ви використовуєте папку під назвою "storage": `sudo mkdir /mnt/backup/storage`

Зауважте, що для однієї машини вам доведеться або повторювати кроки `umount` і `mount` кожного разу, коли приєднується диск, або кожного разу, коли система перезавантажується, або автоматизувати ці команди зі сценарієм.

Рекомендується автоматизація.

## Налаштування `rsnapshot`

Це найважливіший крок. При внесенні змін у файл конфігурації можна зробити помилку. Конфігурація `rsnapshot` вимагає табуляції для будь-якого розділення елементів, і попередження про це знаходиться у верхній частині файлу конфігурації.

Пробіл спричинить збій усієї конфігурації та вашої резервної копії. Наприклад, ближче до початку файлу конфігурації є розділ для `# SNAPSHOT ROOT DIRECTORY #`. Якби ви додавали це з нуля, ви б набрали `snapshot_root`, потім TAB, а потім `/який_шлях_до_кореневого_знімку_буде/`

Найкраще те, що конфігурація за замовчуванням, що входить до складу `rsnapshot`, потребує лише незначних змін, щоб вона працювала для резервного копіювання локальної машини. Проте завжди доцільно створити резервну копію файлу конфігурації перед початком редагування:

`cp /etc/rsnapshot.conf /etc/rsnapshot.conf.bak`

## Резервне копіювання базової машини або одного сервера

У цьому випадку `rsnapshot` буде запущено локально для резервного копіювання певної машини. У цьому прикладі ми розберемо конфігураційний файл і покажемо вам, що саме вам потрібно змінити.

Щоб відкрити файл _/etc/rsnapshot.conf_, вам знадобиться використати `vi` (або відредагувати його у вашому улюбленому редакторі).

Перше, що потрібно змінити, це налаштування _snapshot_root_. За замовчуванням має таке значення:

```text
snapshot_root   /.snapshots/
```

Вам потрібно змінити це на точку монтування, яку ви створили, і додати в «сховище».

```text
snapshot_root   /mnt/backup/storage/`
```

Ви також хочете вказати, щоб резервне копіювання не запускалося, якщо диск не підключено. Для цього видаліть знак «#» (також званий приміткою, знаком числа, символом решітки тощо) next to `no_create_root` which looks this way:

```text
no_create_root 1
```

Далі перейдіть до розділу під назвою `# EXTERNAL PROGRAM DEPENDENCIES #` і видаліть коментар (знову знак «#») із цього рядка:

```text
#cmd_cp         /usr/bin/cp
```

Тепер він читає:

```text
cmd_cp         /usr/bin/cp
```

Хоча вам не потрібен `cmd_ssh` для цієї конкретної конфігурації, він знадобиться для нашої іншої опції, і його ввімкнення не завадить. Знайдіть рядок, який говорить:

```text
#cmd_ssh        /usr/bin/ssh
```

Видаліть знак "#":

```text
cmd_ssh        /usr/bin/ssh
```

Далі потрібно перейти до розділу під назвою `# РІВНІ РЕЗЕРВНОГО КОПІЮВАННЯ / ІНТЕРВАЛИ #`

У попередніх версіях `rsnapshot` були значення «щогодини», «щодня», «щомісяця», «річно», але тепер вони містять значення «альфа, бета, гамма, дельта». Це трохи заплутано. Вам потрібно додати зауваження до будь-яких інтервалів, які ви не використовуватимете. У конфігурації дельта вже виділена.

У цьому прикладі ви не збираєтеся запускати жодних інших інкрементів, окрім нічного резервного копіювання. Просто додайте примітку до альфа- і гамма. Після завершення файл конфігурації матиме наступний вигляд:

```text
#retain  alpha   6
retain  beta    7
#retain  gamma   4
#retain delta   3
```

Перейдіть до рядка `logfile`, який за умовчанням:

```text
#logfile        /var/log/rsnapshot
```

І видаліть примітку:

```text
logfile        /var/log/rsnapshot
```

Нарешті, перейдіть до розділу `### ТОЧКИ РЕЗЕРВНОГО КОПІЮВАННЯ / СЦЕНАРІЇ ###` та додайте будь-які каталоги, які ви хочете додати, у розділ `# LOCALHOST`, не забудьте використовувати + +табуляція++, а не ++пробіл++ між елементами!

Наразі запишіть свої зміни (++shift+двокрапка+"wq!"++ для `vi`) та вийдіть із конфігураційного файлу.

### Перевірка конфігурації

Ви хочете переконатися, що ви не додали пробіли чи будь-які інші явні помилки до нашого файлу конфігурації під час його редагування. Для цього потрібно запустити команду `rsnapshot` для нашої конфігурації з опцією `configtest`:

`rsnapshot configtest` покаже `Syntax OK`, якщо немає помилок.

Візьміть за звичку запускати `configtest` для певної конфігурації. Причина цього буде більш очевидною, коли ви перейдете до розділу **Резервні копії кількох машин або кількох серверів**.

Щоб запустити `configtest` для певного файлу конфігурації, запустіть його з опцією `-c`, щоб визначити конфігурацію:

```bash
rsnapshot -c /etc/rsnapshot.conf configtest
```

## Перший запуск резервного копіювання

Після того, як `configtest` перевірив, що все гаразд, настав час вперше запустити резервне копіювання. Ви можете спочатку запустити це в тестовому режимі, щоб побачити, що робить сценарій резервного копіювання.

Знову ж таки, щоб зробити це, вам не обов’язково вказувати конфігурацію в цьому випадку, але було б гарною ідеєю увійти в звичку робити це:

```bash
rsnapshot -c /etc/rsnapshot.conf -t beta
```

Котрий поверне щось подібне до цього, показуючи вам, що станеться, коли резервне копіювання фактично запуститься:

```bash
echo 1441 > /var/run/rsnapshot.pid
mkdir -m 0755 -p /mnt/backup/storage/beta.0/
/usr/bin/rsync -a --delete --numeric-ids --relative --delete-excluded \
    /home/ /mnt/backup/storage/beta.0/localhost/
mkdir -m 0755 -p /mnt/backup/storage/beta.0/
/usr/bin/rsync -a --delete --numeric-ids --relative --delete-excluded /etc/ \
    /mnt/backup/storage/beta.0/localhost/
mkdir -m 0755 -p /mnt/backup/storage/beta.0/
/usr/bin/rsync -a --delete --numeric-ids --relative --delete-excluded \
    /usr/local/ /mnt/backup/storage/beta.0/localhost/
touch /mnt/backup/storage/beta.0/
```

Коли тест виправдає ваші очікування, запустіть його вручну вперше без тесту:

```bash
rsnapshot -c /etc/rsnapshot.conf beta
```

Після завершення резервного копіювання перейдіть до `/mnt/backup` та перегляньте структуру каталогів, яку воно там створює. Там буде каталог `storage/beta.0/localhost`, а за ним — каталоги, які ви вказали для резервного копіювання.

### Подальше пояснення

Кожного разу, коли виконується резервне копіювання, воно створюватиме ще один приріст бета-версії, резервні копії тривалістю 0–6 або 7 днів. Найновіша резервна копія завжди буде beta.0, тоді як вчорашня резервна копія завжди буде beta.1.

Розмір кожної з цих резервних копій буде таким, що займає однаковий (або більше) дискового простору, але це пов'язано з жорсткими посиланнями, що використовуються `rsnapshot`. Щоб відновити файли з учорашньої резервної копії, просто скопіюйте їх назад зі структури каталогів beta.1.

Кожне резервне копіювання є лише додатковим резервним копіюванням із попереднього запуску, АЛЕ через використання жорстких посилань кожен каталог резервного копіювання містить або файл, або жорстке посилання на файл, незалежно від того, у якому каталозі було створено резервну копію.

Щоб відновити файли, вам не потрібно вирішувати каталог або приріст, з якого їх відновлювати, а лише позначку часу резервної копії, яку ви відновлюєте. Це чудова система, яка займає набагато менше дискового простору, ніж багато інших рішень для резервного копіювання.

## Налаштування автоматичного запуску резервного копіювання

Після завершення тестування та впевненості в тому, що все працюватиме без проблем, наступним кроком є ​​налаштування `crontab` для користувача root, щоб автоматизувати процес щодня:

```bash
sudo crontab -e
```

Якщо ви не запускали це раніше, виберіть "vim.basic" як свій редактор або власне налаштування редактора, коли з’явиться рядок `Select an editor`.

Ви збираєтеся налаштувати резервне копіювання на автоматичний запуск о 23:00, тож додайте це до `crontab`:

```bash
## Running the backup at 11 PM
00 23 *  *  *  /usr/bin/rsnapshot -c /etc/rsnapshot.conf beta`
```

## Резервне копіювання кількох машин або кількох серверів

Створення резервних копій кількох машин із машини з RAID-масивом або великою ємністю пам’яті, локально або через підключення до Інтернету в іншому місці працює добре.

Якщо ви виконуєте ці резервні копії через Інтернет, вам потрібно переконатися, що кожне місце має достатню пропускну здатність для створення резервних копій. Ви можете використовувати `rsnapshot` для синхронізації локального сервера з віддаленим резервним масивом або резервним сервером для покращення резервування даних.

## Припущення

Запуск `rsnapshot` з машини віддалено, локально. Запуск цієї точної конфігурації також можливий дистанційно поза приміщенням.

У цьому випадку вам потрібно буде встановити `rsnapshot` на машину, яка виконує всі резервні копії. Інші припущення:

- Що сервери, на які ви будете створювати резервні копії, мають правило брандмауера, яке дозволяє віддаленій машині підключитися до нього через SSH
- Що на кожному сервері, резервну копію якого ви створюватимете, встановлено останню версію `rsync`. Для серверів Rocky Linux запустіть команду `dnf install rsync`, щоб оновити версію `rsync` вашої системи.
- Що ви підключилися до комп’ютера як користувач root або ви запустили `sudo -s`, щоб переключитися на користувача root

## Відкриті або закриті ключі SSH

Для сервера, який виконуватиме резервне копіювання, вам потрібно створити пару ключів SSH для використання під час резервного копіювання. Для нашого прикладу ви будете створювати ключі RSA.

Якщо у вас уже є згенерований набір ключів, ви можете пропустити цей крок. Ви можете дізнатися це, виконавши команду `ls -al .ssh` та знайшовши пару ключів `id_rsa` та `id_rsa.pub`. Якщо такого немає, скористайтеся наведеним нижче посиланням, щоб налаштувати ключі для вашої машини та серверів, до яких ви хочете отримати доступ:

[Пари відкритий-приватний ключ SSH](../security/ssh_public_private_keys.md)

## Конфігурація `rsnapshot`

Файл конфігурації має бути майже таким самим, як той, який ми створили для **базової машини або резервного копіювання одного сервера**, за винятком того, що вам потрібно змінити деякі параметри.

Корінь snapshot є типовим:

```text
snapshot_root   /.snapshots/
```

Прокоментуйте цей рядок:

```text
no_create_root 1
#no_create_root 1
```

Інша відмінність полягає в тому, що кожна машина матиме власну конфігурацію. Коли ви звикнете до цього, ви просто скопіюєте один із наявних конфігураційних файлів під іншу назву та зміните його відповідно до будь-яких додаткових машин, резервну копію яких ви хочете створити.

Наразі ви хочете просто змінити файл конфігурації (як показано вище) і зберегти його. Скопіюйте цей файл як шаблон для нашого першого сервера:

```bash
cp /etc/rsnapshot.conf /etc/rsnapshot_web.conf
```

Ви хочете змінити файл конфігурації та створити журнал і `файл блокування` з назвою машини:

```text
logfile /var/log/rsnapshot_web.log
lockfile        /var/run/rsnapshot_web.pid
```

Далі вам потрібно змінити `rsnapshot_web.conf`, щоб включити каталоги, резервні копії яких ви хочете створити. Єдине, що тут інше – це мета.

Ось приклад конфігурації "web.ourdomain.com":

```bash
### BACKUP POINTS / SCRIPTS ###
backup  root@web.ourourdomain.com:/etc/     web.ourourdomain.com/
backup  root@web.ourourdomain.com:/var/www/     web.ourourdomain.com/
backup  root@web.ourdomain.com:/usr/local/     web.ourdomain.com/
backup  root@web.ourdomain.com:/home/     web.ourdomain.com/
backup  root@web.ourdomain.com:/root/     web.ourdomain.com/
```

### Перевірка конфігурації та запуск початкової резервної копії

Тепер ви можете перевірити конфігурацію, щоб переконатися, що вона синтаксично правильна:

```bash
rsnapshot -c /etc/rsnapshot_web.conf configtest
```

Ви шукаєте повідомлення `Syntax OK`. Якщо все в порядку, ви можете запустити резервне копіювання вручну:

```bash
/usr/bin/rsnapshot -c /etc/rsnapshot_web.conf beta
```

Якщо припустити, що все працює, ви можете створити файли конфігурації для поштового сервера (`rsnapshot_mail.conf`) і сервера порталу (`rsnapshot_portal.conf`), перевірити їх і виконати пробну версію резервне копіювання.

## Автоматизація резервного копіювання

Автоматизація резервного копіювання для кількох версій машин або серверів дещо відрізняється. Ви хочете створити сценарій bash для виклику резервних копій по порядку. Коли один закінчить, почнеться наступний. Цей сценарій виглядатиме так:

```bash
vi /usr/local/sbin/backup_all
```

Зі змістом:

```bash
#!/bin/bash/
# script to run rsnapshot backups in succession
/usr/bin/rsnapshot -c /etc/rsnapshot_web.conf beta
/usr/bin/rsnapshot -c /etc/rsnapshot_mail.conf beta
/usr/bin/rsnapshot -c /etc/rsnapshot_portal.conf beta
```

Збережіть сценарій у `/usr/local/sbin` і зробіть його виконуваним:

```bash
chmod +x /usr/local/sbin/backup_all
```

Створіть `crontab` для root для запуску сценарію резервного копіювання:

```bash
crontab -e
```

І додайте цей рядок:

```bash
## Running the backup at 11 PM
00 23 *  *  *  /usr/local/sbin/backup_all
```

## Повідомлення про статус резервного копіювання

Щоб переконатися, що все резервне копіювання виконується згідно з планом, ви можете надіслати файли журналу резервного копіювання на свою електронну пошту. Якщо ви створюєте резервні копії кількох машин за допомогою `rsnapshot`, кожен файл журналу матиме власну назву, яку ви можете надіслати на свою електронну пошту для перегляду за допомогою процедури [Використання постфікса для звітності про серверні процеси](../email/postfix_reporting.md).

## Відновлення резервної копії

Відновлення кількох файлів або цілої резервної копії включає копіювання файлів, які ви хочете, з каталогу з датою, яку ви хочете відновити, назад на ваш комп’ютер.

## Висновки та інші ресурси

Правильна настройка за допомогою `rsnapshot` спочатку трохи складна, але може заощадити багато часу на резервне копіювання ваших машин або серверів.

`rsnapshot` — потужний, швидкий та економний у використанні дискового простору. Ви можете знайти більше інформації про `rsnapshot`, відвідавши [rsnapshot github] (https://github.com/rsnapshot/rsnapshot).
