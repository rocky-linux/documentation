---
title: OliveTin
author: Ezequiel Bruni
contributors: Steven Spencer
tested with: 8.5, 8.6
tags:
  - automatización
  - web
  - bash
---

# Cómo instalar & utilizar OliveTin en Rocky Linux

## Introducción

¿Alguna vez se ha cansado de escribir las mismas instrucciones desde la línea de comandos una y otra vez? ¿Alguna vez ha querido que los demás miembros de su casa puedan reiniciar el servidor Plex sin su intervención? ¿Quiere escribir un nombre en un panel web, pulsar un botón y ver un contenedor personalizado Docker/LXD mágicamente?

Entonces tal vez quiera echar un vistazo a OliveTin. OliveTin es literalmente sólo una aplicación que te permite generar una página web desde un archivo de configuración, y esa página web tiene botones. Pulse los botones, y OliveTin ejecutará los comandos bash predefinidos que se configuren.

Claro, técnicamente puede crear algo como esto desde cero, con suficiente experiencia de programación... pero esta es la *forma* más fácil. Su aspecto es algo así cuando está configurado (imagen cortesía del repositorio [OliveTin](https://https://github.com/OliveTin/OliveTin)):

![Una captura de pantalla de OliveTin en el escritorio; incluye varios cuadrados en una cuadrícula, con etiquetas y acciones para cada comando que se puede ejecutar.](olivetin/screenshotDesktop.png)

!!! Warning "NUNCA ejecute esta aplicación en un servidor público"

    Esta aplicación, por su diseño y por lo que permite su creador, está pensada para ser utilizada en redes locales, *quizás* en entornos de desarrollo. Sin embargo, actualmente no dispone de ningún sistema de autenticación de usuario, y (hasta que el desarrollador corrija esto) *se ejecuta como root por defecto*.
    
    Así que sí, usa esto todo lo que quieras en una red segura y con firewall. *No lo ponga* en nada que deba ser usado públicamente. Por ahora.

## Requisitos previos y supuestos

Para seguir esta guía necesitará:

* Un servidor que ejecute Rocky Linux
* Experiencia con la línea de comandos.
* Acceso root o la capacidad de usar `sudo`.
* Conocer lo básico de YAML. No es difícil; le cogerá el truco más abajo.

## Instalar OliveTin

Esta es la parte más fácil: OliveTin viene con RPMs pre-construidos. Simplemente descargue la última versión para su arquitectura, e instálela. Si sigue esta guía en una estación de trabajo con un escritorio gráfico, simplemente descargue el archivo y haga doble clic en él para inastalarlo en su gestor de archivos preferido.

Si está instalando esta aplicación en un servidor, puede descargarla en su máquina de trabajo y subirla a través de SSH/SCP/SFTP, o hacer lo que algunas personas dicen que no hagan y descargalo mediante `wget`.

Por ejemplo.

```bash
wget https://github.com/OliveTin/OliveTin/releases/download/2022-04-07/OliveTin_2022-04-07_linux_amd64.rpm
```

A continuación, instale la aplicación mediante el comando que se muestra a continuación:

```bash
sudo rpm -i OliveTin_2022-04-07_linux_amd64.rpm
```

Ahora OliveTin puede ejecutarse como un servicio normal de `systemd`, pero no lo habilite todavía. Necesita configurar su archivo de configuración primero.

!!! Note

    Después de algunas pruebas, hemos determinado que estas mismas instrucciones de instalación funcionarán perfectamente en un contenedor LXD de Rocky Linux. Para cualquiera que le guste Docker, hay imágenes preconstruidas disponibles.

## Configurar las acciones de OliveTin

OliveTin puede hacer cualquier cosa que bash pueda hacer, y más. Puede usarlo para ejecutar aplicaciones con opciones CLI, ejecutar scripts de bash, servicios de reinicio, etc. Para empezar, abra el archivo de configuración con el editor de texto de su elección con root/sudo:

```bash
sudo nano /etc/OliveTin/config.yaml
```

El tipo de acción más básico es un simple botón; se hace clic en él, y el comando se ejecuta en el host. Puede definirlo en el archivo YAML así:

```yaml
actions:
  - title: Restart Nginx
    shell: systemctl restart nginx
```

También puede añadir iconos personalizados a cada acción con emojis unicode:

```yaml
actions:
  - title: Restart Nginx
    icon: "&#1F504"
    shell: systemctl restart nginx
```

No voy a entrar en todos los detalles de las opciones de personalización, pero también puede utilizar entradas de texto y menús desplegables para añadir variables y opciones a los comandos que quiera ejecutar. Si lo hace, OliveTin le preguntará por la entrada antes de ejecutar el comando.

Al hacer esto, puede ejecutar cualquier programa, controlar máquinas remotas mediante SSH, disparar webhooks y más. Consultea [la documentación oficial](https://docs.olivetin.app/actions.html) para obtener más ideas.

Aquí hay un ejemplo propio: tengo un script personal que utilizo para generar contenedores LXD con servidores web preinstalados en ellos. Con OliveTin, pude hacer rápidamente un GUI para dicho script:

```yaml
actions:
- title: Build Container
  shell: sh /home/ezequiel/server-scripts/rocky-host/buildcontainer -c {{ containerName }} -d {{ domainName }} {{ softwarePackage }}
  timeout: 60
  arguments:
    - name: containerName
      title: Container Name
      type: ascii_identifier

    - name: domainName
      title: Domain
      type: ascii_identifier

    - name: softwarePackage
      title: Default Software
      choices:
        - title: None
          value:

        - title: Nginx
          value: -s nginx

        - title: Nginx & PHP
          value: -s nginx-php

        - title: mariadb
          value: -s mariadb
```

En la interfaz, se ve así (y sí, OliveTin tiene un modo oscuro, y yo *realmente* necesito cambiar ese icono):

![Un formulario con tres campos de texto y un menú desplegable](olivetin/containeraction.png)

## Habilitar OliveTin

Una vez que tenga el archivo de configuración definido de la manera que lo desee, simplemente habilite e inicie OliveTin con:

```bash
sudo systemctl enable --now OliveTin
```

Cada vez que edite el archivo de configuración, necesitará reiniciar el servicio de la manera habitual:

```bash
sudo systemctl restart OliveTin
```

## Conclusión

OliveTin es una forma muy buena de ejecutar todo, desde simples comandos de bash hasta operaciones complejas a través de scripts. Tenga en cuenta, sin embargo, que por defecto todo se ejecuta como root, a menos que utilice su/sudo en sus comandos de shell para cambiar el usuario para ese comando en particular.

Como tal, debería tener cuidado con cómo establecer todo esto especialmente si usted planea dar acceso por ejemplo, a su familia, para controlar los servidores y aparatos domésticos, etc.

Y otra vez, no ponga esto en un servidor público a menos que esté listo para intentar asegurar la página por si mismo.

De lo contrario, diviértaae con ella. Es una pequeña pero muy útil herramienta.
