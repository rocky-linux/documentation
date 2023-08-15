---
title: HAProxy-Apache-LXD
author: Steven Spencer
contributors: Ezequiel Bruni, Antoine Le Morvan
tested_with: 8.5, 8.6, 9.0
---

# HAProxy Load Balancing Apache з використанням контейнерів LXD

## Вступ

HAProxy розшифровується як «High Availability Proxy». Цей проксі-сервер може стояти перед будь-якою програмою TCP (наприклад, веб-серверами), але часто використовується як балансир навантаження між кількома примірниками веб-сайту.

Для цього може бути кілька причин. Якщо у вас є веб-сайт, який сильно постраждав — додайте ще один екземпляр того самого веб-сайту та розмістіть HAProxy перед обома — це дозволить вам розподілити трафік між екземплярами. Іншою причиною може бути можливість оновлювати вміст на веб-сайті без будь-яких простоїв. HAProxy також може допомогти пом'якшити атаки DOS і DDOS.

У цьому посібнику розглядається використання HAProxy з використанням двох екземплярів веб-сайту та балансування навантаження з циклічним чергуванням на тому самому хості LXD. Це може бути чудовим рішенням для того, щоб оновлення можна було виконувати без простоїв.

Однак, якщо ваша проблема пов’язана з продуктивністю веб-сайту, вам може знадобитися розподілити кілька сайтів на фактичному «голому металі» або між кількома хостами LXD. Звичайно, все це можливо зробити на голому металі без використання LXD; однак LXD пропонує велику гнучкість і продуктивність, а також чудово підходить для лабораторних випробувань.

## Передумови та припущення

* Повний комфорт у командному рядку на машині Linux
* Досвід роботи з редактором командного рядка (тут ми використовуємо `vim`)
* Досвід роботи з `crontab`
* Знання LXD. Для отримання додаткової інформації ви можете ознайомитися з документом [LXD Server](../../books/lxd_server/00-toc.md). Це чудовий варіант для встановлення LXD на ноутбук або робочу станцію без виконання повномасштабної інсталяції сервера. Цей документ написано за допомогою лабораторної машини, на якій працює LXD, але він не налаштований як цілий сервер, як це використовується в документі, на який посилається вище.
* Деякі знання щодо встановлення, налаштування та використання веб-серверів.
* Ми припустимо, що LXD вже встановлений і готовий до створення контейнерів.

## Установка контейнерів

На вашому хості LXD для цього посібника нам знадобляться три контейнери. За бажанням може бути більше контейнерів веб-сервера. Ми будемо використовувати **web1** і **web2** для наших контейнерів веб-сайтів і **proxyha ** для нашого контейнера HAProxy. Щоб установити їх на хост LXD, виконайте такі дії:

```
lxc launch images:rockylinux/8 web1
lxc launch images:rockylinux/8 web2
lxc launch images:rockylinux/8 proxyha
```
Запуск `lxc list` має повернути щось на зразок цього:

```
+---------+---------+----------------------+------+-----------+-----------+
|  NAME   |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+---------+---------+----------------------+------+-----------+-----------+
| proxyha | RUNNING | 10.181.87.137 (eth0) |      | CONTAINER | 0         |
+---------+---------+----------------------+------+-----------+-----------+
| web1    | RUNNING | 10.181.87.207 (eth0) |      | CONTAINER | 0         |
+---------+---------+----------------------+------+-----------+-----------+
| web2    | RUNNING | 10.181.87.34 (eth0)  |      | CONTAINER | 0         |
+---------+---------+----------------------+------+-----------+-----------+
```

## Створення та використання профілю `macvlan`

Контейнери працюють на стандартному інтерфейсі мосту з адресами DHCP, призначеними мостом. Ми хочемо використовувати адреси DHCP з нашої локальної мережі, тому перше, що нам потрібно зробити, це створити та призначити профіль `macvlan`.

Почніть зі створення профілю:

`lxc profile create macvlan`

Переконайтеся, що встановлено бажаний редактор, у цьому випадку `vim`:

`export EDITOR=/usr/bin/vim`

Далі нам потрібно змінити профіль `macvlan`. Але перш ніж це зробити, нам потрібно знати, який інтерфейс хост використовує для нашої локальної мережі, тому запустіть `ip addr` і знайдіть інтерфейс із призначенням IP-адреси локальної мережі:

