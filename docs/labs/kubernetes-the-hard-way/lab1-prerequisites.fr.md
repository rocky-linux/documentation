---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - exercice d'atelier
---

# Atelier n°1 : Prérequis

!!! info

    Il s'agit d'un fork de l'original ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) écrit à l'origine par Kelsey Hightower (GitHub : kelseyhightower). Contrairement à l'original, qui se base sur des distributions de type Debian pour l'architecture ARM64, ce fork cible les distributions Enterprise Linux telles que Rocky Linux, qui fonctionne sur l'architecture x86_64.

Dans ce laboratoire, vous passerez en revue les exigences machine nécessaires pour suivre ce didacticiel.

## Machines virtuelles ou physiques

Ce tutoriel nécessite quatre (4) machines x86_64 virtuelles ou physiques exécutant Rocky Linux 9.5 (les conteneurs Incus ou LXD devraient également fonctionner). Le tableau suivant répertorie les quatre machines et leurs exigences en matière de CPU, de mémoire et de stockage.

| Nom     | Description               | CPU | RAM    | Stockage |
| ------- | ------------------------- | --- | ------ | -------- |
| jumpbox | Hôte administratif        | 1   | 512 Mo | 10Go     |
| server  | Serveur Kubernetes        | 1   | 2 Go   | 20 Go    |
| node-0  | Nœud Worker de Kubernetes | 1   | 2 Go   | 20 Go    |
| node-1  | Nœud Worker de Kubernetes | 1   | 2 Go   | 20 Go    |

La manière dont vous provisionnez les machines dépend de vous, la seule exigence est que chaque machine réponde aux exigences système ci-dessus, y compris les spécifications de la machine et la version du système d'exploitation. Une fois les quatre machines provisionnées, vérifiez la configuration système requise en exécutant la commande `uname` sur chaque machine :

```bash
uname -mov
```

Après avoir exécuté la commande `uname`, vous devriez obtenir un résultat similaire :

```text
#1 SMP PREEMPT_DYNAMIC Wed Feb 19 16:28:19 UTC 2025 x86_64 GNU/Linux
```

Le `x86_64` que vous voyez dans le résultat confirme que le système est une architecture x86_64. Cela devrait être le cas pour divers systèmes basés sur AMD et Intel.

À suivre : [setting-up-the-jumpbox](lab2-jumpbox.md)
