---
title: Navigational Changes
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zyhrnova
tags:
  - contribute
  - navigation
---

# Navigational Changes - A Process Document for Managers or Editors

## Reason for this document

When the documentation project started, it was hoped that menus in Mkdocs would be as automatic as possible, making manual navigation editing rare. After a few months of generating documents, it became clear that just placing documents in the correct folder and letting Mkdocs generate the navigation could not be depended on to keep things clean and neat. We needed categories, which Mkdocs does not provide unless the documents are placed in specific folders. Mkdocs will then create a navigation with an alphabetic sort. However, creating a folder structure that fixes navigation is not the entire picture. Even that will sometimes need additional changes to keep things organized. For instance, capitalization without modifying the lower-case folder structure.

## Goals

Our goals were:

* Create the folder structure as needed now (new folders may be required in the future)
* Adjust the navigation so that the Rocky Installation, Migration, and Contribution areas were at the top
* Adjust the navigation to name some folders better, and enable correct capitalization. As an example, "DNS" and "File Sharing Services" otherwise show up as "Dns" and "File sharing" without some manipulation. 
* Ensure that these navigation files are restricted to Managers and Editors

This last item may seem unnecessary to some reading this, but it will become more apparent as this document continues.

## Assumptions

The assumption is that you have a local clone of the Rocky GitHub repository: [https://github.com/rocky-linux/documentation](https://github.com/rocky-linux/documentation).

## Environment changes

With these changes comes a real need to "see" how any changes you are making affect content, in the context of the website, _BEFORE_ that content is committed to the document repository, and subsequently goes 'live'.

MkDocs is a [Python](https://www.python.org) application and the extra packages it uses are also Python code, this means that the environment required to run MkDocs needs to be a **correctly configured Python environment**. Setting up Python for development tasks (which is what is being done running MkDocs) is not a trivial task, and instructions for that are out of the scope of this document. Some considerations are:

* The version of Python should be >= 3.8, also **particular care must be taken not to use the 'system' Python version of a computer if the computer runs Linux/macOS**. For example, as of the writing of this document, the system version of Python on macOS is still version 2.7.
* Running a Python 'virtual environment'. When running Python application project and installing packages, for example MkDocs, it is **strongly recommended** by the Python community to [create an isolated virtual environment](https://realpython.com/python-virtual-environments-a-primer/) for each project.
* Use a modern IDE (Integrated Development Environment) that supports Python well. Two popular IDEs, which also have integrated support for running virtual environments, are:
    * PyCharm - (free version available) the leading IDE for Python https://www.jetbrains.com/pycharm/
    * Visual Studio Code - (free version available) from Microsoft https://code.visualstudio.com

Doing this effectively requires:

* Setting up a new Python project which, ideally, uses a virtual environment (above).
* Installing `mkdocs`
* Installing some python plugins
* Cloning this Rocky GitHub repository:[https://github.com/rocky-linux/docs.rockylinux.org](https://github.com/rocky-linux/docs.rockylinux.org)
* Linking to the `docs` folder within your cloned documentation repository (you can also just modify the mkdocs.yml file if you wish to load the correct folder, but linking keeps your mkdocs environment cleaner)
* Running `mkdocs serve` within your clone of docs.rockylinux.org

!!! tip

    You can build totally separate environments for `mkdocs` by using any of procedures found in the "Local Documentation" section of the "Contribute" menu.

!!! Note

    This document was written in a Linux environment. If your environment is different (Windows or Mac), then you will need to research matching up to some of these steps. An editor or manager reading this can submit changes to it to add in steps for those environments.

### Installing

* Install `mkdocs` with the python environment: `pip install mkdocs`
* Install needed plugins:  `pip install mkdocs-material mkdocs-localsearch mkdocs-awesome-pages-plugin mkdocs-redirects mkdocs-i18n`
* Clone the repository (noted above)

### Linking and running `mkdocs`

Inside your docs.rockylinux.org local (clone), do the following. This assumes the location of your documentation clone, so modify as needed:

`ln -s /home/username/documentation/docs docs`

Again, if you desire, you can modify the local copy of the `mkdocs.yml` file to set the path. If using this method, you would modify this line to point to your `documentation/docs` folder:

```
docs_dir: 'docs/docs'
```

Once completed, you can try running `mkdocs serve` to see if you get your desired content. This will run on your localhost on port 8000; for example: <a href="http://127.0.0.1:8000/">http://127.0.0.1:8000/</a> 

## Navigation and other changes

Navigation is handled with mkdocs `.pages` files **OR** by the value of the "title:" meta in the document front matter. The `.pages` files are not terribly complex, BUT, if something is left out, it can cause the server to fail to load. That's why this procedure is **ONLY** for Managers and Editors. These individuals are going to have the tools in place (local install of mkdocs, plus clones of both documentation and docs.rockylinux.org) so that something pushed and merged to GitHub will not break the serving of the documentation website. A contributor cannot be expected to have even one of these requirements.


### `.pages` files

As already stated, the `.pages` files are generally pretty simple. They are a YAML formatted file that `mkdocs` reads before rendering the content. To take a look at one of the more complex `.pages` files, let's look at the one created to help format the side navigation:

```
---
nav:
    - ... | index*.md
    - ... | installation*.md
    - ... | migrate2rocky*.md
    - Contribute: contribute
    - Automation: automation
    - Backup & Sync: backup
    - Content Management: cms
    - Communications: communications
    - Containers: containers
    - Database: database
    - Desktop: desktop
    - DNS: dns
    - Email: email
    - File Sharing Services: file_sharing
    - Git: git
    - Interoperability: interoperability
    - Mirror Management: mirror_management
    - Network: network
    - Package Management: package_management
    - ...

```
Here, the `index*md` shows the "Guides Home: ", `installation*.md` shows the "Installing Rocky Linux" document link, and the `migrate2rocky*.md` shows the "Migrating To Rocky Linux" document link. The "*" within each link allows that document to be in _any_ language. Finally, by placing "Contribute" next, it falls beneath these items rather than in the normal (alphabetic) sort order. Looking down the list, you can see what each item is doing. Note that after the "Package Management: package_management" entry, there are actually two more folders (security and web). These do not require any additional formatting, so we are just telling `mkdocs` to load them normally with the "-..."

You can also use YAML formatting within an actual file. A reason for doing this might be that the beginning heading of the file is so long, that it just doesn't display well in the navigation section.  As an example, take this document heading "# `mod_ssl` on Rocky Linux in an httpd Apache Web-Server Environment". That is very long. It displays very poorly in the side navigation once the "Web" navigation item is opened. To fix this, you can either work with the author to change his heading, or, you can change how it displays in the menu by adding a title before the heading inside the document. For the example document, there is a title added:
```
---
title: Apache With `mod_ssl`
---
```
This changes the title regarding the navigation but leaves the author's original title in place within the document.

There will probably not be a lot of need for additional `.pages` files. They should be used economically.

## Conclusion

While the navigational changes that might need to be made are not difficult, the potential for breaking the live documentation exists. For this reason, only managers and editors with the appropriate tooling in place should have the permissions to edit these files. Having a full environment available to view what the live pages will look like keeps the manager or editor from making a mistake while editing these files, breaking the live documentation.
