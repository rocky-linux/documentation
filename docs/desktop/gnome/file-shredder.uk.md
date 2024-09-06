---
title: File Shredder
author: Christine Belzie
contributors: Steven Spencer
---

## Вступ

Вам потрібно видалити листівку чи PDF-файл, що містить інформацію, як-от ваш день народження? Перевірте File Shredder. Це програма, яка назавжди видаляє конфіденційну інформацію в Інтернеті.

## Припущення

У цьому посібнику передбачається, що ви маєте наступне:

- Rocky Linux
- Flatpak
- FlatHub

## Процес встановлення

![Screenshot of the File Shredder app page on FlatHub, showing the blue install button being highlighted by a red rectangle](images/01_file-shredder.png)

1. Перейдіть на [веб-сайт Flathub](https://flathub.org), введіть «File Shredder» у рядку пошуку та натисніть **Install**

   ![manual install script and run script](images/file-shredder_install.png)

2. Скопіюйте скрипт у свій термінал:

   ```bash
   flatpak install flathub io.github.ADBeveridge.Raider
   ```

3. Нарешті, запустіть сценарій у вашому терміналі:

   ```bash
   flatpak run flathub io.github.ADBeveridge.Raider
   ```

## Як цим користуватися

Щоб скористатися File Shredder, виконайте такі дії:

1. Перетягніть або клацніть **Add file**, щоб вибрати файли, які потрібно видалити

   ![Screenshot of the File Shredder homepage, showing the add drop-down menu and drop here button being highlighted by red rectangles](images/02_file-shredder.png)

2. Натисніть **Shred All**

![Screenshot of a file named Social Security appearing on top. At the bottom, there is a red button with the phrase Shred All written in white font and surrounded by a red rectangle](images/03_file-shredder.png)

## Висновок

Незалежно від того, чи це файл соціального страхування, чи виписка з банківського рахунку, File Shredder — це інструмент, який дозволяє легко знищувати файли, не купуючи шредер. Ви прагнете дізнатися більше про цю програму чи маєте більше ідей для неї? [Надішліть проблему в репозиторій File Shredder на GitHub](https://github.com/ADBeveridge/raider/issues).
