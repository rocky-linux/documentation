---
title: Registro de cambios de Rocky Linux 8
author: Louis Abel
contributors: Steven Spencer, tianci li, Pedro Garcia
tags:
  - registro de cambios de rocky
  - registro de cambios
---

# Registro de cambios de Rocky Linux 8

Los datos del registro de cambios para las versiones de Rocky Linux son actualmente un trabajo en curso. Este documento trata sobre dónde puede encontrar la información del registro de cambios para la versión 8. Habrá un enfoque más formal en el futuro que incluirá también la versión 9. Si desea opinar sobre cómo aparecerá esta información en el futuro, eche un vistazo a este [enlace](https://github.com/rocky-linux/peridot/issues/9) y añada sus comentarios. Además, puede encontrar los cambios actuales e históricos de la versión 8 [aquí](https://errata.build.resf.org/).

Las actualizaciones publicadas desde upstream se publican en todas nuestras arquitecturas actuales. Recomendamos encarecidamente a todos los usuarios que apliquen *todas* las actualizaciones, incluido el contenido publicado hoy, en sus máquinas Rocky Linux existentes. Esto se puede hacer ejecutando el comando `dnf update`.

Todos los componentes de Rocky Linux se construyen a partir de las fuentes alojadas en [git.rockylinux.org](https://git.rockylinux.org). Además, los SRPM están siendo publicados junto a los repositorios en un directorio de "fuente" correspondiente. Puede encontrarlo en cualquiera de nuestras replicas. Estos paquetes fuente coinciden con cada RPM binario que publicamos.
