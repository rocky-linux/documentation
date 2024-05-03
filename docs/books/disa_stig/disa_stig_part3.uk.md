---
title: Веб-сервер DISA Apache STIG
author: Scott Shinn
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.6
tags:
  - DISA
  - STIG
  - безпека
  - enterprise
---

# Вступ

У частині 1 цієї серії ми розглянули, як створити наш веб-сервер із застосуванням базового RHEL8 DISA STIG, а в частині 2 ми дізналися, як перевірити відповідність STIG за допомогою інструменту OpenSCAP. Тепер ми збираємося зробити щось із системою, створити просту веб-програму та застосувати веб-сервер DISA STIG: <https://www.stigviewer.com/stig/web_server/>

Спочатку давайте порівняємо, у що ми тут втягуємося, RHEL 8 DISA STIG призначений для дуже специфічної платформи, тому елементи керування досить легко зрозуміти в цьому контексті, протестувати та застосувати.  Додатки STIG мають бути переносними на кілька платформ, тому вміст тут є загальним, щоб працювати з різними дистрибутивами Linux (RHEL, Ubuntu, SuSE тощо)**. Це означає, що такі інструменти, як OpenSCAP, не допоможуть нам перевірити/виправити конфігурацію, нам доведеться робити це вручну. Ці STIG наступні:

* Apache 2.4 V2R5 - сервер; що стосується самого веб-сервера
* Apache 2.4 V2R5 - сайт; що стосується веб-програми/веб-сайту

Для нашого посібника ми створимо простий веб-сервер, який лише обслуговує статичний вміст. Ми можемо використати зміни, які ми вносимо тут, щоб створити базове зображення, а потім використати це базове зображення, коли пізніше створюватимемо більш складні веб-сервери.

## Apache 2.4 V2R5 Server Quickstart

Перш ніж почати, вам потрібно повернутися до частини 1 і застосувати профіль безпеки DISA STIG. Вважайте це як крок 0.

1.) Встановіть `apache` та `mod_ssl`

```bash
dnf install httpd mod_ssl
```

2.) Зміни конфігурації

```bash
sed -i 's/^\([^#].*\)**/# \1/g' /etc/httpd/conf.d/welcome.conf
dnf -y remove httpd-manual
dnf -y install mod_session

echo “MaxKeepAliveRequests 100” > /etc/httpd/conf.d/disa-apache-stig.conf
echo “SessionCookieName session path=/; HttpOnly; Secure;” >>  /etc/httpd/conf.d/disa-apache-stig.conf
echo “Session On” >>  /etc/httpd/conf.d/disa-apache-stig.conf
echo “SessionMaxAge 600” >>  /etc/httpd/conf.d/disa-apache-stig.conf
echo “SessionCryptoCipher aes256” >>  /etc/httpd/conf.d/disa-apache-stig.conf
echo “Timeout 10” >>  /etc/httpd/conf.d/disa-apache-stig.conf
echo “TraceEnable Off” >>  /etc/httpd/conf.d/disa-apache-stig.conf
echo “RequestReadTimeout 120” >> /etc/httpd/conf.d/disa-apache-stig.conf

sed -i “s/^#LoadModule usertrack_module/LoadModule usertrack_module/g” /etc/httpd/conf.modules.d/00-optional.conf
sed -i "s/proxy_module/#proxy_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_ajp_module/#proxy_ajp_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_balancer_module/#proxy_balancer_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_ftp_module/#proxy_ftp_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_http_module/#proxy_http_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_connect_module/#proxy_connect_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
```

  3.) Оновіть політику брандмауера та запустіть `httpd`

```bash
firewall-cmd --zone=public --add-service=https --permanent
firewall-cmd --zone=public --add-service=https
firewall-cmd --reload
systemctl enable httpd
systemctl start httpd
```

## Детальний огляд елементів керування

Якщо ви зайшли так далеко, то, ймовірно, вам буде цікаво дізнатися більше про те, чого хоче від нас STIG. Це допомагає зрозуміти важливість елемента керування, а потім, як він застосовується до програми. Іноді елемент керування є технічним (змініть налаштування X на Y), а іноді – операційним (як ви його використовуєте).  Взагалі кажучи, технічний контроль — це те, що можна змінити за допомогою коду, а оперативний контроль, ймовірно, ні.

