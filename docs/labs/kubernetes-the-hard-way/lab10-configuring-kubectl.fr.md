---
author: Wale Soyinka
contributors: Steven Spencer
tags:
  - kubernetes
  - k8s
  - exercice d'atelier
  - runc
  - containerd
  - etcd
  - kubectl
---

# Atelier n°10 : Configuration de `kubectl` pour l'accès à distance

!!! info

    Il s'agit d'un fork de l'original ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) écrit à l'origine par Kelsey Hightower (GitHub : kelseyhightower). Contrairement à l'original, qui se base sur des distributions de type Debian pour l'architecture ARM64, ce fork cible les distributions Enterprise Linux telles que Rocky Linux, qui fonctionne sur l'architecture x86_64.

Dans ce laboratoire, vous allez générer un fichier kubeconfig pour l'utilitaire de ligne de commande `kubectl` en fonction des informations d'identification de l'utilisateur `admin`.

> Exécutez les commandes de cet atelier à partir de la machine `jumpbox`.

## Le fichier de configuration Kubernetes de l'administrateur

Chaque `kubeconfig` nécessite un serveur API Kubernetes auquel se connecter.

Sur la base de l'entrée DNS `/etc/hosts` d'un laboratoire précédent, vous devriez pouvoir envoyer une requête ping à`server.kubernetes.local`.

```bash
curl -k --cacert ca.crt \
  https://server.kubernetes.local:6443/version
```

```text
{
  "major": "1",
  "minor": "32",
  "gitVersion": "v1.32.0",
  "gitCommit": "70d3cc986aa8221cd1dfb1121852688902d3bf53",
  "gitTreeState": "clean",
  "buildDate": "2024-12-11T17:59:15Z",
  "goVersion": "go1.23.3",
  "compiler": "gc",
  "platform": "linux/amd64"
}
```

Générez un fichier `kubeconfig` adapté à l'authentification en tant qu'utilisateur `admin` :

```bash
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.crt \
    --embed-certs=true \
    --server=https://server.kubernetes.local:6443

  kubectl config set-credentials admin \
    --client-certificate=admin.crt \
    --client-key=admin.key

  kubectl config set-context kubernetes-the-hard-way \
    --cluster=kubernetes-the-hard-way \
    --user=admin

  kubectl config use-context kubernetes-the-hard-way
```

Les résultats de l'exécution de la commande ci-dessus devraient créer un fichier kubeconfig à l'emplacement par défaut `~/.kube/config` utilisé par l'outil de ligne de commande `kubectl`. Cela signifie également que vous pouvez exécuter la commande `kubectl` sans spécifier de configuration.

## Vérification

Vérifiez la version du groupe Kubernetes distant :

```bash
kubectl version
```

```text
Client Version: v1.32.0
Kustomize Version: v5.5.0
Server Version: v1.32.0
```

Dressez la liste des nœuds du cluster Kubernetes distant :

```bash
kubectl get nodes
```

```text
NAME     STATUS   ROLES    AGE   VERSION
node-0   Ready    <none>   30m   v1.31.2
node-1   Ready    <none>   35m   v1.31.2
```

Suivant : [Provisionnement des routes réseau des pods](lab11-pod-network-routes.md)
