---
author: Antoine Le Morvan
contributors: Steven Spencer
title: Частина 7 Висока доступність
tags:
  - кластеризація
  - ha
  - висока доступність
  - pcs
  - pacemaker
---

## Кластеризація під Linux

> **Висока доступність** часто використовується в ІТ у зв’язку з архітектурою системи чи послугою, щоб позначити, що ця архітектура чи послуга має відповідний рівень доступності. ~ wikipedia

Ця доступність є показником продуктивності, вираженим у відсотках, отриманим за допомогою співвідношення **Час роботи** / **Загальний бажаний час роботи**.

| Оцінки   | Річний простій              |
| -------- | --------------------------- |
| 90%      | 876 годин                   |
| 95%      | 438 годин                   |
| 99%      | 87 годин і 36 хвилин        |
| 99,9%    | 8 годин 45 хвилин 36 секунд |
| 99,99%   | 52 хвилини 33 секунди       |
| 99,999%  | 5 хвилин 15 секунд          |
| 99,9999% | 31,68 секунди               |

«Висока доступність» (**HA**) стосується всіх заходів, вжитих для гарантування максимально можливої ​​доступності послуги. Іншими словами, це правильна робота 24 години на добу.

### Огляд

Кластер — це "комп'ютерний кластер", група з двох або більше машин.

Кластер дозволяє:

- розподілене обчислення з використанням обчислювальної потужності всіх вузлів
- висока доступність: безперервність обслуговування та автоматичне перемикання після відмови у випадку збою вузла

#### Види послуг

- Активні/пасивні послуги

  Встановлення кластера з двома активними/пасивними вузлами за допомогою Pacemaker і DRBD є недорогим рішенням для багатьох ситуацій, які вимагають високої доступності системи.

- N+1 послуг

  З кількома вузлами Pacemaker може зменшити витрати на апаратне забезпечення, дозволяючи кільком активним/пасивним кластерам об’єднуватися та спільно використовувати резервний вузол.

- N TO N послуг

  Завдяки спільному сховищу кожен вузол потенційно може бути використаний для відмовостійкості. Pacemaker також може запускати кілька копій служб для розподілу робочого навантаження.

- Сервіси віддаленого сайту

  Pacemaker містить удосконалення для спрощення створення багатосайтових кластерів.

#### VIP

VIP — це віртуальна IP-адреса. Це адреса, призначена активному/пасивному кластеру. Призначте VIP активному вузлу кластера. У разі збою в службі VIP дезактивується на невдалому вузлі, тоді як активація відбувається на вузлі, який приймає. Це відомо як відновлення після відмови.

Клієнти завжди звертаються до кластера за допомогою VIP, що робить активне відновлення сервера прозорим.

#### Split-brain

Split-brain є основним ризиком, з яким може зіткнутися кластер. Ця умова виникає, коли кілька вузлів у кластері вважають, що їхні сусіди неактивні. Потім вузол намагається запустити резервну службу, і кілька вузлів надають ту саму послугу, що може призвести до неприємних побічних ефектів (дублювання VIP-адрес у мережі, конкуруючий доступ до даних тощо).

Можливі технічні рішення, щоб уникнути цієї проблеми:

- Відокремлення трафіку загальнодоступної мережі від трафіку мережі кластера
- за допомогою мережевого з’єднання

## Pacemaker (PCS)

У цьому розділі ви дізнаєтесь про Pacemaker, рішення для кластеризації.

****

**Цілі**: Ви дізнаєтеся, як:

:heavy_check_mark: встановити та налаштувати кластер Pacemaker;
:heavy_check_mark: адмініструвати кластер Pacemaker.

:checkered_flag: **clustering**, **ha**, **high availability**, **pcs**, **pacemaker**

**Знання**: :star: :star: :star:
**Складність**: :star: :star:

**Час читання**: 20 хвилин

****

### Загальні положення

**Pacemaker** — це програмна частина кластера, яка керує його ресурсами (VIP-персонами, послугами, даними). Він відповідає за запуск, зупинку та нагляд за ресурсами кластера. Це гарантує високу доступність вузла.

Pacemaker використовує рівень повідомлень, наданий **corosync** (за замовчуванням) або **Heartbeat**.

Pacemaker складається з **5 ключових компонентів**:

