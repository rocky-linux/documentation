---
title: HAProxy-Apache-LXD
author: Steven Spencer
contributors: Ezequiel Bruni, Antoine Le Morvan, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
---

# HAProxy балансування навантаження Apache з контейнерами LXD

## Вступ

HAProxy розшифровується як «High Availability Proxy». Цей проксі-сервер може стояти перед будь-якою програмою TCP (наприклад, веб-серверами), але часто використовується як балансир навантаження між багатьма примірниками веб-сайтів.

Для цього може бути кілька причин. Якщо у вас є веб-сайт, який сильно постраждав — додайте ще один екземпляр того самого веб-сайту та розмістіть HAProxy перед обома — це дозволить вам розподілити трафік між екземплярами. Іншою причиною може бути можливість оновлювати вміст на веб-сайті без будь-яких простоїв. HAProxy також може допомогти пом'якшити атаки DOS і DDOS.

У цьому посібнику розглядається використання HAProxy із двома екземплярами веб-сайтів і балансування навантаження з циклічним чергуванням на одному хості LXD. Це може бути чудовим рішенням для того, щоб оновлення можна було виконувати без простоїв.

Однак, якщо ваша проблема пов’язана з продуктивністю веб-сайту, вам може знадобитися розподілити кілька сайтів між фактичними «голими металами» або кількома хостами LXD. Все це можна зробити на голому металі без використання LXD. Однак LXD пропонує велику гнучкість і продуктивність, а також чудово підходить для лабораторних випробувань.

## Передумови та припущення

- Повний комфорт у командному рядку на машині Linux
- Досвід роботи з редактором командного рядка (тут ми використовуємо `vim`)
- Досвід роботи з `crontab`
- Знання LXD. Для отримання додаткової інформації ви можете ознайомитися з документом [LXD Server](../../books/lxd_server/00-toc.md). Можна встановити LXD на ноутбук або робочу станцію, не виконуючи повномасштабну інсталяцію сервера. Цей документ написаний на лабораторній машині, на якій працює LXD, але не налаштований як цілий сервер, як це використовується в наведеному вище документі.
- Деякі знання щодо встановлення, налаштування та використання веб-серверів.
- Ми припустимо, що LXD вже встановлений і готовий до створення контейнерів.

## Установка контейнерів

На вашому хості LXD для цього посібника вам знадобляться три контейнери. За бажанням може бути більше контейнерів веб-сервера. Ви будете використовувати **web1** і **web2** для наших контейнерів веб-сайтів і **proxyha ** для нашого контейнера HAProxy. Щоб установити їх на хост LXD, виконайте такі дії:

```bash
lxc launch images:rockylinux/8 web1
lxc launch images:rockylinux/8 web2
lxc launch images:rockylinux/8 proxyha
```

Запуск `lxc list` має повернути щось на зразок цього:

```bash
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

Контейнери працюють на стандартному інтерфейсі мосту з адресами DHCP, призначеними мостом. Їх потрібно змінити на адреси DHCP з нашої локальної локальної мережі. Перше, що потрібно, це створити та призначити профіль `macvlan`.

Почніть зі створення профілю:

`lxc profile create macvlan`

Переконайтеся, що для вашого редактора встановлено бажаний редактор, у цьому випадку `vim`:

`export EDITOR=/usr/bin/vim`

Далі змініть профіль `macvlan`. Але перш ніж це зробити, ви повинні знати, який інтерфейс хост використовує для нашої локальної мережі. Запустіть `ip addr` і знайдіть інтерфейс із призначенням IP-адреси локальної мережі:

```bash
2: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether a8:5e:45:52:f8:b6 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.141/24 brd 192.168.1.255 scope global dynamic noprefixroute eno1
```

!!! Note "Примітка"

    У цьому випадку ви шукаєте інтерфейс "eno1", який може бути зовсім іншим у вашій системі. Використовуйте інформацію про **ваш** інтерфейс!

Тепер, коли ви знаєте інтерфейс локальної мережі, ви можете змінити наш профіль `macvlan`. Для цього в командному рядку введіть:

`lxc profile edit macvlan`

Відредагуйте профіль, щоб він виглядав приблизно так. Автор виключив коментарі у верхній частині файлу, але якщо ви новачок у LXD, перегляньте їх:

```bash
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

