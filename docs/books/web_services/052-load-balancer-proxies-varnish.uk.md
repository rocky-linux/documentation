---
author: Antoine Le Morvan
contributors: Ganna Zhyrnova
title: Частина 5.2 Varnish
---

## Varnish

У цьому розділі ви дізнаєтесь про кеш-проксі веб-прискорювача: Varnish.

****

**Цілі**: Ви дізнаєтеся, як:

:heavy_check_mark: Встановити та налаштувати Varnish;\
:heavy_check_mark: Кешувати вміст веб-сайту.

:checkered_flag: **зворотний проксі**, **кеш**

**Знання**: :star: :star:\
**Складність**: :star: :star: :star:

**Час читання**: 30 хвилин

****

### Загальні положення

Varnish — це служба зворотного проксі-кешу HTTP або прискорювач веб-сайтів.

Varnish отримує HTTP-запити від відвідувачів:

- Якщо відповідь на кешований запит доступна, вона повертає відповідь безпосередньо клієнту з пам’яті сервера,
- Якщо він не має відповіді, Varnish звертається до веб-сервера. Потім Varnish надсилає запит на веб-сервер, отримує відповідь, зберігає її у своєму кеші та відповідає клієнту.

Відповідь із кешу в пам’яті покращує час відповіді для клієнтів. У цьому випадку немає доступу до фізичних дисків.

За замовчуванням Varnish прослуховує порт **6081** і використовує **VCL** (**V**arnish **C**onfiguration **L**language) для своєї конфігурації. Завдяки VCL можна:

- Визначити вміст, який клієнт отримує шляхом передачі
- Визначити кешований вміст
- З якого сайту і як відбуваються зміни відповіді.

Varnish розширюється за допомогою модулів VMOD (Varnish Modules).

#### Забезпечення високої доступності

Використання кількох механізмів забезпечує високу доступність у всьому веб-ланцюжку:

- Якщо varnish знаходиться за балансувальниками навантаження (LB), вони вже перебувають у режимі HA, оскільки LB зазвичай перебувають у режимі кластера. Перевірка від LBs підтверджує наявність Varnish. Якщо сервер varnish більше не відповідає, він автоматично видаляється з пулу доступних серверів. В цьому випадку varnish знаходиться в режимі ACTIVE/ACTIVE.
- якщо varnish не знаходиться за кластером LB, клієнти звертаються до VIP (див. розділ Heartbeat), спільного між двома varnish. У цьому випадку varnish знаходиться в режимі ACTIVE/PASSIVE. VIP перемикається на другий вузол varnish, якщо активний сервер недоступний.
- Якщо серверна частина більше не доступна, ви можете видалити її з пулу серверної версії varnish або автоматично (за допомогою перевірки працездатності), або вручну в режимі CLI (корисно для полегшення оновлень).

#### Забезпечення масштабованості

Якщо серверних модулів вже недостатньо для підтримки робочого навантаження:

- або додати більше ресурсів до серверних модулів і переналаштувати проміжне програмне забезпечення
- або додайте іншу серверну частину до пулу серверної обробки varnish

#### Полегшення масштабованості

Під час створення веб-сторінка часто складається з HTML (часто динамічно створеного PHP) і більш статичних ресурсів (JPG, gif, CSS, js тощо). Швидко стає цікаво кешувати кешовані ресурси (статичні), що розвантажує багато запитів із серверних програм.

!!! NOTE "Примітка"

```
Кешування веб-сторінок (HTML, PHP, ASP, JSP тощо) можливо, але це складніше. Вам потрібно знати додаток і чи кешуються сторінки, що має бути у випадку з REST API.
```

Коли клієнт безпосередньо звертається до веб-сервера, сервер повинен повертати те саме зображення так часто, як запитує клієнт. Коли клієнт отримав зображення вперше, воно кешується на стороні браузера, залежно від конфігурації сайту та веб-програми.

Під час доступу до сервера за належним чином налаштованим сервером кешу перший клієнт, який запитує зображення, ініціює початковий запит серверної частини. Однак кешування зображення відбуватиметься протягом певного періоду, а подальша доставка буде спрямована іншим клієнтам, які запитують той самий ресурс.