- Cluster Information Base (**CIB**)
- Cluster Resource Management daemon (**CRMd**)
- Local Resource Management daemon (**LRMd**)
- Policy Engine (**PEngine** or **PE**)
- Fencing daemon (**STONITHd**)

CIB представляє конфігурацію кластера та поточний стан усіх ресурсів кластера. Вміст CIB автоматично синхронізується в усьому кластері та використовується PEngine для розрахунку того, як досягти ідеального стану кластера.

Потім список інструкцій надається призначеному контролеру (DC). Pacemaker централізує всі рішення кластера, обираючи один із екземплярів CRMd головним.

DC виконує інструкції PEngine у ​​необхідному порядку, передаючи їх локальному LRMd або CRMd інших вузлів через Corosync або Heartbeat.

Іноді може знадобитися зупинка вузлів, щоб захистити спільні дані або дозволити їх відновлення. Pacemaker постачається разом із STONITHd для цієї мети.

#### Stonith

Stonith є компонентом Pacemaker. Це означає Shoot-The-Other-Node-In-The-Head, рекомендовану практику для забезпечення ізоляції несправного вузла якомога швидше (вимкнення або принаймні відключення від спільних ресурсів), таким чином уникаючи пошкодження даних.

Якщо вузол не відповідає, це не означає, що він більше не може отримати доступ до даних. Єдиний спосіб переконатися, що вузол більше не отримує доступу до даних, перш ніж передати їх іншому вузлу, - це використовувати STONITH, який вимкне або перезапустить сервер, що вийшов з ладу.

STONITH також відіграє роль, якщо кластерний сервіс не вимикається. У цьому випадку Pacemaker використовує STONITH, щоб примусово зупинити весь вузол.

#### Керування кворумом

Кворум представляє мінімальну кількість вузлів, що працюють, щоб перевірити рішення, наприклад, вирішити, який резервний вузол повинен взяти на себе, якщо один із вузлів помилковий. За замовчуванням Pacemaker вимагає, щоб більше половини вузлів були онлайн.

Коли проблеми зі зв’язком розбивають кластер на кілька вузлів групи, кворум запобігає запуску ресурсів на більшій кількості вузлів, ніж очікувалося. Кластер є кворуючим, якщо більше половини всіх вузлів, які, як відомо, знаходяться в мережі, знаходяться в його групі (active_nodes_group > active_total_nodes / 2).

Якщо кворум не досягнуто, рішенням за замовчуванням є вимкнути всі ресурси.

Приклади:

- У **кластері з двома вузлами**, оскільки досягнення кворуму **неможливо**, збій вузла слід ігнорувати, або весь кластер буде закрито.
- Якщо кластер із 5 вузлів розділити на 2 групи з 3 і 2 вузлами, група з 3 вузлами матиме кворум і продовжуватиме керувати ресурсами.
- Якщо кластер із 6 вузлів розділити на 2 групи по 3 вузли, жодна група не матиме кворуму. У цьому випадку pacemaker за замовчуванням зупиняє всі ресурси, щоб уникнути пошкодження даних.

#### Кластерне спілкування

Pacemaker використовує **Corosync** або **Heartbeat** (з проекту Linux-ha) для зв’язку між вузлами та керування кластером.

##### Corosync

**Corosync Cluster Engine** — це рівень обміну повідомленнями між членами кластера, який об’єднує додаткові функції для реалізації високої доступності в програмах. Corosync походить від проекту OpenAIS.

Вузли спілкуються в режимі клієнт/сервер за допомогою протоколу UDP.

Він може керувати кластерами з понад 16 активних/пасивних або активних/активних режимів.

##### Heartbeat

Технологія Heartbeat більш обмежена, ніж Corosync. Неможливо створити кластер з більш ніж двох вузлів, а його правила управління менш складні, ніж у конкурента.

!!! NOTE "Примітка"

```
Вибір pacemaker/corosync сьогодні здається більш доречним, оскільки це вибір за замовчуванням для дистрибутивів RedHat, Debian і Ubuntu.
```

#### Управління даними

##### Мережевий рейд DRDB

DRDB — це драйвер пристрою блочного типу, що забезпечує реалізацію RAID 1 (дзеркалювання) у мережі.

DRDB може бути корисним, коли технології NAS або SAN недоступні, але потрібна синхронізація даних.

### Встановлення

Щоб інсталювати Pacemaker, спочатку ввімкніть репозиторій `highavailability`:

```bash
sudo dnf config-manager --set-enabled highavailability
```