Під час створення профілю `macvlan` система копіює профіль `за замовчуванням`. Змінити профіль `за замовчуванням` неможливо.

Тепер, коли профіль `macvlan` існує, вам потрібно застосувати його до наших трьох контейнерів:

```bash
lxc profile assign web1 default,macvlan
lxc profile assign web2 default,macvlan
lxc profile assign proxyha default,macvlan
```

На жаль, типова поведінка `macvlan`, реалізована в ядрі, незрозумілим чином порушена в контейнері LXD (див. [цей документ](../../books/lxd_server/06-profiles.md)) `dhclient` під час завантаження в кожному з контейнерів.

Зробити це досить просто при використанні DHCP. Просто дотримуйтесь цього для кожного контейнера:

- `lxc exec web1 bash`, який переведе вас у командний рядок контейнера **web1**
- `crontab -e`, який редагуватиме кореневий `crontab` у контейнері
- введіть ++i++ , щоб перейти в режим вставки.
- додайте рядок: `@reboot /usr/sbin/dhclient`
- натисніть клавішу  ++escape++, щоб вийти з режиму вставки.
- збережіть зміни за допомогою ++shift++colon+w+q++
- введіть `exit`, щоб вийти з контейнера

Повторіть кроки для **web2** і **proxyha**.

Після виконання цих кроків перезапустіть контейнери:

```bash
lxc restart web1
lxc restart web2
lxc restart proxyha
```

і коли ви знову створите `список lxc`, ви побачите, що адреси DHCP тепер призначено з вашої локальної мережі:

```bash
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

Наше середовище готове. Далі встановіть Apache (`httpd`) на кожен веб-контейнер. Ви можете зробити це без фізичного доступу до них:

```bash
lxc exec web1 dnf install httpd
lxc exec web2 dnf install httpd
```

Вам знадобиться більше, ніж Apache для будь-якого сучасного веб-сервера, але цього достатньо, щоб провести деякі тести.

Потім увімкніть `httpd`, запустіть його та змініть типовий екран привітання. Таким чином ви знаєте, що сервер відповідає на спробу доступу через проксі.

Увімкніть і запустіть `httpd`:

```bash
lxc exec web1 systemctl enable httpd
lxc exec web1 systemctl start httpd
lxc exec web2 systemctl enable httpd
lxc exec web2 systemctl start httpd
```

Змініть екран привітання. Цей екран з’являється, коли веб-сайт не налаштовано, по суті це сторінка за замовчуванням, яка завантажується. У Rocky Linux ця сторінка розташована тут `/usr/share/httpd/noindex/index.html`. Зміна цього файлу не вимагає прямого доступу до контейнера. Просто виконайте наступне:

`lxc exec web1 vi /usr/share/httpd/noindex/index.html`

знайдіть тег `<h1>`, який покаже це:

`<h1>HTTP Server <strong>Test Page</strong></h1>`

Змініть цей рядок на:

`<h1>SITE1 HTTP Server <strong>Test Page</strong></h1>`

Повторіть процес для web2. Перехід до цих машин через IP у браузері тепер повертатиме правильну сторінку привітання для кожної. З веб-серверами можна зробити більше, але поки що залиште їх і перейдіть до проксі-сервера.

## Встановлення HAProxy на proxyha та конфігурації проксі LXD

Так само легко встановити HAProxy на проксі-контейнер. Знову ж таки, немає необхідності безпосереднього доступу до цього контейнера:

`lxc exec proxyha dnf install haproxy`

Далі ви хочете налаштувати `haproxy` для прослуховування веб-служб на портах 80 і 443. Зробіть це за допомогою підкоманди configure `lxc`:

```bash
lxc config device add proxyha http proxy listen=tcp:0.0.0.0:80 connect=tcp:127.0.0.1:80
lxc config device add proxyha https proxy listen=tcp:0.0.0.0:443 connect=tcp:127.0.0.1:443
```

Для нашого тестування ви використовуватимете лише порт 80 або трафік HTTP, але тут показано, як ви налаштовуєте контейнер для прослуховування веб-портів за замовчуванням для HTTP та HTTPS. Використання цієї команди також гарантує, що перезапуск контейнера **proxyha** збереже ці порти прослуховування.

## Конфігурація HAProxy

Ви встановили HAProxy на контейнер, але нічого не зробили з конфігурацією. Перш ніж налаштовувати, вам потрібно щось зробити, щоб вирішити ваші хости. Зазвичай ви використовуєте повні доменні імена, але в цьому лабораторному середовищі ви використовуєте IP-адреси. Щоб отримати деякі імена, пов’язані з машинами, ви збираєтеся додати деякі записи файлів хосту до контейнера **proxyha**.

`lxc exec proxyha vi /etc/hosts`

Додайте такі записи внизу файлу:

```bash
192.168.1.150   site1.testdomain.com     site1
192.168.1.101   site2.testdomain.com     site2
```

Що дозволяє контейнеру **proxyha** розпізнавати ці імена.

Відредагуйте файл `haproxy.cfg`. Ви не використовуєте більшу частину оригінального файлу. Спочатку потрібно створити резервну копію файлу, перемістивши його під іншу назву:

`lxc exec proxyha mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.orig`

Створіть новий файл конфігурації:

`lxc exec proxyha vi /etc/haproxy/haproxy.cfg`

Зверніть увагу, наразі коментування рядків протоколу HTTPS. У робочому середовищі ви захочете використовувати сертифікат підстановки, який охоплює ваші веб-сервери та вмикає HTTPS:

```bash
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

