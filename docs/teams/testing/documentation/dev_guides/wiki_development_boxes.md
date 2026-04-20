---
title: Create live devbox for wiki.rockylinux.org
author:
    - Lukas Magauer
    - Al Bowles
revision_date: 2026-04-17
render_macros: true
---

# How to create a live system to work on the documentation

There are several ways how to setup your development environment, here are the currently used once by the testing team:

## Vagrant

For now here is the link to [Trevor's vagrant box setup](https://github.com/tcooper/rocky-linux-wikibox), this might be merged here in the future!

## Manual setup for WSL and toolbox

### WSL specific

Create a WSL machine like [described here](https://docs.rockylinux.org/guides/interoperability/import_rocky_to_wsl), make sure to give it a name like `rocky-wiki`.

### toolbox specific

- Make sure you have `toolbox` installed on your system
- Create a toolbox `toolbox create rocky-wiki` (on Rocky Linux 8 and 9 machines this will create either a Rocky Linux 8 or 9 toolbox container)

### Container setup for both

- Run `dnf -y update` to update the system
- Run `dnf -y install git python39-pip` to install Python 3.9 and pip (Python 3.9 is default for Rocky Linux 9, the package is called `python3-pip` there)
- Run `python3.9 -m pip install -U pip` to update pip
- Clone the repo `git clone <path-to-git-project>`
- And get into the folder of the repo `cd <git-project-name>`
- Sometimes you will need to switch the branch here
- Install all the requirements of the repo `python3.9 -m pip install -r requirements.txt`
- If you just want to look at the output run `mkdocs serve 2>&1 | tee ./mkdocs.serve.log`

To develop then, the easiest way is to use VS Code with the [Remote - WSL](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl), where you have to open the repo in the container (click on the Remote symbol on the lower left, 'Open folder in WSL...').

For toolbox just place the repo inside your user profile and you will be able to access it with VS Code inside and outside of the toolbox container.

And finally run `mkdocs serve 2>&1 | tee ./mkdocs.serve.log` in the terminal of this VS Code session. Then you are ready to start changing stuff!

## Docker

From the root of this repository on a machine with Docker installed, run

    docker-compose up

When the container finishes starting up, you can access the documentation in your web browser at [http://localhost:8000](http://localhost:8000).

{% include 'teams/testing/rc_content_bottom.md' %}
