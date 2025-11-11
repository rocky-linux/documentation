---
title: Встановлення драйверів NVIDIA GPU
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
---

## Вступ

Nvidia є одним з найпопулярніших виробників GPU. Ви можете встановити драйвери Nvidia GPU кількома способами. Цей посібник використовує офіційне сховище Nvidia для встановлення їх драйверів. Тому [посібник із встановлення Nvidia](https://docs.nvidia.com/cuda/pdf/CUDA_Installation_Guide_Linux.pdf) тут багато посилається.

Деякі інші альтернативні способи встановлення драйверів Nvidia включають:

- Nvidia's `.run` installer
- Сторонній репозиторій RPMFusion
- Сторонній драйвер ELRepo

У більшості випадків найкраще встановити драйвери Nvidia з офіційного джерела. RPMFusion і ELRepo доступні для тих, хто віддає перевагу репозиторію на основі спільноти. Для старішого обладнання найкраще працює RPMFusion. Бажано уникати використання інсталятора `.run`. Хоча це зручно, використання інсталятора `.run` відоме тим, що він перезаписує системні файли та має проблеми з несумісністю.

## Припущення

Для цього посібника вам потрібно:

- Робоча станція Rocky Linux
- привілеї `sudo`

## Встановіть необхідні утиліти та залежності

Увімкніть репозиторій Extra Packages for Enterprise Linux (EPEL):

```bash
sudo dnf install epel-release -y
```

Увімкніть репозиторій CodeReady Builder (CRB):

```bash
sudo dnf config-manager --enable crb
```

Встановлення засобів розробки забезпечує необхідні залежності збірки:

```bash
sudo dnf groupinstall "Development Tools" -y
```

Пакет `kernel-devel` надає необхідні заголовки та інструменти для створення модулів ядра:

```bash
sudo dnf install kernel-devel-matched kernel-headers -y
```

## Встановлення драйверів NVIDIA

Після встановлення необхідних передумов настав час встановити драйвери Nvidia.

Додайте офіційний репозиторій Nvidia за допомогою такої команди:

```bash
sudo dnf config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/rhel10/$(uname -i)/cuda-rhel10.repo
```

Далі очистіть кеш репозиторію DNF:

```bash
sudo dnf clean expire-cache
```

Нарешті, встановіть найновіший драйвер NVIDIA для вашої системи. Для відкритих модулів ядра виконайте:

```bash
sudo dnf install nvidia-open -y
```

Для власницьких модулів ядра виконайте:

```bash
sudo dnf install cuda-drivers -y
```

## Вимкнення Nouveau

Nouveau — це драйвер NVIDIA з відкритим вихідним кодом, який надає обмежену функціональність порівняно з пропрієтарними драйверами NVIDIA. Найкраще відключити його, щоб уникнути конфліктів драйверів:

```bash
sudo grubby --args="nouveau.modeset=0 rd.driver.blacklist=nouveau" --update-kernel=ALL
```

!!! Note "Примітка"

````
Для систем із увімкненим безпечним завантаженням вам потрібно виконати цей крок:

```bash
sudo mokutil --import /var/lib/dkms/mok.pub
```

Команда `mokutil` запропонує вам створити пароль, який використовуватиметься під час перезавантаження.

Після перезавантаження ваша система має запитати вас, чи хочете ви зареєструвати ключ або щось подібне; скажіть «yes», і він запитає пароль, який ви вказали в команді `mokutil`.
````

Перезавантаження:

```bash
sudo reboot now
```

## Висновок

Ви встановили драйвери NVIDIA GPU у своїй системі за допомогою офіційного репозиторію NVIDIA. Насолоджуйтесь розширеними можливостями графічного процесора NVIDIA, які не можуть надати стандартні драйвери Nouveau.
