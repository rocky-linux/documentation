---
title: Création automatique de templates - Packer - Ansible - VMware vSphere
author: Antoine Le Morvan
contributors: Steven Spencer, Ryan Johnson, Pedro Garcia, Ganna Zhyrnova
---

# Création automatique de modèles avec Packer et déploiement avec Ansible dans un environnement VMware vSphere

**Connaissances** : :star: :star: :star:  
**Complexité** : :star: :star: :star:

**Temps de lecture** : 31 minutes

## Prérequis, Hypothèses et Généralités

- Un environnement vSphere disponible et un utilisateur avec un accès autorisé.
- Un serveur web interne pour stocker des fichiers
- Accès Web aux dépôts de Rocky Linux
- Une image ISO de Rocky Linux
- Un environnement Ansible est disponible
- L'auteur de ce guide présume que vous avez une certaine connaissance de chaque produit mentionné. Sinon, veuillez consulter la documentation correspondante avant de commencer.
- Vagrant n'est **pas utilisé** ici. Il a été constaté qu'avec Vagrant, une clé SSH qui n'était pas auto-signée serait fournie. Si vous voulez y arriver, vous pouvez le faire, mais ce n'est pas couvert dans ce document.

## Introduction

Ce document couvre la création de modèles de machines virtuelles vSphere avec Packer et comment déployer l'artefact en tant que nouvelles machines virtuelles avec Ansible.

## Ajustements possibles

Bien sûr, vous pouvez adapter ce guide à d'autres hyperviseurs.

Bien que nous utilisions l'image ISO minimale ici, vous pouvez choisir d'utiliser l'image DVD (beaucoup plus grande et peut-être excecive) ou l'image de démarrage (beaucoup plus petite et peut-être trop restreinte). Le choix vous appatient. Cela influencera la bande passante nécessaire et par conséquent le temps de mise en place. Nous discuterons ensuite de l'impact du choix par défaut et de la manière d'y remédier.

Vous pouvez aussi choisir de ne pas convertir la machine virtuelle en modèle. Dans ce cas vous utiliserez Packer pour déployer chaque nouvelle machine virtuelle, ce qui est encore tout à fait faisable. Une installation à partir de zéro prend moins de 10 minutes sans interaction humaine.

## Packer

### Introduction à Packer

Packer est un outil d'imagerie de machines virtuelles open source, publié sous la licence MPL 2.0 et créé par HashiCorp. Il vous aidera à automatiser le processus de création d'images de machine virtuelle avec des systèmes d'exploitation pré-configurés et des logiciels installés à partir d'une configuration source unique dans les deux cas, des environnements virtualisés sur le cloud et sur prém.

With Packer you can create images to be used on the following platforms:

