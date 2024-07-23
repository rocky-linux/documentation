---
title: Зміцнення підрозділів Systemd
author: Julian Patocki
contributors: Steven Spencer
tags:
  - безпека
  - systemd
  - можливості
---

## Передумови

- Знайомство з інструментами командного рядка
- Базове розуміння `systemd` і дозволів на файли
- Уміння читати сторінки man

## Вступ

Багато служб працюють із привілеями, які їм не потрібні для належної роботи. `systemd` містить багато інструментів, які допомагають мінімізувати ризик, коли процес скомпрометовано, шляхом застосування заходів безпеки та обмеження дозволів.

## Завдання

- Покращення безпеки блоків `systemd`

## Відмова від відповідальності

У цьому посібнику пояснюється механізм захисту блоків `systemd` і не розглядається правильна конфігурація будь-якого конкретного блоку. Деякі поняття надто спрощені. Розуміння їх і деяких використовуваних команд вимагає більш глибокого занурення в тему.

## Ресурси

- [`SYSTEMD.EXEC(5)` man page](https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html)
- [`Capabilities(7)` man page](https://man7.org/linux/man-pages/man7/capabilities.7.html)

## Аналіз

`systemd` містить чудовий інструмент, який дає швидкий огляд загальної конфігурації безпеки блоку `systemd`.
`systemd-analyze security` надає швидкий огляд конфігурації безпеки блоку `systemd`. Ось оцінка щойно встановленого `httpd`:

```bash
[user@rocky-vm ~]$ systemd-analyze security httpd
  NAME                                  DESCRIPTION                                                              EXPOSURE
✗ RootDirectory=/RootImage=             Service runs within the host's root directory                            0.1
  SupplementaryGroups=                  Service runs as root, option does not matter
  RemoveIPC=                            Service runs as root, option does not apply
✗ User=/DynamicUser=                    Service runs as root user                                                0.4
✗ CapabilityBoundingSet=~CAP_SYS_TIME   Service processes may change the system clock                            0.2
✗ NoNewPrivileges=                      Service processes may acquire new privileges                             0.2
...
...
...
✓ NotifyAccess=                         Service child processes cannot alter service state
✓ PrivateMounts=                        Service cannot install system mounts
✗ UMask=                                Files created by service are world-readable by default                   0.1

→ Overall exposure level for httpd.service: 9.2 UNSAFE 😨
```

## Можливості

Поняття можливостей може бути дуже заплутаним. Розуміння цього має вирішальне значення для покращення безпеки одиниць `systemd`. Ось уривок зі сторінки довідки `Capabilities(7)`:

```text
З метою перевірки дозволів у традиційних реалізаціях UNIX розрізняють дві категорії процесів: привілейовані процеси (чий ефективний ідентифікатор користувача дорівнює 0, званий суперкористувачем або root) і непривілейовані процеси (чий ефективний UID відмінний від нуля). Привілейовані процеси обходять усі перевірки дозволів ядра, тоді як непривілейовані процеси підлягають повній перевірці дозволів на основі облікових даних процесу (зазвичай: ефективний UID, ефективний GID і список додаткових груп).

Починаючи з Linux 2.2, Linux ділить привілеї, традиційно пов’язані з суперкористувачем, на окремі одиниці, відомі як можливості, які можна незалежно вмикати та вимикати. Можливості є атрибутом для кожного потоку.
```

Це в основному означає, що можливості можуть надавати деякі привілеї `root` непривілейованим процесам, але також обмежувати привілеї процесів, які запускаються `root`.

Зараз існує 41 можливість. Це означає, що привілеї `root` користувача мають 41 набір привілеїв. Ось кілька прикладів:

- **CAP_CHOWN**: Вносить довільні зміни в UID та GID файлів
- **CAP_KILL**: Обходить перевірки дозволів для надсилання сигналів
- **CAP_NET_BIND_SERVICE**: Прив’язує сокет до привілейованих портів Інтернет-домену (номера портів менше 1024)

Сторінка довідки `Capabilities(7)` містить повний список.

Є два типи можливостей:

- Можливості файлів
- Можливості потоку

## Можливості файлів

Можливості файлів дозволяють асоціювати привілеї з виконуваним файлом, подібно до `suid`. Вони включають три набори, що зберігаються в розширеному атрибуті: `Permitted`, `Inheritable`, and `Effective`.

Зверніться до сторінки довідки `Capabilities(7)` для повного пояснення.

Можливості файлів не можуть вплинути на загальний рівень експозиції пристрою, тому вони лише незначно стосуються цього посібника. Однак розуміння їх може бути корисним. Тому коротка демонстрація:

Давайте спробуємо запустити `httpd` на стандартному (привілейованому) порту 80 як непривілейований користувач:

```bash
[user@rocky-vm ~]$ sudo -u apache /usr/sbin/httpd
(13)Permission denied: AH00072: make_sock: could not bind to address 0.0.0.0:80
no listening sockets available, shutting down
```

Як і очікувалося, операція не вдається. Давайте оснастимо двійковий файл `httpd` згаданими раніше **CAP_NET_BIND_SERVICE** і **CAP_DAC_OVERRIDE** (щоб замінити перевірки дозволів на файли log і pid для цієї вправи) і спробуємо ще раз:

```bash
[user@rocky-vm ~]$ sudo setcap "cap_net_bind_service=+ep cap_dac_override=+ep" /usr/sbin/httpd
[user@rocky-vm ~]$ sudo -u apache /usr/sbin/httpd
[user@rocky-vm ~]$ curl --head localhost
HTTP/1.1 403 Forbidden
...
```

Як і очікувалося, веб-сервер вдалося успішно запустити.

## Можливості потоку

Можливості потоку застосовуються до процесу та його дітей. Існує п'ять наборів можливостей потоку:

- Permitted
- Inheritable
- Effective
- Bounding
- Ambient

Щоб отримати повне пояснення, зверніться до сторінки довідки `Capabilities(7)`.

Ви вже встановили, що `httpd` не потребує всіх привілеїв, доступних користувачеві `root`. Давайте видалимо раніше надані можливості з двійкового файлу `httpd`, запустимо демон `httpd` і перевіримо його привілеї:

```bash
[user@rocky-vm ~]$ sudo setcap -r /usr/sbin/httpd
[user@rocky-vm ~]$ sudo systemctl start httpd
[user@rocky-vm ~]$ grep Cap /proc/$(pgrep --uid 0 httpd)/status
CapInh: 0000000000000000
CapPrm: 000001ffffffffff
CapEff: 000001ffffffffff
CapBnd: 000001ffffffffff
CapAmb: 0000000000000000
[user@rocky-vm ~]$ capsh --decode=000001ffffffffff
0x000001ffffffffff=cap_chown,cap_dac_override,cap_dac_read_search,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_linux_immutable,cap_net_bind_service,cap_net_broadcast,cap_net_admin,cap_net_raw,cap_ipc_lock,cap_ipc_owner,cap_sys_module,cap_sys_rawio,cap_sys_chroot,cap_sys_ptrace,cap_sys_pacct,cap_sys_admin,cap_sys_boot,cap_sys_nice,cap_sys_resource,cap_sys_time,cap_sys_tty_config,cap_mknod,cap_lease,cap_audit_write,cap_audit_control,cap_setfcap,cap_mac_override,cap_mac_admin,cap_syslog,cap_wake_alarm,cap_block_suspend,cap_audit_read,cap_perfmon,cap_bpf,cap_checkpoint_restore
```

Основний процес `httpd` працює з усіма доступними можливостями, хоча більшість із них не потрібні.

## Обмеження можливостей

`systemd` зменшує набори можливостей до наступного:

- **CapabilityBoundingSet**: обмежує можливості, отримані під час `execve`
- **AmbientCapabilities**: корисний, якщо ви хочете виконати процес як непривілейований користувач, але все ж хочете надати йому деякі можливості

Щоб зберегти конфігурацію над оновленнями пакетів, створіть файл `override.conf` у каталозі `/lib/systemd/system/httpd.service.d/`.

Знаючи, що службі потрібен доступ до привілейованого порту та вона запускається як `root`, але розгалужує свої потоки як `apache`, необхідно вказати такі можливості в розділі `[Service]` `/lib/ файл systemd/system/httpd.service.d/override.conf`:

```bash
[Service]
CapabilityBoundingSet=CAP_NET_BIND_SERVICE CAP_SETUID CAP_SETGID
```

Можливе зниження загального рівня впливу від "НЕБЕЗПЕЧНО" до "СЕРЕДНЬОГО".

```bash
[user@rocky-vm ~]$ sudo systemctl daemon-reload
[user@rocky-vm ~]$ sudo systemctl restart httpd
[user@rocky-vm ~]$ systemd-analyze security --no-pager httpd | grep Overall
→ Overall exposure level for httpd.service: 7.1 MEDIUM 😐
```

Однак цей процес все ще виконується як `root`. Можливе подальше зниження рівня експозиції, запустивши його виключно як `apache`.

Крім доступу до порту 80, процес повинен писати в журнали, розташовані в `/etc/httpd/logs/`, і мати можливість створити `/run/httpd/` і писати в нього. У першому ви можете досягти цього, змінивши дозволи за допомогою `chown`, а в другому ви можете скористатися утилітою `systemd-tmpfiles`. Ви можете використовувати його з опцією `--create`, щоб створити файл без перезавантаження, але відтепер він створюватиметься автоматично під час кожного запуску системи.

```bash
[user@rocky-vm ~]$ sudo chown -R apache:apache /etc/httpd/logs/
[user@rocky-vm ~]$ echo 'd /run/httpd 0755 apache apache -' | sudo tee /etc/tmpfiles.d/httpd.conf
d /run/httpd 0755 apache apache -
[user@rocky-vm ~]$ sudo systemd-tmpfiles --create /etc/tmpfiles.d/httpd.conf
[user@rocky-vm ~]$ ls -ld /run/httpd/
drwxr-xr-x. 2 apache apache 40 Jun 30 08:29 /run/httpd/
```

Вам потрібно налаштувати конфігурацію в `/lib/systemd/system/httpd.service.d/override.conf`. Вам потрібно надати нові можливості за допомогою **AmbientCapabilities**. Якщо `httpd` увімкнено під час запуску, розширення залежностей у розділі `[Unit]` має відбутися, щоб служба запустилася після створення тимчасового файлу.

```bash
[Unit]
After=systemd-tmpfiles-setup.service

[Service]
User=apache
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE
```

```bash
[user@rocky-vm ~]$ sudo systemctl daemon-reload
[user@rocky-vm ~]$ sudo systemctl restart httpd
[user@rocky-vm ~]$ grep Cap /proc/$(pgrep httpd | head -1)/status
CapInh: 0000000000000400
CapPrm: 0000000000000400
CapEff: 0000000000000400
CapBnd: 0000000000000400
CapAmb: 0000000000000400
[user@rocky-vm ~]$ capsh --decode=0000000000000400
0x0000000000000400=cap_net_bind_service
[user@rocky-vm ~]$ systemd-analyze security --no-pager httpd | grep Overall
→ Overall exposure level for httpd.service: 6.5 MEDIUM 😐
```

## Обмеження файлової системи

Управління дозволами на файли, які створює процес, здійснюється шляхом встановлення `UMask`.
Параметр `UMask` змінює дозволи на файл за замовчуванням, виконуючи побітові операції. Це в основному встановлює дозволи за замовчуванням на вісімковий `0644` (`-rw-r--r--`), а `UMask` за замовчуванням - `0022`. Це означає, що `UMask` не змінює набір за замовчуванням:

```bash
[user@rocky-vm ~]$ printf "%o\n" $(echo $(( 00644 &  ~00022 )))
644
```

Якщо припустити, що бажаним набором дозволів для файлів, створених демоном, є `0640` (`-rw-r-----`), ви можете встановити для `UMask` значення `7137`. Це досягає мети, навіть якщо дозволи за замовчуванням встановлені на `7777`:

```bash
[user@rocky-vm ~]$ printf "%o\n" $(echo $(( 07777 &  ~07137  )))
640
```

Крім того:

- `ProtectSystem=`: _"Якщо встановлено значення "`strict`", уся ієрархія файлової системи монтується лише для читання, за винятком піддерев файлової системи API `/dev/`, `/proc/` та `/sys/` (захистіть ці каталоги за допомогою `PrivateDevices=`, `ProtectKernelTunables=`, `ProtectControlGroups=`)."_
- `ReadWritePaths=`: знову робить окремі шляхи доступними для запису
- `ProtectHome=`: робить `/home/`, `/root` і `/run/user` недоступними
- `PrivateDevices=`: вимикає доступ до фізичних пристроїв, дозволяє доступ лише до псевдопристроїв, таких як `/dev/null`, `/dev/zero`, `/dev/random`
- `ProtectKernelTunables=`: робить `/proc/` і `/sys/` доступними лише для читання
- `ProtectControlGroups=`: робить `cgroups` доступними лише для читання
- `ProtectKernelModules=`: забороняє явне завантаження модуля
- `ProtectKernelLogs=`: обмежує доступ до буфера журналу ядра
- `ProtectProc=`: _"Якщо встановлено значення «невидимий», процеси, що належать іншим користувачам, приховані від /proc/."_
- `ProcSubset=`: _"Якщо «pid», усі файли та каталоги, які безпосередньо не пов’язані з керуванням процесами та самоаналізом, стають невидимими у файловій системі /proc/, налаштованій для процесів пристрою."_

Також можливо обмежити шляхи до виконуваних файлів. Демону потрібно лише виконати свої двійкові файли та бібліотеки. Утиліта `ldd` може сказати нам, які бібліотеки використовує двійковий файл:

```bash
[user@rocky-vm ~]$ ldd /usr/sbin/httpd
        linux-vdso.so.1 (0x00007ffc0e823000)
        libpcre.so.1 => /lib64/libpcre.so.1 (0x00007fa360d61000)
        libselinux.so.1 => /lib64/libselinux.so.1 (0x00007fa360d34000)
        libaprutil-1.so.0 => /lib64/libaprutil-1.so.0 (0x00007fa360d05000)
        libcrypt.so.2 => /lib64/libcrypt.so.2 (0x00007fa360ccb000)
        libexpat.so.1 => /lib64/libexpat.so.1 (0x00007fa360c9a000)
        libapr-1.so.0 => /lib64/libapr-1.so.0 (0x00007fa360c5a000)
        libc.so.6 => /lib64/libc.so.6 (0x00007fa360a00000)
        libpcre2-8.so.0 => /lib64/libpcre2-8.so.0 (0x00007fa360964000)
        /lib64/ld-linux-x86-64.so.2 (0x00007fa360e70000)
        libuuid.so.1 => /lib64/libuuid.so.1 (0x00007fa360c4e000)
        libm.so.6 => /lib64/libm.so.6 (0x00007fa360889000)
```

Наступні рядки буде додано до розділу `[Service]` у файлі `override.conf`:

```bash
UMask=7177
ProtectSystem=strict
ReadWritePaths=/run/httpd /etc/httpd/logs

ProtectHome=true
PrivateDevices=true
ProtectKernelTunables=true
ProtectControlGroups=true
ProtectKernelModules=true
ProtectKernelLogs=true
ProtectProc=invisible
ProcSubset=pid

NoExecPaths=/
ExecPaths=/usr/sbin/httpd /lib64
```

Перезавантажимо конфігурацію та перевіримо вплив на рахунок:

```bash
[user@rocky-vm ~]$ sudo systemctl daemon-reload
[user@rocky-vm ~]$ sudo systemctl restart httpd
[user@rocky-vm ~]$ systemd-analyze security --no-pager httpd | grep Overall
→ Overall exposure level for httpd.service: 4.9 OK 🙂
```

## Системні обмеження

Різні параметри можуть обмежувати роботу системи для підвищення безпеки:

- `NoNewPrivileges=`: гарантує, що процес не може отримати нові привілеї через біти `setuid`, `setgid` і можливості файлової системи
- `ProtectClock=`: забороняє запис до системних і апаратних годинників
- `SystemCallArchitectures=`: якщо встановлено значення `native`, процеси можуть виконувати лише власні `системні виклики` (у більшості випадків `x86-64`)
- `RestrictNamespaces=`: простори імен здебільшого стосуються контейнерів, тому їх можна обмежити для цього блоку
- `RestrictSUIDSGID=`: не дозволяє процесу встановлювати біти `setuid` і `setgid` для файлів
- `LockPersonality=`: запобігає зміні домену виконання, що може бути корисним лише для запуску застарілих програм або програмного забезпечення, розробленого для інших Unix-подібних систем
- `RestrictRealtime=`: планування в реальному часі актуальне лише для додатків, які вимагають суворих гарантій синхронізації, таких як промислові системи керування, обробка аудіо/відео та наукове моделювання
- `RestrictAddressFamilies=`: обмежує доступні сімейства адрес сокетів; можна встановити значення `AF_(INET|INET6)`, щоб дозволити лише сокети IPv4 та IPv6; деяким службам знадобиться `AF_UNIX` для внутрішнього зв'язку та журналювання
- `MemoryDenyWriteExecute=`: гарантує, що процес не зможе виділяти нові області пам’яті, які доступні як для запису, так і для виконання, запобігає деяким типам атак, коли шкідливий код вставляється в пам’ять для запису, а потім виконується; може призвести до збою компіляторів JIT, які використовуються JavaScript, Java або .NET
- `ProtectHostname=`: запобігає використанню процесом `syscalls` `sethostname()`, `setdomainname()`

Давайте додамо наступне до файлу `override.conf`, перезавантажимо конфігурацію та перевіримо вплив на рахунок:

```bash
NoNewPrivileges=true
ProtectClock=true
SystemCallArchitectures=native
RestrictNamespaces=true
RestrictSUIDSGID=true
LockPersonality=true
RestrictRealtime=true
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX
MemoryDenyWriteExecute=true
ProtectHostname=true
```

```bash
[user@rocky-vm ~]$ sudo systemctl daemon-reload
[user@rocky-vm ~]$ sudo systemctl restart httpd
[user@rocky-vm ~]$ systemd-analyze security --no-pager httpd | grep Overall
→ Overall exposure level for httpd.service: 3.0 OK 🙂
```

## Фільтрація системних викликів

Обмежити системні виклики може бути нелегко. Важко визначити, які системні виклики мають виконувати деякі демони, щоб функціонувати належним чином.

Утиліта `strace` може бути корисною для визначення того, які системні виклики створюються. Параметр `-f` вказує на те, щоб стежити за роздвоєними процесами, а `-o` зберігає вихідні дані у файл під назвою `httpd.strace`.

```bash
[user@rocky-vm ~]$ sudo strace -f -o httpd.strace /usr/sbin/httpd
```

Після запуску процесу на деякий час і взаємодії з ним зупиніть виконання, щоб перевірити вихід:

```bash
[user@rocky-vm ~]$ awk '{print $2}' httpd.strace | cut -d '(' -f 1 | sort | uniq | sed '/^[^a-zA-Z0-9]*$/d' | wc -l
79
```

Під час роботи програма здійснила 79 унікальних системних викликів.
Ви можете налаштувати список системних викликів як дозволений за допомогою наступного однорядка:

```bash
[user@rocky-vm ~]$ echo SystemCallFilter=$(awk '{print $2}' httpd.strace | cut -d '(' -f 1 | sort | uniq | sed '/^[^a-zA-Z0-9]*$/d' | tr "\n" " ") | sudo tee -a /lib/systemd/system/httpd.service.d/override.conf
...
...
...
[user@rocky-vm ~]$ sudo systemctl daemon-reload
[user@rocky-vm ~]$ sudo systemctl restart httpd
[user@rocky-vm ~]$ systemd-analyze security --no-pager httpd | grep Overall
→ Overall exposure level for httpd.service: 1.5 OK 🙂
[user@rocky-vm ~]$ curl --head localhost
HTTP/1.1 403 Forbidden
```

Веб-сервер все ще працює, і ризик значно зменшився.

Наведений вище підхід є точним. Якщо системний виклик пропущено, це може призвести до збою програми. `systemd` групує системні виклики в попередньо визначені набори. Щоб спростити обмеження системних викликів, замість того, щоб встановлювати один системний виклик у список дозволених або заборонених, можна встановити цілу групу в списку дозволених або заборонених. Щоб переглянути списки:

```bash
[user@rocky-vm ~]$ systemd-analyze syscall-filter
@default
    # System calls that are always permitted
    arch_prctl
    brk
    cacheflush
    clock_getres
...
...
...
```

Системні виклики в групах можуть збігатися, особливо для деяких груп, які включають інші групи. Таким чином, окремі виклики або групи можна заборонити, вказавши символ `~`. Наступні директиви у файлі `override.conf` повинні працювати для цього пристрою:

```bash
SystemCallFilter=@system-service
SystemCallFilter=~@privileged @resources @mount @swap @reboot
```

## Висновки

Конфігурація безпеки за замовчуванням більшості блоків `systemd` є неналежною. Їх зміцнення може зайняти деякий час, але воно того варте, особливо у великих середовищах, доступних до Інтернету. Якщо зловмисник використовує вразливість або неправильну конфігурацію, захищений блок може перешкодити йому отримати контроль над системою.
