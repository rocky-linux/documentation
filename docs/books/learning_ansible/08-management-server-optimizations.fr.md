---
title: Optimisations du serveur de Management Ansible
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
update: 06-Dec-2021
---

# Optimisations du serveur de Management Ansible

Dans ce chapitre, nous allons passer en revue les options de configuration qui peuvent être intéressantes pour optimiser notre serveur de management Ansible.

## Le fichier de configuration `ansible.cfg`

Quelques options de configuration intéressantes à évoquer :

* `forks`: par défaut à 5, il s'agit du nombre de processus qu'Ansible lancera en parallèle pour communiquer avec les hôtes. Plus ce nombre est élevé, plus Ansible pourra gérer de clients en même temps, et donc accélérer le traitement. La valeur que vous pouvez définir dépend des ressources de CPU/RAM de votre serveur de management. Notez que la valeur par défaut, `5`, est très faible, la documentation Ansible indique que de nombreux utilisateurs la fixent à 50, voire 500 ou plus.

* `gathering` : cette variable modifie la politique de collecte des "facts". Par défaut, la valeur est `implicit`, ce qui implique que les "facts" seront collectés systématiquement. Modifier cette variable à `smart` permet de collecter les "facts" uniquement s'ils n'ont pas déjà été collectés. Associée a un "facts cache" (voir ci-dessous), cette option permet de considérablement augmenter la performance.

* `host_key_checking` : Attention à la sécurité de votre serveur de Management ! Cependant, si vous avez le contrôle total de votre environnement, il peut être intéressant de désactiver le contrôle des clés des serveurs distants et de gagner du temps à la connexion. Vous pouvez aussi, sur les serveurs distants, désactiver l'utilisation du DNS du serveur SSH (dans le fichier `/etc/ssh/sshd_config`, option `UseDNS no`), cette option fait perdre du temps à la connexion et n'est, la plupart du temps, utilisée que dans les logs de connexion.

* `ansible_managed` : Cette variable, contenant `Ansible managed` par défaut, est généralement utilisée dans les templates de fichiers qui sont déployés sur les serveurs distants. Elle permet d'informer les administrateurs que le fichier est automatiquement mis à jour par Ansible et que les changements qu'ils apporteront seront potentiellement perdus. Il peut être intéressant de laisser des messages plus exhaustifs. Attention toutefois, si vous modifiez cette variable, cela peut provoquer le redémarrage des services (via les "handlers" associés aux templates).

* `ssh_args = -C -o ControlMaster=auto -o ControlPersist=300s -o PreferredAuthentications=publickey` : spécifie les options de connexion ssh. En désactivant toutes les méthodes d'authentification autre que les clés publiques, vous pouvez économiser beaucoup de temps. Vous pouvez aussi augmenter le `ControlPersist` pour améliorer la performance (la documentation suggère qu'une valeur équivalente à 30 minutes peut être appropriée). La connexion à un client reste ouverte plus longtemps et peut être réutilisée lors d'une reconnexion au même serveur, ce qui représente un gain de temps considérable.

* `control_path_dir` : Indiquer le chemin d'accès aux sockets de connexion. Un path trop long peut causer des problèmes. Considérez le fait de le changer pour quelque chose de plus court, comme `/tmp/.cp`.

* `pipelining` : La définition de cette valeur à `True` augmente les performances en réduisant le nombre de connexions SSH nécessaires lors de l'exécution de modules distants. Vous devez d'abord vous assurer que l'option `requiretty` est désactivée dans les options `sudoers` (voir documentation).

## Mettre les "facts" en cache

La collecte des "facts" est un processus qui peut prendre un certain temps. Il peut être intéressant de désactiver cette collecte pour les playbooks qui n'en ont pas besoin (via l'option `gather_facts`) ou de garder ces faits en mémoire dans un cache pendant une certaine durée (par exemple 24H).

Ces "facts" peuvent être facilement stockés dans une base de données `redis` :

```
sudo yum install redis
sudo systemctl start redis
sudo systemctl enable redis
sudo pip3 install redis
```

N'oubliez pas de modifier la configuration d'Ansible :

```
fact_caching = redis
fact_caching_timeout = 86400
fact_caching_connection = localhost:6379:0
```