- [Amazon Web Services](https://aws.amazon.com).
- [Azure](https://azure.microsoft.com/en-us/).
- [GCP](https://cloud.google.com).
- [DigitalOcean](https://www.digitalocean.com).
- [OpenStack](https://www.openstack.org).
- [VirtualBox](https://www.virtualbox.org/).
- [VMware](https://www.vmware.com).

Pour de plus amples informations veuillez consulter les ressources suivantes :

- Le site [Packer](https://www.packer.io/)
- [Documentation de Packer](https://www.packer.io/docs)
- Le constructeur de la documentation `vsphere-iso`de [](https://www.packer.io/docs/builders/vsphere/vsphere-iso)

### Installation de Packer

Il y a deux façons d'installer Packer dans votre système Rocky Linux.

#### Installation de Packer à partir du dépôt `HashiCorp`

`HashiCorp` maintient et signe des paquets pour différentes distributions GNU/Linux. Pour installer Packer sur votre système Rocky Linux, veuillez suivre les étapes suivantes :

1. Installation du 'dnf-config-manager' :

    ```bash
    sudo dnf install -y dnf-plugins-core
    ```

1. Ajouter le dépôt HashiCorp aux repos disponibles dans notre système Rocky Linux :

    ```bash
    sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
    ```

1. Installation de Packer :

    ```bash
    sudo dnf -y install packer
    ```

#### Télécharger et installer depuis le site web de Packer

Vous pouvez commencer par télécharger les binaires pour votre propre plateforme avec [Téléchargements Packer](https://www.packer.io/downloads).

1. Sur la page de téléchargement, copiez le lien dans la section Téléchargement binaire de Linux qui correspond à l'architecture de votre système.

1. À partir d'un shell ou d'un terminal, téléchargez-le à l'aide de l'outil `wget` :

    ```bash
    wget https://releases.hashicorp.com/packer/1.8.3/packer_1.8.3_linux_amd64.zip
    ```

    Ceci va télécharger un fichier .zip.

1. Pour décompresser l'archive téléchargée, exécutez la commande suivante dans le shell :

    ```bash
    unzip packer_1.8.3_linux_amd64.zip
    ```

    !!! tip "Astuce"

     Si vous obtenez une erreur et que vous n'avez pas l'application unzip installée sur votre système, vous pouvez l'installer en exécutant la commande ```sudo dnf install unzip```.

1. Déplacer l'application Packer dans le dossier 'bin' adéquat :

    ```bash
    sudo mv packer /usr/local/bin/
    ```

#### Vérification de l'installation de Packer

Si toutes les étapes des procédures précédentes ont été effectuées correctement, vous pouvez procéder à la vérification de l'installation de Packer sur votre système.

Pour vérifier que Packer a été installé correctement, exécutez la commande `packer` et vous obtiendrez le résultat suivant :

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

### Création d'un modèle avec Packer

!!! note "Remarque"

    Les exemples suivants sont conçus pour un système GNU/Linux.

Comme nous allons nous connecter à un serveur VMware vCenter pour envoyer nos commandes via Packer, nous devons stocker nos identifiants en dehors des fichiers de configuration que nous allons créer ensuite.

Créons un fichier caché, avec nos identifiants, dans notre répertoire personnel. Ceci est un fichier 'json' :

```bash
$ vim .vsphere-secrets.json {
    "vcenter_username": "rockstar",
    "vcenter_password": "mysecurepassword"
  }
```

Ces informations d’identification nécessitent un accès à votre environnement vSphere.

Nous allons créer un fichier json (dans le futur, le format de ce fichier passera au HCL) :

```json
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

Ensuite, nous allons décrire chaque section de ce fichier.

### Section des Variables

Dans un premier temps, nous déclarons des variables, principalement pour des raisons de lisibilité :

```json
"variables": {
  "version": "0.0.X",
  "HTTP_IP": "fileserver.rockylinux.lan",
  "HTTP_PATH": "/packer/rockylinux/8/ks.cfg"
},
```

Nous utiliserons la variable `version` plus tard dans le nom du modèle que nous allons créer. Vous pouvez facilement incrémenter cette valeur en fonction de vos besoins.

Nous aurons également besoin de notre machine virtuelle de démarrage pour accéder à un fichier `ks.cfg` (Kickstart).

Un fichier 'Kickstart' contient les réponses aux questions posées au cours du processus d'installation. Ce fichier transmet tout son contenu à 'Anaconda' (le processus d'installation), ce qui vous permet d'automatiser complètement la création du modèle.

Pour en savoir plus sur les fichiers Kickstart et comment les déployer sur Rocky Linux, veuillez consulter le [Guide des fichiers Kickstart et de Rocky Linux](kickstart-rocky.md).

L'auteur préfère stocker son fichier `ks.cfg` sur un serveur web interne accessible à partir de son modèle, mais il existe d'autres possibilités que vous pouvez choisir d'utiliser à la place.

Par exemple, le fichier `ks.cfg` est accessible depuis la VM à cette URL dans notre laboratoire : <http://fileserver.rockylinux.lan/packer/rockylinux/8/ks.cfg>. Vous devriez installer quelque chose de similaire pour utiliser cette méthode.

Puisque nous voulons garder notre mot de passe privé, il est déclaré comme variable sensible. Exemple :

```json
"sensitive-variables": ["vcenter_password"],
```

### Section de provisionnement

La partie suivante est intéressante et sera traitée plus tard en vous fournissant le code pour le script `requirements.sh` :

```json
"provisioners": [
  {
    "type": "shell",
    "expect_disconnect": true,
    "execute_command": "bash '{{.Path}}'",
    "script": "{{template_dir}}/scripts/requirements.sh"
  }
],
```

Une fois l'installation terminée, la machine virtuelle va redémarrer. Dès que Packer détecte une adresse IP (grâce à VMware Tools), il copiera le script `requirements.sh` et l'exécutera. C'est une fonctionnalité pratique pour nettoyer la machine virtuelle après le processus d'installation (supprimer les clés SSH, nettoyer l'historique, etc.) et installer des paquets supplémentaires.

### La section des constructeurs

Vous pouvez déclarer un ou plusieurs builders pour cibler quelque chose d'autre que votre environnement vSphere (peut-être un modèle Vagrant).

Mais ici, vous utiliserez le builder `vsphere-iso` :

```json
"builders": [
  {
    "type": "vsphere-iso",
```

Ce 'builder' nous permet de configurer le matériel dont nous avons besoin :

```json
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

!!! note "Remarque"

    Vous n’oublierez plus jamais d’inclure CPU_hot_plug car c’est désormais automatique !

Vous pouvez faire encore plus de choses intéressantes avec le disque, le processeur, etc. Vous devez vous référer à la documentation si vous souhaitez effectuer d'autres réglages.

Pour démarrer l'installation, vous avez besoin d'une image ISO de Rocky Linux. Voici un exemple d'utilisation d'une image située dans une bibliothèque de contenus de vSphere. Vous pouvez bien sûr stocker l'ISO à un autre endroit. Dans le cas d'une bibliothèque de contenus vSphere, vous devez obtenir le chemin complet du fichier ISO sur le serveur hébergeant cette bibliothèque des contenus. Dans ce cas il s'agit de Synology, donc directement sur l'explorateur DSM.

```json
"iso_paths": [
  "[datasyno-contentlibrary-mylib] contentlib-a86ad29a-a43b-4717-97e6-593b8358801b/3a381c78-b9df-45a6-82e1-3c07c8187dbe/Rocky-8.4-x86_64-minimal_72cc0cc6-9d0f-4c68-9bcd-06385a506a5d.iso"
],
```

Ensuite, vous devez fournir la commande complète à entrer pendant le processus d'installation : configuration de l'IP et transmission du chemin vers le fichier Kickstart.

!!! note "Remarque"

    Cet exemple prend en considération le cas le plus complexe : l'utilisation d'une adresse IP statique. Si vous disposez d'un serveur DHCP, la procédure sera beaucoup plus facile.

C'est la partie la plus amusante de la procédure : je suis sûr que vous irez admirer la console VMware pendant la génération, histoire de voir la saisie automatique des commandes lors du démarrage.

```json
"boot_command": [
"<up><tab> text ip=192.168.1.11::192.168.1.254:255.255.255.0:template:ens192:none nameserver=192.168.1.254 inst.ks=http://{{ user `HTTP_IP` }}/{{ user `HTTP_PATH` }}<enter><wait><enter>"
],
```

Après le premier redémarrage, Packer se connectera à votre serveur par SSH. Vous pouvez utiliser l'utilisateur root, ou un autre utilisateur avec des droits sudo, mais dans tous les cas, cet utilisateur doit correspondre à l'utilisateur qui est défini dans votre fichier `ks.cfg`.

```json
"ssh_password": "mysecurepassword",
"ssh_username": "root",
```

À la fin du processus, la VM doit être arrêtée. C'est un peu plus compliqué avec un utilisateur non root, mais tout est bien documenté :

```json
"shutdown_command": "/sbin/halt -h -p",
```

Ensuite, nous traitons de la configuration de vSphere. Les seules choses notables ici sont l'utilisation des variables définies au début du document dans notre répertoire personnel, ainsi que l'option `insecure_connection` parce que notre vSphere utilise un certificat auto-signé (voir la note dans les prérequis en haut de ce document) :

```json
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

Et enfin, nous allons demander à vSphere de convertir notre machine virtuelle arrêtée en un modèle.

À ce stade, vous pouvez également choisir d'utiliser la machine virtuelle comme elle est (ne pas la convertir en un modèle). Dans ce cas, vous pouvez décider d'enregistrer un snapshot à la place :

```json
"convert_to_template": true,
"create_snapshot": false,
```

## Le fichier ks.cfg

Comme indiqué ci-dessus, nous devons fournir un fichier `kickstart` qui sera utilisé par `Anaconda`.

Voici un exemple de ce fichier :

```bash
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

Comme nous avons choisi d'utiliser l'image ISO minimum, au lieu de Boot ou du DVD, tous les paquets d'installation nécessaires ne seront pas disponibles.

Comme Packer se base sur des outils VMware pour détecter la fin de l'installation et le package `open-vm-tools` n'est disponible que dans les dépôts AppStream, nous devons indiquer au processus d'installation que nous voulons utiliser comme source à la fois le cdrom et ce dépôt distant :

!!! note "Remarque"

    Si vous n'avez pas accès aux dépôts externes, vous pouvez utiliser soit un miroir du dépôt, soit un proxy Squid, soit le DVD.

```bash
# Use CD-ROM installation media
repo --name="AppStream" --baseurl="http://download.rockylinux.org/pub/rocky/8.4/AppStream/x86_64/os/"
cdrom
```

Allons à la configuration du réseau. Une fois de plus, dans cet exemple, nous n'utilisons pas de serveur DHCP :

```bash
# Network information
network --bootproto=static --device=ens192 --gateway=192.168.1.254 --ip=192.168.1.11 --nameserver=192.168.1.254,4.4.4.4 --netmask=255.255.255.0 --onboot=on --ipv6=auto --activate
```

Remember we specified the user to connect via SSH with to Packer at the end of the installation. Cet utilisateur et le mot de passe doivent correspondre :

```bash
# Root password
rootpw mysecurepassword
```

!!! warning "Avertissement"

    Vous pouvez utiliser ici un mot de passe non sécurisé, à condition de vous assurer que ce mot de passe sera modifié immédiatement après le déploiement de votre VM, par exemple avec Ansible.

Voici le schéma de partition choisi. Des choses bien plus complexes peuvent être réalisées. Vous pouvez définir un schéma de partition qui correspond à vos besoins, en l'adaptant à l'espace disque défini dans Packer, et qui respecte les règles de sécurité définies pour votre environnement (partition dédiée pour `/tmp`, etc.) :

```bash
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

La section suivante concerne les packages qui seront installés. Une « bonne pratique » consiste à limiter la quantité de packages installés à ceux dont vous avez besoin, ce qui limite la surface d'attaque, en particulier dans un environnement serveur.

!!! note "Remarque"

    L'auteur préfère limiter les actions à effectuer dans le processus d'installation et reporter l'installation de ce qui est nécessaire dans le script de post-installation de 'Packer'. Donc dans ce cas, nous installons uniquement les packages minimum requis.

Le paquet `openssh-clients` semble être requis pour que 'Packer' copie ses scripts dans la machine virtuelle.

`open-vm-tools` est également nécessaire à Packer pour détecter la fin de l'installation, ce qui explique l'ajout du référentiel AppStream. Les packages `perl` et `perl-File-Temp` seront également requis par VMware Tools lors de la partie déploiement. C'est dommage, car cela nécessite beaucoup d'autres paquets dépendants. `python3` (3.6) sera également requis dans le futur pour que 'Ansible' fonctionne (si vous n'utilisez ni Ansible ni python, supprimez-les !).

```bash
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

Vous pouvez non seulement ajouter des packages, mais également les supprimer. Puisque vous contrôlez l'environnement dans lequel votre matériel fonctionnera, vous pouvez supprimer n'importe quel firmware qui vous sera inutile :

```bash
# unnecessary firmware
-aic94xx-firmware
-atmel-firmware
...
```

La partie suivante décrit l'ajout de quelques utilisateurs. Il est intéressant dans le cas de cet exemple de créer un utilisateur `ansible`, sans mot de passe mais avec une clé publique. Cela permet à toutes nos nouvelles machines virtuelles d'être accessibles depuis notre serveur 'Ansible' pour exécuter les actions de post-installation :

```bash
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

Maintenant nous devons activer et démarrer `vmtoolsd` (le processus qui gère open-vm-tools). vSphere détectera l'adresse IP après le redémarrage de la machine virtuelle.

```bash
systemctl enable vmtoolsd
systemctl start vmtoolsd
```

Une fois l'installation terminée, la machine virtuelle va redémarrer.

## Les provisioners

Rappelez-vous que nous avons déclaré dans 'Packer' un 'provisioner', qui dans notre cas correspond à un script `.sh`, à stocker dans un sous-répertoire à côté de notre fichier json.

Il existe différents types de 'provisioners', nous aurions également pu utiliser 'Ansible'. Vous êtes libre d'explorer ces possibilités.

Ce fichier peut être complètement modifié, mais cela fournit un exemple de ce qui peut être fait avec un script, dans ce cas `requirements.sh`. La note ci-dessous « URL de l'article de la base de connaissances » remplace une URL cassée, mais ne change pas le sens :

```bash
#!/bin/sh -eux

echo "Updating the system..."
dnf -y update

echo "Installing cloud-init..."
dnf -y install cloud-init

# see https://bugs.launchpad.net/cloud-init/+bug/1712680
# and "URL to knowlege base article"
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

Quelques explications sont nécessaires :

```bash
echo "Installing cloud-init..."
dnf -y install cloud-init

# see https://bugs.launchpad.net/cloud-init/+bug/1712680
# and https://kb.vmware.com/s/article/71264
# Virtual Machine customized with cloud-init is set to DHCP after reboot
echo "manual_cache_clean: True" > /etc/cloud/cloud.cfg.d/99-manual.cfg
```

Comme vSphere utilise maintenant `cloud-init` via les outils VMware pour configurer le réseau d'une machine invitée centos8, le paquet doit être installé. Cependant, si vous ne faites rien, la configuration sera appliquée au prochain redémarrage et tout ira bien. Mais au prochain redémarrage, 'cloud-init' ne recevra pas de nouvelles informations de vSphere. Dans ce cas, sans information sur ce qu'il faut faire, 'cloud-init' reconfigurera l'interface réseau de la machine virtuelle pour utiliser DHCP et vous perdrez votre configuration statique.

Comme ce n'est pas le comportement que nous souhaitons, nous devons spécifier à `cloud-init` de ne pas supprimer son cache automatiquement, et donc de réutiliser les informations de configuration qu'il a reçues lors de son premier redémarrage et de chaque redémarrage suivant.

Pour cela, nous créons un fichier `/etc/cloud/cloud.cfg.d/99-manual.cfg` contenant la directive `manual_cache_clean: True`.

!!! note "Remarque"

    Cela implique que si vous devez réappliquer une configuration réseau via les personnalisations invitées de `vSphere` (ce qui, dans une utilisation normale, devrait être assez rare), vous devrez supprimer vous-même le cache `cloud-init`.

Le reste du script est commenté et ne nécessite pas plus de détails.

Vous pouvez consulter le site du [projet Bento](https://github.com/chef/bento/tree/master/packer_templates) pour avoir plus d'idées sur ce qui peut être fait dans cette partie du processus d'automatisation.

## Création du modèle

Il est maintenant temps de lancer Packer et de vérifier que le processus de création, qui est entièrement automatique, fonctionne bien.

Entrez simplement ceci dans la ligne de commande :

```bash
./packer build -var-file=~/.vsphere-secrets.json rockylinux8/template.json
```

Vous pouvez accéder rapidement à vSphere et admirer le travail.

Vous verrez la machine se créer, démarrer, et si vous lancez une console, vous verrez la saisie automatique des commandes et le processus d'installation.

A la fin de la création, vous retrouverez votre modèle prêt à être utilisé dans vSphere.

## Partie Déploiement

Cette documentation ne serait pas complète sans la partie déploiement automatique du modèle.

Pour cela, nous utiliserons un playbook Ansible simple, qui utilise le module `vmware_guest`.

Ce 'playbook' que nous vous fournissons, doit être adapté à vos besoins et à votre façon de faire.

```ansible
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

Vous pouvez stocker des données sensibles dans le fichier `./vars/credentials.yml`, que vous aurez évidemment chiffré à l'avance avec `ansible-vault` (surtout si vous utilisez git pour votre travail). Comme toute configuration utilise des variables, vous pouvez facilement la rendre adaptée à vos besoins.

Si vous n'utilisez pas quelque chose comme 'Rundeck' ou 'Awx', vous pouvez lancer le déploiement avec une ligne de commande similaire à celle-ci :

```bash
ansible-playbook -i ./inventory/hosts  -e '{"comments":"my comments","cluster_name":"CS_NAME","esxi_hostname":"ESX_NAME","state":"started","storage_folder":"PROD","datacenter_name":"DC_NAME}","datastore_name":"DS_NAME","template_name":"template-rockylinux8-0.0.1","vm_name":"test_vm","network_name":"net_prod","network_ip":"192.168.1.20","network_gateway":"192.168.1.254","network_mask":"255.255.255.0","memory_mb":"4","num_cpu":"2","domain":"rockylinux.lan","dns_servers":"192.168.1.254","guest_id":"centos8_64Guest"}' ./vmware/create_vm.yml --vault-password-file /etc/ansible/vault_pass.py
```

C'est à ce stade que vous pouvez lancer la configuration finale de votre machine virtuelle en utilisant 'Ansible'. N'oubliez pas de changer le mot de passe root, de sécuriser SSH, d'enregistrer la nouvelle machine virtuelle dans votre outil de surveillance et dans votre inventaire informatique, etc.

## En Résumé

Comme nous l'avons vu, il y a maintenant des solutions DevOps entièrement automatisées pour créer et déployer des machines virtuelles.

En même temps, cela représente un gain de temps indéniable, en particulier dans les environnements Cloud ou de centre de données. Il facilite également une conformité standard à travers tous les ordinateurs d'une société (serveurs et postes de travail) et une maintenance facile des modèles.

## Autres références

Pour un projet détaillé qui couvre également le déploiement de Rocky Linux et d'autres systèmes d'exploitation en utilisant la dernière version de vSphere, Packer et le plugiciel `Packer Plugin for vSphere`, veuillez visiter [ce projet](https://github.com/vmware-samples/packer-examples-for-vsphere).
