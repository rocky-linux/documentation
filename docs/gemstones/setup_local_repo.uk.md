---
title: Налаштування локального сховища Rocky
author: codedude
contributors: Steven Spencer
update: 09-Dec-2021
---

# Вступ

Іноді вам потрібно мати локальні репозиторії Rocky для створення віртуальних машин, лабораторних середовищ тощо. Це також може допомогти заощадити пропускну здатність, якщо це викликає занепокоєння.  Ця стаття допоможе вам використати `rsync` для копіювання сховищ Rocky на локальний веб-сервер.  Створення веб-сервера виходить за рамки цієї короткої статті.

## Вимоги

* Веб-сервер

## Код

```
#!/bin/bash
repos_base_dir="/web/path"

# Start sync if base repo directory exist
if [[ -d "$repos_base_dir" ]] ; then
  # Start Sync
  rsync  -avSHP --progress --delete --exclude-from=/opt/scripts/excludes.txt rsync://ord.mirror.rackspace.com/rocky  "$repos_base_dir" --delete-excluded
  # Download Rocky 8 repository key
  if [[ -e /web/path/RPM-GPG-KEY-rockyofficial ]]; then
     exit
  else
      wget -P $repos_base_dir https://dl.rockylinux.org/pub/rocky/RPM-GPG-KEY-rockyofficial
  fi
fi
```

## Аналіз

Цей простий сценарій оболонки використовує `rsync` для отримання файлів сховища з найближчого дзеркала.  Він також використовує опцію "виключити", яка визначена в текстовому файлі у вигляді ключових слів, які не слід включати.  Виключення корисні, якщо у вас обмежений простір на диску або просто з будь-якої причини не потрібно все.  Ми можемо використовувати `*` як символ підстановки.  Будьте обережні з використанням `*/ng`, оскільки це виключить усе, що відповідає цим символам.  Нижче наведено приклад:

```
*/source*
*/debug*
*/images*
*/Devel*
8/*
8.4-RC1/*
8.4-RC1
```

# Кінець
Простий сценарій, який може допомогти заощадити пропускну здатність або спростити створення лабораторного середовища.
