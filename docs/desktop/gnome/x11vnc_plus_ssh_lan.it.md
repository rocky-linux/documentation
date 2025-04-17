---
title: Condivisione del desktop tramite x11vnc+SSH
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova, Franco Colussi
---

## Introduzione

x11vnc è un potente programma VNC. Ciò che rende x11vnc diverso dagli altri programmi VNC è che un amministratore può prendere la sessione X esistente di un utente invece di essere costretto a crearne una nuova. Questo rende X11VNC ideale per fornire assistenza remota ai desktop Linux.

Questa guida spiega come impostare un server X11vnc e come connettersi ad esso da remoto.

!!! note "Nota"

```
Uno dei principali vantaggi dell'utilizzo di x11vnc rispetto a SSH è che elimina la necessità di aprire altre porte sul computer, riducendo così al minimo la superficie di attacco.
```

## Presupposti

Per questa guida, si presuppone che si disponga di quanto segue:

- Rocky Linux Workstation
- Privilegi `sudo`

## Impostazione del server VNC

Per catturare la sessione X, è necessario installare il server x11vnc sulla workstation Rocky.

### Disattivare Wayland

Per prima cosa, è necessario disabilitare Wayland. Aprire il file `custom.conf` usando il proprio editor di testo:

```bash
sudo vim /etc/gdm/custom.conf
```

Togliere il commento a `WaylandEnable=false`:

```bash
# GDM configuration storage

[daemon]
WaylandEnable=false

[security]

[xdmcp]

[chooser]

[debug]
# Uncomment the line below to turn on debugging
#Enable=true
```

Riavviare il servizio `gdm`:

```bash
sudo systemctl restart gdm
```

## Installare e configurare x11vnc

Abilitare il repository EPEL:

```bash
sudo dnf install epel-release
```

Creare una password per x11vnc:

```bash
x11vnc -storepasswd ~/.x11vnc.pwd
```

Creare un nuovo file con il proprio editor di testo. Si utilizzerà per creare un servizio per eseguire x11vnc:

```bash
sudo vim /etc/systemd/system/x11vnc.service
```

Copiare e incollare il testo seguente nel file, quindi scrivere e uscire:

!!! note "Nota"

```
Sostituire il percorso `rfbauth` con il percorso del file di password creato in precedenza. Inoltre, sostituire i valori `User` e `Group` con l'utente a cui si intende fornire assistenza remota.
```

```bash
[Unit]
Description=Start x11vnc at startup
After=display-manager.service

[Service]
Type=simple
Environment=DISPLAY=:1
Environment=XAUTHORITY=/run/user/1000/gdm/Xauthority
ExecStart=/usr/bin/x11vnc -auth /var/lib/gdm/.Xauthority -forever -loop -noxdamage -repeat -rfbauth /home/server/.x11vnc.pwd -rfbport 5900 -shared
User=server
Group=server

[Install]
WantedBy=multi-user.target
```

Attivare e avviare il servizio x11vnc:

```bash
sudo systemctl enable --now x11vnc.service
```

## Connessione al server VNC dalla workstation Rocky

### Installare il repository EPEL

```bash
sudo dnf install epel-release
```

### Installare un client VNC

Installare TigerVNC. Il server non viene utilizzato, ma si utilizzerà il client:

```bash
sudo dnf install tigervnc
```

### Creare il tunnel SSH

![The ssh command in a terminal window](images/x11vnc_plus_ssh_lan_images/vnc_ssh_tunnel.webp)

Creare un tunnel SSH per connettersi al server VNC in modo sicuro:

```bash
ssh -L 5900:localhost:5900 REMOTEIP
```

### Avviare il visualizzatore VNC

Aprite il vostro visualizzatore VNC con il seguente comando:

```bash
vncviewer
```

![TigerVNC viewer](images/x11vnc_plus_ssh_lan_images/vnc_viewer.webp)

Collegarsi al server VNC inserendo 127.0.0.1 o localhost in TigerVNC e connettersi.

![TigerVNC viewer password prompt](images/x11vnc_plus_ssh_lan_images/vnc_viewer_password.webp)

Inserire la password x11vnc creata in precedenza.

![TigerVNC viewer connected to an X session](images/x11vnc_plus_ssh_lan_images/x11vnc_over_ssh_lan_conclusion.webp)

Congratulazioni! Ora è possibile controllare il desktop da remoto!

## Connessione a una macchina attraverso Internet

Finora questo articolo ha mostrato come impostare un server x11vnc e come connettersi ad esso utilizzando VNC inoltrato attraverso un tunnel SSH. È importante notare che questo metodo funziona solo per i computer della stessa rete locale (LAN). Supponendo di volersi collegare a un computer su un'altra LAN. Un modo per farlo è impostare una VPN. Di seguito sono riportate alcune guide su come impostare una VPN:

- [OpenVPN](https://docs.rockylinux.org/guides/security/openvpn/)
- [Wireguard VPN](https://docs.rockylinux.org/guides/security/wireguard_vpn/)

## Conclusione

Congratulazioni! È stato configurato con successo un server x11vnc e ci si è collegati ad esso utilizzando un client TigerVNC. Questa soluzione è ideale per l'assistenza remota, in quanto condivide la stessa sessione X dell'utente, garantendo un'esperienza di assistenza senza soluzione di continuità.
