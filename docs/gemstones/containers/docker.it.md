---
title: Installare il Docker Engine
author: Wale Soyinka
contributors: Neel Chauhan, Srinivas Nishant Viswanadha, Stein Arne Storslett, Ganna Zhyrnova, Steven Spencer
date: 2021-08-04
tags:
  - docker
---

# Introduzione

Docker Engine può eseguire carichi di lavoro nativi in stile Docker su server Rocky Linux. A volte è preferibile quando si esegue l'ambiente Docker Desktop completo.

## Aggiungere il repository Docker

Utilizzare l'utilità `dnf` per aggiungere il repository Docker al server Rocky Linux. Digita:

```bash
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
```

## Installare i pacchetti necessari

Installare l'ultima versione di Docker Engine, `containerd` e Docker Compose, eseguendo:

```bash
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## Avviare e abilitare Docker`(dockerd`)

Usare `systemctl` per configurare l'avvio automatico di Docker al riavvio e contemporaneamente avviarlo ora. Digitare:

```bash
sudo systemctl --now enable docker
```

## Consentire facoltativamente a un utente non root di gestire docker

Aggiungere un utente non root al gruppo `docker`  per consentire all'utente di gestire  `docker`  senza `sudo`.

Questo è un passo facoltativo, ma può essere comodo se si è l'utente principale del sistema o se si vuole permettere a più utenti di gestire docker, ma non si vuole concedere loro i permessi `sudo`.

Digitare:

```bash
# Add the current user
sudo usermod -a -G docker $(whoami)

# Add a specific user
sudo usermod -a -G docker custom-user
```

Per assegnare il nuovo gruppo, è necessario uscire e rientrare. Verificare con il comando `id` che il gruppo sia stato aggiunto.

### Note

```docker
docker-ce               :Questo pacchetto fornisce la tecnologia di base per la creazione e l'esecuzione di contenitori docker (dockerd)
docker-ce-cli           : Fornisce l'interfaccia a riga di comando (CLI) dello strumento docker (docker)
containerd.io           : Fornisce il runtime del contenitore (runc)
docker-buildx-plugin    : Plugin Docker Buildx per la CLI di Docker
docker-compose-plugin   : Un plugin che fornisce il sottocomando "docker compose" 
```
