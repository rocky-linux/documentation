- - -
Title:  Лабораторна робота 3 – Аудит системи author: Wale Soyinka contributors: Steven Spencer, Ganna Zhyrnova
- - -

# Лабораторна робота 3 – Аудит системи

## Завдання

Після виконання цієї лабораторної роботи ви зможете:

- створювати простий і спеціальний інструмент аудиту з нуля
- використовувати та розуміти інструменти аудиту безпеки, такі як Tripwire

Приблизний час виконання цієї лабораторної роботи: 90 хвилин

## Простий домашній засіб перевірки цілісності

Перед установкою та налаштуванням Tripwire ми створюємо зразок сценарію, який виконує аналогічну функцію. Цей сценарій допоможе краще зрозуміти, як працюють Tripwire та подібні інструменти.

Сценарій значною мірою покладається на програму md5sum. Програма md5sum використовується для обчислення 128-бітної контрольної суми (або «відбитка») для вказаного ФАЙЛУ.

Функції сценарію, як описано нижче:

1. Відразу після встановлення базової системи вона створить резервні копії деяких файлів конфігурації системи в каталозі /etc у каталозі etc.bak у кореневому каталозі.

    Зокрема, він створить резервні копії всіх файлів у /etc із суфіксом «*.conf»

    Він робить це, коли виконується з параметром ініціалізації ( -- initialization| -i)

2. Потім сценарій отримає контрольні суми md5 відомих придатних файлів (незабруднених файлів).

3. Список сум MD5 зберігатиметься у файлі під назвою «md5_good».

4. Коли сценарій виконується в режимі перевірки, програма md5sum буде викликана з опцією «- -check», щоб перевірити поточні суми MD5 за вказаним списком (файл md5_good).

    Сценарій роздрукує вихідні дані перевірки у стандартний вихідний файл і надішле копію результату електронною поштою суперкористувачу.

5. Кожного разу, коли вносяться зміни (законні чи незаконні) до конфігураційних файлів у /etc, сценарій можна викликати за допомогою `--rebuild| -r` параметр для затвердження змін і перебудови базової псевдобази даних.

6. Ви можете періодично запускати сценарій вручну або створити завдання cron для автоматичного запуску сценарію.

Наведений нижче сценарій можна точно налаштувати та масштабувати, щоб робити набагато більше, ніж він робить. Вам і вашій уяві залишається зробити все, що ви хочете.

Якщо вам потрібен швидкий і брудний спосіб виконати роботу, сценарію буде достатньо, але для всього іншого є Tripwire.

## Завдання 1

1. Увійдіть як root і запустіть обраний текстовий редактор. Введіть текст нижче:

```bash

#!/bin/sh
# This script checks for changes in the MD5 sums of files named "/etc/*.conf"

case $1 in
    -i|--initialize)
        # This section will run if the script is run in an initialization mode
        # Delete old directory, make directory, backup good files, and change directory to /root/etc.bak

        rm -rf /root/etc.bak
        mkdir /root/etc.bak
        cp /etc/*.conf /root/etc.bak
        cd /root/etc.bak

        # Create our baseline file containing a list of good MD5 sums

        for i in /etc/*.conf; do
            md5sum $i >> md5_good
        done
        echo -e "\nUntainted baseline file (~/etc.bak/md5_good) has been created !!\n"
        ;;

    -v|--verify)
        # This section will run if the script is called in a verify mode
        cd /root/etc.bak

        # Check if there is any file containing output from a previous run

        if [ -f md5_diffs ]; then
            rm -f md5_diffs # if it exists we delete it
        fi

        # We re-create the file with a pretty sub-heading and some advice

        echo -e "\n **** Possibly tainted File(s) ****\n" > md5_diffs

        # Run the md5sum program against a known good list i.e. "md5_good" file

        md5sum -c md5_good 2> /dev/null | grep FAILED >> md5_diffs
        if [ $? -ge 1 ]; then
            echo "Nothing wrong here."
        else
            # Append some helpful text to the md5_diffs file

            echo -e "\nUpdate the baseline file if you approve of the changes to the file(s) above \n" >> md5_diffs
            echo -e "Re-run the script with the re-build option (e.g. ./check.sh --rebuild) to approve \n" >> md5_diffs

            cat md5_diffs # print the md5_diffs file to the display
            if [ -x /usr/bin/mail ]; then
                mail -s "Changed Files" root < md5_diffs # also e-mail the md5_diffs file to root
            fi
        fi
        ;;

    -r|--rebuild)
        # This section is for re-building the Baseline file just in case
        # the changes to the configuration files are legal and sanctioned

        cd /root/etc.bak/
        mv md5_good md5_good.bak # make a backup copy of the current untainted baseline file

        for j in /etc/*.conf; do
            md5sum $j >> md5_good
        done
        echo -e "\nBaseline file updated with approved changes !!!\n"
        ;;

    *)
        echo "This script accepts: only ( -i|--initialize or -v|--verify or -r|--rebuild ) parameters"
        ;;
esac

```

