---
title: 4. Розширене забезпечення
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - cloud-init
  - rocky linux
  - cloud
  - automation
  - networking
---

## Мережа та багатокомпонентні корисні навантаження

У попередньому розділі ви опанували основні модулі `cloud-init` для керування користувачами, пакетами та файлами. Тепер ви можете декларативно створити добре налаштований сервер. Зараз саме час дослідити більш просунуті методи, які надають вам ще більший контроль над конфігурацією вашого екземпляра.

У цьому розділі розглядаються дві важливі та складні теми:

1. Декларативна конфігурація мережі: Як вийти за рамки DHCP та визначити статичні конфігурації мережі для ваших екземплярів.
2. Багатокомпонентні MIME-корисні навантаження: Як об'єднати різні типи даних користувача, такі як скрипти оболонки та файли `#cloud-config`, в одне потужне корисне навантаження.

## 1) Декларативна конфігурація мережі

За замовчуванням конфігурація більшості хмарних образів передбачає отримання IP-адреси через DHCP. Хоча це зручно, багато виробничих середовищ вимагають, щоб сервери мали передбачувані статичні IP-адреси. Система конфігурації мережі `cloud-init` забезпечує платформо-незалежний, декларативний спосіб керування цим.

Специфікація конфігурації мережі знаходиться в окремому документі YAML, окремо від вашого основного `#cloud-config`. `cloud-init` обробляє обидва з одного файлу, використовуючи стандартний роздільник документів YAML (`---`) для їх розрізнення.

!!! note "Як `cloud-init` застосовує стан мережі"

    У Rocky Linux `cloud-init` не налаштовує мережеві інтерфейси безпосередньо. Натомість він діє як перекладач, перетворюючи свою мережеву конфігурацію у файли, які може зрозуміти **NetworkManager** (мережева служба за замовчуванням). Потім він передає керування NetworkManager для застосування конфігурації. Ви можете переглянути отримані профілі з'єднань у `/etc/NetworkManager/system-connections/`.

### Приклад 1: Налаштування однієї статичної IP-адреси

У цій вправі ми налаштуємо нашу віртуальну машину зі статичною IP-адресою, шлюзом за замовчуванням та власними DNS-серверами.

1. **Створити `user-data.yml`:**

   Цей файл містить два окремі документи YAML, розділені символом `---`. Перший — це наш стандартний `#cloud-config`. Другий визначає стан мережі.

    ```bash
    cat <<EOF > user-data.yml
    #cloud-config
    # We can still include standard modules.
    # Let's install a network troubleshooting tool.
    packages:
      - traceroute
    
    ---
    
    # This second document defines the network configuration.
    network:
      version: 2
      ethernets:
        eth0:
          dhcp4: no
          addresses:
            - 192.168.122.100/24
          gateway4: 192.168.122.1
          nameservers:
            addresses: [8.8.8.8, 8.8.4.4]
    EOF
    ```

2. **Пояснення ключових директив:**

   - `network:`: Ключ верхнього рівня для конфігурації мережі.
   - `version: 2`: Вказує, що ми використовуємо сучасний синтаксис, подібний до Netplan.
   - `ethernets:`: Словник фізичних мережевих інтерфейсів для налаштування, ключ якого дається за назвою інтерфейсу (наприклад, `eth0`).
   - `dhcp4: no`: Вимикає IPv4 DHCP на цьому інтерфейсі.
   - `addresses`: Список статичних IP-адрес для призначення, зазначених у нотації CIDR.
   - `gateway4`: Шлюз за замовчуванням для IPv4-трафіку.
   - `nameservers`: Словник, що містить список IP-адрес для розв'язання DNS.

3. **Завантаження та перевірка:**

   Цього разу перевірка відрізняється, оскільки віртуальна машина не отримає динамічної IP-адреси. Ви повинні підключитися до консолі віртуальної машини безпосередньо.

    ```bash
    # Use a new disk image for this exercise
    qemu-img create -f qcow2 -F qcow2 -b Rocky-10-GenericCloud.qcow2 static-ip-vm.qcow2
    
    virt-install --name rocky10-static-ip \
    --memory 2048 --vcpus 2 \
    --disk path=static-ip-vm.qcow2,format=qcow2 \
    --cloud-init user-data=user-data.yml,hostname=network-server \
    --os-variant rockylinux10 \
    --import --noautoconsole
    
    # Connect to the virtual console
    virsh console rocky10-static-ip
    
    # Once logged in, check the IP address
    [rocky@network-server ~]$ ip a show eth0
    ```

   Вивід має показувати, що `eth0` має статичну IP-адресу `192.168.122.100/24`.

### Приклад 2: Конфігурація з кількома інтерфейсами

Типовим реальним сценарієм є сервер з кількома мережевими інтерфейсами. Тут ми створимо віртуальну машину з двома інтерфейсами: `eth0` використовуватиме DHCP, а `eth1` матиме статичну IP-адресу.

