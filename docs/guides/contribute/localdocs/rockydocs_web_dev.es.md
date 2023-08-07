---
title: Documentación local - Docker
author: Wale Soyinka
contributors: Steven Spencer
update: 27-Feb-2022
---

# Ejecutar una copia local del sitio web docs.rockylinux.org para el desarrollo web o para los creadores de contenido

Este documento explica cómo recrear y ejecutar una copia local de todo el sitio web docs.rockylinux.org en su máquina local. **Es un trabajo en curso.**

La ejecución de una copia local del sitio web de documentación puede ser útil en los siguientes casos:

* Está interesado en conocer y contribuir a los aspectos de desarrollo web del sitio docs.rockylinux.org.
* Es un autor y le gustaría ver cómo se verán sus documentos en el sitio web de docs antes de contribuir con los mismos.
* Es un desarrollador web que quiere contribuir o ayudar a mantener el sitio web docs.rockylinux.org.


### Algunos apuntes:

* Las instrucciones de esta guía **NO** son un requisito previo para los autores/colaboradores de la documentación de Rocky.
* Todo el entorno se ejecuta en un contenedor Docker, por lo que necesitará un motor Docker en su máquina local.
* El contenedor está construido sobre la imagen Docker oficial de RockyLinux disponible aquí https://hub.docker.com/r/rockylinux/rockylinux.
* El contenedor mantiene el contenido de la documentación (guías, libros, imágenes y demás) separado del motor web (mkdocs).
* El contenedor inicia un servidor web local escuchando en el puerto 8000.  Y el puerto 8000 será reenviado al host Docker.


## Crear el entorno con el contenido

1. Cambie el directorio de trabajo actual de su sistema por la carpeta en la que pretende escribir la documentación. En el resto de este documento nos referiremos a este directorio como `$ROCKYDOCS`.  Para esta demostración, en nuestro sistema, `$ROCKYDOCS` apunta a `~/projects/rockydocs`.

Cree $ROCKYDOCS si aún no existe y luego escriba:

```
cd  $ROCKYDOCS
```

2. Asegúrese que tiene `git` instalado (`dnf -y install git`).  Mientras se encuentre en la carpeta $ROCKYDOCS utilice git para clonar el repo de contenido de la documentación oficial de Rocky. Teclee:

```
git clone https://github.com/rocky-linux/documentation.git
```

Ahora tendrá una nueva carpeta `$ROCKYDOCS/documentación`. Esta carpeta es un repositorio git y está bajo el control de git.


## Crear e iniciar el entorno de desarrollo web RockyDocs

3.  Asegúrese de que tiene Docker funcionando en su máquina local (puede comprobarlo con `systemctl`)

4. Desde un terminal teclee:

```
docker pull wsoyinka/rockydocs:latest
```

5. Compruebe que la imagen se ha descargado correctamente. Teclee:

```
docker image  ls
```

## Iniciar el contenedor RockyDocs

1. Inicie un contenedor desde la imagen de rockydocs. Teclee:

```
docker run -it --name rockydoc --rm \
     -p 8000:8000  \
     --mount type=bind,source="$(pwd)"/documentation,target=/documentation  \
     wsoyinka/rockydocs:latest

```


Alternativamente si lo prefiere y si tiene `docker-compose` instalado, puede crear un archivo llamado `docker-compose.yml` con el siguiente contenido:

```
version: "3.9"
services:
  rockydocs:
    image: wsoyinka/rockydocs:latest
    volumes:
      - type: bind
        source: ./documentation
        target: /documentation
    container_name: rocky
    ports:
       - "8000:8000"

```

Guarde el archivo con el nombre `docker-compose.yml` en su directorio de trabajo $ROCKYDOCS.  Y arranque el servicio/contenedor ejecutando:

```
docker-compose  up
```


## Ver el sitio web local docs.rockylinux.org

Con el contenedor en funcionamiento, ahora debería poder dirigir su navegador web a la siguiente URL para ver su copia local del sitio:

http://localhost:8000