Збережіть наведений вище текст у текстовому файлі та назвіть файл "check.sh"

### Для використання сценарію check.sh

1. Створіть каталог у домашньому каталозі root під назвою «scripts»

2. Скопіюйте сценарій, який ви створили вище, у свій каталог сценаріїв.

3. Зробіть сценарій виконуваним.

4. Запустіть сценарій з опцією ініціалізації. Впишіть:

    ```bash
    [root@localhost scripts]# ./check.sh -i

    Untainted baseline file (~/etc.bak/md5_good) has been created !!
    ```

5. Використовуйте команду `ls` для перегляду вмісту домашнього каталогу root. У ньому має бути новий каталог під назвою `etc.bak`. Використовуйте команду `cat`, щоб переглянути файл `/root/etc.bak/md5_good`.

6. Запустіть сценарій за допомогою параметра перевірки. Впишіть:

    ```bash
    [root@localhost scripts]# ./check.sh -v

    Тут все вірно.
    ```

    Ви маєте отримати результат вище, якщо все добре.

7. Ви навмисно зміните файли `/etc/kdump.conf` у каталозі `/etc`. Впишіть:

    ```bash
    [root@localhost scripts]# echo "# This is just a test" >> /etc/kdump.conf
    ```

8. Тепер знову запустіть сценарій check.sh у режимі перевірки. Впишіть:

    ```bash
    [root@localhost scripts]# ./check.sh -v
    ****

    /etc/kdump.conf: FAILED

    Update the baseline file if you approve of the changes to the file(s) above

    Re-run the script with the re-build option (e.g. ./check.sh  --rebuild) to approve
    ```

9. Згідно з наведеним вище попередженням, вам слід додатково дослідити, чи відповідає змінений файл вашому схваленню. Якщо так, ви можете запустити сценарій із параметром `--rebuild`. Щоб переглянути лише відмінності між «заплямованим» та «незаплямованим» файлом, ви можете ввести:

    ```bash
    [root@localhost scripts]# sdiff -s /etc/kdump.conf  /root/etc.bak/kdump.conf
    ```

## Tripwire

Однією з перших речей, які ви повинні зробити після створення будь-якої нової системи, є отримання знімка завідомо доброго стану системи до того, як система буде «заражена» або перед розгортанням системи у виробництві.

Для цього існує кілька інструментів. Одним з таких інструментів є Tripwire. Tripwire — це вдосконалений інструмент, тож підготуйтеся до багатьох параметрів, синтаксису, особливостей і перемикачів.

Tripwire можна розглядати як форму системи виявлення вторгнень на основі хоста (IDS). Він виконує функції виявлення вторгнень, роблячи знімок «справної системи», а потім порівнюючи цей працездатний стан з будь-якими іншими підозрілими станами. Він надає засоби дізнатися/відстежити, чи певні конфіденційні файли були змінені незаконним шляхом. Звичайно, системний адміністратор вирішує, які файли слід контролювати.

Автори Tripwire описують його як програмне забезпечення безпеки з відкритим вихідним кодом, виявлення вторгнень, оцінки збитків і відновлення та криміналістику.

Tripwire порівнює новий підпис файлу з підписом, отриманим під час створення бази даних.

Кроки, пов’язані зі встановленням і налаштуванням Tripwire, перераховані нижче:

1. Встановіть програмне забезпечення з вихідного або двійкового файлу

2. Запустіть сценарій налаштування: (twinstall.sh). Цей сценарій використовується для: a) Створення ключа сайту та локального ключа і запиту парольних фраз для обох b) Підпису файлу політики та файлу конфігурації ключем сайту.

3. Ініціалізуйте бази даних tripwire

4. Виконайте першу перевірку цілісності.

5. Відредагуйте файл конфігурації (twcfg.txt)

6. Відредагуйте файл політики (twpol.txt)

Tripwire приймає такі параметри командного рядка:

**Режим ініціалізації бази даних:**

