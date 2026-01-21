---
title: Файли Kickstart та Rocky Linux
author: Howard Van Der Wal
contributors: Steven Spencer
tested with: 10, 9, 8
tags:
  - file
  - install
  - kickstart
  - linux
  - rocky
---

# Файли Kickstart та Rocky Linux

**Знання**: :star: :star:  
**Час читання**: 15 хвилин

## Вступ

Файли Kickstart є незамінним інструментом для встановлення та налаштування Rocky Linux на одній або кількох машинах одночасно. Ви можете використовувати їх для швидкого налаштування всього: від вашої улюбленої ігрової робочої станції до розгортання сотень машин у корпоративній організації. Вони заощаджують години часу та зусиль на ручне налаштування кожної машини по черзі.

В кінці цієї статті ви зрозумієте, як працюють файли `kickstart`, як створити та застосувати власний файл `kickstart` до ISO-образу Rocky Linux, а потім зможете налаштувати власну машину.

## Що таке конфігурації кікстарту?

Файли Kickstart — це набір файлів конфігурації, які користувачі можуть використовувати для швидкого та легкого розгортання дистрибутива Linux. Файли Kickstart працюють не лише на Rocky Linux, але й на CentOS Stream, Fedora та багатьох інших дистрибутивах.

## Як застосовуються конфігурації кікстарту до ISO?

За допомогою `mkkiso` файл кікстарту копіюється в кореневий каталог ISO-образу Linux. Звідти `mkkiso` редагує `/isolinux/isolinux.cfg` та поміщає туди файл `kickstart` як параметр командного рядка ядра (`inst.ks`):

```bash
sudo mount -o ro,loop rocky-linux10-dvd-shadow.iso /mnt/
cat /mnt/EFI/BOOT/grub.cfg | grep shadow | head -1
linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=Rocky-10-1-x86_64-dvd quiet inst.ks=hd:LABEL=Rocky-10-1-x86_64-dvd:/rocky_linux10_shadow.ks
```

Після цього `mkkiso` створює новий ISO-образ із вбудованою конфігурацією `kickstart`. Коли ISO-образ завантажується, `anaconda` виконує інструкції, перелічені у файлі `kickstart`.

## Передумови

