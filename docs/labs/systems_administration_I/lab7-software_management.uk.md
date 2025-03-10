---
author: Wale Soyinka
contributors: Steven Spencer, tianci li, Ganna Zhyrnova
tested on: 8.8
tags:
  - лабораторна вправа
  - управління програмним забезпеченням
---

# Лабораторна робота 7: Керування та інсталяція програмного забезпечення

## Завдання

Після виконання цієї лабораторної роботи ви зможете:

- Надсилати пакети запитів для отримання інформації
- Встановлювати програмне забезпечення з бінарних пакетів
- Вирішувати деякі основні проблеми залежностей
- Компілювати та встановлювати програмне забезпечення з джерел

Приблизний час виконання цієї лабораторної роботи: 90 хвилин

## Бінарні та вихідні файли

Програми, встановлені у вашій системі, залежать від кількох факторів. Основний фактор залежить від груп програмних пакетів, вибраних під час встановлення операційної системи. Інший фактор залежить від того, що було зроблено з системою з моменту її використання.

Ви побачите, що одним із ваших рутинних завдань як системного адміністратора є керування програмним забезпеченням. Це часто включає:

- встановлення нового програмного забезпечення
- видалення програмного забезпечення
- оновлення вже встановленого програмного забезпечення

Програмне забезпечення можна встановити в системах на базі Linux кількома способами. Ви можете встановити з вихідного коду або попередньо скомпільованих двійкових файлів. Останній спосіб є найпростішим, але він також найменш настроюваний. Більшість роботи вже зроблено за вас, коли ви встановлюєте з попередньо скомпільованих двійкових файлів. Тим не менш, ви повинні знати назву та де знайти потрібне програмне забезпечення.

Майже все програмне забезпечення спочатку надходить у вигляді вихідних файлів мови програмування C або "C++". Вихідні програми зазвичай розповсюджуються як архіви вихідних файлів. Зазвичай файли tar або gzip d, або bzip2. Це означає, що вони надходять у стисненому вигляді або як єдиний пучок.

Більшість розробників зробили свій вихідний код відповідним до стандартів GNU, що полегшило обмін. Це також означає, що пакунки будуть скомпільовані на будь-якій UNIX або UNIX-подібній системі (наприклад, Linux).

RPM є основним інструментом для керування програмами (пакетами) у дистрибутивах на основі Red Hat, таких як Rocky Linux, Fedora, Red Hat Enterprise Linux (RHEL), openSuSE, Mandrake тощо.

Програми, які використовуються для керування програмним забезпеченням у дистрибутивах Linux, називаються менеджерами пакетів. Прикладами є:

- The Red Hat Package Manager (`rpm`). Пакунки мають суфікс «.rpm»
- The Debian package management system (`dpkg`).  Пакунки мають суфікс «.deb»

Далі наведено деякі популярні параметри командного рядка та синтаксис для команди RPM:

### `rpm`

Використання: rpm [OPTION...]

**ЗАПИТИ ПАКЕТІВ**

```bash
Опції пакетів (з -q або --query):
  -c, --configfiles                  список усіх конфігураційних файлів
  -d, --docfiles                     перелік всіх файлів документації
  -L, --licensefiles                 перелік всіх ліцензійних файлів
  -A, --artifactfiles                список усіх файлів артефактів
      --dump                         основна інформація про файл
  -l, --list                         список файлів у пакеті
      --queryformat=QUERYFORMAT      використання наступного формату запиту
  -s, --state                        відображення стану файлів у списку
```

**ПЕРЕВІРКА ПАКЕТІВ**

```bash
Опції верифікації (з -V або --verify):
      --nofiledigest                 не перевіряти дайджест файлів
      --nofiles                      не перевіряти файли в пакеті
      --nodeps                       не перевіряти залежності пакетів
      --noscript                     не виконувати сценарії перевірки
```

**ВСТАНОВЛЕННЯ, ОНОВЛЕННЯ ТА ВИДАЛЕННЯ ПАКЕТІВ**

```bash
Параметри встановлення/оновлення/видалення:
      --allfiles                     інсталювати всі файли, навіть конфігурації, які інакше можна було б пропустити
  -e, --erase=<package>+             стерти (видалити) пакет
      --excludedocs                  не встановлювати документацію
      --excludepath=<path>           пропускати файли з провідним компонентом <path>
      --force                        скорочення для --replacepkgs --replacefiles
  -F, --freshen=<packagefile>+       пакети оновлення, якщо вони вже встановлені
  -h, --hash                         друкувати хеш-мітки під час встановлення пакетів (добре з -v)
      --noverify                     скорочення для --ignorepayload --ignoresignature
  -i, --install                      встановити пакет(и)
      --nodeps                       не перевіряти залежності пакетів
      --noscripts                    не виконувати пакетний скриптлет(и)
      --percent                      друкувати відсотки як встановлення пакетів
      --prefix=<dir>                 перемістити пакет до <dir>, якщо його можна перемістити
      --relocate=<old>=<new>         перемістити файли зі шляху <old> до <new>
      --replacefiles                ігнорувати конфлікти файлів між пакетами
      --replacepkgs                  перевстановити, якщо пакет уже присутній
      --test                         не встановлюйте, а скажіть, буде працювати чи ні
  -U, --upgrade=<packagefile>+       пакет(и) оновлення
      --reinstall=<packagefile>+     перевстановити пакет(и)
```

