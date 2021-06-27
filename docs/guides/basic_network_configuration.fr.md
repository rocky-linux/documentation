# Configuration réseau de base

## Prérequis

* Être à l'aise avec le fonctionnement depuis la ligne de commande
* Toutes les opérations nécessitent un accès root
* Facultatif: être familier des concepts de mise en réseau

# Introduction

De nos jours, un ordinateur est presque inutile à lui seul. Que vous ayez besoin de mettre à jour les packages définis sur un serveur ou de naviguer sur le Web depuis votre ordinateur portable, vous aurez besoin d'un accès réseau.
Ce guide vise à fournir aux utilisateurs de Rocky Linux les connaissances de base sur la configuration de la connectivité réseau sur un système Rocky Linux.

## Utilisation du service NetworkManager

Au niveau de l'utilisateur, la pile réseau est gérée par *NetworkManager*. Cet outil s'exécute en tant que service, vous pouvez vérifier son état avec la commande suivante:

	systemctl status NetworkManager

### Fichiers de configuration

*NetworkManager* applique simplement une configuration lue à partir des fichiers trouvés dans `/etc/sysconfig/network-scripts/ifcfg-<IFACE_NAME>`.
Chaque interface réseau a son fichier de configuration. Voici par exemple une configuration par défaut d'un serveur:

	TYPE=Ethernet
	PROXY_METHOD=none
	BROWSER_ONLY=no
	BOOTPROTO=none
	DEFROUTE=yes
	IPV4_FAILURE_FATAL=no
	IPV6INIT=no
	NAME=ens18
	UUID=74c5ccee-c1f4-4f45-883f-fc4f765a8477
	DEVICE=ens18
	ONBOOT=yes
	IPADDR=192.168.0.1
	PREFIX=24
	GATEWAY=192.168.0.254
	DNS1=192.168.0.254
	DNS2=1.1.1.1
	IPV6_DISABLED=yes

Le nom de l'interface est **ens18** donc le nom de ce fichier sera `/etc/sysconfig/network-scripts/ifcfg-ens18`.

#### Adresse IP

Ici, il n'y a pas d'attribution d'adresse IP dynamique (DHCP) car le paramètre `BOOTPROTO` est réglé sur `none`. Pour l'activer, réglez-le sur `dhcp` et supprimez les lignes `IPADDR`, `PREFIX` et` GATEWAY`.
Pour configurer une attribution d'adresse IP statique, définissez les éléments suivants:

* IPADDR: l'adresse IP pour attribuer l'interface
* PREFIX: le masque de sous-réseau en [notation CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing#CIDR_notation)
* GATEWAY: la passerelle par défaut

Le paramètre `ONBOOT` réglé sur `yes` indique que cette connexion sera activée pendant le démarrage.

#### Résolution DNS

Pour obtenir une résolution de nom fonctionnelle, les paramètres suivants doivent être définis:

* DNS1: l'adresse IP du serveur de noms principal
* DNS2: l'adresse IP du serveur de noms secondaire (facultatif)

*NetworkManager* utilisera la configuration des serveurs de noms et remplira `/etc/resolv.conf` avec ces paramètres.

### Appliquer la configuration

Pour appliquer la configuration réseau, la commande `nmcli` peut être utilisée:

    nmcli connection up ens18

Pour obtenir l'état de la connexion, utilisez simplement:

    nmcli connection show

Vous pouvez également utiliser les commandes `ifup` et `ifdown` pour activer ou désactiver l'interface (ce sont de simples *wrappers* autour de `nmcli`):

	ifup ens18
	ifdown ens18

### Vérification de la configuration

Vous pouvez vérifier que la configuration a été correctement appliquée avec la commande `nmcli` suivante:

	nmcli device show ens18

qui devrait vous donner la sortie suivante:

	GENERAL.DEVICE:                         ens18
	GENERAL.TYPE:                           ethernet
	GENERAL.HWADDR:                         6E:86:C0:4E:15:DB
	GENERAL.MTU:                            1500
	GENERAL.STATE:                          100 (connecté)
	GENERAL.CONNECTION:                     ens18
	GENERAL.CON-PATH:                       /org/freedesktop/NetworkManager/ActiveConnection/1
	WIRED-PROPERTIES.CARRIER:               marche
	IP4.ADDRESS[1]:                         192.168.0.1/24
	IP4.GATEWAY:                            192.168.0.254
	IP4.ROUTE[1]:                           dst = 192.168.0.0/24, nh = 0.0.0.0, mt = 100
	IP4.ROUTE[2]:                           dst = 0.0.0.0/0, nh = 192.168.0.254, mt = 100
	IP4.DNS[1]:                             192.168.0.254
	IP4.DNS[2]:                             1.1.1.1
	IP6.GATEWAY:                            --

## Utilisation de l'utilitaire ip

La commande `ip` (fournie par le package *iproute2*) est un outil puissant pour obtenir des informations et configurer le réseau d'un système Linux moderne tel que Rocky Linux.

Dans cet exemple, nous utiliserons les paramètres suivants en guise d'exemple:

* nom de l'interface: ens19
* adresse IP: 192.168.20.10
* masque de sous-réseau: 24
* passerelle: 192.168.20.254

### Obtenir des informations générales

Pour voir l'état détaillé de toutes les interfaces, utilisez:

	ip a

**Petites astuces:**
* utilisez l'option `-c` pour obtenir une sortie colorée plus lisible: `ip -c a`.
* `ip` accepte les abréviations donc `ip a`, `ip addr` et `ip address` sont équivalents.

### Démarrer ou arrêter l'interface

Pour activer l'interface *ens19*, utilisez simplement `ip link set ens19 up` et pour l'arrêter, utilisez `ip link set ens19 down`.

### Attribuer une adresse statique à l'interface

La commande à utiliser est de la forme suivante:

	ip addr add <IP ADDRESS/CIDR> dev <IFACE NAME>

où <IP ADDRESS/CIDR> est l'adresse IP avec son suffixe de sous-réseau et < IFACE NAME> le nom de l'interface ciblée.

Pour attribuer les paramètres d'exemple ci-dessus, nous utiliserons donc:

	ip a add 192.168.20.10/24 dev ens19

Ensuite, vérifiez le résultat avec:

	ip a show dev ens19

qui affichera:

	3: ens19: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
		link/ether 4a:f2:f5:b6:aa:9f brd ff:ff:ff:ff:ff:ff
		inet 192.168.20.10/24 scope global ens19
		valid_lft forever preferred_lft foreve

Notre interface est en place et configurée, mais il nous manque quelque chose, la configuration de la passerelle (voir ci-dessous).

### Utilisation de l'utilitaire ifcfg

Pour configurer l'interface *ens19* avec notre adresse IP et l'utilitaire *ifcfg*, utilisez la commande suivante:

	ifcfg ens19 add 192.168.20.10/24

Pour supprimer l'adresse:

	ifcfg ens19 del 192.168.20.10/24

Pour désactiver complètement l'adressage IP sur cette interface:

	ifcfg ens19 stop

*Notez que cela ne désactive pas l'interface, cela désassigne simplement toutes les adresses IP de l'interface.*

### Configuration de la passerelle

Maintenant que l'interface a une adresse, nous devons définir sa route par défaut, cela peut être fait avec:

	ip route add default via 192.168.20.254 dev ens1

La table de routage du noyau peut être affichée avec

	ip route

ou `ip r` pour faire court.

## Vérification de la connectivité réseau

À ce stade, vous devriez avoir votre interface réseau en place et correctement configurée. Il existe plusieurs façons de vérifier votre connectivité.

En utilisant *ping* vers une autre adresse IP dans le même réseau (nous utiliserons `192.168.20.42` comme exemple):

	ping -c3 192.168.20.42

Cette commande émettra 3 *pings* (connus sous le nom de requête ICMP) et attendra une réponse. Si tout s'est bien passé, vous devriez obtenir cette sortie:

	PING 192.168.20.42 (192.168.20.42) 56(84) bytes of data.
	64 bytes from 192.168.20.42: icmp_seq=1 ttl=64 time=1.07 ms
	64 bytes from 192.168.20.42: icmp_seq=2 ttl=64 time=0.915 ms
	64 bytes from 192.168.20.42: icmp_seq=3 ttl=64 time=0.850 ms

	--- 192.168.20.42 ping statistics ---
	3 packets transmitted, 3 received, 0% packet loss, time 5ms
	rtt min/avg/max/mdev = 0.850/0.946/1.074/0.097 ms

Ensuite, pour vous assurer que votre configuration de routage est correcte, essayez de faire un *ping* vers un hôte externe, tel que ce résolveur DNS public bien connu:

	ping -c3 8.8.8.8

Si votre machine dispose de plusieurs interfaces réseau et que vous souhaitez faire une requête ICMP via une interface spécifique, vous pouvez utiliser l'option `-I`:

	ping -I ens19 -c3 192.168.20.42

Il est maintenant temps de s'assurer que la résolution DNS fonctionne correctement. Pour rappel, la résolution DNS est un mécanisme utilisé pour convertir les noms de machines (faciles à retenir pour les humains) en leurs adresses IP et inversement (DNS inversé).
Si le fichier `/etc/resolv.conf` indique un serveur DNS accessible, alors ce qui suit devrait fonctionner:

	host rockylinux.org

Résultat:

	rockylinux.org has address 76.76.21.21

