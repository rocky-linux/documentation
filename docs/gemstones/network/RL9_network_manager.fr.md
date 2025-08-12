---
title: RL9 - Gestionnaire de Réseau
author: tianci li
contributors: Steven Spencer
tags:
  - NetworkManager
  - RL9
---

# Suite d'outils de configuration réseau NetworkManager

En 2004, Red Hat a lancé le projet **NetworkManager**, qui vise à faciliter la réponse des utilisateurs de Linux aux besoins de la gestion actuelle du réseau, en particulier la gestion des réseaux sans fil. À l'heure actuelle, le projet est géré par GNOME. La [page d'accueil de NetworkManager se trouve ici](https://networkmanager.dev/).

Introduction officielle - NetworkManager est une suite d'outils standard de configuration du réseau sous Linux. Il prend en charge divers paramètres de réseau, du bureau au serveur et aux appareils mobiles et est parfaitement intégré aux environnements desktop populaires et aux outils de gestion de la configuration des serveurs.

La suite comprend principalement deux outils de ligne de commande :

- `nmtui`. Configure le réseau dans une interface graphique.

```bash
shell > dnf -y install NetworkManager NetworkManager-tui
shell > nmtui
```

| NetworkManager TUI               |    |
| -------------------------------- | -- |
| Modifier une connexion           |    |
| Activer une connexion            |    |
| Définir le nom d'hôte du système |    |
| Quitter                          |    |
|                                  | Ok |

- `nmcli`. Utilisez la ligne de commande pour configurer le réseau, soit une simple ligne de commande, soit une ligne de commande interactive.

```bash
Shell > nmcli connection show
NAME    UUID                                  TYPE      DEVICE
ens160  25106d13-ba04-37a8-8eb9-64daa05168c9  ethernet  ens160
```

Pour RockyLinux 8.x, nous avons expliqué comment configurer son réseau [ici](./nmtui.md). Vous pouvez utiliser `vim` pour éditer le fichier de configuration de la carte réseau dans le répertoire **/etc/sysconfig/network-script/** , ou vous pouvez utiliser `nmcli`/`nmtui`, qui sont tous deux acceptables.

## Règles de nommage pour udev device manager

Pour RockyLinux 9.x, si vous allez dans le répertoire **/etc/sysconfig/network-scripts/** , il y aura un **readme-ifcfg-rh.txt** texte de description qui vous invite à vous rendre dans le répertoire **/etc/NetworkManager/system-connections/**.

```bash
Shell > cd /etc/NetworkManager/system-connections/  && ls
ens160.nmconnection
```

La désignation `ens160` fait ici référence au nom de la carte réseau dans le système. Vous pouvez vous demander pourquoi le nom semble si étrange ? Ceci est dû au gestionnaire de périphériques `udev`. Il supporte de nombreux schémas de nommage différents. Par défaut, des noms fixes sont attribués en fonction des informations de micrologiciel, de topologie et d'emplacement. Ses avantages comprennent :

- Les noms de périphériques sont tout à fait prévisibles.
- Les noms de périphériques restent fixes même si vous ajoutez ou supprimez du matériel, car aucune renumérotation n'a lieu.
- Le matériel défectueux peut être remplacé en toute transparence.

Dans RHEL 9 et les systèmes d'exploitation de version communautaire correspondants, la dénomination cohérente des périphériques est activée par défaut. Le gestionnaire de périphériques `udev` va générer des noms de périphériques selon le schéma suivant :

| Schéma | Description                                                                                                                                                                                                                     | Exemple         |
| ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------- |
| 1      | Les noms de périphériques intègrent les numéros d'index fournis par le micrologiciel ou le BIOS pour les périphériques intégrés. Si cette information n'est ni disponible, ni applicable, `udev` utilise le schéma 2.           | eno1            |
| 2      | Les noms de périphériques intègrent les numéros d'index des slots de connexion PCI Express (PCIe) fournis par le micrologiciel ou le BIOS. Si cette information n'est pas disponible ou applicable, `udev` utilise le schéma 3. | ens1            |
| 3      | Les noms de périphériques intègrent l'emplacement physique du connecteur du matériel. Si cette information n'est pas disponible ou applicable, `udev` utilise le schéma 5.                                                      | enp2s0          |
| 4      | Les noms de périphériques intègrent l'adresse MAC. Red Hat Enterprise Linux n'utilise pas ce schéma par défaut, mais les administrateurs peuvent éventuellement l'utiliser.                                                     | enx525400d5e0fb |
| 5      | Le schéma traditionnel de nommage imprévisible du noyau. Si `udev` ne peut s'appliquer à aucun des autres schémas, le gestionnaire de périphériques utilise celui-ci.                                                           | eth0            |

Le gestionnaire de périphériques `udev` nomme le préfixe de la carte réseau en fonction du type d'interface :

- **en** pour Ethernet.
- **wl** pour LAN sans fil (WLAN).
- **ww** pour le réseau sans fil à zone étendue (WWAN).
- **ib**, réseau InfiniBand.
- **sl**, Serial Line Internet Protocol (slip)

Ajouter des suffixes au préfixe, tels que :

- **o** on-board_index_number
- **s** hot_plug_slot_index_number **[f]** fonction **[d]** device_id
- **x** adresse MAC
- **[P]** numéro de domaine **p** bus **s** slot **[f]** fonction **[d]** device_id
- **[P]** numéro de domaine **p** bus **s** slot **[f]** fonction **[u]** port usb **[c]** config **[i]** interface

Vous pouvez utiliser `man 7 systemd.net-naming-scheme` pour accéder à des informations plus détaillées.

## La commande `nmcli` (recommandée)

Les utilisateurs peuvent non seulement configurer le réseau en mode ligne de commande, mais aussi utiliser des commandes interactives pour configurer le réseau.

### `nmcli connection`

La commande `nmcli connection` peut afficher, supprimer, ajouter, modifier, éditer, activer, désactiver, etc.

Pour une utilisation spécifique, veuillez vous référer à `nmcli connection add --help`, `nmcli connection edit --help`, `nmcli connection modify --help` et ainsi de suite.

Par exemple, pour configurer une nouvelle connexion IP statique ipv4 en utilisant une ligne de commande et démarrer automatiquement, un exemple de commande à utiliser est le suivant :

```bash
Shell > nmcli  connection  add  type  ethernet  con-name   CONNECTION_NAME  ifname  NIC_DEVICE_NAME   \
ipv4.method  manual  ipv4.address "192.168.10.5/24"  ipv4.gateway "192.168.10.1"  ipv4.dns "8.8.8.8,114.114.114.114" \
ipv6.method  disabled  autoconnect yes
```

Si vous utilisez DHCP pour obtenir l'adresse ipv4, la commande nmcli est la suivante :

```bash
Shell > nmcli  connection  add  type ethernet con-name CONNECTION_NAME  ifname  NIC_DEVICE_NAME \
ipv4.method  auto  ipv6.method  disabled  autoconnect  yes
```

Avec la configuration choisie ci-dessus, la connexion n'est pas activée. Vous devez effectuer les opérations suivantes :

```bash
Shell > nmcli connection up  NIC_DEVICE_NAME
```

Entrez l'interface interactive à travers le mot clé `edit` sur la base de la connexion existante et modifiez-le :

```bash
Shell > nmcli connection  edit  CONNECTION_NAME
nmcli > help
```

Vous pouvez également modifier une ou plusieurs propriétés de la connexion directement à partir de la ligne de commande avec le mot-clé `modify`. Par exemple :

```bash
Shell > nmcli connection modify CONNECTION_NAME autoconnect yes ipv6.method dhcp
```

!!! info "Info"

    Les opérations via `nmcli` ou `nmtui` sont enregistrées de manière permanente et non temporaire.

#### Agrégation de liens

Certains utilisent plusieurs cartes réseau pour l'agrégation de liens. Au début, avec la technologie de **bonding**, il y avait sept modes de fonctionnement (0 à 6) et le mode `bonding` ne prenait en charge que deux cartes réseau au maximum. Plus tard, la technologie **teaming** est progressivement utilisée comme alternative, il existe cinq modes de fonctionnement et le mode `team` peut utiliser jusqu'à huit cartes réseau. Le lien comparatif entre le bonding et le teaming [peut être trouvé sur ce lien](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/networking_guide/sec-comparison_of_network_teaming_to_bonding).

Par exemple, le mode de bonding 0 :

```bash
Shell > nmcli  connection  add  type  bond  con-name  BOND_CONNECTION_NAME   ifname  BOND_NIC_DEVICE_NAME  mode 0
Shell > nmcli  connection  add  type  bond-slave   ifname NIC_DEVICE_NAME1   master  BOND_NIC_DEVICE_NAME
Shell > nmcli  connection  add  type  bond-slave   ifname NIC_DEVICE_NAME2   master  BOND_NIC_DEVICE_NAME
```

## Configuration de la carte réseau

!!! warning "Avertissement"

    Il n'est pas recommandé d'effectuer des modifications à l'aide de `vim` ou d'autres éditeurs.

Vous pouvez afficher des informations plus détaillées via `man 5 NetworkManager.conf` et `man 5 nm-settings-nmcli`.

Le contenu du fichier de configuration de la carte réseau NetworkManager est un fichier clé de style init. Par exemple :

```bash
Shell > cat /etc/NetworkManager/system-connections/ens160.nmconnection
[connection]
id=ens160
uuid=5903ac99-e03f-46a8-8806-0a7a8424497e
type=ethernet
interface-name=ens160
timestamp=1670056998

[ethernet]
mac-address=00:0C:29:47:68:D0

[ipv4]
address1=192.168.100.4/24,192.168.100.1
dns=8.8.8.8;114.114.114.114;
method=manual

[ipv6]
addr-gen-mode=default
method=disabled

[proxy]
```

- Les lignes qui commencent par le signe `#` et les lignes vides sont considérées comme des commentaires.
- Entouré des parenthèses [ et ] se trouve la section dans laquelle le titre est déclaré et en dessous se trouvent les paires clé-valeur spécifiques inclues. Chaque titre déclaré et sa paire clé-valeur forment un segment de syntaxe.
- N'importe quel fichier avec le suffixe `.nmconnection` peut être utilisé par **NetworkManager**.

Les titres comme nom de **connection** peuvent contenir ces paires de clé-valeur commune :

| nom de la clé  | Description                                                                                                                                                                        |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| id             | L'alias de `con-name`, dont la valeur est une chaîne.                                                                                                                            |
| uuid           | Identifiant universel unique, dont la valeur est une chaîne de caractères.                                                                                                         |
| type           | Le type de connexion, dont les valeurs peuvent être `ethernet`, `bluetooth`, `vpn`, `vlan`, etc. Vous pouvez utiliser `man nmcli` pour voir tous les types pris en charge. |
| interface-name | Le nom de l'interface réseau à laquelle cette connexion est liée et dont la valeur est un string.                                                                                  |
| timestamp      | Horodatage d'Unix, en secondes. Cette valeur est le nombre de secondes depuis le 1er janvier 1970.                                                                                 |
| autoconnect    | S'il est lancé automatiquement au démarrage du système. La valeur est de type booléen.                                                                                             |

**les noms de titres** éthernet peuvent contenir ces paires de clés communes :

| nom de la clé  | Description                                                                                                                                                                                                                                                                                                                                                                                                                 |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| mac-address    | Adresse MAC physique.                                                                                                                                                                                                                                                                                                                                                                                                       |
| mtu            | Unité de Transmission Maximale.                                                                                                                                                                                                                                                                                                                                                                                             |
| auto-negotiate | Sélection automatique du mode de transmission. La valeur est de type booléen.                                                                                                                                                                                                                                                                                                                                               |
| duplex         | Les valeurs possibles sont `half` (half-duplex) et `full` (full-duplex)                                                                                                                                                                                                                                                                                                                                                 |
| vitesse        | Spécifie le taux de transmission de la carte réseau. 100 signifie 100Mbit/s. Si **auto-negotiate=false**, la clé **speed** et la clé **duplex** doivent être définies ; si **auto-negotiate=true**, la vitesse utilisée est la vitesse négociée et l'écriture ici n'a pas d'effet (ceci n'est applicable qu'à la spécification BASE-T 802.3) ; lorsqu'elle est différente de zéro, la clé **duplex** doit avoir une valeur. |

Les titres des noms **ipv4** peuvent contenir ces paires de valeurs clés communes:

| Mot-clé   | Description                                                                                                                                         |
| --------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| addresses | Adresses IP assignées                                                                                                                               |
| gateway   | Passerelle (accès réseau) pour l'interface                                                                                                          |
| dns       | Serveurs de noms de domaine utilisés                                                                                                                |
| method    | La méthode à obtenir par IP. La valeur est de type `string`. La valeur peut être : `auto`, `disabled`, `link-local`, `manual`, `shared` |