Деякі відомості про пакет pacemaker:

```bash
$ dnf info pacemaker
Rocky Linux 9 - High Availability                                                                                                                                     289 kB/s | 250 kB     00:00
Available Packages
Name         : pacemaker
Version      : 2.1.7
Release      : 5.el9_4
Architecture : x86_64
Size         : 465 k
Source       : pacemaker-2.1.7-5.el9_4.src.rpm
Repository   : highavailability
Summary      : Scalable High-Availability cluster resource manager
URL          : https://www.clusterlabs.org/
License      : GPL-2.0-or-later AND LGPL-2.1-or-later
Description  : Pacemaker is an advanced, scalable High-Availability cluster resource
             : manager.
             :
             : It supports more than 16 node clusters with significant capabilities
             : for managing resources and dependencies.
             :
             : It will run scripts at initialization, when machines go up or down,
             : when related resources fail and can be configured to periodically check
             : resource health.
             :
             : Available rpmbuild rebuild options:
             :   --with(out) : cibsecrets hardening nls pre_release profiling
             :                 stonithd


```

Використовуючи команду `repoquery`, ви можете дізнатися про залежності пакета кардіостимулятора:

```bash
$ repoquery --requires pacemaker
corosync >= 3.1.1
pacemaker-cli = 2.1.7-5.el9_4
resource-agents
systemd
...
```

Тому встановлення pacemaker автоматично встановить corosync та інтерфейс CLI для pacemaker.

Деякі відомості про пакет corosync:

```bash
$ dnf info corosync
Available Packages
Name         : corosync
Version      : 3.1.8
Release      : 1.el9
Architecture : x86_64
Size         : 262 k
Source       : corosync-3.1.8-1.el9.src.rpm
Repository   : highavailability
Summary      : The Corosync Cluster Engine and Application Programming Interfaces
URL          : http://corosync.github.io/corosync/
License      : BSD
Description  : This package contains the Corosync Cluster Engine Executive, several default
             : APIs and libraries, default configuration files, and an init script.
```

Зараз встановіть необхідні пакети:

```bash
sudo dnf install pacemaker
```

Відкрийте брандмауер, якщо він у вас є:

```bash
sudo firewall-cmd --permanent --add-service=high-availability
sudo firewall-cmd --reload
```

!!! NOTE "Примітка"

```
Не запускайте служби зараз, оскільки вони не налаштовані та не працюватимуть.
```

### Управління кластером

Пакет `pcs` надає засоби керування кластером. Команда `pcs` — це інтерфейс командного рядка для керування **стеком високої доступності Pacemaker**.

Конфігурацію кластера можна виконати вручну, але пакет pcs значно спрощує керування (створення, налаштування та усунення несправностей) кластером!

!!! NOTE "Примітка"

```
Існують альтернативи pcs.
```

Встановіть пакет на всіх вузлах і активуйте демон:

```bash
sudo dnf install pcs
sudo systemctl enable pcsd --now
```

Встановлення пакета створило користувача `hacluster` з порожнім паролем. Для виконання таких завдань, як синхронізація файлів конфігурації corosync або перезавантаження віддалених вузлів. Необхідно призначити цьому користувачеві пароль.

```text
hacluster:x:189:189:cluster user:/var/lib/pacemaker:/sbin/nologin
```

На всіх вузлах призначте ідентичний пароль для користувача hacluster:

```bash
echo "pwdhacluster" | sudo passwd --stdin hacluster
```

!!! NOTE "Примітка"

```
Будь ласка, замініть "pwdhacluster" більш безпечним паролем.
```

З будь-якого вузла можна пройти автентифікацію як користувача hacluster на всіх вузлах, а потім використовувати на них команди `pcs`:

```bash
$ sudo pcs host auth server1 server2
Username: hacluster
Password:
server1: Authorized
server2: Authorized
```

З вузла, на якому відбувається автентифікація Пк, запустіть конфігурацію кластера:

