---
title: Автоматичне створення шаблону - Packer - Ansible - VMware vSphere
author: Antoine Le Morvan
contributors: Steven Spencer, Ryan Johnson, Pedro Garcia
---

# Автоматичне створення шаблону за допомогою Packer і розгортання за допомогою Ansible у середовищі VMware vSphere

**Знання**: :star: :star: :star:   
**Складність**: :star: :star: :star:

**Час читання**: 30 хвилин

## Передумови, припущення та загальні зауваження

* Доступне середовище vSphere і користувач із наданим доступом.
* Внутрішній веб-сервер для зберігання файлів.
* Веб-доступ до сховищ Rocky Linux.
* ISO Rocky Linux.
* Доступне середовище Ansible.
* Передбачається, що ви маєте певні знання про кожен згаданий продукт. Якщо ні, заглибтеся в цю документацію, перш ніж почати.
* Vagrant тут **не** використовується. Було зазначено, що з Vagrant буде надано ключ SSH, який не буде самопідписаним. Якщо ви хочете поглибити це, ви можете це зробити, але це не описано в цьому документі.

## Вступ

У цьому документі розповідається про створення шаблону віртуальної машини vSphere за допомогою Packer і про те, як розгорнути артефакт як нові віртуальні машини за допомогою Ansible.

## Можливі коригування

Звичайно, ви можете адаптувати цю інструкцію для інших гіпервізорів.

Хоча тут ми використовуємо мінімальний образ ISO, ви можете вибрати образ DVD (набагато більший і, можливо, завеликий) або завантажувальний образ (набагато менший і, можливо, замалий). Цей вибір за вами. Це, зокрема, впливає на пропускну здатність, яка потрібна для інсталяції, а отже, на час підготовки. Далі ми обговоримо вплив вибору за умовчанням і способи його усунення.

Ви також можете не перетворювати віртуальну машину на шаблон, у цьому випадку ви будете використовувати Packer для розгортання кожної нової віртуальної машини, що все ще цілком можливо (встановлення, починаючи з 0, займає менше 10 хвилин без участі людини).

## Packer

### Знайомство з Packer

Packer — це інструмент створення образів віртуальної машини з відкритим кодом, випущений за ліцензією MPL 2.0 і створений HashiCorp. Це допоможе вам автоматизувати процес створення образів віртуальних машин із попередньо налаштованими операційними системами та встановленим програмним забезпеченням з єдиної конфігурації джерела як у хмарі, так і в локальному віртуалізованому середовищі.

За допомогою Packer ви можете створювати зображення для використання на таких платформах:

