- - -
author: Wale Soyinka contributors: Steven Spencer, Ganna Zhyrnova tested on: Всі версії tags:
  - лабораторні вправи
  - керування завантаженням, призначенням і службами
  - systemd
  - systemctl
- - -


# Лабораторна робота 3: Процеси завантаження та запуску


## Завдання


Виконавши цю лабораторну роботу, ви зможете

- вручну контролювати деякі процеси та служби запуску
- автоматично керувати послугами


Приблизний час виконання цієї лабораторної роботи: 50 хвилин


## Огляд процесу завантаження

Вправи в цій лабораторній роботі розпочнуться від процесу завантаження до входу користувача. Ці кроки перевірять і намагатимуться налаштувати частини процесів завантаження. Етапами високого рівня в процесі завантаження є:

*Підсумок кроків*

1. Апаратне забезпечення завантажує, читає та виконує завантажувальний сектор
2. Завантажувач виконується. Цей завантажувач є GRUB у більшості дистрибутивів Linux.
3. ядро розпаковується та виконується
4. ядро ініціалізує обладнання.
5. ядро монтує кореневу файлову систему
6. ядро виконує /usr/lib/systemd/systemd як PID 1.
7. systemd запускає модулі, необхідні та налаштовані для запуску цільового завантаження за замовчуванням
8. програми getty створюються на кожному визначеному терміналі.
9. getty запитує вхід.
10. getty виконує /bin/login для автентичного користувача.
11. вхід запускає оболонку


### systemd

systemd — це системний менеджер і менеджер служб для операційних систем Linux.

### systemd units

systemd забезпечує систему залежності між різними сутностями, які називаються «одиницями» ("units"). Юніти інкапсулюють різні об’єкти, необхідні для завантаження та обслуговування системи. Більшість одиниць налаштовуються у так званих файлах конфігурації одиниць — простих текстових файлах у стилі ini.

### Типи юнітів systemd

systemd має наступні 11 типів визначених юнітів:

*Service units* запускає та контролює демони та процеси, з яких вони складаються.

*Socket units* інкапсулює локальні IPC або мережеві сокети в системі, що корисно для активації на основі сокетів.

*Target units* використовуються для групування інших одиниць. Вони забезпечують добре відомі точки синхронізації під час завантаження

*Device units* розкриває пристрої ядра в systemd і може використовуватися для реалізації активації на основі пристрою.

*Mount units* контролює точки монтування у файловій системі

*Automount units* забезпечують можливості автоматичного монтування для монтування файлових систем за вимогою та розпаралеленого завантаження.

*Timer units* корисні для запуску активації інших одиниць на основі таймерів.

*Swap units* дуже схожі на модулі монтування та інкапсулюють розділи підкачки пам’яті або файли операційної системи.

*Path units* може використовуватися для активації інших служб, коли об’єкти файлової системи змінюються або модифікуються.

*Slice units* може використовуватися для групування одиниць, які керують системними процесами (таких як одиниці обслуговування та області дії), в ієрархічному дереві з метою управління ресурсами.

*Scope units* схожі на сервісні одиниці, але керують сторонніми процесами замість того, щоб запускати їх.

## Завдання 1

### /usr/lib/systemd/systemd | PID=1

Історично init називався багатьма іменами та мав кілька форм.

Незалежно від назви чи реалізації, init (або його еквівалент) часто називають *матір'ю всіх процесів*.

Сторінка довідки для «init» називає його батьківським для всіх процесів. Згідно з угодою, перша програма або процес ядра, який виконується, завжди має ідентифікатор процесу 1. Після запуску першого процесу він запускає інші служби, демони, процеси, програми тощо.

#### Для вивчення першого системного процесу

1. Увійдіть у систему як будь-який користувач. Запитуючи шлях до віртуальної файлової системи /proc/<PID>/comm, дізнайтеся назву процесу з ідентифікатором процесу 1. Впишіть:

    ```bash
    [root@localhost ~]# cat /proc/1/comm

    systemd
    ```

2. Виконайте команду `ls`, щоб переглянути шлях до віртуальної файлової системи /proc/<PID>/exe, а також ім’я та шлях до виконуваного файлу процесу з ідентифікатором процесу. з 1. Впишіть:

    ```bash
    [root@localhost ~]# ls -l /proc/1/exe

    lrwxrwxrwx 1 root root 0 Oct  5 23:56 /proc/1/exe -> /usr/lib/systemd/systemd
    ```