```bash

       -m i            --init
       -v              --verbose
       -s              --silent, --quiet
       -c cfgfile      --cfgfile cfgfile
       -p polfile      --polfile polfile
       -d database     --dbfile database
       -S sitekey      --site-keyfile sitekey
       -L localkey     --local-keyfile localkey
       -P passphrase   --local-passphrase passphrase
       -e              --no-encryption
```

**Режим перевірки цілісності:**

```bash

           -m c                  --check
           -I                    --interactive
           -v                    --verbose
           -s                    --silent, --quiet
           -c cfgfile            --cfgfile cfgfile
           -p polfile            --polfile polfile
           -d database           --dbfile database
           -r report             --twrfile report
           -S sitekey            --site-keyfile sitekey
           -L localkey           --local-keyfile localkey
           -P passphrase         --local-passphrase passphrase
           -n                    --no-tty-output
           -V editor             --visual editor
           -E                    --signed-report
           -i list               --ignore list
           -l { level | name }   --severity { level | name }
           -R rule               --rule-name rule
           -x section            --section section
           -M                    --email-report
           -t { 0|1|2|3|4 }      --email-report-level { 0|1|2|3|4 }
           -h                    --hexadecimal
           [ object1 [ object2... ]]
```

**Режим оновлення бази даних:**

```bash
 -m u                --update
           -v                  --verbose
           -s                  --silent, --quiet
           -c cfgfile          --cfgfile cfgfile
           -p polfile          --polfile polfile
           -d database         --dbfile database
           -r report           --twrfile report
           -S sitekey          --site-keyfile sitekey
           -L localkey         --local-keyfile localkey
           -P passphrase       --local-passphrase passphrase
           -V editor           --visual editor
           -a                  --accept-all
           -Z { low | high }   --secure-mode { low | high }
```

**Режим оновлення політики:**

```bash
 -m p                --update-policy
           -v                  --verbose
           -s                  --silent, --quiet
           -c cfgfile          --cfgfile cfgfile
           -p polfile          --polfile polfile
           -d database         --dbfile database
           -S sitekey          --site-keyfile sitekey
           -L localkey         --local-keyfile localkey
           -P passphrase       --local-passphrase passphrase
           -Q passphrase       --site-passphrase passphrase
           -Z { low | high }   --secure-mode { low | high }
           policyfile.txt
```

**Підсумок параметрів для команди `tripwire`:**

```bash
SYNOPSIS
  Database Initialization:    tripwire { -m i | --init } [ options... ]
  Integrity Checking:    tripwire { -m c | --check } [ options... ]
            [ object1 [ object2... ]]
  Database Update:      tripwire { -m u | --update } [ options... ]
  Policy update:     tripwire { -m p | --update-policy } [ options... ]
            policyfile.txt
  Test:     tripwire { -m t | --test } [ options... ]

```

### `twadmin`

Утиліта `twadmin` виконує адміністративні функції, пов’язані з файлами tripwire та параметрами конфігурації. Зокрема, `twadmin` дозволяє кодувати, декодувати, підписувати та перевіряти файли Tripwire і надає засоби для створення та зміни локальних ключів і ключів сайту.

```bash
Створити файл конфігурації:  twadmin [-m F|--create-cfgfile][options] cfgfile.txt
Друк файлу конфігурації:   twadmin [-m f|--print-cfgfile] [options]
Створити файл політики:     twadmin [-m P|--create-polfile] [options] polfile.txt
Файл політики друку:     twadmin [-m p|--print-polfile] [options]
Видалити шифрування:     twadmin [-m R|--remove-encryption] [options] [file1...]
Шифрування:       twadmin [-m E|--encrypt] [options] [file1...]
Вивчіть шифрування:     twadmin [-m e|--examine] [options] [file1...]
Генерувати ключі:       twadmin [-m G|--generate-keys] [options]
```

### `twprint`

Друкує файли бази даних Tripwire і звітів у звичайному текстовому форматі.

**Режим друку звіту:**

```bash
-m r                     --print-report
-v                       --verbose
-s                       --silent, --quiet
-c cfgfile            --cfgfile cfgfile
-r report              --twrfile report
-L localkey            --local-keyfile localkey
-t { 0|1|2|3|4 }       --report-level { 0|1|2|3|4 }
```

**Режим друку бази даних:**

```bash
-m d                   --print-dbfile
-v                       --verbose
-s                       --silent, --quiet
-c cfgfile             --cfgfile cfgfile
-d database            --dbfile database
-L localkey            --local-keyfile localkey
[object1 [object2 ...]
```

### `siggen`

`siggen` — це процедура збору підписів для Tripwire. Це утиліта, яка відображає значення хеш-функції для вказаних файлів.