Визначення для **site1** і **site2** знаходяться в розділі «acl». Кожен сайт є циклічним циклом для відповідних серверів. Що відбувається, коли ви заходите на site1.testdomain.com у тесті, URL-адреса не змінюється, але сторінка всередині змінюватиметься щоразу, коли ви переходите на сторінку з **site1** на тестові сторінки **site2**. Те саме стосується site2.testdomain.com.

Це показує, що відбувається перемикання, але вміст вашого веб-сайту виглядатиме однаково незалежно від того, який сервер ви використовуєте. У документі показано, як ви можете розподілити трафік між кількома хостами. Ви також можете використовувати «leastcon» у рядку балансу, і замість перемикання на основі попереднього попадання він завантажуватиме сайт із найменшою кількістю підключень.

### Файли помилок

Деякі версії HAProxy постачаються зі стандартним набором веб-файлів помилок; однак у версії від Rocky Linux (і постачальника вищої версії) немає цих файлів. Ймовірно, ви **робите** хочете їх створити, оскільки вони можуть допомогти вам вирішити будь-які проблеми. Ці файли зберігаються в каталозі `/etc/haproxy/errors`, якого не існує.

Спочатку створіть цей каталог:

`lxc exec proxyha mkdir /etc/haproxy/errors`

Створіть кожен із цих файлів у цьому каталозі. Зауважте, що ви можете зробити це з кожним ім’ям файлу на вашому хості LXD за допомогою команди `lxc exec proxyha vi /etc/haproxy/errors/filename.http`, де «filename.http» посилається на одне з імен файлів нижче. У виробничому середовищі ваша компанія може мати більш специфічні помилки, які вони хочуть використовувати:

Ім'я файлу `400.http`:

```bash
HTTP/1.0 400 Bad request
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>400 Bad request</h1>
Your browser sent an invalid request.
</body></html>
```

Ім'я файлу `403.http`:

