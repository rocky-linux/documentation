---
title: Виправлення з dnf-automatic
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.5
tags:
  - безпека
  - dnf
  - автоматизація
  - updates
---

# Виправлення серверів за допомогою `dnf-automatic`

Керування встановленням оновлень безпеки є важливим для системного адміністратора. Надання оновлень програмного забезпечення — добре проторений шлях, який зрештою спричиняє мало проблем. З цих причин доцільно автоматизувати щоденне та автоматичне завантаження та застосування оновлень на серверах Rocky.

Безпека вашої інформаційної системи буде посилена. `dnf-automatic` є додатковим інструментом, який дозволить вам досягти цього.

!!! tip "Якщо ви хвилюєтесь..."

    Багато років тому автоматичне застосування оновлень було б рецептом катастрофи. Було багато випадків, коли застосоване оновлення могло спричинити проблеми. Це трапляється рідко, коли оновлення пакета видаляє застарілу функцію, яка використовується на сервері, але здебільшого це не проблема сьогодні. Якщо ви все ще відчуваєте дискомфорт, дозволяючи `dnf-automatic` обробляти оновлення, скористайтеся ним для завантаження та/або сповіщення про наявність оновлень. Таким чином, ваш сервер довго не залишатиметься невиправленим. Це функції `dnf-automatic-notifyonly` і `dnf-automatic-download`
    
    Щоб дізнатися більше про ці функції, перегляньте [офіційну документацію](https://dnf.readthedocs.io/en/latest/automatic.html).

## Встановлення

Ви можете встановити `dnf-automatic` зі складних репозиторіїв:

```
sudo dnf install dnf-automatic
```

## Конфігурація

За замовчуванням процес оновлення розпочнеться о 6 годині ранку з випадковою додатковою дельтою часу, щоб уникнути одночасного оновлення всіх ваших машин. Щоб змінити цю поведінку, ви повинні змінити конфігурацію таймера, пов’язану зі службою програми:

```
sudo systemctl edit dnf-automatic.timer

[Unit]
Description=dnf-automatic timer
# See comment in dnf-makecache.service
ConditionPathExists=!/run/ostree-booted
Wants=network-online.target

[Timer]
OnCalendar=*-*-* 6:00
RandomizedDelaySec=10m
Persistent=true

[Install]
WantedBy=timers.target
```

Ця конфігурація зменшує затримку запуску між 6:00 і 6:10 ранку. (Сервер, вимкнений зараз, буде автоматично виправлено після перезапуску.)

Потім активуйте таймер, пов’язаний із послугою (не самою послугою):

```
$ sudo systemctl enable --now dnf-automatic.timer
```

## А як щодо серверів CentOS 7?

!!! tip "Підказка"

    Так, це документація Rocky Linux, але якщо ви є системним або мережевим адміністратором, у вас все ще можуть бути деякі машини CentOS 7 у грі. Ми це розуміємо, і тому включили цей розділ.

Процес у CentOS 7 схожий, але використовує `yum-cron`.

```
$ sudo yum install yum-cron
```

Цього разу налаштування служби виконується у файлі `/etc/yum/yum-cron.conf`.

Налаштуйте необхідну конфігурацію:

```
[commands]
#  What kind of update to use:
# default                            = yum upgrade
# security                           = yum --security upgrade
# security-severity:Critical         = yum --sec-severity=Critical upgrade
# minimal                            = yum --bugfix update-minimal
# minimal-security                   = yum --security update-minimal
# minimal-security-severity:Critical =  --sec-severity=Critical update-minimal
update_cmd = default

# Whether a message should be emitted when updates are available,
# were downloaded, or applied.
update_messages = yes

# Whether updates should be downloaded when they are available.
download_updates = yes

# Whether updates should be applied when they are available.  Примітка
# щоб download_updates також мав бути yes для застосування оновлення.
apply_updates = yes

# Максимальний час довільного сну, у хвилинах.  Програма
# буде спати протягом випадкового проміжку часу від 0 до random_sleep
# хвилин перед початком.  Це корисно, наприклад, для випадків
# коли кілька систем отримуватимуть доступ до серверів оновлення.  Якщо
# random_sleep дорівнює 0 або негативне значення, програма запуститься негайно.
# 6*60 = 360
random_sleep = 30
```

Коментарі у файлі конфігурації говорять самі за себе.

Тепер ви можете включити службу та запустити її:

```
$ sudo systemctl enable --now yum-cron
```

## Висновок

Автоматичне оновлення пакетів легко активується та значно підвищує безпеку вашої інформаційної системи.