```
2: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether a8:5e:45:52:f8:b6 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.141/24 brd 192.168.1.255 scope global dynamic noprefixroute eno1
```
!!! Note "Примітка"

    У цьому випадку ми шукаємо інтерфейс "eno1", але він може бути зовсім іншим у вашій системі. Використовуйте інформацію про **ваш** інтерфейс!

Тепер, коли ми знаємо інтерфейс локальної мережі, ми можемо змінити наш профіль `macvlan`. Для цього в командному рядку введіть:

`lxc profile edit macvlan`

Нам потрібно зробити наш профіль приблизно таким. Ми виключили коментарі у верхній частині файлу, але якщо ви новачок у LXD, подивіться на них:

```
config: {}
description: ""
devices:
  eth0:
    name: eth0
    nictype: macvlan
    parent: eno1
    type: nic
name: macvlan
```

Під час створення профілю `macvlan` було скопійовано профіль `за замовчуванням`. Профіль `за замовчуванням` не можна змінити.

Тепер, коли у нас є профіль `macvlan`, нам потрібно застосувати його до наших трьох контейнерів:

```
lxc profile assign web1 default,macvlan
lxc profile assign web2 default,macvlan
lxc profile assign proxyha default,macvlan
```

На жаль, типова поведінка `macvlan`, реалізована в ядрі, незрозумілим чином порушена в контейнері LXD (див. [цей документ](../../books/lxd_server/06-profiles.md)) `dhclient` під час завантаження в кожному з контейнерів.

За допомогою DHCP це зробити досить просто. Просто дотримуйтесь цього для кожного контейнера:

* `lxc exec web1 bash`, який переведе вас у командний рядок контейнера **web1**
* `crontab -e`, який редагуватиме кореневий `crontab` у контейнері
* введіть `i`, щоб перейти в режим вставки.
* додайте рядок: `@reboot /usr/sbin/dhclient`
* натисніть клавішу `ESC`, щоб вийти з режиму вставки.
* збережіть зміни за допомогою `SHIFT: wq`
* введіть `exit`, щоб вийти з контейнера

Повторіть кроки для **web2** і **proxyha**.

Після виконання цих кроків перезапустіть контейнери:

```
lxc restart web1
lxc restart web2
lxc restart proxyha
```

і коли ви знову створите `lxc list`, ви побачите, що адреси DHCP тепер призначено з вашої локальної мережі:

```
+---------+---------+----------------------+------+-----------+-----------+
|  NAME   |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+---------+---------+----------------------+------+-----------+-----------+
| proxyha | RUNNING | 192.168.1.149 (eth0) |      | CONTAINER | 0         |
+---------+---------+----------------------+------+-----------+-----------+
| web1    | RUNNING | 192.168.1.150 (eth0) |      | CONTAINER | 0         |
+---------+---------+----------------------+------+-----------+-----------+
| web2    | RUNNING | 192.168.1.101 (eth0) |      | CONTAINER | 0         |
+---------+---------+----------------------+------+-----------+-----------+
```

## Встановлення Apache і зміна екрана привітання

Тепер, коли наше середовище налаштовано, нам потрібно встановити Apache (`httpd`) на кожен веб-контейнер. Це можна зробити без фізичного доступу до них:

```
lxc exec web1 dnf install httpd
lxc exec web2 dnf install httpd
```
Хоча зрозуміло, що вам знадобиться набагато більше, ніж Apache для будь-якого сучасного веб-сервера, цього достатньо для проведення деяких тестів.

Далі нам потрібно ввімкнути `httpd`, запустити його, а потім змінити екран привітання за замовчуванням, щоб ми знали, на який сервер звертаємось, коли намагаємося отримати доступ через проксі.

Увімкніть і запустіть `httpd`:

```
lxc exec web1 systemctl enable httpd
lxc exec web1 systemctl start httpd
lxc exec web2 systemctl enable httpd
lxc exec web2 systemctl start httpd
```

Тепер, коли `httpd` увімкнено та запущено, давайте змінимо екран привітання. Цей екран з’являється, коли веб-сайт не налаштовано, по суті це сторінка за замовчуванням, яка завантажується. У Rocky Linux ця сторінка розташована тут `/usr/share/httpd/noindex/index.html`. Знову ж таки, щоб змінити цей файл, немає потреби в прямому доступі до контейнера. Просто виконайте наступне:

`lxc exec web1 vi /usr/share/httpd/noindex/index.html`

