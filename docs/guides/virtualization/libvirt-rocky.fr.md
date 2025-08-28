---
title: libvirt et Rocky Linux
author: Howard Van Der Wal
contributors: Steven Spencer
tested with: 9.5
tags:
  - libvirt
  - kvm
  - virtualisation
---

## Introduction

[libvirt](https://libvirt.org/) est une API qui permet la virtualisation de presque tous les systèmes d'exploitation de votre choix avec la puissance de KVM comme hyperviseur et de QEMU comme émulateur.

Ce document fournit les instructions de configuration de `libvirt` sur Rocky Linux 9.

## Prérequis

- Une machine 64bit fonctionnant sous Rocky Linux 9.
- Assurez-vous de l'activation de la virtualisation dans les paramètres de votre BIOS. Si la commande suivante renvoie un résultat, cela signifie que l'activation de la virtualisation est terminée :

```bash
sudo grep -e 'vmx' /proc/cpuinfo
```

## Mise en place du référentiel et installation des packages

- Activez le dépôt EPEL (Extra Packages for Enterprise Linux) :

```bash
sudo dnf install -y epel-release
```

- Installez les packages requis pour `libvirt` (en option pour `virt-manager` si vous souhaitez utiliser une interface graphique pour gérer vos machines virtuelles) :

```bash
sudo dnf install -y bridge-utils virt-top libguestfs-tools bridge-utils virt-viewer qemu-kvm libvirt virt-manager virt-install
```

## Configuration de l'utilisateur `libvirt`

- Ajoutez votre utilisateur au groupe `libvirt`. Cela permet de gérer vos VM et d'utiliser des commandes telles que `virt-install` en tant qu'utilisateur non root :

```bash
sudo usermod -aG libvirt $USER
```

- Activez le groupe `libvirt` en utilisant la commande `newgrp` :

```bash
sudo newgrp libvirt
```

- Activez et démarrez le service `libvirtd` :

```bash
sudo systemctl enable --now libvirtd
```

## Configuration de l'interface `Bridge` pour un accès direct aux machines virtuelles

- Vérifiez les interfaces actuellement utilisées et notez l'interface principale avec une connexion Internet :

```bash
sudo nmcli connection show
```

- Supprimez l'interface connectée à Internet et toutes les connexions de pont virtuel actuellement présentes :

```bash
sudo nmcli connection delete <CONNECTION_NAME>
```

!!! warning "Avertissement"

```
Assurez-vous d'avoir un accès direct à la machine. Si vous configurez la machine via SSH, la connexion sera interrompue après la suppression de la connexion à l'interface principale.
```

- Créer la nouvelle connexion de pont :

```bash
sudo nmcli connection add type bridge autoconnect yes con-name <VIRTUAL_BRIDGE_CON-NAME> ifname <VIRTUAL_BRIDGE_IFNAME>
```

- Attribuez une adresse IP statique :

```bash
sudo nmcli connection modify <VIRTUAL_BRIDGE_CON-NAME> ipv4.addresses <STATIC_IP/SUBNET_MASK> ipv4.method manual
```

- Attribuez une adresse de passerelle :

```bash
sudo nmcli connection modify <VIRTUAL_BRIDGE_CON-NAME> ipv4.gateway <GATEWAY_IP>
```

- Attribuez une adresse DNS :

```bash
sudo nmcli connection modify <VIRTUAL_BRIDGE_CON-NAME> ipv4.dns <DNS_IP>
```

- Ajoutez la connexion esclave du pont :

```bash
sudo nmcli connection add type bridge-slave autoconnect yes con-name <MAIN_INTERFACE_WITH_INTERNET_ACCESS_CON-NAME> ifname <MAIN_INTERFACE_WITH_INTERNET_ACCESS_IFNAME> master <VIRTUAL_BRIDGE_CON-NAME>
```

- Démarrer la connexion du pont :

```bash
sudo nmcli connection up <VIRTUAL_BRIDGE_CON-NAME>
```

- Ajoutez la ligne `allow all` à `bridge.conf` :

```bash
sudo tee -a /etc/qemu-kvm/bridge.conf <<EOF
allow all
EOF
```

- Redémarrez le service `libvirtd` :

```bash
sudo systemctl restart libvirtd
```

## Installation de machine virtuelle

- Définissez la propriété du répertoire `/var/lib/libvirt` et de ses répertoires imbriqués sur votre utilisateur :

```bash
sudo chown -R $USER:libvirt /var/lib/libvirt/
```

- Vous pouvez créer une machine virtuelle sur la ligne de commande en utilisant la commande `virt-install`. Par exemple, pour créer une machine virtuelle Rocky Linux 9.5 Minimal, vous devez exécuter la commande suivante :

```bash
virt-install --name Rocky-Linux-9 --ram 4096 --vcpus 4 --disk path=/var/lib/libvirt/images/rocky-linux-9.img,size=20 --os-variant rocky9 --network bridge=virbr0,model=virtio --graphics none --console pty,target_type=serial --extra-args 'console=ttyS0,115200n8' --location ~/isos/Rocky-9.5-x86_64-minimal.iso
```

- Pour ceux qui souhaitent gérer leurs machines virtuelles via une interface graphique, `virt-manager` est l'outil parfait.

## Comment éteindre une machine virtuelle

- La commande `shutdown` accomplit ceci :

```bash
virsh shutdown --domain <YOUR_VM_NAME>
```

- Pour forcer l'arrêt d'une VM qui ne répond pas, utilisez la commande `destroy` :

```bash
virsh destroy --domain <YOUR_VM_NAME>
```

## Comment supprimer une machine virtuelle

- Utilisez la commande `undefine` :

```bash
virsh undefine --domain <YOUR_VM_NAME> --nvram
```

- Pour plus de commandes `virsh`, consultez les pages de manuel `virsh`.

## Conclusion

- libvirt offre de nombreuses possibilités et vous permet d'installer et de gérer vos machines virtuelles en toute simplicité. Si vous avez des ajouts ou des modifications à apporter à ce document que vous souhaiteriez partager, l’auteur vous invite volontiers à le faire.
