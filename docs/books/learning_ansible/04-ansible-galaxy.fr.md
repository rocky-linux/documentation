---
title: Ansible Galaxy
---

# Ansible Galaxy : Collections et Rôles

Dans ce chapitre, vous apprendrez comment utiliser, installer et gérer les rôles et les collections d'Ansible.

****

**Objectifs** : Dans ce chapitre, vous apprendrez à :

:heavy_check_mark: installer et gérer les collections.       
:heavy_check_mark: installer et gérer les rôles.

:checkered_flag: **ansible**, **ansible-galaxy**, **rôles**, **collections**

**Connaissances**: :star: :star:      
**Complexité**: :star: :star: :star:

**Temps de lecture** : 41 minutes

****

[La Ansible Galaxy](https://galaxy.ansible.com) fournit des Rôles Ansibles et des Collections de la Communauté Ansible.

Les éléments fournis sont prêts à l'emploi et peuvent être référencés dans les playbooks

## La commande `ansible-galaxy`

La commande `ansible-galaxy` gère les rôles et les collections à l'aide de [galaxy.ansible.com](http://galaxy.ansible.com).

* Pour gérer les rôles :

```
ansible-galaxy role [import|init|install|login|remove|...]
```

| Sous-commandes | Function                                                                |
| -------------- | ----------------------------------------------------------------------- |
| `install`      | installe un rôle.                                                       |
| `remove`       | supprime un ou plusieurs rôles.                                         |
| `list`         | affiche le nom et la version des rôles installés.                       |
| `info`         | afficher des informations sur un rôle.                                  |
| `init`         | générer le squelette d'un nouveau rôle.                                 |
| `import`       | importer un rôle depuis le site web de galaxy. Nécessite une connexion. |

* Pour gérer les collections :

```
ansible-galaxy collection [import|init|install|login|remove|...]
```

| Sous-commandes | Observation                                              |
| -------------- | -------------------------------------------------------- |
| `init`         | générer le squelette d'une nouvelle collection.          |
| `install`      | installer une collection.                                |
| `list`         | affiche le nom et la version des collections installées. |

## Rôles Ansible

Un rôle Ansible est une unité qui favorise la réutilisation des playbooks.

!!! note "Remarque"

    Plus d'informations peuvent être [trouvées ici](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html)

### Installation de rôles utiles

Afin de souligner l'intérêt d'utiliser des rôles, nous vous suggérons d'utiliser le rôle `alemorvan/patchmanagement` qui vous permettra d'effectuer beaucoup de tâches (pré-mise à jour ou post-mise à jour par exemple) pendant votre processus de mise à jour en seulement quelques lignes de code.

Vous pouvez vérifier le code dans le dépôt github du rôle [ici](https://github.com/alemorvan/patchmanagement).

* Installer le rôle. Ceci ne nécessite qu'une seule commande :

```
ansible-galaxy role install alemorvan.patchmanagement
```

* Créer un playbook pour inclure le rôle :

```
- name: Start a Patch Management
  hosts: ansible_clients
  vars:
    pm_before_update_tasks_file: custom_tasks/pm_before_update_tasks_file.yml
    pm_after_update_tasks_file: custom_tasks/pm_after_update_tasks_file.yml

  tasks:
    - name: "Include patchmanagement"
      include_role:
        name: "alemorvan.patchmanagement"
```

Avec ce rôle, vous pouvez ajouter vos propres tâches pour tout votre inventaire ou seulement pour votre nœud cible.

Nous allons créer des tâches qui seront exécutées avant et après le processus de mise à jour :

* Créer le dossier `custom_tasks` :

```
mkdir custom_tasks
```

* Créer le `custom_tasks/pm_before_update_tasks_file.yml` (n'hésitez pas à changer le nom et le contenu de ce fichier)

```
---
- name: sample task before the update process
  debug:
    msg: "This is a sample tasks, feel free to add your own test task"
```

* Créer le fichier `custom_tasks/pm_after_update_tasks_file.yml` (n'hésitez pas à changer le nom et le contenu de ce fichier)

```
---
- name: sample task after the update process
  debug:
    msg: "This is a sample tasks, feel free to add your own test task"
```

Et lancez votre première gestion des patchs:

```
ansible-playbook patchmanagement.yml

PLAY [Start a Patch Management] *************************************************************************

TASK [Gathering Facts] **********************************************************************************
ok: [192.168.1.11]

TASK [Include patchmanagement] **************************************************************************

TASK [alemorvan.patchmanagement : MAIN | Linux Patch Management Job] ************************************
ok: [192.168.1.11] => {
    "msg": "Start 192 patch management"
}

...

TASK [alemorvan.patchmanagement : sample task before the update process] ********************************
ok: [192.168.1.11] => {
    "msg": "This is a sample tasks, feel free to add your own test task"
}

...

TASK [alemorvan.patchmanagement : MAIN | We can now patch] **********************************************
included: /home/ansible/.ansible/roles/alemorvan.patchmanagement/tasks/patch.yml for 192.168.1.11

TASK [alemorvan.patchmanagement : PATCH | Tasks depends on distribution] ********************************
ok: [192.168.1.11] => {
    "ansible_distribution": "Rocky"
}

TASK [alemorvan.patchmanagement : PATCH | Include tasks for CentOS & RedHat tasks] **********************
included: /home/ansible/.ansible/roles/alemorvan.patchmanagement/tasks/linux_tasks/redhat_centos.yml for 192.168.1.11

TASK [alemorvan.patchmanagement : RHEL CENTOS | yum clean all] ******************************************
changed: [192.168.1.11]

TASK [alemorvan.patchmanagement : RHEL CENTOS | Ensure yum-utils is installed] **************************
ok: [192.168.1.11]

TASK [alemorvan.patchmanagement : RHEL CENTOS | Remove old kernels] *************************************
skipping: [192.168.1.11]

TASK [alemorvan.patchmanagement : RHEL CENTOS | Update rpm package with yum] ****************************
ok: [192.168.1.11]

TASK [alemorvan.patchmanagement : PATCH | Inlude tasks for Debian & Ubuntu tasks] ***********************
skipping: [192.168.1.11]

TASK [alemorvan.patchmanagement : MAIN | We can now reboot] *********************************************
included: /home/ansible/.ansible/roles/alemorvan.patchmanagement/tasks/reboot.yml for 192.168.1.11

TASK [alemorvan.patchmanagement : REBOOT | Reboot triggered] ********************************************
ok: [192.168.1.11]

TASK [alemorvan.patchmanagement : REBOOT | Ensure we are not in rescue mode] ****************************
ok: [192.168.1.11]

...

TASK [alemorvan.patchmanagement : FACTS | Insert fact file] *********************************************
ok: [192.168.1.11]

TASK [alemorvan.patchmanagement : FACTS | Save date of last PM] *****************************************
ok: [192.168.1.11]

...

TASK [alemorvan.patchmanagement : sample task after the update process] *********************************
ok: [192.168.1.11] => {
    "msg": "This is a sample tasks, feel free to add your own test task"
}

PLAY RECAP **********************************************************************************************
192.168.1.11               : ok=31   changed=1    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0  
```

Trop facile pour un processus aussi complexe, n'est-ce pas?

Ce n'est qu'un exemple de ce qui peut être fait en utilisant les rôles mis à disposition par la communauté. Jetez un œil à [galaxy.ansible.com](https://galaxy.ansible.com/) pour découvrir les rôles qui pourraient vous être utiles !

Vous pouvez également créer vos propres rôles pour vos propres besoins et les publier sur Internet si vous en avez envie. C'est ce que nous aborderons brièvement dans le chapitre suivant.

### Introduction au développement des rôles

Un squelette de rôle, servant de point de départ pour le développement de rôles personnalisés, peut être généré par la commande `ansible-galaxy` :

```
$ ansible-galaxy role init rocky8
- Role rocky8 was created successfully
```

La commande va générer l'arborescence suivante pour contenir le rôle `rocky8` :

```
tree rocky8/
rocky8/
├── defaults
│   └── main.yml
├── files
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── README.md
├── tasks
│   └── main.yml
├── templates
├── tests
│   ├── inventory
│   └── test.yml
└── vars
    └── main.yml

8 directories, 8 files
```

Les rôles vous permettent de supprimer le besoin d'inclure des fichiers. Il n'est pas nécessaire de spécifier les chemins de fichiers ou les directives `include` dans les playbooks. Il vous suffit de spécifier une tâche, et Ansible s'occupe des inclusions.

La structure d'un rôle est plutôt évidente.

Les variables sont simplement stockées soit dans `vars/main.yml` si les variables ne doivent pas être remplacées, soit dans `default/main.yml` si vous voulez laisser la possibilité de remplacer le contenu de la variable en dehors de votre rôle.

Les handlers, fichiers et modèles nécessaires à votre code sont stockés dans `handlers/main.yml`, `files` et `templates` respectivement.

Il ne reste plus qu'à définir le code pour les tâches de votre rôle dans `tasks/main.yml`.

Une fois que tout cela fonctionne bien, vous pouvez utiliser ce rôle dans vos playbooks. Vous pourrez utiliser votre rôle sans vous soucier de l'aspect technique de ses tâches, tout en personnalisant son fonctionnement avec des variables.

### Travail pratique : créer un premier rôle simple

Implémentons cela avec un rôle "go anywhere" qui créera un utilisateur par défaut et installera des paquets logiciels. Ce rôle peut être systématiquement appliqué à tous vos serveurs.

#### Variables

Nous allons créer un utilisateur `rockstar` sur tous nos serveurs. Comme nous ne voulons pas que cet utilisateur soit remplacé, définissons-le dans le fichier `vars/main.yml` :

```
---
rocky8_default_group:
  name: rockstar
  gid: 1100
rocky8_default_user:
  name: rockstar
  uid: 1100
  group: rockstar
```

Nous pouvons maintenant utiliser ces variables à l'intérieur de notre `tasks/main.yml` sans aucune inclusion.

```
---
- name: Create default group
  group:
    name: "{{ rocky8_default_group.name }}"
    gid: "{{ rocky8_default_group.gid }}"

- name: Create default user
  user:
    name: "{{ rocky8_default_user.name }}"
    uid: "{{ rocky8_default_user.uid }}"
    group: "{{ rocky8_default_user.group }}"
```

Pour tester le nouveau rôle, créons un playbook `test-role.yml` dans le même répertoire que le rôle :

```
---
- name: Test my role
  hosts: localhost

  roles:

    - role: rocky8
      become: true
      become_user: root
```

et lancer :

```
ansible-playbook test-role.yml

PLAY [Test my role] ************************************************************************************

TASK [Gathering Facts] *********************************************************************************
ok: [localhost]

TASK [rocky8 : Create default group] *******************************************************************
changed: [localhost]

TASK [rocky8 : Create default user] ********************************************************************
changed: [localhost]

PLAY RECAP *********************************************************************************************
localhost                  : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

Félicitations ! Vous pouvez maintenant créer des choses géniales avec un playbook de quelques lignes.

Voyons l'utilisation des variables par défaut.

Créer une liste de paquets à installer par défaut sur vos serveurs et une liste vide de paquets à désinstaller. Modifier les fichiers `defaults/main.yml` et ajouter ces deux listes :

```
rocky8_default_packages:
  - tree
  - vim
rocky8_remove_packages: []
```

et les utiliser dans `tasks/main.yml` :

```
- name: Install default packages (can be overridden)
  package:
    name: "{{ rocky8_default_packages }}"
    state: present

- name: "Uninstall default packages (can be overridden) {{ rocky8_remove_packages }}"
  package:
    name: "{{ rocky8_remove_packages }}"
    state: absent
```

Testez votre rôle avec l'aide du playbook précédemment créé :

```
ansible-playbook test-role.yml

PLAY [Test my role] ************************************************************************************

TASK [Gathering Facts] *********************************************************************************
ok: [localhost]

TASK [rocky8 : Create default group] *******************************************************************
ok: [localhost]

TASK [rocky8 : Create default user] ********************************************************************
ok: [localhost]

TASK [rocky8 : Install default packages (can be overridden)] ********************************************
ok: [localhost]

TASK [rocky8 : Uninstall default packages (can be overridden) []] ***************************************
ok: [localhost]

PLAY RECAP *********************************************************************************************
localhost                  : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

Vous pouvez maintenant remplacer `rocky8_remove_packages` dans votre playbook et désinstaller par exemple `cockpit` :

```
---
- name: Test my role
  hosts: localhost
  vars:
    rocky8_remove_packages:
      - cockpit

  roles:

    - role: rocky8
      become: true
      become_user: root
```

```
ansible-playbook test-role.yml

PLAY [Test my role] ************************************************************************************

TASK [Gathering Facts] *********************************************************************************
ok: [localhost]

TASK [rocky8 : Create default group] *******************************************************************
ok: [localhost]

TASK [rocky8 : Create default user] ********************************************************************
ok: [localhost]

TASK [rocky8 : Install default packages (can be overridden)] ********************************************
ok: [localhost]

TASK [rocky8 : Uninstall default packages (can be overridden) ['cockpit']] ******************************
changed: [localhost]

PLAY RECAP *********************************************************************************************
localhost                  : ok=5    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

Évidemment, il n'y a pas de limite à ce que vous pouvez améliorer dans le rôle. Imaginez que pour l'un de vos serveurs, vous avez besoin d'un paquet qui se trouve dans la liste de ceux à désinstaller. Vous pouvez par exemple, créer une liste modifiable des paquets à désinstaller et supprimer de cette liste les paquets qui restent nécessaires en utilisant le filtre `difference()` de jinja.

```
- name: "Uninstall default packages (can be overridden) {{ rocky8_remove_packages }}"
  package:
    name: "{{ rocky8_remove_packages | difference(rocky8_specifics_packages) }}"
    state: absent
```

## Collections Ansible

Les collections sont un format de distribution pour du contenu Ansible qui peut inclure des playbooks, des rôles, des modules et des plugiciels.

!!! note "Remarque"

    Plus d'informations peuvent être [trouvées ici](https://docs.ansible.com/ansible/latest/user_guide/collections_using.html)

Pour installer ou mettre à jour une collection :

```
ansible-galaxy collection install namespace.collection [--upgrade]
```

Vous pouvez alors utiliser la collection nouvellement installée en utilisant son espace de noms et son nom avant le nom du rôle ou du module :

```
- import_role:
    name: namespace.collection.rolename

- namespace.collection.modulename:
    option1: value
```

Vous pouvez trouver un index de collections [ici](https://docs.ansible.com/ansible/latest/collections/index.html).

Nous allons installer la collection `community.general` :

```
ansible-galaxy collection install community.general
Starting galaxy collection install process
Process install dependency map
Starting collection install process
Downloading https://galaxy.ansible.com/download/community-general-3.3.2.tar.gz to /home/ansible/.ansible/tmp/ansible-local-51384hsuhf3t5/tmpr_c9qrt1/community-general-3.3.2-f4q9u4dg
Installing 'community.general:3.3.2' to '/home/ansible/.ansible/collections/ansible_collections/community/general'
community.general:3.3.2 was installed successfully
```

Nous pouvons maintenant utiliser le module nouvellement disponible `yum_versionlock` :

```
- name: Start a Patch Management
  hosts: ansible_clients
  become: true
  become_user: root
  tasks:

    - name: Ensure yum-versionlock is installed
      package:
        name: python3-dnf-plugin-versionlock
        state: present

    - name: Prevent kernel from being updated
      community.general.yum_versionlock:
        state: present
        name: kernel
      register: locks

    - name: Display locks
      debug:
        var: locks.meta.packages                            
```

```
ansible-playbook versionlock.yml

PLAY [Start a Patch Management] *************************************************************************

TASK [Gathering Facts] **********************************************************************************
ok: [192.168.1.11]

TASK [Ensure yum-versionlock is installed] **************************************************************
changed: [192.168.1.11]

TASK [Prevent kernel from being updated] ****************************************************************
changed: [192.168.1.11]

TASK [Display locks] ************************************************************************************
ok: [192.168.1.11] => {
    "locks.meta.packages": [
        "kernel"
    ]
}

PLAY RECAP **********************************************************************************************
192.168.1.11               : ok=4    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

### Création d'une propre collection

Comme pour les rôles, vous pouvez créer une propre collection à l'aide de la commande `ansible-galaxy` :

```
ansible-galaxy collection init rocky8.rockstarcollection
- Collection rocky8.rockstarcollection was created successfully
```

```
tree rocky8/rockstarcollection/
rocky8/rockstarcollection/
├── docs
├── galaxy.yml
├── plugins
│   └── README.md
├── README.md
└── roles
```

Vous pouvez ensuite stocker vos propres plugins ou rôles dans cette nouvelle collection.