### Рівні

* Cat I - (HIGH) - 5 Controls
* Cat II - (MEDIUM) - 41 Controls
* Cat III - (LOW) - 1 Controls

### Типи

* Technical - 24  controls
* Operational  - 23 controls

У цій статті ми не будемо розглядати «чому» ці зміни, а лише те, що має статися, якщо це технічний контроль.  Якщо ми нічого не можемо змінити, як у випадку з оперативним контролем, поле **Fix:** буде відсутнім. Хороша новина в багатьох із цих випадків, це вже за замовчуванням у Rocky Linux 8, тому вам взагалі нічого не потрібно змінювати.

## Apache 2.4 V2R5 – Інформація про сервер

**(V-214248)** Каталоги програм веб-сервера Apache, бібліотеки та файли конфігурації мають бути доступні лише для привілейованих користувачів.

**Severity:** Cat I High  
**Type:** Операційний  
**Fix:** немає, перевірте, щоб лише привілейовані користувачі мали доступ до файлів веб-сервера

**(V-214242)** Веб-сервер Apache має надавати параметри встановлення, щоб виключити встановлення документації, зразків коду, прикладів програм і навчальних посібників.

**Severity:** Cat I High  
**Type:** Technical  
**Fix:**

```bash
sed -i 's/^\([^#].*\)/# \1/g' /etc/httpd/conf.d/welcome.conf
```

**(V-214253)** Веб-сервер Apache має генерувати ідентифікатор сеансу, використовуючи якомога більше набору символів, щоб зменшити ризик застосування грубої сили.

**Severity:** Cat I High  
**Type:** технічний  
**Fix:** немає, виправлено за умовчанням у Rocky Linux 8

**(V-214273)** Версія програмного забезпечення веб-сервера Apache має підтримуватися постачальником.

**Severity:** Cat I High  
**Type:** Technical  
**Fix:** Немає, виправлено за замовчуванням у Rocky Linux 8

**(V-214271)** Обліковий запис, який використовується для запуску веб-сервера Apache, не повинен мати дійсну оболонку входу та визначений пароль.

**Severity:** Cat I High  
**Type:** Technical  
**Fix:** Немає, виправлено за замовчуванням у Rocky Linux 8

**(V-214245)** На веб-сервері Apache має бути вимкнено Web Distributed Authoring (WebDAV). **Severity:** Cat II Medium **Type:** Technical **Fix:**

```bash
sed -i 's/^\([^#].*\)/# \1/g' /etc/httpd/conf.d/welcome.conf
```

**(V-214264)** Веб-сервер Apache має бути налаштований для інтеграції з інфраструктурою безпеки організації.

**Severity:** Cat II Medium **Type:** Operational **Fix:** Немає, пересилати журнали веб-сервера до SIEM

**(V-214243)** Веб-сервер Apache має мати налаштовані зіставлення ресурсів, щоб вимкнути обслуговування певних типів файлів.

**Severity:** Cat II Medium **Type:** Technical **Fix:** немає, виправлено за умовчанням у Rocky Linux 8

**(V-214240)** Веб-сервер Apache має містити лише служби та функції, необхідні для роботи.

**Severity:** Cat II Medium **Type:** Technical **Fix:**

```bash
dnf remove httpd-manual
```

**(V-214238)** Модулі розширення мають бути повністю перевірені, протестовані та підписані, перш ніж вони зможуть існувати на робочому веб-сервері Apache.

**Severity:** Cat II Medium **Type:** Operational **Fix:** Жодного, вимкнути всі непотрібні для програми модулі

**(V-214268)** Файли cookie, якими обмінюються веб-сервер Apache і клієнт, наприклад файли cookie сеансу, повинні мати властивості файлів cookie, налаштовані на заборону клієнтським сценаріям читати файли cookie даних.

**Severity:** Cat II Medium **Type:** Technical **Fix:**