```bash
$ sudo pcs cluster setup mycluster server1 server2
No addresses specified for host 'server1', using 'server1'
No addresses specified for host 'server2', using 'server2'
Destroying cluster on hosts: 'server1', 'server2'...
server2: Successfully destroyed cluster
server1: Successfully destroyed cluster
Requesting remove 'pcsd settings' from 'server1', 'server2'
server1: successful removal of the file 'pcsd settings'
server2: successful removal of the file 'pcsd settings'
Sending 'corosync authkey', 'pacemaker authkey' to 'server1', 'server2'
server1: successful distribution of the file 'corosync authkey'
server1: successful distribution of the file 'pacemaker authkey'
server2: successful distribution of the file 'corosync authkey'
server2: successful distribution of the file 'pacemaker authkey'
Sending 'corosync.conf' to 'server1', 'server2'
server1: successful distribution of the file 'corosync.conf'
server2: successful distribution of the file 'corosync.conf'
Cluster has been successfully set up.
```

!!! NOTE "Примітка"

```
Команда pcs cluster setup вирішує проблему кворуму для двовузлових кластерів. Таким чином, такий кластер буде правильно функціонувати в разі відмови одного з двох вузлів. Якщо ви налаштовуєте Corosync вручну або використовуєте іншу оболонку керування кластером, ви повинні правильно налаштувати Corosync.
```

Тепер можна запускати кластер:

```bash
$ sudo pcs cluster start --all
server1: Starting Cluster...
server2: Starting Cluster...
```

Увімкніть службу кластера для запуску під час завантаження:

```bash
sudo pcs cluster enable --all
```

Перевірте статус послуги:

```bash
$ sudo pcs status
Cluster name: mycluster

WARNINGS:
No stonith devices and stonith-enabled is not false

Cluster Summary:
  * Stack: corosync (Pacemaker is running)
  * Current DC: server1 (version 2.1.7-5.el9_4-0f7f88312) - partition with quorum
  * Last updated: Mon Jul  8 17:50:14 2024 on server1
  * Last change:  Mon Jul  8 17:50:00 2024 by hacluster via hacluster on server1
  * 2 nodes configured
  * 0 resource instances configured

Node List:
  * Online: [ server1 server2 ]

Full List of Resources:
  * No resources

Daemon Status:
  corosync: active/disabled
  pacemaker: active/disabled
  pcsd: active/enabled
```

#### Додавання ресурсів

Перш ніж ви зможете налаштувати ресурси, вам потрібно буде мати справу з попередженням:

```bash
WARNINGS:
No stonith devices and stonith-enabled is not false
```

У цьому стані Pacemaker відмовиться запускати ваші нові ресурси.

У вас є два варіанти:

- вимкнути `stonith`
- налаштувати його

По-перше, ви вимкнете `stonith`, поки не навчитеся його налаштовувати:

```bash
sudo pcs property set stonith-enabled=false
```

!!! WARNING "Увага"

```
Будьте обережні, щоб не залишити `stonith` вимкненим у робочому середовищі!
```

##### Конфігурація VIP

Перший ресурс, який ви створите у своєму кластері, — це VIP.

Перелічіть стандартні ресурси, доступні за допомогою команди `pcs resource standards`:

```bash
$ pcs resource standards
lsb
ocf
service
systemd
```

Цей VIP відповідає IP-адресам клієнтів, щоб вони могли отримати доступ до майбутніх служб кластера. Ви повинні призначити його одному з вузлів. Тоді, якщо станеться збій, кластер переключить цей ресурс з одного вузла на інший, щоб забезпечити безперервність обслуговування.

```bash
pcs resource create myclusterVIP ocf:heartbeat:IPaddr2 ip=192.168.1.12 cidr_netmask=24 op monitor interval=30s
```

Аргумент ocf:heartbeat:IPaddr2 містить три поля, які надають Pacemaker такі дані:

- стандарт (тут `ocf`)
- простір імен сценарію (тут `heartbeat`)
- назва сценарію ресурсу

Результатом є додавання віртуальної IP-адреси до списку керованих ресурсів:

```bash
$ sudo pcs status
Cluster name: mycluster

...
Cluster name: mycluster
Cluster Summary:
  * Stack: corosync (Pacemaker is running)
  ...
  * 2 nodes configured
  * 1 resource instance configured

Full List of Resources:
  * myclusterVIP        (ocf:heartbeat:IPaddr2):         Started server1
...
```

У цьому випадку VIP активний на server1. Можлива перевірка за допомогою команди `ip`:

```bash
$ ip add show dev enp0s3
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:df:29:09 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.10/24 brd 192.168.1.255 scope global noprefixroute enp0s3
       valid_lft forever preferred_lft forever
    inet 192.168.1.12/24 brd 192.168.1.255 scope global secondary enp0s3
       valid_lft forever preferred_lft forever
```