Хоча добре налаштований кеш на стороні браузера зменшує кількість запитів до серверної частини, він доповнює використання кеш-проксі-сервера.

#### Керування сертифікатами TLS

Varnish не може спілкуватися через HTTPS (і це не його роль).

Отже, сертифікат:

- передається LB, коли потік проходить через нього (рекомендованим рішенням є централізація сертифіката тощо). Потім потік проходить незашифрованим через центр обробки даних.
- передається службою Apache, Nginx або HAProxy на самому сервері varnish, який діє лише як проксі для varnish (від порту 443 до порту 80). Це рішення корисно при безпосередньому доступі до varnish.
- Подібним чином Varnish не може зв’язуватися з серверними частинами через порт 443. Якщо необхідно, вам потрібно використовувати зворотний проксі-сервер Nginx або Apache, щоб розшифрувати запит на varnish.

#### Як це працює

У базовій веб-службі клієнт зв’язується безпосередньо зі службою через TCP на порту 80.

![How a standard website works](img/varnish_website.png)

Щоб використовувати кеш, клієнт повинен зв’язатися з веб-службою через стандартний порт Varnish 6081.

![How Varnish works by default](img/varnish_website_with_varnish.png)

Щоб зробити службу прозорою для клієнта, вам потрібно буде змінити порт прослуховування за замовчуванням для Varnish і vhosts веб-служби.

![Transparent implementation for the customer](img/varnish_website_with_varnish_port_80.png)

Щоб надати службу HTTPS, вам потрібно буде додати або балансувальник навантаження перед службою варіювання, або проксі-сервер на сервері версії, наприклад Apache, Nginx або HAProxy.

### Конфігурація

Установка проста:

```bash
dnf install -y varnish
systemctl enable varnish
systemctl start varnish
```

#### Налаштування демона varnish

Починаючи з `systemctl`, параметри varnish налаштовуються завдяки службовому файлу `/usr/lib/systemd/system/varnish.service`:

```bash
[Unit]
Description=Varnish Cache, a high-performance HTTP accelerator
After=network-online.target

[Service]
Type=forking
KillMode=process

# Maximum number of open files (for ulimit -n)
LimitNOFILE=131072

# Locked shared memory - should suffice to lock the shared memory log
# (varnishd -l argument)
# Default log size is 80MB vsl + 1M vsm + header -> 82MB
# unit is bytes
LimitMEMLOCK=85983232

# Enable this to avoid "fork failed" on reload.
TasksMax=infinity

# Maximum size of the corefile.
LimitCORE=infinity

ExecStart=/usr/sbin/varnishd -a :6081 -f /etc/varnish/default.vcl -s malloc,256m
ExecReload=/usr/sbin/varnishreload

[Install]
WantedBy=multi-user.target
```

Змініть значення за замовчуванням завдяки `systemctl edit varnish.service`: це створить файл `/etc/systemd/system/varnish.service.d/override.conf`:

```bash
$ sudo systemctl edit varnish.service
[Service]
ExecStart=/usr/sbin/varnishd -a :6081 -f /etc/varnish/default.vcl -s malloc,512m
```

Ви можете вибрати опцію кілька разів, щоб указати серверну частину кешу. Можливі типи зберігання: `malloc` (кешувати в пам’яті, потім замінити, якщо потрібно) або `file` (створити файл на диску, а потім відобразити в пам’яті). Розміри виражаються в K/M/G/T (кілобайтах, мегабайтах, гігабайтах або терабайтах).

#### Налаштування бекендів

Для конфігурації Varnish використовується спеціальна мова під назвою VCL.

Це передбачає компіляцію файлу конфігурації VCL на C. Якщо компіляція пройшла успішно без сигналів тривоги, службу можна перезапустити.

Ви можете перевірити конфігурацію лаку за допомогою такої команди:

```bash
varnishd -C -f /etc/varnish/default.vcl
```

!!! NOTE "Примітка"

```
Бажано перевірити синтаксис VCL перед перезапуском демона varnishd.
```

Перезавантажте конфігурацію командою:

```bash
systemctl reload varnishd
```

!!! warning "Важливо"

