---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - lab exercise
---

# Laboratorio 13: Pulizia

!!! info

    Si tratta di un fork dell'originale ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) scritto originariamente da Kelsey Hightower (GitHub: kelseyhightower). A differenza dell'originale, che si basa su distribuzioni simili a Debian per l'architettura ARM64, questo fork si rivolge a distribuzioni Enterprise Linux come Rocky Linux, che gira su architettura x86_64.

In questo laboratorio si elimineranno le risorse di calcolo create durante questo tutorial.

## Istanze di calcolo

Le versioni precedenti di questa guida utilizzavano risorse GCP per vari aspetti dell'elaborazione dati e della rete. La versione attuale è agnostica; tutte le configurazioni vengono eseguite su `jumpbox`, `server` o nodi.

Per ripulire il sistema è sufficiente eliminare tutte le macchine virtuali create per questo esercizio.

Successivo: [Ricomincia da capo](lab0-README.md)
