---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tested on: All Versions
tags:
  - лабораторна вправа
  - системні утиліти
  - cli
---

# Лабораторна робота 3: Загальні системні утиліти

## Цілі

Виконавши цю лабораторну роботу, ви зможете

- Використовувати звичайні системні утиліти, які є в більшості систем Linux

Приблизний час виконання цієї лабораторної роботи: 70 хвилин

## Загальні системні утиліти в системах Linux

Вправи в цій лабораторній роботі охоплюють деякі основні системні утиліти, з якими повинні бути знайомі користувачі та адміністратори. Більшість команд використовуються для навігації та керування файловою системою. Файлова система складається з файлів і каталогів.

Вправи охоплюватимуть використання утиліт –`pwd`, `cd`, `ls`, `rm`, `mv`, `ftp`, `cp`, `touch`, `mkdir`, `file`, `cat`, `find` та `locate`.

## Вправа 1

### `cd`

Команда `cd` означає зміну каталогу. Ви почнете ці лабораторні роботи, перейшовши до інших каталогів у файловій системі.

#### Використання `cd`

1. Увійдіть на комп'ютер як root

2. Перейдіть із поточного каталогу до каталогу /etc.

    ```bash
    [root@localhost root]# cd /etc
    ```

3. Зауважте, що ваш запит змінився з “[root@localhost root]# ” на : “[root@localhost etc]# “

4. Перейдіть до каталогу `/usr/local/`

    ```bash
    [root@localhost etc]# cd /usr/local
    
    [root@localhost local]#
    ```

   !!! Question "Питання"

        ```
         Що змінилося у вашій підказці?
        ```

5. Поверніться до домашнього каталогу root

    ```bash
    [root@localhost local]# cd /root
    ```

6. Знову перейдіть до каталогу /usr/local/. Впишіть:

    ```bash
    [root@localhost root]# cd /usr/local
    ```

7. Щоб перейти до батьківського каталогу локального каталогу, введіть «cd ..»

    ```bash
    [root@localhost local]# cd ..
    ```

   !!! Question "Питання"

        ```
         Який батьківський каталог є батьківським для каталогу /usr/local/?
        ```

8. Щоб швидко повернутися до домашнього каталогу root, введіть “cd” без аргументів.

    ```bash
    [root@localhost usr]# cd
    
    [root@localhost root]#
    ```

## Вправа 2

### `pwd`

Команда `pwd` розшифровується як «поточний робочий каталог». Він показує розташування у файловій системі, де ви перебуваєте.

#### Використання `pwd`

1. Щоб дізнатися тип поточного робочого каталогу

    ```bash
    [root@localhost root]# pwd
    /root
    ```

2. Змініть свій каталог на /usr/local/ за допомогою команди «cd».

    ```bash
    [root@localhost root]# cd /usr/local
    ```

3. Використайте `pwd`, щоб знайти ваш поточний робочий каталог:

    ```bash
    [root@localhost local]# pwd
    /usr/local
    ```

4. Повернутися до домашнього каталогу root.

    ```bash
    [root@localhost root]#  cd
    ```

## Вправа 3

### `mkdir`

Команда `mkdir` використовується для створення каталогів. Ви створите два каталоги під назвою «folder1» і «folder2».

#### Завдання 3

1. Впишіть:

    ```bash
    [root@localhost root]# mkdir folder1
    ```

2. Створіть другий каталог під назвою folder2

    ```bash
    [root@localhost root]# mkdir   folder2
    ```

3. Тепер змініть свій робочий каталог на каталог “folder1”, який ви створили вище.

    ```bash
    [root@localhost root]# cd folder1
    ```

4. Покажіть ваш поточний робочий каталог.

    ```bash
    [root@localhost folder1]# pwd
    /root/folder1
    ```

   !!! question

            Не виходячи з поточного каталогу, перейдіть до каталогу «folder2». Яка команда для цього?

5. Поверніться до домашнього каталогу root.

## Вправа 4

### `touch`

Команду `touch` можна використовувати для створення звичайних файлів. Ви створите «file11, file12, file21 і file22» у зазначених вище папках.

#### Використання `touch`

1. Змініть каталог, тобто `cd`, на folder1 та створіть "file11:"

    ```bash
    [root@localhost folder1]# touch file11
    ```

2. Перебуваючи в folder1, створіть «file12»

    ```bash
    [root@localhost folder1]# touch file12
    ```

