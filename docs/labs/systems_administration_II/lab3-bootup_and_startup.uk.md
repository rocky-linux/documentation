---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tested on: All versions
tags:
  - лабораторні вправи
  - керування завантаженням
  - цільове управління
  - управління обслуговуванням
  - systemd
  - systemctl
---

# Лабораторна робота 3: Процеси завантаження та запуску

## Цілі

Після виконання цієї лабораторної роботи ви зможете:

- вручну контролювати деякі процеси та служби запуску
- автоматично керувати послугами

Приблизний час виконання цієї лабораторної роботи: 50 хвилин

## Огляд процесу завантаження

Вправи в цій лабораторній роботі розпочнуться від процесу завантаження до входу користувача. Ці кроки перевірять і намагатимуться налаштувати частини процесів завантаження. Етапами високого рівня в процесі завантаження є:

### Підсумок кроків

1. Апаратне забезпечення завантажує, читає та виконує завантажувальний сектор.
2. завантажувач виконується (GRUB у більшості дистрибутивів Linux)
3. ядро розпаковується та виконується.
4. ядро ініціалізує обладнання.
5. ядро монтує кореневу файлову систему.
6. ядро виконує /usr/lib/systemd/systemd як PID 1.
7. `systemd` запускає необхідні та налаштовані пристрої для роботи цільового завантаження за замовчуванням
8. Програми `getty` запускаються на кожному визначеному терміналі
9. `getty` запитує вхід
10. `getty` виконує /bin/login для автентичного користувача
11. вхід запускає оболонку.

### `systemd`

`systemd` — це системний та сервісний менеджер для операційних систем Linux.

### `systemd` units