`systemctl restart varnishd` очищає кеш-пам’ять varnish і спричиняє пікове навантаження на сервери. Тому вам слід уникати перезавантаження varnishd.

!!! NOTE "Примітка"

```
Щоб налаштувати Varnish, дотримуйтесь рекомендацій на цій сторінці: <https://www.getpagespeed.com/server-setup/varnish/varnish-virtual-hosts>.
```

### Мова VCL

#### Підпрограми

Varnish використовує файли VCL, сегментовані на підпрограми, що містять дії для виконання. Ці підпрограми виконуються лише в конкретних випадках, які вони визначають. Типовий файл `/etc/varnish/default.vcl` містить підпрограми `vcl_recv`, `vcl_backend_response` і `vcl_deliver`:

```bash
#
# This is an example VCL file for Varnish.
#
# It does not do anything by default, delegating control to the
# builtin VCL. The builtin VCL is called when there is no explicit
# return statement.
#
# See the VCL chapters in the Users Guide at https://www.varnish-cache.org/docs/
# and http://varnish-cache.org/trac/wiki/VCLExamples for more examples.

# Marker to tell the VCL compiler that this VCL has been adapted to the
# new 4.0 format.
vcl 4.0;

# Default backend definition. Set this to point to your content server.
backend default {
    .host = "127.0.0.1";
    .port = "8080";
}

sub vcl_recv {

}

sub vcl_backend_response {

}

sub vcl_deliver {

}
```

- **vcl_recv**: підпрограма, що викликається перед надсиланням запиту до серверної частини. У цій процедурі ви можете змінювати заголовки HTTP та файли cookie, вибирати серверну частину тощо. Перегляньте дії `set req`.
- **vcl_backend_response**: процедура викликається після отримання відповіді серверної частини (`beresp` означає BackEnd RESPonse). Перегляньте дії `set bereq.` і `set beresp.`.
- **vcl_deliver**: Ця процедура підходить для модифікації виводу Varnish. Якщо вам потрібно змінити кінцевий об’єкт (наприклад, додати або видалити заголовок), ви можете зробити це у `vcl_deliver`.

#### Оператори VCL

- `=`: призначення
- `==`: порівняння
- `~`: порівняння в поєднанні з регулярним виразом і ACL
- `!`: заперечення
- `&&`: і логіка
- `||`: або логіка

#### Varnish об'єкти

- **req**: об'єкт запиту. Створює `req`, коли Varnish отримує запит. Більшість роботи в підпрограмі `vcl_recv` стосується цього об'єкта.
- **bereq**: Об’єкт запиту призначено для веб-сервера. Varnish створює цей об’єкт із `req`.
- **beresp**: об'єкт відповіді веб-сервера. Він містить заголовки об’єктів із програми. Ви можете змінити відповідь сервера в підпрограмі `vcl_backend_response`.
- **resp**: відповідь HTTP, надіслана клієнту. Змініть цей об’єкт за допомогою підпрограми `vcl_deliver`.
- **obj**: кешований об’єкт. Тільки для читання.

#### Varnish дії

Найчастіші дії:

- **pass**: Запит і подальша відповідь надійдуть із сервера додатків після повернення. Застосування кешу не відбувається. `pass` повертає з підпрограми `vcl_recv`.
- **hash**: Після повернення з `vcl_recv` Varnish обслуговуватиме вміст із кешу, навіть якщо конфігурація запиту вказує передачу без кешу.
- **pipe**: Використовується для керування потоками. У цьому випадку Varnish більше не перевірятиме кожен запит, але пропускатиме всі байти на сервер. Веб-сокети або керування відеопотоком, наприклад, використовують `pipe`.
- **deliver**: Доставляє об'єкт клієнту. Зазвичай із підпрограми `vcl_backend_response`.
- **restart**: Перезапускає процес обробки запиту. Зберігає зміни в об’єкті `req`.
- **retry**: Передає запит назад на сервер додатків. Використовується з `vcl_backend_response` або `vcl_backend_error`, якщо відповідь програми є незадовільною.

У підсумку, на діаграмі нижче показано можливі взаємодії між підпрограмами та діями:

![Transparent implementation for the customer](img/varnish_interactions.png)

### Перевірка/тестування/усунення несправностей