```bash
Опції
       ‐t, --terse
              Terse mode.  Друкує запитувані хеші для заданого файлу в одному рядку, розділеному пробілами, без сторонньої інформації.

       ‐h, --шістнадцятковий
              Відображення результатів у шістнадцятковій системі нотації, а не в системі base64.

       ‐a, --всі
              Відображає всі значення хеш-функції (за замовчуванням).

       ‐C, --CRC32
              Відображає CRC-32, сумісну з POSIX 1003.2 32-розрядну циклічну перевірку надмірності.

       ‐M, --MD5
              Відображає MD5, алгоритм дайджесту повідомлень RSA Data Security, Inc.

       ‐S, --SHA
              Відображає SHA, реалізацію Tripwire стандарту безпечного хешування NIST, SHS (NIST FIPS 180).

       ‐H, --HAVAL
              Показати значення Haval, 128-бітний хеш-код.

       file1 [ file2... ]
              Список об'єктів файлової системи, для яких потрібно відобразити значення.
```

## Завдання 2

### Щоб встановити Tripwire

1. Перевірте, чи у вашій системі вже встановлено Tripwire. Впишіть:

    ```bash
    [root@localhost root]# rpm -q tripwire
    tripwire-*
    ```

    Якщо ви отримаєте результат, подібний до наведеного вище, це означає, що він уже встановлений. Пропустіть наступний крок.

2. Якщо у вас його не встановлено, отримайте двійковий файл Tripwire і встановіть його. Впишіть:

    ```bash
    [root@localhost root]# dnf -y install tripwire
    ```

### Щоб налаштувати Tripwire

Налаштування Tripwire включає (за потреби) налаштування файлу конфігурації Tripwire і файлу політики, а потім запуск сценарію налаштування. Сценарій запропонує вам ввести парольну фразу, яка використовуватиметься для підпису/захисту файлу конфігурації, файлу політики та файлу бази даних.

1. Змініть свій pwd на робочий каталог Tripwire. Введіть наступне:

    ```bash
    [root@localhost  root]# cd /etc/tripwire/
    ```

2. Перелічіть вміст каталогу

3. Використовуйте будь-який пейджер або текстовий редактор для перегляду/вивчення файлів у каталозі.

4. Ми приймемо налаштування, які постачаються з конфігурацією за замовчуванням. файл (twcfg.txt) і наданий файл політики за замовчуванням (twpol.txt).

5. Запустіть утиліту налаштування Tripwire як root. Вам буде запропоновано (двічі) ввести парольну фразу файлу ключа сайту. Виберіть будь-яку парольну фразу, яку ви НЕ забудете (ключ сайту призначений для файлів twcfg.txt і twpol.txt). Введіть:

    ```bash
    [root@localhost tripwire]# tripwire-setup-keyfiles
    .....
    Enter the site keyfile passphrase:
    Verify the site keyfile passphrase:
    ......
    Generating key (this may take several minutes)...Key generation complete.
    ```

    Далі вам буде запропоновано ввести локальний ключ. Знову виберіть інший пароль, ЯКИЙ ВИ не забудете. (Локальний ключ підписує файли бази даних tripwire і файли звітів)

    ```bash
    Enter the local keyfile passphrase:
    Verify the local keyfile passphrase:
    ....
    Generating key (this may take several minutes)...Key generation complete.

    ```

    Після вибору ваших парольних фраз програма `tripwire-setup-keyfiles` продовжить фактичне створення/підписання зашифрованих версій оригінальних простих текстових файлів (тобто буде створено tw.cfg і tw.pol відповідно). Вам знову буде запропоновано ввести парольні фрази, які ви вибрали раніше. На цьому етапі просто дотримуйтесь підказок, доки сценарій не завершить роботу.

    ```bash
    ----------------------------------------------
    Signing configuration file...
    Please enter your site passphrase: ********

    ----------------------------------------------
    Signing policy file...
    Please enter your site passphrase: ********
    ......

    Wrote policy file: /etc/tripwire/tw.pol
    ```

    !!! question "Лабораторне завдання:"

     Виведіть новий вміст каталогу /etc/tripwire.

6. Відповідно до попередження, яке ви отримали під час роботи утиліти `tripwire-setup-keyfiles`, тепер ви перемістите звичайні текстові версії файлу конфігурації та файлів політики з локальної системи. Ви можете зберегти їх на зовнішньому носії видалення або зашифрувати на місці (використовуючи, наприклад, такий інструмент, як GPG), АБО повністю видалити їх, якщо ви відчуваєте себе особливо сміливим. Впишіть:

    ```bash
    [root@localhost tripwire]# mkdir /root/tripwire_stuff && mv twcfg.txt twpol.txt /root/tripwire_stuff
    ```