```bash
HTTP/1.0 403 Forbidden
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>403 Forbidden</h1>
Request forbidden by administrative rules.
</body></html>
```

Ім'я файлу `408.http`:

```bash
HTTP/1.0 408 Request Time-out
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>408 Request Time-out</h1>
Your browser didn't send a complete request in time.
</body></html>
```

Ім'я файлу `500.http`:

```bash
HTTP/1.0 500 Internal Server Error
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>500 Internal Server Error</h1>
An internal server error occurred.
</body></html>
```

Ім'я файлу `502.http`:

```bash
HTTP/1.0 502 Bad Gateway
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>502 Bad Gateway</h1>
The server returned an invalid or incomplete response.
</body></html>
```

Filename `503.http`:

```bash
HTTP/1.0 503 Service Unavailable
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>503 Service Unavailable</h1>
No server is available to handle this request.
</body></html>
```

Filename `504.http`:

```bash
HTTP/1.0 504 Gateway Time-out
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>504 Gateway Time-out</h1>
The server didn't respond in time.
</body></html>
```

## Запуск проксі

Створіть каталог «run» для `haproxy` перед запуском служби:

`lxc exec proxyha mkdir /run/haproxy`

Далі включаємо службу і запускаємо її:

```bash
lxc exec proxyha systemctl enable haproxy
lxc exec proxyha systemctl start haproxy
```

Якщо ви отримуєте будь-які помилки, дослідіть причину за допомогою:

`lxc exec proxyha systemctl status haproxy`

Якщо все запускається і працює без проблем, ми готові переходити до тестування.

## Тестування проксі

Як і у випадку з налаштуваннями хостів (`/etc/hosts`), які використовуються для того, щоб наш контейнер **proxyha** міг розпізнавати веб-сервери, а оскільки наше лабораторне середовище робить не має запущеного локального DNS-сервера, встановіть значення IP на нашій локальній машині для кожного веб-сайту, щоб відповідати нашому haproxy контейнеру.

Для цього змініть файл `/etc/hosts` на локальній машині. Вважайте цей метод визначення домену «DNS для бідняків».

`sudo vi /etc/hosts`

Додайте ці два рядки:

```bash
192.168.1.149   site1.testdomain.com     site1
192.168.1.149   site2.testdomain.com     site2
```

Якщо ви зараз перевірите **site1** або **site2** на вашій локальній машині, ви отримаєте відповідь від **proxyha**:

```bash
PING site1.testdomain.com (192.168.1.149) 56(84) bytes of data.
64 bytes from site1.testdomain.com (192.168.1.149): icmp_seq=1 ttl=64 time=0.427 ms
64 bytes from site1.testdomain.com (192.168.1.149): icmp_seq=2 ttl=64 time=0.430 ms
```

Відкрийте веб-переглядач і в адресному рядку введіть URL-адресу site1.testdomain.com (або site2.testdomain.com). Ви отримаєте відповідь від однієї з двох тестових сторінок, і якщо ви знову завантажите сторінку, ви отримаєте наступну тестову сторінку сервера. Зауважте, що URL-адреса не змінюється, але повернута сторінка по черзі перемикатиметься між серверами.

![знімок екрана із завантаженням web1 і показом другого тестового повідомлення сервера](../images/haproxy_apache_lxd.png)

## Ведення журналу

Незважаючи на те, що наш конфігураційний файл налаштовано правильно для журналювання, вам потрібні дві речі: по-перше, каталог у /var/lib/haproxy/ під назвою «dev»:

`lxc exec proxyha mkdir /var/lib/haproxy/dev`

Потім створіть системний процес для `rsyslogd`, щоб захоплювати екземпляри з сокета (`/var/lib/haproxy/dev/log` у цьому випадку) і зберігати їх у ` /var/log/haproxy.log`:

`lxc exec proxyha vi /etc/rsyslog.d/99-haproxy.conf`

Додайте такий вміст до цього файлу:

```bash
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

```bash
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
