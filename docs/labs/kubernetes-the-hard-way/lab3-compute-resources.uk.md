---
author: Wale Soyinka
contributors: Steven Spencer
tags:
  - kubernetes
  - k8s
  - лабораторна вправа
---

# Лабораторна робота 3: Надання обчислювальних ресурсів

!!! info

    Це гілка розгалуження від оригінальної ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way), Келсі Хайтауера (GitHub: kelseyhightower). На відміну від оригіналу, який базується на дистрибутивах, подібних до Debian, для архітектури ARM64, ця гілка націлена на дистрибутиви Enterprise Linux, такі як Rocky Linux, який працює на архітектурі x86_64.

Для Kubernetes потрібен набір машин для розміщення площини керування Kubernetes і робочих вузлів, де зрештою запускаються контейнери. У цій лабораторній роботі ви надасте машини, необхідні для налаштування кластера Kubernetes.

## Машинна база даних

Цей підручник використовуватиме текстовий файл, який слугуватиме машинною базою даних, щоб зберігати різні атрибути машини, які ви використовуватимете під час налаштування рівня керування Kubernetes і робочих вузлів. Наступна схема представляє записи в машинній базі даних, один запис на рядок:

```text
IPV4_ADDRESS FQDN HOSTNAME POD_SUBNET
```

Кожен стовпець відповідає IP-адресі машини `IPV4_ADDRESS`, повному доменному імені `FQDN`, імені хосту `HOSTNAME` та IP-підмережі `POD_SUBNET`. Kubernetes призначає одну IP-адресу кожному «pod», а «POD_SUBNET» представляє унікальний діапазон IP-адрес, призначений кожній машині в кластері для цього.

Ось приклад машинної бази даних, подібної до тієї, що використовувалася під час створення цього посібника. Зверніть увагу на приховані IP-адреси. Ви можете призначити будь-яку IP-адресу своїм машинам за умови, що кожна машина доступна один одному та «jumpbox».

```bash
cat machines.txt
```

```text
XXX.XXX.XXX.XXX server.kubernetes.local server  
XXX.XXX.XXX.XXX node-0.kubernetes.local node-0 10.200.0.0/24
XXX.XXX.XXX.XXX node-1.kubernetes.local node-1 10.200.1.0/24
```

Тепер ваша черга створити файл `machines.txt` з деталями для трьох машин, які ви використовуватимете для створення свого кластера Kubernetes. Скористайтеся наведеною вище прикладом бази даних машин і додайте деталі для своїх машин.

## Налаштування SSH доступу

Ви будете використовувати SSH для налаштування машин у кластері. Переконайтеся, що у вас є `кореневий` доступ SSH до кожної машини, зазначеної в базі даних вашої машини. Вам може знадобитися ввімкнути кореневий доступ SSH на кожному вузлі, оновивши файл `sshd_config` і перезапустивши сервер SSH.

### Увімкніть кореневий доступ SSH

Ви можете пропустити цей розділ, якщо у вас є `кореневий` доступ SSH для кожної з ваших машин.

Нова інсталяція `Rocky Linux` вимикає доступ SSH для користувача `root` за умовчанням. Це з міркувань безпеки, оскільки користувач `root` має повний адміністративний контроль над Unix-подібними системами. Слабкі паролі жахливі для машин, підключених до Інтернету. Як згадувалося раніше, ви ввімкнете «кореневий» доступ через SSH, щоб спростити кроки в цьому посібнику. Безпека – це компроміс; у цьому випадку ви оптимізуєтеся для зручності.

Увійдіть на кожну машину за допомогою SSH і свого облікового запису користувача, а потім перейдіть на `root` користувача за допомогою команди `su`:

```bash
su - root
```

Відредагуйте файл конфігурації демона SSH `/etc/ssh/sshd_config` і встановіть для параметра `PermitRootLogin` значення `yes`:

```bash
sed -i \
  's/^#PermitRootLogin.*/PermitRootLogin yes/' \
  /etc/ssh/sshd_config
```

Перезапустіть сервер SSH `sshd`, щоб отримати оновлений файл конфігурації:

```bash
systemctl restart sshd
```

### Створення та розповсюдження ключів SSH

Тут ви згенеруєте та розповсюдите пару ключів SSH на машини `server`, `node-0` і `node-1, які ви використовуватимете для виконання команд на цих машинах протягом цього підручника. Виконайте наступні команди з машини `jumpbox\`.

Згенеруйте новий ключ SSH:

```bash
ssh-keygen
```

Натисніть ++enter++, щоб прийняти всі значення за замовчуванням для запитів тут:

```text
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /root/.ssh/id_rsa
Your public key has been saved in /root/.ssh/id_rsa.pub
```

Скопіюйте відкритий ключ SSH на кожну машину:

```bash
while read IP FQDN HOST SUBNET; do 
  ssh-copy-id root@${IP}
