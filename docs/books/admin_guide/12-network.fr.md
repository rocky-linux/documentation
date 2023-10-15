---
title: Implémentation du Réseau
---

# Implémentation du Réseau

Dans ce chapitre, vous apprendrez comment travailler avec, utiliser et gérer le réseau.

****

**Objectifs** : Dans ce chapitre vous apprendrez à :

:heavy_check_mark: Configurer un poste de travail pour utiliser DHCP ;  
:heavy_check_mark: Configurer un poste de travail pour utiliser une configuration statique ;   
:heavy_check_mark: Configurer un poste de travail pour utiliser une passerelle ;   
:heavy_check_mark: Configurer un poste de travail pour utiliser des serveurs DNS ;   
:heavy_check_mark: Dépanner le réseau d'un poste de travail.

:checkered_flag: **réseau**, **linux**, **ip**

**Connaissances** : :star: :star:  
**Complexité** : :star: :star:

**Temps de lecture : **30 minutes

****

## Généralités

Pour illustrer ce chapitre, nous utiliserons l'architecture suivante.

![Illustration de notre architecture réseau](images/network-001.png)

Cela nous permettra d'envisager :

* intégration dans un réseau local (LAN) ;
* la configuration d'une passerelle pour atteindre un serveur distant ;
* la configuration d'un serveur DNS et l'implémentation de la résolution des noms.

Les paramètres minimums à définir pour la machine sont :

* le nom de la machine ;
* l'adresse IP ;
* le masque du sous-réseau.

Exemple :

*   `pc-rocky` ;
*   `192.168.1.10` ;
*   `255.255.255.0`.

La notation appelée CIDR est de plus en plus fréquente : 192.168.1.10/24

Les adresses IP sont utilisées pour le routage approprié des messages (paquets). Ils sont divisés en deux parties :

* la partie fixe, identifiant le réseau ;
* l'identifiant de l'hôte dans le réseau.

Le masque de sous-réseau est un ensemble de **4 octets** destiné à isoler :

* l'adresse réseau (**NetID** ou **SubnetID**) en effectuant un ET logique entre l'adresse IP et le masque ;
* l'adresse de l'hôte (**HostID**) en effectuant un ET logique entre l'adresse IP et le complément du masque.

Il existe également des adresses spécifiques au sein d'un réseau, qui doivent être identifiées. La première adresse d'une plage ainsi que la dernière ont un rôle particulier :

* La première adresse d'une plage est l'**adresse réseau**. Elle sert à identifier les réseaux et à acheminer l'information d'un réseau vers un autre.

* La dernière adresse d'une plage est l'**adresse de diffusion**. Elle est utilisée pour diffuser des informations à toutes les machines du réseau.

### Adresse MAC / adresse IP

Une **adresse MAC** est un identifiant physique enregistré dans l'usine sur l'appareil. On parle parfois de l'adresse matérielle. Elle se compose de 6 octets souvent définis sous forme hexadécimale (par exemple 5E:FF:56:A2:AF:15). Elle est composée de : 3 octets de l'identifiant du fabricant et 3 octets du numéro de série.

!!! warning "Avertissement"

    De nos jours ces affirmations ont un peu perdu leur signification dans le cadre de la virtualisation. Il existe également des solutions logicielles pour changer l'adresse MAC.

Une adresse IP (**Protocole Internet**) est un numéro d'identification attribué en permanence ou temporairement à chaque périphérique connecté à un réseau informatique en utilisant le protocole Internet. Une partie définit l'adresse réseau (NetID ou SubnetID selon le cas), l'autre partie définit l'adresse de l'hôte dans le réseau (HostID). La taille relative de chaque partie varie selon le (sous-)masque du réseau.

Une adresse IPv4 définit une adresse sur 4 octets. Le nombre d'adresses disponibles étant proche de la saturation, un nouveau standard a été créé, l'IPv6 défini sur 16 octets.