!!! note "Примітка"

    Може бути корисно зберігати версії з простим текстом у безпечному місці, якщо ви забудете свої парольні фрази. Тоді ви завжди можете повторно запустити `tripwire-setup-keyfiles` на основі конфігурацій і політик, які ви налаштували з часом.

### Для ініціалізації бази даних

Ініціалізація бази даних — це термінологія Tripwire для створення початкового «незаплямованого» знімка файлів, які ви вирішили контролювати (на основі файлу політики). Це створює базу даних, а також підписує базу даних локальним ключем. База даних служить основою для всіх майбутніх перевірок цілісності.

1. Увійшовши в систему як root:

    ```bash
    [root@localhost tripwire]# tripwire --init

    Please enter your local passphrase:
    Parsing policy file: /etc/tripwire/tw.pol
    Generating the database...
    *** Processing Unix File System ***

    ```

    Коли буде запропоновано, введіть локальну парольну фразу. Створення бази даних завершиться, і ви повинні отримати результат, подібний до наведеного нижче:

    **Базу даних успішно створено.**

2. Використовуйте команду `ls`, щоб переконатися, що базу даних було створено у вказаному місці. Впишіть:

    ```bash
    [root@localhost tripwire]# ls -lh /var/lib/tripwire/$(hostname).twd
    -rw-r--r--. 1 root root 3.3M Sep 27 18:35 /var/lib/tripwire/localhost.twd
    ```

## Завдання 3

**Перевірка цілісності та перегляд звітів**

У цій вправі ви дізнаєтеся, як запустити перевірку цілісності системи та переглянути звіти, які Tripwire створює для вас.

### Щоб запустити перевірку цілісності

Запуск Tripwire у цьому режимі (режим перевірки цілісності) порівнює поточні об’єкти файлової системи з їхніми властивостями в базі даних tripwire. Розбіжності між базою даних і поточними об’єктами файлової системи виводяться на стандартний вихід, поки Tripwire працює в цьому режимі. Після завершення перевірки Tripwire також створює файл звіту в каталозі, зазначеному у файлі twcfg.txt (/var/lib/tripwire/report/).

1. Виконайте перевірку цілісності. Впишіть:

    ```bash
    [root@localhost tripwire]# tripwire --check
    ```

    Під час цієї перевірки ви побачите [очікуваний] потік попереджень.

    Перевірте в каталозі `/var/lib/tripwire/report`, щоб побачити, чи там також створено звіт для вас.

    !!! question "Лабораторне завдання:"

     Запишіть назву створеного файлу звіту.
    
     FILE_NAME =

2. Знову запустіть перевірку цілісності, але вручну вкажіть ім’я файлу звіту. Впишіть:

    ```bash
    [root@localhost tripwire]# tripwire -m c -r /root/tripwire_report.twr
    ```

3. Переконайтеся, що для вас створено новий файл у кореневому каталозі. Впишіть:

    ```bash
    [root@localhost tripwire]# ls -l /root/tripwire_report.twr
    ```

### Для перевірки звіту

Файли звітів Tripwire — це набір порушень правил, виявлених під час перевірки цілісності.

Є кілька способів переглянути файл звіту Tripwire:

- під час перевірки цілісності
- у вигляді електронного листа, автоматично надісланого вам
- за допомогою команди `twprint`, що надається разом із пакетом Tripwire

!!! note "Примітка"

    Ви, мабуть, помітили під час попередньої вправи, що tripwire за замовчуванням використовує комбінацію імені FQDN системи, дати та часу для іменування файлів звіту.

1. Спочатку перейдіть до каталогу звіту за замовчуванням і перегляньте звіт за замовчуванням, створений для вас у кроці 1 вище (FILE_NAME). Впишіть:

    ```bash
    [root@localhost report]# cd /var/lib/tripwire/report && twprint --print-report -r <FILE_NAME>
    ```

    Замініть <FILE_NAME> вище значенням, яке ви зазначили раніше.

    Щоб використати коротку форму наведеної вище команди, введіть:

    ```bash
    [root@localhost report]# twprint -m r -r <FILE_NAME> | less
    ```

    Ми перенаправляємо вихід до команди less, оскільки звіт швидко прокручується.

