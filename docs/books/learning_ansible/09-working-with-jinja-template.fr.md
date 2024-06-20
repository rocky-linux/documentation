---
title: Utilisation de Modèle Jinja
author: Srinivas Nishant Viswanadha
contributors: Steven Spencer, Antoine Le Morvan, Ganna Zhyrnova
---

# Chapitre : Les Templates Jinja pour Ansible

## Introduction

Ansible fournit un moyen puissant et simple de gérer les configurations à l'aide de modèles Jinja via le module `template` intégré. Ce chapitre explore deux façons essentielles d'utiliser les modèles Jinja dans Ansible :

- ajouter des variables à un fichier de configuration
- créer des fichiers complexes avec des boucles et des structures de données complexes.

## Ajouter des variables à un fichier de configuration

### Étape 1 : créer un modèle Jinja

Créez un fichier modèle Jinja, par exemple `sshd_config.j2`, avec des espaces réservés pour les variables :

```jinja
# /path/to/sshd_config.j2

Port {{ ssh_port }}
PermitRootLogin {{ permit_root_login }}
# Add more variables as needed
```

### Étape 2 : utiliser le module de template Ansible

Dans votre playbook Ansible, utilisez le module `template` pour restituer le modèle Jinja avec des valeurs spécifiques :

```yaml
---
- name: Generate sshd_config
  hosts: your_target_hosts
  tasks:
    - name: Template sshd_config
      template:
        src: /path/to/sshd_config.j2
        dest: /etc/ssh/sshd_config
      vars:
        ssh_port: 22
        permit_root_login: no
      # Add more variables as needed
```

### Étape 3 : appliquer les modifications de configuration

Exécutez le playbook Ansible pour appliquer les modifications aux hôtes cibles :

```bash
ansible-playbook your_playbook.yml
```

Cette étape garantit que les modifications de configuration sont appliquées de manière cohérente sur l’ensemble de votre infrastructure.

## Création d'un fichier complet avec des boucles et des structures de données complexes

### Étape 1 : améliorer le modèle Jinja

Étendez votre modèle Jinja pour gérer les boucles et les structures de données complexes. Voici un exemple de configuration d'une application hypothétique avec plusieurs composants :

```jinja
# /path/to/app_config.j2

{% for component in components %}
[{{ component.name }}]
    Path = {{ component.path }}
    Port = {{ component.port }}
    # Add more configurations as needed
{% endfor %}
```

### Étape 2 : intégrer le module template Ansible

Dans votre playbook Ansible, intégrez le module `template` pour générer un fichier de configuration complet :

```yaml
---
- name: Generate Application Configuration
  hosts: your_target_hosts
  vars:
    components:
      - name: web_server
        path: /var/www/html
        port: 80
      - name: database
        path: /var/lib/db
        port: 3306
      # Add more components as needed
  tasks:
    - name: Template Application Configuration
      template:
        src: /path/to/app_config.j2
        dest: /etc/app/config.ini
```

Exécutez le playbook Ansible pour appliquer les modifications aux hôtes cibles :

```bash
ansible-playbook your_playbook.yml
```

Cette étape garantit que les modifications de configuration sont appliquées de manière cohérente sur l’ensemble de votre infrastructure.

Le module Ansible `template` fournit un moyen d'utiliser les modèles Jinja pour générer dynamiquement des fichiers de configuration pendant l'exécution du playbook. Ce module vous permet de séparer la logique de configuration et les données, rendant vos playbooks Ansible plus flexibles et maintenables.

### Principales caractéristiques

1. **Rendu de modèle :**
   - Le module restitue des modèles Jinja pour créer des fichiers de configuration avec un contenu dynamique.
   - Les variables définies dans le playbook ou l'inventaire peuvent être injectées dans des modèles, permettant des configurations dynamiques.

2. **Utilisation de Jinja2 :**
   - Le module `template` exploite le moteur de création de modèles Jinja2, fournissant des fonctionnalités puissantes telles que des conditions, des boucles et des filtres pour une manipulation avancée des modèles.

3. **Chemins Source et de Destination :**
   - Spécifie le fichier modèle Jinja source et le chemin de destination pour le fichier de configuration généré.

4. \*\* Passage variable : \*\*
   - Les variables peuvent être transmises directement dans la tâche playbook ou chargées à partir de fichiers externes, permettant une génération de configuration flexible et dynamique.

5. **Exécution Idempotente :**
   - Le module `template` prend en charge l'exécution idempotente, garantissant que le modèle n'est appliqué que si des modifications sont détectées.

### Exemple de playbook snippet

```yaml
---
- name: Generate Configuration File
  hosts: your_target_hosts
  tasks:
    - name: Template Configuration File
      template:
        src: /path/to/template.j2
        dest: /etc/config/config_file
      vars:
        variable1: value1
        variable2: value2
```

### Exemples d'utilisation

1. **Gestion de Configuration :**
   - Idéal pour gérer les configurations de système en générant dynamiquement des fichiers en fonction de paramètres spécifiques.

2. **Mise en Place d'Application :**
   - Utile pour créer des fichiers de configuration spécifiques à une application avec différents paramètres.

3. **Infrastructure sous Forme de Code :**
   - Facilite les pratiques d'infrastructure en tant que code en permettant des ajustements dynamiques des configurations en fonction de variables.

### Les bonnes pratiques

1. **Séparation des Thèmes :**
   - Confine la logique de configuration réelle dans les modèles Jinja, en la séparant de la structure principale du playbook.

2. **Contrôle de Version :**
   - Stocke les modèles Jinja dans des référentiels contrôlés en version pour un meilleur suivi et une meilleure collaboration.

3. **Testabilité :**
   - Permet de tester les modèles de manière indépendante pour vous assurer qu’ils produisent le résultat de configuration attendu.

En tirant parti du module `template`, les utilisateurs d'Ansible peuvent améliorer la gérabilité et la flexibilité des tâches de configuration, favorisant ainsi une approche plus rationalisée et efficace de la configuration du système et des applications.

### Références

[Ansible Template Module Documentation](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html).