3. Тепер поверніться до домашнього каталогу root.

4. `cd` до папки folder2 та створення «file21» та «file22»

    ```bash
    [root@localhost folder2]# Touch file21 file22
    ```

5. Поверніться до домашнього каталогу root.

## Вправа 5

### `ls`

Команда `ls` означає список. Вона відображає список вмісту каталогу.

#### Використання `ls`

1. Введіть `ls` у домашньому каталозі root:

    ```bash
    [root@localhost root]# ls
    ```

   !!! Question "Питання"

        ```
         Перерахуйте вміст каталогу
        ```

2. Перейдіть до каталогу "folder1"

3. Виведіть вміст каталогу “folder1”. Введіть `ls`

    ```bash
    [root@localhost folder1]# ls
    file11  file12
    ```

4. Перейдіть до каталогу folder2 і перелічіть його вміст тут:

5. Поверніться до домашнього каталогу та перерахуйте «всі» приховані файли та папки.

    ```bash
    [root@localhost folder2]# cd
    
    [root@localhost root]# ls   –a
    ..  .bash_history  .bash_logout  .bash_profile  .bashrc  folder1  folder2  .gtkrc  .kde   screenrc
    ```

6. Щоб отримати довгий або детальний список усіх файлів і папок у вашому домашньому каталозі, введіть:

    ```bash
    [root@localhost root]# ls –al
    total 44
    
    drwx------    5 root    root        4096 May  8 10:15 .
    
    drwxr-xr-x    8 root     root         4096 May  8 09:44 ..
    
    -rw-------    1 root    root          43 May  8 09:48 .bash_history
    
    -rw-r--r--    1 root    root          24 May  8 09:44 .bash_logout
    
    -rw-r--r--    1 root    root         191 May  8 09:44 .bash_profile
    
    -rw-r--r--    1 root    root         124 May  8 09:44 .bashrc
    
    drwxrwxr-x    2 root    root        4096 May  8 10:17 folder1
    
    drwxrwxr-x    2 root    root        4096 May  8 10:18 folder2
    
    ………………………..
    ```

## Вправа 6

### `mv`

Команда `mv` означає переміщення. Він перейменовує файли або каталоги. Він також може переміщувати файли.

#### Завдання 6

1. Змініть каталог на каталог folder1 і перегляньте його вміст

    ```bash
    [root@localhost root]# cd   folder1
    [root@localhost folder1] ls
    
    file11  file12
    ```

2. Ви перейменуєте file11 і file12 у каталозі folder1 на temp_file11 і temp_file12 відповідно.

    ```bash
    [root@localhost folder1]# mv file11 temp_file11
    ```

3. Знову перерахуйте вміст folder1.

    ```bash
    [root@localhost folder1]# ls
    ```

   !!! Question "Питання"

        ```
         Запишіть зміст:
        ```

4. Перейменуйте file12 на temp_file12:

    ```bash
    [root@localhost folder1]# mv file12 temp_file12
    ```

5. Не змінюючи каталог, перейменуйте file21 і file22 у folder2 на temp_file21 і temp_file22 відповідно.

    ```bash
    [root@localhost folder1]# mv   /root/folder2/file21     /root/folder2/temp_file21
    
    [root@localhost folder1]# mv   /root/folder2/file22    /root/folder2/temp_file22
    ```

6. Не змінюючи ваш поточний каталог, перегляньте вміст folder2.

   !!! question

            Яка команда для цього? Також перелічіть результат виконання команди?

## Вправа 7

### `cp`

Команда `cp` означає копіювання. Він створює копії файлів або каталогів.

1. Змініть свій каталог на каталог folder2.

2. Скопіюйте вміст folder2 (temp_file21 і temp_file22) до folder1

    ```bash
    [root@localhost folder2]# cp  temp_file21  temp_file22    ../folder1
    ```

3. Перелічіть вміст folder1.

    ```bash
    [root@localhost folder2]# ls  ../folder1
    temp_file11  temp_file12  temp_file21  temp_file22
    ```

4. Перелічіть вміст folder2. Зауважте, що оригінальні копії temp_file21 і temp_file22 залишаються в folder2.

    ```bash
    [root@localhost folder2]# ls
    temp_file21  temp_file22
    ```

## Вправа 8

### `file`

Утиліта `file` використовується для визначення типів файлів або каталогів.

