---
title: Команди dump та restore
author: tianci li
contributors: Steven Spencer
tested_with: 8.10
tags:
  - dump
  - restore
  - резервне копіювання
---

## Огляд

`dump` перевіряє файли у файловій системі, визначає, які для резервного копіювання, і копіює ці файли на вказаний диск, стрічку або інший носій даних. Команда `restore` виконує зворотну функцію `dump`.

Ця утиліта застосовується до таких файлових систем:

- ext2
- ext3
- ext4

!!! tip

    Для файлової системи xfs використовуйте `xfsdump`.

[Це](https://dump.sourceforge.io/) домашня сторінка проекту.

Перш ніж використовувати цю утиліту, виконайте таку команду, щоб інсталювати її:

```bash
Shell > dnf -y install dump
```

Після інсталяції доступні два часто використовувані командні інструменти:

- `dump`
- `restore`

### Команда `dump`

Існує два основних способи використання цієї команди:

- Виконати резервне копіювання (dump) - \`dump [параметр(и)] -f <File-Name> <File1>
- Перегляд інформації про резервну копію (dump) - `dump [-W | -w]`

Загальні опції:

- `-<level>` - Резервний рівень. Будь ласка, замініть "level" на будь-яке число від 0-9, коли використовується. Число 0 означає повне резервне копіювання, тоді як інші числа позначають інкрементне резервне копіювання.
- `-f <File-Name>` - Після резервного копіювання вкажіть ім’я файлу та шлях.
- `-u` - Після успішного резервного копіювання запишіть час резервного копіювання у файл **/etc/dumpdates**. Якщо об’єкт резервної копії є незалежним розділом, можна використовувати параметр `-u`. Однак ви не можете використовувати опцію `-u`, якщо об'єкт резервного копіювання є каталогом без розділів.
- `-v` - Відображення деталей обробки під час процесу резервного копіювання.
- `-W` - Опція для перегляду інформації про dump.
- `-z[LEVEL]` - Налаштуйте рівень стиснення за допомогою бібліотеки zlib із стандартним рівнем стиснення 2. Наприклад, ви можете стиснути файл резервної копії до формату `.gz`. Діапазон регулювання рівня стиснення 1-9.
- `-j[LEVEL]` - Налаштуйте рівень стиснення за допомогою бібліотеки bzlib із стандартним рівнем стиснення 2. Наприклад, ви можете стиснути файл резервної копії до формату `.bz2`. Діапазон регулювання рівня стиснення 1-9.

#### Приклад використання `dump`

1. Виконайте повне резервне копіювання кореневого розділу:

    ```bash
    Shell > dump -0u -j3 -f /tmp/root-20241208.bak.bz2 /
    DUMP: Date of this level 0 dump: Sun Dec  8 19:04:39 2024
    DUMP: Dumping /dev/nvme0n1p2 (/) to /tmp/root-20241208.bak.bz2
    DUMP: Label: none
    DUMP: Writing 10 Kilobyte records
    DUMP: Compressing output at transformation level 3 (bzlib)
    DUMP: mapping (Pass I) [regular files]
    DUMP: mapping (Pass II) [directories]
    DUMP: estimated 14693111 blocks.
    DUMP: Volume 1 started with block 1 at: Sun Dec  8 19:04:41 2024
    DUMP: dumping (Pass III) [directories]
    DUMP: dumping (Pass IV) [regular files]
    DUMP: 20.69% done at 10133 kB/s, finished in 0:19
    DUMP: 43.74% done at 10712 kB/s, finished in 0:12
    DUMP: 70.91% done at 11575 kB/s, finished in 0:06
    DUMP: 93.23% done at 11415 kB/s, finished in 0:01
    DUMP: Closing /tmp/root-20241208.bak.bz2
    DUMP: Volume 1 completed at: Sun Dec  8 19:26:08 2024
    DUMP: Volume 1 took 0:21:27
    DUMP: Volume 1 transfer rate: 5133 kB/s
    DUMP: Volume 1 14722930kB uncompressed, 6607183kB compressed, 2.229:1
    DUMP: 14722930 blocks (14377.86MB) on 1 volume(s)
    DUMP: finished in 1287 seconds, throughput 11439 kBytes/sec
    DUMP: Date of this level 0 dump: Sun Dec  8 19:04:39 2024
    DUMP: Date this dump completed:  Sun Dec  8 19:26:08 2024
    DUMP: Average transfer rate: 5133 kB/s
    DUMP: Wrote 14722930kB uncompressed, 6607183kB compressed, 2.229:1
    DUMP: DUMP IS DONE
    
    Shell > ls -lh /tmp/root-20241208.bak.bz2
    -rw-r--r-- 1 root root 6.4G Dec  8 19:26 /tmp/root-20241208.bak.bz2
    ```

2. Після успішного скидання перевірте відповідну інформацію:

    ```bash
    Shell > cat /etc/dumpdates
    /dev/nvme0n1p2 0 Sun Dec  8 19:04:39 2024 +0800
    
    Shell > dump -W
    Last dump(s) done (Dump '>' file systems):
    /dev/nvme0n1p2        (     /) Last dump: Level 0, Date Sun Dec  8 19:04:39 2024
    ```

3. Реалізувати інкрементне резервне копіювання на основі повного резервного копіювання:

    ```bash
    Shell > echo "jack" >> /tmp/tmpfile.txt
    
    Shell > dump -1u -j4 -f /tmp/root-20241208-LV1.bak.bz2 /
    DUMP: Date of this level 1 dump: Sun Dec  8 19:38:51 2024
    DUMP: Date of last level 0 dump: Sun Dec  8 19:04:39 2024
    DUMP: Dumping /dev/nvme0n1p2 (/) to /tmp/root-20241208-LV1.bak.bz2
    DUMP: Label: none
    DUMP: Writing 10 Kilobyte records
    DUMP: Compressing output at transformation level 4 (bzlib)
    DUMP: mapping (Pass I) [regular files]
    DUMP: mapping (Pass II) [directories]
    DUMP: estimated 6620898 blocks.
    DUMP: Volume 1 started with block 1 at: Sun Dec  8 19:38:58 2024
    DUMP: dumping (Pass III) [directories]
    DUMP: dumping (Pass IV) [regular files]
    DUMP: 38.13% done at 8415 kB/s, finished in 0:08
    DUMP: 75.30% done at 8309 kB/s, finished in 0:03
    DUMP: Closing /tmp/root-20241208-LV1.bak.bz2
    DUMP: Volume 1 completed at: Sun Dec  8 19:52:03 2024
    DUMP: Volume 1 took 0:13:05
    DUMP: Volume 1 transfer rate: 8408 kB/s
    DUMP: Volume 1 6620910kB uncompressed, 6600592kB compressed, 1.004:1
    DUMP: 6620910 blocks (6465.73MB) on 1 volume(s)
    DUMP: finished in 785 seconds, throughput 8434 kBytes/sec
    DUMP: Date of this level 1 dump: Sun Dec  8 19:38:51 2024
    DUMP: Date this dump completed:  Sun Dec  8 19:52:03 2024
    DUMP: Average transfer rate: 8408 kB/s
    DUMP: Wrote 6620910kB uncompressed, 6600592kB compressed, 1.004:1
    DUMP: DUMP IS DONE
    
    Shell > cat /etc/dumpdates
    /dev/nvme0n1p2 0 Sun Dec  8 19:04:39 2024 +0800
    /dev/nvme0n1p2 1 Sun Dec  8 19:38:51 2024 +0800
    
    Shell > dump -W
    Last dump(s) done (Dump '>' file systems):
    /dev/nvme0n1p2        (     /) Last dump: Level 1, Date Sun Dec  8 19:38:51 2024
    ```

4. Для нерозділеного каталогу можна використовувати лише параметр «Повна резервна копія» (`-0`), а не параметр `-u`:

    ```bash
    Shell > dump -0uj -f /tmp/etc-full-20241208.bak.bz2 /etc/
    DUMP: You can't update the dumpdates file when dumping a subdirectory
    DUMP: The ENTIRE dump is aborted.
    
    Shell > dump -0j -f /tmp/etc-full-20241208.bak.bz2 /etc/
    DUMP: Date of this level 0 dump: Sun Dec  8 20:00:38 2024
    DUMP: Dumping /dev/nvme0n1p2 (/ (dir etc)) to /tmp/etc-full-20241208.bak.bz2
    DUMP: Label: none
    DUMP: Writing 10 Kilobyte records
    DUMP: Compressing output at transformation level 2 (bzlib)
    DUMP: mapping (Pass I) [regular files]
    DUMP: mapping (Pass II) [directories]
    DUMP: estimated 28204 blocks.
    DUMP: Volume 1 started with block 1 at: Sun Dec  8 20:00:38 2024
    DUMP: dumping (Pass III) [directories]
    DUMP: dumping (Pass IV) [regular files]
    DUMP: Closing /tmp/etc-full-20241208.bak.bz2
    DUMP: Volume 1 completed at: Sun Dec  8 20:00:40 2024
    DUMP: Volume 1 took 0:00:02
    DUMP: Volume 1 transfer rate: 3751 kB/s
    DUMP: Volume 1 29090kB uncompressed, 7503kB compressed, 3.878:1
    DUMP: 29090 blocks (28.41MB) on 1 volume(s)
    DUMP: finished in 2 seconds, throughput 14545 kBytes/sec
    DUMP: Date of this level 0 dump: Sun Dec  8 20:00:38 2024
    DUMP: Date this dump completed:  Sun Dec  8 20:00:40 2024
    DUMP: Average transfer rate: 3751 kB/s
    DUMP: Wrote 29090kB uncompressed, 7503kB compressed, 3.878:1
    DUMP: DUMP IS DONE
    ```

   Виконання інкрементного резервного копіювання каталогу /etc/ призведе до помилки:

    ```bash
    Shell > dump -1j -f /tmp/etc-incr-20241208.bak.bz2 /etc/
    DUMP: Only level 0 dumps are allowed on a subdirectory
    DUMP: The ENTIRE dump is aborted.
    ```

### Команда `restore`

Використання цієї команди - `restore <mode(flag)> [параметр(и)] -f <Dump-File>`

Режим (прапор) може бути одним із таких:

- `-C` - Режим порівняння. Restore читає резервну копію та порівнює її вміст із файлами на диску. В основному використовується для порівняння після виконання резервного копіювання на розділі. У цьому режимі «відновлення» лише порівнює зміни на основі вихідних даних. Якщо на диску є нові дані, ви не зможете їх порівняти чи виявити.
- `-i` - Інтерактивний режим. Цей режим дозволяє інтерактивно відновлювати файли з дампа.
- `-t` - Режим списку. Перелічіть, які дані містяться у файлі резервної копії.
- `-r` - Режим відновлення (перебудови). Якщо це метод «Повне резервне копіювання + додаткове резервне копіювання», відновлення даних відбуватиметься в хронологічному порядку.
- `-x` - Режим екстракції. Витягніть деякі або всі файли з файлу резервної копії.

#### Приклад використання `restore`

1. Відновити дані з /tmp/etc-full-20241208.bak.bz2:

    ```bash
    Shell > mkdir /tmp/data/
    
    Shell > restore -t -f /tmp/etc-full-20241208.bak.bz2
    
    Shell > cd /tmp/data/ ; restore -r -f /tmp/etc-full-20241208.bak.bz2
    
    Shell > ls -l /tmp/data/
    total 4992
    drwxr-xr-x. 90 root root    4096 Dec  8 17:13 etc
    -rw-------   1 root root 5107632 Dec  8 20:39 restoresymtable
    ```

   Як бачите, після успішного відновлення з’являється файл із назвою `restoresymtable`. Цей файл важливий. Він призначений для операцій відновлення системи поетапного резервного копіювання.

2. Обробка резервних копій файлів в інтерактивному режимі:

    ```bash
    Shell > restore -i -f /tmp/etc-full-20241208.bak.bz2
    Dump tape is compressed.
    
    restore > ?
    ```

   Ви можете ввести ++question++, щоб переглянути доступні інтерактивні команди в цьому режимі.
