---
title: Installare il Docker Engine
author: wale soyinka
contributors:
date: 2021-08-04
tags:
  - docker
---

# Introduzione

Il Docker Engine può essere utilizzato eseguendo carichi di lavoro per container in stile Docker nativo sui server Rocky Linux. A volte è preferito eseguire l'ambiente Docker Desktop.

## Aggiungere il repository docker

Usa l'utilità dnf per aggiungere il repository docker al tuo server Rocky Linux. Digita:

```
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

## Installare i pacchetti necessari

Installare l'ultima versione di Docker Engine, containerd e Docker Compose, digitando:

```
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

## Avviare e abilitare il servizio docker di systemd (dockerd)

Usare l'utilità `systemctl` per configurare il demone dockerd in modo che si avvii automaticamente al prossimo riavvio del sistema e contemporaneamente si avvii per la sessione corrente. Digita:

```
sudo systemctl --now enable docker
```


### Note

```
docker-ce : Questo pacchetto fornisce la tecnologia sottostante per costruire ed eseguire docker containers (dockerd) 
docker-ce-cli : Fornisce l'interfaccia a riga di comando (CLI) client docker tool (docker)
containerd. o : Fornisce l' esecuzione del contenitore (runc)
docker-compose-plugin : un plugin che fornisce il sottocomando 'docker compose' 

```



