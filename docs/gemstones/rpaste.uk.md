---
title: rpaste - інструмент Pastebin
author: Steven Spencer
contributors:
tags:
  - rpaste
  - Mattermost
  - pastebin
---

# Вступ до `rpaste`

`rpaste` — це інструмент для обміну кодом, виводом журналу та іншим наддовгим текстом. Це pastebin, створений розробниками Rocky Linux. Цей інструмент корисний, коли вам потрібно поділитися чимось публічно, але ви не хочете, щоб ваш текст домінував у стрічці. Це особливо важливо під час використання Mattermost, який має мости до інших служб IRC. Інструмент `rpaste` можна встановити на будь-якій системі Rocky Linux. Якщо на вашій настільній машині не встановлено Rocky Linux або ви просто не хочете встановлювати інструмент, ви можете скористатися ним вручну, перейшовши за [pinnwand URL](https://rpa.st) а потім вставте системний вихід або текст, яким ви хочете поділитися. `rpaste` дозволяє створювати цю інформацію автоматично.

## Інсталяція

Встановлення `rpaste` на Rocky Linux:

```bash
sudo dnf --enablerepo=extras install rpaste
```

## Використання

У разі серйозних системних проблем вам може знадобитися надіслати всю інформацію про вашу систему, щоб її можна було перевірити на наявність проблем. Для цього запустіть:

```bash
rpaste --sysinfo
```

Що поверне посилання на сторінку pinnwand:

```bash
Uploading...
Paste URL:   https://rpa.st/2GIQ
Raw URL:     https://rpa.st/raw/2GIQ
Removal URL: https://rpa.st/remove/YBWRFULDFCGTTJ4ASNLQ6UAQTA
```

Потім ви можете самостійно переглянути інформацію в браузері та вирішити, чи хочете ви її зберегти чи видалити та почати все спочатку. Якщо ви хочете зберегти його, ви можете скопіювати «Вставити URL-адресу» та поділитися нею з усіма, з ким ви працюєте, або в стрічці на Mattermost. Щоб видалити, просто скопіюйте «URL-адресу видалення» та відкрийте її у своєму браузері.

Ви можете додати вміст у свій pastebin, перекинувши вміст. Як приклад, якщо ви хочете додати вміст із файлу `/var/log/messages` від 10 березня, ви можете зробити це:

```bash
sudo more /var/log/messages | grep 'Mar 10' | rpaste
```

## Довідка `rpaste`

Щоб отримати довідку щодо команди, просто введіть:

```bash
rpaste --help
```

Що дасть наступний результат:

```bash
rpaste: A paste utility originally made for the Rocky paste service

Usage: rpaste [options] [filepath]
       command | rpaste [options]

This command can take a file or standard in as input

Options:
--life value, -x value      Sets the life time of a paste (1hour, 1day, 1week) (default: 1hour)
--type value, -t value      Sets the syntax highlighting (default: text)
--sysinfo, -s               Collects general system information (disables stdin and file input) (default: false)
--dry, -d                   Turns on dry mode, which doesn't paste the output, but shows the data to stdin (default: false)
--pastebin value, -p value  Sets the paste bin service to send to. Current supported: rpaste, fpaste (default: "rpaste")
--help, -h                  show help (default: false)
--version, -v               print the version (default: false)
```

## Висновки

Іноді важливо поділитися великим обсягом тексту під час роботи над проблемою, обміну кодом або текстом тощо. Використання `rpaste` позбавить інших від необхідності переглядати велику кількість текстового вмісту, який для них не важливий. Також важливий етикет спілкування в Rocky Linux.
