---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - exercice d'atelier
  - runc
  - containerd
  - etcd
  - kubectl
---

# Atelier n°9 : Initialisation des nœuds de travail Kubernetes

!!! info

    Il s'agit d'un fork de l'original ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) écrit à l'origine par Kelsey Hightower (GitHub : kelseyhightower). Contrairement à l'original, qui se base sur des distributions de type Debian pour l'architecture ARM64, ce fork cible les distributions Enterprise Linux telles que Rocky Linux, qui fonctionne sur l'architecture x86_64.

Dans cet atelier, vous démarrerez deux nœuds de travail Kubernetes. Vous installerez les composants suivants : [runc](https://github.com/opencontainers/runc), [plugins de réseautage de conteneurs](https://github.com/containernetworking/cni), [containerd](https://github.com/containerd/containerd), [kubelet](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/) et [kube-proxy](https://kubernetes.io/docs/concepts/cluster-administration/proxies).

## Prérequis

Depuis le serveur `jumpbox`, copiez les fichiers binaires Kubernetes et les fichiers d'unités `systemd` sur chaque instance worker :

```bash
for host in node-0 node-1; do
  SUBNET=$(grep $host machines.txt | cut -d " " -f 4)
  sed "s|SUBNET|$SUBNET|g" \
    configs/10-bridge.conf > 10-bridge.conf 
    
  sed "s|SUBNET|$SUBNET|g" \
    configs/kubelet-config.yaml > kubelet-config.yaml
    
  scp 10-bridge.conf kubelet-config.yaml \
  root@$host:~/
done
```

```bash
for host in node-0 node-1; do
  scp \
    downloads/runc.amd64 \
    downloads/crictl-v1.32.0-linux-amd64.tar.gz \
    downloads/cni-plugins-linux-amd64-v1.6.2.tgz \
    downloads/containerd-2.0.3-linux-amd64.tar.gz \
    downloads/kubectl \
    downloads/kubelet \
    downloads/kube-proxy \
    configs/99-loopback.conf \
    configs/containerd-config.toml \
    configs/kubelet-config.yaml \
    configs/kube-proxy-config.yaml \
    units/containerd.service \
    units/kubelet.service \
    units/kube-proxy.service \
    root@$host:~/
done
```

Les commandes de cet atelier doivent être exécutées séparément sur chaque instance worker : `node-0` et `node-1`. Seules les étapes pour `node-0` sont affichées. Vous devez répéter exactement les étapes et les commandes sur `node-1`.

Connectez-vous à l'instance de nœud de travail `node-0` avec la commande `ssh`.

```bash
ssh root@node-0
```

## Provisionnement d'un nœud de travail Kubernetes

Installez les dépendances du système d'exploitation :

```bash
  dnf -y update
  dnf -y install socat conntrack ipset tar
```

> Le binaire `socat` prend en charge la commande `kubectl port-forward`.

### Désactivation du `Swap`

Si vous avez activé [swap](https://help.ubuntu.com/community/SwapFaq), le `kubelet` ne pourra pas démarrer. La [recommandation est de désactiver `swap`](https://github.com/kubernetes/kubernetes/issues/7294) pour s'assurer que Kubernetes fournit une allocation de ressources et une qualité de service appropriées.

Vérifiez que le `swap` est bien activé :

```bash
swapon --show
```

Si la sortie est vide, le `swap` n'est pas activé. Si le résultat n’est pas vide, exécutez la commande suivante pour désactiver immédiatement le swap :

```bash
swapoff -a
```

Pour vous assurer que le swap reste désactivé après le redémarrage, commentez la ligne qui monte automatiquement le volume de `swap` dans le fichier `/etc/fstab`. Entrer la commande suivante :

```bash
sudo sed -i '/swap/s/^/#/' /etc/fstab
```

Créez les répertoires d’installation :

```bash
mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes
```

Installez les fichiers binaires de travail :

```bash
  mkdir -p containerd
  tar -xvf crictl-v1.32.0-linux-amd64.tar.gz
  tar -xvf containerd-2.0.3-linux-amd64.tar.gz -C containerd
  tar -xvf cni-plugins-linux-amd64-v1.6.2.tgz -C /opt/cni/bin/
  mv runc.amd64 runc
  chmod +x crictl kubectl kube-proxy kubelet runc 
  mv crictl kubectl kube-proxy kubelet runc /usr/local/bin/
  mv containerd/bin/* /bin/
```

### Configuration du Réseau `CNI`

Créez le fichier de configuration réseau `bridge` :

```bash
mv 10-bridge.conf 99-loopback.conf /etc/cni/net.d/
```

### Configuration de `containerd`

Installez les fichiers de configuration `containerd` :

```bash
  mkdir -p /etc/containerd/
  mv containerd-config.toml /etc/containerd/config.toml
  mv containerd.service /etc/systemd/system/
```

### Configuration de `Kubelet`

Créez le fichier de configuration `kubelet-config.yaml` :

```bash
  mv kubelet-config.yaml /var/lib/kubelet/
  mv kubelet.service /etc/systemd/system/
```

### Configuration du proxy Kubernetes

```bash
  mv kube-proxy-config.yaml /var/lib/kube-proxy/
  mv kube-proxy.service /etc/systemd/system/
```

!!! note "Remarque "

    Bien que cela soit considéré comme une mauvaise sécurité, vous devrez peut-être désactiver SELinux temporairement ou définitivement si vous rencontrez des difficultés pour démarrer les services systemd nécessaires. La solution appropriée consiste à analyser et à créer les fichiers de stratégie requis à l'aide d'outils tels qu'ausearch, audit2allow, etc.
    
    Pour supprimer et désactiver SELinux, exécutez la commande suivante :

  ```bash
  sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
  setenforce 0
  ```

### Lancement des `Worker Services`

```bash
  systemctl daemon-reload
  systemctl enable containerd kubelet kube-proxy
  systemctl start containerd kubelet kube-proxy
```

## Vérification

Les instances de calcul créées dans ce didacticiel n'auront pas l'autorisation de terminer cette section de vérification. Exécutez les commandes suivantes à partir de la machine `jumpbox`.

Énumérez les nœuds Kubernetes enregistrés :

```bash
ssh root@server "kubectl get nodes --kubeconfig admin.kubeconfig"
```

```text
NAME     STATUS   ROLES    AGE    VERSION
node-0   Ready    <none>   1m     v1.32.0
```

Après avoir terminé toutes les étapes précédentes de ce laboratoire sur `node-0` et `node-1`, la sortie de la commande `kubectl get nodes` devrait afficher :

```text
NAME     STATUS   ROLES    AGE    VERSION
node-0   Ready    <none>   1m     v1.32.0
node-1   Ready    <none>   10s    v1.32.0
```

Next: [Configuring kubectl for Remote Access](lab10-configuring-kubectl.md)
