---
title: Introduzione
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
---

# Kubernetes The Hard Way (Rocky Linux)

!!! info

    Questo è un fork dell'originale [“Kubernetes the hard way”](https://github.com/kelseyhightower/kubernetes-the-hard-way) scritto originariamente da Kelsey Hightower (GitHub: kelseyhightower). A differenza dell'originale, che si basa su distribuzioni simili a Debian per l'architettura ARM64, questo fork è destinato alle distribuzioni Enterprise Linux come Rocky Linux, che funzionano su architettura x86_64.
    
    Tradotto con DeepL.com (versione gratuita)

Questo tutorial vi guiderà nella configurazione di Kubernetes alla maniera "hard way". Non è adatto per chi è alla ricerca di un tool completamente automatizzato per configurare un cluster Kubernetes. Kubernetes The Hard Way è progettato per l'apprendimento, il che significa intraprendere un iter più lungo per assicurarsi di comprendere ogni task necessario per avviare un cluster Kubernetes.

Il risultato finale di questo tutorial non è da considerare adatto per un ambiente di produzione e potrebbe non essere supportato dalla comunty, ma non si lasci che questo vi impedisca di imparare!

## Copyright

![Creative Commons License](images/cc_by_sa.png)

La licenza di quest'opera è concessa ai sensi della [Creative Commons Attribution-NonCommercial-=ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-nc-sa/4.0/).

## Destinatari

Questo tutorial è rivolto a chiunque desideri comprendere i fondamenti di Kubernetes e il funzionamento dei suoi componenti principali.

## Dettagli del cluster

Kubernetes The Hard Way vi guiderà nel processo di avvio di un cluster Kubernetes di base con tutti i componenti del control plane in esecuzione su un singolo nodo e due nodi di elaborazione (worker), sufficienti per apprendere i concetti fondamentali.

Versioni dei componenti:

- [kubernetes](https://github.com/kubernetes/kubernetes) v1.32.x
- [containerd](https://github.com/containerd/containerd) v2.0.x
- [cni](https://github.com/containernetworking/cni) v1.6.x
- [etcd](https://github.com/etcd-io/etcd) v3.4.x

## Labs

Questo tutorial richiede quattro (4) macchine virtuali o fisiche basate su x86_64 collegate alla stessa rete. Sebbene il tutorial utilizzi macchine basate su x86_64, è possibile applicare le nozioni apprese ad altre piattaforme.

- [Prerequisiti](lab1-prerequisites.md)
- [Configurazione della Jumpbox](lab2-jumpbox.md)
- [Provisioning delle risorse di calcolo](lab3-compute-resources.md)
- [Provisioning della CA e generazione dei certificati TLS](lab4-certificate-authority.md)
- [Generazione dei file di configurazione Kubernetes per l'autenticazione](lab5-kubernetes-configuration-files.md)
- [Generazione della configurazione e della chiave di crittografia dei dati](lab6-data-encryption-keys.md)
- [Avvio del cluster etcd](lab7-bootstrapping-etcd.md)
- [Avvio del Control Plane di Kubernetes](lab8-bootstrapping-kubernetes-controllers.md)
- [Avvio dei nodi Worker di Kubernetes](lab9-bootstrapping-kubernetes-workers.md)
- [Configurazione di kubectl per l'accesso remoto](lab10-configuring-kubectl.md)
- [Provisioning delle rotte di rete dei pod](lab11-pod-network-routes.md)
- [Smoke Test](lab12-smoke-test.md)
- [Cleaning Up](lab13-cleanup.md)
