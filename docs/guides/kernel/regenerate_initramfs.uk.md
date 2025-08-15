---
title: Відновлення `initramfs`
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 9.4
tags:
  - hardware
---

## Вступ

`initramfs` - це коренева файлова система всередині ядра Linux, яка допомагає завантажити систему. Вона містить основні модулі, необхідні для завантаження Linux.

Іноді адміністратор Linux може захотіти повторно створити `initramfs`, скажімо, якщо він хоче додати драйвер до чорного списку або включити зовнішній модуль. Автор зробив це, щоб [увімкнути Intel vPro на Minisforum MS-01](https://spaceterran.com/posts/step-by-step-guide-enabling-intel-vpro-on-your-minisforum-ms-01-bios/).

## Вимоги

Нижче наведено мінімальні вимоги для використання цієї процедури:

- Система або віртуальна машина Rocky Linux (не контейнер)
- Зміни в налаштуваннях ядра, наприклад, внесення до чорного списку або додавання модуля

## Відновлення `initramfs`

Щоб відновити `initramfs`, ви повинні спочатку створити резервну копію існуючого `initramfs`:

```bash
cp /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r)-$(date +%m-%d-%H%M%S).img
```

Далі запустіть `dracut`, щоб повторно згенерувати `initramfs`:

```bash
dracut -f /boot/initramfs-$(uname -r).img $(uname -r)
```

Потім перезавантажте:

```bash
reboot
```

## Висновок

Ядро Linux є надзвичайно потужним і модульним. Цілком зрозуміло, що деякі користувачі можуть дозволити або заборонити певні модулі, і повторне створення `initramfs` дозволяє це зробити.
