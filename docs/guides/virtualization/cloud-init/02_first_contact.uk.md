---
title: 2. Перший контакт
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - cloud-init
  - cloud
  - automation
---

## Просте завантаження з образу Rocky Linux 10 QCOW2

У попередньому розділі ми розглянули основні концепції `cloud-init`. Зараз саме час перейти від теорії до практики. Цей розділ — ваше перше практичне завдання: ви візьмете офіційний образ Rocky Linux 10 Generic Cloud, надасте йому простий набір інструкцій і спостерігатимете, як він налаштовується під час першого завантаження.

## 1. Підготовка лабораторного середовища

Перш ніж ми зможемо завантажити наш перший екземпляр, нам потрібно підготувати наше локальне лабораторне середовище. Для цих вправ ми будемо моделювати хмарне середовище за допомогою стандартних інструментів віртуалізації Linux.

### Необхідні умови: інструменти хостингу

Переконайтеся, що на вашому хост-комп'ютері встановлено такі інструменти. На хості Rocky Linux ви можете встановити їх за допомогою `dnf`:

```bash
sudo dnf install -y libvirt qemu-kvm virt-install genisoimage
```

- **Гіпервізор віртуалізації**: інструмент, подібний до KVM/QEMU або VirtualBox.
- `virt-install`: Утиліта командного рядка для налаштування нових віртуальних машин.
- `genisoimage` (або `mkisofs`): Інструмент для створення файлової системи ISO9660.

### Образ QCOW2

Якщо ви ще цього не зробили, завантажте офіційний образ Rocky Linux 10 Generic Cloud.

```bash
curl -L -o Rocky-10-GenericCloud.qcow2 \
https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-GenericCloud-Base.latest.x86_64.qcow2
```

Щоб зберегти оригінал, створіть робочу копію образу для вашої віртуальної машини.

```bash
cp Rocky-10-GenericCloud.qcow2 first-boot-vm.qcow2
```

!!! tip "Збереження місця на диску за допомогою резервних файлів"

    Повна копія образу може бути великою. Щоб заощадити місце на диску, можна створити _зв'язаний клон_, який використовуватиме оригінальне образ як резервний файл. Це створить набагато менший файл `qcow2`, який зберігатиме лише відмінності від оригіналу.
    
    `bash     qemu-img create -f qcow2 -F qcow2 \     -b Rocky-10-GenericCloud.qcow2 first-boot-vm.qcow2     `

## 2. Спосіб 1: Джерело даних `NoCloud` (ISO)

Одним із найпоширеніших способів надання даних до `cloud-init` у локальному середовищі є джерело даних `NoCloud`. Цей метод вимагає пакування файлів конфігурації на віртуальний CD-ROM (ISO-файл), який `cloud-init` автоматично виявить та зчитає під час завантаження.

### Створення файлів конфігурації

1. **Створіть каталог для файлів конфігурації:**

    ```bash
    mkdir cloud-init-data
    ```

2. **Створіть файл `user-data`:** Цей файл є вашим основним набором інструкцій. Ми скористаємося heredoc `cat` для його створення.

    ```bash
    cat <<EOF > cloud-init-data/user-data
    #cloud-config
    hostname: cloud-rockstar-01
    runcmd:
      - [ sh, -c, "echo 'Hello from the cloud-init Final Stage!' > /root/boot_done.txt" ]
    EOF
    ```

3. **Створіть файл `meta-data`:** Цей файл надає контекст _про_ екземпляр. `instance-id` особливо важливий, оскільки `cloud-init` використовує його, щоб визначити, чи виконувалося це на цьому екземплярі раніше. Зміна ідентифікатора призведе до повторного запуску `cloud-init`.

    ```bash
    cat <<EOF > cloud-init-data/meta-data
    {
      "instance-id": "i-first-boot-01",
      "local-hostname": "cloud-rockstar-01"
    }
    EOF
    ```

4. **Згенеруйте ISO:** Використайте `genisoimage` для пакування файлів у `config.iso`. Мітка тому `-V cidata` — це чарівний ключ, який шукає `cloud-init`.

    ```bash
    genisoimage -o config.iso -V cidata -r -J cloud-init-data
    ```

### Завантаження та перевірка

1. **Запустіть віртуальну машину** за допомогою `virt-install`, приєднавши як образ віртуальної машини, так і `config.iso`.

    ```bash
    virt-install --name rocky10-iso-boot \
    --memory 2048 --vcpus 2 \
    --disk path=first-boot-vm.qcow2,format=qcow2 \
    --disk path=config.iso,device=cdrom \
    --os-variant rockylinux10 \
    --import --noautoconsole
    ```

2. **Знайдіть IP-адресу та підключіться через SSH.** Користувач за замовчуванням — `rocky`.

    ```bash
    virsh domifaddr rocky10-iso-boot
    ssh rocky@<IP_ADDRESS>
    ```

       !!! tip "Безпечний вхід за допомогою SSH-ключів"

        ```
         Підключення до користувача за замовчуванням зручне для швидкого лабораторного тесту, але це не безпечна практика. У наступному розділі ми розглянемо, як використовувати `cloud-init` для автоматичного введення вашого відкритого ключа SSH, що дозволяє безпечний вхід без пароля.
        ```

3. **Перевірте зміни:** Перевірте ім'я хоста та файл, створений командою `runcmd`.

    ```bash
    hostname
    sudo cat /root/boot_done.txt
    ```

## 3) Спосіб 2: Пряме впровадження за допомогою `virt-install`

Створення ISO-образу — це надійний метод, але для користувачів `libvirt` та `virt-install` існує набагато простіший спосіб. Прапорець `--cloud-init` дозволяє передавати `user-data` безпосередньо, дозволяючи `virt-install` автоматично створювати джерело даних.

### Спрощені `дані користувача`

Створіть простий файл `user-data.yml`. Ви навіть можете додати SSH-ключ превентивно.

```bash
cat <<EOF > user-data.yml
#cloud-config
users:
  - name: rocky
    ssh_authorized_keys:
      - <YOUR_SSH_PUBLIC_KEY>
EOF
```

### Завантаження та перевірка

1. **Запустіть віртуальну машину**, використовуючи прапорець `--cloud-init`. Зверніть увагу, що ми можемо встановити ім'я хоста тут безпосередньо.

    ```bash
    virt-install --name rocky10-direct-boot \
    --memory 2048 --vcpus 2 \
    --disk path=first-boot-vm.qcow2,format=qcow2 \
    --cloud-init user-data=user-data.yml,hostname=cloud-rockstar-02 \
    --os-variant rockylinux10 \
    --import --noautoconsole
    ```

2. **Знайдіть IP-адресу та підключіться.** Якщо ви додали свій SSH-ключ, ви зможете підключитися без пароля.

3. **Перевірте ім'я хоста.** Воно має бути `cloud-rockstar-02`.

Цей прямий метод часто швидший та зручніший для локальної розробки та тестування за допомогою `libvirt`.