Перевірити, що сторінка походить із кешу varnish, можна за допомогою заголовків відповіді HTTP:

![Simplified varnish operation](img/varnish_troobleshooting.png)

### Бекенди

Varnish використовує термін «backend» для віртуальних хостів, які йому потрібні для проксі.

Ви можете визначити кілька серверних модулів на одному сервері Varnish.

Налаштування серверних модулів здійснюється через `/etc/varnish/default.vcl`.

#### Керування ACL

```bash
# Deny ACL
acl deny {
"10.10.0.10"/32;
"192.168.1.0"/24;
}
```

Застосувати ACL:

```bash
# Block ACL deny IPs
if (client.ip ~ forbidden) {
  error 403 "Access forbidden";
}
```

Не кешувати певні сторінки:

```bash
# Do not cache login and admin pages
if (req.url ~ "/(login|admin)") {
  return (pass);
}
```

#### Налаштування POST і файлів cookie

Varnish ніколи не кешує запити HTTP POST або запити, що містять файли cookie (від клієнта чи серверної частини).

Якщо серверна частина використовує файли cookie, кешування вмісту не відбуватиметься.

Щоб виправити цю поведінку, ви можете скасувати файли cookie у своїх запитах:

```bash
sub vcl_recv {
    unset req.http.cookie;
}

sub vcl_backend_response {
    unset beresp.http.set-cookie;
}
```

#### Розповсюдження запитів на різні бекенди

Якщо розміщено кілька сайтів, наприклад сервер документів (<docs.rockylinux.org>) і вікі (<wiki.rockylinux.org>), можна розподіляти запити на правильну серверну частину.

Оголошення бекендів:

```bash
backend docs {
    .host = "127.0.0.1";
    .port = "8080";
}

backend blog {
    .host = "127.0.0.1";
    .port = "8081";
}
```

Модифікація об’єкта `req.backend` відбувається відповідно до хоста, викликаного в HTTP-запиті в підпрограмі `vcl_recv`:

```bash
sub vcl_recv {
    if (req.http.host ~ "^doc.rockylinux.org$") {
        set req.backend = docs;
    }

    if (req.http.host ~ "^wiki.rockylinux.org$") {
        set req.backend = wiki;
    }
}
```

#### Розподіл навантаження

Varnish може обробляти балансування навантаження за допомогою певних серверних модулів, які називаються directors.

Director циклічного керування розповсюджує запити до систем циклічного керування (по черзі). Ви можете призначити вагу кожному серверу.

Director клієнта розподіляє запити відповідно до липкої спорідненості сеансу на будь-якому елементі заголовка (тобто за допомогою файлу cookie сеансу). У цьому випадку клієнт завжди повертається до того самого сервера.

Оголошення бекендів

```bash
backend docs1 {
    .host = "192.168.1.10";
    .port = "8080";
}

backend docs2 {
    .host = "192.168.1.11";
    .port = "8080";
}
```

`director` дозволяє пов’язати 2 визначені серверні модулі.

Director - оголошення:

```bash
director docs_director round-robin {
    { .backend = docs1; }
    { .backend = docs2; }
}
```

Все, що залишилося, це визначити director як бекенд для запитів:

```bash
sub vcl_recv {
    set req.backend = docs_director;
}
```

#### Керування бекендами за допомогою CLI

Позначення серверів як **хворих** або **справних** можна з метою адміністрування чи обслуговування. Ця дія дозволяє видалити вузол із пулу, не змінюючи конфігурацію сервера Varnish (без його перезапуску) або зупиняючи серверну службу.

Переглянути статус бекенда: команда `backend.list` відображає всі бекенди, навіть ті без перевірки працездатності (зонду).

```bash
$ varnishadm backend.list
Backend name                   Admin      Probe
site.default                   probe      Healthy (no probe)
site.front01                   probe      Healthy 5/5
site.front02                   probe      Healthy 5/5
```

Щоб перейти з одного стану в інший:

```bash
varnishadm backend.set_health site.front01 sick

varnishadm backend.list
Backend name                   Admin      Probe
site.default                   probe      Healthy (no probe)
site.front01                   sick       Sick 0/5
site.front02                   probe      Healthy 5/5

varnishadm backend.set_health site.front01 healthy

varnishadm backend.list
Backend name                   Admin      Probe
site.default                   probe      Healthy (no probe)
site.front01                   probe      Healthy 5/5
site.front02                   probe      Healthy 5/5
```