Une adresse IPv6 est souvent représentée par 8 groupes de 2 octets séparés par un deux-points. Des zéros non-significatifs peuvent être omis, un ou plusieurs groupes de 4 zéros consécutifs peuvent être remplacés par un double deux-points.

Les masques de sous-réseau ont entre 0 et 128 bits. (par exemple 21ac:0000:0000:0611:21e0:00ba:321b:54da/64 ou 21ac::611:21e0:ba:321b:54da/64)

Dans une adresse Web ou une URL (Uniform Resource Locator), une adresse IP peut être suivie par un deux-points et l'adresse du port (qui indique l'application à laquelle les données sont destinées). Aussi pour éviter la confusion dans une URL, l'adresse IPv6 est écrite entre crochets [ ], deux-points, adresse du port.

Les adresses IP et MAC doivent être uniques sur un réseau !

### Domaine DNS

Les machines clientes peuvent faire partie d'un domaine DNS (**Domain Name System**, par exemple `mydomain.lan`).

Le nom complet de la machine (**FQDN**) devient `pc-rocky.mydomain.lan`.

Un ensemble d'ordinateurs peuvent être regroupés en un ensemble logique de résolution de noms, appelé domaine DNS. Un domaine DNS n'est évidemment pas limité à un seul réseau physique.

Pour qu'un ordinateur fasse partie d'un domaine DNS, il faut lui attribuer un suffixe DNS (ici `mydomain.lan`) ainsi que les serveurs qu'il peut interroger.

### Rappel du modèle OSI

!!! note "Aide mémoire"

    Pour mémoriser l'ordre des couches du modèle OSI, rappelez-vous la phrase suivante : __Please Do Not Touch Steven's Pet Alligator__.

| Couche           | Protocoles                                                   |
| ---------------- | ------------------------------------------------------------ |
| 7 - Application  | POP, IMAP, SMTP, SSH, SNMP, HTTP, FTP, ...                   |
| 6 - Présentation | ASCII, MIME, ...                                             |
| 5 - Session      | TLS, SSL, NetBIOS, ...                                       |
| 4 - Transport    | TLS, SSL, TCP, UDP, ...                                      |
| 3 - Réseau       | IPv4, IPv6, ARP, ...                                         |
| 2 - Data Link    | Ethernet, WiFi, Token Ring, ...                              |
| 1 - Physique     | Câbles, fibres optiques, ondes radio, pigeons voyageurs, ... |

**La couche 1** (Physique) supporte la transmission sur un canal de communication (Wifi, fibre optique, câble RJ, etc.). Unité: le bit.

**La couche 2** (Data Link) supports network topology (token-ring, star, bus, etc.), data splitting and transmission errors. Unité: le frame.

**La couche 3** (Réseau) supporte la transmission de données de bout en bout (routage IP = passerelle).</strong> Unité : le paquet.

**La couche 4** (Transport) prend en charge le cryptage et le contrôle de flux du type de service (connecté ou non). Unité : le segment ou le datagramme.

**La couche 5** (Session) supporte la communication entre deux ordinateurs.

**La couche 6** (Présentation) représente la zone indépendante des données à la couche d'application. Fondamentalement, cette couche traduit du format réseau au format de l'application, ou du format de l'application au format réseau.

**La couche 7** (Application) représente le contact avec l'utilisateur. It provides the services offered by the network: http, dns, ftp, imap, pop, smtp, etc.

## Le nommage des interfaces

*lo* est l'interface "**loopback**" qui permet aux programmes TCP/IP de communiquer entre eux sans quitter la machine locale. Ceci permet de tester si le module réseau **du système fonctionne correctement** et permet également d'utiliser ping pour vérifier la connection avec localhost. Tous les paquets qui entrent via localhost passent par localhost. Les paquets reçus sont les mêmes que les paquets envoyés.

Le noyau Linux attribue des noms d'interface avec un préfixe spécifique selon le type. Traditionnellement, toutes les interfaces **Ethernet** , par exemple, ont commencé à **ème**. Le préfixe a été suivi d'un nombre, le premier étant 0 (eth0, eth1, eth2...). Les interfaces wifi ont reçu un préfixe de wlan.

