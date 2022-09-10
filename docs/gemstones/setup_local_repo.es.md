---
title: Configurar los repositorios locales de Rocky
author: codedude
contributors: Steven Spencer, Pedro Garcia
update: 06-12-2021
---

# Introducción

A veces es necesario tener los repositorios de Rocky Linux disponibles de forma local para poder construir máquinas virtuales, entornos de laboratorio, etc.  También puede ayudarle a ahorrar ancho de banda si eso es una preocupación.  Este artículo le guiará a través del uso de `rsync` para copiar los repositorios de Rocky Linux a un servidor web local.  Montar un servidor web está fuera del alcance de este breve artículo.

## Requisitos

* Un servidor web

## Código

```
#!/bin/bash
repos_base_dir="/web/path"

# Start sync if base repo directory exist
if [[ -d "$repos_base_dir" ]] ; then
  # Start Sync
  rsync  -avSHP --progress --delete --exclude-from=/opt/scripts/excludes.txt rsync://ord.mirror.rackspace.com/rocky  "$repos_base_dir" --delete-excluded
  # Download Rocky 8 repository key
  if [[ -e /web/path/RPM-GPG-KEY-rockyofficial ]]; then
     exit
  else
      wget -P $repos_base_dir https://dl.rockylinux.org/pub/rocky/RPM-GPG-KEY-rockyofficial
  fi
fi
```

## Descripción

Este sencillo script de shell utiliza `rsync` para obtener los archivos del repositorio desde la réplica más cercana.  También utiliza la opción de "excluir", que se define en un archivo de texto en forma de palabras clave que no deben incluirse.  Las exclusiones son buenas si tiene espacio limitado en el disco o simplemente no quiere sincronizar todo por cualquier razón.  Podemos utilizar `*` como comodín.  Tenga cuidado al utilizar `*/ng` ya que excluirá todo lo que coincida con esos caracteres.  A continuación, se muestra un ejemplo:

```
*/source*
*/debug*
*/images*
*/Devel*
8/*
8.4-RC1/*
8.4-RC1
```

# Fin
Un sencillo script que le puede ayudar a ahorrar ancho de banda o facilitar la creación de un entorno de laboratorio.
