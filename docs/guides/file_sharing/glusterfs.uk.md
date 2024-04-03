---
title: Кластеризація - GlusterFS
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
update: 11 лютого 2022 р
---

# Кластер високої доступності з GlusterFS

## Передумови

- Вміння працювати з редактором командного рядка (у цьому прикладі використовується *vi*)
- Високий рівень комфорту з видачею команд із командного рядка, переглядом журналів та іншими загальними обов’язками системного адміністратора
- Усі команди виконуються від імені користувача root або sudo

## Вступ

GlusterFS — це розподілена файлова система.

Це дозволяє зберігати великі обсяги даних, розподілених між кластерами серверів з дуже високою доступністю.

Він складається з серверної частини, яка встановлюється на всіх вузлах серверних кластерів.

Клієнти можуть отримати доступ до даних через клієнт `glusterfs` або команду `mount`.

GlusterFS може працювати в двох режимах:

- реплікований режим: кожен вузол кластера має всі дані.
- розподілений режим: без надмірності даних. Якщо сховище виходить з ладу, дані на несправному вузлі втрачаються.

Обидва режими можна використовувати разом, щоб забезпечити репліковану та розподілену файлову систему, якщо у вас є правильна кількість серверів.

Дані зберігаються всередині блоків.

> Brick — це основна одиниця зберігання в GlusterFS, представлена каталогом експорту на сервері в довіреному пулі зберігання.

## Тестова платформа

Наша фіктивна платформа складається з двох серверів і клієнта, всі сервери Rocky Linux.

- Перший вузол: node1.cluster.local - 192.168.1.10
- Другий вузол: node2.cluster.local - 192.168.1.11
- Клієнт1: клієнт1.клієнти.локальний - 192.168.1.12

!!! Note "Примітка"

    Переконайтеся, що у вас є необхідна пропускна здатність між серверами кластера.

Кожен сервер у кластері має другий диск для зберігання даних.

## Підготовка дисків

Ми створимо новий логічний том LVM, який буде змонтовано на `/data/glusterfs/vol0` на обох серверах кластера:

```bash
sudo pvcreate /dev/sdb
sudo vgcreate vg_data /dev/sdb
sudo lvcreate -l 100%FREE -n lv_data vg_data
sudo mkfs.xfs /dev/vg_data/lv_data
sudo mkdir -p /data/glusterfs/volume1
```

!!! Note "Примітка"

    Якщо LVM недоступний на ваших серверах, інсталюйте його за допомогою наступної команди:

    ```
    sudo dnf install lvm2
    ```

Тепер ми можемо додати цей логічний том до файлу `/etc/fstab`:

```bash
/dev/mapper/vg_data-lv_data /data/glusterfs/volume1        xfs     defaults        1 2
```

І змонтуйте його:

```bash
sudo mount -a
```

Оскільки дані зберігаються у підтомі, який називається цеглиною, ми можемо створити каталог у цьому новому просторі даних, призначеному для них:

```bash
sudo mkdir /data/glusterfs/volume1/brick0
```

## Інсталяція

На момент написання цієї документації оригінальний репозиторій CentOS Storage SIG більше не доступний, а репозиторій RockyLinux ще не доступний.

Проте ми будемо використовувати (поки що) архівну версію.

Перш за все, необхідно додати спеціальний репозиторій до gluster (у версії 9) на обох серверах:

```bash
sudo dnf install centos-release-gluster9
```

!!! Note "Примітка"

    Пізніше, коли він буде готовий на стороні Rocky, ми зможемо змінити назву цього пакета.

Оскільки список сховищ і URL-адреса більше не доступні, давайте змінимо вміст `/etc/yum.repos.d/CentOS-Gluster-9.repo`:

```bash
[centos-gluster9]
name=CentOS-$releasever - Gluster 9
#mirrorlist=http://mirrorlist.centos.org?arch=$basearch&release=$releasever&repo=storage-gluster-9
baseurl=https://dl.rockylinux.org/vault/centos/8.5.2111/storage/x86_64/gluster-9/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Storage
```

Тепер ми готові встановити сервер glusterfs:

```bash
sudo dnf install glusterfs glusterfs-libs glusterfs-server
```

## Правила брандмауера

Для роботи сервісу необхідно дотримуватися кількох правил:

```bash
sudo firewall-cmd --zone=public --add-service=glusterfs --permanent
sudo firewall-cmd --reload
```

або:

```bash
sudo firewall-cmd --zone=public --add-port=24007-24008/tcp --permanent
sudo firewall-cmd --zone=public --add-port=49152/tcp --permanent
sudo firewall-cmd --reload
```

## Роздільна здатність імен

Ви можете дозволити DNS виконувати розпізнавання імен серверів у вашому кластері, або ви можете звільнити сервери від цього завдання, вставивши записи для кожного з них у ваші файли `/etc/hosts`. Це також забезпечить роботу навіть під час збою DNS.

```text
192.168.10.10 node1.cluster.local
192.168.10.11 node2.cluster.local
```

## Запуск служби

Не зволікаючи, запустимо службу:

```bash
sudo systemctl enable glusterfsd.service glusterd.service
sudo systemctl start glusterfsd.service glusterd.service
```

Ми готові об’єднати два вузли в одному пулі.

Цю команду потрібно виконати лише один раз на одному вузлі (тут на node1):

```bash
sudo gluster peer probe node2.cluster.local
peer probe: success
```

Підтвердити:

```bash
node1 $ sudo gluster peer status
Number of Peers: 1

Hostname: node2.cluster.local
Uuid: c4ff108d-0682-43b2-bc0c-311a0417fae2
State: Peer in Cluster (Connected)
Other names:
192.168.10.11

```

```bash
node2 $ sudo gluster peer status
Number of Peers: 1

Hostname: node1.cluster.local
Uuid: 6375e3c2-4f25-42de-bbb6-ab6a859bf55f
State: Peer in Cluster (Connected)
Other names:
192.168.10.10
```

Тепер ми можемо створити том із 2 репліками:

```bash
$ sudo gluster volume create volume1 replica 2 node1.cluster.local:/data/glusterfs/volume1/brick0/ node2.cluster.local:/data/glusterfs/volume1/brick0/
Replica 2 volumes are prone to split-brain. Щоб уникнути цього, використовуйте Arbiter або Replica 3. Див.: https://docs.gluster.org/en/latest/Administrator-Guide/Split-brain-and-ways-to-deal-with-it/.
Do you still want to continue?
 (y/n) y
volume create: volume1: success: please start the volume to access data
```

!!! Note "Примітка"

    Як говорить команда return, кластер із 2 вузлами — не найкраща ідея проти розщепленого мозку у світі. Але цього буде достатньо для нашої тестової платформи.

Тепер ми можемо запустити том для доступу до даних:

```bash
sudo gluster volume start volume1

volume start: volume1: success
```

Перевірте стан гучності:

```bash
$ sudo gluster volume status
Status of volume: volume1
Gluster process                             TCP Port  RDMA Port  Online  Pid
------------------------------------------------------------------------------
Brick node1.cluster.local:/data/glusterfs/v
olume1/brick0                               49152     0          Y       1210
Brick node2.cluster.local:/data/glusterfs/v
olume1/brick0                               49152     0          Y       1135
Self-heal Daemon on localhost               N/A       N/A        Y       1227
Self-heal Daemon on node2.cluster.local     N/A       N/A        Y       1152

Task Status of Volume volume1
------------------------------------------------------------------------------
There are no active volume tasks
```

```bash
$ sudo gluster volume info

Volume Name: volume1
Type: Replicate
Volume ID: f51ca783-e815-4474-b256-3444af2c40c4
Status: Started
Snapshot Count: 0
Number of Bricks: 1 x 2 = 2
Transport-type: tcp
Bricks:
Brick1: node1.cluster.local:/data/glusterfs/volume1/brick0
Brick2: node2.cluster.local:/data/glusterfs/volume1/brick0
Options Reconfigured:
cluster.granular-entry-heal: on
storage.fips-mode-rchecksum: on
transport.address-family: inet
nfs.disable: on
performance.client-io-threads: off
```

Статус повинен бути «Started».

Ми вже можемо трохи обмежити доступ до тому:

```bash
sudo gluster volume set volume1 auth.allow 192.168.10.*
```

Це так просто.

## Доступ клієнтів

Є кілька способів отримати доступ до наших даних від клієнта.

Переважний метод:

```bash
sudo dnf install glusterfs-client
sudo mkdir /data
sudo mount.glusterfs node1.cluster.local:/volume1 /data
```

Немає додаткових репозиторіїв для налаштування. Клієнт уже присутній у базовому репо.

Створіть файл і переконайтеся, що він присутній на всіх вузлах кластера:

На клієнті:

```bash
sudo touch /data/test
```

На обох серверах:

```bash
$ ll /data/glusterfs/volume1/brick0/
total 0
-rw-r--r--. 2 root root 0 Feb  3 19:21 test
```

Звучить добре! Але що станеться, якщо вузол 1 виходить з ладу? Саме він був вказаний при монтуванні віддаленого доступу.

Давайте зупинимо вузол один:

```bash
sudo shutdown -h now
```

Перевірте статус на node2:

```bash
$ sudo gluster peer status
Number of Peers: 1

Hostname: node1.cluster.local
Uuid: 6375e3c2-4f25-42de-bbb6-ab6a859bf55f
State: Peer in Cluster (Disconnected)
Other names:
192.168.10.10
[antoine@node2 ~]$ sudo gluster volume status
Status of volume: volume1
Gluster process                             TCP Port  RDMA Port  Online  Pid
------------------------------------------------------------------------------
Brick node2.cluster.local:/data/glusterfs/v
olume1/brick0                               49152     0          Y       1135
Self-heal Daemon on localhost               N/A       N/A        Y       1152

Task Status of Volume volume1
------------------------------------------------------------------------------
There are no active volume tasks
```

Node1 відсутній.

І на клієнті:

```bash
$ ll /data/test
-rw-r--r--. 1 root root 0 Feb  4 16:41 /data/test
```

Файл уже є.

Після підключення клієнт glusterfs отримує список вузлів, до яких він може звертатися, що пояснює прозоре перемикання, свідками якого ми щойно стали.

## Висновки

Хоча поточних сховищ немає, використання архівних сховищ, які були в CentOS для GlusterFS, все одно працюватиме. Як було зазначено, GlusterFS досить легко встановити та підтримувати. Використання інструментів командного рядка є досить простим процесом. GlusterFS допоможе створити та підтримувати кластери високої доступності для зберігання та резервування даних. Ви можете знайти більше інформації про GlusterFS і використання інструменту на [сторінках офіційної документації.](https://docs.gluster.org/en/latest/)