Sur les distributions Rocky8 Linux, le système nommera les interfaces avec la nouvelle convention suivante où "X" représente un nombre :

* `enoX`: périphériques embarqués
* `ensX`: hotplug slot PCI Express
* `enpXsX`: emplacement physique/géographique du connecteur du matériel
* ...

## Utilisation de la commande `ip`

Oubliez l'ancienne commande `ifconfig` ! Pensez à `ip` !

!!! note "Remarque"

    Commentaire pour les administrateurs d'anciens systèmes Linux :
    
    La commande historique de gestion du réseau est « ifconfig ». Cette commande a été remplacée par la commande `ip`, qui est déjà bien connue des administrateurs réseau.
    
    La commande `ip` est la seule commande pour gérer **l'adresse IP, ARP, routage, etc.**.
    
    La commande `ifconfig` n'est plus installée par défaut dans Rocky8.
    
    Il est important de prendre dès maintenant de bonnes habitudes.

## Le nom d'hôte

La commande `hostname` affiche ou définit le nom d'hôte du système

```
hostname [-f] [hostname]
```

| Option | Observation                                          |
| ------ | ---------------------------------------------------- |
| `-f`   | Affiche le FQDN                                      |
| `-i`   | Affiche des informations sur l'adresse IP du système |

!!! tip "Astuce"

    Cette commande est utilisée par divers programmes réseau pour identifier la machine.

Pour assigner un nom d'hôte, il est possible d'utiliser la commande `hostname` , mais les changements ne seront pas conservés au prochain démarrage. La commande sans arguments affiche le nom de l'hôte.

Pour définir le nom de l'hôte, le fichier `/etc/sysconfig/network` doit être modifié :

```
NETWORKING=yes
HOSTNAME=pc-rocky.mondomaine.lan
```

Le script de démarrage de RedHat consulte également le fichier `/etc/hosts` pour résoudre le nom d'hôte du système.

Lorsque le système démarre, Linux évalue la valeur de `HOSTNAME` dans le fichier `/etc/sysconfig/network`.

Il utilise ensuite le fichier `/etc/hosts` pour évaluer l'adresse IP principale du serveur. Il déduit le nom de domaine DNS.

Il est donc essentiel de remplir ces deux fichiers avant toute configuration des services de réseau.

!!! tip "Astuce"

    Pour savoir si cette configuration est effectuée correctement, les commandes `hostname` et `hostname -f` doivent renvoyer les valeurs attendues.

## Fichier /etc/hosts

Le fichier `/etc/hosts` est une table statique de mappage de nom d'hôte, qui suit le format suivant :

```
@IP <hostname>  [alias]  [# comment]
```

Exemple de fichier `/etc/host` :

```
127.0.0.1       localhost localhost.localdomain
::1             localhost localhost.localdomain
192.168.1.10    rockstar.rockylinux.lan rockstar
```

Le fichier `/etc/hosts` est toujours utilisé par le système, en particulier au moment où le FQDN du système est déterminé.

!!! tip "Astuce"

    RedHat recommande de remplir au moins une ligne avec le nom du système.

Si le service **DNS** (**D**omain **N**ame **S**ervice) n'est pas en place, vous devez renseigner tous les noms dans le fichier hosts pour chacune de vos machines.

Le fichier `/etc/hosts` contient une ligne par entrée, avec l'adresse IP, le FQDN, puis le nom de l'hôte (dans cet ordre) et une série d'alias (alias1 alias2 ...). L'alias est facultatif.

## Le fichier `/etc/nsswitch.conf`

La **NSS** (**N**nom **S**ervice **S**witch) permet de substituer des fichiers de configuration (par ex. `/etc/passwd`, `/etc/group`, `/etc/hosts`) pour être remplacés par une ou plusieurs bases de données centralisées.

Le fichier `/etc/nsswitch.conf` est utilisé pour configurer les bases de données du service de noms.