#### Використання `file`

1. Поверніться до домашнього каталогу.

2. Щоб перевірити, чи є "folder1" файлом або каталогом, впишіть:

    ```bash
    [root@localhost root]# file    folder1
    folder1: directory
    ```

3. Перейдіть до каталогу folder1

4. Використайте утиліту `file`, щоб визначити тип файлу temp_file11:

    ```bash
    [root@localhost folder1]# file     temp_file11
    temp_file11: empty
    ```

5. Використайте утиліту `file`, щоб дізнатися тип файлу для всіх файлів у каталозі folder1. Перелік тут:

6. Змініть каталог на каталог /etc.

    ```bash
    [root@localhost folder1]# cd /etc
    ```

7. Використайте утиліту `file`, щоб дізнатися тип файлу "passwd".

    ```bash
    [root@localhost etc]# file passwd
    ```

   !!! Question "Питання"

        ```
         Який це тип файлу?
        ```

## Вправа 9

### `cat`

Команда `cat` — це скорочення від concatenate, що означає, що вона об'єднує файли разом. Команда `cat` також відобразить вміст усього файлу на екрані. Ви будете використовувати `cat` разом із символом перенаправлення ">" для створення файлу.

#### Використання `cat` для створення файлу

1. Змініть каталог на каталог /root/folder1

2. Створіть новий текстовий файл під назвою «first.txt»

    ```bash
    [root@localhost folder1]# cat > first.txt
    ```

3. Введіть наведену нижче фразу в пустому рядку та натисніть ++enter++.

    ```bash
    Це рядок з first.txt !!
    ```

4. Одночасно натисніть ++ctrl+c++.

5. Введіть «cat first.txt», щоб прочитати щойно введений текст.

    ```bash
    [root@localhost folder1]#  cat    first.txt
    This is a line from first.txt !!
    ```

6. Створіть ще один файл під назвою «second.txt» за допомогою `cat`. Введіть у файл наступний текст – «This is a line from second.txt!!»

   !!! Question "Питання"

        ```
         Яка команда для цього?
        ```

#### Використання `cat` для об'єднання файлів разом

1. Ви об’єднаєте файли “first.txt” і “second.txt”. Впишіть:

    ```bash
    [root@localhost folder1]#  cat     first.txt    second.txt
    ```

   !!! Question "Питання"

        ```
         Який ваш вихід?
        ```

## Вправа 10

### `ftp`

`ftp` — це клієнтська програма для використання та підключення до FTP-сервісів через протокол передачі файлів (FTP Protocol). Програма дозволяє користувачам передавати файли на віддалений мережевий сайт і з нього. Це утиліта, яку ви можете часто використовувати.

У цій вправі ви дізнаєтеся, як анонімно увійти на FTP-сервер та завантажити файл із сервера за допомогою клієнтської програми `ftp`.

!!! note

    Вам потрібно буде виконати вправи з попередньої лабораторної роботи, щоб продовжувати цю конкретну вправу, для якої потрібен доступний FTP-сервер, який працює десь доступно.

#### Використання `ftp`

1. Увійдіть на свою машину як root

2. Змініть каталог на “/usr/local/src/”.

3. Створіть новий каталог під назвою «завантаження» в каталозі «/usr/local/src/».

   !!! Question "Питання"

        ```
         Яка команда для цього?
        ```

4. Змініть каталог на щойно створений каталог «завантажень».

    ```bash
    [root@localhost src]# cd  downloads
    ```

5. Введіть «ftp», щоб запустити ваш `ftp`-клієнт:

    ```bash
    [root@localhost downloads]#  ftp
    ftp>
    ```

6. Для підключення до FTP-сервера введіть:

    ```bash
    ftp> open  < server-address>         (Obtain the <server-address> from your instructor)
    ………  
    
    220 localhost.localdomain FTP server (Version wu-2.6.2-5) ready.
    ………..
    ```

7. Увійдіть як анонімний користувач. Введіть «anonymous» у запиті:

    ```bash
    Name (10.4.51.29:root):  anonymous
    ```

8. У вікні запиту пароля введіть будь-яку адресу електронної пошти та натисніть клавішу enter

    ```bash
    Password:         ***************
    
    230 Guest login ok, access restrictions apply.
    
    Remote system type is UNIX.
    
    Using binary mode to transfer files.
    
    ftp>
    ```