```bash
dnf install mod_session
echo “SessionCookieName session path=/; HttpOnly; Secure;” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214269)** Веб-сервер Apache має видалити всі шифри експорту, щоб захистити конфіденційність і цілісність переданої інформації.

**Severity:** Cat II Medium **Type:** Technical **Fix:** Немає, виправлено за замовчуванням у профілі безпеки Rocky Linux 8 DISA STIG

**(V-214260)** Веб-сервер Apache має бути налаштований на миттєве відключення або вимкнення віддаленого доступу до розміщених програм.

**Severity:** Cat II Medium **Type:** Operational **Fix:** Ні, це процедура зупинки веб-сервера

**(V-214249)** Веб-сервер Apache має відокремити розміщені програми від функцій керування веб-сервером Apache.

**Severity:** Cat II Medium **Type:** Operational **Fix:** Жодного, це стосується веб-програм, а не сервера

**(V-214246)** Веб-сервер Apache має бути налаштований на використання вказаної IP-адреси та порту.

**Severity:** Cat II Medium **Type:** Operational **Fix:** Немає, веб-сервер має бути налаштований на прослуховування лише певної IP-адреси/порту

**(V-214247)** Облікові записи веб-сервера Apache, які мають доступ до дерева каталогів, оболонки чи інших функцій і утиліт операційної системи, мають бути лише адміністративними обліковими записами.

**Severity:** Cat II Medium **Type:** Operational **Fix:** Нічого, усі файли та каталоги, які обслуговує веб-сервер, мають належати адміністраторам, а не користувачу веб-сервера.

**(V-214244)** Веб-сервер Apache має дозволяти видаляти зіставлення з невикористаними та вразливими сценаріями.

**Severity:** Cat II Medium **Type:** Operational **Fix:** Жодного, будь-які зіставлення cgi-bin або інші зіставлення Script/ScriptAlias, які не використовуються, потрібно видалити

**(V-214263)** Веб-сервер Apache не повинен перешкоджати запису вказаного вмісту запису журналу на сервер журналу аудиту.

**Severity:** Cat II Medium **Type:** Operational **Fix:** Ні, співпрацюйте з адміністратором SIEM, щоб надати можливість записувати вказаний вміст запису журналу на сервер журналу аудиту.

**(V-214228)** Веб-сервер Apache має обмежити кількість дозволених одночасних запитів на сеанс.

**Severity:** Cat II Medium **Type:** Technical **Fix:**

```bash
echo “MaxKeepAliveRequests 100” > /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214229)** Веб-сервер Apache має керувати сеансом на стороні сервера.

**Severity:** Cat II Medium **Type:** Technical **Fix:**

```bash
sed -i “s/^#LoadModule usertrack_module/LoadModule usertrack_module/g” /etc/httpd/conf.modules.d/00-optional.conf
```

**(V-214266)** Веб-сервер Apache повинен забороняти або обмежувати використання незахищених або непотрібних портів, протоколів, модулів і/або служб.

**Severity:** Cat II Medium **Type:** Operational **Fix:** Ні, переконайтеся, що на веб-сайті використовуються добре відомі порти IANA для HTTP та HTTPS.

**(V-214241)** Веб-сервер Apache не має бути проксі-сервером.

**Severity:** Cat II Medium **Type:** Technical **Fix:**

```bash
sed -i "s/proxy_module/#proxy_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_ajp_module/#proxy_ajp_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_balancer_module/#proxy_balancer_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_ftp_module/#proxy_ftp_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_http_module/#proxy_http_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_connect_module/#proxy_connect_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
```

**(V-214265)** Веб-сервер Apache має генерувати записи журналу, які можна зіставляти з універсальним координованим часом (UTC)** або середнім часом за Гринвічем (GMT), які мають відмітку з мінімальною ступінчастістю в одну секунду.

**Severity:** Cat II Medium **Type:** Technical **Fix:** Немає, виправлено за замовчуванням у Rocky Linux 8

**(V-214256)** Попередження та повідомлення про помилки, які відображаються клієнтам, необхідно змінити, щоб мінімізувати ідентифікацію веб-сервера Apache, виправлень, завантажених модулів і шляхів до каталогу.

**Severity:** Cat II Medium **Type:** Operational **Fix:** Використовуйте директиву "ErrorDocument", щоб увімкнути спеціальні сторінки помилок для кодів статусу HTTP 4xx або 5xx.