###### Тест перемикання

З будь-якого місця в мережі запустіть команду ping на VIP:

```bash
ping 192.168.1.12
```

Переведіть активний вузол у режим очікування:

```bash
sudo pcs node standby server1
```

Перевірте, чи всі ping-запити виконані успішно під час операції (без пропуску `icmp_seq`):

```bash
64 bytes from 192.168.1.12: icmp_seq=39 ttl=64 time=0.419 ms
64 bytes from 192.168.1.12: icmp_seq=40 ttl=64 time=0.043 ms
64 bytes from 192.168.1.12: icmp_seq=41 ttl=64 time=0.129 ms
64 bytes from 192.168.1.12: icmp_seq=42 ttl=64 time=0.074 ms
64 bytes from 192.168.1.12: icmp_seq=43 ttl=64 time=0.099 ms
64 bytes from 192.168.1.12: icmp_seq=44 ttl=64 time=0.044 ms
64 bytes from 192.168.1.12: icmp_seq=45 ttl=64 time=0.021 ms
64 bytes from 192.168.1.12: icmp_seq=46 ttl=64 time=0.058 ms
```

Перевірте стан кластера:

```bash
$ sudo pcs status
Cluster name: mycluster
Cluster Summary:
...
  * 2 nodes configured
  * 1 resource instance configured

Node List:
  * Node server1: standby
  * Online: [ server2 ]

Full List of Resources:
  * myclusterVIP        (ocf:heartbeat:IPaddr2):         Started server2
```

VIP переміщено на server2. Перевірте за допомогою команди `ip add`, як і раніше.

Поверніть server1 до пулу:

```bash
sudo pcs node unstandby server1
```

Після того, як сервер1 перейшов у режим очікування, кластер повертається до нормального стану, але ресурс не передається назад на сервер1: він залишається на сервері2.

##### Конфігурація служби

Ви встановите службу Apache на обох вузлах кластера. Ця служба запускається лише на активному вузлі та перемикатиме вузли одночасно з VIP, якщо станеться збій активного вузла.

Зверніться до розділу про Apache, щоб отримати докладні інструкції щодо встановлення.

Ви повинні встановити `httpd` на обох вузлах:

```bash
sudo dnf install -y httpd
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload
```

!!! WARNING "Увага"

```
Не запускайте та не активуйте послугу самостійно. Pacemaker подбає про це.
```

За замовчуванням відображатиметься HTML-сторінка з назвою сервера:

```bash
echo "<html><body>Node $(hostname -f)</body></html>" | sudo tee "/var/www/html/index.html"
```

Агент ресурсу Pacemaker використовуватиме сторінку `/server-status` (див. розділ Apache), щоб визначити свій стан справності. Ви повинні активувати його, створивши файл `/etc/httpd/conf.d/status.conf` на обох серверах:

```bash
sudo vim /etc/httpd/conf.d/status.conf
<Location /server-status>
    SetHandler server-status
    Require local
</Location>
```

Щоб створити ресурс, викличете «Веб-сайт»; ви викличете сценарій Apache ресурсу OCF і в просторі імен heartbeat.

```bash
sudo pcs resource create WebSite ocf:heartbeat:apache configfile=/etc/httpd/conf/httpd.conf statusurl="http://localhost/server-status" op monitor interval=1min
```

Кластер перевірятиме справність Apache щохвилини (`операційний інтервал моніторингу=1 хв`).

Нарешті, щоб гарантувати, що служба Apache запускається на тому ж вузлі, що й VIP-адреса, ви повинні додати обмеження до кластера:

```bash
sudo pcs constraint colocation add WebSite with myclusterVIP INFINITY
```

Також можна налаштувати службу Apache для запуску після VIP. Це може бути корисним, якщо Apache має конфігурації VHost для прослуховування VIP-адреси (`Listen 192.168.1.12`):

```bash
$ sudo pcs constraint order myclusterVIP then WebSite
Adding myclusterVIP WebSite (kind: Mandatory) (Options: first-action=start then-action=start)
```

###### Тестування відмовостійкості

Ви виконаєте відмову та перевірите, чи ваш веб-сервер усе ще доступний:

