---
title: Запис на фізичний CD/DVD за допомогою Xorriso
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
---

## Вступ

Нещодавно я виявив, що запис гібридних ISO-образів на фізичний CD/DVD у Rocky Linux за допомогою графічних інструментів є складним завданням. На щастя, Xorriso — це простий у використанні додаток CLI, який добре справляється з цим завданням!

## Опис проблеми

Запиc ISO-образ на фізичний CD/DVD-диск.

## Передумови

- З’єднання з Інтернетом
- Знайомство з терміналом
- Привід CD/DVD-RW

## Процедура

**Встановлення Xorriso**:

   ```bash
   sudo dnf install xorriso -y
   ```

**Запис ISO на диск**:

   ```bash
   sudo xorriso -as cdrecord -v dev=/dev/sr0 -blank=as_needed -dao Rocky-10.1-x86_64-boot.iso -eject
   ```

## Додаткова інформація

Xorriso використовує бібліотеку мови C `libisofs`. Ви можете дізнатися більше про `libisofs` на [спостережувачі пакетів Fedora](https://packages.fedoraproject.org/pkgs/libisofs/libisofs/index.html).

## Висновок

У цій статті ви дізналися, як записати ISO-образ на фізичний диск за допомогою Xorriso! Майте на увазі, що Xorriso можна використовувати для запису інших типів файлів на фізичні диски, але я вважаю його особливо зручним для гібридного формату ISO, з яким графічні інструменти не вміли працювати.