1. **Створіть `user-data.yml` для двох інтерфейсів:**

    ```bash
    cat <<EOF > user-data.yml
    #cloud-config
    packages: [iperf3]
    
    ---
    
    network:
      version: 2
      ethernets:
        eth0:
          dhcp4: yes
        eth1:
          dhcp4: no
          addresses: [192.168.200.10/24]
    EOF
    ```

2. **Завантаження віртуальної машини з двома мережевими картами:** Ми додаємо другий прапорець `--network` до команди `virt-install`.

    ```bash
    virt-install --name rocky10-multi-nic \
    --memory 2048 --vcpus 2 \
    --disk path=... \
    --network network=default,model=virtio \
    --network network=default,model=virtio \
    --cloud-init user-data=user-data.yml,hostname=multi-nic-server \
    --os-variant rockylinux10 --import --noautoconsole
    ```

3. **Перевірка:** Підключіться через SSH до адреси, призначеної DHCP, на `eth0`, а потім перевірте статичну IP-адресу на `eth1` за допомогою `ip a show eth1`.

## 2) Об'єднання корисних навантажень за допомогою багатокомпонентного MIME

Іноді потрібно запустити скрипт налаштування _перед_ виконанням основних модулів `#cloud-config`. Багатокомпонентні файли MIME – це рішення, яке дозволяє об’єднувати різні типи контенту в одне впорядковане корисне навантаження.

Ви можете візуалізувати структуру MIME-файлу наступним чином:

```
+-----------------------------------------+
| Main Header (multipart/mixed; boundary) |
+-----------------------------------------+
|
| --boundary                              |
| +-------------------------------------+
| | Part 1 Header (e.g., text/x-shellscript)  |
| +-------------------------------------+
| | Part 1 Content (#/bin/sh...)        |
| +-------------------------------------+
|
| --boundary                              |
| +-------------------------------------+
| | Part 2 Header (e.g., text/cloud-config)   |
| +-------------------------------------+
| | Part 2 Content (#cloud-config...)   |
| +-------------------------------------+
|
| --boundary-- (closing)                  |
+-----------------------------------------+
```

### Практичний досвід: сценарій передпольотної перевірки

Ми створимо багаточастинний файл, який спочатку запускає скрипт оболонки, а потім переходить до основного `#cloud-config`.

1. **Створіть багатокомпонентний файл `user-data.mime`:**

   Це спеціально відформатований текстовий файл, який використовує рядок-"границю" для розділення частин.

    ```bash
    cat <<EOF > user-data.mime
    Content-Type: multipart/mixed; boundary="//"
    MIME-Version: 1.0
    
    --//
    Content-Type: text/x-shellscript; charset="us-ascii"
    
    #!/bin/sh
    echo "Running pre-flight checks..."
    # In a real script, you might check disk space or memory.
    # If checks failed, you could 'exit 1' to halt cloud-init.
    echo "Pre-flight checks passed." > /tmp/pre-flight-status.txt
    
    --//
    Content-Type: text/cloud-config; charset="us-ascii"
    
    #cloud-config
    packages:
        - htop
        runcmd:
          - [ sh, -c, "echo 'Main cloud-config ran successfully' > /tmp/main-config-status.txt" ]
    
    --//--
    EOF
    ```

       !!! note "Про межі MIME"

        ```
         Рядок межі (у цьому випадку `//`) – це довільний рядок, який не повинен з'являтися у вмісті жодної частини. Він використовується для розділення різних розділів файлу.
        ```

2. **Завантаження та перевірка:**

   Ви передаєте цей файл до `virt-install` так само, як і стандартний файл `user-data.yml`.

    ```bash
    # Use a new disk image
    qemu-img create -f qcow2 -F qcow2 -b Rocky-10-GenericCloud.qcow2 mime-vm.qcow2
    
    virt-install --name rocky10-mime-test \
    --memory 2048 --vcpus 2 \
    --disk path=mime-vm.qcow2,format=qcow2 \
    --cloud-init user-data=user-data.mime,hostname=mime-server \
    --os-variant rockylinux10 \
    --import --noautoconsole
    ```

   Після завантаження увійдіть до віртуальної машини через SSH та перевірте, чи обидві частини запрацювали, знайшовши створені ними файли:

    ```bash
    cat /tmp/pre-flight-status.txt
    cat /tmp/main-config-status.txt
    ```

!!! tip "Інші типи багаточастинного контенту"

    `cloud-init` підтримує інші типи контенту для складних випадків використання, такі як `text/cloud-boothook` для дуже ранніх скриптів завантаження або `text/part-handler` для запуску власного коду Python. Зверніться до офіційної документації для отримання додаткової інформації.

## Що далі

Ви вже вивчили дві потужні, просунуті методи «хмарної ініціалізації». Тепер ви можете визначати статичні мережі та керувати складними робочими процесами забезпечення ресурсів за допомогою багатокомпонентних користувацьких даних.

У наступному розділі ми змінимо нашу точку зору від _використання_ `cloud-init` для кожного екземпляра до _налаштування його поведінки за замовчуванням_ для створення власних попередньо налаштованих «золотих образів».
