---
title: Генерація ключів SSL - Let's Encrypt
author: Steven Spencer
contributors: wsoyinka, Antoine Le Morvan, Ezequiel Bruni, Andrew Thiesen, Ganna Zhyrnova
tested*with: 8.5
tags:
  - безпека
  - ssl
  - certbot
---

# Генерація ключів SSL - Let's Encrypt

## Передумови та припущення

- Володіння командним рядком
- Знайомство із захистом веб-сайтів за допомогою сертифікатів SSL є перевагою
- Знання текстових редакторів командного рядка (у цьому прикладі використовується *vi*)
- Веб-сервер, відкритий для світу та працює на порту 80 (http)
- Знайомство з *ssh* (захищена оболонка) і можливість доступу до вашого сервера за допомогою *ssh*
- Усі команди припускають, що ви або користувач root, або використовували *sudo* для отримання доступу root.

## Вступ

Одним із найпопулярніших способів захисту веб-сайту на даний момент є використання сертифікатів Let's Encrypt SSL, які також безкоштовні.

Це справжні сертифікати, а не самопідписані чи зміїні масла тощо, тому вони чудово підходять для малобюджетного рішення безпеки. Цей документ допоможе вам встановити та використовувати сертифікати Let's Encrypt на веб-сервері Rocky Linux.

## Встановлення

Щоб виконати наступні кроки, скористайтеся *ssh* для входу на свій сервер. Якщо повне DNS-ім’я вашого сервера було www.myhost.com, ви б використовували:

```bash
ssh -l root www.myhost.com
```

Або якщо ви спочатку маєте отримати доступ до свого сервера як непривілейований користувач. Використовуйте своє ім'я користувача:

```bash
ssh -l username www.myhost.com
```

І потім:

```bash
sudo -s
```

У цьому випадку вам знадобляться облікові дані вашого користувача *sudo*, щоб отримати доступ до системи як root.

Let's Encrypt використовує пакет під назвою *certbot*, який потрібно встановити через репозиторії EPEL. Додайте їх першими:

```bash
dnf install epel-release
```

Потім встановіть відповідні пакети залежно від того, чи використовуєте ви Apache або Nginx як веб-сервер. Для Apache це:

```bash
dnf install certbot python3-certbot-apache
```

Для Nginx просто змініть один пакет:

```bash
dnf install certbot python3-certbot-nginx
```

За потреби ви завжди можете встановити обидва серверні модулі.

