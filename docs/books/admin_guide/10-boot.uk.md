---
title: Запуск системи
---

# Запуск системи

У цьому розділі ви дізнаєтесь, як запускається система.

****
**Цілі**: у цьому розділі майбутні адміністратори Linux дізнаються про:

:heavy_check_mark: Різні етапи процесу завантаження;  
:heavy_check_mark: Як Rocky Linux підтримує це завантаження через GRUB2 і systemd;  
:heavy_check_mark: Як захистити GRUB2 від атаки;  
:heavy_check_mark: Як керувати послугами;  
:heavy_check_mark: Як отримати доступ до журналів з `journald`.

:checkered_flag: **користувачі**

**Знання**: :star: :star:  
**Складність**: :star: :star: :star:

**Час читання**: 20 хвилин
****

## Процес завантаження

Важливо розуміти процес завантаження Linux, щоб вирішити проблеми, які можуть виникнути.

Процес завантаження включає:

### Запуск BIOS

**BIOS** (базова система вводу/виводу) виконує **POST** (самотестування при включенні), щоб виявити, протестувати та ініціалізувати апаратні компоненти системи.

Потім завантажується **MBR** (головний завантажувальний запис).

### Головний завантажувальний запис (MBR)

Головний завантажувальний запис — це перші 512 байт завантажувального диска. MBR виявляє завантажувальний пристрій і завантажує bootloader **GRUB2** у пам'ять і передає йому керування.

Наступні 64 байти містять таблицю розділів диска.

### GRUB2 bootloader

Bootloader за умовчанням для дистрибутива Rocky 8 є **GRUB2** (GRand Unified Bootloader). GRUB2 замінює старий завантажувач GRUB (також званий GRUB legacy).

Файл конфігурації GRUB 2 знаходиться під `/boot/grub2/grub.cfg`, але цей файл не слід редагувати безпосередньо.

Ви можете знайти параметри конфігурації меню GRUB2 у `/etc/default/grub`.  Команда `grub2-mkdconfig` використовує їх для створення файлу `grub.cfg`.

```bash
# cat /etc/default/grub
GRUB_TIMEOUT=5
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="rd.lvm.lv=rhel/swap crashkernel=auto rd.lvm.lv=rhel/root rhgb quiet net.ifnames=0"
GRUB_DISABLE_RECOVERY="true"
```

Якщо внесено зміни до одного чи кількох із цих параметрів, необхідно запустити команду `grub2-mkconfig`, щоб повторно створити файл `/boot/grub2/grub.cfg`.

```bash
[root] # grub2-mkconfig –o /boot/grub2/grub.cfg
```

* GRUB2 шукає стислий образ ядра (файл `vmlinuz`) у каталозі `/boot`.
* GRUB2 завантажує образ ядра в пам’ять і витягує вміст файлу зображення `initramfs` у тимчасову папку в пам’яті за допомогою файлової системи `tmpfs`.

### Ядро

Ядро запускає процес `systemd` з PID 1.

```bash
root          1      0  0 02:10 ?        00:00:02 /usr/lib/systemd/systemd --switched-root --system --deserialize 23
```

### `systemd`

`systemd` є батьківським для всіх системних процесів. Він зчитує посилання target-a `/etc/systemd/system/default.target` (наприклад, `/usr/lib/systemd/system/multi-user.target`) для визначення target системи за замовчуванням. Файл визначає служби, які потрібно запустити.

Потім `systemd` переводить систему в стан target-defined, виконуючи наступні завдання ініціалізації:

1. Встановлення назви машини
2. Ініціалізація мережі
3. Ініціалізація SELinux
4. Відображення банера привітання
5. Ініціалізація апаратного забезпечення на основі аргументів, наданих ядру під час завантаження
6. Монтування файлових систем, включаючи віртуальні файлові системи, такі як /proc
7. Очищення каталогу в /var
8. Запуск віртуальної пам'яті (swap)

## Захист завантажувача GRUB2

Навіщо захищати завантажувач паролем?

