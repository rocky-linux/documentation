---
title: torsocks — Acheminement du trafic via Tor/SOCKS5
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova
date: 2024-02-25
---

!!! warning "Avertissement"

```
Les bibliothèques `tor` et `torsocks` sont actuellement absentes de l'EPEL. Leur compilation est prévue ultérieurement. L'équipe de documentation continuera de tester leur disponibilité dans l'EPEL dès que possible. Pour l'instant, la seule solution est de les compiler à partir du code source, mais les instructions pour ce faire ne sont pas disponibles ici.
```

## `torsocks` - Introduction

`torsocks` est un utilitaire permettant de rediriger le trafic IP d'une application de ligne de commande sur le réseau [Tor](https://www.torproject.org/) ou un serveur SOCKS5.

## Using `torsocks`

```bash
dnf -y install epel-release
dnf -y install tor torsocks
systemctl enable --now tor
```

Les options courantes de la commande `torsocks` suivent et, dans des circonstances normales, ne nécessitent rien de plus. Les options précèdent l'application à exécuter (par exemple, `curl`) :

| Option     | Description                                                  |
| ---------- | ------------------------------------------------------------ |
| --shell    | Crée un nouveau shell avec LD\_PRELOAD |
| -u USER    | Indique l'utilisateur de SOCKS5                              |
| -p PASS    | Indique le mot de passe de SOCKS5                            |
| -a ADDRESS | Indique l'adresse du serveur SOCKS5                          |
| -P PORT    | Indique le port du serveur SOCKS5                            |
| -i         | Activation de l'isolation de `Tor`                           |

Un exemple (redacted) de sortie de l'IP checker [icanhazip.com](https://icanhazip.com/) via `torsocks`:

![torsocks output](./images/torsocks.png)

Notez que l'adresse IP de `torsocks` diffère de l'adresse IP directe de `curl`.
