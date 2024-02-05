---
title: Команда Grep
author: tianci li
contributors: null
tags:
  - grep
---

# Команда `grep`

Команда `grep` фільтрує вміст одного або кількох файлів. Існують деякі варіанти цього командного інструменту, наприклад `egrep (grep -E)` і `fgrep (grep -f)`. Для інформації, яка не охоплюється, перегляньте [посібник `grep`](https://www.gnu.org/software/grep/manual/ "посібник grep").

Використання команди `grep` наступне:

```text
grep [OPTIONS] PATTERN [FILE...]
grep [OPTIONS] -e PATTERN ... [FILE...]
grep [OPTIONS] -f FILE ... [FILE...]
```

Варіанти в основному поділяються на чотири частини:

- match control
- output control
- content line control
- directory or file control

match control：

| опції                    | опис                                                       |
| :----------------------- | :--------------------------------------------------------- |
| -E<br/>--extended-regexp | Вмикає ERE                                                 |
| -P<br/>--perl-regexp     | Вмикає PCRE                                                |
| -G<br/>--basic-regexp    | Вмикає BRE за замовченням                                  |
| -e<br/>--regexp=PATTERN  | Відповідність шаблону, можна вказати кілька параметрів -e. |
| -i                       | Ігнорує регістр                                            |
| -w                       | Точна відповідність всьому слову                           |
| -f FILE                  | Отримує шаблони з ФАЙЛУ, по одному на рядок                |
| -x                       | Візерункове збігання по всій лінії                         |
| -v                       | Вибирає рядки вмісту, які не збігаються                    |

output control:

| опції  | опис                                                                                                               |
| :----- | :----------------------------------------------------------------------------------------------------------------- |
| -m NUM | Виводить кілька перших відповідних результатів                                                                     |
| -n     | Друкує номери рядків на виході                                                                                     |
| -H     | У разі зіставлення вмісту кількох файлів відображає назву файлу на початку рядка. Це налаштування за замовчуванням |
| -h     | Під час зіставлення вмісту кількох файлів ім’я файлу не відображається на початку рядка                            |
| -o     | Друкує лише відповідний вміст без виведення всього рядка                                                           |
| -q     | Не виводить нормальну інформацію                                                                                   |
| -s     | Не виводить повідомлення про помилки                                                                               |
| -r     | Рекурсивне зіставлення для каталогів                                                                               |
| -c     | Друкує кількість рядків, які відповідають кожному файлу на основі вмісту користувача                               |

content line control:

| опції  | опис                                                               |
| :----- | :----------------------------------------------------------------- |
| -B NUM | Друкує NUM рядків початкового контексту перед відповідними рядками |
| -A NUM | Друкує NUM рядків кінцевого контексту після відповідних рядків     |
| -C NUM | Друкує NUM рядків вихідного контексту                              |

directory or file control:

| опції                                       | опис                                                                                                                                                                                                                                                                                                                         |
| :------------------------------------------ | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| --include=FILE_PATTERN | Шукає лише файли, які відповідають FILE_PATTERN. Підтримуються символи підстановки для імен файлів \*, ?, [], [^], [-], {..}, {,}           |
| --exclude=FILE_PATTERN | Пропускає файли та каталоги, що відповідають FILE_PATTERN. Підтримуються символи підстановки для імен файлів \*, ?, [], [^], [-], {..}, {,} |
| --exclude-dir=PATTERN                       | Виключає вказану назву каталогу. Підтримка назв каталогу \*, ?, [], [^], [-], {..}, {,}                                                                          |
| --exclude-from=FILE                         | Виключає вказаний каталог із вмісту файлу.                                                                                                                                                                                                                                                                                   |

## Приклади використання

1. опція -f і опція -o

   ```bash
   Shell > cat /root/a
   abcdef
   123456
   338922549
   24680
   hello world

   Shell > cat /root/b
   12345
   test
   world
   aaaaa

   # Treat each line of file b as a matching pattern and output the lines that match file a.
   Shell > grep -f /root/b /root/a
   123456
   hello world

   Shell > grep -f /root/b /root/a -o
   12345
   world
   ```

2. Зіставлення кількох шаблонів (за допомогою параметра -e)

   ```bash
   Shell > echo -e "a\nab\nbc\nbcde" | grep -e 'a' -e 'cd'
   a
   ab
   bcde
   ```

   або:

   ```bash
   Shell > echo -e "a\nab\nbc\nbcde" | grep -E "a|cd"
   a
   ab
   bcde
   ```

3. Видалення порожніх рядків та рядків коментарів із файлу конфігурації

   ```bash
   Shell > grep -v -E "^$|^#" /etc/chrony.conf
   server ntp1.tencent.com iburst
   server ntp2.tencent.com iburst
   server ntp3.tencent.com iburst
   server ntp4.tencent.com iburst
   driftfile /var/lib/chrony/drift
   makestep 1.0 3
   rtcsync
   keyfile /etc/chrony.keys
   leapsectz right/UTC
   logdir /var/log/chrony
   ```

4. Друк 5 найкращих результатів, які збігаються

   ```bash
   Shell > seq 1 20 | grep -m 5 -E "[0-9]{2}"
   10
   11
   12
   13
   14
   ```

   або:

   ```bash
   Shell > seq 1 20 | grep -m 5  "[0-9]\{2\}"
   10
   11
   12
   13
   14
   ```

5. Опція -B та опція -A

   ```bash
   Shell > seq 1 20 | grep -B 2 -A 3 -m 5 -E "[0-9]{2}"
   8
   9
   10
   11
   12
   13
   14
   15
   16
   17
   ```

6. Опція -C

   ```bash
   Shell > seq 1 20 | grep -C 3 -m 5 -E "[0-9]{2}"
   7
   8
   9
   10
   11
   12
   13
   14
   15
   16
   17
   ```

7. опція -c

   ```bash
   Shell > cat /etc/ssh/sshd_config | grep  -n -i -E "port"
   13:# If you want to change the port on a SELinux system, you have to tell
   15:# semanage port -a -t ssh_port_t -p tcp #PORTNUMBER
   17:#Port 22
   99:# WARNING: 'UsePAM no' is not supported in RHEL and may cause several
   105:#GatewayPorts no

   Shell > cat /etc/ssh/sshd_config | grep -E -i "port" -c
   5
   ```

8. опція -v

   ```bash
   Shell > cat /etc/ssh/sshd_config | grep -i -v -E "port" -c
   140
   ```

9. Фільтрувати файли в каталозі, які містять рядки, які відповідають рядку (виключити файли в підкаталогах)

   ```bash
   Shell > grep -i -E "port" /etc/n*.conf -n
   /etc/named.conf:11:     listen-on port 53 { 127.0.0.1; };
   /etc/named.conf:12:     listen-on-v6 port 53 { ::1; };
   /etc/nsswitch.conf:32:# winbind                 Use Samba winbind support
   /etc/nsswitch.conf:33:# wins                    Use Samba wins support
   ```

10. Фільтрувати файли в каталозі, які містять рядки, що відповідають рядку (включити або виключити файли або каталоги в підкаталогах)

    Включити синтаксис для кількох файлів:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --include={0..20}_*
    /etc/grub.d/20_ppc_terminfo:26:export TEXTDOMAIN=grub
    /etc/grub.d/20_ppc_terminfo:27:export TEXTDOMAINDIR=/usr/share/locale
    /etc/grub.d/20_linux_xen:26:export TEXTDOMAIN=grub
    /etc/grub.d/20_linux_xen:27:export TEXTDOMAINDIR="${datarootdir}/locale"
    /etc/grub.d/20_linux_xen:46:# Default to disabling partition uuid support to maintian compatibility with
    /etc/grub.d/10_linux:26:export TEXTDOMAIN=grub
    /etc/grub.d/10_linux:27:export TEXTDOMAINDIR="${datarootdir}/locale"
    /etc/grub.d/10_linux:47:# Default to disabling partition uuid support to maintian compatibility with

    Shell > grep -n -i -r -E  "port" /etc/ --include={{0..20}_*,sshd_config} -c
    /etc/ssh/sshd_config:5
    /etc/grub.d/20_ppc_terminfo:2
    /etc/grub.d/10_reset_boot_success:0
    /etc/grub.d/12_menu_auto_hide:0
    /etc/grub.d/20_linux_xen:3
    /etc/grub.d/10_linux:3
    ```

    Якщо вам потрібно виключити один каталог, використовуйте такий синтаксис:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --exclude-dir=selin[u]x
    ```

    Якщо вам потрібно виключити кілька каталогів, використовуйте такий синтаксис:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --exclude-dir={selin[u]x,"profile.d",{a..z}ki,au[a-z]it}
    ```

    Якщо вам потрібно виключити один файл, використовуйте такий синтаксис:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --exclude=sshd_config
    ```

    Якщо вам потрібно виключити кілька файлів, використовуйте такий синтаксис:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --exclude={ssh[a-z]_config,*.conf,services}
    ```

    Якщо вам потрібно виключити кілька файлів і каталогів одночасно, використовуйте такий синтаксис:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --exclude-dir={selin[u]x,"profile.d",{a..z}ki,au[a-z]it} --exclude={ssh[a-z]_config,*.conf,services,[0-9][0-9]*}
    ```

11. Підрахувати всі IPv4-адреси поточної машини

    ```bash
    Shell > ip a | grep -o  -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | grep -v -E "127|255"
    192.168.100.3
    ```
