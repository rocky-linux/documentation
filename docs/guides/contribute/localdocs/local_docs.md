---
title: Quick Method
author: Lukas Magauer
contributors: Steven Spencer, Ganna Zyhrnova
tested_with: 8.6, 9.0
tags:
  - documentation
  - local server
---

# Introduction

You can build the documentation system locally without either Docker or LXD if you like. If you elect to use this procedure however, be aware that if you do a lot of Python coding or use Python locally, your safest bet is to create a Python Virtual Environment [described here](https://docs.python.org/3/library/venv.html). This keeps all of your Python processes protected from each other, which is recommended. If you choose to use this procedure without the Python Virtual Environment, then just be aware that you are taking a certain amount of risk.

## Procedure

* Clone the docs.rockylinux.org repository:

```
git clone https://github.com/rocky-linux/docs.rockylinux.org.git
```

* Once finished, change into the docs.rockylinux.org directory:

```
cd docs.rockylinux.org
```

* Now clone the documentation repository using:

```
git clone https://github.com/rocky-linux/documentation.git docs
```

* Next, install the requirements.txt file for mkdocs:

```
python3 -m pip install -r requirements.txt
```

* Finally run the mkdocs server:

```
mkdocs serve
```

## Conclusion

This provides a quick and simple way to run a local copy of documentation without Docker or LXD. If you choose this method, you should really setup a Python Virtual Environment to protect your other Python processes.