done < machines.txt
```

Додавши кожен ключ, переконайтеся, що доступ до відкритого ключа SSH працює:

```bash
while read IP FQDN HOST SUBNET; do 
  ssh -n root@${IP} uname -o -m
done < machines.txt
```

```text
x86_64 GNU/Linux
x86_64 GNU/Linux
x86_64 GNU/Linux
```

## Імена хостів

У цьому розділі ви призначите імена хостів машинам `server`, `node-0` і `node-1`. Ви використовуватимете ім’я хоста під час виконання команд із `jumpbox` для кожної машини. Ім'я хоста також відіграє важливу роль у кластері. Замість використання IP-адреси для видачі команд серверу API Kubernetes клієнти Kubernetes використовуватимуть ім’я хоста `server`. Кожна робоча машина також використовує імена хостів «node-0» і «node-1» під час реєстрації в певному кластері Kubernetes.

Щоб налаштувати ім’я хоста для кожного комп’ютера, виконайте наступні команди в `jumpbox`.

Встановіть ім’я хоста для кожної машини, зазначеної у файлі `machines.txt`:

```bash
while read IP FQDN HOST SUBNET; do
    ssh -n root@${IP} cp /etc/hosts /etc/hosts.bak 
    CMD="sed -i 's/^127.0.0.1.*/127.0.0.1\t${FQDN} ${HOST}/' /etc/hosts"
    ssh -n root@${IP} "$CMD"
    ssh -n root@${IP} hostnamectl hostname ${HOST}
done < machines.txt
```

Перевірте ім’я хоста, налаштоване на кожній машині:

```bash
while read IP FQDN HOST SUBNET; do
  ssh -n root@${IP} hostname --fqdn
done < machines.txt
```

```text
server.kubernetes.local
node-0.kubernetes.local
node-1.kubernetes.local
```

## Таблиця пошуку хостів

У цьому розділі ви згенеруєте файл `hosts` і додасте його до файлу `/etc/hosts` у `jumpbox` і до файлів `/etc/hosts` на всіх трьох членах кластера, які використовуються для цього посібника. Це дозволить кожній машині бути доступною за допомогою імені хоста, наприклад `server`, `node-0` або `node-1`.

Створіть новий файл `hosts` і додайте заголовок, щоб визначити додані машини:

```bash
echo "" > hosts
echo "# Kubernetes The Hard Way" >> hosts
```

Згенеруйте запис хоста для кожної машини у файлі `machines.txt` і додайте його до файлу `hosts`:

```bash
while read IP FQDN HOST SUBNET; do 
    ENTRY="${IP} ${FQDN} ${HOST}"
    echo $ENTRY >> hosts
done < machines.txt
```

Перегляньте записи хостів у файлі `hosts`:

```bash
cat hosts
```

```text

# Kubernetes The Hard Way
XXX.XXX.XXX.XXX server.kubernetes.local server
XXX.XXX.XXX.XXX node-0.kubernetes.local node-0
XXX.XXX.XXX.XXX node-1.kubernetes.local node-1
```

## Додавання записів `/etc/hosts` до локальної машини

У цьому розділі ви додасте записи DNS із файлу `hosts` до локального файлу `/etc/hosts` на вашій машині `jumpbox`.

Додайте записи DNS із `hosts` до `/etc/hosts`:

```bash
cat hosts >> /etc/hosts
```

Перевірте оновлення файлу `/etc/hosts`:

```bash
cat /etc/hosts
```

```text
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

# Kubernetes The Hard Way
XXX.XXX.XXX.XXX server.kubernetes.local server
XXX.XXX.XXX.XXX node-0.kubernetes.local node-0
XXX.XXX.XXX.XXX node-1.kubernetes.local node-1
```

Ви повинні мати можливість SSH для кожної машини, зазначеної у файлі `machines.txt`, використовуючи ім’я хоста.

```bash
for host in server node-0 node-1
   do ssh root@${host} uname -o -m -n
done
```

```text
server x86_64 GNU/Linux
node-0 x86_64 GNU/Linux
node-1 x86_64 GNU/Linux
```

## Додавання записів `/etc/hosts` до віддалених машин

У цьому розділі ви додасте записи хостів із `hosts` до `/etc/hosts` на кожній машині, указаній у текстовому файлі `machines.txt`.

Скопіюйте файл `hosts` на кожну машину та додайте його вміст до `/etc/hosts`:

```bash
while read IP FQDN HOST SUBNET; do
  scp hosts root@${HOST}:~/
  ssh -n \
    root@${HOST} "cat hosts >> /etc/hosts"
done < machines.txt
```

Ви можете використовувати імена хостів під час підключення до комп’ютерів зі свого комп’ютера «jumpbox» або будь-якого з трьох комп’ютерів у кластері Kubernetes. Замість використання IP-адрес тепер ви можете підключатися до машин за допомогою імені хоста, наприклад `server`, `node-0` або `node-1`.

Далі: [Надання ЦС і генерація сертифікатів TLS](lab4-certificate-authority.md)
