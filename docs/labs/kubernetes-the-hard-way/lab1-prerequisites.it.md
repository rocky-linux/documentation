---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - lab exercise
---

# Laboratorio 1: Prerequisiti

!!! info

    Si tratta di un fork dell'originale ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) scritto originariamente da Kelsey Hightower (GitHub: kelseyhightower). A differenza dell'originale, che si basa su distribuzioni simili a Debian per l'architettura ARM64, questo fork si rivolge a distribuzioni Enterprise Linux come Rocky Linux, che gira su architettura x86_64.

In questo laboratorio verranno esaminati i requisiti della macchina necessari per seguire questa esercitazione.

## Macchine virtuali o fisiche

Questa esercitazione richiede quattro (4) macchine virtuali o fisiche x86_64 con Rocky Linux 9.5 (anche i container Incus o LXD dovrebbero funzionare). La tabella seguente elenca le quattro macchine e i relativi requisiti di CPU, memoria e storage.

| Nome    | Descrizione            | CPU | RAM   | Storage |
| ------- | ---------------------- | --- | ----- | ------- |
| jumpbox | Host amministrativo    | 1   | 512MB | 10GB    |
| server  | Kubernetes server      | 1   | 2GB   | 20GB    |
| node-0  | Nodo worker Kubernetes | 1   | 2GB   | 20GB    |
| node-1  | Nodo worker Kubernetes | 1   | 2GB   | 20GB    |

La modalità di provisioning delle macchine è a vostra discrezione; l'unico requisito è che ogni macchina soddisfi i requisiti di sistema sopra indicati, comprese le specifiche della macchina e la versione del sistema operativo. Una volta che tutte e quattro le macchine sono state messe a disposizione, verificare i requisiti di sistema eseguendo il comando `uname` su ogni macchina:

```bash
uname -mov
```

Dopo aver eseguito il comando `uname`, si dovrebbe vedere il seguente risultato:

```text
#1 SMP PREEMPT_DYNAMIC Wed Feb 19 16:28:19 UTC 2025 x86_64 GNU/Linux
```

L'indicazione `x86_64` nell'output conferma che il sistema è un'architettura x86_64. Questo dovrebbe essere il caso di vari sistemi basati su AMD e Intel.

Successivo: [setting-up-the-jumpbox](lab2-jumpbox.md)
