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

![Nerd Fonts](images/nerd_fonts_site_small.png){ align=right } Nerd Fonts — це колекція модифікованих шрифтів, призначених для розробників. Зокрема, для додавання додаткових гліфів використовуються «знакові шрифти», такі як [Font Awesome](https://fontawesome.com/), [Devicons](https://devicon.dev/) і [Octicons](https://primer.style/foundations/icons).

Nerd Fonts також використовує найпопулярніші програмні шрифти, такі як MonoLisa або SourceCode Pro, і змінює їх, додаючи групу гліфів (піктограм). Патчер шрифтів доступний, якщо шрифт, який ви бажаєте використовувати, ще не було відредаговано.  Існує також функція попереднього перегляду, щоб побачити, як шрифт має виглядати в редакторі. Для отримання додаткової інформації відвідайте головний [сайт](https://www.nerdfonts.com/) проекту.

## :material-monitor-arrow-down-variant: Завантаження

Шрифти доступні для завантаження за адресою:

```text
https://www.nerdfonts.com/font-downloads
```

### :material-monitor-arrow-down-variant: Процедура інсталяції

Встановлення Nerd Fonts у Rocky Linux виконується повністю з командного рядка завдяки реалізації процедури, наданої репозиторієм проекту [ryanoasis/nerd-fonts](https://github.com/ryanoasis/nerd-fonts). Процедура використовує *git* для отримання необхідних шрифтів і *fc-cache* для їх налаштування.

!!! Note "Примітка"

    Цей метод можна використовувати в усіх дистрибутивах *linux*, які використовують [fontconfig](https://www.freedesktop.org/wiki/Software/fontconfig/) для керування системними шрифтами.

Для початку отримайте необхідні файли зі сховища проекту:

```bash
git clone --filter=blob:none --sparse git@github.com:ryanoasis/nerd-fonts
```

Ця команда завантажує лише необхідні файли, пропускаючи шрифти, які містяться в *patched-fonts*, щоб не перевантажувати локальне сховище шрифтами, які пізніше не використовуватимуться, таким чином дозволяючи вибіркове встановлення.  
У цьому посібнику використовуватиметься шрифт [IBM Plex Mono](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/IBMPlexMono), який пропонує чисте та трохи типографське відображення, функції, які роблять його особливо придатним для написання документації Markdown.  
Для огляду з попереднім переглядом доступних шрифтів ви можете відвідати [спеціальний сайт](https://www.programmingfonts.org/#plex-mono).

Перейдіть до новоствореної папки та завантажте набір шрифтів за допомогою команд:

```bash
cd ~/nerd-fonts/
git sparse-checkout add patched-fonts/IBMPlexMono
```

Команда завантажить шрифти до папки *patched-fonts* і після завершення ви зможете встановити їх за допомогою наданого сценарію ==install.sh==, введіть:

```bash
./install.sh IBMPlexMono
```

!!! Note "Зарезервована Назва"

    Під час інсталяції шрифт перейменовується на BlexMono відповідно до ліцензії SIL Open Font License (OFL) і, зокрема, [механізму зарезервованих імен](http://scripts.sil.org/cms/scripts/page.php? item_id=OFL_web_fonts_and_RFNs#14cbfd4a).

Сценарій *install.sh* копіює шрифти до папки користувача `~/.local/share/fonts/` і викликає програму *fc-cache* для зареєструвати їх у системі. Після завершення шрифти будуть доступні для емулятора терміналу; зокрема, ми знайдемо такі встановлені шрифти:

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