```
passwd: files
shadow: files
group: files

hosts: files dns
```

In this case, Linux will first look for a host name match (`hosts:` line) in the `/etc/hosts` file (`files` value) before querying DNS (`dns` value)! Ce comportement peut simplement être modifié en éditant le fichier `/etc/nsswitch.conf`.

Bien sûr, il est possible d'imaginer interroger un LDAP, MySQL ou un autre serveur en configurant le service de noms pour répondre aux requêtes système des hôtes, utilisateurs, groupes, etc.

La résolution du service de nom peut être testée avec la commande `getent` que nous verrons plus tard dans ce cours.

## Le fichier `/etc/resolv.conf`

Le fichier `/etc/resolv.conf` contient la configuration de résolution du nom DNS.

```
#Generated by NetworkManager
domain mondomaine.lan
search mondomaine.lan
nameserver 192.168.1.254
```

!!! tip "Astuce"

    Ce fichier est désuet. Il n'est plus rempli directement!

Les nouvelles générations de distributions ont généralement intégré le service `NetworkManager`. Ce service vous permet de gérer la configuration plus efficacement, en mode graphique ou en mode console.

Il permet d'ajouter des serveurs DNS à partir du fichier de configuration d'une interface réseau. Il remplit alors automatiquement le fichier `/etc/resolv.conf` qui ne devrait jamais être modifié directement, sinon les changements de configuration seront perdus la prochaine fois que le service réseau sera démarré.

## La `commande ip`

La commande `ip` du paquet `iproute2` vous permet de configurer une interface et sa table de routage.

Afficher les interfaces :

```
[root]# ip link
```

Afficher les informations sur les interfaces :

```
[root]# addr ip afficher
```

Afficher les informations d'une interface :

```
[root]# ip addr show eth0
```

Afficher la table ARP :

```
[root]# ip neigh
```

Toutes les commandes de gestion de réseau historiques ont été regroupées sous la commande `ip` , bien connue des administrateurs réseau.

## Configuration DHCP

Le protocole **DHCP** (**D**ynamique **H**ost **C**ontrol **P**rotocol) vous permet d'obtenir automatiquement une configuration IP complète via le réseau. C'est le mode de configuration par défaut d'une interface réseau sous Rocky Linux, ce qui explique pourquoi un système connecté au réseau d'un routeur Internet peut fonctionner sans configuration supplémentaire.

La configuration des interfaces sous Rocky Linux se fait dans le répertoire `/etc/sysconfig/network-scripts/`.

Pour chaque interface Ethernet, un fichier `ifcfg-ethX` permet la configuration de l'interface associée.

```
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=dhcp
HWADDR=00:0c:29:96:32:e3
```

*  Nom de l'interface (doit être dans le nom du fichier) :

```
DEVICE=eth0
```

* Démarrer automatiquement l'interface :

```
ONBOOT=yes
```

* Faire une requête DHCP au démarrage de l'interface :

```
BOOTPROTO=dhcp
```

* Spécifiez l'adresse MAC (facultative mais utile lorsqu'il y a plusieurs interfaces) :

```
HWADDR=00:0c:29:96:32:e3
```

!!! tip "Astuce"

    Si le service NetworkManager est installé, les modifications seront prises en compte automatiquement. Dans le cas contraire, vous devez redémarrer le service réseau.

* Redémarrer le service réseau :

```
[root]# systemctl restart NetworkManager
```

## Configuration statique

La configuration statique nécessite au moins :

```
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=none
IPADDR=192.168.1.10
NETMASK=255.255.255.0
```

* Ici, nous remplacons "dhcp" par "none" qui équivaut à la configuration statique :

```
BOOTPROTO=none
```

* Adresse IP :

```
IPADDR=192.168.1.10
```

* Subnet mask:

```
NETMASK=255.255.255.0
```

* Le masque peut être spécifié avec un préfixe :

```
PREFIX=24
```

!!! warning "Avertissement"

    Vous devez utiliser NETMASK ou bien PREFIX - mais pas les deux !