2. Тепер перегляньте інший звіт, який ви створили вручну, у домашньому каталозі root. Впишіть:

    ```bash
    [root@localhost root]# cd && twprint --print-report -r /root/tripwire_report.twr | less
    ```

3. Уважно вивчіть вихід файлу звіту.

4. Ви повинні були знову помітити, що Tripwire створив двійкові форми/форми даних для файлів звітів. Створіть лише текстову версію файлу звіту в кореневому домашньому каталозі. Впишіть:

    ```bash
    [root@localhost root]# twprint --print-report -r /root/tripwire_report.twr > tripwire_report.txt
    ```

### Для перегляду звітів електронною поштою

Тут ви перевірите роботу електронної пошти Tripwire. Система сповіщень електронною поштою Tripwire використовує налаштування, указані у файлі конфігурації Tripwire. (twcfg.txt).

1. Спочатку перегляньте файл конфігурації та запам’ятайте змінну(-и), яка керує системою сповіщень електронною поштою Tripwire. Щоб переглянути тип файлу конфігурації:

    ```bash
    [root@localhost report]# twadmin  -m f | less
    ```

    !!! question "Лабораторне завдання:"

     Запишіть відповідну(і) змінну(и).

2. Далі переконайтеся, що ваша локальна поштова система запущена та працює, перевіривши стан Postfix. Впишіть:

    ```bash
    [root@localhost report]# systemctl -n 0 status postfix
    .......
         Active: active (running) since Thu 2023-08-31 16:21:26 UTC; 3 weeks 6 days ago
    .......
    ```

    Ваш результат має бути подібним до наведеного вище. Якщо ваша система розсилки не працює, спочатку усуньте її та запустіть її, перш ніж продовжувати.

3. Надішліть тестове повідомлення root. Впишіть:

    ```bash
    [root@localhost report]# tripwire --test --email root
    ```

4. Використовуйте поштову програму для перевірки пошти root. Впишіть:

    ```bash
    [root@localhost report]# mail
    ```

    Суперкористувач має мати повідомлення з темою «Тестове повідомлення електронної пошти від Tripwire»

5. Переконавшись, що функція електронної пошти працює, ви можете спробувати вручну надіслати собі копію одного зі звітів.

    !!! question "Питання"
   
        Яка команда для цього?

### Тонка настройка Tripwire

Після інсталяції Tripwire, створення знімка системи та запуску першої перевірки цілісності вам, швидше за все, знадобиться точно налаштувати tripwire відповідно до потреб вашого конкретного середовища. Це здебільшого тому, що файл конфігурації та політики за замовчуванням, який постачається разом із tripwire, може не зовсім відповідати вашим потребам або не відображати фактичні об’єкти у вашій файловій системі.

Вам потрібно з’ясувати, чи є порушення файлової системи, про які повідомляється у файлі звіту під час перевірки цілісності, фактичними порушеннями чи законними/авторизованими змінами об’єктів вашої файлової системи. Знову ж таки, Tripwire пропонує кілька способів зробити це.

### Оновлення файлу політики

Використовуючи цей метод, ви зміните або точно налаштуєте те, що tripwire вважає порушенням об’єктів вашої файлової системи, змінивши правила у файлі політики. Потім базу даних можна оновити без повної повторної ініціалізації. Це економить час і зберігає безпеку, зберігаючи файл політики синхронізованим із базою даних, яку він використовує.

Ви будете використовувати файл звіту, який ви створили раніше ( /root/tripwire_report.txt ), щоб точно налаштувати файл політики, спочатку заборонивши tripwire повідомляти про відсутність файлів, які ніколи не були у файловій системі.

Це допоможе значно скоротити довжину файлу звіту, яким потрібно керувати.

#### Для точного налаштування Tripwire

1. Використовуйте команду grep, щоб відфільтрувати всі рядки у файлі звіту, які посилаються на відсутні файли (тобто Рядки, що містять слово «Ім’я файлу»). Перенаправте вихід в інший файл - tripwire_diffs.txt. Впишіть:

    ```bash
    [root@localhost root]# grep Filename  /root/tripwire_report.txt > tripwire_diffs.txt
    ```

2. Перегляньте вміст файлу, який ви створили вище. Впишіть:

    ```bash
    [root@localhost root]# less tripwire_diffs.txt
    207:     Filename: /proc/scsi

    210:     Filename: /root/.esd_auth

    213:     Filename: /root/.gnome_private

    216:     Filename: /sbin/fsck.minix

    219:     Filename: /sbin/mkfs.bfs
    ..................................
    ```