**(V-214237)** Для даних журналу та записів із веб-сервера Apache необхідно створити резервну копію на іншій системі чи носії.

**Severity:** Cat II Medium **Type:** Operational **Fix:** Ні, задокументуйте процедури резервного копіювання веб-сервера

**(V-214236)** Інформація журналу з веб-сервера Apache повинна бути захищена від несанкціонованої зміни або видалення.

**Severity:** Cat II Medium **Type:** Operational **Fix:** Ні, задокументуйте процедури резервного копіювання веб-сервера

**(V-214261)** Непривілейовані облікові записи в системі хостингу мають мати доступ лише до інформації, що стосується безпеки веб-сервера Apache, і працювати через окремий обліковий запис адміністратора. **Severity:** Cat II Medium **Type:** Operational **Fix:** Немає, обмежити доступ до інструменту веб-адміністрування лише для системного адміністратора, веб-менеджера або призначених веб-менеджером осіб.

**(V-214235)** Файли журналу веб-сервера Apache мають бути доступні лише для привілейованих користувачів.

**Severity:** Cat II Medium **Type:** Operational **Fix:** Немає. Щоб захистити цілісність даних, які зберігаються у файлах журналу, переконайтеся, що дозволи на читання файлів журналу мають лише члени групи аудиторів, адміністратори та користувач, призначений для запуску програмного забезпечення веб-сервера.

**(V-214234)** Веб-сервер Apache має використовувати механізм журналювання, налаштований на сповіщення спеціаліста з безпеки інформаційної системи (ISSO) і системного адміністратора (SA) у випадку збій обробки.

**Severity:** Cat II Medium **Type:** Operational **Fix:** Ні, працюйте з адміністратором SIEM, щоб налаштувати сповіщення, коли дані аудиту не надходять від Apache на основі визначеного розкладу підключень.

**(V-214233)** Веб-сервер Apache за балансувальником навантаження або проксі-сервером має створювати записи журналу, що містять інформацію про IP-адресу клієнта як джерела та призначення, а не завантаження інформацію про IP балансера або проксі з кожною подією.

**Severity:** Cat II Medium **Type:** Operational **Fix:** Ні, отримати доступ до проксі-сервера, через який передається вхідний веб-трафік, і налаштувати параметри для прозорої передачі веб-трафіку на веб-сервер Apache.

Зверніться до <https://httpd.apache.org/docs/2.4/mod/mod_remoteip.html>, щоб отримати додаткову інформацію про параметри журналювання на основі налаштувань проксі/навантаження.

**(V-214231)** На веб-сервері Apache має бути ввімкнено системне журналювання.

**Severity:** Cat II Medium **Type:** Technical **Fix:** Немає, виправлено за замовчуванням у Rocky Linux 8

**(V-214232)** Веб-сервер Apache має створювати принаймні записи журналу для запуску та завершення роботи системи, доступу до системи та подій автентифікації системи.

**Severity:** Cat II Medium **Type:** Technical **Fix:** Немає, виправлено за замовчуванням у Rocky Linux 8

V-214251 Файли cookie, якими обмінюються веб-сервер Apache і клієнт, наприклад файли cookie сеансу, повинні мати параметри безпеки, які забороняють доступ до файлів cookie за межами вихідного веб-сервера Apache і розміщеної програми.

**Severity:** Cat II Medium **Type:** Technical **Fix:**

```bash
echo “Session On” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214250)** Веб-сервер Apache має робити ідентифікатори сеансу недійсними після виходу користувача розміщеної програми або іншого завершення сеансу.

**Severity:** Cat II Medium **Type:** Technical **Fix:**

```bash
echo “SessionMaxAge 600” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214252)** Веб-сервер Apache має генерувати ідентифікатор сеансу достатньо довгий, щоб його неможливо було вгадати за допомогою грубої сили.

**Severity:** Cat II Medium **Type:** Technical **Fix:**