Pour vérifier le bon fonctionnement, il suffit d'interroger le serveur `redis` :

```
redis-cli
127.0.0.1:6379> keys *
127.0.0.1:6379> get ansible_facts_SERVERNAME
```

## Utilisation de Vault

Les différents mots de passe et secrets ne peuvent pas être stockés en clair avec le code source d'Ansible, que ce soit localement sur le serveur de Management ou sur un éventuel dépôt de code source.

Ansible propose d'utiliser un gestionnaire de chiffrement : `ansible-vault`.

Le principe est de chiffrer une variable ou un fichier entier avec la commande `ansible-vault`.

Ansible pourra déchiffrer ce fichier au moment de l'exécution en récupérant la clé de chiffrement dans le fichier (par exemple) `/etc/ansible/ansible.cfg`. Ce dernier peut également être un script python ou autre.

Editez le fichier `/etc/ansible/ansible.cfg` :

```
#vault_password_file = /path/to/vault_password_file
vault_password_file = /etc/ansible/vault_pass
```

Stockez le mot de passe dans ce fichier `/etc/ansible/vault_pass` et attribuez les droits et restrictions nécessaires :

```
mysecretpassword
```

Vous pouvez ensuite chiffrer vos fichiers avec la commande :

```
ansible-vault encrypt myfile.yml
```

Un fichier chiffré par `ansible-vault` peut être facilement reconnu grâce à son en-tête :

```
$ANSIBLE_VAULT;1.1;AES256
35376532343663353330613133663834626136316234323964333735363333396136613266383966
6664322261633261356566383438393738386165333966660a343032663233343762633936313630
34373230124561663766306134656235386233323964336239336661653433663036633334366661
6434656630306261650a313364636261393931313739363931336664386536333766326264633330
6334
```

Une fois qu'un fichier est chiffré, il peut toujours être édité avec la commande :

```
ansible-vault edit myfile.yml
```

Vous pouvez également délocaliser votre stockage de mots de passe vers n'importe quel gestionnaire de mots de passe.

Par exemple, pour récupérer un mot de passe qui serait stocké dans le Rundeck vault :

```
#!/usr/bin/env python
# -*- coding: utf-8 -*-
import urllib.request
import io
import ssl

def get_password():
    '''
    :return: Vault password
    :return_type: str
    '''
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE

    url = 'https://rundeck.rockylinux.org/api/11/storage/keys/ansible/vault'
    req = urllib.request.Request(url, headers={
                          'Accept': '*/*',
                          'X-Rundeck-Auth-Token': '****token-rundeck****'
                          })
    response = urllib.request.urlopen(req, context=ctx)

    return response.read().decode('utf-8')

if __name__ == '__main__':
    print(get_password())
```

## Utilisation sur des serveurs Windows

Il sera nécessaire d'installer plusieurs paquets sur le serveur de Management :

* Via le gestionnaire de packages :

```
sudo dnf install python38-devel krb5-devel krb5-libs krb5-workstation
```

et éditer le fichier `/etc/krb5.conf` pour spécifier les bons `realms` :

```
[realms]
ROCKYLINUX.ORG = {
    kdc = dc1.rockylinux.org
    kdc = dc2.rockylinux.org
}
[domain_realm]
  .rockylinux.org = ROCKYLINUX.ORG
```

* Via le gestionnaire de packages Python Package Manager:

```
pip3 install pywinrm
pip3 install pywinrm[credssp]
pip3 install kerberos requests-kerberos
```

## Utilisation des modules IP

Les modules réseau nécessitent généralement le module Python `netaddr`:

```
sudo pip3 install netaddr
```

## Générer une CMDB (Configuration Management DataBase)

Un outil, `ansible-cmdb`, a été développé pour générer une CMDB.

```
pip3 install ansible-cmdb
```

Ces "facts" doivent être exportés par ansible avec la commande suivante :

```
ansible --become --become-user=root -o -m setup --tree /var/www/ansible/cmdb/out/
```

Vous pouvez génerer ensuite un fichier `json` :

```
ansible-cmdb -t json /var/www/ansible/cmdb/out/linux > /var/www/ansible/cmdb/cmdb-linux.json
```

Si vous préférez une interface Web :

```
ansible-cmdb -t html_fancy_split /var/www/ansible/cmdb/out/
```