9. Перейти в двійковий режим. Впишіть:

    ```bash
    ftp> binary
    ```

   !!! Question "Питання"

        ```
         Який результат виконання команди binary та що таке бінарний режим "бінарний режим"?
        ```

10. Перелічіть поточні каталоги на ftp-сервері. Введіть «ls» у командному рядку ftp (ftp>):

    ```bash
    ftp>  ls  
    227 Entering Passive Mode (10,0,4,5,16,103).
    125 Data connection already open; Transfer starting.
    11-23-43  10:23PM       <DIR>          images
    11-02-43  02:20PM       <DIR>          pub
    226 Transfer complete.
    ```

11. Змініть каталог на каталог «pub». Впишіть:

    ```bash
    ftp> cd  pub
    ```

12. Використовуйте команду «ls», щоб отримати список файлів і каталогів у каталозі «pub».

    !!! Question "Питання"

        ```
        Скільки файлів і каталогів там зараз?
        ```

13. Завантажте файл під назвою «hello-2.1.1.tar.gz» у свій локальний каталог. Введіть «yes» у запиті.

    ```bash
    ftp>  mget     hello-2.1.1.tar.gz
    mget hello-2.1.1.tar.gz?    yes

    227 Entering Passive Mode (10,0,4,5,16,252).

    125 Data connection already open; Transfer starting.

    226 Transfer complete.

    389363 bytes received in 0.0745 secs (5.1e+03 Kbytes/sec)
    ```

14. Вийдіть з FTP-сервера та закрийте свій `ftp`-клієнт. Впишіть:

    ```bash
    ftp> bye
    ```

15. Ви будете кинуті назад у свою локальну оболонку.

16. Переконайтеся, що ви все ще перебуваєте в каталозі «завантажень» локальної машини.

    !!! question

            Перелічіть файли в папці завантажень.

## Вправа 11

### Використання перенаправлення

Більшість утиліт і команд, якими ви користуєтеся в Linux, надсилають вихідні дані на екран. Екран називається стандартним виводом (stdout). Переспрямування дає змогу надіслати результат кудись ще – можливо, файл.

Кожна програма, запущена в системі Linux, має три дескриптори відкритих файлів: stdin (0), stdout (1) і stderr (2). Ви можете перенаправляти або передавати їх окремо. Символи перенаправлення: “>, < “

#### Використання перенаправлення

1. Переконайтеся, що ви все ще перебуваєте в каталозі folder1.

2. Ви будете використовувати переспрямування виводу, щоб переспрямувати вихід із команди ls (list) до текстового файлу під назвою myredirects

    ```bash
    [root@localhost folder1]# ls  > myredirects
    ```

3. Перегляньте новий файл (myredirects), створений у каталозі folder1.

    ```bash
    [root@localhost folder1] # cat     myredirects
    temp_file11  temp_file12  temp_file21  temp_file22 myredirects
    ```

4. Тепер ви перенаправите вихід команди file у той самий файл. Ви хочете дізнатися тип файлу для temp_file11 у каталозі folder1 і надіслати результат у свій файл myredirects

    ```bash
    [root@localhost folder1]#  file    temp_file11   >   myredirects
    ```

5. Перегляньте вміст файлу myredirects.

   !!! question

            Це змінилося. Що сталося?

6. Якщо ви хочете запобігти тому, що сталося вище, ви використовуватимете символ подвійного перенаправлення «>>».  Це додасть новий вихід до файлу замість його заміни. Впишіть:

    ```bash
    [root@localhost folder1]#  ls  >>  myredirects
    ```

7. Тепер знову перевірте вміст файлу myredirects за допомогою `cat`.

   !!! Question "Питання"

        ```
         Запишіть його зміст тут:
        ```

### Використання перенаправлення для придушення виводу команди

Ви будете часто використовувати концепції, розглянуті тут, у Linux, тому, будь ласка, зверніть на це особливу увагу. Це може бути трохи складно.

Бувають випадки, коли ви не хочете, щоб користувач бачив результат команди, можливо, повідомлення про помилку. Зазвичай це відбувається тому, що дивні повідомлення про помилки часто лякають звичайних користувачів. У цих вправах ви надішлете вихід своїх команд на нульовий пристрій ( /dev/null/ ). Нульовий пристрій схожий на «бітове відро». Все, що ви кладете всередину, зникає назавжди. Ви також можете надіслати (або перенаправити) звичайний вихід команди на нульовий пристрій "null device".