## Завдання 1

### Встановлення, запит і видалення пакетів

У цій лабораторній роботі ви дізнаєтеся, як використовувати систему RPM і встановити зразок програми у вашій системі.

!!! tip "Підказка"

```
У вас є багато варіантів, звідки отримати пакети Rocky Linux. Ви можете вручну завантажити їх із надійних [або ненадійних] сховищ. Ви можете отримати їх із дистрибутива ISO. Ви можете отримати їх із централізованого спільного розташування за допомогою таких протоколів, як - nfs, git, https, ftp, smb, cifs тощо. Якщо вам цікаво, ви можете переглянути наступний офіційний веб-сайт і переглянути відповідне сховище для потрібного пакета:

https://download.rockylinux.org/pub/rocky/8.8/
```

#### Запит пакетів для отримання інформації.

1. Щоб переглянути список усіх пакетів, які зараз встановлено у вашій локальній системі, введіть:

  ```bash
  $ rpm -qa
  python3-gobject-base-*
  NetworkManager-*
  rocky-repos-*
  ...<OUTPUT TRUNCATED>...
  ```

  Ви повинні побачити довгий список.

2. Давайте заглибимося глибше та дізнаємося більше про один із пакетів, встановлених у системі. Ми розглянемо NetworkManager. Ми будемо використовувати параметри --query (-q) і --info (-i) з командою `rpm`. Впишіть:

  ```bash
  $ rpm -qi NetworkManager
  Name        : NetworkManager
  Epoch       : 1
  ...<OUTPUT TRUNCATED>...
  ```

  Це величезна кількість інформації (метаданих)!

3. Скажімо, нас цікавить лише поле «Підсумок» попередньої команди. Ми можемо використовувати опцію --queryformat rpm, щоб фільтрувати інформацію, яку ми отримуємо з опції запиту.

  Наприклад, щоб переглянути лише поле Summary, введіть:

  ```bash
  rpm -q --queryformat '%{summary}\n' NetworkManager
  ```

  Назва поля нечутлива до регістру.

4. Щоб переглянути поля Version та Summary встановленого типу пакета NetworkManager:

  ```bash
  rpm -q --queryformat '%{version}  %{summary}\n' NetworkManager
  ```

5. Введіть команду, щоб переглянути інформацію про пакет bash, встановлений у системі.

  ```bash
  rpm -qi bash
  ```

  !!! note "Примітка"

  ```
   Попередні вправи стосувалися запитів і роботи з пакетами, уже встановленими в системі. У наступних вправах ми почнемо працювати з пакетами, які ще не встановлено. Ми будемо використовувати програму DNF для завантаження пакетів, які використовуватимемо в наступних кроках. 
  ```

6. По-перше, переконайтеся, що програму `wget` ще не встановлено в системі. Впишіть:

  ```bash
  rpm -q wget
  package wget is not installed
  ```

  Схоже, `wget` не встановлено в нашій демонстраційній системі.

7. Починаючи з Rocky Linux 8.x, команда `dnf download` дозволить вам отримати останній пакет `rpm` для `wget`. Впишіть:

  ```bash
  dnf download wget
  ```

8. Використовуйте команду `ls`, щоб переконатися, що пакет завантажено у ваш поточний каталог. Впишіть:

  ```bash
  ls -lh wg*
  ```

9. Використовуйте команду `rpm`, щоб отримати інформацію про завантажений wget-\*.rpm. Впишіть:

  ```bash
  rpm -qip wget-*.rpm
  Name        : wget
  Architecture: x86_64
  Install Date: (not installed)
  Group       : Applications/Internet
  ...<TRUNCATED>...
  ```

  !!! question "Питання"

  ```
   Виходячи з результатів попереднього кроку, що саме таке пакет `wget`? Підказка: ви можете використовувати параметр формату запиту `rpm`, щоб переглянути поле опису пакета завантаження.
  ```

10. Якщо вас цікавить пакет `wget files-.rpm`, ви можете перелічити всі файли, включені до пакета, ввівши:

  ```bash
  rpm -qlp wget-*.rpm | head
  /etc/wgetrc
  /usr/bin/wget
  ...<TRUNCATED>...
  /usr/share/doc/wget/AUTHORS
  /usr/share/doc/wget/COPYING
  /usr/share/doc/wget/MAILING-LIST
  /usr/share/doc/wget/NEWS
  ```