```bash
echo “SessionCryptoCipher aes256” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214255)** Веб-сервер Apache має бути налаштований відповідно до робочих вимог розміщеної програми.

**Severity:** Cat II Medium **Type:** Technical **Fix:**

```bash
echo “Timeout 10” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214254)** Веб-сервер Apache має бути створений таким чином, щоб перевести його у відомий безпечний стан, якщо не вдається ініціалізувати систему, завершити роботу чи завершити роботу.

**Severity:** Cat II Medium **Type:** Operational **Fix:** Ні, підготуйте документацію щодо методів аварійного відновлення для веб-сервера Apache 2.4 у разі необхідності відкату.

**(V-214257)** Інформація про налагодження та трасування, яка використовується для діагностики веб-сервера Apache, має бути вимкнена.

**Severity:** Cat II Medium **Type:** Technical **Fix:**

```bash
echo “TraceEnable Off” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214230)** Веб-сервер Apache має використовувати криптографію для захисту цілісності віддалених сеансів.

**Severity:** Cat II Medium **Type:** Technical **Fix:**

```bash
sed -i "s/^#SSLProtocol.*/SSLProtocol -ALL +TLSv1.2/g" /etc/httpd/conf.d/ssl.conf
```

**(V-214258)** Веб-сервер Apache має встановити час очікування неактивності для сеансів.

**Severity:** Cat II Medium **Type:** Technical **Fix:**

```bash
echo “RequestReadTimeout 120” >> /etc/httpd/conf.d/disa-stig-apache.conf
```

**(V-214270)** Веб-сервер Apache має інсталювати оновлення програмного забезпечення, пов’язані з безпекою, протягом налаштованого періоду часу, указаного авторитетним джерелом (наприклад, IAVM, CTO, DTM та STIG).

**Severity:** Cat II Medium **Type:** Operational **Fix:** Ні, інсталюйте поточну версію програмного забезпечення веб-сервера та підтримуйте відповідні пакети оновлень і виправлень.

**(V-214239)** Веб-сервер Apache не повинен виконувати керування користувачами для розміщених програм.

**Severity:** Cat II Medium **Type:** Technical **Fix:**  Немає, виправлено за замовчуванням у Rocky Linux 8

**(V-214274)** Файли htpasswd веб-сервера Apache (за наявності) мають відображати належне право власності та дозволи.

**Severity:** Cat II Medium **Type:** Operational **Fix:** Ні, переконайтеся, що обліковий запис SA або Web Manager володіє файлом "htpasswd".  Переконайтеся, що для дозволів встановлено значення «550».

**(V-214259)** Веб-сервер Apache має обмежувати вхідні з’єднання з незахищених зон.

**Severity:** Cat II Medium **Type:** Operational **Fix:** Ні, налаштуйте файл "http.conf", щоб включити обмеження. Приклад:

```bash
Require not ip 192.168.205
Require not host phishers.example.com
```

**(V-214267)** Веб-сервер Apache має бути захищений від зупинки непривілейованим користувачем.

**Severity:** Cat II Medium **Type:** Technical **Fix:** Немає, виправлено Rocky Linux 8 за замовчуванням

**(V-214262)** Веб-сервер Apache повинен використовувати механізм журналювання, налаштований на виділення достатньо великої ємності для зберігання записів журналу, щоб задовольнити вимоги веб-сервера Apache до журналювання.

**Severity:** Cat II Medium **Type:** Operational **Fix:** немає, попрацюйте з адміністратором SIEM, щоб визначити, чи налаштовано SIEM на виділення достатньо великої ємності для зберігання записів журналу, щоб відповідати вимогам веб-сервера Apache до журналювання.

**(V-214272)** Веб-сервер Apache має бути налаштований відповідно до параметрів конфігурації безпеки на основі конфігурації безпеки Міністерства оборони або вказівок із впровадження, включаючи STIG, посібники з конфігурації NSA, CTO та DTM.

**Severity:** Cat III Low **Type:** Operational **Fix:**  None

## Про автора

Скотт Шінн є технічним директором Atomicorp і є частиною команди Rocky Linux Security. Він працював із федеральними інформаційними системами Білого дому, Міністерства оборони та розвідувального співтовариства з 1995 року. Частиною цього було створення STIG і вимога th Ви використовуєте їх, і я дуже шкодую про це.