3. Тепер вам потрібно відредагувати файл політики tripwire і закоментувати або видалити записи у файлі, яких там не повинно бути. Наприклад, деякі файли відсутні у вашій системі, а також файли, які, ймовірно, ніколи не будуть у вашій системі. Наприклад, одним із файлів, які файл політики намагається контролювати, є файл /proc/scsi. Якщо у вашій системі немає пристрою SCSI, то немає сенсу контролювати цей файл.

    Іншим спірним прикладом того, що контролювати чи ні контролювати, є різні файли блокувань у каталозі `/var/lock/subsys/`. Вибір моніторингу цих файлів має бути особистим рішенням.

    Повторно створіть текстову версію файлу політики - на випадок, якщо ви видалили його (як рекомендовано) з локальної системи. Впишіть:

    ```bash
    [root@localhost root]# twadmin --print-polfile  > twpol.txt
    ```

4. Відредагуйте створений вище текстовий файл за допомогою будь-якого текстового редактора. Закоментуйте посилання на об’єкти, які ви не хочете контролювати. Ви можете використовувати створений раніше файл tripwire_diffs.txt як орієнтир. Впишіть:

    ```bash
    [root@localhost  root]# vi twpol.txt
    ```

    Збережіть зміни у файлі та закрийте його.

5. Запустіть `tripwire` у режимі оновлення файлу політики. Впишіть:

    ```bash
    [root@localhost root]# tripwire  --update-policy   /root/twpol.txt
    ```

    Коли з’явиться відповідний запит, введіть ваші локальні та сайтові парольні фрази.

    Новий підписаний і зашифрований файл політики буде створено для вас у каталозі `/etc/tripwire/`.

6. Видаліть або видаліть текстову версію файлу політики з локальної системи.

7. Виконання команди на кроці 5 вище також створить для вас файл звіту в каталозі `/var/lib/tripwire/report directory`.

    !!! Question "Лабораторне завдання:"
   
        Запишіть назву останнього файлу звіту.
       
        <LATEST_REPORT>

8. Повторно запустіть перевірку цілісності системи, доки не переконаєтеся, що у вас є хороша базова лінія системи, на основі якої можна приймати майбутні рішення.

    !!! Question "Питання"
   
        Яка команда для цього?

### Оновлення бази даних

Запуск `tripwire` у режимі оновлення бази даних після перевірки цілісності забезпечує швидкий і брудний спосіб точного налаштування Tripwire. Це пояснюється тим, що режим оновлення бази даних дозволяє узгодити будь-які відмінності між базою даних і поточною системою.  Це дозволить запобігти відображенню порушень у майбутніх звітах.

Цей процес оновлення економить час, дозволяючи оновлювати базу даних без необхідності її повторно ініціалізувати.

#### Для оновлення бази даних

1. Змініть свій pwd на місце, де Tripwire зберігає файли звітів у вашій системі. Впишіть:

    ```bash
    [root@localhost root]# cd /var/lib/tripwire/report/
    ```

2. Спочатку ви використаєте режим оновлення бази даних в інтерактивному режимі. Впишіть:

    ```bash
    [root@localhost report]# tripwire --update  -Z  low  -r  <LATEST_REPORT>
    ```

    Замініть <LATEST_REPORT> назвою файлу звіту, яку ви зазначили раніше.

    Наведена вище команда також запустить текстовий редактор за замовчуванням (наприклад, `vi`), який надасть вам так звані «оновлені скриньки для голосування». Можливо, знадобиться прокрутити файл.

    Записи, позначені «[x]», означають, що базу даних слід оновити цим конкретним об’єктом.

    Видаліть «x» із урни «[ ]», щоб запобігти оновленню бази даних новими значеннями для цього об’єкта.

    Використовуйте звичайні натискання клавіш текстового редактора, щоб зберегти та вийти з редактора.

3. Далі спробуйте використати режим оновлення бази даних у неінтерактивний спосіб. тобто ви погодитеся, що всі записи у файлі звіту будуть прийняті без запиту. Впишіть:

    ```bash
    [root@localhost report]# tripwire --update -Z  low -a -r  <LATEST_REPORT>
    ```

### Файл конфігурації Tripwire

Ви почнете ці вправи, спочатку налаштувавши файл конфігурації. У попередній вправі вам порадили видалити або видалити всі версії відкритого тексту файлу Tripwire із вашої системи. Ви створите трохи безпечнішу установку Tripwire, відредагувавши деякі змінні у файлі конфігурації Tripwire. Ви вкажете, що Tripwire має завжди шукати двійкові версії політики та конфігураційного файлу на знімному носії, такому як дискета або компакт-диск.