1. Запобігання доступу до режиму *одного користувача* - якщо зловмисник може завантажитися в режимі одного користувача, він стає користувачем root.
2. Заборонити доступ до консолі GRUB. Якщо зловмиснику вдається скористатися консоллю GRUB, він може змінити її конфігурацію або зібрати інформацію про систему за допомогою команди `cat`.
3. Запобігання доступу до незахищених операційних систем. Якщо в системі є подвійне завантаження, зловмисник може вибрати під час завантаження операційну систему, наприклад DOS, яка ігнорує елементи керування доступом і дозволи на файли.

Щоб захистити паролем завантажувач GRUB2:

1. Увійдіть в операційну систему як користувач root і виконайте команду `grub2-mkpasswd-pbkdf2`. Результат цієї команди такий:

    ```bash
    Enter password:
    Reenter password:
    PBKDF2 hash of your password is grub.pbkdf2.sha512.10000.D0182EDB28164C19454FA94421D1ECD6309F076F1135A2E5BFE91A5088BD9EC87687FE14794BE7194F67EA39A8565E868A41C639572F6156900C81C08C1E8413.40F6981C22F1F81B32E45EC915F2AB6E2635D9A62C0BA67105A9B900D9F365860E84F1B92B2EF3AA0F83CECC68E13BA9F4174922877910F026DED961F6592BB7
    ```

    Вам потрібно ввести свій пароль під час взаємодії. Зашифрованим текстом пароля є довгий рядок "grub.pbkdf2.sha512...".

2. Вставте зашифрований текст пароля в останній рядок файлу **/etc/grub.d/00_header**. Вставлений формат виглядає наступним чином:

    ```bash
    cat <<EOF
    set superusers='frank'
    password_obkdf2 frank grub.pbkdf2.sha512.10000.D0182EDB28164C19454FA94421D1ECD6309F076F1135A2E5BFE91A5088BD9EC87687FE14794BE7194F67EA39A8565E868A41C639572F6156900C81C08C1E8413.40F6981C22F1F81B32E45EC915F2AB6E2635D9A62C0BA67105A9B900D9F365860E84F1B92B2EF3AA0F83CECC68E13BA9F4174922877910F026DED961F6592BB7
    EOF
    ```

    Ви можете замінити користувача 'frank' на будь-якого іншого.

    Ви також можете встановити простий текстовий пароль, наприклад:

    ```bash
    cat <<EOF
    set superusers='frank'
    password frank rockylinux8.x
    EOF
    ```

3. Останнім кроком є ​​виконання команди `grub2-mkconfig -o /boot/grub2/grub.cfg` для оновлення параметрів GRUB2.

4. Перезапустіть операційну систему, щоб перевірити шифрування GRUB2. Виберіть перший пункт меню завантаження та введіть клавішу ++"e"++, а потім введіть відповідного користувача та пароль.

    ```bash
    Enter username:
    frank
    Enter password:

    ```

    Після успішної перевірки введіть ++ctrl+"x"++, щоб запустити операційну систему.

Іноді в деяких документах можна побачити, що команда `grub2-set-password` (`grub2-setpassword`) використовується для захисту завантажувача GRUB2:

| команда                 | Основні функції                          | Метод модифікації файлу конфігурації | автоматизм |
| ----------------------- | ---------------------------------------- | ------------------------------------ | ---------- |
| `grub2-set-password`    | Встановлює пароль і оновлює конфігурацію | Автозавершення                       | висока     |
| `grub2-mkpasswd-pbkdf2` | Генерує лише зашифровані хеш-значення    | Вимагає редагування вручну           | низький    |

Увійдіть в операційну систему як користувач root і виконайте команду `gurb2-set-password` наступним чином:

```bash
[root] # grub2-set-password
Enter password:
Confirm password:

[root] # cat /boot/grub2/user.cfg
GRUB2_PASSWORD=grub.pbkdf2.sha512.10000.32E5BAF2C2723B0024C1541F444B8A3656E0A04429EC4BA234C8269AE022BD4690C884B59F344C3EC7F9AC1B51973D65F194D766D06ABA93432643FC94119F17.4E16DF72AA1412599EEA8E90D0F248F7399E45F34395670225172017FB99B61057FA64C1330E2EDC2EF1BA6499146400150CA476057A94957AB4251F5A898FC3

[root] # grub2-mkconfig -o /boot/grub2/grub.cfg

[root] # reboot
```

