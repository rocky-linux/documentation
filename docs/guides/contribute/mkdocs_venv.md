---
title: MkDocs in Virtual Enviroment
author: Franco Colussi
contributors: Steven Spencer
tested with: 8.7, 9.1
tags:
  - mkdocs
  - testing
  - documentation
---

# MkDocs (Python Virtual Enviroment)

## Introduction

One of the aspects of the process of creating documentation for Rocky Linux is verifying that our new document displays correctly before of its publication.

The purpose of this guide is to give some suggestions for performing this task in a local python environment dedicated solely for this purpose.

The documentation for Rocky Linux is written using the Markdown language, a language designed to be converted to other formats, clean in syntax and particularly well suited for writing technical documentation.

In our case, the documentation is converted to `HTML` using a python application that takes care of building the static site. The application used by the developers is [MkDocs](https://www.mkdocs.org/).

One of the problems that arise during the development of a python application is to achieve isolation of the python instance used for development from the system interpreter, the isolation is to prevent any incompatibilities between the modules needed to install the python application and the modules installed on the host system. Any incompatibilities would result in visualization errors or malfunctions of our local site.

In this regard there are already excellent guides using **containers** for isolating the python interpreter, these guides, however, imply a knowledge of the various containerization techniques on which we can not be so, or at all, knowledgeable.

In this guide the `venv` module provided by the *python* package of Rocky Linux will be used for separation, this module is available on all new versions of *Python* since version 3.6. This will directly achieve the isolation of the python interpreter on the system we are using without the need to install and configure new "**systems**".

### Requirements

- a running copy of Rocky Linux
- the *python* package correctly installed
- familiarity with the command line
- an active internet connection

## Preparing the environment

The environment provides a root folder where to contain the two required Rocky Linux GitHub repositories and the folder where to initialize and later run our copy of python in the virtual environment.

We will then first go to create the folder that will contain everything else, and contextually we will also create the **env** folder where we will run MkDocs:

```bash
mkdir -p ~/lab/rockydocs/env
```

### Python Virtual Environment

To create our copy of Python where to run MkDocs we will use the module specially developed for the purpose, the python `venv` module, the module allows the creation of a virtual environment, derived from the one installed on the system, totally isolated and independent.

This will allow us to have a copy in a separate folder of the interpreter with only the packages required by `MkDocs` to run the Rocky Linux documentation installed.

We then go to the folder we just created (*rockydocs*) and create the virtual environment with:

```bash
cd ~/lab/rockydocs/
python -m venv env
```

The command will populate our **env** folder with a series of folders and files that mimic our system's *python* tree as shown below:

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

As we can see, the python interpreter used by the virtual environment is still the one available on the system `python -> /usr/bin/python`, the virtualization process only takes care of isolating our instance.

#### Activating the virtual environment

Among the files listed in the structure above we can see that there are several files named **activate** that serve this purpose, the suffix of each file indicates the related *shell*.

Activation separates this instance of python from the system instance and allows us to perform documentation development without interference. To activate it, we take ourselves to the *env* folder and run the command:

```bash
[rocky_user@rl9 rockydocs]$ cd ~/lab/rockydocs/env/
[rocky_user@rl9 env]$ source ./bin/activate
```

We used the *activate* command without any suffix as this refers to the *bash* shell, Rocky Linux's default shell. At this point our *shell prompt* should be changed to:

```bash
(env) [rocky_user@rl9 env]$
```

As we can see the initial *(env)* part indicates that we are now in the virtual environment. The first thing we need to do at this point is to update **pip** the python module manager that will be used to install MkDocs, to do this we use the command:

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

To exit the virtual environment, the *deactivate* command is provided:

```bash
(env) [rocky_user@rl9 env]$ deactivate
[rocky_user@rl9 env]$
```

As you can see, the terminal *prompt* after deactivation has reverted to the system one; in this regard, it is recommended that you always check the prompt carefully before running *MkDocs* installation and subsequent commands. The check will prevent unnecessary and unwanted global application installations and missed runs of `mkdocs serve`.

### Downloading the repositories

Now that we have seen how to create our virtual environment and how to manage it, we can move on to preparing everything we need.

Two repositories are required for the proper implementation of a local version of the Rocky Linux documentation, the documentation repository [documentation](https://github.com/rocky-linux/documentation) and the site structure repository [docs.rockylinux.org](https://github.com/rocky-linux/docs.rockylinux.org), both of which can be downloaded from the Rocky Linux GitHub.

We then start with the site structure repository, which we will clone into the **rockydocs** folder:

```bash
cd ~/lab/rockydocs/
git clone https://github.com/rocky-linux/docs.rockylinux.org.git
```

In this folder there are two files that we are going to use for building the local documentation and they are **mkdocs.yml** and **requirement.txt**, the former is the configuration file that we will use to initialize MkDocs while the latter contains all the python packages needed for the installation of *mkdocs*.

Once finished we also download the documentation repository:

```bash
git clone https://github.com/rocky-linux/documentation.git
```

At this point we will have the following structure in the **rockydocs** folder:

```text
rockydocs/
├── env
├── docs.rockylinux.org
├── documentation
```

Schematizing, we can say that the **env** folder will be our *MkDocs* engine that will use **docs.rockylinux.org** as a container to display the data contained in **documentation**.

### Installation of MkDocs

As we pointed out earlier, the developers of Rocky Linux provide the **requirement.txt** file, which contains the list of modules required for the proper run of a custom instance of MkDocs; we will use the file to install everything we need in a single operation.

First we enter our python virtual environment:

```bash
[rocky_user@rl9 rockydocs]$ cd ~/lab/rockydocs/env/
[rocky_user@rl9 env]$ source ./bin/activate
(env) [rocky_user@rl9 env]$
```

And we proceed to install MkDocs and all its components with the command:

```bash
(env) [rocky_user@rl9 env]$ python -m pip install -r ../docs.rockylinux.org/requirements.txt
```

To check that everything went well, we can call up the MkDocs help, which also introduces us to the commands that can be used:

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

If everything has worked as planned, we can exit the virtual environment and start preparing the necessary connections.

```bash
(env) [rocky_user@rl9 env]$ deacticate
[rocky_user@rl9 env]$
```

### Linking documentation

Now that we have everything we need prepared, all that is left is to link the documentation repository within the *docs.rockylinux.org* container site. Following the setup defined in *mkdocs.yml*:

```yaml
docs_dir: 'docs/docs'
```

We will first need to create a **docs** folder in **docs.rockylinux.org** and then from within it link our **docs** folder from the **documentation** repository.

```bash
cd ~/lab/rockydocs/docs.rockylinux.org
mkdir docs
cd docs/
ln -s ../../documentation/docs/ docs
```

## Starting Local Documentation

At this point we are ready to start our local copy of the Rocky Linux documentation, first we need to start the python virtual environment and then initialize our MkDocs instance with the settings defined in **docs.rockylinux.org/mkdocs.yml**.

This file contains all the settings necessary for localization, feature management, and theme management.

The developers for the site's UI chose the [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) theme, which provides many additional features and customizations over the default MkDocs theme.

We then perform the following commands:

```bash
[rocky_user@rl9 rockydocs]$ cd ~/lab/rockydocs/env/
[rocky_user@rl9 rockydocs]$ source ./bin/activate
(env) [rocky_user@rl9 env]$ mkdocs serve -f ../docs.rockylinux.org/mkdocs.yml
```

We should see in our terminal the start of site construction during which we will be notified of any errors found by MkDocs such as missing links or other:

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

By now opening our browser at the address specified above we will have our copy of the documentation site running, the copy perfectly mirrors the online site in functionality and structure therefore allowing us to assess the appearance and impact our page will have on the site.

MkDocs incorporates a mechanism for checking changes to the files in the folder specified by the `docs_dir` path, and inserting a new page or modifying an existing one in `documentation/docs` will automatically be recognized and produce a new static site build.

Since the time for MkDocs to build the static site can be several minutes on not very powerful computers it is recommended to carefully review the page you are writing before saving or inserting it. This saves waiting while the site is being rebuilt just because we forgot for example punctuation.

### Exit the Development Environment

Once we are satisfied with how our new page will display on the site we can exit our development environment, this involves first exiting *MkDocs* and then deactivating the python virtual environment. To exit *MkDocs* we need to type the key combination <kbd>CTRL</kbd> + <kbd>C</kbd> while as we saw above to exit the virtual environment we will need to invoke the `deactivate` command.

```bash
...
INFO     -  [22:32:41] Serving on http://127.0.0.1:8000/
^CINFO     -  Shutting down...
(env) [rocky_user@rl9 env]$
(env) [rocky_user@rl9 env]$ deacticate
[rocky_user@rl9 env]$
```

## Conclusions and final thoughts

Verification of our new pages in a local development site provides us with the assurance that our work will always conform to the online documentation site therefore allowing us to contribute optimally.

Document compliance is also a great help to the curators of the documentation site, who then only have to deal with the correctness of the content.

In conclusion, we can say that this method allows meeting the requirements for a "clean" installation of MkDocs without the need to resort to containerization.