11. Давайте переглянемо вміст файлу `/usr/share/doc/wget/AUTHORS`, зазначеного як частину пакета `wget`. Ми будемо використовувати команду `cat`. Впишіть:

  ```bash
  cat /usr/share/doc/wget/AUTHORS
  cat: /usr/share/doc/wget/AUTHORS: No such file or directory
  ```

  `wget` [ще] не встановлено в нашій демонстраційній системі! Отже, ми не можемо переглянути файл AUTHORS, який запаковано з ним!

12. Перегляньте список файлів, які постачаються з іншим пакетом (curl), _вже_ встановленим у системі. Впишіть:

  ```bash
  $ rpm -ql curl
  /usr/bin/curl
  /usr/lib/.build-id
  /usr/lib/.build-id/fc
  ...<>...
  ```

  !!! note "Примітка"

  ```
  Ви помітите, що вам не потрібно було посилатися на повну назву пакета `curl` у попередній команді. Це тому, що `curl` уже встановлено.
  ```

#### Розширені знання про назву пакета

- **Повна назва пакета**: коли ви завантажуєте пакет із надійного джерела (наприклад, веб-сайт постачальника, сховище розробника), ім’я завантаженого файлу є повним ім’ям пакета, наприклад -- htop-3.2.1- 1.el8.x86_64.rpm. Під час використання команди `rpm` для встановлення/оновлення цього пакунка об’єкт, керований командою, має бути повною назвою (або відповідним символом узагальнення) пакунка, наприклад:

  ```bash
  rpm -ivh htop-3.2.1-1.el8.x86_64.rpm
  ```

  ```bash
  rpm -Uvh htop-3.2.1-1.*.rpm
  ```

  ```bash
  rpm -qip htop-3.*.rpm
  ```

  ```bash
  rpm -qlp wget-1.19.5-11.el8.x86_64.rpm
  ```

  Повна назва пакета відповідає умовам іменування, подібним до цього —— `[Package_Name]-[Version]-[Release].[OS].[Arch].rpm` or `[Package_Name]-[Version]-[Release].[OS].[Arch].src.rpm`

- **Назва пакета**: оскільки RPM використовує базу даних для керування програмним забезпеченням, база даних матиме відповідні записи після завершення встановлення пакета. Наразі робочий об’єкт команди `rpm` потребує лише введення імені пакета. як от:

  ```bash
  rpm -qi bash
  ```

  ```bash
  rpm -q systemd
  ```

  ```bash
  rpm -ql chrony
  ```

## Завдання 2

### Цілісність упаковки

1. Можна завантажити або отримати пошкоджений або зіпсований файл. Перевірте цілісність пакета `wget`, який ви завантажили. Впишіть:

  ```bash
  rpm -K  wget-*.rpm
  wget-1.19.5-10.el8.x86_64.rpm: digests signatures OK
  ```

  Повідомлення «digests signatures OK» у вихідних даних показує, що з пакетом все гаразд.

2. Давайте проявимо зловмисність і навмисно змінимо завантажений пакет. Це можна зробити, додавши будь-що до оригінального пакету або вилучивши щось із нього. Будь-що, що змінює пакунок у спосіб, який не передбачали вихідні пакувачі, пошкодить пакунок. Ми змінимо файл за допомогою команди echo, щоб додати рядок «haha» до пакета. Впишіть:

  ```bash
  echo haha >> wget-1.19.5-10.el8.x86_64.rpm 
  ```

3. Тепер спробуйте ще раз перевірити цілісність пакета за допомогою параметра -K rpm.

  ```bash
  $ rpm -K  wget-*.rpm
  wget-1.19.5-10.el8.x86_64.rpm: DIGESTS SIGNATURES NOT OK
  ```

  Зараз це зовсім інше повідомлення. Висновок «DIGESTS SIGNATURES NOT OK» чітко попереджає, що вам не слід намагатися використовувати або інсталювати пакет. Більше не варто довіряти.

4. Використовуйте команду `rm`, щоб видалити пошкоджений файл пакета `wget` і завантажити нову копію за допомогою `dnf`. Впишіть:

  ```bash
  rm wget-*.rpm  && dnf download wget
  ```

  Ще раз перевірте, чи нещодавно завантажений пакет пройшов перевірку цілісності RPM.

## Завдання 3

### Встановлення пакетів

Під час інсталяції програмного забезпечення у вашій системі ви можете наштовхнутися на проблеми «невдалих залежностей». Це особливо часто трапляється під час використання низькорівневої утиліти RPM для ручного керування програмами в системі.