## Routage

![Architecture réseau avec passerelle](images/network-002.png)

```
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=aucun
HWADDR=00:0c:29:96:32:e3
IPADDR=192.168.1.10
NETMASK=255.255.255.0
GATEWAY=192.168.1.254
```

La commande `ip route` :

```
[root]# ip route show
192.168.1.0/24 dev eth0 […] src 192.168.1.10 metric 1
default via 192.168.1.254 dev eth0 proto static
```

C'est une bonne idée de savoir comment lire une table de routage, en particulier dans un environnement avec plusieurs interfaces réseau.

* Dans l'exemple montré, le `192.168.1. /24` le réseau est accessible directement depuis le périphérique `eth0` , donc il y a une métrique à `1` (ne traverse pas un routeur).

* Tous les autres réseaux autres que le précédent seront accessibles, à nouveau à partir du périphérique `eth0`, mais cette fois les paquets seront adressés à une passerelle `192.168.1.254`. Le protocole de routage est un protocole statique (bien qu'il soit possible d'ajouter une route à une adresse assignée dynamiquement dans Linux).

## Résolution du nom

Un système doit résoudre :

* FQDNs vers les adresses IP

```
www.free.fr = 212.27.48.10
```

* Adresses IP vers les noms

```
212.27.48.10 = www.free.fr
```

* ou pour obtenir des informations sur une zone :

```
MX de free.fr = 10 mx1.free.fr + 20 mx2.free.fr
```

```
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=none
HWADDR=00:0c:29:96:32:e3
IPADDR=192.168.1.10
NETMASK=255.255.255.0
GATEWAY=192.168.1.254
DNS1=172.16.1.2
DNS2=172.16.1.3
DOMAIN=rockylinux.lan
```

Dans ce cas, pour atteindre le DNS, vous devez passer par la passerelle.

```
 #Generated by NetworkManager
 domain mondomaine.lan
 search mondomaine.lan
 nameserver 172.16.1.2
 nameserver 172.16.1.3
```

Le fichier a été mis à jour par NetworkManager.

## Dépannage

La commande `ping` envoie des datagrammes à une autre machine et attend une réponse.

C'est la commande de base pour tester le réseau, car elle vérifie la connectivité entre votre interface réseau et une autre.

Syntaxe de la commande `ping` :

```
ping [-c numérique] destination
```

L'option `-c` (count) vous permet d'arrêter la commande après le compte à rebours en secondes.

Exemple :

```
[root]# ping –c 4 localhost
```

!!! tip "Astuce"

    Valider la connectivité progressivement en partant localement

1) Valider la couche logicielle TCP/IP

```
[root]# ping localhost
```

Le "ping" de la boucle intérieure ne détecte pas de défaillance matérielle sur l'interface réseau. Il détermine simplement si la configuration du logiciel IP est correcte.

2) Valider la carte réseau

```
[root]# ping 192.168.1.10
```

Pour déterminer si la carte réseau est fonctionnelle, nous devons maintenant lancer un ping avec son adresse IP. La carte réseau, si le câble réseau n'est pas connecté, doit être en état "inactivé".

Si le ping ne fonctionne pas, vérifiez d'abord le câble réseau à votre commutateur réseau et reassemblez l'interface (voir la commande `if up`), puis vérifiez l'interface elle-même.

3) Valider la connectivité de la passerelle

```
[root]# ping 192.168.1.254
```

4) Valider la connectivité d'un serveur distant

```
[root]# ping 172.16.1.2
```

5) Valider le service DNS

```
[root]# ping www.free.fr
```

### La commande `dig`

La commande `dig` est utilisée pour interroger le serveur DNS.

La syntaxe de la commande `dig` :

```
dig [-t type] [+short] [name]
```

Exemples :

```
[root]# dig +short rockylinux.org
76.223.126.88
[root]# dig -t MX +short rockylinux.org                                                          ✔
5 alt1.aspmx.l.google.com.
...
```

