---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - лабораторна вправа
  - runc
  - containerd
  - etcd
  - kubectl
---

# Лабораторна робота 9: Завантаження робочих вузлів Kubernetes

!!! info

    Це гілка розгалуження від оригінальної ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way), Келсі Хайтауера (GitHub: kelseyhightower). На відміну від оригіналу, який базується на дистрибутивах, подібних до Debian, для архітектури ARM64, ця гілка націлена на дистрибутиви Enterprise Linux, такі як Rocky Linux, який працює на архітектурі x86_64.

У цій лабораторній роботі ви завантажите два робочі вузли Kubernetes. Ви встановите такі компоненти: [[runc](https://github.com/opencontainers/runc), [плагіни мережевих контейнерів](https://github.com/containernetworking/cni), [containerd](https://github.com/containerd/containerd), [kubelet](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/) і [kube-proxy](https://kubernetes.io/docs/concepts/cluster-administration/proxies).

## Передумови

З `jumpbox` скопіюйте двійкові файли Kubernetes і файли блоку `systemd` до кожного робочого екземпляра:

```bash
for host in node-0 node-1; do
  SUBNET=$(grep $host machines.txt | cut -d " " -f 5)
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

Команди в цій лабораторній роботі потрібно запускати окремо для кожного робочого екземпляра: `node-0` і `node-1`. Показані лише кроки для `node-0`. Ви повинні повторити точні кроки та команди на `node-1`.

Увійдіть до робочого екземпляра `node-0` за допомогою команди `ssh`.

```bash
ssh root@node-0
```

## Надання робочого вузла Kubernetes

Встановіть залежності операційної системи:

```bash
  dnf -y update
  dnf -y install socat conntrack ipset tar
```

> Двійковий файл `socat` підтримує команду `kubectl port-forward`.

### Вимкніть Swap

Якщо ви ввімкнули [swap](https://help.ubuntu.com/community/SwapFaq), kubelet не запуститься. [Рекомендовано вимкнути swap](https://github.com/kubernetes/kubernetes/issues/7294), щоб Kubernetes забезпечував належний розподіл ресурсів і якість обслуговування.

Перевірте, чи ввімкнено обмін:

```bash
swapon --show
```

Якщо вихідні дані порожні, то обмін не ввімкнено. Якщо вихідні дані не порожні, виконайте таку команду, щоб негайно вимкнути обмін:

```bash
swapoff -a
```

Щоб гарантувати, що підкачка залишиться вимкненою після перезавантаження, закоментуйте рядок, який автоматично монтує том підкачки у файлі `/etc/fstab`. Впишіть:

```bash
sudo sed -i '/swap/s/^/#/' /etc/fstab
```

Створіть каталоги встановлення:

```bash
mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes
```

Встановіть робочі двійкові файли:

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

### Налаштуйте мережу CNI

Створіть файл конфігурації мережі `bridge`:

```bash
mv 10-bridge.conf 99-loopback.conf /etc/cni/net.d/
```

### Налаштуйте `containerd`

Встановіть конфігураційні файли `container`:

```bash
  mkdir -p /etc/containerd/
  mv containerd-config.toml /etc/containerd/config.toml
  mv containerd.service /etc/systemd/system/
```

### Налаштуйте Kubelet

Створіть файл конфігурації `kubelet-config.yaml`:

```bash
  mv kubelet-config.yaml /var/lib/kubelet/
  mv kubelet.service /etc/systemd/system/
```

### Налаштуйте проксі Kubernetes

```bash
  mv kube-proxy-config.yaml /var/lib/kube-proxy/
  mv kube-proxy.service /etc/systemd/system/
```

!!! Примітка

    Хоча це вважається поганою формою безпеки, вам, можливо, доведеться тимчасово або назавжди вимкнути SELinux, якщо у вас виникнуть проблеми із запуском необхідних служб systemd. Правильним рішенням є дослідження та створення необхідних файлів політики за допомогою таких інструментів, як ausearch, audit2allow тощо.  
    
    Щоб виправити SELinux із шляху та вимкнути його, запустіть наступне:

  ```bash
  sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
  setenforce 0
  ```

### Запустіть Worker Services

```bash
  systemctl daemon-reload
  systemctl enable containerd kubelet kube-proxy
  systemctl start containerd kubelet kube-proxy
```

## Верифікація

Екземпляри обчислень, створені в цьому посібнику, не матимуть дозволу на завершення цього розділу перевірки. Виконайте наступні команди з машини `jumpbox`.

Перелічіть зареєстровані вузли Kubernetes:

```bash
ssh root@server "kubectl get nodes --kubeconfig admin.kubeconfig"
```

```text
NAME     STATUS   ROLES    AGE    VERSION
node-0   Ready    <none>   1m     v1.32.0
```

Після виконання всіх попередніх кроків у цій лабораторній роботі на `node-0` і `node-1` результат команди `kubectl get nodes` має показати:

```text
NAME     STATUS   ROLES    AGE    VERSION
node-0   Ready    <none>   1m     v1.32.0
node-1   Ready    <none>   10s    v1.32.0
```

Далі: [Налаштування kubectl для віддаленого доступу](lab10-configuring-kubectl.md)