Після виконання команди `grub2-set-password` буде автоматично створено файл **/boot/grub2/user.cfg**.

Виберіть перший пункт меню завантаження та введіть клавішу ++"e"++, а потім введіть відповідного користувача та пароль:

```bash
Enter username:
root
Enter password:

```

## Systemd

*Systemd* — це менеджер служб для операційних систем Linux.

Розробка `systemd` полягала в:

* сумісництва зі старими сценаріями ініціалізації SysV,
* забезпечення багатьох функцій, наприклад, паралельний запуск системних служб під час запуску системи, активацію демонів на вимогу, підтримку моментальних знімків або керування залежностями між службами.

!!! Note "Примітка"

    `systemd` є системою ініціалізації за замовчуванням, починаючи з RedHat/CentOS 7.

`systemd` представляє концепцію одиничних файлів, також відомих як одиниці `systemd`.

| Тип          | Розширення файлу | Функціональність                              |
| ------------ | ---------------- | --------------------------------------------- |
| Service unit | `.service`       | Системний сервіс                              |
| Target unit  | `.target`        | Група системних одиниць                       |
| Mount unit   | `.automount`     | Автоматична точка монтування файлової системи |

!!! Примітка

    Існує багато типів юнітів (units): Device unit, Mount unit, Path unit, Scope unit, Slice unit, Snapshot unit, Socket unit, Swap unit, Timer unit.

* `systemd` підтримує знімки стану системи та відновлення.

* Точки монтування можна налаштувати як `systemd` targets.

* Під час запуску `systemd` створює сокети прослуховування для всіх системних служб, які підтримують цей тип активації, і передає ці сокети цим службам, щойно вони запускаються. Це дає змогу перезапустити службу, не втрачаючи жодного повідомлення, надісланого до неї мережею під час її недоступності. Відповідний сокет залишається доступним, а всі повідомлення ставляться в чергу.

* Системні служби, які використовують D-BUS для зв’язку між процесами, можуть бути запущені на вимогу під час першого використання клієнтом.

* `systemd` зупиняє або перезапускає лише запущені служби. Попередні версії (до RHEL7) намагалися зупинити служби напряму, не перевіряючи їх поточний статус.

* Системні служби не успадковують жодного контексту (наприклад, змінні середовища HOME та PATH). Кожна служба працює у власному контексті виконання.

Для всіх операцій сервісного блоку встановлено тайм-аут за замовчуванням у 5 хвилин, щоб запобігти зависанню системи через несправну службу.

Через обмеження простору цей документ не містить дуже детального вступу до `systemd`. Якщо ви зацікавлені в подальшому дослідженні `systemd`, у [цьому документі](./16-about-sytemd.md) є дуже детальний вступ.

### Управління системними службами

Службові блоки закінчуються розширенням файлу `.service` і мають подібне призначення до сценаріїв ініціалізації. Команда `systemctl` використовується для системних служб `display`, `start`, `stop`, `restart`:

| systemctl                                 | Опис                                         |
| ----------------------------------------- | -------------------------------------------- |
| systemctl start *name*.service            | Запускає службу                              |
| systemctl stop *name*.service             | Зупиняє служби                               |
| systemctl restart *name*.service          | Перезапускає службу                          |
| systemctl reload *name*.service           | Перезавантажує конфігурації                  |
| systemctl status *name*.service           | Перевіряє, чи працює служба                  |
| systemctl try-restart *name*.service      | Перезапускає служби, лише якщо вона запущена |
| systemctl list-units --type service --all | Відображає стан всіх послуг                  |

Команда `systemctl` також використовується для `ввімкнення (enable)` або `вимкнення (disable)` системної служби та відображення пов’язаних служб:

| systemctl                                | Опис                                                     |
| ---------------------------------------- | -------------------------------------------------------- |
| systemctl enable *name*.service          | Активує послуги                                          |
| systemctl disable *name*.service         | Вимикає служби                                           |
| systemctl list-unit-files --type service | Перелічує всі служби та перевіряє, чи вони запущені      |
| systemctl list-dependencies --after      | Перелічує служби, які починаються перед вказаним unit'om |
| systemctl list-dependencies --before     | Перелічує служби, які починаються після вказаного unit'a |