Наприклад, якщо ви спробуєте встановити пакет «abc.rpm», інсталятор RPM може скаржитися на деякі невдалі залежності. Він може сказати вам, що для пакета «abc.rpm» спочатку потрібно встановити інший пакет «xyz.rpm». Проблема залежностей виникає через те, що програми майже завжди залежать від іншого програмного забезпечення чи бібліотеки. Якщо необхідної програми або спільної бібліотеки ще немає в системі, перед установкою цільової програми потрібно виконати цю передумову.

Утиліта RPM низького рівня часто знає про взаємозалежності між програмами. Але зазвичай він не знає, як і де отримати програму чи бібліотеку, необхідну для вирішення проблеми. Іншими словами, RPM знає _що_ і _як_, але не має вбудованої можливості відповісти на запитання _де_. Тут сяють такі інструменти, як `dnf`, `yum` тощо.

#### Для встановлення пакетів

У цій вправі ви спробуєте встановити пакет `wget` (wget-\*.rpm).

1. Спробуйте встановити програму `wget`. Використовуйте параметри командного рядка RPM -ivh. Впишіть:

  ```bash
  rpm -ivh wget-*.rpm
  error: Failed dependencies:
      libmetalink.so.3()(64bit) is needed by wget-*
  ```

  Відразу - проблема залежності! Зразок результату показує, що `wget` потребує якогось файлу бібліотеки під назвою "libmetalink.so.3"

  !!! note "Примітка"

  ```
   Відповідно до результатів тесту вище, для пакета wget-*.rpm потрібно встановити пакет libmetalink-*.rpm. Іншими словами, libmetalink є необхідною умовою для встановлення wget-*.rpm. Ви можете примусово встановити пакет wget-*.rpm за допомогою параметра «nodeps», якщо знаєте, що робите, але це, як правило, ПОГАНА практика. 
  ```

2. RPM дав нам підказку про те, чого не вистачає. Ви пам’ятаєте, що `rpm` знає, що і як, але не обов’язково знає, де. Скористаємося утилітою `dnf`, щоб визначити назву пакета, який надає відсутню бібліотеку. Впишіть:

  ```bash
  $ dnf whatprovides libmetalink.so.3
  ...<TRUNCATED>...
  libmetalink-* : Metalink library written in C
  Repo        : baseos
  Matched from:
  Provide    : libmetalink.so.3
  ```

3. З результату нам потрібно завантажити пакет `libmetalink`, який надає відсутню бібліотеку. Зокрема, нам потрібна 64-розрядна версія бібліотеки. Викличмо окрему утиліту (`dnf`), щоб допомогти нам знайти та завантажити пакет для нашої демонстраційної 64-розрядної (x86_64) архітектури. Впишіть:

  ```bash
  dnf download --arch x86_64  libmetalink
  ```

4. Тепер у вашому робочому каталозі має бути принаймні 2 пакети rpm. Використовуйте команду `ls`, щоб підтвердити це.

5. Встановіть відсутню залежність `libmetalink`. Впишіть:

  ```bash
  sudo rpm -ivh libmetalink-*.rpm
  ```

6. З установленою залежністю ми можемо повернутися до нашої початкової мети встановлення пакета `wget`. Впишіть:

  ```bash
  sudo rpm -ivh wget-*.rpm
  ```

  !!! note "Примітка"

  ````
   RPM підтримує транзакції. У попередніх вправах ми могли виконати одну транзакцію rpm, яка включала оригінальний пакет, який ми хотіли встановити, і всі пакети та бібліотеки, від яких він залежав. Було б достатньо однієї такої команди, як наведена нижче:

       ```bash
       rpm -Uvh  wget-*.rpm  libmetalink-*.rpm
       ```
  ````

7. Момент істини зараз. Спробуйте запустити програму `wget` без будь-яких опцій, щоб перевірити, чи вона встановлена. Впишіть:

  ```bash
  wget
  ```

8. Давайте подивимося на `wget` в дії. Використовуйте `wget`, щоб завантажити файл з Інтернету з командного рядка. Впишіть:

  ```bash
  wget  https://kernel.org
  ```

  Це завантажить стандартний index.html з веб-сайту kernel.org!

9. Використовуйте `rpm`, щоб переглянути список усіх файлів у програмі `wget`.

10. Використовуйте `rpm`, щоб переглянути будь-яку документацію, що міститься в `wget`.

11. Використовуйте `rpm`, щоб переглянути список усіх бінарних файлів, встановлених разом з пакетом `wget`.

12. Вам потрібно було встановити пакет `libmetalink`, щоб встановити `wget`. Спробуйте запустити або виконати `libmetalink` з командного рядка. Впишіть:

  ```bash
  libmetalink
  -bash: libmetalink: command not found
  ```

  !!! attention "Увага"

  ```
  Що це дає? Чому ви не можете запустити або виконати `libmetalink`?
  ```

