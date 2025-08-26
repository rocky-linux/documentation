---
title: Valuta
author: Christine Belzie
contributors: Steven Spencer, Ganna Zhyrnova
---

## Вступ

Якщо ви часто подорожуєте або переїжджаєте за кордон, спростіть своє фінансове планування з Valuta. Ця програма швидко конвертує валюти.

## Припущення

У цьому посібнику передбачається, що ви маєте наступне:

 - Rocky Linux
 - Flatpak
 - FlatHub

## Процес встановлення

![Screenshot of the Valuta page on Flathub with the blue install button highlighted in a red square](images/01_valuta.png)

1. Перейдіть на [Flathub.org](https://flathub.org), введіть «Valuta» в рядку пошуку та натисніть **Install**

   ![manual install script and run script](images/valuta-install.png)

2. Скопіюйте скрипт у свій термінал:

   ```bash
   flatpak install flathub io.github.idevecore.Valuta
   ```

3. Нарешті, скрипт у вашому терміналі:

   ```bash
   flatpak run flathub io.github.idevecore.Valuta
   ```

## Як використовувати

Щоб використовувати Valuta, виконайте такі дії:

1. Виберіть свою країну зі спадного меню та введіть суму готівки, яку хочете витратити.

   ![Screenshot of Valuta app showing 1000 USD in the input field, with a grey arrow pointing down to a grey box showing 1000 USD](images/02_valuta.png)

2. Виберіть країну, до якої ви подорожуєте, зі спадного меню. Звідти автоматично з’являється конвертована сума.

![Screenshot showing a grey arrow pointing upward to a green box displaying the converted amount, 899.52 EUR](images/03_valuta.png)

## Висновок

Незалежно від того, під час відпустки чи відрядження, Valuta спрощує конвертацію валюти. Хочете дізнатися більше або поділитися ідеями щодо його покращення? [Надішліть проблему в репозиторій Valuta на GitHub](https://github.com/ideveCore/valuta/issues).