Щоб дозволити Varnish вирішувати стан своїх серверних модулів, необхідно вручну перемкнути серверні модулі на хворі чи працездатні та повернутися до автоматичного режиму.

```bash
varnishadm backend.set_health site.front01 auto
```

Оголошення серверних модулів виконується наступним чином: <https://github.com/mattiasgeniar/varnish-6.0-configuration-templates>.

### Журнали Apache

Оскільки HTTP-служба має зворотний проксі-сервер, веб-сервер більше не матиме доступу до IP-адреси клієнта, а лише до служби Varnish.

Щоб врахувати зворотний проксі в журналах Apache, змініть формат журналу подій у файлі конфігурації сервера:

```bash
LogFormat "%{X-Forwarded-For}i %l %u %t "%r" %>s %b "%{Referer}i" "%{User-Agent}i"" varnishcombined
```

і врахуйте цей новий формат у веб-сайті vhost:

```bash
CustomLog /var/log/httpd/www-access.log.formatux.fr varnishcombined
```

і зробити його сумісним з Varnish:

```bash
if (req.restarts == 0) {
  if (req.http.x-forwarded-for) {
    set req.http.X-Forwarded-For = req.http.X-Forwarded-For + ", " + client.ip;
  } else {
   set req.http.X-Forwarded-For = client.ip;
  }
}
```

### Очищення кешу

Кілька запитів на очищення кешу:

в командному рядку:

```bash
varnishadm 'ban req.url ~ .'
```

використовуючи секрет і порт, відмінний від типового:

```bash
varnishadm -S /etc/varnish/secret -T 127.0.0.1:6082 'ban req.url ~ .'
```

на CLI:

```bash
varnishadm

varnish> ban req.url ~ ".css$"
200

varnish> ban req.http.host == example.com
200

varnish> ban req.http.host ~ .
200
```

через запит HTTP PURGE:

```bash
curl -X PURGE http://example.org/foo.txt
```

Налаштування Varnish для прийняття цього запиту виконується за допомогою:

```bash
acl local {
    "localhost";
    "10.10.1.50";
}

sub vcl_recv {
    # directive to be placed first,
    # otherwise another directive may match first
    # and the purge will never be performed
    if (req.method == "PURGE") {
        if (client.ip ~ local) {
            return(purge);
        }
    }
}
```

### Керування журналами

Varnish записує свої журнали в пам’ять і двійковий файл, щоб не погіршувати продуктивність. Коли пам’ять закінчується, він переписує нові записи поверх старих, починаючи з початку пам’яті.

Можна переглянути журнали за допомогою інструментів `varnishstat` (статистика), `varnishtop` (зверху для Varnish), `varnishlog` (докладне ведення журналів) або `varnishnsca` (журнали у форматі NCSA, наприклад Apache):

```bash
varnishstat
varnishtop -i ReqURL
varnishlog
varnishnsca
```

Використання параметра `-q` для застосування фільтрів до журналів здійснюється за допомогою:

```bash
varnishlog -q 'TxHeader eq MISS' -q "ReqHeader ~ '^Host: rockylinux\.org$'"
varnishncsa -q "ReqHeader eq 'X-Cache: MISS'"
```

Демони `varnishlog` і `varnishnsca` записують журнали на диск незалежно від демона `varnishd`. Демон `varnishd` продовжує заповнювати свої журнали в пам'яті, не погіршуючи продуктивність клієнтів; потім інші демони копіюють журнали на диск.

### Практичне завдання

Для цього практичного завдання вам знадобиться один сервер із встановленими, налаштованими та захищеними службами Apache, як описано в попередніх розділах.

Ви налаштуєте зворотний кеш-проксі перед ним.

Ваш сервер має такі IP-адреси:

- server1: 192.168.1.10

Якщо у вас немає служби для визначення імен, заповніть файл `/etc/hosts` таким вмістом:

```bash
$ cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

192.168.1.10 server1 server1.rockylinux.lan
```

