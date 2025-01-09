---
title: OpenVPN
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.4
tags:
  - безпека
  - vpn
---

## Вступ

[OpenVPN](https://openvpn.net/) — це безкоштовна віртуальна приватна мережа (VPN) із відкритим кодом. Ця стаття допоможе вам налаштувати OpenVPN з інфраструктурою відкритих ключів X509 (PKI). Для цього посібника потрібна система Rocky Linux із загальнодоступною IP-адресою, оскільки OpenVPN працює за моделлю клієнт/сервер. Найпростіший спосіб досягти цього — розгорнути віртуальний приватний сервер (VPS) через хмарного постачальника за вашим вибором. На момент написання статті Google Cloud Platform пропонує безкоштовний рівень для своїх екземплярів e2-micro. Якщо ви шукаєте найпростіше налаштування OpenVPN за допомогою VPN типу «точка-точка» (p2p) без PKI, зверніться до [Static Key Mini-HOWTO](https://openvpn.net/community-resources/static-key-mini-howto/).

## Передумови та припущення

Мінімальні вимоги до цієї процедури:

- Можливість запускати команди від імені користувача root або використовувати `sudo` для підвищення привілеїв.
- Система Rocky Linux із загальнодоступною IP-адресою

## Встановлення OpenVPN

Встановіть репозиторій Extra Packages for Enterprise Linux (EPEL):

```bash
sudo dnf install epel-release -y
```

Встановлення OpenVPN:

```bash
sudo dnf install openvpn -y
```

## Налаштування центра сертифікації

Встановлення easy-rsa:

```bash
sudo dnf install easy-rsa -y
```

Створіть каталог `easy-rsa` в `/etc/openvpn`:

```bash
sudo mkdir /etc/openvpn/easy-rsa
```

Створіть символічне посилання на файли easy-rsa:

```bash
sudo ln -s /usr/share/easy-rsa /etc/openvpn/easy-rsa
```

Змініть каталог на `/etc/openvpn/easy-rsa`:

```bash
cd /etc/openvpn/easy-rsa
```

Запустіть сценарій `easyrsa` з параметром `init-pki`, щоб ініціалізувати PKI центру сертифікації:

```bash
sudo ./easy-rsa/3/easyrsa init-pki
```

Запустіть сценарій `easyrsa` з параметрами `build-ca` і `nopass`, щоб створити центр сертифікації без пароля:

```bash
sudo ./easy-rsa/3/easyrsa build-ca nopass
```

## Створення сертифікатів

Запустіть сценарій `easyrsa` з параметрами `gen-req` і `nopass`, щоб створити сертифікат сервера без пароля:

```bash
sudo ./easy-rsa/3/easyrsa gen-req server nopass
```

Запустіть сценарій `easyrsa` з параметрами `sign-req` і `server`, щоб підписати сертифікат сервера:

```bash
sudo ./easy-rsa/3/easyrsa sign-req server server
```

!!! Note "Примітка"

```
Ви можете повторити наведені нижче кроки стільки разів, скільки потрібно для додаткових клієнтів.
```

Запустіть сценарій `easyrsa` з параметрами `gen-req` і `nopass`, щоб створити клієнтські сертифікати без пароля:

```bash
sudo ./easy-rsa/3/easyrsa gen-req client1 nopass
```

Запустіть сценарій `easyrsa` з параметрами `sign-req` і `client`, щоб підписати клієнтські сертифікати без пароля:

```bash
sudo ./easy-rsa/3/easyrsa sign-req client client1
```

OpenVPN вимагає параметрів Diffie Hellman. Виконайте цю команду, щоб згенерувати їх:

```bash
sudo ./easy-rsa/3/easyrsa gen-dh
```

## Налаштування OpenVPN

Після завершення створення PKI настав час налаштувати OpenVPN.

Скопіюйте файл зразка `server.conf` до `/etc/openvpn`:

```bash
sudo cp /usr/share/doc/openvpn/sample/sample-config-files/server.conf /etc/openvpn
```

Використовуйте обраний редактор, щоб відкрити та записати в `server.conf`:

```bash
sudo vim /etc/openvpn/server.conf
```

Далі потрібно додати шляхи до файлів центру сертифікації, сертифіката сервера та ключа сервера до файлу конфігурації сервера OpenVPN.

Скопіюйте та вставте шляхи до файлів для ключів і сертифікатів у рядках 78-80:

!!! Note "Примітка"

```
У Vim ви можете додати номери рядків до вашого поточного редагування за допомогою `:set nu`
```

```bash
ca /etc/openvpn/easy-rsa/pki/ca.crt
cert /etc/openvpn/easy-rsa/pki/issued/server.crt
key /etc/openvpn/easy-rsa/pki/private/server.key  # This file should be kept secret
```

Скопіюйте та вставте шлях до файлу Diffie Hellman у рядок 85 зразка файлу `server.conf`:

```bash
dh /etc/openvpn/easy-rsa/pki/dh.pem
```

OpenVPN використовує SSL за замовчуванням, але за бажанням може використовувати TLS. Цей посібник використовує SSL.

Закоментуйте значення пари ключів `tls-auth ta.key` у рядку 244:

```bash
#tls-auth ta.key 0 # This file is secret
```

Збережіть перед закриттям `server.conf`.

## Налаштування брандмауера

OpenVPN за замовчуванням працює на порту UDP 1194. Ви будете використовувати `firewalld`, щоб дозволити трафіку OpenVPN надходити на сервер.

Встановлення `firewalld`:

```bash
sudo dnf install firewalld -y
```

Увімкнення `firewalld`:

```bash
sudo systemctl enable --now firewalld
```

Дозвольте OpenVPN через брандмауер, додавши його як службу:

```bash
sudo firewall-cmd --add-service=openvpn --permanent
```

Увімкніть трансляцію мережевих адрес (NAT) і приховайте публічні IP-адреси клієнтів, додавши правило маскараду до брандмауера:

```bash
sudo firewall-cmd --add-masquerade --permanent
```

Перезавантажте брандмауер:

```bash
sudo firewall-cmd --reload
```

## Налаштування маршрутизації

Дозвольте IP-переадресацію за допомогою такої команди:

```bash
sudo sysctl -w net.ipv4.ip_forward=1
```

## Запуск сервера OpenVPN

Відповідно до [документації OpenVPN](https://openvpn.net/community-resources/how-to/#starting-up-the-vpn-and-testing-for-initial-connectivity), "найкраще спочатку запустити Сервер OpenVPN з командного рядка":

```bash
sudo openvpn /etc/openvpn/server.conf
```

Після запуску OpenVPN натисніть `Ctrl + Z`, а потім відправте завдання у фоновий режим:

```bash
bg
```

## Налаштування та запуск клієнта

Окрім сервера, для роботи потрібно встановити OpenVPN на всіх клієнтах. Установіть OpenVPN на клієнті, якщо ви ще цього не зробили:

```bash
sudo dnf install openvpn -y
```

Створіть нові каталоги для зберігання ключів клієнта, сертифікатів і файлу конфігурації:

```bash
sudo mkdir -p /etc/openvpn/pki`
```

Тепер скопіюйте ключі та сертифікати за допомогою безпечного транспортного засобу та помістіть їх у папку `/etc/openvpn/pki`. Це можна зробити за допомогою протоколів SFTP або SCP. Перегляньте посібник Rocky Linux [відкритий і закритий ключ SSH](https://docs.rockylinux.org/guides/security/ssh_public_private_keys/), щоб налаштувати доступ SSH.

Це необхідні сертифікати та ключі, необхідні для конфігурації клієнта та їхніх шляхів до файлів на сервері:

- ca.crt
- client1.crt
- client1.key

Після збереження необхідних сертифікатів і ключів у `/etc/openvpn/pki` скопіюйте зразок файлу `client.conf` до `/etc/openvpn`:

```bash
sudo cp /usr/share/doc/openvpn/sample/sample-config-files/client.conf /etc/openvpn
```

Відкрийте `client.conf` за допомогою редактора на ваш вибір:

```bash
sudo vim /etc/openvpn/client.conf`
```

Зіставте шляхи файлів необхідних сертифікатів і ключів до файлу конфігурації клієнта. Ви можете зробити це, скопіювавши та вставивши рядки тексту в рядки 88-90 файлу зразка:

```bash
ca /etc/openvpn/pki/ca.crt
cert /etc/openvpn/pki/client1.crt
key /etc/openvpn/pki/client1.key
```

Вам також потрібно буде встановити ім’я хоста або IP-адресу сервера. Ви можете залишити стандартний UDP-порт 1194. У файлі зразка це в рядку 42:

```bash
remote server 1194
```

Збережіть перед виходом з `client.conf`.

Запустіть OpenVPN на клієнті:

```bash
sudo openvpn /etc/openvpn/client.conf
```

Після запуску OpenVPN натисніть `Ctrl + Z` і відправте завдання у фоновий режим:

```bash
bg
```

Виконайте команду нижче, щоб переглянути завдання, що виконуються у фоновому режимі:

```bash
jobs
```

Надішліть тестовий пінг на сервер. За умовчанням його приватна адреса `10.8.0.1`:

```bash
ping 10.8.0.1
```

## Висновок

Тепер у вас має бути запущений власний сервер OpenVPN! За допомогою цієї базової конфігурації ви забезпечили приватний тунель для зв’язку ваших систем через ширший Інтернет. Однак OpenVPN можна налаштувати, і цей посібник залишає багато чого для уяви. Ви можете глибше вивчити OpenVPN, відвідавши їхній [веб-сайт](https://www.openvpn.net). Ви також можете дізнатися більше про OpenVPN прямо у вашій системі - `man openvpn` - за допомогою сторінки довідки.