а потім виконайте пошук за тегом `<h1>`, який має показати це:

`<h1>HTTP Server <strong>Test Page</strong></h1>`

Просто змініть цей рядок на:

`<h1>SITE1 HTTP Server <strong>Test Page</strong></h1>`

Тепер повторіть процес для web2. Перехід до цих машин через IP у браузері має повернути правильну сторінку привітання для кожної. На веб-серверах є чим зайнятися, але давайте залишимо їх і перейдемо до проксі-сервера.

## Встановлення HAProxy на proxyha та конфігурації проксі LXD

Так само легко встановити HAProxy на проксі-контейнер. Знову ж таки, немає необхідності безпосереднього доступу до цього контейнера:

`lxc exec proxyha dnf install haproxy`

Далі ми хочемо налаштувати `haproxy` для прослуховування портів 80 і 443 для веб-служб. Це робиться за допомогою підкоманди configure `lxc`:
```
lxc config device add proxyha http proxy listen=tcp:0.0.0.0:80 connect=tcp:127.0.0.1:80
lxc config device add proxyha https proxy listen=tcp:0.0.0.0:443 connect=tcp:127.0.0.1:443
```

Для нашого тестування ми будемо використовувати лише порт 80 або трафік HTTP, але тут показано, як налаштувати контейнер для прослуховування веб-портів за замовчуванням для HTTP та HTTPS. Використання цієї команди також гарантує, що перезапуск контейнера **proxyha** збереже ці порти прослуховування.

## Конфігурація HAProxy

Ми вже встановили HAProxy на контейнер, але нічого не зробили з конфігурацією. Перш ніж щось робити, нам потрібно щось зробити, щоб вирішити наші хости. Зазвичай ми використовуємо повні доменні імена, але в цьому лабораторному середовищі ми використовуємо IP-адреси. Щоб отримати деякі імена, пов’язані з машинами, ми збираємося додати деякі записи файлів хосту до контейнера **proxyha**.

`lxc exec proxyha vi /etc/hosts`

Додайте такі записи внизу файлу:

```
192.168.1.150   site1.testdomain.com     site1
192.168.1.101   site2.testdomain.com     site2
```

Що має дозволити контейнеру **proxyha** розпізнавати ці імена.

Коли це буде завершено, давайте відредагуємо файл `haproxy.cfg`. У оригінальному файлі є стільки всього, що ми не збираємося використовувати, що ми просто збираємося спочатку зробити його резервну копію, перемістивши його під іншу назву:

`lxc exec proxyha mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.orig`

Тепер давайте створимо новий файл конфігурації:

`lxc exec proxyha vi /etc/haproxy/haproxy.cfg`

Зауважте, що наразі ми закоментували всі рядки протоколу HTTPS. У робочому середовищі ви захочете використовувати сертифікат підстановки, який охоплюватиме ваші веб-сервери та вмикатиме HTTPS:

```
global
log /dev/log local0
log /dev/log local1 notice
chroot /var/lib/haproxy
stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
stats timeout 30s
user haproxy
group haproxy
daemon

# For now, all https is remarked out
#
#ssl-default-bind-options no-sslv3 no-tlsv10 no-tlsv11 no-tls-tickets
#ssl-default-bind-ciphers EECDH+AESGCM:EDH+AESGCM
#tune.ssl.default-dh-param 2048

defaults
log global
mode http
option httplog
option dontlognull
option forwardfor
option http-server-close
timeout connect 5000
timeout client 50000
timeout server 50000
errorfile 400 /etc/haproxy/errors/400.http
errorfile 403 /etc/haproxy/errors/403.http
errorfile 408 /etc/haproxy/errors/408.http
errorfile 500 /etc/haproxy/errors/500.http
errorfile 502 /etc/haproxy/errors/502.http
errorfile 503 /etc/haproxy/errors/503.http
errorfile 504 /etc/haproxy/errors/504.http

# For now, all https is remarked out
# frontend www-https
# bind *:443 ssl crt /etc/letsencrypt/live/example.com/example.com.pem
# reqadd X-Forwarded-Proto:\ https

# acl host_web1 hdr(host) -i site1.testdomain.com
# acl host_web2 hdr(host) -i site2.testdomain.com

# use_backend subdomain1 if host_web1
# use_backend subdomain2 if host_web2

frontend http_frontend
bind *:80

acl web_host1 hdr(host) -i site1.testdomain.com
acl web_host2 hdr(host) -i site2.testdomain.com

use_backend subdomain1 if web_host1
use_backend subdomain2 if web_host2

backend subdomain1
# balance leastconn
  balance roundrobin
  http-request set-header X-Client-IP %[src]
# redirect scheme https if !{ ssl_fc }
     server site1 site1.testdomain.com:80 check
     server site2 web2.testdomain.com:80 check

backend subdomain2
# balance leastconn
  balance roundrobin
  http-request set-header X-Client-IP %[src]
# redirect scheme https if !{ ssl_fc }
     server site2 site2.testdomain.com:80 check
     server site1 site1.testdomain.com:80 check
```