Використовуйте наведені нижче вказівки:

```bash
|Redirector|<p></p><p>Function</p>|
| :- | :- |
|> file|Direct standard output to file|
|< file|Take standard input from file|
|Cmd1 | cmd2|Pipe; take standard out of cmd1 as standard input to cmd2|
|n> file|Direct file descriptor n to file|
|N< file|Set file as file descriptor n|
|>&n|Duplicate standard output to file descriptor n|
|<&n|Duplicate standard input from file descriptor n|
|&>file|Direct standard output and standard error to file|

```

1. Переконайтеся, що ви все ще перебуваєте в каталозі folder1. Використовуйте опцію довгого списку команди ls у temp_file11:

    ```bash
    [root@localhost folder1]#  ls   –l   temp_file11
    -rw-r--r--    1 root     root            0 Jul 26 18:26 temp_file11
    ```

2. Ви перенаправите вихід тієї ж команди вище (ls –l temp_file11) на нульовий пристрій.

    ```bash
    [root@localhost folder1]#  ls   –l temp_file11  > /dev/null
    ```

   У вас не повинно бути результату.

3. Тепер, якщо ви випадково неправильно ввели назву файлу, інформацію про який ви хочете переглянути; Ви отримаєте:

    ```bash
    [root@localhost folder1]# ls –l te_file1
    ls: te_file1: No such file or directory
    ```

   Вищезазначене є результатом типу помилки, яку було запрограмовано видати команду `ls`.

4. Виконайте ту саму команду, що й вище, з неправильним написанням імені файлу та перенаправте його до /dev/null

    ```bash
    [root@localhost folder1]# ls   -l   te_file1  >  /dev/null
    
    ls: te_file1: No such file or directory
    ```

   !!! Question "Питання"

        ```
         Що тут сталося? Чому вивід все ще відображається на екрані (стандартний вивід)?
        ```

5. З різних причин ви можете придушити такі повідомлення про помилки, як наведене вище. Щоб зробити це, впишіть:

    ```bash
    [root@localhost folder1]# ls –l te_file1 > /dev/null 2>&1
    ```

   Ви не отримаєте результату.

   Цього разу стандартний вихід, а також стандартна помилка пригнічуються.

   Порядок перенаправлення ВАЖЛИВИЙ!!

   Переспрямування читається зліва направо в командному рядку.

   Ліва частина символу перенаправлення — «>»: надсилатиме стандартний вивід (stdout) до /dev/null. Тоді крайня права частина перенаправлення — «2>&1»: продублює стандартну помилку (2) у стандартний вивід (1).

   Отже, наведену вище команду можна прочитати так: перенаправити stdout(1) до “/dev/null”, а потім скопіювати stderr (2) до stdout

6. Щоб додатково продемонструвати важливість порядку перенаправлення. Спробуйте:

    ```bash
    [root@localhost folder1]# ls   –l    tem_file  2>&1   > order.txt
    ```

   Використайте команду `cat` для перевірки вмісту файлу “order.txt”

   Крайня ліва частина – «2>&1» скопіює стандартну помилку у стандартний вивід. Потім, крайня права частина вищезазначеного – “ > order.txt ” перенаправляє stdout до файлу order.txt.

7. Спробуйте цей варіант описаного вище кроку:

    ```bash
    [root@localhost folder1]# ls  –l   hgh_ghz  2>  order2.txt   > order2.txt
    ```

   !!! question

            Перегляньте файл «order2.txt» та поясніть, що сталося?

8. Щоб надіслати стандартний вивід і стандартну помилку в окремі файли, впишіть:

    ```bash
    [root@localhost folder1]# ls  –l  tep_f   > standard_out  2> standard_err
    ```

   !!! question

            Було створено два нових файли. Які назви цих файлів і який їхній вміст?

9. Ви можете аналогічно переспрямувати як stdout, так і stderr до одного файлу, використовуючи:

    ```bash
    [root@localhost folder1]# ls  –l   te_fil   &>   standard_both
    ```

## Вправа 12

### `rm`

Команда `rm` використовується для видалення файлів або каталогів. Ви збираєтеся використовувати `rm` для видалення деяких файлів, створених у попередніх вправах.

#### Використання `rm`

