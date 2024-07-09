---
title: nmtui - Outil de gestion du réseau
author: tianci li
contributors: Steven Spencer, Neil Hanlon
update: 2021-10-23
---

# Présentation de nmtui

Pour les utilisateurs qui sont nouveaux sur GNU/Linux la première chose à considérer est comment connecter la machine à Internet après avoir installé le système d'exploitation. Cet article vous indiquera comment configurer l'adresse IP, le masque de sous-réseau, la passerelle et le DNS. Il y a plusieurs moyens pour y parvenir. Que vous soyez novice ou expérimenté, vous pourrez débuter rapidement.

## nmtui

`NetworkManager` est une suite standard d'outils de configuration réseau Linux qui prend en charge les environnements serveur et de bureau. De nos jours, la plupart des distributions populaires le supportent. Cet ensemble d'outils de configuration réseau est adapté aux versions de Rocky Linux 8 et ultérieures. Si vous voulez configurer graphiquement les informations du réseau (en utilisant la commande `nmtui`), vous devez procéder comme suit :

```bash
shell > dnf -y install NetworkManager NetworkManager-tui
shell > nmtui
```

| NetworkManager TUI (nmtui)       |          |
| -------------------------------- | -------- |
| Modifier une connexion           |          |
| Activer une connexion            |          |
| Définir le nom d'hôte du système |          |
| Quitter                          |          |
|                                  | \<OK\> |

Vous pouvez utiliser la touche ++tab++ ou la touche ++arrow-up++ ++arrow-down++ ++arrow-left++ ++arrow-right++ pour sélectionner une section spéciale. Si vous souhaitez modifier les informations réseau, veuillez sélectionner **Edit a connexion** puis ++enter++. Changez la carte réseau et sélectionnez **Edit..** pour l'éditer.

### DHCP IPv4

Pour IPv4, s'il s'agit d'obtenir des informations réseau avec DHCP, sélectionnez simplement *CONFIGURATION IPv4* **&lt;Automatic&gt;** et exécutez `systemctl restart NetworkManager.service` dans le terminal. Cela fonctionne dans la plupart des cas. Dans de rares cas, vous devez désactiver et réactiver votre carte réseau pour que la modification prenne effet. Par exemple : `nmcli connection down ens33`, `nmcli connection up ens33`

### Corriger manuellement les informations sur le réseau

Si vous voulez corriger manuellement toutes les informations du réseau IPv4, vous devez sélectionner **&lt;Manual&gt;** après *CONFIGURATION IPv4* et les jouter ligne par ligne. Par exemple, l'auteur utilise ceci :

| Élément      | Valeur           |
| ------------ | ---------------- |
| Adresses     | 192.168.100.4/24 |
| Passerelle   | 192.168.100.1    |
| Serveurs DNS | 8.8.8.8          |

Puis cliquez sur \< OK \>, retournez à l'interface de terminal étape par étape et exécutez `systemctl restart NetworkManager.service`. De même, dans de rares cas, la carte réseau doit être rallumée pour que les modifications prennent effet.

## Changer directement les fichiers de configuration