Невелике пояснення того, що відбувається вище. Ви повинні побачити це під час тестування, коли перейдете до розділу тестування цього посібника (нижче):

І **site1**, і **site2** визначено в розділі "acl". Потім обидва **site1** і **site2** включаються до "круглого циклу" один одного для відповідних серверних частин. Що відбувається, коли ви заходите на site1.testdomain.com у тесті, URL-адреса не змінюється, але сторінка всередині змінюватиметься щоразу, коли ви переходите на сторінку з **site1** на тестові сторінки **site2**. Те саме стосується site2.testdomain.com.

Це робиться для того, щоб показати вам, що відбувається перемикання, але вміст вашого веб-сайту виглядатиме однаково незалежно від того, який сервер ви використовуєте. Майте на увазі, що ми показуємо, як ви можете розподілити трафік між кількома хостами. Ви також можете використовувати «leastcon» у рядку балансу, і замість перемикання на основі попереднього попадання він завантажуватиме сайт із найменшою кількістю підключень.

### Файли помилок

Деякі версії HAProxy постачаються зі стандартним набором веб-файлів помилок; однак у версії від Rocky Linux (і постачальника вищої версії) немає цих файлів. Ймовірно, ви **робите** хочете їх створити, оскільки вони можуть допомогти вам вирішити будь-які проблеми. Ці файли зберігаються в каталозі `/etc/haproxy/errors`, якого не існує.

Перше, що нам потрібно зробити, це створити цей каталог:

`lxc exec proxyha mkdir /etc/haproxy/errors`

Потім нам потрібно створити кожен із цих файлів у цьому каталозі. Зауважте, що ви можете зробити це з кожним ім’ям файлу на вашому хості LXD за допомогою команди `lxc exec proxyha vi /etc/haproxy/errors/filename.http`, де «filename.http» посилається на одне з імен файлів нижче. У виробничому середовищі ваша компанія може мати більш специфічні помилки, які вони хотіли б використовувати:

Ім'я файлу `400.http`:

```
HTTP/1.0 400 Bad request
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>400 Bad request</h1>
Your browser sent an invalid request.
</body></html>
```

Ім'я файлу `403.http`:

```
HTTP/1.0 403 Forbidden
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>403 Forbidden</h1>
Request forbidden by administrative rules.
</body></html>
```

Ім'я файлу `408.http`:

```
HTTP/1.0 408 Request Time-out
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>408 Request Time-out</h1>
Your browser didn't send a complete request in time.
</body></html>
```

Ім'я файлу `500.http`:

```
HTTP/1.0 500 Internal Server Error
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>500 Internal Server Error</h1>
An internal server error occurred.
</body></html>
```

Ім'я файлу `502.http`:

```
HTTP/1.0 502 Bad Gateway
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>502 Bad Gateway</h1>
The server returned an invalid or incomplete response.
</body></html>
```

Filename `503.http`:

```
HTTP/1.0 503 Service Unavailable
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>503 Service Unavailable</h1>
No server is available to handle this request.
</body></html>
```

Filename `504.http`:

```
HTTP/1.0 504 Gateway Time-out
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>504 Gateway Time-out</h1>
The server didn't respond in time.
</body></html>
```

## Запуск проксі

Нам потрібно створити каталог «run» для `haproxy` перед запуском служби:

`lxc exec proxyha mkdir /run/haproxy`

Далі нам потрібно включити службу і запустити її:
```
lxc exec proxyha systemctl enable haproxy
lxc exec proxyha systemctl start haproxy
```
Якщо ви отримуєте будь-які помилки, дослідіть причину за допомогою:

`lxc exec proxyha systemctl status haproxy`