3. Спробуйте скористатися командою `ps`, щоб дізнатися назву процесу або програми, що стоїть за PID. Впишіть:

    ```bash
    [root@localhost ~]# ps -p 1 -o comm=

    systemd
    ```

4. Використовуйте команду `ps`, щоб переглянути повний шлях і будь-які аргументи командного рядка процесу або програми, що стоїть за PID 1. Впишіть:

    ```bash
    [root@localhost ~]# ps -p  1 -o args=

    /usr/lib/systemd/systemd --switched-root --system --deserialize 16
    ```

5. Щоб переконатися, що основним процесом, який традиційно називають init, є systemd, використовуйте `ls`, щоб підтвердити, що `init` є символічним посиланням на `systemd ` двійковий. Впишіть:

    ```bash
    [root@localhost ~]# ls -l /usr/sbin/init
    lrwxrwxrwx. 1 root root 22 Aug  8 15:33 /usr/sbin/init -> ../lib/systemd/systemd
    ```

6. Використовуйте команду `pstree`, щоб показати системні процеси у вигляді дерева. Впишіть:

    ```bash
    [root@localhost ~]# pstree --show-pids

    ```

## Завдання 2

### `systemd` Targets (RUNLEVELS)

`systemd` визначає та покладається на багато різних цілей для керування системою. У цій вправі ми зосередимося лише на 5 основних цілях. 5 основних цілей, розглянутих у цьому розділі, перераховані тут:

1. poweroff.target
2. rescue.target
3. multi-user.target - Завантажує систему з повною багатокористувацькою підтримкою без графічного середовища.
4. graphical.target - Завантажує систему з мережею, підтримкою кількох користувачів і менеджером відображення.
5. reboot.target

!!! tip "Порада"

    Цільові одиниці замінюють рівні виконання SysV у класичній системі ініціалізації SysV.

#### Для керування цілями systemd

1. Перелічіть УСІ (активні + неактивні + невдалі) доступні цілі на сервері.

    ```bash
    [root@localhost ~]# systemctl list-units --type target --all
    ```

2. Перелічіть лише поточні активні цілі. Впишіть:

    ```bash
    [root@localhost ~]# systemctl list-units -t target    
    ```

3. Використовуйте команду `systemctl`, щоб переглянути/отримати ім’я цілі за умовчанням, для завантаження якої налаштовано систему. Впишіть:

    ```bash
    [root@localhost ~]# systemctl get-default

    multi-user.target
    ```

4. Перегляньте вміст файлу юніту для цілі за замовчуванням (multi-user.target). Впишіть:

    ```bash
    [root@localhost ~]# systemctl cat multi-user.target

    # /usr/lib/systemd/system/multi-user.target
    ........
    [Unit]
    Description=Multi-User System
    Documentation=man:systemd.special(7)
    Requires=basic.target
    Conflicts=rescue.service rescue.target
    After=basic.target rescue.service rescue.target
    AllowIsolate=yes
    ```

    Зверніть увагу на деякі властивості та їхні значення, налаштовані в модулі multi-user.target. Такі властивості, як - Description, Documentation, Requires, After, та інші.

5. Юніт `basic.target` указана як значення властивості `Requires` для `multi-user.target`. Перегляньте файл блоку для basic.target. Впишіть:

    ```bash
    [root@localhost ~]# systemctl cat multi-user.target
    # /usr/lib/systemd/system/basic.target
    [Unit]
    Description=Basic System
    Documentation=man:systemd.special(7)
    Requires=sysinit.target
    Wants=sockets.target timers.target paths.target slices.target
    After=sysinit.target sockets.target paths.target slices.target tmp.mount
    RequiresMountsFor=/var /var/tmp
    ```

6. Команда `systemctl cat` показує лише підмножину властивостей і значень певної одиниці. Щоб переглянути дамп УСІХ властивостей і значень цільового блоку, скористайтеся підкомандою show. Команда `show` також відобразить властивості низького рівня. Показати ВСІ властивості multi-user.target, введіть:

    ```bash
    [root@localhost ~]# systemctl show  multi-user.target
    ```

7. Відфільтруйте властивості Id, Requires і Description із довгого списку властивостей у модулі multi-user.target. Впишіть:

    ```bash
    [root@localhost ~]# systemctl --no-pager show \
    --property  Id,Requires,Description  multi-user.target

    Id=multi-user.target
    Requires=basic.target
    Description=Multi-User System
    ```