- Додатково – розгорніть свій ISO-образ `kickstart` через PXE-сервер: ознайомтеся з посібником [Як налаштувати PXE-сервер на Rocky Linux 9.x] (https://kb.ciq.com/article/rocky-linux/rl-pxe-boot-kickstart-file), щоб дізнатися більше.

- Одна флешка USB Gen 3.0+ для встановлення через USB.

- Мінімальний ISO-образ Rocky Linux 8, 9 або 10 з https://rockylinux.org/download (ISO-образ DVD не є обов'язковим).

- Дотримуйтесь інструкцій [Кроки налаштування власного ISO-образу Rocky Linux] (https://docs.rockylinux.org/10/guides/isos/iso_creation/), щоб встановити пакет `lorax` та створити ISO-образ Rocky Linux для `kickstart`.

## Приклади Kickstart

\=== "10"

    ````
    ```
    lang en_GB
    keyboard --xlayouts='jp'
    timezone Asia/Tokyo --utc
    rootpw --iscrypted $6$0oXug1vTr7TO3kJu$/kvm.lctWsLDHaeak/YuUaEu26LzvNuE1L/tvUC4G91ZroChjDTUDwQDEkQfGhwQw4doiDcZc2P6et.zzRqOZ/ --allow-ssh
    user --name howard --password $6$8wzUW5ipTdTs.MbM$1F6mPfqQAXPeSVArqT2r/GL6QljXs2dQWCcNGjQq5cpEPGWhNvOCAiVCDJRA0FZQpoTXJSBtNON2ZqvEMBUNX/ --iscrypted --groups=wheel
    reboot
    text
    url --url='https://download.rockylinux.org/pub/rocky/10/BaseOS/x86_64/os/'
    bootloader --location=boot --append="ro crashkernel=2G-64G:256M,64G-:512M rhgb quiet"
    zerombr
    clearpart --all --initlabel --disklabel=gpt
    ignoredisk --only-use=nvme0n1
    part /boot/efi --fstype=efi --size=600
    part /boot --fstype=xfs --size=1024
    part pv.0 --fstype=lvmpv --size=480000
    volgroup rl --pesize=4096 pv.0
    logvol / --vgname=rl --name=root --fstype=xfs --size=70000
    logvol swap --vgname=rl --name=swap --fstype=swap --size=1024
    logvol /home --vgname=rl --name=home --fstype=xfs --size=1000 --grow
    network --device=enp4s0 --hostname=shadow --bootproto=static --ip=192.168.1.102 --netmask=255.255.255.0 --gateway=192.168.1.1 --nameserver=192.168.1.1 --activate
    skipx
    firstboot --disable
    selinux --enforcing
    firewall --enabled --ssh
    %packages
    @^server-product-environment
    %end
    
    %post
    mkdir -p /mnt/storage1
    mkdir -p /mnt/storage2
    mkfs.xfs /dev/nvme0n1
    mkfs.xfs /dev/sda
    sync
    udevadm settle
    sleep 2
    UUID_NVME0N1=$(blkid -s UUID -o value /dev/nvme0n1)
    UUID_SDA=$(blkid -s UUID -o value /dev/sda)
    if [ -n "$UUID_NVME0N1" ]; then
        echo "UUID=$UUID_NVME0N1 /mnt/storage1 xfs defaults,inode64 0 0" >> /etc/fstab
    fi
    if [ -n "$UUID_SDA" ]; then
        echo "UUID=$UUID_SDA /mnt/storage2 xfs defaults,inode64 0 0" >> /etc/fstab
    fi
    mount -U $UUID_NVME0N1 /mnt/storage1
    mount -U $UUID_SDA /mnt/storage2
    chown -R howard:howard /mnt/storage1
    chown -R howard:howard /mnt/storage2
    %end
    ```
    ````

\=== "9"

    ````
    ```
    lang en_GB
    keyboard --xlayouts='jp'
    timezone Asia/Tokyo --utc
    rootpw --iscrypted $6$IjIs0nEufTOaj2cZ$EnZKdrjHQ9OmhePUMVWUcaJmmC0vU2L.b02lBMKmRMLq/VZOhnrgBO64ru29rFnB8HQsGo0cQLqBoLIpL7PbS1 --allow-ssh
    user --name howard --groups wheel --password $6$OdZuQb9owvkol5gv$6X7w0VraE7hDSrrHS5oz9BvNACB.PcrNt5Ulka9/g1Sgxdzl93LAuGT3GH8a.4ZUpqzchKU3glgRyCWXhSN68. --iscrypted
    reboot
    text
    url --url='https://download.rockylinux.org/pub/rocky/9/BaseOS/x86_64/os/'
    bootloader --location=boot --append="crashkernel=1G-4G:192M,4G-64G:256M,64G:512M rhgb quiet"
    zerombr
    clearpart --all --initlabel --disklabel=gpt
    ignoredisk --only-use=sda
    part /boot/efi --fstype=efi --size=600
    part /boot --fstype=xfs --size=1024
    part pv.0 --fstype=lvmpv --size=120012
    volgroup rl --pesize=4096 pv.0
    logvol / --vgname=rl --name=root --fstype=xfs --size=70000
    logvol swap --vgname=rl --name=swap --fstype=swap --size=1024
    logvol /home --vgname=rl --name=home --fstype=xfs --size=1000 --grow
    network --device=enp2s0 --hostname=mighty --bootproto=static --ip=192.168.1.104 --netmask=255.255.255.0 --gateway=192.168.1.1 --nameserver=192.168.1.1 --activate
    skipx
    firstboot --disable
    selinux --enforcing
    firewall --enabled --ssh
    %packages
    @^server-product-environment
    %end
    ```
    ````

\=== "8"

    ````
    ```
    lang en_GB
    keyboard jp106
    timezone Asia/Tokyo --utc
    rootpw <ROOT_PASSWORD_HERE> --iscrypted
    user --name=howard --password=<USER_PASSWORD_HERE> --iscrypted --groups=wheel
    reboot
    text
    url --url='https://download.rockylinux.org/pub/rocky/8/BaseOS/x86_64/os/'
    bootloader --append="rhgb quiet crashkernel=auto"
    zerombr
    clearpart --all --initlabel
    autopart
    network --device=enp1s0 --hostname=rocky-linux8-slurm-controller-node --bootproto=static --ip=192.168.1.120 --netmask=255.255.255.0 --gateway=192.168.1.1 --nameserver=192.168.1.1
    firstboot --disable
    selinux --enforcing
    firewall --enabled --ssh
    %packages
    @^server-product-environment
    %end 
    ```
    ````

**Нижче виділено цікаві пункти, зокрема, файл `kickstart` для Rocky Linux 10. Також обговорюються будь-які відмінності між файлами `kickstart`:**

### Розбивка файлів кікстарту Rocky Linux 10

#### rootpw

!!! warning

    Завжди використовуйте опцію `--iscrypted` для пароля root, щоб він не відображався у вигляді звичайного тексту

Щоб згенерувати хеш потрібного вам пароля, скористайтеся наступною командою `openssl` та введіть свій пароль, коли буде запропоновано:

```bash
openssl passwd -6
```

Для доступу `ssh` до облікового запису `root`, додайте опцію `--allow-ssh` до рядка `rootpw`.

#### user

Аналогічно, використовуйте опцію `--iscrypted`, щоб ваші паролі не відображалися у вигляді звичайного тексту.

Якщо ви хочете зробити свого користувача адміністратором, додайте його до групи `wheel` за допомогою `--groups=wheel`

#### URL

Використання опції `cdrom` з `ignoredisk` призводить до того, що Anaconda не може отримати доступ до USB-накопичувача, і він зависає під час налаштування сховища. Використання `url --url` обходить цю проблему, завантажуючи інсталяцію з `BaseOS`.

#### Bootloader

Встановлює розташування завантажувача та додає необхідні параметри командного рядка ядра.

#### Zerombr

Забезпечує знищення будь-яких таблиць розділів або інших параметрів форматування, які Anaconda не розпізнає на вибраному диску.

#### Clearpart

Стирає всі розділи на цільовому диску та встановлює мітку диска як `gpt`.

#### Ignoredisk

Якщо `ignoredisk` не вказано, `anaconda` матиме доступ до всіх дисків у системі. Якщо вказано, `anaconda` використовуватиме лише диск, вибраний користувачем.

#### Part

`part` дозволяє користувачеві вказати розділи, які він хоче створити. Вище наведено приклад конфігурації `/boot`, `/boot/efi` та керування логічними томами. Ось що ви отримаєте, коли виконаєш автоматичну інсталяцію Rocky Linux.

#### Volgroup

Команда `volgroup` створює групу LVM. У цьому прикладі показано вибір імені `rl` та фізичного розміру (`pesize`) `4096 KiB`.

#### Logvol

Створіть логічні томи в групі LVM. Зверніть увагу на опцію `--grow` для тому `/home`, щоб забезпечити використання всього простору групи LVM.

#### Network

Тут ви можете вибрати статичне або динамічне налаштування конфігурації мережі.

#### Skipx

Зупиняє конфігурацію X-сервера в системі.

#### Firstboot

У цьому випадку ми встановлюємо прапорець `--disable`, який зупиняє запуск агента встановлення під час завантаження системи.

#### Firewall

Важливо дозволити доступ `ssh` через брандмауер за допомогою `--ssh`, щоб ви могли увійти на свою машину, де доступ до консолі недоступний.

#### %packages

Перелічує пакети, які ви хочете встановити. У цьому прикладі група пакетів `@^server-product-environment` є кандидатом на встановлення. Це встановлює всі необхідні пакети для стабільної роботи сервера Rocky Linux.

Крім того, ви також можете вибрати окремі пакети для встановлення тут, виключити встановлення певних пакетів тощо.

#### %post

Після завершення встановлення ОС ви також можете перерахувати тут додаткові завдання для виконання. У наведеному прикладі автор налаштовує та монтує додаткове сховище, доступне в їхній системі.

Тут також доступні інші опції, такі як `%pre`, `%pre-install`, `%onerror` та `%traceback`. Ви можете дізнатися більше про ці опції, скориставшись посиланнями, наведеними в кінці цього документа.

### Відмінності між стартовими версіями Rocky Linux

У Rocky Linux 10 та 9 розкладка клавіатури (приклад з японською клавіатурою) визначається наступним чином:

```
keyboard --xlayouts='jp'
```

Однак, Rocky Linux 8 визначає розкладку клавіатури так:

```
keyboard jp106
```

Для доступу `ssh` до облікового запису `root`, файл `kickstart` Rocky Linux 8 **не** потребує додавання прапорця `--allow-ssh`.

Параметр командного рядка ядра `crashkernel` відрізняється для всіх трьох версій Rocky Linux. Будь ласка, пам’ятайте про це під час налаштування цього параметра.

У прикладі `kickstart` Rocky Linux 8 (це стосується всіх версій Rocky Linux), якщо ви хочете автоматично розбити диск на розділи, просто встановіть опцію `autopart`.

## Висновок

Якщо ви хочете автоматизувати встановлення Rocky Linux, тоді файли `kickstart` — це те, що вам потрібно. Цей посібник — лише верхівка айсберга того, що ви можете зробити за допомогою файлів `kickstart`. Щоб отримати чудовий ресурс щодо кожного доступного варіанту `kickstart` з прикладами, перегляньте документацію `kickstart` від Кріса Люменса та команди інсталяторів Anaconda^2^.

Для тих, хто бажає глибше розвинути автоматизацію в сфері розгортання віртуальних машин, а також скористатися своїми знаннями для «стартового етапу», Антуан Ле Морван написав чудовий посібник^1^ про те, як це зробити за допомогою `packer`.

Команда розробників релізів Rocky Linux також має кілька прикладів файлів `kickstart`, доступних у репозиторії Rocky Linux^4^.

Зрештою, якщо у вас є доступ до облікового запису Red Hat, Red Hat надає Kickstart Generator, який дозволяє швидко та легко створювати файли «kickstart» через інтерфейс користувача.

## Посилання

1. «Автоматичне створення шаблонів за допомогою Packer та розгортання за допомогою Ansible у середовищі VMware vSphere» від Антуана Ле Морвана [https://docs.rockylinux.org/10/guides/automation/templates-automation-packer-vsphere/](https://docs.rockylinux.org/10/guides/automation/templates-automation-packer-vsphere/)
2. «Докладна документація для kickstart» від Кріса Люменса та команди інсталяторів Anaconda [https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html](https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html)
3. «Генератор Red Hat Kickstart (потрібен обліковий запис Red Hat)» від Red Hat [https://access.redhat.com/labsinfo/kickstartconfig](https://access.redhat.com/labsinfo/kickstartconfig)
4. «Кікстартовий репозиторій Rocky Linux» від команди розробників релізів Rocky Linux [https://github.com/rocky-linux/kickstarts/tree/main](https://github.com/rocky-linux/kickstarts/tree/main)