La commande `dig` est utilisée pour interroger les serveurs DNS. C'est très verbeux par défaut, mais ce comportement peut être modifié avec l'option `+short`.

Il est également possible de spécifier un **type d'enregistrement DNS** à résoudre, comme un **type MX** pour obtenir des informations sur les échangeurs de courriels pour un domaine.

### La commande `getent`

La commande `getent` (get entry) est utilisée pour obtenir une entrée NSSwitch (`hosts` + `dns`)

Syntaxe de la commande `getent` :


```
getent hosts name
```

Exemple :

```
[root]# getent hosts rockylinux.org
  76.223.126.88 rockylinux.org
```

Interroger seulement un serveur DNS peut retourner un résultat erroné qui ne prend pas en compte le contenu d'un fichier `hosts` bien que cela devrait être rare de nos jours.

Pour prendre également en compte le fichier `/etc/hosts` . le service de nom NSSwitch doit être interrogé, ce qui prendra en charge toute résolution DNS.

### La commande `ipcalc`

La commande `ipcalc` (**ip calcul**) est utilisée pour calculer l'adresse d'un réseau ou de diffusion à partir d'une adresse IP et d'un masque.

Syntaxe de la commande `ipcalc` :

```
ipcalc  [options] IP <netmask>
```

Exemple :

```
[root]# ipcalc –b 172.16.66.203 255.255.240.0
BROADCAST=172.16.79.255
```

!!! tip "Astuce"

    Cette commande est intéressante si elle est suivie d'une redirection permettant de compiler automatiquement les fichiers de configuration de l'interface :

    ```
    [root]# ipcalc –b 172.16.66.203 255.255.240.0 >> /etc/sysconfig/network-scripts/ifcfg-eth0
    ```

| Option | Observation                               |
| ------ | ----------------------------------------- |
| `-b`   | Affiche l'adresse de diffusion.           |
| `-R`   | Affiche l'adresse et le masque du réseau. |

`ipcalc` est un moyen simple de calculer les informations IP d'un hôte. Les diverses options indiquent quelles informations `ipcalc` doivent être affichées sur la sortie standard. Plusieurs options peuvent être spécifiées. Une adresse IP sur laquelle opérer doit être spécifiée. La plupart des opérations nécessitent également un masque réseau ou un préfixe CIDR.

| Option courte | Option longue | Observation                                                                                                                                                                                                                                               |
| ------------- | ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `-b`          | `--broadcast` | Affiche l'adresse de diffusion de l'adresse IP donnée et le masque réseau.                                                                                                                                                                                |
| `-h`          | `--hostname`  | Affiche le nom d'hôte de l'adresse IP fournie via DNS.                                                                                                                                                                                                    |
| `-n`          | `--netmask`   | Calcule le masque de réseau pour l'adresse IP donnée. Suppose que l'adresse IP fait partie d'un réseau complet de classe A, B ou C. De nombreux réseaux n'utilisent pas de masques de réseau par défaut, auquel cas une valeur incorrecte sera retournée. |
| `-p`          | `--prefix`    | Indique le préfixe de l'adresse masque/IP.                                                                                                                                                                                                                |
| `-n`          | `--network`   | Indique l'adresse réseau de l'adresse IP et du masque donnés.                                                                                                                                                                                             |
| `-s`          | `--silent`    | Ne jamais afficher les messages d'erreur.                                                                                                                                                                                                                 |

### La commande `ss`

La commande `ss` (**statistiques de sockets**) affiche les ports d'écoute sur le réseau.

Syntaxe de la commande `ss` :

```
ss [-tuna]
```

Exemple :

```
[root]# ss –tuna
tcp   LISTEN   0   128   *:22   *:*
```

Les commandes `ss` et `netstat` (à suivre) seront très importantes pour le reste de votre carrière Linux.

Lors de l'implémentation des services réseau, il est très courant de vérifier avec l'une de ces deux commandes que le service écoute sur les ports attendus.

### La commande `netstat`

