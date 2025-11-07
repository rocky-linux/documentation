---
title: Встановлення Nerd Fonts
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova, Christine Belzie
tested: 8.6, 9.0
tags:
  - nvchad
  - coding
  - шрифти
---

# :material-format-font: Nerd Fonts - Шрифти для розробників

## :material-format-font: Що таке Nerd Fonts?

![Шрифти Nerd](images/nerd_fonts_site_small.png){ align=right } Nerd Fonts — це колекція модифікованих шрифтів, призначених для розробників. Зокрема, для додавання додаткових гліфів використовуються «культові шрифти», такі як [Font Awesome](https://fontawesome.com/), [Devicons](https://devicon.dev/) та [Octicons](https://primer.style/foundations/icons).

Nerd Fonts також використовує найпопулярніші програмні шрифти, такі як MonoLisa або SourceCode Pro, і змінює їх, додаючи групу гліфів (піктограм). Патчер шрифтів доступний, якщо шрифт, який ви бажаєте використовувати, ще не було відредаговано.  Існує також функція попереднього перегляду, щоб побачити, як шрифт має виглядати в редакторі. Щоб отримати додаткову інформацію, відвідайте головний [сайт] проєкту (https://www.nerdfonts.com/).

## :material-monitor-arrow-down-variant: Завантаження

Шрифти доступні для завантаження за адресою:

```text
https://www.nerdfonts.com/font-downloads
```

### :material-monitor-arrow-down-variant: Процедура інсталяції

Встановлення шрифтів Nerd у Rocky Linux здійснюється повністю з командного рядка завдяки реалізації процедури, що надається репозиторієм проекту [ryanoasis/nerd-fonts](https://github.com/ryanoasis/nerd-fonts). Процедура використовує _git_ для отримання необхідних шрифтів та _fc-cache_ для їхньої конфігурації.

!!! Note "Примітка"

    ```
    Цей метод можна використовувати в усіх дистрибутивах *linux*, які використовують [fontconfig](https://www.freedesktop.org/wiki/Software/fontconfig/) для керування системними шрифтами.
    ```

Для початку отримайте необхідні файли зі сховища проекту:

```bash
git clone --filter=blob:none --sparse git@github.com:ryanoasis/nerd-fonts
```

Ця команда завантажує лише необхідні файли, пропускаючи шрифти, що містяться у _patched-fonts_, щоб не перевантажувати локальний репозиторій шрифтами, які пізніше не використовуватимуться, що дозволяє вибіркове встановлення.  
У цьому посібнику буде використано шрифт [IBM Plex Mono](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/IBMPlexMono), який пропонує чисте та злегка типографічне відображення, що робить його особливо придатним для написання документації Markdown.  
Відвідайте [спеціальний сайт](https://www.programmingfonts.org/#plex-mono) для огляду та попереднього перегляду доступних шрифтів.

Перейдіть до новоствореної папки та завантажте набір шрифтів за допомогою команд:

```bash
cd ~/nerd-fonts/
git sparse-checkout add patched-fonts/IBMPlexMono
```

Команда завантажить шрифти до папки _patched-fonts_ і після завершення ви зможете встановити їх за допомогою наданого сценарію ==install.sh==, введіть:

```bash
./install.sh IBMPlexMono
```

!!! Note "Зарезервована Назва"

    ```
    Під час інсталяції шрифт перейменовується на BlexMono відповідно до ліцензії SIL Open Font License (OFL) і, зокрема, [механізму зарезервованих імен](http://scripts.sil.org/cms/scripts/page.php? item_id=OFL_web_fonts_and_RFNs#14cbfd4a).
    ```

Скрипт _install.sh_ копіює шрифти до папки користувача `~/.local/share/fonts/` та викликає програму _fc-cache_ для їх реєстрації в системі. Після завершення шрифти будуть доступні для емулятора терміналу; зокрема, ми знайдемо такі встановлені шрифти:

```text title="~/.local/share/fonts/"
NerdFonts/
├── BlexMonoNerdFont-BoldItalic.ttf
├── BlexMonoNerdFont-Bold.ttf
├── BlexMonoNerdFont-ExtraLightItalic.ttf
├── BlexMonoNerdFont-ExtraLight.ttf
├── BlexMonoNerdFont-Italic.ttf
├── BlexMonoNerdFont-LightItalic.ttf
├── BlexMonoNerdFont-Light.ttf
├── BlexMonoNerdFont-MediumItalic.ttf
├── BlexMonoNerdFont-Medium.ttf
├── BlexMonoNerdFont-Regular.ttf
├── BlexMonoNerdFont-SemiBoldItalic.ttf
├── BlexMonoNerdFont-SemiBold.ttf
├── BlexMonoNerdFont-TextItalic.ttf
├── BlexMonoNerdFont-Text.ttf
├── BlexMonoNerdFont-ThinItalic.ttf
├── BlexMonoNerdFont-Thin.ttf
```

## :material-file-cog-outline: Конфігурація

На цьому етапі вибраний вами шрифт Nerd має бути доступним для вибору. Щоб вибрати його, ви повинні звернутися до робочого столу, який ви використовуєте.

![Font Manager](images/font_nerd_view.png)

Якщо ви використовуєте робочий стіл Rocky Linux за замовчуванням (Gnome), щоб змінити шрифт в емуляторі терміналу, вам потрібно буде відкрити `gnome-terminal`, перейти до «Параметрів» і встановити Nerd Font для ваш профіль.