systemd\` забезпечує систему залежностей між різними сутностями, які називаються "юнітами". Модулі інкапсулюють різні об’єкти, необхідні для завантаження та обслуговування системи. Більшість одиниць налаштовуються у так званих файлах конфігурації одиниць — простих текстових файлах у стилі ini.

### Типи юнітів `systemd`

У `systemd` визначено наступні 11 типів одиниць вимірювання:

_Сервісні блоки_ запускають та керують демонами та процесами, з яких вони складаються.

_Сокетні одиниці_ інкапсулюють локальні IPC або мережеві сокети в системі, що корисно для активації на основі сокетів.

_Цільові одиниці_ використовуються для групування інших одиниць. Вони забезпечують добре відомі точки синхронізації під час завантаження

_Device units_ надають доступ до пристроїв ядра в `systemd` і можуть бути використані для реалізації активації на основі пристроїв.

_Mount units_ контролюють точки монтування у файловій системі

_Automount units_ забезпечують можливості автомонтування для монтування файлових систем на вимогу, а також для паралельного завантаження.

_Timer units_ корисні для запуску активації інших пристроїв на основі таймерів.

_Swap units_ дуже схожі на блоки монтування та інкапсулюють розділи підкачки або файли пам'яті операційної системи.

_Path units_ можуть активувати інші служби, коли об'єкти файлової системи змінюються або модифікуються.

_Slice units_ можуть використовуватися для групування одиниць, які керують системними процесами (такими як одиниці обслуговування та області видимості), в ієрархічне дерево з метою управління ресурсами.

_Scope units_ схожі на сервісні одиниці, але керують сторонніми процесами, а не запускають їх.

## Завдання 1

### /usr/lib/systemd/systemd | PID=1

Історично init називався багатьма іменами та мав кілька форм.

Незалежно від назви чи реалізації, init (або його еквівалент) часто називають _матір'ю всіх процесів_.

Сторінка довідки для «init» посилається на нього як на батьківський для всіх процесів. Згідно з угодою, перша програма або процес ядра, який виконується, завжди має ідентифікатор процесу 1.
Після запуску першого процесу він запускає інші служби, демони, процеси, програми тощо.

#### Для вивчення першого системного процесу

!!! note

    У наведених нижче вправах замініть PID на ідентифікаційний номер процесу.

1. Увійдіть у систему як будь-який користувач. Запитайте шлях віртуальної файлової системи /proc/PID/comm і знайдіть назву процесу з ідентифікатором 1. Впишіть:

    ```bash
    [root@localhost ~]# cat /proc/1/comm
    
    systemd
    ```

2. Виконайте команду `ls`, щоб переглянути шлях віртуальної файлової системи /proc/PID/exe та побачити назву й шлях до виконуваного файлу процесу з ідентифікатором 1. Впишіть:

    ```bash
    [root@localhost ~]# ls -l /proc/1/exe
    
    lrwxrwxrwx 1 root root 0 Oct  5 23:56 /proc/1/exe -> /usr/lib/systemd/systemd
    ```

3. Спробуйте скористатися командою `ps`, щоб дізнатися назву процесу або програми, що відповідає за PID. Впишіть:

    ```bash
    [root@localhost ~]# ps -p 1 -o comm=
    
    systemd
    ```

4. Використовуйте команду `ps`, щоб переглянути повний шлях та будь-які аргументи командного рядка процесу або програми, що стоїть за PID 1. Впишіть:

    ```bash
    [root@localhost ~]# ps -p  1 -o args=
    
    /usr/lib/systemd/systemd --switched-root --system --deserialize 16
    ```

5. Щоб перевірити, чи головний процес, який традиційно називають init, насправді є systemd, використовуйте `ls`, щоб підтвердити, що `init` є символічним посиланням на бінарний файл `systemd`. Впишіть:

    ```bash
    [root@localhost ~]# ls -l /usr/sbin/init
    lrwxrwxrwx. 1 root root 22 Aug  8 15:33 /usr/sbin/init -> ../lib/systemd/systemd
    ```

6. Використовуйте команду `pstree` для відображення деревоподібного вигляду системних процесів. Впишіть:

    ```bash
    [root@localhost ~]# pstree --show-pids
    
    ```

## Завдання 2

### `systemd` Targets (RUNLEVELS)

`systemd` визначає та спирається на багато різних цілей для керування системою. У цій вправі ми зосередимося лише на 5 основних цілях. 5 основних цілей, розглянутих у цьому розділі, перераховані тут:

1. poweroff.target
2. rescue.target
3. multi-user.target - Завантажує систему з повною багатокористувацькою підтримкою без графічного середовища.
4. graphical.target - Завантажує систему з мережею, підтримкою кількох користувачів і менеджером відображення.
5. reboot.target

!!! Tip "Підказка"

    ```
    Цільові одиниці замінюють рівні виконання SysV у класичній системі ініціалізації SysV.
    ```

#### Для керування цілями systemd

1. Перелічіть УСІ (активні + неактивні + невдалі) доступні цілі на сервері.

    ```bash
    [root@localhost ~]# systemctl list-units --type target --all
    ```

2. Перелічіть лише поточні активні цілі. Впишіть:

    ```bash
    [root@localhost ~]# systemctl list-units -t target    
    ```

3. Використовуйте команду `systemctl`, щоб переглянути/отримати назву цільового пристрою за замовчуванням, з якого налаштовано завантаження системи. Впишіть:

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

   Зверніть увагу на деякі властивості та їх значення, налаштовані в блоці `multi-user.target`. Такі властивості, як - Description, Documentation, Requires, After, та інші.

5. Одиниця `basic.target` вказана як значення властивості `Requires` для `multi-user.target`. Перегляньте файл модуля для `basic.target`. Впишіть:

    ```bash
    [root@localhost ~]# systemctl cat basic.target
    # /usr/lib/systemd/system/basic.target
    [Unit]
    Description=Basic System
    Documentation=man:systemd.special(7)
    Requires=sysinit.target
    Wants=sockets.target timers.target paths.target slices.target
    After=sysinit.target sockets.target paths.target slices.target tmp.mount
    RequiresMountsFor=/var /var/tmp
    ```

6. Команда `systemctl cat` показує лише підмножину властивостей та значень заданого юніта. Щоб переглянути дамп УСІХ властивостей і значень цільового блоку, скористайтеся підкомандою show. Команда `show` також відобразить низькорівневі властивості. Показати ВСІ властивості multi-user.target, введіть:

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

9. Використовуйте команди `ls` та `file`, щоб дізнатися більше про зв'язок традиційної програми `init` з програмою `systemd`. Впишіть:

    ```bash
    [root@localhost ~]# ls -l /usr/sbin/init && file /usr/sbin/init
    
    lrwxrwxrwx. 1 root root 22 Aug  8 15:33 /usr/sbin/init -> ../lib/systemd/systemd
    /usr/sbin/init: symbolic link to ../lib/systemd/systemd
    ```

#### Щоб змінити ціль завантаження за замовчуванням

1. Встановити/змінити ціль за замовчуванням, з якої система завантажується. Використайте команду `systemctl set-default`, щоб змінити ціль за замовчуванням на `graphical.target`. Впишіть:

    ```bash
    [root@localhost ~]# systemctl set-default graphical.target
    
    ```

2. Перевірте, чи активна щойно встановлена ціль завантаження. Впишіть:

    ```bash
    [root@localhost ~]# systemctl is-active graphical.target
    
    inactive
    ```

   Зверніть увагу, що результат показує, що ціль _не_ активна, хоча вона була встановлена ​​за замовчуванням!

3. Щоб змусити систему негайно переключитися та використовувати задану ціль, потрібно скористатися підкомандою `isolate`. Впишіть:

    ```bash
    [root@localhost ~]# systemctl isolate graphical.target
    ```

   !!! Warning "Важливо"

        ```
         Команда systemctl isolate може бути небезпечною, якщо її використовувати неправильно. Це пояснюється тим, що вона негайно зупинить процеси, не ввімкнені в новому цільовому об'єкті, можливо, включаючи графічне середовище або термінал, який ви зараз використовуєте!
        ```

4. Перевірте ще раз, чи `graphical.target` зараз використовується та чи є активним.

5. Запитуйте та переглядайте, які інші служби чи ресурси «Wants» graphical.target.

   !!! Question "Питання"

        ```
         Які основні відмінності між multi-user.target та graphical.target "Wants"?
        ```

6. Оскільки ваша система працює під керуванням операційної системи серверного класу, де повноцінне графічне середовище робочого столу може бути небажаним, перемкніть систему назад до більш відповідного multi-user.target. Впишіть:

    ```bash
    [root@localhost ~]# systemctl isolate multi-user
    
    ```

7. Встановити/змінити ціль завантаження системи за замовчуванням на multi-user.target.

8. Запустіть швидку [і додаткову] ручну перевірку, щоб побачити, на яку ціль вказує символічне посилання default.target, виконавши:

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

2. Переглянути список активних одиниць `systemd` з типом служби.

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

3. Звузьте коло пошуку та дізнайтеся більше про конфігурацію однієї з служб у попередньому виводі, _crond.service_. Впишіть:

    ```bash
    [root@localhost ~]# systemctl cat crond.service
    ```

4. Перевірте, чи налаштовано `crond.service` на автоматичний запуск під час завантаження системи. Впишіть:

    ```bash
    [root@localhost ~]# systemctl is-enabled  crond.service
    
    enabled
    ```

5. Переглядайте стан служби `crond.service` у режимі реального часу. Впишіть:

    ```bash
    [root@localhost ~]# systemctl  status  crond.service  
    ```

   За замовчуванням вихідні дані включатимуть 10 останніх рядків/записів/журналів журналу.

6. Перегляньте стан `crond.service` та приберіть відображення будь-яких рядків журналу. Впишіть:

    ```bash
    [root@localhost ~]# systemctl -n 0  status  crond.service  
    ```

7. Переглянути стан sshd.service.

   !!! Question "Питання"

        ```
         Переглянути стан `firewalld.service`. Що таке модуль `firewalld.service`?
        ```

### Щоб зупинити сервіси

1. Увійшовши в систему як користувач з правами адміністратора, скористайтеся командою `pgrep`, щоб перевірити, чи відображається процес `crond` у списку процесів, що працюють у системі.

    ```bash
    [root@localhost ~]# pgrep  -a crond
    
    313274 /usr/sbin/crond -n
    ```

   Якщо команда `pgrep` знайде відповідне ім'я процесу, вона повинна знайти та вивести PID `crond`.

2. Використайте `systemctl` для зупинки модуля `cron.service`. Впишіть:

    ```bash
    [root@localhost ~]# systemctl stop crond.service
    ```

   Команда має завершитися без жодного результату.

3. Використовуючи `systemctl`, перегляньте стан `crond.service`, щоб побачити ефект від ваших змін.

4. Знову скористайтеся командою `pgrep`, щоб перевірити, чи процес `crond` все ще відображається у списку процесів.

### Щоб запустити сервіси

1. Увійдіть під обліковим записом адміністратора. Використайте команду `pgrep`, щоб перевірити, чи відображається процес `crond` у списку процесів, що працюють у системі.

    ```bash
    [root@localhost ~]# pgrep  -a crond
    ```

   Якщо `pgrep` знаходить відповідну назву процесу, він виведе PID `crond`.

2. Використайте `systemctl` для запуску модуля `cron.service`. Впишіть:

    ```bash
    [root@localhost ~]# systemctl start crond.service
    ```

   Команда має завершитися без жодних виводів чи видимого зворотного зв’язку.

3. Використовуючи `systemctl`, перегляньте стан `crond.service`, щоб побачити ефект від ваших змін. Впишіть:

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

        ```
         Згідно з виводом команди status `systemctl` у вашій системі, який PID `crond`?
        ```

4. Аналогічно, знову скористайтеся командою `pgrep`, щоб побачити, чи процес `crond` тепер відображається у списку процесів. Порівняйте PID, що відображається pgrep, з PID, що відображається в попередньому статусі `systemctl` `crond.service`.

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

   У виводі зверніть увагу на PID для `crond`.

2. Виконайте команду `systemctl restart`, щоб перезапустити `crond.service`. Впишіть:

    ```bash
    [root@localhost ~]# systemctl -n 0 status crond.service
    ```

   Команда має завершитися без жодних виводів чи видимого зворотного зв’язку.

3. Знову перевірте статус `crond.service`. Порівняйте останній PID із PID, зазначеним на кроці 1.

4. Використайте `systemctl`, щоб перевірити, чи активний `crond.service`. Впишіть:

    ```bash
    [root@localhost ~]# systemctl is-active crond.service
    active
    ```

   !!! Question "Питання"

        ```
         Чому, на вашу думку, PID-ідентифікатори відрізняються щоразу, коли ви перезапускаєте службу?
        ```

   !!! Tip "Підказка"

        ```
         Функціональність старої доброї класичної команди service була перенесена для безперебійної роботи на системах, керованих systemd. Ви можете використовувати команди service, такі як наведені нижче, для зупинки, запуску, перезапуску та перегляду стану служби `smartd`.
         
         ```bash
         # service smartd status
         
         # service smartd stop
         
         # service smartd start
         
         # service smartd restart
         ```
        ```

### Щоб вимкнути послугу

1. Використайте `systemctl`, щоб перевірити, чи ввімкнено автоматичний запуск `crond.service` під час завантаження системи. Впишіть:

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

3. Знову виконайте команду `systemctl is-enabled`, щоб побачити ефект від ваших змін.

   !!! Question "Питання"

        ```
         На сервері, яким потрібно керувати віддалено, чому б НЕ вимикати автоматичний запуск служби, такої як `sshd.service`, під час завантаження системи?
        ```

### Щоб забезпечити відключення (маскування) сервісу

Хоча команду `systemctl disable` можна використовувати для вимкнення служб, як ви бачили в попередніх вправах, інші модулі `systemd` (процеси, служби, демони тощо) можуть непомітно повторно ввімкнути вимкнену службу, якщо це необхідно. Це може статися, коли служба залежить від іншої [вимкненої] служби.

Вам слід замаскувати службу, щоб гарантовано вимкнути службовий блок `systemd` та запобігти випадковій повторній активації.

1. Використайте `systemctl`, щоб замаскувати `crond.service` та запобігти небажаній повторній активації, введіть:

    ```bash
    [root@localhost ~]# systemctl mask crond.service
    
    Created symlink /etc/systemd/system/crond.service → /dev/null.
    ```

2. Виконайте команду `systemctl is-enabled`, щоб побачити ефект від ваших змін.

    ```bash
    [root@localhost ~]# systemctl is-enabled  crond.service
    
    masked
    ```

3. Щоб скасувати зміни та розмаскувати `crond.service`, скористайтеся командою `systemctl unmask`, виконавши:

    ```bash
    [root@localhost ~]# systemctl unmask crond.service
    
    Removed /etc/systemd/system/crond.service.
    ```

### Щоб увімкнути сервіс

1. Використовуйте `systemctl` для перевірки стану блоку `crond.service`. Впишіть:

    ```bash
    [root@localhost ~]# systemctl status crond.service
    ```

   Служба все ще має бути в стані зупинки.

2. Використайте команду `systemctl enable`, щоб увімкнути автоматичний запуск `crond.service`. Впишіть:

    ```bash
    [root@localhost ~]# systemctl enable crond.service
    
    Created symlink /etc/systemd/system/multi-user.target.wants/crond.service → /usr/lib/systemd/system/crond.service.
    ```

3. Знову використовуйте `systemctl`, щоб перевірити, чи активний `crond.service`. Впишіть:

    ```bash
    [root@localhost ~]# systemctl is-active crond.service
    inactive
    ```

   !!! Question "Питання"

        ```
         Ви щойно ввімкнули `crond.service`. Чому він не працює або не відображається як активний у попередній команді?
        ```

4. Використайте дещо інший варіант команди `systemctl enable`, щоб увімкнути `crond.service` та негайно запустити демон. Впишіть:

    ```bash
    [root@localhost ~]# systemctl --now enable crond.service
    ```

5. Перевірте, чи `crond.service` зараз активний. Впишіть:

    ```bash
    [root@localhost ~]# systemctl is-active crond.service
    active
    ```

6. Використовуючи `systemctl`, переконайтеся, що `crond.service` запущено, працює та увімкнено для автоматичного запуску.