```bash
$ sudo pcs status
Cluster name: mycluster
Cluster Summary:
  * Stack: corosync (Pacemaker is running)
  * Current DC: server1 (version 2.1.7-5.el9_4-0f7f88312) - partition with quorum
  ...

Node List:
  * Online: [ server1 server2 ]

Full List of Resources:
  * myclusterVIP        (ocf:heartbeat:IPaddr2):         Started server1
  * WebSite     (ocf:heartbeat:apache):  Started server1
```

Зараз ви працюєте на сервері 1.

```bash
$ curl http://192.168.1.12/
<html><body>Node server1</body></html>
```

Симулюйте збій на server1:

```bash
sudo pcs node standby server1
```

```bash
$ curl http://192.168.1.12/
<html><body>Node server2</body></html>
```

Як бачите, ваша веб-служба все ще працює, але зараз вона знаходиться на server2.

```bash
sudo pcs node unstandby server1
```

Зверніть увагу, що послуга була перервана лише на кілька секунд, поки VIP перемикався, і служби перезапускалися.

### Усунення несправностей кластера

#### Команда `pcs status`

Команда `pcs status` надає інформацію про загальний стан кластера:

```bash
$ sudo pcs status
Cluster name: mycluster
Cluster Summary:
  * Stack: corosync (Pacemaker is running)
  * Current DC: server1 (version 2.1.7-5.el9_4-0f7f88312) - partition with quorum
  * Last updated: Tue Jul  9 12:25:42 2024 on server1
  * Last change:  Tue Jul  9 12:10:55 2024 by root via root on server1
  * 2 nodes configured
  * 2 resource instances configured

Node List:
  * Online: [ server1 ]
  * OFFLINE: [ server2 ]

Full List of Resources:
  * myclusterVIP        (ocf:heartbeat:IPaddr2):         Started server1
  * WebSite     (ocf:heartbeat:apache):  Started server1

Daemon Status:
  corosync: active/enabled
  pacemaker: active/enabled
  pcsd: active/enabled
```

Як бачите, один із двох серверів офлайн.

#### Команда `pcs status corosync`

Команда `pcs status corosync` надає інформацію про стан вузлів `corosync`:

```bash
$ sudo pcs status corosync

Membership information
----------------------
    Nodeid      Votes Name
         1          1 server1 (local)
```

і як тільки server2 повернеться:

```bash
$ sudo pcs status corosync

Membership information
----------------------
    Nodeid      Votes Name
         1          1 server1 (local)
         2          1 server2
```

#### Команда `crm_mon`

Команда `crm_mon` повертає інформацію про стан кластера. Використовуйте параметр «-1», щоб один раз відобразити стан кластера та вийти.

```bash
$ sudo crm_mon -1
Cluster Summary:
  * Stack: corosync (Pacemaker is running)
  * Current DC: server1 (version 2.1.7-5.el9_4-0f7f88312) - partition with quorum
  * Last updated: Tue Jul  9 12:30:21 2024 on server1
  * Last change:  Tue Jul  9 12:10:55 2024 by root via root on server1
  * 2 nodes configured
  * 2 resource instances configured

Node List:
  * Online: [ server1 server2 ]

Active Resources:
  * myclusterVIP        (ocf:heartbeat:IPaddr2):         Started server1
  * WebSite     (ocf:heartbeat:apache):  Started server1
```

#### Команди `corosync-*cfgtool*`

Команда `corosync-cfgtool` перевіряє правильність конфігурації та належну роботу зв’язку з кластером:

```bash
$ sudo corosync-cfgtool -s
Local node ID 1, transport knet
LINK ID 0 udp
        addr    = 192.168.1.10
        status:
                nodeid:          1:     localhost
                nodeid:          2:     connected
```

Команда `corosync-cmapctl` є інструментом для доступу до бази даних об'єктів.
Наприклад, ви можете використовувати його для перевірки стану вузлів-членів кластера:

```bash
$ sudo corosync-cmapctl  | grep members
runtime.members.1.config_version (u64) = 0
runtime.members.1.ip (str) = r(0) ip(192.168.1.10)
runtime.members.1.join_count (u32) = 1
runtime.members.1.status (str) = joined
runtime.members.2.config_version (u64) = 0
runtime.members.2.ip (str) = r(0) ip(192.168.1.11)
runtime.members.2.join_count (u32) = 2
runtime.members.2.status (str) = joined
```

### Практичне завдання

Для цього завдання вам знадобляться два сервери з інстальованими, налаштованими та захищеними службами Pacemaker, як описано в попередніх розділах.

Ви налаштуєте високодоступний кластер Apache.

