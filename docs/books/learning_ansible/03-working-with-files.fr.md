---
title: Gestion de Fichiers
---

# Ansible - Gestion de Fichiers

Dans ce chapitre, vous apprendrez à gérer des fichiers avec Ansible.

****

**Objectifs** : Dans ce chapitre, vous apprendrez à :

:heavy_check_mark: modifier le contenu d'un fichier ;       
:heavy_check_mark: transmettre des fichiers vers des serveurs cibles ;   
:heavy_check_mark: télécharger des fichiers à partir de serveurs distants.

:checkered_flag: **ansible**, **module**, **fichiers**

**Connaissances** : :star: :star:     
**Complexité** : :star:

**Temps de lecture :** 23 minutes

****

Suivant vos besoins, vous devrez utiliser différents modules Ansible pour modifier les fichiers de configuration du système.

## `ini_file` module

Quand vous voulez modifier un fichier ini (section entre les crochers `[]` et les paires `key=value`), le plus facile est d'utiliser le module `ini_file`.

!!! note "Remarque"

    Des informations plus détaillées sont disponibles [ici](https://docs.ansible.com/ansible/latest/collections/community/general/ini_file_module.html).

Le module nécessite :

* La valeur de la section
* Le nom de l'option
* La nouvelle valeur

Exemple d'utilisation :

```
- name: change value on inifile
  community.general.ini_file:
    dest: /path/to/file.ini
    section: SECTIONNAME
    option: OPTIONNAME
    value: NEWVALUE
```

## Module `lineinfile`

Pour s'assurer qu'une certaine ligne est présente dans un fichier ou bien si il est nécessaire d'ajouter ou de modifier une ligne, vous utiliserez le module `linefile`.

!!! note "Remarque"

    Des informations plus détaillées sont disponibles [ici](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html).

Dans ce cas, la ligne à modifier sera identifiée en utilisant regexp.

Par exemple, pour s'assurer que la ligne qui commence par `SELINUX=` dans le fichier `/etc/selinux/config` contient bien la valeur `enforcing` :

```
- ansible.builtin.lineinfile:
    path: /etc/selinux/config
    regexp: '^SELINUX='
    line: 'SELINUX=enforcing'
```

## Module `copy`

Pour copier un fichier à partir du serveur Ansible vers un ou plusieurs hôtes, il est préférable d'utiliser le module `copy`.

!!! note "Remarque"

    Pour des informations plus détaillées, veuillez consulter [ce site](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html).

L'exemple suivant illustre la copie du fichier `myflile.conf` d'un endroit à un autre :

```
- ansible.builtin.copy:
    src: /data/ansible/sources/myfile.conf
    dest: /etc/myfile.conf
    owner: root
    group: root
    mode: 0644
```

## Module `fetch`

Pour copier un fichier à partir d'un serveur distant vers le serveur local, il est préférable d'utiliser le module `fetch`.

!!! note "Remarque"

    Des informations plus détaillées sont disponibles [ici](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/fetch_module.html).

Ce module effectue l'opération inverse du module `copy` :

```
- ansible.builtin.fetch:
    src: /etc/myfile.conf
    dest: /data/ansible/backup/myfile-{{ inventory_hostname }}.conf
    flat: yes
```

## Module `template`

Ansible et son module `template` utilisent le système de modèles **Jinja2** (http://jinja.pocoo.org/docs/) pour générer des fichiers dans la machine cible.

!!! note "Remarque"

    Des informations plus détaillées sont disponibles [ici](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html).

Par exemple :

```
- ansible.builtin.template:
    src: /data/ansible/templates/monfichier.j2
    dest: /etc/myfile.conf
    owner: root
    group: root
    mode: 0644
```

Il est possible d'ajouter une étape de validation si le service ciblé le permet (par exemple avec apache en utilisant la commande `apachectl -t`) :

```
- template:
    src: /data/ansible/templates/vhost.j2
    dest: /etc/httpd/sites-available/vhost.conf
    owner: root
    group: root
    mode: 0644
    validate: '/usr/sbin/apachectl -t'
```

## Module `get_url`

Pour tranférer des fichiers à partir d'un site web ou ftp vers un ou plusieurs hôtes, vous pouvez utiliser le module `get_url` :

```
- get_url:
    url: http://site.com/archive.zip
    dest: /tmp/archive.zip
    mode: 0640
    checksum: sha256:f772bd36185515581aa9a2e4b38fb97940ff28764900ba708e68286121770e9a
```

En enregistrant la somme de contrôle on évite les transfers inutiles de fichiers déjà existants dans les répertoires de la destination.