1. Змініть свій pwd на каталог /etc/tripwire.

2. Згенеруйте версію конфігураційного файлу в відкритому вигляді. Впишіть:

    ```bash
    [root@localhost tripwire]# twadmin --print-cfgfile  > twcfg.txt
    ```

3. Відкрийте файл конфігурації, який ви створили вище, у текстовому редакторі. Впишіть:

    ```bash
    [root@localhost tripwire]# vi twcfg.txt
    ```

    Відредагуйте файл, щоб він виглядав як приклад файлу нижче:

    (ПРИМІТКА: щойно додані та змінені змінні були виділені для вас)

    ```bash
    1 ROOT                     =/usr/sbin

    2 POLFILE                  =/mnt/usbdrive/tw.pol

    3 DBFILE                   =/var/lib/tripwire/$(HOSTNAME).twd

    4 REPORTFILE             =/var/lib/tripwire/report/$(HOSTNAME)-$(DATE).twr

    5 SITEKEYFILE            =/mnt/usbdrive/site.key

    6 LOCALKEYFILE      =/mnt/usbdrive/$(HOSTNAME)-local.key

    7 EDITOR                   =/bin/vi

    8 LATEPROMPTING    =false

    9 LOOSEDIRECTORYCHECKING   =true

    10 GLOBALEMAIL                =root@localhost

    11 MAILNOVIOLATIONS           =true

    12 EMAILREPORTLEVEL         =3

    13 REPORTLEVEL                =3

    14 MAILMETHOD                 =SENDMAIL

    15 SYSLOGREPORTING         =true

    16 MAILPROGRAM                =/usr/sbin/sendmail -oi -t
    ```

    !!! question "Лабораторне завдання:"

     Перегляньте сторінку довідки для “twconfig”, щоб дізнатися, для чого призначені наступні змінні:

        ```txt
        LOOSEDIRECTORYCHECKING

        GLOBALEMAIL

        SYSLOGREPORTING
        ```

4. Змонтуйте носій для видалення в каталог /mnt/usbdrive. Впишіть:

    ```bash
    [root@localhost tripwire]# mount /dev/usbdrive   /mnt/usbdrive
    ```

    !!! note "Примітка"  

     Якщо ви вирішите зберігати свої файли в іншому місці (наприклад, на компакт-диску), внесіть необхідні зміни до команд.

5. Перемістіть ключ сайту, локальний ключ і двійкові файли в розташування, указане в новому файлі конфігурації. Впишіть:

    ```bash
    [root@localhost tripwire]# mv site.key tw.pol localhost.localdomain-local.key /mnt/usbdrive
    ```

6. Створіть двійкову версію відкритого текстового файлу конфігурації. Впишіть:

    ```bash
    [root@localhost tripwire]# twadmin --create-cfgfile -S /mnt/usbdrive/site.key twcfg.txt*
    ```

    Для вас буде створено файл `/etc/tripwire/tw.cfg`.

7. Перевірте своє нове налаштування. Від’єднайте USB-накопичувач і вийміть його.

8. Спробуйте запустити одну з команд `tripwire`, для якої потрібні файли, збережені на дисководі. Впишіть:

    ```bash
    [root@localhost tripwire]# twadmin --print-polfile

    ### Error: File could not be opened.

    ### Filename: /mnt/usbdrive/tw.pol

    ### No such file or directory

    ###

    ### Unable to print policy file.

    ### Exiting...
    ```

    Ви повинні отримати помилку, подібну до наведеної вище.

9. Підключіть носій, де зберігаються ваші файли Tripwire, і повторіть команду вище.

    !!! question "Питання"
   
        Команда виконана успішно цього разу?

10. Знайдіть і видаліть усі звичайні текстові версії конфігураційних файлів Tripwire, які ви створили на даний момент у своїй системі.

Необхідність монтувати та демонтувати знімний носій кожного разу, коли ви хочете адмініструвати аспект tripwire, може бути ускладненням, але винагородою може бути додаткова безпека. Ви точно захочете зберегти незайману версію бази даних tripwire на носії лише для читання, такому як DVD.

### ДОДАТКОВІ ВПРАВИ

1. Налаштуйте інсталяцію tripwire, запускайте перевірку цілісності щодня о 2 годині ночі та надсилайте звіт про перевірку цілісності електронною поштою суперкористувачеві системи.

    !!! hint "Підказка"
   
        Вам може знадобитися зробити це за допомогою завдання cron.