Ваші два сервери мають такі IP-адреси:

- server1: 192.168.1.10
- server2: 192.168.1.11

Якщо у вас немає служби для визначення імен, заповніть файл `/etc/hosts` таким вмістом:

```bash
$ cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

192.168.1.10 server1 server1.rockylinux.lan
192.168.1.11 server2 server2.rockylinux.lan
```

Ви будете використовувати VIP-адресу `192.168.1.12`.

#### Завдання 1: Встановлення та налаштування

Для встановлення Pacemaker. Увімкніть репозиторій `highavailability`.

На обох вузлах:

```bash
sudo dnf config-manager --set-enabled highavailability
sudo dnf install pacemaker pcs
sudo firewall-cmd --permanent --add-service=high-availability
sudo firewall-cmd --reload
sudo systemctl enable pcsd --now
echo "pwdhacluster" | sudo passwd --stdin hacluster
```

На server1:

```bash
$ sudo pcs host auth server1 server2
Username: hacluster
Password:
server1: Authorized
server2: Authorized
$ sudo pcs cluster setup mycluster server1 server2
$ sudo pcs cluster start --all
$ sudo pcs cluster enable --all
$ sudo pcs property set stonith-enabled=false
```

#### Завдання 2: Додавання VIP

Перший ресурс, який ви створите у своєму кластері, — це VIP.

```bash
pcs resource create myclusterVIP ocf:heartbeat:IPaddr2 ip=192.168.1.12 cidr_netmask=24 op monitor interval=30s
```

Перевірте стан кластера:

```bash
$ sudo pcs status
Cluster name: mycluster
Cluster Summary:
...
  * 2 nodes configured
  * 1 resource instance configured

Node List:
  * Node server1: standby
  * Online: [ server2 ]

Full List of Resources:
  * myclusterVIP        (ocf:heartbeat:IPaddr2):         Started server2
```

#### Завдання 3: встановлення сервера Apache

Виконайте цю установку на обох вузлах:

```bash
$ sudo dnf install -y httpd
$ sudo firewall-cmd --permanent --add-service=http
$ sudo firewall-cmd --reload
echo "<html><body>Node $(hostname -f)</body></html>" | sudo tee "/var/www/html/index.html"
sudo vim /etc/httpd/conf.d/status.conf
<Location /server-status>
    SetHandler server-status
    Require local
</Location>
```

#### Завдання 4: Додавання ресурсу `httpd`

Тільки на server1 додайте новий ресурс до кластера з необхідними обмеженнями:

```bash
sudo pcs resource create WebSite ocf:heartbeat:apache configfile=/etc/httpd/conf/httpd.conf statusurl="http://localhost/server-status" op monitor interval=1min
sudo pcs constraint colocation add WebSite with myclusterVIP INFINITY
sudo pcs constraint order myclusterVIP then WebSite
```

#### Завдання 5: Перевірте свій кластер

Ви виконаєте відмову та перевірите, чи ваш веб-сервер усе ще доступний:

```bash
$ sudo pcs status
Cluster name: mycluster
Cluster Summary:
  * Stack: corosync (Pacemaker is running)
  * Current DC: server1 (version 2.1.7-5.el9_4-0f7f88312) - partition with quorum
  ...

Node List:
  * Online: [ server1 server2 ]

Full List of Resources:
  * myclusterVIP        (ocf:heartbeat:IPaddr2):         Started server1
  * WebSite     (ocf:heartbeat:apache):  Started server1
```

Зараз ви працюєте на сервері 1.

```bash
$ curl http://192.168.1.12/
<html><body>Node server1</body></html>
```

Симулюйте збій на server1:

```bash
sudo pcs node standby server1
```

```bash
$ curl http://192.168.1.12/
<html><body>Node server2</body></html>
```

Як бачите, ваша веб-служба все ще працює, але зараз вона знаходиться на server2.

```bash
sudo pcs node unstandby server1
```

Зверніть увагу, що послуга була перервана лише на кілька секунд, поки VIP перемикався, і служби перезапускалися.

### Перевірка знань

:heavy_check_mark: Чи єдина команда `pcs` керує кластером pacemaker?

:heavy_check_mark: Яка команда повертає стан кластера?

- [ ] `sudo pcs status`
- [ ] `systemctl status pcs`
- [ ] `sudo crm_mon -1`
- [ ] `sudo pacemaker -t`
