---
title: Infrastructure à Grande Échelle
---

# Ansible - Infrastructure à Grande Échelle

Dans ce chapitre vous allez apprendre à échelonner votre système de gestion de configuration.

****

**Objectifs** : Dans ce chapitre, vous apprendrez à :

:heavy_check_mark: Organiser votre code pour gérer une grande infrastructure ;  
:heavy_check_mark: Appliquer une partie ou le tout de votre gestionnaire de configuration à un groupe de nœuds ;

:checkered_flag: **ansible**, **config management**, **scale**

**Connaissances** : :star: :star: :star:  
**Complexité** : :star: :star: :star: :star:

**Temps de lecture** : 31 minutes

****

Nous avons vu dans les chapitres précédents comment organiser notre code sous forme de rôles, mais aussi comment utiliser certains rôles pour la gestion des mises à jour (patch management) ou le déploiement de code.

Qu'en est-il de la gestion de la configuration ? Comment gérer la configuration de dizaines, de centaines ou même de milliers de machines virtuelles en utilisant Ansible ?

L'avènement du cloud a un peu changé les méthodes traditionnelles. La machine virtuelle est configurée lors du déploiement. Si la configuration n'est plus conforme, elle est supprimée et remplacée par une nouvelle.

L'organisation du système de gestion de configuration présentée dans ce chapitre répondra à ces deux modes de provisionnement : utilisation « one-shot » ou « reconfiguration » normale d'un parc de serveurs.

Cependant, attention : utiliser Ansible pour assurer la conformité d'un parc nécessite de changer les habitudes de travail. Il n'est plus possible de modifier une configuration de gestion de services sans voir les changements annullés au cours du prochain provisionnement avec Ansible.

!!! note "Remarque"

    Ce que nous allons mettre en œuvre ci-dessous n'est pas le terrain de prédilection d'Ansible. Des technologies comme Puppet ou bien Salt sont mieux adaptées. Rappelons qu'Ansible est un couteau suisse de l'automatisation et est dépourvu d'agent sur le client, ce qui explique les différences de performances.

