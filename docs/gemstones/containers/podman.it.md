---
title: Podman
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova, Christian Steinert
date: 2024-03-07
tags:
  - docker
  - podman
---

# Introduzione

[Podman](https://podman.io/) è un runtime alternativo per container compatibile con Docker che, a differenza di quest'ultimo, è incluso nei repository Rocky Linux e può eseguire i container come servizio `systemd`.

## Installare `Podman`

Utilizzare l'utility `dnf` per installare Podman:

```bash
dnf install podman
```

## Aggiungere un container

Prendiamo come esempio una piattaforma cloud self-hosted [Nextcloud](https://nextcloud.com/):

```bash
podman run -d -p 8080:80 nextcloud
```

Verrà richiesto di selezionare il container registry da cui scaricarlo. Nel nostro esempio, si utilizzerà `docker.io/library/nextcloud:latest`.

Una volta scaricato il contenitore Nextcloud, questo verrà eseguito.

Inserite **indirizzo_ip:8080** nel vostro browser web (supponendo di aver aperto la porta in `firewalld`) e configurate Nextcloud:

![Nextcloud in container](../images/podman_nextcloud.png)

## Eseguire contenitori come servizi `systemd`

### Utilizzare `quadlet`

Dalla versione 4.4, Podman viene fornito con [Quadlet](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html), un generatore di systemd che può generare unitary file per servizi systemd rootless e rootful.

I file quadlet per i servizi rootful possono essere presenti in

- `/etc/containers/systemd/`
- `/usr/share/containers/systemd/`

mentre i file rootless possono essere salvati in alternativa in

- `$XDG_CONFIG_HOME/containers/systemd/` or `~/.config/containers/systemd/`
- `/etc/containers/systemd/users/$(UID)`
- `/etc/containers/systemd/users/`

Sono supportati singoli container, pod, immagini, reti, volumi e file kube, ma ritornando all'esempio precedentemente implementato di Nextcloud. Creare un nuovo file `~/.config/containers/systemd/nextcloud.container` con il seguente contenuto:

```systemd
[Container]
Image=nextcloud
PublishPort=8080:80
```

Sono disponibili [molte altre opzioni](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#container-units-container).

Per eseguire il generator e far sapere a systemd che c'è un nuovo servizio da eseguire:

```bash
systemctl --user daemon-reload
```

Per avviare il servizio, eseguire:

```bash
systemctl --user start nextcloud.service
```

!!! note "Nota"

```
Se si è già creato un file in una delle directory per i servizi rootful, omettere il flag `--user`.
```

Per eseguire automaticamente il container all'avvio del sistema o al login dell'utente, si può aggiungere un'altra sezione al file `nextcloud.container`:

```systemd
[Install]
WantedBy=default.target
```

Poiché i file del servizio generati sono considerati temporanei, non possono essere abilitati da systemd. Per ovviare a questo problema, il generator applica manualmente le installazioni durante la generazione. In questo modo si abilitano effettivamente anche i file dei servizi.

Sono supportati altri tipi di file: pod, volume, network, image, and kube. [Pods](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#pod-units-pod), per esempio, può essere usato per raggruppare i container – i servizi systemd generati e le loro dipendenze (creare il pod prima dei container) sono gestiti automaticamente da systemd.

### Utilizzare `podman generate systemd`

Podman fornisce inoltre il sottocomando `generate systemd`. Può essere usato per generare i file di servizio di `systemd`.

!!! warning "Attenzione"

```
`generate systemd` è ora deprecato e non riceverà ulteriori funzioni. Si raccomanda l'uso di Quadlet.
```

Ora lo si farà con Nextcloud. Eseguire:

```bash
podman ps
```

Si otterrà un elenco di container in esecuzione:

```bash
04f7553f431a  docker.io/library/nextcloud:latest  apache2-foregroun...  5 minutes ago  Up 5 minutes  0.0.0.0:8080->80/tcp  compassionate_meninsky
```

Come visto sopra, il nome del nostro container è `compassionate_meninsky`.

Per creare un servizio `systemd` per il container Nextcloud e abilitarlo al riavvio, eseguire quanto segue:

```bash
podman generate systemd --name compassionate_meninsky > /usr/lib/systemd/system/nextcloud.service
systemctl enable nextcloud
```

Sostituire `compassionate_meninsky` con il nome assegnato al container.

Quando il sistema si riavvia, Nextcloud si riavvia in Podman.
