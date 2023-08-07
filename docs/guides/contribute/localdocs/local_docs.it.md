---
title: Documentazione Locale - Veloce
author: Lukas Magauer
contributors: Steven Spencer, Franco Colussi
tested_with: 8.6, 9.0
tags:
  - documentation
  - local server
---

# Introduzione

Puoi costruire il sistema di documentazione localmente senza Docker o LXD se vuoi. Se si sceglie di usare questa procedura, tuttavia, è bene tenere presente che se si si scrive molto codice in Python o si usa Python localmente, la scelta più sicura è quella di creare un ambiente virtuale Python [descritto qui](https://docs.python.org/3/library/venv.html). Questo mantiene tutti i processi Python protetti gli uni dagli altri, che è raccomandato. Se scegliete di usare questa procedura senza l'ambiente virtuale Python, sappiate che state correndo un certo rischio.

## Procedura

* Clona il repository docs.rockylinux.org:

```
git clone https://github.com/rocky-linux/docs.rockylinux.org.git
```

* Una volta terminato, passate alla directory docs.rockylinux.org:

```
cd docs.rockylinux.org
```

* Ora clonare il repository di documentazione utilizzando:

```
git clone https://github.com/rocky-linux/documentation.git docs
```

* Quindi, installare il file requirements.txt per mkdocs:

```
python3 -m pip install -r requirements.txt
```

* Infine esegui il server mkdocs:

```
mkdocs serve
```

## Conclusione

Questo fornisce un modo semplice e veloce per eseguire una copia locale della documentazione senza Docker o LXD. Se scegli questo metodo, dovresti davvero configurare un Ambiente Virtuale Python per proteggere gli altri processi Python.
