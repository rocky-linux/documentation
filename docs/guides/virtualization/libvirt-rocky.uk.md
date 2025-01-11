---
title: Налаштування libvirt на Rocky Linux
author: Howard Van Der Wal
contributors: Steven Spencer
tested with: 9.5
tags:
  - libvirt
  - kvm
  - віртуалізація
---

## Вступ

[libvirt](https://libvirt.org/) — це неймовірний API віртуалізації, який дозволяє віртуалізувати майже будь-яку операційну систему на ваш вибір за допомогою потужності KVM як гіпервізора та QEMU як емулятора.

Цей документ містить інструкції з налаштування libvirt у Rocky Linux 9.

## Передумови

- 4-бітна машина під керуванням Rocky Linux 9.
- Переконайтеся, що віртуалізація включена в налаштуваннях BIOS. Якщо наступна команда повертає вихідні дані, це означає, що активацію віртуалізації завершено:

```bash
sudo grep -e 'vmx' /proc/cpuinfo
```

## Налаштування репозиторію та встановлення пакетів

- Увімкніть репозиторій EPEL (додаткові пакети для Enterprise Linux):

```bash
sudo dnf install -y epel-release
```

- Встановіть необхідні пакунки для `libvirt` (необов’язково для `virt-manager`, якщо ви бажаєте використовувати GUI для керування своїми віртуальними машинами):

```bash
sudo dnf install -y bridge-utils virt-top libguestfs-tools bridge-utils virt-viewer qemu-kvm libvirt virt-manager virt-install
```

## налаштування користувача libvirt

- Додайте свого користувача до групи `libvirt`. Це дає змогу керувати вашими віртуальними машинами та використовувати такі команди, як `virt-install`, як не-root користувач:

```bash
sudo usermod -aG libvirt $USER
```

- Активуйте групу `libvirt` за допомогою команди `newgrp`:

```bash
sudo newgrp libvirt
```

- Увімкніть і запустіть службу `libvirtd`:

```bash
sudo systemctl enable --now libvirtd
```

## Налаштування інтерфейсу Bridge для прямого доступу до віртуальних машин

- Перевірте поточні інтерфейси, які використовуються, і запишіть основний інтерфейс із підключенням до Інтернету:

```bash
sudo nmcli connection show
```

- Видаліть інтерфейс, підключений до Інтернету, і будь-які існуючі віртуальні мостові підключення:

```bash
sudo nmcli connection delete <CONNECTION_NAME>
```

!!! warning "Важливо"

```
Переконайтеся, що у вас є прямий доступ до машини. Якщо ви налаштовуєте машину через SSH, з’єднання буде розірвано після видалення з’єднання основного інтерфейсу.
```

- Створіть нове з'єднання мосту:

```bash
sudo nmcli connection add type bridge autoconnect yes con-name <VIRTUAL_BRIDGE_CON-NAME> ifname <VIRTUAL_BRIDGE_IFNAME>
```

- Призначте статичну IP-адресу:

```bash
sudo nmcli connection modify <VIRTUAL_BRIDGE_CON-NAME> ipv4.addresses <STATIC_IP/SUBNET_MASK> ipv4.method manual
```

- Призначте адресу шлюзу:

```bash
sudo nmcli connection modify <VIRTUAL_BRIDGE_CON-NAME> ipv4.gateway <GATEWAY_IP>
```

- Призначте адресу DNS:

```bash
sudo nmcli connection modify <VIRTUAL_BRIDGE_CON-NAME> ipv4.dns <DNS_IP>
```

- Додайте підпорядковане підключення мосту:

```bash
sudo nmcli connection add type bridge-slave autoconnect yes con-name <MAIN_INTERFACE_WITH_INTERNET_ACCESS_CON-NAME> ifname <MAIN_INTERFACE_WITH_INTERNET_ACCESS_IFNAME> master <VIRTUAL_BRIDGE_CON-NAME>
```

- Запустіть з'єднання мостом:

```bash
sudo nmcli connection up <VIRTUAL_BRIDGE_CON-NAME>
```

- Додайте рядок `allow all` до `bridge.conf`:

```bash
sudo tee -a /etc/qemu-kvm/bridge.conf <<EOF
allow all
EOF
```

- Перезапустіть службу `libvirtd`:

```bash
sudo systemctl restart libvirtd
```

## Встановлення віртуальної машини

- Установіть право власності на каталог `/var/lib/libvirt` і його вкладені каталоги для вашого користувача:

```bash
sudo chown -R $USER:libvirt /var/lib/libvirt/
```

- Ви можете створити віртуальну машину в командному рядку за допомогою команди `virt-install`. Наприклад, щоб створити мінімальну віртуальну машину Rocky Linux 9.5, потрібно виконати таку команду:

```bash
virt-install --name Rocky-Linux-9 --ram 4096 --vcpus 4 --disk path=/var/lib/libvirt/images/rocky-linux-9.img,size=20 --os-variant rocky9 --network bridge=virbr0,model=virtio --graphics none --console pty,target_type=serial --extra-args 'console=ttyS0,115200n8' --location ~/isos/Rocky-9.5-x86_64-minimal.iso
```

- Для тих, хто хоче керувати своїми віртуальними машинами за допомогою графічного інтерфейсу користувача, `virt-manager` є ідеальним інструментом.

## Як вимкнути віртуальну машину

- Команда `shutdown` виконує це:

```bash
virsh shutdown --domain <YOUR_VM_NAME>
```

- Щоб примусово вимкнути віртуальну машину, яка не відповідає, скористайтеся командою `destroy`:

```bash
virsh destroy --domain <YOUR_VM_NAME>
```

## Як видалити віртуальну машину

- Використовуйте команду `undefine`:

```bash
virsh undefine --domain <YOUR_VM_NAME> --nvram
```

- Щоб отримати додаткові команди `virsh`, перевірте сторінки `man` `virsh`.

## Висновок

- libvirt надає багато можливостей і дозволяє легко встановлювати віртуальні машини та керувати ними. Якщо у вас є додаткові доповнення або зміни до цього документа, якими ви хотіли б поділитися, автор люб’язно запрошує вас це зробити.