8. Перегляньте служби та ресурси, які залучає multi-user.target під час запуску. Іншими словами, відображати те, що «бажає» multi-user.target. Впишіть:

    ```bash
    [root@localhost ~]# systemctl show --no-pager -p "Wants"  multi-user.target

    Wants=irqbalance.service sshd.service.....
    ...<SNIP>...
    ```

9.  Використовуйте команди `ls` і `file`, щоб дізнатися більше про зв’язок традиційної програми `init` з програмою `systemd`. Впишіть:

    ```bash
    [root@localhost ~]# ls -l /usr/sbin/init && file /usr/sbin/init

    lrwxrwxrwx. 1 root root 22 Aug  8 15:33 /usr/sbin/init -> ../lib/systemd/systemd
    /usr/sbin/init: symbolic link to ../lib/systemd/systemd
    ```

#### Щоб змінити ціль завантаження за замовчуванням


1. Встановити/змінити ціль за замовчуванням, з якої система завантажується. Використовуйте команду `systemctl set-default`, щоб змінити ціль за замовчуванням на `graphical.target`. Впишіть:

    ```bash
    [root@localhost ~]# systemctl set-default graphical.target

    ```

2. Перевірте, чи активна щойно встановлена ціль завантаження. Впишіть:

    ```bash
    [root@localhost ~]# systemctl is-active graphical.target

    inactive
    ```

    Зауважте, що вихідні дані показують, що ціль *не* активна, навіть якщо вона була встановлена як типова!

3. Для примусового переходу системи та негайного використання. заданої цілі, ви повинні використати підкоманду `isolate`. Введіть:

    ```bash
    [root@localhost ~]# systemctl isolate graphical.target
    ```

    !!! Warning "Важливо"

     Команда systemctl isolate може бути небезпечною, якщо її використовувати неправильно. Це тому, що він негайно зупинить процеси, не активовані в новій цілі, можливо, включаючи графічне середовище або термінал, який ви зараз використовуєте!

4. Перевірте ще раз, чи `graphical.target` зараз використовується та активний.

5. Запитуйте та переглядайте, які інші служби чи ресурси «Wants» graphical.target.

    !!! Question "Питання"
   
        Які основні відмінності між multi-user.target і graphical.target "Wants"?

6. Оскільки ваша система працює під керуванням операційної системи серверного класу, де повноцінне графічне середовище робочого столу може бути небажаним, перемкніть систему назад до більш відповідного multi-user.target. Впишіть:

    ```bash
    [root@localhost ~]# systemctl isolate multi-user

    ```

7.  Встановити/змінити ціль завантаження системи за замовчуванням на multi-user.target.

8.  Запустіть швидку [і додаткову] ручну перевірку, щоб побачити, на яку ціль вказує символічне посилання default.target, виконавши:

    ```bash
    [root@localhost ~]# ls -l /etc/systemd/system/default.target
    ```

## Завдання 3

Вправи в цьому розділі покажуть вам, як налаштувати системні/користувацькі процеси та демони (також відомі як служби), які, можливо, потребуватимуть автоматичного запуску разом із системою.

### Щоб переглянути статус послуги

1. Увійшовши в систему як root, перерахуйте всі блоки systemd, які мають певний тип служби. Впишіть:

    ```bash
    root@localhost ~]# systemctl list-units -t service -all
    ```

    Це покаже повний список активних і завантажених, але неактивних одиниць.

2. Перегляньте список активних модулів systemd, які мають тип служби.

    ```bash
    [root@localhost ~]# systemctl list-units --state=active --type service
    UNIT                LOAD   ACTIVE SUB     DESCRIPTION
    atd.service         loaded active running Job spooling tools
    auditd.service      loaded active running Security Auditing Service
    chronyd.service     loaded active running NTP client/server
    crond.service       loaded active running Command Scheduler
    dbus.service        loaded active running D-Bus System Message Bus
    firewalld.service   loaded active running firewalld - dynamic firewall daemon
    ...<SNIP>...
    ```

3. Звузьте список і дізнайтеся більше про конфігурацію однієї зі служб у попередніх результатах. *crond.service*. Впишіть:

    ```bash
    [root@localhost ~]# systemctl cat crond.service
    ```

