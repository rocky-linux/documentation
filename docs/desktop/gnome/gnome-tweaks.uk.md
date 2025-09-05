---
title: GNOME Tweaks
author: Steven Spencer
contributors: Ganna Zhyrnova
---

## Вступ

GNOME Tweaks — це інструмент для налаштування робочого столу, включаючи типові шрифти, вікна, робочі області тощо.

## Припущення

- Робоча станція або сервер Rocky Linux із інсталяцією GNOME.

## Встановлення GNOME Tweaks

GNOME Tweaks доступний у репозиторії "appstream", не потребуючи додаткової конфігурації сховища. Встановіть за допомогою:

```bash
sudo dnf install gnome-tweaks 
```

Інсталяція включає всі необхідні залежності.

## Екрани та функції

![Activities Menu](images/activities.png)

Щоб запустити Tweaks, у меню «Дії» введіть «tweaks» і натисніть «Tweaks».

![Tweaks](images/tweaks.png)

<!-- Please, add here a screen where you click Tweaks -->

_General_ дозволяє змінювати типову поведінку анімації, призупинення та надмірне посилення.

![Tweaks General](images/01_tweaks.png)

_Appearance_ дозволяє змінювати параметри теми за замовчуванням, а також зображення фону та екрана блокування.

![Tweaks Appearance](images/02_tweaks.png)

_Fonts_ дозволяють змінювати стандартні шрифти та розміри.

![Tweaks Fonts](images/03_tweaks.png)

_Keyboard & Mouse_ дозволяє змінити поведінку клавіатури та миші за замовчуванням.

![Tweaks Keyboard and Mouse](images/04_tweaks.png)

Якщо у вас є програми, які потрібно запускати під час запуску оболонки GNOME, ви можете налаштувати їх у _Startup Applications_.

![Tweaks Startup Applications](images/05_tweaks.png)

Налаштуйте параметри _Top Bar_ - годинник, календар, батарея.

![Tweaks Top Bar](images/06_tweaks.png)

_Window Titlebars_ дозволяє змінювати типову поведінку заголовків.

![Tweaks Window Titlebars](images/07_tweaks.png)

_Windows_ дозволяє змінювати поведінку вікон за замовчуванням.

![Tweaks Windows](images/08_tweaks.png)

_Workspaces_ дозволяють змінювати спосіб створення робочих областей (динамічно чи статично) і спосіб їх відображення.

![Tweaks Workspaces](images/09_tweaks.png)

!!! note "Примітка"

```
Ви можете скинути все назад до значень за замовчуванням за допомогою меню з трьома смужками біля пункту «Tweaks» в лівому куті.
```

## Висновок

GNOME Tweaks — хороший інструмент для налаштування робочого середовища GNOME.
