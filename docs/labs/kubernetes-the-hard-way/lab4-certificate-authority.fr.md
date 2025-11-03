---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - exercice d'atelier
---

# Atelier n° 4 : Provisionnement d'une Autorité de Certification et Génération de Certificats TLS

!!! info

    Il s'agit d'un fork de l'original ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) écrit à l'origine par Kelsey Hightower (GitHub : kelseyhightower). Contrairement à l'original, qui se base sur des distributions de type Debian pour l'architecture ARM64, ce fork cible les distributions Enterprise Linux telles que Rocky Linux, qui fonctionne sur l'architecture x86_64.

Dans cet atelier, vous allez provisionner une [infrastructure PKI](https://en.wikipedia.org/wiki/Public_key_infrastructure) à l'aide d'`OpenSSL` pour démarrer une autorité de certification et générer des certificats TLS pour les composants suivants :

- kube-apiserver
- kube-controller-manager
- kube-scheduler
- kubelet
- kube-proxy

Exécutez les commandes de cette section à partir de la `jumpbox`.

## Autorité de Certification

Dans cette section, vous allez provisionner une autorité de certification que vous utiliserez pour générer des certificats TLS supplémentaires pour les autres composants Kubernetes. La configuration de l'autorité de certification et la génération de certificats avec `openssl` peuvent prendre du temps, surtout lorsque vous le faites pour la première fois. Pour rationaliser ce laboratoire, un fichier de configuration `openssl`, `ca.conf`, doit être inclus, qui définit tous les détails nécessaires pour générer des certificats pour chaque composant Kubernetes.

Prenez un moment pour examiner le fichier de configuration `ca.conf` :

```bash
cat ca.conf
```

Pour terminer ce tutoriel, vous n'avez pas besoin de comprendre tout ce qui se trouve dans le fichier `ca.conf`. Néanmoins, vous devriez le considérer comme un point de départ pour apprendre `openssl` et la configuration nécessaire à la gestion des certificats à un niveau élevé.

Chaque autorité de certification commence par une clé privée et un certificat `root`. Dans cette section, vous allez créer une autorité de certification auto-signée, et bien que ce soit tout ce dont vous avez besoin pour ce tutoriel, c'est quelque chose que vous ne devriez pas prendre en compte dans un environnement de production réel.

Générez le fichier de configuration de l'autorité de certification, le certificat et la clé privée :

```bash
  openssl genrsa -out ca.key 4096
  openssl req -x509 -new -sha512 -noenc \
    -key ca.key -days 3653 \
    -config ca.conf \
    -out ca.crt
```

Résultats :

```txt
ca.crt ca.key
```

!!! tip "Astuce"

    Pour afficher les détails encodés dans le fichier de certificat généré (ca.crt), vous pouvez utiliser cette commande OpenSSL
    `openssl x509 -in ca.crt -text -noout | less`.

## Création des certificats client et serveur

Dans cette section, vous allez générer des certificats client et serveur pour chaque composant Kubernetes et un certificat client pour l'utilisateur Kubernetes `admin`.

Générer les certificats et les clés privées :

```bash
certs=(
  "admin" "node-0" "node-1"
  "kube-proxy" "kube-scheduler"
  "kube-controller-manager"
  "kube-api-server"
  "service-accounts"
)
```

```bash
for i in ${certs[*]}; do
  openssl genrsa -out "${i}.key" 4096

  openssl req -new -key "${i}.key" -sha256 \
    -config "ca.conf" -section ${i} \
    -out "${i}.csr"
  
  openssl x509 -req -days 3653 -in "${i}.csr" \
    -copy_extensions copyall \
    -sha256 -CA "ca.crt" \
    -CAkey "ca.key" \
    -CAcreateserial \
    -out "${i}.crt"
done
```

Les résultats de la commande ci-dessus généreront une clé privée, une demande de certificat et un certificat SSL signé pour chaque composant Kubernetes. Vous pouvez dresser la liste des fichiers générés avec la commande suivante :

```bash
ls -1 *.crt *.key *.csr
```

## Distribution des certificats client et serveur

Dans cette section, vous copierez les différents certificats sur chaque machine en utilisant un chemin où chaque composant Kubernetes recherchera sa paire de certificats. Dans un environnement réel, vous traiteriez ces certificats comme un ensemble de secrets sensibles, car Kubernetes utilise ces composants comme informations d'identification pour s'authentifier les uns auprès des autres.

Copiez les certificats et les clés privées appropriés sur les machines `node-0` et `node-1` :

```bash
for host in node-0 node-1; do
  ssh root@$host mkdir /var/lib/kubelet/
  
  scp ca.crt root@$host:/var/lib/kubelet/
    
  scp $host.crt \
    root@$host:/var/lib/kubelet/kubelet.crt
    
  scp $host.key \
    root@$host:/var/lib/kubelet/kubelet.key
done
```

Copiez les certificats et les clés privées appropriés sur la machine `server` :

```bash
scp \
  ca.key ca.crt \
  kube-api-server.key kube-api-server.crt \
  service-accounts.key service-accounts.crt \
  root@server:~/
```

Dans le prochain laboratoire, vous utiliserez les certificats clients `kube-proxy`, `kube-controller-manager`, `kube-scheduler` et `kubelet` pour générer des fichiers de configuration d’authentification client.

Suivant : [Génération des fichiers de configuration Kubernetes pour l'authentification](lab5-kubernetes-configuration-files.md)