4. Перевірте, чи `crond.service` налаштовано на автоматичний запуск під час завантаження системи. Впишіть:

    ```bash
    [root@localhost ~]# systemctl is-enabled  crond.service

    enabled
    ```

5. Переглядайте статус служби `crond.service` у реальному часі. Впишіть:

    ```bash
    [root@localhost ~]# systemctl  status  crond.service  
    ```

    За замовчуванням вихідні дані включатимуть 10 останніх рядків/записів/журналів журналу.

6. Перегляньте статус `crond.service` і припиніть показ будь-яких рядків журналу. Впишіть:

    ```bash
    [root@localhost ~]# systemctl -n 0  status  crond.service  
    ```

7. Переглянути стан sshd.service.

    !!! Question "Питання"
   
        Перегляньте статус `firewalld.service`. Що таке юніт `firewalld.service`?

### Щоб зупинити сервіси

1. Увійшовши в систему як користувач із правами адміністратора, скористайтеся командою `pgrep`, щоб перевірити, чи з’являється процес `crond` у списку процесів, запущених у системі.

    ```bash
    [root@localhost ~]# pgrep  -a crond

    313274 /usr/sbin/crond -n
    ```

    Якщо вона знаходить відповідну назву процесу, команда `pgrep` повинна знайти та перерахувати PID `crond`.

2. Використовуйте `systemctl`, щоб зупинити модуль `crond.service`. Впишіть:

    ```bash
    [root@localhost ~]# systemctl stop crond.service
    ```

    Команда має завершитися без жодного результату.

3. Використовуючи `systemctl`, перегляньте статус `crond.service`, щоб побачити ефект ваших змін.

4. Скористайтеся `pgrep` знову, щоб перевірити, чи процес crond все ще відображається у списку процесів.

### Щоб запустити сервіси

1. Увійдіть під обліковим записом адміністратора. Використовуйте команду `pgrep`, щоб перевірити, чи з’являється процес `crond` у списку процесів, які виконуються в системі.

    ```bash
    [root@localhost ~]# pgrep  -a crond
    ```

    Якщо `pgrep` знайде відповідну назву процесу, він перерахує PID `crond`.

2. Використовуйте `systemctl`, щоб запустити модуль `crond.service`. Впишіть:

    ```bash
    [root@localhost ~]# systemctl start crond.service
    ```

    Команда має завершитися без жодних виводів чи видимого зворотного зв’язку.

3. Використовуючи `systemctl`, перегляньте статус `crond.service`, щоб побачити ефект ваших змін. Впишіть:

    ```bash
    [root@localhost ~]# systemctl -n 0 status crond.service

    ● crond.service - Command Scheduler
    Loaded: loaded (/usr/lib/systemd/system/crond.service; enabled; vendor preset: enabled)
    Active: active (running) since Mon 2023-10-16 11:38:04 EDT; 54s ago
    Main PID: 313451 (crond)
        Tasks: 1 (limit: 48282)
    Memory: 1000.0K
    CGroup: /system.slice/crond.service
            └─313451 /usr/sbin/crond -n
    ```

    !!! Question "Питання"

     З результатів команди `systemctl` status у вашій системі, який PID `crond`?

4. Подібним чином знову скористайтеся `pgrep`, щоб побачити, чи процес `crond` тепер відображається у списку процесів. Порівняйте PID, показаний pgrep, із PID, показаним у попередньому статусі `systemctl` `crond.service`.

    ```bash
    [root@localhost ~]# systemctl is-enabled  crond.service

    enabled
    ```

### Щоб перезапустити сервіси

Для багатьох служб/демонов часто потрібне перезапуск або перезавантаження запущеної служби/демона щоразу, коли вносяться зміни до їхніх базових файлів конфігурації. Це робиться для того, щоб даний процес/служба/демон міг застосувати останні зміни конфігурації.

1. Перегляньте статус crond.service. Впишіть:

    ```bash
    [root@localhost ~]# systemctl -n 0 status crond.service
    ```

    Занотуйте PID для crond у вихідних даних.

2. Запустіть `systemctl restart`, щоб перезапустити `crond.service`. Впишіть:

    ```bash
    [root@localhost ~]# systemctl -n 0 status crond.service
    ```

    Команда має завершитися без жодних виводів чи видимого зворотного зв’язку.

3. Знову перевірте статус `crond.service`. Порівняйте останній PID із PID, зазначеним на кроці 1.

