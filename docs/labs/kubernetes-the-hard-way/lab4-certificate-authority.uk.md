---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - лабораторна вправа
---

# Лабораторна робота 4: Надання ЦС і генерація сертифікатів TLS

!!! info

    Це гілка розгалуження від оригінальної ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way), Келсі Хайтауера (GitHub: kelseyhightower). На відміну від оригіналу, який базується на дистрибутивах, подібних до Debian, для архітектури ARM64, ця гілка націлена на дистрибутиви Enterprise Linux, такі як Rocky Linux, який працює на архітектурі x86_64.

У цій лабораторній роботі ви створите [інфраструктуру PKI](https://en.wikipedia.org/wiki/Public_key_infrastructure) за допомогою OpenSSL для завантаження центру сертифікації та створення сертифікатів TLS для таких компонентів:

- kube-apiserver
- kube-controller-manager
- kube-scheduler
- kubelet
- kube-proxy

Виконуйте команди в цьому розділі з `jumpbox`.

## Центр сертифікації

У цьому розділі ви надасте центр сертифікації, який використовуватимете для створення додаткових сертифікатів TLS для інших компонентів Kubernetes. Налаштування ЦС і генерування сертифікатів за допомогою `openssl` може зайняти багато часу, особливо коли це робиться вперше. Щоб оптимізувати цю лабораторну роботу, потрібно включити файл конфігурації openssl, ca.conf, який визначає всі деталі, необхідні для створення сертифікатів для кожного компонента Kubernetes.

Перегляньте файл конфігурації `ca.conf`:

```bash
cat ca.conf
```

Щоб пройти цей підручник, вам не потрібно розуміти все у файлі `ca.conf`. Тим не менш, ви повинні вважати це відправною точкою для вивчення `openssl` і конфігурації, яка входить до керування сертифікатами на високому рівні.

Кожен центр сертифікації починається з закритого ключа та кореневого сертифіката. У цьому розділі ви створите самопідписаний центр сертифікації. Хоча це все, що вам потрібно для цього підручника, ви не повинні розглядати це в реальному виробничому середовищі.

Згенеруйте файл конфігурації ЦС, сертифікат і закритий ключ:

```bash
  openssl genrsa -out ca.key 4096
  openssl req -x509 -new -sha512 -noenc \
    -key ca.key -days 3653 \
    -config ca.conf \
    -out ca.crt
```

Результати:

```txt
ca.crt ca.key
```

!!! Tip "Порада"

    Щоб переглянути деталі, закодовані у створеному файлі сертифіката (ca.crt), ви можете скористатися цією командою OpenSSL `openssl x509 -in ca.crt -text -noout | less`.  

## Створення сертифікатів клієнта та сервера

У цьому розділі ви створите сертифікати клієнта та сервера для кожного компонента Kubernetes, а також сертифікат клієнта для користувача Kubernetes «адміністратор».

Згенеруйте сертифікати та закриті ключі:

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

Результати команди вище створять закритий ключ, запит на сертифікат і підписаний сертифікат SSL для кожного компонента Kubernetes. Ви можете отримати список згенерованих файлів за допомогою такої команди:

```bash
ls -1 *.crt *.key *.csr
```

## Поширення сертифікатів клієнта та сервера

У цьому розділі ви скопіюєте різні сертифікати на кожну машину за допомогою шляху, де кожен компонент Kubernetes шукатиме свою пару сертифікатів. У реальному середовищі ви б розглядали ці сертифікати як набір конфіденційних секретів, оскільки Kubernetes використовує ці компоненти як облікові дані для автентифікації один одного.

Скопіюйте відповідні сертифікати та закриті ключі на машини `node-0` і `node-1`:

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

Скопіюйте відповідні сертифікати та приватні ключі на машину `server`:

```bash
scp \
  ca.key ca.crt \
  kube-api-server.key kube-api-server.crt \
  service-accounts.key service-accounts.crt \
  root@server:~/
```

У наступній лабораторній роботі ви будете використовувати клієнтські сертифікати `kube-proxy`, `kube-controller-manager`, `kube-scheduler` і `kubelet` для створення файлів конфігурації автентифікації клієнта.

Далі: [Створення файлів конфігурації Kubernetes для автентифікації](lab5-kubernetes-configuration-files.md)