Приклади:

```bash
systemctl stop nfs-server.service
# or
systemctl stop nfs-server
```

Щоб отримати список усіх завантажених юнітів:

```bash
systemctl list-units --type service
```

Для перегляду списку усіх юнітів, щоб перевірити, чи вони активовані:

```bash
systemctl list-unit-files --type service
```

```bash
systemctl enable httpd.service
systemctl disable bluetooth.service
```

### Приклад файлу .service для служби postfix

```bash
postfix.service Unit File
What follows is the content of the /usr/lib/systemd/system/postfix.service unit file as currently provided by the postfix package:

[Unit]
Description=Postfix Mail Transport Agent
After=syslog.target network.target
Conflicts=sendmail.service exim.service

[Service]
Type=forking
PIDFile=/var/spool/postfix/pid/master.pid
EnvironmentFile=-/etc/sysconfig/network
ExecStartPre=-/usr/libexec/postfix/aliasesdb
ExecStartPre=-/usr/libexec/postfix/chroot-update
ExecStart=/usr/sbin/postfix start
ExecReload=/usr/sbin/postfix reload
ExecStop=/usr/sbin/postfix stop

[Install]
WantedBy=multi-user.target
```

### Використання системних таргетів (targets)

У Rocky8/RHEL8 концепцію рівнів запуску було замінено таргетами `systemd`.

Таргети `systemd` представлені target units. Target units закінчуються розширенням файлу `.target` і їхня єдина мета — групувати інші блоки `systemd` у ланцюжок залежностей.

Наприклад, модуль `graphical.target`, який використовується для запуску графічного сеансу, запускає системні служби, такі як **менеджер відображення GNOME** (`gdm.service`) або **сервіс облікових записів** (`accounts-daemon.service`), а також активує блок `multi-user.target`.

Так само модуль `multi-user.target` запускає інші важливі системні служби, такі як **NetworkManager** (`NetworkManager.service`) або **D- Bus** (`dbus.service`) і активує іншу target unit під назвою `basic.target`.

| Target Units      | Опис                                                          |
| ----------------- | ------------------------------------------------------------- |
| poweroff.target   | Закриває систему та вимикає її                                |
| rescue.target     | Активує аварійну оболонку (rescue shell)                      |
| multi-user.target | Активує багатокористувацьку систему без графічного інтерфейсу |
| graphical.target  | Активує багатокористувацьку систему з графічним інтерфейсом   |
| reboot.target     | Вимикає та перезавантажує систему                             |

#### Target за умовчанням

Щоб визначити, який target використовується за замовчуванням:

```bash
systemctl get-default
```

Ця команда шукає target символічного посилання, розташованого за адресою `/etc/systemd/system/default.target`, і відображає результат.

```bash
$ systemctl get-default
graphical.target
```

Команда `systemctl` також може надати список доступних таргетів:

```bash
systemctl list-units --type target
UNIT                   LOAD   ACTIVE SUB    DESCRIPTION
basic.target           loaded active active Basic System
bluetooth.target       loaded active active Bluetooth
cryptsetup.target      loaded active active Encrypted Volumes
getty.target           loaded active active Login Prompts
graphical.target       loaded active active Graphical Interface
local-fs-pre.target    loaded active active Local File Systems (Pre)
local-fs.target        loaded active active Local File Systems
multi-user.target      loaded active active Multi-User System
network-online.target  loaded active active Network is Online
network.target         loaded active active Network
nss-user-lookup.target loaded active active User and Group Name Lookups
paths.target           loaded active active Paths
remote-fs.target       loaded active active Remote File Systems
slices.target          loaded active active Slices
sockets.target         loaded active active Sockets
sound.target           loaded active active Sound Card
swap.target            loaded active active Swap
sysinit.target         loaded active active System Initialization
timers.target          loaded active active Timers
```

Щоб налаштувати систему на використання іншого таргету за замовчуванням:

```bash
systemctl set-default name.target
```

Приклад:

