---
title: micro
author: Ezequiel Bruni
contributors: Steven Spencer
tested version: 8.5
tags:
  - editor
  - editores
  - micro
---

# Instalar micro en Rocky Linux

## Introducción

*[micro](https://micro-editor.github.io)* es un fantástico editor de texto basado en terminal que se encuentra entre *nano* y *vim* en términos de complejidad. Posee un flujo de trabajo sencillo y fácil de reconocer con características increibles:

* Todos los comandos habituales como “Control-C”, ”Control-V” y “Control-F” funcionan tal y como lo harían en un editor de texto basado en el escritorio. Por supuesto, todas las combinacions de teclado se pueden volver a definir.
* Soporte para el ratón — haga clic y arrastre para seleccionar el texto, haga doble clic para seleccionar laspalabras o haga incluso triple-clic para seleccionar líneas.
* Más de 75 lenguajes soportados con resaltado de sintaxis por defecto.
* Cuando necesite editar múltiples líneas a la vez dispone de múltiples cursores.
* Incluye un sistema de complementos.
* Varios paneles.

Y así es como se ve en mi propio terminal:

![Una captura de pantalla del editor de micro texto](images/micro-text-editor.png)

!!! Note

    *Puede* instalar micro a través de una aplicación Snap. Si ya está utilizando snap en su máquina... Quiero decir... ¿por qué no? Pero yo prefiero hacerlo directamente desde su origen.

## Requisitos previos

* Una máquina o contenedor ejecutando Rocky Linux y conectado a Internet.
* Conocimiento básico de la línea de comandos, y el deseo de editar su texto allí.
* Algunos comandos tienen que ejecutarse como root, o con `sudo`.

### Cómo instalar micro

Este es quizás el tutorial más fácil que he escrito hasta ahora, con exactamente tres comandos. Primero, asegúrese de que los programas *tar* y *curl* estén instalados. Esto sólo debería ser relevante si está ejecutando una instalación mínima de Rocky, o ejecutándolo dentro de un contenedor.

```bash
sudo dnf install tar curl
```

A continuación, necesitará el instalador que puede descargar desde la página web de *micro*. El siguiente comando descargará el instalador y lo ejecutará en el directorio en el que se encuentre en el momento de ejecutarlo. Normalmente no aconsejamos copiar y pegar comandos desde sitios web, pero éste nunca me ha dado ningún problema.

```bash
curl https://getmic.ro | bash
```

Para instalar la aplicación en todo el sistema (y así puedes simplemente escribir "micro" para abrir la aplicación), puede ejecutar el script como el usuario root dentro de la carpeta `/usr/bin/`. Sin embargo, si quiere probarlo y revisarlo primero, puedes instalar el *micro* en cualquier carpeta que quieras, y luego mover la aplicación más adelante ejecutando el comando que se muestra a continuación:

```bash
sudo mv micro /usr/bin/
```

¡Y eso es todo! Feliz edición de texto.

### La forma realmente fácil

He creado un sencillo script que básicamente ejecuta todos los comandos anteriores. Puede encontrarlo en mi gist de[ Github](https://gist.github.com/EzequielBruni/0e29f2c0a63500baf6fe9e8c51c7b02f). Copie y pegue el texto a un archivo en su máquina, o descargalo mediante la aplicación `wget`.

## Desinstalar micro

Vaya a la carpeta en la que instaló *micro* y (usando sus poderes de root divinamente según sea necesario) ejecute:

```bash
rm micro
```

Probablemente *micro* dejará algunos archivos de configuración en su directorio principal (y en los directorios de inicio de cada usuario que lo haya ejecutado). Puedes deshacerse de ellos ejecutando:

```bash
rm -rf /home/[username]/.config/micro
```

## Conclusión

Si quiere una guía completa para utilizar *micro*, eche un vistazo a su [sitio web principal](https://micro-editor.github.io), y a la documentación que se encuentra en el repositorio disponible en [Github](https://github.com/zyedidia/micro/tree/master/runtime/help). También puede presionar “Control-G” para abrir el archivo de ayuda principal dentro de la aplicación.

Probablemente *micro* no satisfaga las necesidades de aquellos disfruten la experiencia de utilizar *vim* o *emacs* pero es perfecto para personas como yo. Siempre he querido disfrutar de esa antigua experiencia de Sublime Text en el terminal, y ahora tengo algo <0>realmente</0> parecido.

Pruébelo, y compruebe si funciona para usted.
