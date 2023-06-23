---
title: Documentación local - Inicio rápido
author: Lukas Magauer
contributors: Steven Spencer, Pedro Garcia
tested_with: 8.6, 9.0
tags:
  - documentación
  - servidor local
---

# Introducción

Si lo desea, puede construir el sistema de documentación localmente sin utilizar Docker o LXD. Sin embargo, si elige utilizar este procedimiento, tenga en cuenta que si hace desarrolla en Python o utiliza Python localmente, su apuesta más segura será crear incialmente, un entorno virtual de Python [tal y como se describe aquí](https://docs.python.org/3/library/venv.html). Esto mantiene todos los procesos de Python protegidos unos de otros, lo cual es recomendable. Si decide utilizar este procedimiento sin configurar el entorno virtual de Python, tenga en cuenta que está asumiendo un cierto riesgo.

## Procedimiento

* Clone el repositorio docs.rockylinux.org:

```
git clone https://github.com/rocky-linux/docs.rockylinux.org.git
```

* Una vez terminado, cambie al directorio docs.rockylinux.org:

```
cd docs.rockylinux.org
```

* Ahora clone el repositorio de documentación utilizando:

```
git clone https://github.com/rocky-linux/documentation.git docs
```

* A continuación, instale el archivo requirements.txt para mkdocs:

```
python3 -m pip install -r requirements.txt
```

* Por último, ejecute el servidor mkdocs:

```
mkdocs serve
```

## Conclusión

Esto proporciona una forma rápida y sencilla de ejecutar una copia local de la documentación sin utilizar Docker o LXD. Si elige este método, debería configurar un entorno virtual de Python para proteger sus otros procesos de Python.
