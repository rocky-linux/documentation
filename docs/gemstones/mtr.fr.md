---
title: mtr - Logiciel d'Analyse de Réseau
author: tianci li
contributors: Steven Spencer
date: 2021-10-20
---

# Présentation de `mtr`

`mtr` est un outil d'analyse de réseau qui permet de diagnostiquer certains problèmes. Il peut remplacer les commandes `ping` et `traceroute`. `mtr` est plus performant.

## Utilisation de `mtr`

```bash
# Install mtr
shell > dnf -y install mtr
```

Les options les plus courantes de la commande `mtr` sont les suivantes. En temps normal aucune option n'est nécessaire, il suffit d'indiquer simplement un nom ou une adresse IP :

| Options  | Description                                      |
| -------- | ------------------------------------------------ |
| -4       | # IPv4 seulement                                |
| -6       | # IPv6 seulement                                |
| -c COUNT | # Nombre de pings                               |
| -n       | # pas de résolution du nom de l'hôte            |
| -z       | # Affichage du nombre AS                        |
| -b       | # Affichage de l'adresse IP et du nom de l'hôte |
| -w       | # Output a wide range of reports                |

Les informations échangées avec le terminal sont les suivantes :

```bash
shell > mtr -c 10 bing.com
 My traceroutr [v0.92]
li(192.168.100.4) 2021-10-20T08:02:05+0800
Keys:Help Display mode Restart Statistics Order of fields quit
HOST: li Loss% Snt Last Avg Best Wrst StDev
 1. _gateway 0.0% 10 2.0 5.6 2.0 12.9 3.6
 2. 10.9.128.1 0.0% 10 13.9 14.8 8.5 20.7 3.9
 3. 120.80.175.109 0.0% 10 15.8 15.0 10.0 20.1 3.1
 4. 112.89.0.57 20.0% 10 18.9 15.2 11.5 18.9 2.9
 5.219.158.8.114 0.0% 10 10.8 14.4 10.6 20.5 3.5
 6. 219.158.24.134 0.0% 10 13.1 14.5 11.9 18.9 2.2
 7. 219.158.10.30 0.0% 10 14.9 21.2 12.0 29.8 6.9
 8. 219.158.33.114 0.0% 10 17.7 17.1 13.0 20.0 2.0
 9. ??? 100.0 10 0.0 0.0 0.0 0.0 0.0
10. ??? 100.0 10 0.0 0.0 0.0 0.0 0.0
11. ??? 100.0 10 0.0 0.0 0.0 0.0 0.0
12. ??? 100.0 10 0.0 0.0 0.0 0.0 0.0
13. a-0001.a-msedge.net 0.0% 10 18.4 15.7 9.5 19.3 3.1
...
```

* Loss% - pourcentage de paquets perdus
* Snt - le nombre de paquets envoyés
* Last - le délai du dernier paquet
* Avg - délai moyen
* Best - latence minimum
* Wrst - délai maximum
* StDev - variance (stabilité)

## Racourcis de clavier
<kbd>p</kbd> - pause; <kbd>d</kbd> - switch display mode; <kbd>n</kbd> - turn on/off DNS; <kbd>r</kbd> - reset all counters; <kbd>j</kbd> - Toggle delay display information; <kbd>y</kbd> - switch IP information; <kbd>q</kbd> - Quit interaction.