```bash
# systemctl set-default multi-user.target
rm '/etc/systemd/system/default.target'
ln -s '/usr/lib/systemd/system/multi-user.target' '/etc/systemd/system/default.target'
```

Щоб переключитися на інший target unit в поточному сеансі:

```bash
systemctl isolate name.target
```

**Режим відновлення** забезпечує просте середовище для відновлення вашої системи у випадках, коли неможливо виконати нормальний процес завантаження.

У `режимі відновлення` система намагається змонтувати всі локальні файлові системи та запустити кілька важливих системних служб, але не вмикає мережевий інтерфейс і не дозволяє іншим користувачам підключатися до системи одночасно.

У Rocky 8 `режим порятунку` еквівалентний старому `режиму одного користувача` та потребує пароля root.

Щоб змінити поточний target і перейти в `режим відновлення` в поточному сеансі:

```bash
systemctl rescue
```

**Аварійний режим** забезпечує максимально мінімалістичне середовище та дозволяє відремонтувати систему навіть у ситуаціях, коли система не може перейти в режим відновлення. В аварійному режимі система монтує кореневу файлову систему лише для читання. Він не намагатиметься змонтувати будь-яку іншу локальну файлову систему, не активуватиме жодного мережевого інтерфейсу та запустить деякі важливі служби.

Щоб змінити поточний target і перейти в екстрений режим у поточному сеансі:

```bash
systemctl emergency
```

#### Вимкнення, призупинення та сплячий режим

Команда `systemctl` замінює кілька команд керування живленням, які використовувалися в попередніх версіях:

| Стара команда       | Нова команда             | Опис                                             |
| ------------------- | ------------------------ | ------------------------------------------------ |
| `halt`              | `systemctl halt`         | Призупиняє систему.                              |
| `poweroff`          | `systemctl poweroff`     | Вимикає систему.                                 |
| `reboot`            | `systemctl reboot`       | Перезавантажує систему.                          |
| `pm-suspend`        | `systemctl suspend`      | Призупиняє систему.                              |
| `pm-hibernate`      | `systemctl hibernate`    | Переводить систему в сплячий режим.              |
| `pm-suspend-hybrid` | `systemctl hybrid-sleep` | Переходить у сплячий режим і призупиняє систему. |

### Процес `journald`

Окрім `rsyslogd`, файлами журналу також може керувати демон `journald`, який є компонентом `systemd`.

Демон `journald` фіксує повідомлення системного журналу, повідомлення журналу ядра, повідомлення з початкового диска RAM і від початку завантаження, а також повідомлення, записані в стандартний вивід і стандартний вивід помилок усіх служб, а потім індексує їх і робить доступними для користувача.

Формат власного файлу журналу, який є структурованим і проіндексованим двійковим файлом, покращує пошук і забезпечує швидшу роботу. Він також зберігає метадані, такі як мітки часу або ідентифікатори користувачів.

### Команда `journalctl`

Команда `journalctl` відображає файли журналу.

```bash
journalctl
```

Команда містить список усіх файлів журналу, згенерованих у системі. Структура цього виводу подібна до тієї, що використовується в `/var/log/messages/`, але пропонує деякі покращення:

* пріоритет записів позначається візуально;
* часові позначки перетворюються на місцевий часовий пояс вашої системи;
* відображаються всі зареєстровані дані, включаючи журнали, що обертаються;
* початок старту позначається спеціальною лінією.

#### Використання безперервного відображення

При постійному відображенні повідомлення журналу відображаються в режимі реального часу.

```bash
journalctl -f
```

Ця команда повертає список із десяти останніх рядків журналу. Потім утиліта journalctl продовжує працювати та чекає нових змін, перш ніж негайно їх відобразити.

#### Фільтрування повідомлень

Можна використовувати різні методи фільтрації для отримання інформації, яка відповідає різним потребам. Повідомлення журналу часто використовуються для відстеження помилкової поведінки в системі. Щоб переглянути записи з вибраним або вищим пріоритетом:

```bash
journalctl -p priority
```

Необхідно замінити пріоритет одним із таких ключових слів (або числом):

* debug (7),
* info (6),
* notice (5),
* warning (4),
* err (3),
* crit (2),
* alert (1),
* emerg (0).