!!! note "Note"

    Des informations plus détaillées sont disponibles [ici](https://docs.ansible.com/ansible/latest/user_guide/sample_setup.html)

## Stockage des Variables

La première chose dont nous devrions parler est la séparation entre les données et le code Ansible.

Au fur et à mesure que le code devient plus complexe, il sera de plus en plus difficile de modifier les variables qu'il contient.

Pour assurer la maintenabilité de votre site, le plus important est de séparer correctement les variables du code Ansible.

Nous n'en avons pas encore parlé jusqu'à maintenant, mais il faut savoir qu'Ansible peut charger automatiquement les variables qu'il trouve dans des dossiers spécifiques en fonction du nom d'inventaire du nœud géré ou de ses groupes membres.

La documentation d'Ansible suggère d'organiser notre code comme suit :

```bash
inventories/
   production/
      hosts               # inventory file for production servers
      group_vars/
         group1.yml       # here we assign variables to particular groups
         group2.yml
      host_vars/
         hostname1.yml    # here we assign variables to particular systems
         hostname2.yml
```

Si le nœud de destination est `hostname1` du groupe `group1`, les variables contenues dans les fichiers `hostname1.yml` et `group1.yml` seront automatiquement chargées. C'est une méthode efficace d'enregistrer tous les paramètres des roles au même endroit.

De cette façon, le fichier d'inventaire de votre serveur devient pratiquement sa carte d'identité. Il contient toutes les variables qui diffèrent des variables par défaut pour votre serveur.

Dans une optique de centralisation des variables, il est souhaitable d'organiser le nommage des variables dans les rôles en les préfixant par exemple par le nom du rôle. Il est ainsi conseillé d'utiliser de simples noms de variables plutôt que des dictionaires.

Par exemple, si vous voulez enregistrer la valeur `PermitRootLogin` dans le fichier `sshd_config`, le nom `sshd_config_permitrootlogin` pour la variable serait adéquat (plutôt que `sshd.config.permitrootlogin`).

## À propos des tags d'Ansible

L'utilisation de balises d'Ansible vous permet d'exécuter ou ignorer partiellement une partie du code des tâches.

!!! note "Remarque"

    Des informations plus détaillées sont disponibles [ici](https://docs.ansible.com/ansible/latest/user_guide/playbooks_tags.html).

Par exemple, modifions notre tâche de création d'utilisateur :

```bash
- name: add users
  user:
    name: "{{ item }}"
    state: present
    groups: "users"
  loop:
     - antoine
     - patrick
     - steven
     - xavier
  tags: users
```

Vous pouvez maintenant exécuter seulement les tâches indiquées par la balise `users` en utilisant l'option de `ansible-playbook` `--tags` :

```bash
ansible-playbook -i inventories/production/hosts --tags users site.yml
```

Vous pouvez aussi essayer l'option `--skip-tags`.

## À propos de la structure du répertoire

Nous allons nous concentrer sur une proposition d'organisation des fichiers et répertoires nécessaires au bon fonctionnement d'un système de gestion de contenu (CMS).

Le fichier `site.yml` sera notre point de départ. Ce fichier est en quelque sorte le chef d'orchestre du système CMS en intégrant les rôles nécessaires pour les nœuds de destination si besoin est :

```bash
---
- name: "Config Management for {{ target }}"
  hosts: "{{ target }}"

  roles:

    - role: roles/functionality1

    - role: roles/functionality2
```

Bien sûr, ces rôles doivent être enregistrés dans le répertoire `roles` au même niveau que le fichier `site.yml`.

Les variables globales peuvent être gérées dans un fichier `vars/global_vars.yml`, même si il serait possible de les enregistrer dans le fichier `inventories/production/group_vars/all.yml`

```bash
---
- name: "Config Management for {{ target }}"
  hosts: "{{ target }}"
  vars_files:
    - vars/global_vars.yml
  roles:

    - role: roles/functionality1

    - role: roles/functionality2
```

On peut aussi garder la possibilité de déactiver une fonctionnalité. Ainsi nous inclurons les rôles avec une condition et une valeur par défaut comme suit :

```bash
---
- name: "Config Management for {{ target }}"
  hosts: "{{ target }}"
  vars_files:
    - vars/global_vars.yml
  roles:

    - role: roles/functionality1
      when:
        - enable_functionality1|default(true)

    - role: roles/functionality2
      when:
        - enable_functionality2|default(false)
```

N'oubliez pas d'utiliser les balises :

```bash
- name: "Config Management for {{ target }}"
  hosts: "{{ target }}"
  vars_files:
    - vars/global_vars.yml
  roles:

    - role: roles/functionality1
      when:
        - enable_functionality1|default(true)
      tags:
        - functionality1

    - role: roles/functionality2
      when:
        - enable_functionality2|default(false)
      tags:
        - functionality2
```

Vous devriez obtenir quelque chose de similaire à ce qui suit :

```bash
$ tree cms
cms
├── inventories
│   └── production
│       ├── group_vars
│       │   └── plateform.yml
│       ├── hosts
│       └── host_vars
│           ├── client1.yml
│           └── client2.yml
├── roles
│   ├── functionality1
│   │   ├── defaults
│   │   │   └── main.yml
│   │   └── tasks
│   │       └── main.yml
│   └── functionality2
│       ├── defaults
│       │   └── main.yml
│       └── tasks
│           └── main.yml
├── site.yml
└── vars
    └── global_vars.yml
```

!!! note "Remarque"

    Vous êtes libre d'intégrer vos rôles dans une collection

## Tests

Lançons le playbook pour éxécuter quelques tests :

```bash
$ ansible-playbook -i inventories/production/hosts -e "target=client1" site.yml

PLAY [Config Management for client1] ****************************************************************************

TASK [Gathering Facts] ******************************************************************************************
ok: [client1]

TASK [roles/functionality1 : Task in functionality 1] *********************************************************
ok: [client1] => {
    "msg": "You are in functionality 1"
}

TASK [roles/functionality2 : Task in functionality 2] *********************************************************
skipping: [client1]

PLAY RECAP ******************************************************************************************************
client1                    : ok=2    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
```

Comme vous pouvez le constater, par défaut, seulement les tâches du rôle `functionality1` seront exécutées.

Activons dans l'inventaire `functionality2` pour notre nœud de destination et réexécutons le playbook :

```bash
$ vim inventories/production/host_vars/client1.yml
---
enable_functionality2: true
```

```bash
$ ansible-playbook -i inventories/production/hosts -e "target=client1" site.yml

PLAY [Config Management for client1] ****************************************************************************

TASK [Gathering Facts] ******************************************************************************************
ok: [client1]

TASK [roles/functionality1 : Task in functionality 1] *********************************************************
ok: [client1] => {
    "msg": "You are in functionality 1"
}

TASK [roles/functionality2 : Task in functionality 2] *********************************************************
ok: [client1] => {
    "msg": "You are in functionality 2"
}

PLAY RECAP ******************************************************************************************************
client1                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

Essayons de d'appliquer uniquement `functionality2` :

```bash
$ ansible-playbook -i inventories/production/hosts -e "target=client1" --tags functionality2 site.yml

PLAY [Config Management for client1] ****************************************************************************

TASK [Gathering Facts] ******************************************************************************************
ok: [client1]

TASK [roles/functionality2 : Task in functionality 2] *********************************************************
ok: [client1] => {
    "msg": "You are in functionality 2"
}

PLAY RECAP ******************************************************************************************************
client1                    : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

Lançons l'inventaire complet :

```bash
$ ansible-playbook -i inventories/production/hosts -e "target=plateform" site.yml

PLAY [Config Management for plateform] **************************************************************************

TASK [Gathering Facts] ******************************************************************************************
ok: [client1]
ok: [client2]

TASK [roles/functionality1 : Task in functionality 1] *********************************************************
ok: [client1] => {
    "msg": "You are in functionality 1"
}
ok: [client2] => {
    "msg": "You are in functionality 1"
}

TASK [roles/functionality2 : Task in functionality 2] *********************************************************
ok: [client1] => {
    "msg": "You are in functionality 2"
}
skipping: [client2]

PLAY RECAP ******************************************************************************************************
client1                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
client2                    : ok=2    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
```

Comme vous pouvez le constater, seulement le rôle `functionality2` est exécuté sur la destination `client1`.

## Avantages

En suivant les conseils donnés dans la documentation d'Ansible, vous allez rapidement obtenir :

* un code source facile à gérer, même si il contient un grand nombre de rôles
* un système de conformité relativement rapide et reproductible que vous pouvez appliquer partiellement ou complètement
* peut être adapté sur une base cas par cas et pour chaque serveur
* les particularités de votre système sont séparées du code, facilement soumises à un audit et centralisées dans les fichiers d'inventaire de votre gestionnaire de configuration.
