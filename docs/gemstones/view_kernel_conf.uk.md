---
title: Перегляд поточної конфігурації ядра
author: David Hensley
contributors: Steven Spencer
tested_with: 8.5
tags:
  - kernel
  - config
  - modules
  - kmod
---

# Перегляд поточної конфігурації ядра

Ядро Linux зберігає поточну інформацію про ядро у двох місцях за допомогою спеціальних файлових систем: ([їх короткий опис](https://www.landoflinux.com/linux_procfs_sysfs.html))

  - Старіші [procfs](https://man7.org/linux/man-pages/man5/procfs.5.html), які монтують `/proc` (перевірте за допомогою `mount -l -t proc`)
  - Новіший [sysfs](https://man7.org/linux/man-pages/man5/sysfs.5.html), який монтує `/sys` (перевірити за допомогою `mount -l -t sysfs`)

!!! warning "Важливо"

    Будьте обережні, якщо перевіряєте згадані тут файли, їх зміна може змінити поведінку фактично запущеного ядра!


Ці два інтерфейси дозволяють переглядати та змінювати параметри поточного ядра.

Зауважте, що якщо ви виконуєте [`ls -l`](https://man7.org/linux/man-pages/man1/ls.1.html) на деяких з цих файлів, вони відображатимуться як довжина "0", але якщо ви виконаєте [`cat`](https://man7.org/linux/man-pages/man1/cat.1.html), вони фактично містять дані; більшість із них є ASCII і їх можна редагувати, однак деякі є двійковими, і в будь-якому випадку такі команди, як [` file`](https://man7.org/linux/man-pages/man1/file.1.html) або [`stat`](https://man7.org/linux/man-pages/man2/lstat.2.html) зазвичай просто повертає "порожній файл" або "0" для довжини, хоча вони показуватимуть іншу інформацію.

Переважними та стандартними програмами для взаємодії з цими функціями є [`lsmod`](https://man7.org/linux/man-pages/man8/lsmod.8.html), [`modinfo`](https://man7.org/linux/man-pages/man8/modinfo.8.html) та [` sysctl`](https://man7.org/linux/man-pages/man8/sysctl.8.html).

```bash
sysctl -a | grep -i <keyword>
```

```bash
lsmod | grep -i <keyword>
```

```bash
modinfo <module>
```

Подивіться, з якою версією «випуску ядра» зараз працюєте:

`uname -r` і замініть його повертане значення в командах за допомогою `$(uname -r)`

RHEL і похідні дистрибутиви (Fedora, CentOS Stream, Scientific Linux, RockyLinux, AlmaLinux тощо) також зберігайте конфігурацію, яка використовується для завантажувальних встановлених ядер, у каталозі `/boot`, який використовується Grub2, як файли ASCII:

```bash
/boot/config-<kernel-release>
```

Щоб перевірити поточну запущену конфігурацію ядра на певне значення:

```bash
cat /boot/config-$(uname -r) | grep -i <keyword>
```

Результати покажуть:

  - "=m", якщо зібрано як модуль ядра
  - "=y", якщо статично зібрано в ядро
  - "is not set", якщо це налаштування було закоментовано
  - числове значення
  - значення рядка в лапках

Деякі дистрибутиви, як-от Gentoo та Arch, використовують модуль ядра `configs`, щоб надати `/proc/config.gz` за замовчуванням:

```bash
zcat /proc/config.gz | grep -i <keyword>
zgrep <keyword> /proc/config.gz
```

Для будь-якого дистрибутива, якщо ваше запущене ядро встановило як `CONFIG_IKCONFIG`, так і `CONFIG_IKCONFIG_PROC` і якщо

```bash
ls -lh /sys/module/configs
```

існує та є виконуваним (можна шукати у випадку каталогу), тоді ви можете створити `/proc/config.gz` за допомогою цієї команди, якщо її немає:

```bash
modprobe configs
```

!!! note "Увімкнено репо"

    Цей документ наразі не охоплює пакети ядра, які могли походити зі сховищ не за замовчуванням, наприклад:
    
    appstream-debug, appstream-source, baseos-debug, baseos-source або devel


Пакети `kernel-devel` встановлюють конфігураційний файл, який використовується для компіляції кожного встановленого стандартного пакета ядра, як файл ASCII у такому місці:

```bash
/usr/src/kernels/<kernel-release>/.config
```

До цього файлу частіше звертаються через шлях із символічним посиланням, наданий пакетами `kernel-core`:

```bash
/lib/modules/<kernel-release>/build/ -> /usr/src/kernels/<kernel-release>/
```

Якщо у вас встановлено пакети `kernel-debug-devel`, ви також матимете цей каталог:

```bash
 /usr/src/kernels/<kernel-release>+debug/
```

Ви можете переглянути будь-яку з наступних сторінок, щоб дізнатися більше про значення конфігурації, які використовуються для створення встановленого ядра:

```bash
/lib/modules/<kernel-release>/config
/lib/modules/<kernel-release>/build/.config
/usr/src/kernels/<kernel-release>/.config
/usr/src/kernels/<kernel-release>+debug/.config
```

Налаштовані модулі для поточного запущеного ядра, скомпільовані як вбудовані (тобто статичні в самому ядрі) або завантажувані модулі, перераховані підкаталогами, названими як назва модуля в:

```bash
/sys/module/
```

Для кожного встановленого випуску ядра ви можете переглянути ці файли, щоб побачити, які значення було скомпільовано в це ядро та яку версію [GCC](https://man7.org/linux/man-pages/man1/gcc.1. html) використовувався для його компіляції:

```bash
cat /lib/modules/$(uname -r)/config | grep -i <keyword>
```

```bash
cat /lib/modules/$(uname -r)/build/.config | grep -i <keyword>
```

```bash
cat /usr/src/kernels/$(uname -r)/.config | grep -i <keyword>
```

```bash
cat /usr/src/kernels/$(uname -r)+debug/.config | grep -i <keyword>
```

```bash
ls -lh /sys/module/ | grep -i <keyword>
```

Ви можете перевірити наявність залежностей модуля ядра у файлі:

```bash
/lib/modules/<kernel-release>/modules.dep
```

але легше прочитати або проаналізувати вивід поля «Використаний» у [` lsmod`](https://man7.org/linux/man-pages/man8/lsmod.8.html).

## Посилання:

[depmod](https://man7.org/linux/man-pages/man8/depmod.8.html), [ls](https://man7.org/linux/man-pages/man1/ls.1.html), [lsmod](https://man7.org/linux/man-pages/man8/lsmod.8.html), [modinfo](https://man7.org/linux/man-pages/man8/modinfo.8.html), [modprobe](https://man7.org/linux/man-pages/man8/modprobe.8.html), [modules.dep](https://man7.org/linux/man-pages/man5/modules.dep.5.html), [namespaces](https://man7.org/linux/man-pages/man7/namespaces.7.html), [procfs](https://man7.org/linux/man-pages/man5/procfs.5.html), [sysctl](https://man7.org/linux/man-pages/man8/sysctl.8.html), [sysfs](https://man7.org/linux/man-pages/man5/sysfs.5.html), [uname](https://man7.org/linux/man-pages/man8/uname26.8.html)