Toutes les distributions RHEL <font color="red">7.x</font> ou <font color="red">8.x</font> que ce soit en amont ou en aval, sont configurées de la même manière. Le fichier de configuration des informations réseau est stocké dans le répertoire **/etc/sysconfig/network-scripts/** et une carte réseau correspond exactement à un fichier de configuration. Le fichier de configuration contient de nombreux paramètres, comme indiqué dans la table suivante. Remarque! Les paramètres doivent être indiqués en majuscules.

!!! warning "Avertissement"

    Dans les distributions RHEL 9.x, l'emplacement du répertoire où le fichier de configuration du réseau est stocké a été modifié, c'est-à-dire **/etc/NetworkManager/system-connections/**. Veuillez consulter [ce site](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html-single/configuring_and_managing_networking/index) pour plus d'informations.

```bash
shell > ls /etc/sysconfig/network-scripts/
ifcfg-ens33
```

| Nom du paramètre     | Signification                                                                                                                                                                                                                                                              | Exemple                             |
| -------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| DEVICE               | Nom logique du périphérique système                                                                                                                                                                                                                                        | DEVICE=ens33                        |
| ONBOOT               | Suivant que la carte réseau démarre automatiquement avec le système ou non, vous pouvez choisir yes ou no                                                                                                                                                                  | ONBOOT=yes                          |
| TYPE                 | Type d'interface de carte réseau, généralement Ethernet                                                                                                                                                                                                                    | TYPE=Ethernet                       |
| BOOTPROTO            | La façon d'obtenir l'adresse IP peut être une acquisition dynamique DHCP ou bien une configuration manuelle statique à l'aide de `static`                                                                                                                                | BOOTPROTO=static                    |
| IPADDR               | L'adresse IP de la carte réseau, lorsque BOOTPROTO=static, ce paramètre prendra effet                                                                                                                                                                                      | IPADDR=192.168.100.4                |
| HWADDR               | Adresse matérielle, i.e., adresse MAC                                                                                                                                                                                                                                      | HWADDR=00:0C:29:84:F6:9C            |
| NETMASK              | Valeur décimale du masque de sous-réseau                                                                                                                                                                                                                                   | NETMASK=255.255.255.0               |
| PRÉFIXE              | Masque de sous-réseau, représenté par des nombres                                                                                                                                                                                                                          | PREFIX=24                           |
| GATEWAY              | Passerelle, s'il y a plusieurs cartes réseau, ce paramètre ne peut apparaître qu'une seule fois                                                                                                                                                                            | GATEWAY=192.168.100.1               |
| PEERDNS              | Quand c'est `yes`, les paramètres DNS définis ici modifieront le fichier /etc/resolv.conf. Quand c'est `no`, /etc/resolv.conf ne sera pas modifié. Lorsque vous utilisez DHCP, la valeur par défaut est `yes`                                                        | PEERDNS=yes                         |
| DNS1                 | Le DNS principal est sélectionné, il prend effet uniquement lorsque PEERDNS=no                                                                                                                                                                                             | DNS1=8.8.8.8                        |
| DNS2                 | DNS alternatifs, seulement en vigueur lorsque PEERDNS=no                                                                                                                                                                                                                   | DNS2=114.114.114.114                |
| BROWSER_ONLY         | Autoriser uniquement les navigateurs                                                                                                                                                                                                                                       | BROWSER_ONLY=no                     |
| USERCTL              | Si les utilisateurs ordinaires sont autorisés à contrôler le périphérique de la carte réseau, `yes` signifie autoriser, `no` le cas contraire                                                                                                                          | USERCTL=no                          |
| UUID                 | Code d'identification unique universel, sa fonction principale est d'identifier le matériel, généralement parlant, il n'est pas nécessaire de l'indiquer                                                                                                                   |                                     |
| PROXY_METHOD         | La méthode Proxy, habituellement aucune, peut être laissée vide                                                                                                                                                                                                            |                                     |
| IPV4_FAILURE_FATAL | Si c'est `yes`, cela signifie que le périphérique sera désactivé après l'échec de la configuration ipv4 ; si c'est `no`, cela signifie qu'il ne sera pas désactivé.                                                                                                    | IPV4_FAILURE_FATAL=no             |
| IPV6INIT             | S'il faut activer IPV6, `yes` pour activer, `no` pour ne pas l'activer. Lorsque IPV6INIT=`yes`, les deux paramètres IPV6ADDR et IPV6_DEFAULTGW peuvent également être activés. La première représente l'adresse IPV6 et la seconde représente la passerelle désignée | IPV6INIT=yes                        |
| IPV6_AUTOCONF        | Si vous voulez utiliser la configuration automatique IPV6, yes signifie utiliser; no le cas contraire                                                                                                                                                                      | IPV6_AUTOCONF=yes                   |
| IPV6_DEFROUTE        | S'il faut donner à IPV6 la route par défaut                                                                                                                                                                                                                                | IPV6_DEFROUTE=yes                   |
| IPV6_FAILURE_FATAL | Après l'échec de la configuration IPV6, désactiver le périphérique                                                                                                                                                                                                         | IPV6_FAILURE_FATAL=no             |
| IPV6_ADDR_GEN_MODE | Générer le modèle d'adresse IPV6, les valeurs optionnelles sont stable-privacy et eui64                                                                                                                                                                                    | IPV6_ADDR_GEN_MODE=stable-privacy |

Une fois le fichier de configuration modifié avec succès, n'oubliez pas de redémarrer le service de carte réseau avec la commande `systemctl restart NetworkManager.service`.

### Configuration recommandée pour IPV4

```bash
TYPE=Ethernet
ONBOOT=yes
DEVICE=ens33
USERCTL=no
IPV4_FAILURE_FATAL=no
BROWSER_ONLY=no
BOOTPROTO=static
PEERDNS=no
IPADDR=192.168.100.4
PREFIX=24
GATEWAY=192.168.100.1
DNS1=8.8.8.8
DNS2=114.114.114.114
```

### Configuration recommandée pour IPV6

```bash
TYPE=Ethernet
ONBOOT=yes
DEVICE=ens33
USERCTL=no
BROWSER_ONLY=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
```

## Voir les informations sur le réseau

`ip a` ou `nmcli device show`