#### Завдання 1: встановлення та налаштування Apache

```bash
sudo dnf install -y httpd mod_ssl
sudo systemctl enable httpd  --now
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
echo "<html><body>Node $(hostname -f)</body></html>" | sudo tee "/var/www/html/index.html"
```

Підтвердити:

```bash
$ curl http://server1.rockylinux.lan
<html><body>Node server1.rockylinux.lan</body></html>

$ curl -I http://server1.rockylinux.lan
HTTP/1.1 200 OK
Date: Mon, 12 Aug 2024 13:16:18 GMT
Server: Apache/2.4.57 (Rocky Linux) OpenSSL/3.0.7
Last-Modified: Mon, 12 Aug 2024 13:11:54 GMT
ETag: "36-61f7c3ca9f29c"
Accept-Ranges: bytes
Content-Length: 54
Content-Type: text/html; charset=UTF-8
```

#### Завдання 2: Встановлення varnish

```bash
sudo dnf install -y varnish
sudo systemctl enable varnishd --now
sudo firewall-cmd --permanent --add-port=6081/tcp --permanent
sudo firewall-cmd --reload
```

#### Завдання 3: Налаштувати Apache як серверну частину

Змініть `/etc/varnish/default.vcl`, щоб використовувати apache (порт 80) як серверну частину:

```bash
# Default backend definition. Set this to point to your content server.
backend default {
    .host = "127.0.0.1";
    .port = "80";
}
```

Перезавантажте Varnish

```bash
sudo systemctl reload varnish
```

Перевірте, чи працює varnish:

```bash
$ curl -I http://server1.rockylinux.lan:6081
HTTP/1.1 200 OK
Server: Apache/2.4.57 (Rocky Linux) OpenSSL/3.0.7
X-Varnish: 32770 6
Age: 8
Via: 1.1 varnish (Varnish/6.6)

$ curl http://server1.rockylinux.lan:6081
<html><body>Node server1.rockylinux.lan</body></html>
```

Як бачите, Apache обслуговує сторінку індексу.

Було додано деякі заголовки, які дають нам інформацію про те, що наш запит було оброблено varnish (заголовок `Via`) і кешований час сторінки (заголовок `Age`), який говорить нам, що наша сторінка була надана безпосередньо з пам'яті varnish з диска з Apache.

#### Завдання 4: Видаліть деякі заголовки

Ми видалимо деякі заголовки, які можуть надати хакерам непотрібну інформацію.

У підрозділі `vcl_deliver` додайте наступне:

```bash
sub vcl_deliver {
    unset resp.http.Server;
    unset resp.http.X-Varnish;
    unset resp.http.Via;
    set resp.http.node = "F01";
    set resp.http.X-Cache-Hits = obj.hits;
    if (obj.hits > 0) { # Add debug header to see if it is a HIT/MISS and the number of hits, disable when not needed
      set resp.http.X-Cache = "HIT";
    } else {
      set resp.http.X-Cache = "MISS";
    }
}
```

Перевірте свою конфігурацію та перезавантажте varnish:

```bash
$ sudo varnishd -C -f /etc/varnish/default.vcl
...
$ sudo systemctl reload varnish
```

Перевірте відмінності:

```bash
$ curl -I http://server1.rockylinux.lan:6081
HTTP/1.1 200 OK
Age: 4
node: F01
X-Cache-Hits: 1
X-Cache: HIT
Accept-Ranges: bytes
Connection: keep-alive
```

Як бачимо, видалення непотрібних заголовків відбувається при додаванні необхідних (для усунення неполадок).

### Висновок

Тепер у вас є всі знання, необхідні для налаштування основного сервера кешу та додавання функцій.

Наявність сервера varnish у вашій інфраструктурі може бути дуже корисним для багатьох речей, окрім кешування: для безпеки серверного сервера, для обробки заголовків, для полегшення оновлень (наприклад, синій/зелений режим або режим жовтий) тощо.

### Перевірте свої знання

:heavy_check_mark: Чи може Varnish розміщувати статичні файли?

- [ ] Так
- [ ] Ні

:heavy_check_mark: Чи потрібно зберігати кеш-пам’ять varnish у пам’яті?

- [ ] Так
- [ ] Ні
