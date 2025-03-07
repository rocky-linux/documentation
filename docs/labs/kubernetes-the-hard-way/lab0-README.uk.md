---
title: Вступ
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
---

# Kubernetes The Hard Way (Rocky Linux)

> Це вітка оригінального ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way), яку спочатку створив Келсі Хайтауер (GitHub: kelseyhightower). На відміну від оригіналу, який базується на дистрибутивах, подібних до Debian, для архітектури ARM64, ця гілка націлена на дистрибутиви Enterprise Linux, такі як Rocky Linux, що працюють на архітектурі x86_64.

Цей підручник допоможе вам налаштувати Kubernetes the hard way. Цей посібник не для тих, хто шукає повністю автоматизований інструмент для запуску кластера Kubernetes. Kubernetes The Hard Way, розроблений для навчання, та це означає що вам доведеться пройти довгий шлях, щоб переконатися, що ви розумієте кожне завдання, необхідне для завантаження кластера Kubernetes.

Не розглядайте результати цього підручника як готові до виробництва. Ви може не отримати підтримки від спільноти, але не дозволяйте цьому заважати вам навчатися!

## Авторські права

![Creative Commons License](images/cc_by_sa.png)

Ліцензування цієї роботи здійснюється за [міжнародною ліцензією Creative Commons Attribution-NonCommercial-=ShareAlike 4.0](http://creativecommons.org/licenses/by-nc-sa/4.0/).

## Цільова аудиторія

Цільова аудиторія цього підручника – усі, хто хоче зрозуміти основи Kubernetes і взаємодію основних компонентів.

## Деталі кластера

Kubernetes The Hard Way проведе вас через завантаження базового кластера Kubernetes із усіма компонентами рівня керування, що працюють на одному вузлі та двох робочих вузлах, чого достатньо, щоб вивчити основні концепції.

Версії компонентів:

- [kubernetes](https://github.com/kubernetes/kubernetes) v1.32.x
- [containerd](https://github.com/containerd/containerd) v2.0.x
- [cni](https://github.com/containernetworking/cni) v1.6.x
- [etcd](https://github.com/etcd-io/etcd) v3.4.x

## Тестова платформа

Для цього посібника потрібні чотири (4) віртуальні або фізичні машини на базі x86_64, підключені до однієї мережі. Хоча підручник використовує машини на базі x86_64, ви можете застосувати отримані уроки на інших платформах.

- [Вимоги](lab1-prerequisites.md)
- [Налаштування Jumpbox](lab2-jumpbox.md)
- [Надання обчислювальних ресурсів](lab3-compute-resources.md)
- [Надання ЦС і генерація сертифікатів TLS](lab4-certificate-authority.md)
- [Створення файлів конфігурації Kubernetes для автентифікації](lab5-kubernetes-configuration-files.md)
- [Створення конфігурації та ключа шифрування даних](lab6-data-encryption-keys.md)
- [Завантаження кластера etcd](lab7-bootstrapping-etcd.md)
- [Завантаження площини керування Kubernetes](lab8-bootstrapping-kubernetes-controllers.md)
- [Завантаження робочих вузлів Kubernetes](lab9-bootstrapping-kubernetes-workers.md)
- [Налаштування kubectl для віддаленого доступу](lab10-configuring-kubectl.md)
- [Надання мережевих маршрутів Pod](lab11-pod-network-routes.md)
- [Smoke Test](lab12-smoke-test.md)
- [Очищення](lab13-cleanup.md)