Якщо все запускається і працює без проблем, ми готові переходити до тестування.

## Тестування проксі

Як і у випадку з налаштуваннями хостів (`/etc/hosts`), які ми використовували, щоб наш контейнер **proxyha** міг розпізнавати веб-сервери, і оскільки в нашому у лабораторному середовищі, якщо у нас не працює локальний DNS-сервер, нам потрібно встановити значення IP на нашому локальному комп’ютері для веб-сайтів site1 і site2, щоб вони відповідали нашому гапроксі-контейнеру.

Для цього нам потрібно змінити наш файл `/etc/hosts` на нашій локальній машині. Вважайте цей метод визначення домену «DNS для бідняків».

`sudo vi /etc/hosts`

Потім просто додайте ці два рядки:

```
192.168.1.149   site1.testdomain.com     site1
192.168.1.149   site2.testdomain.com     site2
```

Якщо ви зараз перевірите **site1** або **site2** на вашій локальній машині, ви маєте отримати відповідь від **proxyha**:

```
PING site1.testdomain.com (192.168.1.149) 56(84) bytes of data.
64 bytes from site1.testdomain.com (192.168.1.149): icmp_seq=1 ttl=64 time=0.427 ms
64 bytes from site1.testdomain.com (192.168.1.149): icmp_seq=2 ttl=64 time=0.430 ms
```

Тепер відкрийте веб-переглядач і в адресному рядку введіть URL-адресу site1.testdomain.com (або site2.testdomain.com). Ви повинні отримати відповідь від однієї з двох тестових сторінок, і якщо ви знову завантажите сторінку, вам слід звернутися до тестової сторінки наступного сервера. Зауважте, що URL-адреса не змінюється, але повернута сторінка по черзі перемикатиметься між серверами.


![знімок екрана із завантаженням web1 і показом другого тестового повідомлення сервера](../images/haproxy_apache_lxd.png)

## Ведення журналу

Незважаючи на те, що наш конфігураційний файл налаштовано правильно для журналювання, нам потрібні дві речі: по-перше, нам потрібен каталог у /var/lib/haproxy/ під назвою "dev":

`lxc exec proxyha mkdir /var/lib/haproxy/dev`

Далі нам потрібно створити системний процес для `rsyslogd`, щоб захоплювати екземпляри з сокета (`/var/lib/haproxy/dev/log` у цьому випадку) і зберігати їх у `/var/log/haproxy.log`:

`lxc exec proxyha vi /etc/rsyslog.d/99-haproxy.conf`

Додайте такий вміст до цього файлу:

```
$AddUnixListenSocket /var/lib/haproxy/dev/log

# Send HAProxy messages to a dedicated logfile
:programname, startswith, "haproxy" {
  /var/log/haproxy.log
  stop
}
```
Збережіть файл і вийдіть, а потім перезапустіть `rsyslog`:

`lxc exec proxyha systemctl restart rsyslog`

Щоб негайно заповнити файл журналу чимось, перезапустіть `haproxy` знову:

`lxc exec proxyha systemctl restart haproxy`

Щоб переглянути створений файл журналу:

`lxc exec proxyha more /var/log/haproxy.log`

Що має показати вам щось на зразок цього:

```
Sep 25 23:18:02 proxyha haproxy[4602]: Proxy http_frontend started.
Sep 25 23:18:02 proxyha haproxy[4602]: Proxy http_frontend started.
Sep 25 23:18:02 proxyha haproxy[4602]: Proxy subdomain1 started.
Sep 25 23:18:02 proxyha haproxy[4602]: Proxy subdomain1 started.
Sep 25 23:18:02 proxyha haproxy[4602]: Proxy subdomain2 started.
Sep 25 23:18:02 proxyha haproxy[4602]: Proxy subdomain2 started.
```

## Висновки

HAProxy — це потужний механізм проксі, який можна використовувати для багатьох речей. Це високопродуктивний балансувальник навантаження з відкритим вихідним кодом і зворотний проксі для програм TCP і HTTP. У цьому документі ми показали, як використовувати балансування навантаження двох примірників веб-сервера.

Його також можна використовувати для інших програм, включаючи бази даних. Він працює в контейнерах LXD, а також на голих і автономних серверах.

Є багато застосувань, які не розглядаються в цьому документі. Перегляньте [офіційний посібник для HAProxy тут.](https://cbonte.github.io/haproxy-dconv/1.8/configuration.html)
