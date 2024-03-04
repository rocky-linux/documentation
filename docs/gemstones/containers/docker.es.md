---
title: Instalar Docker Engine
author: wale soyinka, Pedro García
contributors:
date: 04-08-2021
tags:
  - docker
---

# Introducción

Docker Engine se puede utilizar para ejecutar cargas de trabajo de contenedores de Docker en servidores Rocky Linux. A veces se prefiere esto a ejecutar el entorno completo de Docker Desktop.

## Añadir el repositorio de Docker

Utilice la herramienta `dnf` para añadir el repositorio de Docker a su servidor Rocky Linux. Teclee:

```
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

## Instalar los paquetes necesarios

Instale la última versión de Docker Engine, containerd y Docker Compose, ejecutando:

```
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

## Iniciar el servicio systemd de Docker (dockerd) y habilitarlo para su arranque automático

Utilice la utilidad `systemctl` para configurar el demonio dockerd y que se inicie automáticamente con el próximo reinicio del sistema y simultáneamente para la sesión actual. Teclee:

```
sudo systemctl --now enable docker
```


### Notas

```
docker-ce               : Este paquete proporciona la tecnología subyacente para construir y ejecutar contenedores docker (dockerd) 
docker-ce-cli          : Proporciona la interfaz de línea de comandos (CLI) cliente de la herramienta docker (docker)
containerd.io           : Proporciona el tiempo de ejecución del contenedor (runc)
docker-compose-plugin  : Un plugin que proporciona el subcomando 'docker compose' 

```