1. Перебуваючи в каталозі "folder1", видаліть файл standard_err. У запиті підтвердження введіть «y»:

    ```bash
    [root@localhost folder1]# rm   standard_err
    rm: remove `standard_err'? y
    ```

2. Видаліть файл «standard_out». Щоб уникнути запиту підтвердження перед видаленням файлу, використовуйте параметр “–f “ разом із командою `rm`:

    ```bash
    [root@localhost folder1]# rm   -f   standard_out
    ```

3. Поверніться до домашнього каталогу (/root) і видаліть каталог «folder2». Щоб видалити папку за допомогою команди `rm`, потрібно скористатися параметром “–r”:

    ```bash
    [root@localhost root]# rm  -r   folder2
    
    rm: descend into directory `folder2'? y
    
    rm: remove `folder2/temp_file21'? y
    
    rm: remove `folder2/temp_file22'? y
    
    rm: remove directory `folder2'? y
    ```

   !!! Question "Питання"

        ```
         Вам знову запропонували підтвердити видалення кожного файлу в каталозі та самого каталогу. Який параметр ви використаєте з командою `rm –r`, щоб запобігти цьому?
        ```

## Вправа 13

### Вивчення `vi`

`vi` — це текстовий редактор. Його можна використовувати для редагування всіх видів звичайного тексту. Це особливо корисно для редагування програм.

vi — великий товстий монстр, який може робити майже все, включаючи приготування кави чи какао!!

Замість того, щоб намагатися навчити вас користуватися `vi`, ця вправа вкаже вам на інструмент, який допоможе вам краще ознайомитися з `vi`.

Будь ласка, знайдіть час, щоб ознайомитися з онлайн-інструкцією з `vi` (точніше `vim`). Просто дотримуйтесь інструкцій.

#### Щоб дізнатися `vi`

1. Увійшовши в систему, введіть:

   [root@localhost root]# vimtutor

## Вправа 14

### Пошук файлів: (`find` та `locate`)

У цій вправі буде розглянуто дві найпопулярніші утиліти, які використовуються для пошуку файлів і каталогів у файловій системі. Це команди `find` та `locate`.

#### `find`

Утиліта `find` існує вже давно. Вона рекурсивно сканує каталоги, щоб знайти файли, які відповідають заданому критерію.

Загальний синтаксис для `find` такий:

```bash
find   [path]    [options]   [criterion]    [action]
```

Якщо ви не вкажете жодного каталогу чи шляху, пошук буде здійснюватися в поточному каталозі. Якщо ви не вкажете критерій, це еквівалентно "true", тому всі файли будуть знайдені. Утиліта `find` має багато опцій для виконання практично будь-якого типу пошуку файлу. Нижче наведено лише деякі параметри, критерії та дії.

```bash
OPTIONS:

-xdev: do not search on directories located on other filesystems;

-mindepth <n> descend at least <n> levels below the specified directory before

searching for files;

-maxdepth <n>: search for files located at most n levels below the specified directory;

-follow: follow symbolic links if they link to directories.

-daystart: when using tests related to time (see below), take the beginning of current day as a timestamp instead of the default (24 hours before current time).
```

```bash
CRITERION

-type <type>: search for a given type of file; <type> can be one of: f (regular file), d (directory),

l (symbolic link), s (socket), b (block mode file), c (character mode file) or

p (named pipe);

-name <pattern>: find files whose names match the given <pattern>;

-iname <pattern>: like -name, but ignore case;

-atime <n>, -amin <n>:find files which have last been accessed <n> days ago (-atime) or <n> minutes ago (-amin). You can also specify +<n> or -<n>, in which case the search will be done for files accessed respectively at most or at least <n> days/minutes ago;

-anewer <file>: find files which have been accessed more recently than file <file>;

-ctime <n>, -cmin <n>, -cnewer <file>: same as for -atime, -amin and -anewer, but applies to the last time when the contents of the file have been modified;

-regex <pattern>: same as -name, but pattern is treated as a regular expression;

-iregex <pattern>: same as -regex, but ignore case.
```

```bash
ACTION:

-print: just prints the name of each file on standard output. This is the default action;

-ls: prints on the standard output the equivalent of ls -ilds for each file found;

-exec <command>: execute command <command> on each file found. The command line <command> must end with a ;, which you must escape so that the shell does not interpret it; the file position is marked with {}.

