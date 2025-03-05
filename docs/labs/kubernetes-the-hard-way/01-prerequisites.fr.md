# Prérequis

Dans ce laboratoire, vous passerez en revue les exigences machine nécessaires pour suivre ce didacticiel.

## Machines virtuelles ou physiques

Ce tutoriel nécessite quatre (4) machines x86_64 virtuelles ou physiques exécutant Debian 12 (bookworm). Le tableau suivant répertorie les quatre machines et leurs exigences en matière de CPU, de mémoire et de stockage.

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

Après avoir exécuté la commande `uname`, vous devriez obtenir le résultat suivant :

```text
#1 SMP PREEMPT_DYNAMIC Wed Feb 19 16:28:19 UTC 2025 x86_64 GNU/Linux
```

Le `x86_64` que vous voyez dans le résultat confirme que le système est une architecture x86_64. Cela devrait être le cas pour divers systèmes basés sur AMD et Intel.

À suivre : [setting-up-the-jumpbox](02-jumpbox.md)