* [Amazon Web Services](https://aws.amazon.com).
* [Azure](https://azure.microsoft.com).
* [GCP](https://cloud.google.com).
* [DigitalOcean](https://www.digitalocean.com).
* [OpenStack](https://www.openstack.org).
* [VirtualBox](https://www.virtualbox.org/).
* [VMware](https://www.vmware.com).

Ви можете переглянути ці ресурси для отримання додаткової інформації:

* [Веб-сайт Packer](https://www.packer.io/)
* [Документація Packer](https://www.packer.io/docs)
* [Документація](https://www.packer.io/docs/builders/vsphere/vsphere-iso) конструктора `vsphere-iso`

### Встановлення Packer

Є два способи встановити Packer у вашій системі Rocky Linux.

#### Встановлення Packer зі сховища HashiCorp

HashiCorp підтримує та підписує пакети для різних дистрибутивів Linux. Щоб установити Packer у нашій системі Rocky Linux, виконайте наступні кроки:


#### Завантажте та встановіть з веб-сайту Packer

1. Встановіть dnf-config-manager:

```bash
$ sudo dnf install -y dnf-plugins-core
```

2. Додайте репозиторій HashiCorp до доступних сховищ у нашій системі Rocky Linux:

```bash
$ sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
```

3. Інсталюйте Packer:

```bash
$ sudo dnf -y install packer
```

#### Завантажте та встановіть з веб-сайту Packer


Ви можете почати із завантаження двійкових файлів для своєї власної платформи за допомогою [завантажень Packer](https://www.packer.io/downloads).

1. На сторінці завантаження скопіюйте посилання для завантаження в розділі Linux Binary Download, яке відповідає архітектурі вашої системи.

2. З оболонки або терміналу завантажте його за допомогою інструменту `wget`:

```bash
$ wget https://releases.hashicorp.com/packer/1.8.3/packer_1.8.3_linux_amd64.zip
```
Буде завантажено файл .zip.

3.  Щоб розпакувати завантажений архів, виконайте наступну команду в оболонці:

```bash
$ unzip packer_1.8.3_linux_amd64.zip
```

!!! tip "Підказка"

    Якщо ви отримуєте повідомлення про помилку, і у вашій системі не встановлено програму для розпакування, ви можете встановити її, виконавши цю команду ```sudo dnf install unzip```.

4. Перемістіть програму Packer до папки bin:

```bash
$ sudo mv packer /usr/local/bin/
```

#### Перевірка правильності установки Packer

Якщо всі кроки попередніх процедур виконано правильно, ми можемо перейти до перевірки встановлення Packer у нашій системі.

Щоб переконатися, що Packer встановлено правильно, виконайте команду `packer`, і ви отримаєте результат, показаний нижче:

```bash
$ packer 
Usage: packer [--version] [--help] <command> [<args>]

Available commands are:
    build           build image(s) from template
    console         creates a console for testing variable interpolation
    fix             fixes templates from old versions of packer
    fmt             rewrites HCL2 config files to canonical format
    hcl2_upgrade    transform a JSON template into an HCL2 configuration
    init            install missing plugins or upgrade plugins
    inspect         see components of a template
    plugins         interact with Packer plugins and catalog
    validate        check that a template is valid
    version         prints the Packer version
```

### Створення шаблону за допомогою Packer

Передбачається, що ви перебуваєте в Linux для виконання наступних завдань.

Оскільки ми будемо підключатися до сервера VMware vCenter для надсилання наших команд через Packer, нам потрібно зберігати облікові дані поза файлами конфігурації, які ми створимо далі.

Давайте створимо прихований файл із нашими обліковими даними в нашому домашньому каталозі. Це файл json:

```
$ vim .vsphere-secrets.json {
    "vcenter_username": "rockstar",
    "vcenter_password": "mysecurepassword"
  }
```

Для цих облікових даних потрібен певний доступ до вашого середовища vSphere.

Створимо файл json (в майбутньому формат цього файлу зміниться на HCL):

```
{
  "variables": {
    "version": "0.0.X",
    "HTTP_IP": "fileserver.rockylinux.lan",
    "HTTP_PATH": "/packer/rockylinux/8/ks.cfg"
  },
  "sensitive-variables": ["vcenter_password"],
  "provisioners": [
    {
      "type": "shell",
      "expect_disconnect": true,
      "execute_command": "bash '{{.Path}}'",
      "script": "{{template_dir}}/scripts/requirements.sh"
    }
  ],
  "builders": [
    {
      "type": "vsphere-iso",
      "CPUs": 2,
      "CPU_hot_plug": true,
      "RAM": 2048,
      "RAM_hot_plug": true,
      "disk_controller_type": "pvscsi",
      "guest_os_type": "centos8_64Guest",
      "iso_paths": [
        "[datasyno-contentlibrary-mylib] contentlib-a86ad29a-a43b-4717-97e6-593b8358801b/3a381c78-b9df-45a6-82e1-3c07c8187dbe/Rocky-8.4-x86_64-minimal_72cc0cc6-9d0f-4c68-9bcd-06385a506a5d.iso"
      ],
      "network_adapters": [
        {
          "network_card": "vmxnet3",
          "network": "net_infra"
        }
      ],
      "storage": [
        {
          "disk_size": 40000,
          "disk_thin_provisioned": true
        }
      ],
      "boot_command": [
      "<up><tab> text ip=192.168.1.11::192.168.1.254:255.255.255.0:template:ens192:none nameserver=192.168.1.254 inst.ks=http://{{ user `HTTP_IP` }}/{{ user `HTTP_PATH` }}<enter><wait><enter>"
      ],
      "ssh_password": "mysecurepassword",
      "ssh_username": "root",
      "shutdown_command": "/sbin/halt -h -p",
      "insecure_connection": "true",
      "username": "{{ user `vcenter_username` }}",
      "password": "{{ user `vcenter_password` }}",
      "vcenter_server": "vsphere.rockylinux.lan",
      "datacenter": "DC_NAME",
      "datastore": "DS_NAME",
      "vm_name": "template-rockylinux8-{{ user `version` }}",
      "folder": "Templates/RockyLinux",
      "cluster": "CLUSTER_NAME",
      "host": "esx1.rockylinux.lan",
      "notes": "Template RockyLinux version {{ user `version` }}",
      "convert_to_template": true,
      "create_snapshot": false
    }
  ]
}
```
Далі ми опишемо кожен розділ цього файлу.

### Розділ змінних

На першому кроці ми оголошуємо змінні, в основному для зручності читання:

```
"variables": {
  "version": "0.0.X",
  "HTTP_IP": "fileserver.rockylinux.lan",
  "HTTP_PATH": "/packer/rockylinux/8/ks.cfg"
},
```

Ми використаємо змінну `version` пізніше в назві шаблону, який ми створимо. Ви можете легко збільшити це значення відповідно до своїх потреб.

Нам також знадобиться наша завантажувальна віртуальна машина для доступу до файлу `ks.cfg` (Kickstart).

Файл Kickstart містить відповіді на запитання, які виникли під час встановлення. Цей файл передає весь свій вміст до Anaconda (процес встановлення), що дозволяє повністю автоматизувати створення шаблону.

Автор любить зберігати свій файл `ks.cfg` на внутрішньому веб-сервері, доступному з його шаблону, але існують інші можливості, які ви натомість можете використати.

Наприклад, файл `ks.cfg` доступний із віртуальної машини за цією URL-адресою в нашій лабораторії: http://fileserver.rockylinux.lan/packer/rockylinux/8/ks.cfg. Вам потрібно буде налаштувати щось подібне, щоб використовувати цей метод.

Оскільки ми хочемо зберегти пароль конфіденційним, він оголошується як чутлива змінна. Приклад:

```
  "sensitive-variables": ["vcenter_password"],
```

### Розділ провайдерів

Наступна частина є цікавою, і ми розглянемо її пізніше, надавши вам сценарій для `requirements.sh`:

```
"provisioners": [
  {
    "type": "shell",
    "expect_disconnect": true,
    "execute_command": "bash '{{.Path}}'",
    "script": "{{template_dir}}/scripts/requirements.sh"
  }
],
```

Після завершення встановлення віртуальна машина перезавантажиться. Щойно Packer виявить IP-адресу (завдяки VMware Tools), він скопіює `requirements.sh` і виконає його. Очистити віртуальну машину після процесу інсталяції (видалити SSH-ключі, очистити історію тощо) і встановити додатковий пакет — це чудова функція.

### Розділ конструкторів

Ви можете оголосити один або кілька конструкторів для націлювання на щось інше, ніж ваше середовище vSphere (можливо, шаблон Vagrant).

Але тут ми використовуємо конструктор `vsphere-iso`:


```
"builders": [
  {
    "type": "vsphere-iso",
```

Цей конструктор дозволяє нам налаштувати необхідне обладнання:

```
  "CPUs": 2,
  "CPU_hot_plug": true,
  "RAM": 2048,
  "RAM_hot_plug": true,
  "disk_controller_type": "pvscsi",
  "guest_os_type": "centos8_64Guest",
  "network_adapters": [
    {
      "network_card": "vmxnet3",
      "network": "net_infra"
    }
  ],
  "storage": [
    {
      "disk_size": 40000,
      "disk_thin_provisioned": true
    }
  ],
```

!!! "Note" "Примітка"

    Ви ніколи не забудете включити CPU_hot_plug, оскільки тепер це автоматично!

Ви можете робити більше крутих речей з диском, процесором тощо. Вам слід звернутися до документації, якщо ви зацікавлені у внесенні інших коригувань.

Щоб розпочати встановлення, вам потрібен ISO-образ Rocky Linux. Ось приклад використання зображення, розташованого в бібліотеці вмісту vSphere. Ви, звичайно, можете зберегти ISO в іншому місці, але у випадку бібліотеки вмісту vSphere вам потрібно отримати повний шлях до файлу ISO на сервері, на якому розміщено бібліотеку вмісту (у цьому випадку це Synology, тому безпосередньо на Провідник DSM).

```
  "iso_paths": [
    "[datasyno-contentlibrary-mylib] contentlib-a86ad29a-a43b-4717-97e6-593b8358801b/3a381c78-b9df-45a6-82e1-3c07c8187dbe/Rocky-8.4-x86_64-minimal_72cc0cc6-9d0f-4c68-9bcd-06385a506a5d.iso"
  ],
```

Потім вам потрібно надати повну команду, яку потрібно ввести під час процесу інсталяції: конфігурація IP-адреси та передача шляху до файлу відповіді Kickstart.

!!! "Note" "Примітка"

    У цьому прикладі розглядається найскладніший випадок: використання статичного IP. Якщо у вас є сервер DHCP, процес буде набагато простіше.

Це найцікавіша частина процедури: я впевнений, що ви підете і помилуєтеся консоллю VMware під час генерації, просто щоб побачити автоматичне введення команд під час завантаження.

```
"boot_command": [
"<up><tab> text ip=192.168.1.11::192.168.1.254:255.255.255.0:template:ens192:none nameserver=192.168.1.254 inst.ks=http://{{ user `HTTP_IP` }}/{{ user `HTTP_PATH` }}<enter><wait><enter>"
],
```

Після першого перезавантаження Packer підключиться до вашого сервера через SSH. Ви можете використовувати користувача root або іншого користувача з правами sudo, але в будь-якому випадку цей користувач має відповідати користувачеві, визначеному у вашому файлі ks.cfg.

```
"ssh_password": "mysecurepassword",
"ssh_username": "root",
```

Наприкінці процесу віртуальну машину необхідно зупинити. Це трохи складніше з користувачем без root, але це добре задокументовано:

```
"shutdown_command": "/sbin/halt -h -p",
```

Далі розберемося з конфігурацією vSphere. Єдині помітні речі тут — це використання змінних, визначених на початку документа в нашому домашньому каталозі, а також параметр `insecure_connection`, оскільки наш vSphere використовує самопідписаний сертифікат (див. примітку в Припущення у верхній частині цього документа):

```
"insecure_connection": "true",
"username": "{{ user `vcenter_username` }}",
"password": "{{ user `vcenter_password` }}",
"vcenter_server": "vsphere.rockylinux.lan",
"datacenter": "DC_NAME",
"datastore": "DS_NAME",
"vm_name": "template-rockylinux8-{{ user `version` }}",
"folder": "Templates/RockyLinux",
"cluster": "CLUSTER_NAME",
"host": "esx1.rockylinux.lan",
"notes": "Template RockyLinux version {{ user `version` }}"
```

І, нарешті, ми попросимо vSphere перетворити нашу зупинену віртуальну машину на шаблон.

На цьому етапі ви також можете вибрати просто використовувати віртуальну машину як є (не перетворюючи її на шаблон). У цьому випадку ви можете замість цього зробити знімок:

```
"convert_to_template": true,
"create_snapshot": false,
```

## Файл ks.cfg

Як зазначалося вище, нам потрібно надати файл відповіді kickstart, який використовуватиме Anaconda.

Ось приклад цього файлу:

```
# Use CD-ROM installation media
repo --name="AppStream" --baseurl="http://download.rockylinux.org/pub/rocky/8.4/AppStream/x86_64/os/"
cdrom
# Use text install
text
# Don't run the Setup Agent on first boot
firstboot --disabled
eula --agreed
ignoredisk --only-use=sda
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network --bootproto=static --device=ens192 --gateway=192.168.1.254 --ip=192.168.1.11 --nameserver=192.168.1.254,4.4.4.4 --netmask=255.255.255.0 --onboot=on --ipv6=auto --activate

# Root password
rootpw mysecurepassword

# System services
selinux --permissive
firewall --enabled
services --enabled="NetworkManager,sshd,chronyd"
# System timezone
timezone Europe/Paris --isUtc
# System booloader configuration
bootloader --location=mbr --boot-drive=sda
# Partition clearing information
clearpart --all --initlabel --drives=sda
# Disk partitionning information
part /boot --fstype="xfs" --ondisk=sda --size=512
part pv.01 --fstype="lvmpv" --ondisk=sda --grow
volgroup vg_root --pesize=4096 pv.01
logvol /home --fstype="xfs" --size=5120 --name=lv_home --vgname=vg_root
logvol /var --fstype="xfs" --size=10240 --name=lv_var --vgname=vg_root
logvol / --fstype="xfs" --size=10240 --name=lv_root --vgname=vg_root
logvol swap --fstype="swap" --size=4092 --name=lv_swap --vgname=vg_root

skipx

reboot

%packages --ignoremissing --excludedocs
openssh-clients
curl
dnf-utils
drpm
net-tools
open-vm-tools
perl
perl-File-Temp
sudo
vim
wget
python3

# unnecessary firmware
-aic94xx-firmware
-atmel-firmware
-b43-openfwwf
-bfa-firmware
-ipw2100-firmware
-ipw2200-firmware
-ivtv-firmware
-iwl*-firmware
-libertas-usb8388-firmware
-ql*-firmware
-rt61pci-firmware
-rt73usb-firmware
-xorg-x11-drv-ati-firmware
-zd1211-firmware
-cockpit
-quota
-alsa-*
-fprintd-pam
-intltool
-microcode_ctl
%end

%addon com_redhat_kdump --disable
%end

%post

# Manage Ansible access
groupadd -g 1001 ansible
useradd -m -g 1001 -u 1001 ansible
mkdir /home/ansible/.ssh
echo -e "<---- PAST YOUR PUBKEY HERE ---->" >  /home/ansible/.ssh/authorized_keys
chown -R ansible:ansible /home/ansible/.ssh
chmod 700 /home/ansible/.ssh
chmod 600 /home/ansible/.ssh/authorized_keys
echo "ansible ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible
chmod 440 /etc/sudoers.d/ansible

systemctl enable vmtoolsd
systemctl start vmtoolsd

%end
```

Оскільки ми вирішили використовувати мінімальний ISO, замість Boot або DVD, не всі необхідні пакети встановлення будуть доступні.

Оскільки Packer покладається на VMware Tools для виявлення завершення інсталяції, а пакет `open-vm-tools` доступний лише в репозиторіях AppStream, ми маємо вказати в процесі інсталяції те, що ми хочемо використовувати як джерело CD-ROM і це віддалене сховище:

!!! "Note" "Примітка"

    Якщо у вас немає доступу до зовнішнього сховища, ви можете використовувати дзеркало сховища, проксі-сервер squid або DVD.

```
# Use CD-ROM installation media
repo --name="AppStream" --baseurl="http://download.rockylinux.org/pub/rocky/8.4/AppStream/x86_64/os/"
cdrom
```

Давайте перейдемо до конфігурації мережі, тому що в цьому прикладі ми не використовуємо сервер DHCP:

```
# Network information
network --bootproto=static --device=ens192 --gateway=192.168.1.254 --ip=192.168.1.11 --nameserver=192.168.1.254,4.4.4.4 --netmask=255.255.255.0 --onboot=on --ipv6=auto --activate
```

Пам’ятайте, що ми вказали користувача для підключення до Packer через SSH наприкінці інсталяції. Цей користувач і пароль мають збігатися:

```
# Root password
rootpw mysecurepassword
```

!!! warning "Важливо"

    Тут можна використовувати ненадійний пароль, якщо ви переконаєтеся, що цей пароль буде змінено одразу після розгортання вашої віртуальної машини, наприклад, за допомогою Ansible.

Ось обрана схема розділу. Можна робити набагато складніші речі. Ви можете визначити схему розділів, яка відповідає вашим потребам, адаптувавши її до дискового простору, визначеного в Packer, і яка поважає правила безпеки, визначені для вашого середовища (виділений розділ для `/tmp` тощо):

```
# System booloader configuration
bootloader --location=mbr --boot-drive=sda
# Partition clearing information
clearpart --all --initlabel --drives=sda
# Disk partitionning information
part /boot --fstype="xfs" --ondisk=sda --size=512
part pv.01 --fstype="lvmpv" --ondisk=sda --grow
volgroup vg_root --pesize=4096 pv.01
logvol /home --fstype="xfs" --size=5120 --name=lv_home --vgname=vg_root
logvol /var --fstype="xfs" --size=10240 --name=lv_var --vgname=vg_root
logvol / --fstype="xfs" --size=10240 --name=lv_root --vgname=vg_root
logvol swap --fstype="swap" --size=4092 --name=lv_swap --vgname=vg_root
```

Наступний розділ стосується пакетів, які буде встановлено. «Найкраща практика» полягає в тому, щоб обмежити кількість встановлених пакетів лише тими, які вам потрібні, що обмежує поверхню атаки, особливо в середовищі сервера.

!!! note "Примітка"

    Автор любить обмежувати дії, які необхідно виконати в процесі інсталяції, і відкладати інсталяцію того, що потрібно в сценарії після інсталяції Packer. Тому в цьому випадку ми встановлюємо лише мінімально необхідні пакети.

Схоже, пакет `openssh-clients` потрібен Packer для копіювання своїх сценаріїв у віртуальну машину.

Інструменти `open-vm-tools` також потрібні Packer для виявлення завершення інсталяції, цим пояснюється додавання репозиторію AppStream. Пакети `perl` і `perl-File-Temp` також знадобляться для VMware Tools під час розгортання. Це прикро, тому що для цього потрібно багато інших залежних пакетів. `python3` (3.6) також знадобиться в майбутньому для роботи Ansible (якщо ви не використовуєте Ansible або python, видаліть їх!).

```
%packages --ignoremissing --excludedocs
openssh-clients
open-vm-tools
python3
perl
perl-File-Temp
curl
dnf-utils
drpm
net-tools
sudo
vim
wget
```

Ви можете не лише додавати пакети, а й видаляти їх. Оскільки ми контролюємо середовище, в якому працюватиме наше обладнання, ми можемо видалити будь-яке мікропрограмне забезпечення, яке буде для нас марним:

```
# unnecessary firmware
-aic94xx-firmware
-atmel-firmware
...
```

Наступна частина додає деяких користувачів. У нашому випадку цікаво створити користувача `ansible` без пароля, але з відкритим ключем. Це дозволяє всім нашим новим віртуальним машинам бути доступними з нашого сервера Ansible для виконання дій після встановлення:

```
# Manage Ansible access
groupadd -g 1001 ansible
useradd -m -g 1001 -u 1001 ansible
mkdir /home/ansible/.ssh
echo -e "<---- PAST YOUR PUBKEY HERE ---->" >  /home/ansible/.ssh/authorized_keys
chown -R ansible:ansible /home/ansible/.ssh
chmod 700 /home/ansible/.ssh
chmod 600 /home/ansible/.ssh/authorized_keys
echo "ansible ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible
chmod 440 /etc/sudoers.d/ansible
```

Тепер нам потрібно ввімкнути та запустити `vmtoolsd` (процес, який керує open-vm-tools). vSphere визначить IP-адресу після перезавантаження віртуальної машини.

```
systemctl enable vmtoolsd
systemctl start vmtoolsd
```

Процес встановлення завершено, і віртуальна машина перезавантажиться.

## Провізори

Пам’ятайте, що ми оголосили в Packer засіб надання, який у нашому випадку відповідає сценарію `.sh`, який буде зберігатися у підкаталозі поруч із нашим файлом json.

Існують різні типи провайдерів, ми також могли б використати Ansible. Ви можете вільно досліджувати ці можливості.

Цей файл можна повністю змінити, але це приклад того, що можна зробити за допомогою сценарію, у цьому випадку `requirements.sh`:

```
#!/bin/sh -eux

echo "Updating the system..."
dnf -y update

echo "Installing cloud-init..."
dnf -y install cloud-init

# see https://bugs.launchpad.net/cloud-init/+bug/1712680
# and https://kb.vmware.com/s/article/71264
# Virtual Machine customized with cloud-init is set to DHCP after reboot
echo "manual_cache_clean: True " > /etc/cloud/cloud.cfg.d/99-manual.cfg

echo "Disable NetworkManager-wait-online.service"
systemctl disable NetworkManager-wait-online.service

# cleanup current SSH keys so templated VMs get fresh key
rm -f /etc/ssh/ssh_host_*

# Avoid ~200 meg firmware package we don't need
# this cannot be done in the KS file so we do it here
echo "Removing extra firmware packages"
dnf -y remove linux-firmware
dnf -y autoremove

echo "Remove previous kernels that preserved for rollbacks"
dnf -y remove -y $(dnf repoquery --installonly --latest-limit=-1 -q)
dnf -y clean all  --enablerepo=\*;

echo "truncate any logs that have built up during the install"
find /var/log -type f -exec truncate --size=0 {} \;

echo "remove the install log"
rm -f /root/anaconda-ks.cfg /root/original-ks.cfg

echo "remove the contents of /tmp and /var/tmp"
rm -rf /tmp/* /var/tmp/*

echo "Force a new random seed to be generated"
rm -f /var/lib/systemd/random-seed

echo "Wipe netplan machine-id (DUID) so machines get unique ID generated on boot"
truncate -s 0 /etc/machine-id

echo "Clear the history so our install commands aren't there"
rm -f /root/.wget-hsts
export HISTSIZE=0

```

Необхідні деякі пояснення:

```
echo "Installing cloud-init..."
dnf -y install cloud-init

# see https://bugs.launchpad.net/cloud-init/+bug/1712680
# and https://kb.vmware.com/s/article/71264
# Virtual Machine customized with cloud-init is set to DHCP after reboot
echo "manual_cache_clean: True" > /etc/cloud/cloud.cfg.d/99-manual.cfg
```

Оскільки vSphere тепер використовує хмарну ініціалізацію через інструменти VMware для налаштування мережі гостьової машини centos8, її потрібно встановити. Однак якщо нічого не робити, конфігурація буде застосована при першому перезавантаженні, і все буде добре. Але під час наступного перезавантаження cloud-init не отримає жодної нової інформації від vSphere. У цих випадках без інформації про те, що робити, cloud-init переналаштує мережевий інтерфейс віртуальної машини для використання DHCP, і ви втратите свою статичну конфігурацію.

Оскільки це не та поведінка, яку ми хочемо, нам потрібно вказати для cloud-init не видаляти свій кеш автоматично, а отже повторно використовувати інформацію про конфігурацію, яку він отримав під час першого перезавантаження та кожного наступного перезавантаження.

Для цього ми створюємо файл `/etc/cloud/cloud.cfg.d/99-manual.cfg` з директивою `manual_cache_clean: True`.

!!! note "Примітка"

    Це означає, що якщо вам потрібно буде повторно застосувати мережеву конфігурацію за допомогою гостьових налаштувань vSphere (що за нормального використання трапляється досить рідко), вам доведеться самостійно видалити кеш ініціалізації хмари.

Решта сценарію коментується і не вимагає додаткових деталей.

Ви можете переглянути [проект Bento](https://github.com/chef/bento/tree/master/packer_templates), щоб отримати більше ідей щодо того, що можна зробити в цій частині процесу автоматизації.

## Створення шаблону

Тепер настав час запустити Packer і перевірити, чи процес створення, який є повністю автоматичним, працює добре.

Просто введіть це в командному рядку:

```
./packer build -var-file=~/.vsphere-secrets.json rockylinux8/template.json
```

Можна швидко зайти в vSphere і помилуватися роботою.

Ви побачите, як машина створюється, запускається, а якщо ви запустите консоль, ви побачите автоматичний ввід команд і процес встановлення.

Наприкінці створення ви знайдете свій шаблон, готовий до використання у vSphere.

## Частина розгортання

Ця документація була б неповною без частини шаблону автоматичного розгортання.

Для цього ми будемо використовувати простий посібник Ansible, який використовує модуль `vmware_guest`.

Цей підручник, який ми вам надаємо, має бути адаптований до ваших потреб і способу дій.

```
---
- name: Deploy VM from template
  hosts: localhost
  gather_facts: no
  vars_files:
    - ./vars/credentials.yml

  tasks:

  - name: Clone the template
    vmware_guest:
      hostname: "{{ vmware_vcenter_hostname }}"
      username: "{{ vmware_username }}"
      password: "{{ vmware_password }}"
      validate_certs: False
      name: "{{ vm_name }}"
      template: "{{ template_name }}"
      datacenter: "{{ datacenter_name }}"
      folder: "{{ storage_folder }}"
      state: "{{ state }}"
      cluster: "{{ cluster_name | default(omit,true) }}"
      esxi_hostname: "{{ esxi_hostname | default(omit,true) }}"
      wait_for_ip_address: no
      annotation: "{{ comments | default('Deployed by Ansible') }}"
      datastore: "{{ datastore_name | default(omit,true) }}"
      networks:
      - name: "{{ network_name }}"
        ip: "{{ network_ip }}"
        netmask: "{{ network_mask }}"
        gateway: "{{ network_gateway }}"
        device_type: "vmxnet3"
        type: static
      hardware:
        memory_mb: "{{ memory_mb|int * 1024 }}"
        num_cpu: "{{ num_cpu }}"
        hotadd_cpu: True
        hotadd_memory: True
      customization:
        domain: "{{ domain }}"
        dns_servers: "{{ dns_servers.split(',') }}"
      guest_id: "{{ guest_id }}"
    register: deploy_vm
```

Ви можете зберігати конфіденційні дані в `./vars/credentials.yml`, який ви, очевидно, заздалегідь зашифрували за допомогою `ansible-vault` (особливо якщо ви використовуєте git для своєї роботи). Оскільки все використовує змінну, ви можете легко зробити це відповідно до ваших потреб.

Якщо ви не використовуєте щось на зразок Rundeck або Awx, ви можете запустити розгортання за допомогою командного рядка, подібного до цього:

```
ansible-playbook -i ./inventory/hosts  -e '{"comments":"my comments","cluster_name":"CS_NAME","esxi_hostname":"ESX_NAME","state":"started","storage_folder":"PROD","datacenter_name":"DC_NAME}","datastore_name":"DS_NAME","template_name":"template-rockylinux8-0.0.1","vm_name":"test_vm","network_name":"net_prod","network_ip":"192.168.1.20","network_gateway":"192.168.1.254","network_mask":"255.255.255.0","memory_mb":"4","num_cpu":"2","domain":"rockylinux.lan","dns_servers":"192.168.1.254","guest_id":"centos8_64Guest"}' ./vmware/create_vm.yml --vault-password-file /etc/ansible/vault_pass.py
```

Саме на цьому етапі ви можете запустити остаточну конфігурацію вашої віртуальної машини за допомогою Ansible. Не забудьте змінити пароль адміністратора, захистити SSH, зареєструвати нову віртуальну машину в інструменті моніторингу та в ІТ-інвентаризації тощо.

## Коротко

Як ми бачили, зараз існують повністю автоматизовані рішення DevOps для створення та розгортання віртуальних машин.

У той же час це беззаперечна економія часу, особливо в хмарних середовищах або центрах обробки даних. Це також сприяє стандартній відповідності на всіх комп’ютерах у компанії (серверах і робочих станціях), а також спрощує технічне обслуговування/розробку шаблонів.

## Інші посилання

Щоб отримати докладний проект, який також охоплює розгортання Rocky Linux та інших операційних систем із використанням останніх версії vSphere, Packer і Packer Plugin для vSphere, відвідайте [цей проект](https://github.com/vmware-samples/ packer-examples-for-vsphere). 