4. Використовуйте `systemctl`, щоб перевірити, чи `crond.service` зараз активний. Впишіть:

    ```bash
    [root@localhost ~]# systemctl is-active crond.service
    active
    ```

    !!! Question "Питання"

     Чому, на вашу думку, PID відрізняються кожного разу, коли ви перезапускаєте службу?


    !!! tip "Порада"

     Функціональність старої доброї класичної команди служби перенесено для бездоганної роботи в керованих системах systemd. Ви можете використовувати такі команди служби, як наведені нижче, щоб зупинити, запустити, перезапустити та переглянути статус служби `smartd`.

        ```bash
        # service smartd status

        # service smartd stop

        # service smartd start

        # service smartd restart
        ```

### Щоб вимкнути послугу

1. Використовуйте `systemctl`, щоб перевірити, чи ввімкнено `crond.service` для автоматичного запуску системи. Впишіть:

    ```bash
    [root@localhost ~]# systemctl is-enabled  crond.service

    enabled
    ```

    Зразок результату показує, що це так.

2. Вимкніть автоматичний запуск `crond.service`. Впишіть:

    ```bash
    [root@localhost ~]# systemctl disable crond.service
    Removed /etc/systemd/system/multi-user.target.wants/crond.service.
    ```

3. Знову виконайте команду `systemctl is-enabled`, щоб побачити ефект ваших змін.

    !!! Question "Питання"
   
        На сервері, яким потрібно керувати віддалено, чому б вам НЕ вимкнути автоматичний запуск під час завантаження системи такої служби, як `sshd.service`?

### Щоб забезпечити відключення (тобто маскування) служби

Незважаючи на те, що команду `systemctl disable` можна використати для вимкнення служб, як ви бачили в попередніх вправах, інші одиниці systemd (процеси, служби, демони тощо) можуть повторно ввімкнути вимкнену службу – якщо потрібно крадькома. Це може статися, коли служба залежить від іншої [вимкненої] служби.

Щоб забезпечити відключення блоку обслуговування systemd і запобігти випадковій повторній активації, ви повинні замаскувати службу.

1. Використовуйте `systemctl`, щоб замаскувати `crond.service` і запобігти будь-якій небажаній повторній активації, введіть:

    ```bash
    [root@localhost ~]# systemctl mask crond.service

    Created symlink /etc/systemd/system/crond.service → /dev/null.
    ```

2. Виконайте команду `systemctl is-enabled`, щоб переглянути ефект ваших змін.

    ```bash
    [root@localhost ~]# systemctl is-enabled  crond.service

    masked
    ```

3. Щоб скасувати зміни та *демаскувати* `crond.service`, скористайтеся командою `systemctl unmask`, виконавши:

    ```bash
    [root@localhost ~]# systemctl unmask crond.service

    Removed /etc/systemd/system/crond.service.
    ```

### Щоб увімкнути послугу

1. Використовуйте `systemctl`, щоб перевірити стан блоку `crond.service`. Впишіть:

    ```bash
    [root@localhost ~]# systemctl status crond.service
    ```

    Служба все ще має бути в стані зупинки.

2. Використовуйте команду `systemctl enable`, щоб увімкнути `crond.service` для автоматичного запуску. Впишіть:

    ```bash
    [root@localhost ~]# systemctl enable crond.service

    Created symlink /etc/systemd/system/multi-user.target.wants/crond.service → /usr/lib/systemd/system/crond.service.
    ```

3. Знову скористайтеся `systemctl`, щоб перевірити, чи активний `crond.service`. Впишіть:

    ```bash
    [root@localhost ~]# systemctl is-active crond.service
    inactive
    ```

    !!! Question "Питання"

     Ви щойно ввімкнули `crond.service`. Чому він не працює або не вказано як активний у попередній команді?

4. Використовуйте дещо інший варіант команди `systemctl enable`, щоб увімкнути `crond.service` і негайно запустити демон. Впишіть:

    ```bash
    [root@localhost ~]# systemctl --now enable crond.service
    ```

5. Перевірте, чи `crond.service` зараз активний. Впишіть:

    ```bash
    [root@localhost ~]# systemctl is-active crond.service
    active
    ```

6. Використовуючи `systemctl`, переконайтеся, що `crond.service` запущено, працює та ввімкнено для автоматичного запуску.