-ok <command>: same as -exec but asks confirmation for each command.
```

#### Щоб використовувати `find`

1. Переконайтеся, що ви перебуваєте у своєму домашньому каталозі.

2. Ви скористаєтеся командою find, щоб відобразити всі файли у вашому поточному каталозі (`pwd`). Впишіть:

    ```bash
    [root@localhost root]# find
    
    
    ………..
    
    ./.bash_profile
    
    ./.bashrc
    
    ./.cshrc
    
    ./.tcshrc
    
    ./.viminfo
    
    ./folder1
    
    ./folder1/first.txt
    
    …………
    ```

   Ваші результати показують типову поведінку find, коли використовується без жодного параметра.

   Він рекурсивно відображає всі файли та каталоги (включаючи приховані файли) у робочому каталозі.

3. Тепер використовуйте `find`, щоб знайти лише каталоги у вашому паролі. Впишіть:

    ```bash
    [root@localhost root]# find   -type   d
    .
    ./folder1
    ./folder2
    ………
    ```

   !!! question "Питання"

            З наведеної вище команди «find –type d»; що таке «опція», що таке «шлях», що таке «критерій» і, нарешті, що таке «дія»?

4. Далі ви шукатимете всі файли у вашій системі, які закінчуються суфіксом «.txt».

    ```bash
    [root@localhost root]# find    /   -maxdepth   3   -name   "*.txt"   -print
    /root/folder1/first.txt
    /root/folder1/second.txt
    /root/folder1/order.txt
    /root/folder1/order2.txt
    ```

   !!! question "Питання"

            Знову ж таки, згідно з наведеною вище командою, що таке «опція», що таке «шлях», що таке «критерій» і, нарешті, що таке «дія»? (ПІДКАЗКА: Дія = «- print»)

   Пошук виконуватиметься лише на 3 каталоги вглиб від каталогу “/”.

   Зірочка, яка використовується в наведеній вище команді, є одним із символів підстановки в Linux.

   Використання символів підстановки в Linux називається «глоббуванням».

5. Використайте команду `find`, щоб знайти всі файли у вашому «pwd», розмір яких «менший» за 200 кілобайт. Впишіть:

    ```bash
    [root@localhost root]# find   .   –size    -200k
    ```

6. Використайте команду `find`, щоб знайти всі файли у вашому паролі, розмір яких перевищує 10 кілобайт, а також відобразити їхній «тип файлу». Впишіть:

    ```bash
    [root@localhost root]#  find   .  –size  +10k   –exec    file     "{ }"      ";"
    ```

#### `locate`

Синтаксис команди `find` іноді може бути досить складним у використанні; а через розширений пошук він може бути повільним. Альтернативна команда — `locate`.

`locate` шукає в попередньо створеній базі даних усіх файлів у файловій системі.

Він спирається на програму `updatedb`.

```bash
search usage:

locate [-qi] [-d <path>] [--database=<path>] <search string>...

locate [-r <regexp>] [--regexp=<regexp>]

database usage: locate [-qv] [-o <file>] [--output=<file>]

locate [-e <dir1,dir2,...>] [-f <fs_type1,...> ] [-l <level>]

[-c] <[-U <path>] [-u]>

general usage: locate [-Vh] [--version] [--help]
```

#### Використання `locate`

1. Перейдіть до каталогу folder1 і створіть порожні файли temp1, temp2 і temp3:

    ```bash
    [root@localhost root]# cd   folder1;   touch temp1   temp2    temp3
    [root@localhost folder1]#
    ```

   Крапка з комою (;), яка використовується у наведеній вище команді, дозволяє виконувати кілька команд в одному рядку!!

2. Використовуйте `locate` для пошуку всіх файлів у вашому паролі, які мають суфікс «temp»

    ```bash
    [root@localhost folder1]# locate  temp*
    /root/folder1/temp_file11
    /root/folder1/temp_file12
    /root/folder1/temp_file21
    /root/folder1/temp_file22
    ```

   Зауважте, що три файли, які ви створили на кроці 1, НЕ знайдено.

3. Ви примусово оновите базу даних за допомогою `updatedb`, щоб вона могла враховувати всі щойно створені файли. Впишіть:

    ```bash
    [root@localhost folder1]# updatedb
    ```

4. Тепер спробуйте пошук знову. Впишіть:

    ```bash
    [root@localhost folder1]# locate    temp
    ```

   !!! Question "Питання"

        ```
         What happened this time?
        ```

5. Ви закінчили цю лабораторну роботу.