#### Щоб імпортувати відкритий ключ через `rpm`

!!! tip "Підказка"

```
Ключі GPG, які використовуються для підпису пакетів, що використовуються в проекті Rocky Linux, можна отримати з різних джерел, таких як веб-сайт проекту, сайт FTP, носії розповсюдження, локальні джерела тощо. На випадок, якщо відповідний ключ відсутній у зв’язку ключів вашої системи RL, ви можете використати параметр `rpm` `--import` для імпорту відкритого ключа Rocky Linux з вашої локальної системи RL, виконавши: `sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY- rockyofficial`
```

!!! question "Питання"

```
Яка різниця між `rpm -Uvh` і `rpm -ivh` під час встановлення пакетів? Зверніться до сторінки довідки щодо `rpm`.
```

## Завдання 4

### Видалення пакетів

Видалити пакети так само просто, як встановити за допомогою менеджера пакетів (RPM) Red Hat.

У цій вправі ви спробуєте використати `rpm` для видалення деяких пакунків із системи.

#### Щоб видалити пакети

1. Видаліть пакет `libmetalink` з вашої системи. Впишіть:

  ```bash
  sudo rpm -e libmetalink
  ```

  !!! question "Питання"

  ```
   Поясніть, чому не вдалося зняти пакет?
  ```

2. Чистим і правильним способом видалення пакетів за допомогою RPM є видалення пакетів разом із їхніми залежностями. Щоб видалити пакет `libmetalink`, ми також повинні видалити пакет `wget`, який залежить від нього. Впишіть:

  ```bash
  sudo rpm -e libmetalink wget
  ```

  !!! note "Примітка"

  ```
   Якщо ви хочете зламати пакунок, який покладається на libmetalink, і *примусово* видалити пакунок із вашої системи, ви можете скористатися параметром rpm `--nodeps` так: `$ sudo rpm -e --nodeps libmetalink`.

   **i.** Параметр «nodeps» означає відсутність залежностей. Тобто ігнорувати всі залежності.  
   **ii.** Вище показано, як примусово видалити пакет із системи. Іноді це потрібно робити, але зазвичай це *не дуже добре*.   
   **iii.** Примусове видалення пакета «xyz», на який покладається інший встановлений пакет «abc», фактично робить пакет «abc» непридатним для використання або дещо зламаним.  
  ```

## Завдання 5

### DNF - менеджер пакетів

DNF — це менеджер пакетів для дистрибутивів Linux на основі RPM. Це наступник популярної утиліти YUM. DNF підтримує сумісність з YUM. Обидві утиліти мають схожі параметри командного рядка та синтаксис.

DNF є одним із багатьох інструментів для керування програмним забезпеченням на основі RPM, таким як Rocky Linux. Порівняно з `rpm`, ці інструменти вищого рівня допомагають спростити встановлення, видалення та запити пакетів. Важливо зазначити, що ці інструменти використовують базову структуру, надану системою RPM. Ось чому корисно зрозуміти, як використовувати RPM.

DNF (та інші інструменти, подібні до нього) діє як обгортка навколо RPM і надає додаткові функції, яких не пропонує RPM. DNF знає, як працювати із залежностями пакетів і бібліотек, а також знає, як використовувати налаштовані репозиторії для автоматичного вирішення більшості проблем.

Загальні параметри, які використовуються з утилітою `dnf`:

```bash
    використання: dnf [options] COMMAND

    Перелік команд:

    alias                     Список або створення псевдонімів команд
    autoremove                видалення всіх непотрібних пакунків, які спочатку були встановлені як залежні
    check                     перевірка наявності проблем у packagedb
    check-update              перевіряє наявність доступних оновлень пакетів
    clean                     видаляє кешовані дані
    deplist                   [deprecated, use repoquery --deplist] Перелічує залежності пакетів і які пакети їх надають
    distro-sync              синхронізує встановлені пакети з останніми доступними версіями
    downgrade                 Понижує пакет
    group                     відображає або використовує інформацію про групи
    help                     відображає корисне повідомлення про використання
    history                   відображає або використовує історію транзакцій
    info                     відображає детальну інформацію про пакет або групу пакетів
    install                 встановлює пакет або пакети у вашу систему
    list                      містить список пакетів або груп пакетів
    makecache                 генерує кеш метаданих
    mark                      позначає або знімає позначку встановлених пакунків як встановлених користувачем
    module                   Взаємодіє з модулями
    provides                  знаходить, який пакет надає дане значення
    reinstall                 перевстановлює пакет
    remove                    видаляє пакет або пакети з вашої системи
    repolist                  відображає налаштовані сховища програмного забезпечення
    repoquery                пошук пакетів, що відповідають ключовому слову
    repository-packages      запускає команди поверх усіх пакунків у заданому репозиторії
    search                    шукає деталі пакета для заданого рядка
    shell                     запускає інтерактивну оболонку DNF
    swap                      запускає інтерактивний мод DNF для видалення та встановлення однієї специфікації
    updateinfo                відображає поради щодо пакетів
    upgrade                   оновлює пакет або пакети у вашій системі
    upgrade-minimal           оновлення, але лише «найновіший» пакет відповідає, який вирішує проблему, що впливає на вашу систему

```