!!! warning "Avertissement"

    La commande `netstat` est désormais obsolète et n'est plus installée par défaut sur Rocky Linux. Vous pouvez toujours trouver certaines versions de Linux sur lesquelles il est installé, mais il est préférable d'utiliser « ss » à la place de « netstat ».

La commande `netstat` (**statistiques du réseau**) affiche les ports d'écoute sur le réseau.

Syntaxe de la commande `netstat` :

```
netstat -tapn
```

Exemple :

```
[root]# netstat –tapn
tcp  0  0  0.0.0.0:22  0.0.0.0:*  LISTEN 2161/sshd
```

### Conflit d'adresse IP ou MAC

Une mauvaise configuration peut faire que plusieurs interfaces utilisent la même adresse IP. Cela peut se produire lorsqu'un réseau a plusieurs serveurs DHCP ou quand la même adresse IP est assignée manuellement plusieurs fois.

Lorsque le réseau ne fonctionne pas, et quand un conflit d'adresse IP peut en être la cause, il est possible d'utiliser le logiciel `art-scan` (nécessite EPEL) :

```
$ dnf install arp-scan
```

Exemple :

```
$ arp-scan -I eth0 -l

172.16.1.104  00:01:02:03:04:05       3COM CORPORATION
172.16.1.107  00:0c:29:1b:eb:97       VMware, Inc.
172.16.1.250  00:26:ab:b1:b7:f6       (Unknown)
172.16.1.252  00:50:56:a9:6a:ed       VMWare, Inc.
172.16.1.253  00:50:56:b6:78:ec       VMWare, Inc.
172.16.1.253  00:50:56:b6:78:ec       VMWare, Inc. (DUP: 2)
172.16.1.253  00:50:56:b6:78:ec       VMWare, Inc. (DUP: 3)
172.16.1.253  00:50:56:b6:78:ec       VMWare, Inc. (DUP: 4)
172.16.1.232  88:51:fb:5e:fa:b3       (Unknown) (DUP: 2)
```

!!! tip "Astuce"

    Comme le montre l’exemple précédent, il est même possible d’avoir des conflits d’adresses MAC ! Ces problèmes sont causés par les technologies de virtualisation et le clonage de machines virtuelles.

## Configuration à chaud

La commande `IP` peut ajouter instantanément une adresse IP à une interface

```
ip addr add @IP dev DEVICE
```

Exemple :

```
[root]# ip addr add 192.168.2.10 dev eth1
```

La commande `ip` permet aussi l'activation ou la désactivation d'une interface :

```
ip link set DEVICE up
ip link set DEVICE down
```

Exemple :

```
[root]# ip link set eth1 up
[root]# ip link set eth1 down
```

La commande `ip` peut être utilisée pour ajouter une route :

```
ip route add [default|netaddr] via @IP [dev device]
```

Exemple :

```
[root]# ip route add default via 192.168.1.254
[root]# ip route add 192.168.100.0/24 via 192.168.2.254 dev eth1
```

## En résumé

Les fichiers utilisés dans ce chapitre sont :

![Synthèse des fichiers implémentés dans la partie réseau](images/network-003.png)

Une configuration complète de l'interface pourrait être ceci (fichier `/etc/sysconfig/network-scripts/ifcfg-eth0`) :

```
 DEVICE=eth0
 ONBOOT=yes
 BOOTPROTO=none
 HWADDR=00:0c:29:96:32:e3
 IPADDR=192.168.1.10
 NETMASK=255.255.255.0
 GATEWAY=192.168.1.254
 DNS1=172.16.1.1
 DNS2=172.16.1.2
 DOMAIN=rockylinux.lan
```

La méthode de dépannage devrait aller progressivement du plus proche au plus distant :

1. ping localhost (test logiciel)
2. ping adresse IP (test matériel)
3. ping gateway (test de connectivité)
4. ping remote server (test de routage)
5. DNS query (dig ou ping)

![Méthode de dépannage ou de validation du réseau](images/network-004.png)
