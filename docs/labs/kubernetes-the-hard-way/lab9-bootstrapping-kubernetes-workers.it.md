---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - lab exercise
  - runc
  - containerd
  - etcd
  - kubectl
---

# Laboratorio 9: Avvio dei nodi di lavoro Kubernetes

!!! info

    Si tratta di un fork dell'originale ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) scritto originariamente da Kelsey Hightower (GitHub: kelseyhightower). A differenza dell'originale, che si basa su distribuzioni simili a Debian per l'architettura ARM64, questo fork si rivolge a distribuzioni Enterprise Linux come Rocky Linux, che gira su architettura x86_64.

In questo laboratorio, si avvierà il bootstrap di due nodi di lavoro Kubernetes. Si installeranno i seguenti componenti: [runc](https://github.com/opencontainers/runc), [plugin di rete per container](https://github.com/containernetworking/cni), [containerd](https://github.com/containerd/containerd), [kubelet](https://kubernetes.io/docs/ reference/command-line-tools-reference/kubelet/), e [kube-proxy](https://kubernetes.io/docs/concepts/cluster-administration/proxies).

## Prerequisiti

Dal `jumpbox`, copiare i file binari di Kubernetes e i file unit di `systemd` su ciascuna istanza di lavoro:

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

I comandi in questo laboratorio devono essere eseguiti separatamente su ciascuna istanza di lavoro: `node-0` e `node-1`. Vengono mostrati solo i passaggi relativi a `node-0`. È necessario ripetere esattamente gli stessi passaggi e comandi su `node-1`.

Accedere all'istanza di lavoro `node-0` con il comando `ssh`.

```bash
ssh root@node-0
```

## Fornitura ad un nodo di lavoro Kubernetes

Installare le dipendenze del sistema operativo:

```bash
  dnf -y update
  dnf -y install socat conntrack ipset tar
```

> Il binario `socat` supporta il comando `kubectl port-forward`.

### Disattivazione della swap

Se hai abilitato la [swap](https://help.ubuntu.com/community/SwapFaq), il kubelet non riuscirà ad avviarsi. Si [consiglia di disabilitare lo swap](https://github.com/kubernetes/kubernetes/issues/7294) per garantire che Kubernetes fornisca una corretta allocazione delle risorse e una qualità del servizio adeguata.

Verificare se la swap è attiva:

```bash
swapon --show
```

Se l'output è vuoto, la swap non è abilitata. Se l'output non è vuoto, eseguire il seguente comando per disabilitare immediatamente la swap:

```bash
swapoff -a
```

Per garantire che la swap rimanga disattivata dopo il riavvio, commentare la riga che monta automaticamente il volume di swap nel file `/etc/fstab`. Digitare:

```bash
sudo sed -i '/swap/s/^/#/' /etc/fstab
```

Creare le directory di installazione:

```bash
mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes
```

Installare i binari di lavoro:

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

### Configurazione della rete CNI

Creare il file di configurazione di rete `bridge`:

```bash
mv 10-bridge.conf 99-loopback.conf /etc/cni/net.d/
```

### Configurazione di `containerd`

Installare i file di configurazione `containerd`:

```bash
  mkdir -p /etc/containerd/
  mv containerd-config.toml /etc/containerd/config.toml
  mv containerd.service /etc/systemd/system/
```

### Configurazione di Kubelet

Creare il file di configurazione `kubelet-config.yaml`:

```bash
  mv kubelet-config.yaml /var/lib/kubelet/
  mv kubelet.service /etc/systemd/system/
```

### Configurazione del proxy Kubernetes

```bash
  mv kube-proxy-config.yaml /var/lib/kube-proxy/
  mv kube-proxy.service /etc/systemd/system/
```

!!! note "Nota"

    Sebbene questa sia considerata una forma di sicurezza inadeguata, potrebbe essere necessario disabilitare temporaneamente o permanentemente SELinux se si riscontrano problemi nell'avvio dei servizi systemd necessari. La soluzione corretta consiste nell'analizzare e creare i file di policy richiesti utilizzando strumenti quali ausearch, audit2allow, ecc.\
    
    Per rimuovere SELinux e disabilitarlo, eseguire quanto segue:

  ```bash
  sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
  setenforce 0
  ```

### Avvio dei servizi di lavoro

```bash
  systemctl daemon-reload
  systemctl enable containerd kubelet kube-proxy
  systemctl start containerd kubelet kube-proxy
```

## Verifica

Le istanze di calcolo create in questo tutorial non avranno l'autorizzazione per completare questa sezione di verifica. Eseguire i seguenti comandi dalla macchina `jumpbox`.

Elencare i nodi Kubernetes registrati:

```bash
ssh root@server "kubectl get nodes --kubeconfig admin.kubeconfig"
```

```text
NAME     STATUS   ROLES    AGE    VERSION
node-0   Ready    <none>   1m     v1.32.0
```

Dopo aver completato tutti i passaggi precedenti in questo laboratorio sia su `node-0` che su `node-1`, l'output del comando `kubectl get nodes` dovrebbe mostrare:

```text
NAME     STATUS   ROLES    AGE    VERSION
node-0   Ready    <none>   1m     v1.32.0
node-1   Ready    <none>   10s    v1.32.0
```

Successivo: [Configurazione di kubectl per l'accesso remoto](lab10-configuring-kubectl.md)