#### Щоб використовувати `dnf` для встановлення пакету

Якщо припустити, що ви видалили утиліту `wget` із вправи, ми використаємо DNF для встановлення пакета в наступних кроках. Процес із 2-3 кроків, який нам був потрібний раніше, коли ми встановлювали `wget` через `rpm`, слід скоротити до одноетапного процесу з використанням `dnf`. `dnf` тихо вирішить будь-які залежності.

1. По-перше, давайте переконаємося, що `wget` і `libmetalink` видалено з системи. Впишіть:

  ```bash
  sudo rpm -e wget libmetalink
  ```

  Після видалення, якщо ви спробуєте запустити `wget` з CLI, ви побачите повідомлення на зразок _wget: command not found_

2. Тепер використовуйте `dnf`, щоб встановити `wget`. Впишіть:

  ```bash
  sudo dnf -y install wget
  Dependencies resolved.
  ...<TRUNCATED>...
  Installed:
  libmetalink-*           wget-*
  Complete!
  ```

  !!! tip "Підказка"

  ```
   Параметр "-y", використаний у попередній команді, пригнічує підказку "[y/N]" для підтвердження дії, яку збирається виконати `dnf`. Це означає, що всі дії підтвердження (або інтерактивні відповіді) будуть «так» (у).
  ```

3. DNF надає параметр «Група середовища», який спрощує додавання нового набору функцій до системи. Щоб додати цю функцію, зазвичай потрібно інсталювати декілька пакунків окремо, але використовуючи `dnf`, все, що вам потрібно знати, це назва або опис потрібної функції. Використовуйте `dnf`, щоб відобразити список усіх доступних груп. Впишіть:

  ```bash
  dnf group list
  ```

4. Нас цікавить група/функція "Інструменти розробки". Давайте дізнаємося більше про цю групу. Впишіть:

  ```bash
  dnf group info "Development Tools"
  ```

5. Пізніше нам знадобляться деякі програми з групою «Development Tools». Встановіть групу «Development Tools» за допомогою `dnf`, виконавши:

  ```bash
  sudo dnf -y group install "Development Tools"
  ```

#### Щоб використовувати `dnf` для видалення пакетів

1. Щоб використати `dnf` для видалення типу пакета `wget`:

  ```bash
  sudo dnf -y remove wget
  ```

2. Використовуйте `dnf`, щоб переконатися, що пакет видалено із системи. Впишіть:

  ```bash
  sudo dnf -y remove wget
  ```

3. Спробуйте використати/запустити `wget`. Впишіть:

  ```bash
  wget
  ```

#### Щоб використовувати `dnf` для оновлення пакета

DNF може перевірити та встановити останню версію окремих пакетів, доступних у сховищах. Його також можна використовувати для встановлення певних версій пакетів.

1. Використовуйте опцію списку з `dnf`, щоб переглянути доступні у вашій системі версії програми `wget`. Впишіть:

  ```bash
  dnf list wget
  ```

2. Якщо ви хочете лише побачити, чи доступні оновлені версії для пакета, скористайтеся опцією перевірки оновлення з `dnf`. Наприклад, для типу пакета `wget`:

  ```bash
  dnf check-update wget
  ```

3. Тепер перерахуйте всі доступні версії пакета ядра для вашої системи. Впишіть:

  ```bash
  sudo dnf list kernel
  ```

4. Тепер перевірте, чи доступні оновлені пакети для встановленого пакета ядра. Впишіть:

  ```bash
  dnf check-update kernel
  ```

5. Оновлення пакетів можуть відбуватися через виправлення помилок, нові функції або виправлення безпеки. Щоб переглянути, чи є будь-які оновлення безпеки для пакета ядра, введіть:

  ```bash
  dnf  --security check-update kernel
  ```

#### Щоб використовувати `dnf` для оновлень системи

DNF можна використовувати для перевірки та встановлення останніх версій усіх пакетів, встановлених у системі. Періодична перевірка наявності оновлень є важливим аспектом адміністрування системи.

1. Щоб перевірити наявність оновлень для пакетів, які ви зараз інсталювали у своїй системі, введіть:

  ```bash
  $ sudo dnf -y remove wget
  ```

2. Щоб перевірити наявність оновлень безпеки для всіх пакетів, встановлених у вашій системі, введіть:

  ```bash
  $ sudo dnf -y remove wget
  ```

