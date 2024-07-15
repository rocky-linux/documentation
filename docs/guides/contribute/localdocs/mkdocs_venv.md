---
title: Python VENV Method 
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.7, 9.1, 9.4
tags:
  - mkdocs
  - testing
  - documentation
---

# MkDocs (Python Virtual Environment)

## Introduction

One of the aspects of the process of creating documentation for Rocky Linux is verifying that your new document displays correctly before publication.

The purpose of this guide is to give some suggestions for performing this task in a local python environment dedicated solely to this purpose.

The documentation for Rocky Linux is written using the Markdown language, generally converted to other formats. Markdown is clean in syntax and particularly well suited for writing technical documentation.

In our case, the documentation is converted to `HTML` using a python application that takes care of building the static site. The application used by the developers is [MkDocs](https://www.mkdocs.org/).

One problem that arises during the development of a python application is achieving isolation of the python instance used for development from the system interpreter. The isolation prevents incompatibilities between the modules needed to install the Python application and those installed on the host system.

There are already excellent guides that use **containers** for isolating the python interpreter. These guides, however, imply a knowledge of the various containerization techniques.

In this guide the `venv` module provided by the *python* package of Rocky Linux is used for separation. This module is available on all new versions of *Python* since version 3.6. This will directly achieve the isolation of the python interpreter on the system without the need to install and configure new "**systems**".

### Requirements

- a running copy of Rocky Linux
- the *python* package correctly installed
- familiarity with the command line
- an active internet connection

## Preparing the environment

The environment provides a root folder containing the two required Rocky Linux GitHub repositories and the folder where initialization, and running your copy of python in the virtual environment occurs.

First, create the folder that will contain everything else, and contextually, also create the **env** folder where MkDocs will run:

```bash
mkdir -p ~/lab/rockydocs/env
```

### Python virtual environment

To create your copy of Python where MkDocs will run, use the module specially developed for this purpose, the python `venv` module. This allows the creation of a virtual environment, derived from the one installed on the system, totally isolated and independent.

This will allow us to have a copy, in a separate folder, of the interpreter with only the packages required by `MkDocs` to run the Rocky Linux documentation.

Go to the folder just created (*rockydocs*) and create the virtual environment with:

```bash
cd ~/lab/rockydocs/
python -m venv env
```

The command will populate your **env** folder with a series of folders and files that mimic your system's *python* tree shown here:

```text
env/
├── bin
│   ├── activate
│   ├── activate.csh
│   ├── activate.fish
│   ├── Activate.ps1
│   ├── pip
│   ├── pip3
│   ├── pip3.11
│   ├── python -> /usr/bin/python
│   ├── python3 -> python
│   └── python3.11 -> python
├── include
│   └── python3.11
├── lib
│   └── python3.11
├── lib64 -> lib
└── pyvenv.cfg
```

As you can see, the python interpreter used by the virtual environment is still the one available on the system `python -> /usr/bin/python`. The virtualization process only takes care of isolating your instance.

#### Activating the virtual environment

Among the files listed in the structure, there are several files named **activate** that serve this purpose. The suffix of each file indicates the related *shell*.

Activation separates this python instance from the system python instance and allows us to perform documentation development without interference. To activate it, go to the *env* folder and run the command:

```bash
[rocky_user@rl9 rockydocs]$ cd ~/lab/rockydocs/env/
[rocky_user@rl9 env]$ source ./bin/activate
```

The *activate* command was issued without any suffix because this refers to the *bash* shell, Rocky Linux's default shell. At this point your *shell prompt* should be:

```bash
(env) [rocky_user@rl9 env]$
```

As you can see, the initial *(env)* part indicates that you are now in the virtual environment. The first thing to do at this point is to update **pip** the python module manager that will is used to install MkDocs. To do this, use the command:

```bash
python -m pip install --upgrade pip
```

```bash
python -m pip install --upgrade pip
Requirement already satisfied: pip in ./lib/python3.9/site-packages (21.2.3)
Collecting pip
  Downloading pip-23.1-py3-none-any.whl (2.1 MB)
    |████████████████████████████████| 2.1 MB 1.6 MB/s
Installing collected packages: pip
  Attempting uninstall: pip
    Found existing installation: pip 21.2.3
    Uninstalling pip-21.2.3:
      Successfully uninstalled pip-21.2.3
Successfully installed pip-23.1
```

#### Deactivate the environment

To exit the virtual environment, use the *deactivate* command:

```bash
(env) [rocky_user@rl9 env]$ deactivate
[rocky_user@rl9 env]$
```

As you can see, the terminal *prompt* has reverted to the system one after deactivation. You should always check the prompt carefully before running *MkDocs* installation and subsequent commands. Checking this will prevent unnecessary and unwanted global application installations and missed runs of `mkdocs serve`.

### Downloading the repositories

Now that you have seen how to create your virtual environment and how to manage it, you can move on to preparing everything needed.

Two repositories are required to implement a local version of the Rocky Linux documentation: the documentation repository [documentation](https://github.com/rocky-linux/documentation), and the site structure repository [docs.rockylinux.org](https://github.com/rocky-linux/docs.rockylinux.org). Downloading these is done from the Rocky Linux GitHub.

Start with the site structure repository, which you will clone into the **rockydocs** folder:

```bash
cd ~/lab/rockydocs/
git clone https://github.com/rocky-linux/docs.rockylinux.org.git
```

In this folder there are two files that you are going to use for building the local documentation. They are **mkdocs.yml**, the configuration file used to initialize MkDocs, and **requirement.txt**, which has all the python packages needed for installing *mkdocs*.

When finished, you also need to download the documentation repository:

```bash
git clone https://github.com/rocky-linux/documentation.git
```

At this point you will have the following structure in the **rockydocs** folder:

```text
rockydocs/
├── env
├── docs.rockylinux.org
├── documentation
```

Schematizing, you can say that the **env** folder will be your *MkDocs* engine that will use **docs.rockylinux.org** as a container to display the data contained in **documentation**.

### Installation of MkDocs

As pointed out earlier, the developers of Rocky Linux provide the **requirement.txt** file, which contains the list of modules required for the proper run of a custom instance of MkDocs. You will use the file to install everything needed in a single operation.

First you enter your python virtual environment:

```bash
[rocky_user@rl9 rockydocs]$ cd ~/lab/rockydocs/env/
[rocky_user@rl9 env]$ source ./bin/activate
(env) [rocky_user@rl9 env]$
```

Next, proceed to install MkDocs and all its components with the command:

```bash
(env) [rocky_user@rl9 env]$ python -m pip install -r ../docs.rockylinux.org/requirements.txt
```

To check that everything went well, you can call up the MkDocs help, which also introduces us to the available commands:

```bash
(env) [rocky_user@rl9 env]$ mkdocs -h
Usage: mkdocs [OPTIONS] COMMAND [ARGS]...

  MkDocs - Project documentation with Markdown.

Options:
  -V, --version  Show the version and exit.
  -q, --quiet    Silence warnings
  -v, --verbose  Enable verbose output
  -h, --help     Show this message and exit.

Commands:
  build      Build the MkDocs documentation
  gh-deploy  Deploy your documentation to GitHub Pages
  new        Create a new MkDocs project
  serve      Run the builtin development server
```

If everything has worked as planned, you can exit the virtual environment and start preparing the necessary connections.

```bash
(env) [rocky_user@rl9 env]$ deactivate
[rocky_user@rl9 env]$
```

### Linking documentation

Now that everything is available, you must link the documentation repository within the *docs.rockylinux.org* container site. Following the setup defined in *mkdocs.yml*:

```yaml
docs_dir: 'docs/docs'
```

You will first need to create a **docs** folder in **docs.rockylinux.org** and then from within it link your **docs** folder from the **documentation** repository.

```bash
cd ~/lab/rockydocs/docs.rockylinux.org
mkdir docs
cd docs/
ln -s ../../documentation/docs/ docs
```

## Starting local documentation

You are ready to start the local copy of the Rocky Linux documentation. First you need to start the python virtual environment and then initialize your MkDocs instance with the settings defined in **docs.rockylinux.org/mkdocs.yml**.

This file has all the settings for localization, feature, and theme management.

The developers for the site's UI chose the [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) theme, which provides many additional features and customizations over the default MkDocs theme.

Perform the following commands:

```bash
[rocky_user@rl9 rockydocs]$ cd ~/lab/rockydocs/env/
[rocky_user@rl9 rockydocs]$ source ./bin/activate
(env) [rocky_user@rl9 env]$ mkdocs serve -f ../docs.rockylinux.org/mkdocs.yml
```

You should see in your terminal the start of site construction. The display will show any errors found by MkDocs, such as missing links or other:

```text
INFO     -  Building documentation...
INFO     -  Adding 'de' to the 'plugins.search.lang' option
INFO     -  Adding 'fr' to the 'plugins.search.lang' option
INFO     -  Adding 'es' to the 'plugins.search.lang' option
INFO     -  Adding 'it' to the 'plugins.search.lang' option
INFO     -  Adding 'ja' to the 'plugins.search.lang' option
...
...
INFO     -  Documentation built in 102.59 seconds
INFO     -  [11:46:50] Watching paths for changes:
            '/home/rocky_user/lab/rockydocs/docs.rockylinux.org/docs/docs',
            '/home/rocky_user/lab/rockydocs/docs.rockylinux.org/mkdocs.yml'
INFO     -  [11:46:50] Serving on http://127.0.0.1:8000/
```

You will have your copy of the documentation site running when opening your browser at the address specified [http://127.0.0.1:8000](http://127.0.0.1:8000). The copy perfectly mirrors the online site in functionality and structure, allowing you to assess the appearance and impact your page will have on the site.

MkDocs incorporates a mechanism for checking changes to the files in the folder specified by the `docs_dir` path, and inserting a new page or modifying an existing one in `documentation/docs` will automatically be recognized and produce a new static site build.

Since the time for MkDocs to build the static site can be several minutes, the recommendation is to carefully review the page you are writing before saving or inserting it. This saves waiting for the site to build just because you forgot, for example, punctuation.

### Exit the development environment

Once the display of your new page meets your satisfaction, you can exit your development environment. This involves first exiting *MkDocs* and then deactivating the python virtual environment. To exit *MkDocs* you need to use the key combination ++ctrl++ + ++"C"++, and as you saw above, to exit the virtual environment you will need to invoke the `deactivate` command.

```bash
...
INFO     -  [22:32:41] Serving on http://127.0.0.1:8000/
^CINFO     -  Shutting down...
(env) [rocky_user@rl9 env]$
(env) [rocky_user@rl9 env]$ deactivate
[rocky_user@rl9 env]$
```

## Conclusions and final thoughts

Verifying your new pages in a local development site assures us that your work will always conform to the online documentation site, allowing us to contribute optimally.

Document compliance is also a great help to the curators of the documentation site, who then only have to deal with the correctness of the content.

In conclusion, you can say that this method allows for meeting the requirements for a "clean" installation of MkDocs without the need to resort to containerization.
