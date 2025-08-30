---
title: "Chapitre 4 : Mise en Place de Pare-feu"
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - entreprise
  - sécurité d'incus
---

Tout au long de ce chapitre, vous devez être l'utilisateur root ou pouvoir utiliser `sudo` pour obtenir les privilèges nécessaires.

Comme pour tout serveur, vous devez vous assurer qu’il est protégé du monde extérieur et sur votre réseau local. Votre serveur en exemple ne dispose que d'une interface LAN, mais il est possible d'avoir deux interfaces, chacune faisant face à vos réseaux LAN et WAN.

## Configuration du pare-feu – `firewalld`

Pour les règles _firewalld_, vous devez utiliser [cette procédure de base](../../guides/security/firewalld.md) ou être familier avec ces concepts. Un réseau LAN de `192.168.1.0/24` et un pont nommé `incusbr0` sont prérequis pour notre exemple. Pour plus de clarté, vous pouvez avoir plusieurs interfaces sur votre serveur Incus, dont une faisant face à votre WAN. Vous allez créer également une zone pour les réseaux pontés et locaux. Il s'agit d'un simple souci de clarté de la zone. Les autres noms de zone ne s'appliquent pas. Cette procédure suppose que vous connaissez déjà les bases de _firewalld_.

```bash
firewall-cmd --new-zone=bridge --permanent
```

Vous devez relancer le pare-feu après avoir ajouté une zone :

```bash
firewall-cmd --reload
```

Vous devrez autoriser tout le trafic en provenance du pont. Ajoutez simplement l'interface et changez la cible de `default` à `ACCEPT` :

!!! warning "Avertissement"

```
    Changer la cible d'une zone `firewalld` *doit* être fait avec l'option `--permanent`, nous pourrions donc aussi bien entrer cet indicateur dans nos autres commandes et renoncer à l'option `--runtime-to-permanent`.
```

!!! note "Remarque"

```
    Si vous devez créer une zone dans laquelle vous souhaitez autoriser tous les accès à l'interface ou à la source, mais ne souhaitez pas avoir à spécifier de protocoles ou de services, vous devez alors modifier la cible de `default` à `ACCEPT`. Il en va de même pour `DROP` et `REJECT` pour un bloc IP particulier pour lequel vous avez des zones personnalisées. La zone `drop` s'en chargera pour vous tant que vous n'utilisez pas de zone personnalisée.
```

```bash
firewall-cmd --zone=bridge --add-interface=incusbr0 --permanent
firewall-cmd --zone=bridge --set-target=ACCEPT --permanent
```

En supposant qu'il n'y ait aucune erreur et que tout fonctionne correctement, effectuez un rechargement du pare-feu :

```bash
firewall-cmd --reload
```

Si vous listez vos règles maintenant avec `firewall-cmd --zone=bridge --list-all`, vous obtiendrez le résultat suivant:

```bash
bridge (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces: incusbr0
  sources:
  services:
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

Notez que vous devez également autoriser l'accès
à votre interface locale. Là encore, les zones incluses ne sont pas nommées de manière appropriée. Créez une zone et utilisez la plage d'adresses IP source pour l'interface locale afin de vous assurer que vous y avez accès :

```bash
firewall-cmd --new-zone=local --permanent
firewall-cmd --reload
```

Ajoutez les adresses IP source pour l'interface locale, et changez la cible en `ACCEPT` :

```bash
firewall-cmd --zone=local --add-source=127.0.0.1/8 --permanent
firewall-cmd --zone=local --set-target=ACCEPT --permanent
firewall-cmd --reload
```

Continuez en faisant une liste de la zone `local` pour vous assurer que vos règles sont bien là avec `firewall-cmd --zone=local --list all` qui affichera :

```bash
local (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces:
  sources: 127.0.0.1/8
  services:
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

Vous pouvez autoriser SSH à partir de notre réseau de confiance. Pour ce faire, autorisez les adresses IP sources à utiliser la zone `trusted` intégrée. Par défaut, la cible de cette zone est `ACCEPT`.

```bash
firewall-cmd --zone=trusted --add-source=192.168.1.0/24
```

Ajouter le service à la zone :

```bash
firewall-cmd --zone=trusted --add-service=ssh
```

Si tout fonctionne correctement, changez le statut de vos règles vers `permanent` et rechargez les règles du pare-feu :

```bash
firewall-cmd --runtime-to-permanent
firewall-cmd --reload
```

La liste de votre zone `trusted` affichera :

```bash
trusted (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.1.0/24
  services: ssh
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

La zone `public` est activée par défaut et SSH est autorisé. Pour des raisons de sécurité, vous ne souhaitez pas que SSH soit autorisé pour la zone `public`. Assurez-vous que vos zones sont correctes et que l'accès au serveur se fait par l'une des adresses IP du réseau local (dans le cas de cet exemple). Vous risquez de vous bloquer sur le serveur si vous ne vérifiez pas cela avant de continuer. Lorsque vous êtes sûr d'avoir accès à l'interface correcte, supprimez SSH de la zone « public » :

```bash
firewall-cmd --zone=public --remove-service=ssh
```

Testez l'accès et assurez-vous que vous n'êtes pas bloqué. Si ce n'est pas le cas, déplacez vos règles vers le niveau permanent, rechargez, et listez la zone « public » pour assurer la suppression de SSH :

```bash
firewall-cmd --runtime-to-permanent
firewall-cmd --reload
firewall-cmd --zone=public --list-all
```

Il peut y avoir d'autres interfaces sur votre serveur à prendre en compte. Vous pouvez utiliser des zones intégrées le cas échéant, mais si les noms ne vous semblent pas adéquats, vous pouvez ajouter les zones nécessaires. N'oubliez pas que si vous n'avez pas de services ou de protocoles que vous devez autoriser ou rejeter spécifiquement, vous devrez modifier la zone cible. Vous pouvez le faire si l'utilisation d'interfaces fonctionne, comme avec le pont. Si vous avez besoin d’un accès plus granulaire aux services, utilisez plutôt les adresses IP sources.
