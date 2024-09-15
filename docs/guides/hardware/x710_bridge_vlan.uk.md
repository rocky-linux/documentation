---
title: Увімкнення VLAN Passthrough на мережевих картах серії Intel X710
author: Neel Chauhan
contributors: null
tested_with: 9.4
tags:
  - обладнання
---

## Вступ

Деякі сервери мають мережеві інтерфейсні карти (NIC) серії Intel X710, наприклад Minisforum MS-01 автора, які використовуються для віртуалізованого брандмауера. На жаль, стандартний драйвер Rocky Linux має [помилку](https://community.intel.com/t5/Ethernet-Products/X710-strips-incoming-vlan-tag-with-SRIOV/m-p/551464), коли VLAN не пройшов через інтерфейси мосту, як очікувалося. Так сталося з авторською віртуальною машиною MikroTik CHR. На щастя, це можна виправити.

## Передумови та припущення

Нижче наведено мінімальні вимоги для використання цієї процедури:

- Сервер Rocky Linux 8 або 9 із мережевою карткою серії Intel X710

## Встановлення драйверів мережевої карти Intel

Хоча стандартний драйвер Rocky Linux не проходить через VLAN, наданий Intel драйвер робить це. Спочатку перейдіть на [сторінку завантаження драйвера Intel](https://www.intel.com/content/www/us/en/download/18026/intel-network-adapter-driver-for-pcie-40-gigabit-ethernet -network-connections-under-linux.html).

![Intel's X710 Driver Download Page](../images/intel_x710_drivers.png)

Коли ви перебуваєте на сторінці вище, завантажте файл `i40e_RPM_Files.zip`, а потім `розпакуйте` його:

```
unzip i40e_RPM_Files.zip
```

Ви побачите купу файлів RPM:

```
kmod-i40e-2.25.11-1.rhel8u10.src.rpm
kmod-i40e-2.25.11-1.rhel8u10.x86_64.rpm
kmod-i40e-2.25.11-1.rhel8u7.src.rpm
kmod-i40e-2.25.11-1.rhel8u7.x86_64.rpm
kmod-i40e-2.25.11-1.rhel8u8.src.rpm
kmod-i40e-2.25.11-1.rhel8u8.x86_64.rpm
kmod-i40e-2.25.11-1.rhel8u9.src.rpm
kmod-i40e-2.25.11-1.rhel8u9.x86_64.rpm
kmod-i40e-2.25.11-1.rhel9u1.src.rpm
kmod-i40e-2.25.11-1.rhel9u1.x86_64.rpm
kmod-i40e-2.25.11-1.rhel9u2.src.rpm
kmod-i40e-2.25.11-1.rhel9u2.x86_64.rpm
kmod-i40e-2.25.11-1.rhel9u3.src.rpm
kmod-i40e-2.25.11-1.rhel9u3.x86_64.rpm
kmod-i40e-2.25.11-1.rhel9u4.src.rpm
kmod-i40e-2.25.11-1.rhel9u4.x86_64.rpm
```

Файл для інсталяції має формат `kmod-i40e-2.25.11-1.rhelXuY.x86_64.rpm`, де `X` і `Y` — це основна та проміжна версії Rocky Linux відповідно. Наприклад, на авторському сервері Rocky Linux 9.4 `X` дорівнює 9, `Y` дорівнює 4, тому інсталяційний пакет автора був таким:

```
sudo dnf install kmod-i40e-2.25.11-1.rhel9u4.x86_64.rpm
```

Після встановлення драйвера потрібно буде перезавантажити сервер:

```
sudo reboot
```

Після перезавантаження мережні карти X710 повинні проходити через VLAN через інтерфейси мосту.