!!! Note "Примітка"

    Попередня версія цього посібника вимагала версії пакета знімків *certbot*, яка тоді була необхідною. Версії RPM були нещодавно повторно перевірені та зараз працюють. Проте Certbot наполегливо рекомендує використовувати [процедуру швидкого встановлення](https://certbot.eff.org/instructions?ws=apache&os=centosrhel8). Rocky Linux 8 і 9 мають *certbot*, доступний у EPEL, тому ми показуємо цю процедуру тут. Якщо ви бажаєте скористатися процедурою, рекомендованою Certbot, дотримуйтеся цієї процедури.

## Отримання сертифіката Let's Encrypt для сервера Apache

Є два способи отримати ваш сертифікат Let's Encrypt: або за допомогою команди, щоб змінити файл конфігурації HTTP для вас, або отримати сертифікат. Якщо ви використовуєте процедуру багатосайтового налаштування, запропоновану для одного чи кількох сайтів у процедурі [Мультисайтове налаштування веб-сервера Apache](../web/apache-sites-enabled.md), тоді ви захочете лише отримати свій сертифікат.

Ми припускаємо, що ви **використовуєте** цю процедуру, тому ми отримаємо лише сертифікат. Якщо ви використовуєте автономний веб-сервер із конфігурацією за замовчуванням, ви можете отримати сертифікат і змінити файл конфігурації за один крок, використовуючи:

```bash
certbot --apache
```

Це найпростіший спосіб зробити справу. Однак іноді ви хочете застосувати більш ручний підхід і отримати сертифікат. Щоб отримати лише сертифікат, використовуйте цю команду:

```bash
certbot certonly --apache
```

Обидві команди створять набір підказок, на які вам потрібно буде відповісти. По-перше, це вказати електронну адресу для важливої інформації:

```bash
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator apache, Installer apache
Enter email address (used for urgent renewal and security notices)
 (Enter 'c' to cancel): yourusername@youremaildomain.com
```

Далі пропонується прочитати та прийняти умови абонентської угоди. Прочитавши угоду, дайте відповідь «Y», щоб продовжити:

```bash
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please read the Terms of Service at
https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf. You must
agree in order to register with the ACME server. Do you agree?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o:
```

Далі — прохання поділитися вашою електронною поштою з Electronic Frontier Foundation. Дайте відповідь 'Y' або 'N' на свій смак:

```bash
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Would you be willing, once your first certificate is successfully issued, to
share your email address with the Electronic Frontier Foundation, a founding
partner of the Let's Encrypt project and the non-profit organization that
develops Certbot? We'd like to send you email about our work encrypting the web,
EFF news, campaigns, and ways to support digital freedom.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o:
```

У наступному запиті вас запитають, для якого домену ви хочете отримати сертифікат. Він має відображати домен у списку на основі вашого запущеного веб-сервера. Якщо так, введіть номер біля домену, для якого ви отримуєте сертифікат. У цьому випадку є тільки один варіант ('1'):

```bash
Which names would you like to activate HTTPS for?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
1: your-server-hostname
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Select the appropriate numbers separated by commas and/or spaces, or leave input
blank to select all options shown (Enter 'c' to cancel):
```

Якщо все йде добре, ви повинні отримати таке повідомлення:

```bash
Requesting a certificate for your-server-hostname
Performing the following challenges:
http-01 challenge for your-server-hostname
Waiting for verification...
Cleaning up challenges
Subscribe to the EFF mailing list (email: yourusername@youremaildomain.com).

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/your-server-hostname/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/your-server-hostname/privkey.pem
   Your certificate will expire on 2021-07-01. To obtain a new or
   tweaked version of this certificate in the future, simply run
   certbot again. To non-interactively renew *all* of your
   certificates, run "certbot renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le
```

## Конфігурація сайту - https

Застосування файлу конфігурації до нашого сайту дещо відрізняється від того, якби ми використовували придбаний сертифікат SSL від іншого постачальника (і якби ми не дозволили *certbot* зробити це автоматично).

Один файл PEM (Privacy Enhanced Mail) містить сертифікат і файл ланцюжка. Зараз це загальний формат для всіх файлів сертифікатів, тому, хоча в посиланні на нього є «Пошта», це лише тип файлу сертифіката. Щоб проілюструвати файл конфігурації, ми покажемо його повністю, а потім опишемо, що відбувається:

```bash
<VirtualHost *:80>
        ServerName your-server-hostname
        ServerAdmin username@rockylinux.org
        Redirect / https://your-server-hostname/
</VirtualHost>
<Virtual Host *:443>
        ServerName your-server-hostname
        ServerAdmin username@rockylinux.org
        DocumentRoot /var/www/sub-domains/com.yourdomain.www/html
        DirectoryIndex index.php index.htm index.html
        Alias /icons/ /var/www/icons/
        # ScriptAlias /cgi-bin/ /var/www/sub-domains/com.yourdomain.www/cgi-bin/

        CustomLog "/var/log/httpd/com.yourdomain.www-access_log" combined
        ErrorLog  "/var/log/httpd/com.yourdomain.www-error_log"

        SSLEngine on
        SSLProtocol all -SSLv2 -SSLv3 -TLSv1
        SSLHonorCipherOrder on
        SSLCipherSuite EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384
:EECDH+aRSA+SHA256:EECDH+aRSA+RC4:EECDH:EDH+aRSA:RC4:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS

        SSLCertificateFile /etc/letsencrypt/live/your-server-hostname/fullchain.pem
        SSLCertificateKeyFile /etc/letsencrypt/live/your-server-hostname/privkey.pem
        SSLCertificateChainFile /etc/letsencrypt/live/your-server-hostname/fullchain.pem

        <Directory /var/www/sub-domains/com.yourdomain.www/html>
                Options -ExecCGI -Indexes
                AllowOverride None

                Order deny,allow
                Deny from all
                Allow from all

                Satisfy all
        </Directory>
</VirtualHost>
```

Ось що відбувається вище. Ви можете переглянути [Налаштування кількох сайтів веб-сервера Apache](../web/apache-sites-enabled.md), щоб побачити відмінності в застосуванні SSL, придбаного в іншого постачальника і сертифікат Let's Encrypt:

- Незважаючи на те, що порт 80 (стандартний http) прослуховує, ми перенаправляємо весь трафік на порт 443 (https)
- SSLEngine увімкнуто - просто говорить про використання SSL
- SSLProtocol all -SSLv2 -SSLv3 -TLSv1 - говорить про використання всіх доступних протоколів, крім тих, які мають вразливості. Ви повинні періодично досліджувати, які протоколи зараз прийнятні для використання.
- SSLHonorCipherOrder on - це стосується наступного рядка щодо наборів шифрів і повідомляє, що потрібно мати справу з ними в тому порядку, у якому вони вказані. Це ще одна область, де ви повинні переглядати набори шифрів, які ви хочете періодично включати
- SSLCertificateFile – це файл PEM, який містить сертифікат сайту **ТА** проміжний сертифікат. Нам все ще потрібен рядок «SSLCertificateChainFile» у нашій конфігурації, але він просто знову вкаже той самий файл PEM.
- SSLCertificateKeyFile – файл PEM для закритого ключа, згенерований за допомогою запиту *certbot*.
- SSLCertificateChainFile – сертифікат від вашого постачальника сертифікатів, який часто називають проміжним сертифікатом, у цьому випадку точно так само, як розташування «SSLCertificateFile» вище.

Коли ви внесете всі зміни, просто перезапустіть *httpd* і, якщо він почнеться, протестуйте свій сайт, щоб переконатися, що тепер у вас відображається дійсний файл сертифіката. Якщо так, ви готові переходити до наступного кроку: автоматизації.

## Використання *certbot* із Nginx

Коротка примітка: використання *certbot* з Nginx майже таке ж, як і з Apache. Ось коротка, коротка версія посібника:

Виконайте цю команду, щоб почати:

```bash
certbot --nginx
```

Ви повинні ввести адресу електронної пошти та сайт, для якого ви хочете отримати сертифікат. Якщо припустити, що у вас налаштовано принаймні один сайт (з доменним іменем, що вказує на сервер), ви побачите такий список:

```bash
1. yourwebsite.com
2. subdomain.yourwebsite.com
```

Якщо у вас кілька сайтів, натисніть номер, що відповідає сайту, для якого ви хочете отримати сертифікат.

Решта тексту схожа на наведену вище. Результати будуть трохи іншими. Якщо у вас є файл конфігурації Nginx, який виглядає так:

```bash
server {
    server_name yourwebsite.com;

    listen 80;
    listen [::]:80;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
}

```

Коли *certbot* впорається з цим, це виглядатиме приблизно так:

```bash
server {
    server*name  yourwebsite.com;

    listen 443 ssl; # managed by Certbot
    listen [::]:443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/yourwebsite.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/yourwebsite.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
}

server {
    if ($host = yourwebsite.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


  listen 80;
  listen [::]:80;
  server_name yourwebsite.com;
    return 404; # managed by Certbot
}
```

Залежно від кількох речей (наприклад, якщо ви використовуєте Nginx як зворотний проксі), вам може знадобитися заглибитися в новий конфігураційний файл, щоб виправити деякі речі, які *certbot * не впорається ідеально сам по собі.

Або напишіть власний файл конфігурації важким способом.

## Автоматизація поновлення сертифіката Let's Encrypt

!!! note "Примітка"

    Замініть випадки на «ім’я хоста-вашого-сервера» в цих прикладах на фактичне ім’я домену або ім’я хосту.

Принадність встановлення *certbot* полягає в тому, що сертифікат Let's Encrypt автоматично поновлюється. Для цього не потрібно створювати процес. Нам потрібно перевірити оновлення за допомогою:

```bash
certbot renew --dry-run
```

Коли ви запустите цю команду, ви отримаєте гарний результат, який показує процес оновлення:

```bash
Saving debug log to /var/log/letsencrypt/letsencrypt.log

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Processing /etc/letsencrypt/renewal/your-server-hostname.conf
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Cert not due for renewal, but simulating renewal for dry run
Plugins selected: Authenticator apache, Installer apache
Account registered.
Simulating renewal of an existing certificate for your-server-hostname
Performing the following challenges:
http-01 challenge for your-server-hostname
Waiting for verification...
Cleaning up challenges

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
new certificate deployed with reload of apache server; fullchain is
/etc/letsencrypt/live/your-server-hostname/fullchain.pem
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Congratulations, all simulated renewals succeeded:
  /etc/letsencrypt/live/your-server-hostname/fullchain.pem (success)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```

Команду для оновлення *certbot* можна знайти одним із таких методів:

- Перерахувавши вміст `/etc/crontab/`
- Перерахувавши вміст `/etc/cron.*/*`
- Запустивши `systemctl list-timers`

У цьому прикладі ми використовуємо останню опцію та бачимо, що *certbot* існує та що його було встановлено за допомогою процедури `snap`:

```bash
sudo systemctl list-timers
Sat 2021-04-03 07:12:00 UTC  14h left   n/a                          n/a          snap.certbot.renew.timer     snap.certbot.renew.service
```

## Висновки

Сертифікати Let's Encrypt SSL є ще одним варіантом для захисту вашого веб-сайту за допомогою SSL. Після встановлення система забезпечує автоматичне оновлення сертифікатів і шифрує трафік до вашого веб-сайту.

Слід зазначити, що сертифікати Let's Encrypt використовуються для стандартних сертифікатів DV (Domain Validation). Їх не можна використовувати для сертифікатів OV (перевірка організації) або EV (розширена перевірка).