3. Щоб оновити всі пакети, встановлені у вашій системі, до найновіших версій, доступних для вашого дистрибутива:

  ```bash
  $ wget
  ```

## Завдання 6

### Створення програмного забезпечення з вихідного коду

Усе програмне забезпечення/програми/пакети походять із звичайних текстових файлів, які можна прочитати людиною. Файли спільно відомі як вихідний код. Пакети RPM, які встановлюються в дистрибутивах Linux, створюються з вихідного коду.

У цій вправі ви завантажите, скомпілюєте та встановите приклад програми з її вихідних файлів. Для зручності вихідні файли зазвичай поширюються як один стиснутий файл, який називається tar-ball (вимовляється як tar-dot-gee-zee).

Наступні вправи базуватимуться на відомому вихідному коді проекту Hello. `hello` — це проста програма командного рядка, написана мовою C++, яка лише друкує «hello» на терміналі. Ви можете дізнатися більше про [проект тут](http://www.gnu.org/software/hello/hello.html)

#### Щоб завантажити вихідний файл

1. Використовуйте `curl`, щоб завантажити останній вихідний код програми `hello`. Давайте завантажимо та збережемо файл у папці Downloads.

  https://ftp.gnu.org/gnu/hello/hello-2.12.tar.gz

#### Щоб розархівувати файл

1. Перейдіть до каталогу на вашій локальній машині, де ви завантажили вихідний код привітання.

2. Розпакуйте (розпакуйте) архів за допомогою програми tar. Впишіть:

  ```bash
  tar -xvzf hello-2.12.tar.gz
  ```

  Вихід

  ```bash
  hello-2.12/
  hello-2.12/NEWS
  hello-2.12/AUTHORS
  hello-2.12/hello.1
  hello-2.12/THANKS
  ...<TRUNCATED>...
  ```

3. Використовуйте команду `ls`, щоб переглянути вміст вашого pwd.

  Новий каталог під назвою hello-2.12 повинен був бути створений для вас під час де-тарування.

4. Перейдіть до цього каталогу та перегляньте його вміст. Впишіть:

  ```bash
  cd hello-2.12 ; ls
  ```

5. Перегляд будь-яких спеціальних інструкцій зі встановлення, які можуть постачатися з вихідним кодом, завжди є хорошою практикою. Ці файли зазвичай мають такі назви: INSTALL, README тощо.

  Використовуйте пейджер, щоб відкрити файл INSTALL і прочитати його. Впишіть:

  ```bash
  less INSTALL
  ```

  Вийдіть із пейджера, коли завершите перегляд файлу.

#### Щоб налаштувати пакет

Більшість програм мають функції, які користувач може ввімкнути або вимкнути. Це одна з переваг доступу до вихідного коду та встановлення з нього. Ви можете контролювати настроювані функції програми. Це на відміну від прийняття всього, що встановлює менеджер пакетів із попередньо скомпільованих двійкових файлів.

Сценарій, який зазвичай дозволяє налаштувати програмне забезпечення, зазвичай має влучну назву «configure»

!!! tip "Порада"

````
Переконайтеся, що ви встановили групу пакетів «Інструменти розробки» перед виконанням наступних вправ.

```bash
sudo dnf -y group install "Development Tools"
```
````

1. Скористайтеся командою `ls` ще раз, щоб переконатися, що у вас справді є файл з назвою _configure_ у вашому pwd.

2. Щоб побачити всі параметри, ви можете ввімкнути або вимкнути тип програми `hello`:

  ```bash
  ./configure --help
  ```

  !!! question "Питання"

  ```
   З результатів команди, що робить параметр «--prefix»?
  ```

3. Якщо ви задоволені стандартними параметрами, які пропонує сценарій налаштування. Впишіть:

  ```bash
  ./configure
  ```

  !!! note "Примітка"

  ```
   Сподіваюся, етап налаштування пройшов гладко, і ви можете перейти до етапу компіляції.

   Якщо ви отримуєте деякі помилки під час етапу налаштування, вам слід уважно переглянути кінцеву частину виводу, щоб побачити джерело помилки. Помилки *іноді* зрозумілі самі за себе, і їх легко виправити. Наприклад, ви можете побачити таку помилку:

   configure: error: no acceptable C compiler found in $PATH

   Наведена вище помилка просто означає, що у вас не встановлено компілятор C (наприклад, `gcc`) у системі або компілятор інстальовано десь не у вашій змінній PATH.
  ```

#### Скомпілювати пакет

Ви створите програму hello, виконавши наступні кроки. Ось де деякі програми, які ви встановили за допомогою групи Development Tools за допомогою DNF, стають у нагоді.

1. Використовуйте команду make, щоб скомпілювати пакет після запуску сценарію “configure”. Впишіть:

  ```bash
  make
  ```

  Вихід

  ```bash
  gcc  -g -O2   -o hello src/hello.o  ./lib/libhello.a
  make[2]: Leaving directory '/home/rocky/hello-2.12'
  ...<OUTPUT TRUNCATED>...
  make[1]: Leaving directory '/home/rocky/hello-2.12'
  ```

  Якщо все піде добре, цей важливий крок `make` допоможе створити остаточний двійковий файл `hello` програми.

2. Знову перерахуйте файли у вашому поточному робочому каталозі. Ви повинні побачити кілька новостворених файлів, включаючи програму `hello`.

#### Щоб встановити програму

Серед інших службових завдань останній крок інсталяції передбачає копіювання будь-яких двійкових файлів програми та бібліотек у відповідні папки.

1. Щоб установити програму hello, виконайте команду make install. Впишіть:

  ```bash
  sudo make install
  ```

  Це встановить пакет у місце, указане аргументом префікса за замовчуванням (--prefix), який раніше використовувався у сценарії «configure». Якщо не було встановлено жодного --prefix, буде використано стандартний префікс `/usr/local/`.

#### Щоб запустити програму hello

1. Використовуйте команду `whereis`, щоб побачити, де у вашій системі знаходиться програма `hello`. Впишіть:

  ```bash
  whereis hello
  ```

2. Спробуйте запустити програму `hello`, щоб побачити, що вона робить. Впишіть:

  ```bash
  hello
  ```

3. Знову запустіть `hello` з опцією `--help`, щоб побачити інші речі, які він може робити.

4. Тепер за допомогою `sudo` знову запустіть `hello` як суперкористувач. Впишіть:

  ```bash
  sudo hello
  ```

  Вихід

  ```bash
  sudo: hello: command not found
  ```

  !!! Question "Питання"

  ```
   Дослідіть, що викликає помилку, коли ви намагаєтесь запустити `hello` за допомогою sudo. Виправте проблему та переконайтеся, що програму `hello` можна використовувати з sudo.
  ```

  !!! tip "Підказка"

  ```
   Тестування програми як звичайного користувача є хорошою практикою, щоб переконатися, що звичайні користувачі можуть використовувати програму. Дозволи для двійкового файлу можуть бути встановлені неправильно, тому лише суперкористувач може використовувати програми. Це, звичайно, припускає, що ви дійсно хочете, щоб звичайні користувачі могли використовувати програму.
  ```

5. Це все. Завдання завершено!

## Завдання 7

### Перевірка цілісності файлу після встановлення пакета

Після встановлення відповідних пакетів у деяких випадках нам потрібно визначити, чи були пов’язані файли змінені, щоб запобігти зловмисним змінам іншими.

#### Перевірка файлу

Використання параметра "-V" команди `rpm`.

Візьміть програму синхронізації часу `chrony` як приклад, щоб проілюструвати значення її виводу.

1. Щоб продемонструвати, як працює перевірка пакету `rpm`, змініть файл конфігурації chrony - `/etc/chrony.conf`. (Передбачається, що ви встановили Chrony). Додайте 2 символи нешкідливого коментаря `##` у кінець файлу. Впишіть:

  ```bash
  echo -e "##"  | sudo tee -a /etc/chrony.conf
  ```

2. Тепер запустіть команду `rpm` з опцією `--verify`. Впишіть:

  ```bash
  rpm -V chrony
  ```

  Вихід

  ```bash
  S.5....T.  c  /etc/chrony.conf
  ```

  Результат розбивається на 3 окремі стовпці.

  - **Перший стовпець (S.5....T.)**

    Зразок вихідних даних - `S.5....T.` вказує на 9 полів, які використовуються для вказівки корисної інформації про дійсність файлів у пакеті RPM. Будь-яке поле чи характеристика, які пройшли певну перевірку/тест, позначається знаком «.».

    Ці 9 різних полів або перевірок описано тут:

    - S: Чи було змінено розмір файлу.
    - M: Чи було змінено тип файлу або права доступу до файлу (rwx).
    - 5: Чи змінено контрольну суму файлу MD5.
    - D: Чи було змінено номер пристрою.
    - L: Чи було змінено шлях до файлу.
    - U: Чи було змінено власника файлу.
    - G: Чи було змінено групу, до якої належить файл.
    - T: Чи було змінено mTime (час зміни) файлу.
    - P: Чи була змінена функція програми.

  - **Друга колонка (c)**

    - **c**: Вказує на зміни у файлі конфігурації. Це також можуть бути такі значення:
    - d: файл документації.
    - g: файл-привид. Дуже мало можна побачити.
    - l: файл ліцензії.
    - r: файл readme.

  - **Третій стовпець (/etc/chrony.conf)**

    - **/etc/chrony.conf**: Представляє шлях до зміненого файлу.
