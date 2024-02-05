---
title: Dnf Package Manager
author: Emre Camalan
contributors: Steven Spencer, Antoine Le Morvan, K.Prasad, Ganna Zhyrnova, Emre Camalan
tested_with: 8.9, 9.3
tags:
  - Dnf
  - Yum
  - Rpm
  - Package Manager
---

# Dnf Package Manager

DNF, or Dandified Yum, is a package manager used in some Linux distributions. It is the next generation version of the Yum (Yellowdog Updater, Modified) package manager, which was widely used in Red Hat-based systems. DNF was introduced as a replacement for Yum to address some limitations and improve performance. 

DNF is commonly used in Rocky Linux, Fedora, RHEL (Red Hat Enterprise Linux) 8 and later, and other Linux distributions that have adopted it as their package manager. It aims to provide a more modern and efficient package management experience for users and administrators.

* For all Rocky Linux versions, the ability to use `sudo` to elevate privileges.

## Installing Packages

  At this point you can use the Dnf package manager on Rocky Linux operating system just like you do with other package managers to install, remove, and update the packages you desire.


  ```bash
  sudo dnf install package_name1 package_name2 package_name3 
  ```

  ```bash
  sudo dnf install perl 
  ```
  ![dnf install perl](../images/dnf_install_1_1.png)

  ![dnf install perl](../images/dnf_install_1_2.png)

  ![dnf install perl](../images/dnf_install_1_3.png)

Installing a package group , for install installing Xfce desktop, Kde Desktop etc.

```Bash
sudo dnf groupinstall xfce
```

![dnf groupinstall](../images/dnf_groupinstall_1.png)

Another ways for KDE Desktop;

```Bash
sudo dnf group install "KDE Plasma Workspaces"
sudo dnf group install kde-desktop-environment
sudo dnf install @kde-desktop-environment
```



## Update and Upgrade Packages

  ## Update & Upgrade

  If you decided to update your packages, use this simple code on the terminal.

  ### Update your system


  ```bash
  sudo dnf update
  ```

  ![dnf update](../images/dnf_update_1.png)

    ### Upgrade your system

  ```bash
  sudo dnf upgrade
  ```

    ![dnf upgrade](../images/dnf_upgrade_1.png)


  ### Update your single package


  ```bash
  sudo dnf upgrade package_name
  ```
  For example you want to upgrade your python package. You can upgrade single package with dnf.

  ![dnf upgrade](../images/dnf_upgrade_2.png)

  Previously we upgrade all system so there is no need to upgrade any package.


## Removing Packages
Similarly to installing packages, you can use `dnf` to uninstall packages. However, package dependencies are crucial in Linux systems, and if you are not aware of these dependencies, I recommend not removing a package. For instance, a mistakenly installed package may have 20 dependencies, and when you remove that package, the system will also remove those 20 packages shared with other programs. Consequently, some previously functioning programs may become unusable. Moreover, if you think you can resolve it by reinstalling the same package, you may encounter version and old version conflict issues. I advise you to be cautious in this regard.

!!! Warning
    DNF cannot remove a package without also removing packages that depend on it. 

> ~]$ sudo dnf remove package_name1 package_name2

```Bash
sudo dnf remove totem
```
![dnf remove](../images/dnf_remove_1.png)


!!! Note
    Be careful, DNF shows the package dependencies! 
    If you remove Perl, you will remove 254 packages that depend on Perl!

```Bash
sudo dnf remove perl
```
![dnf remove](../images/dnf_remove_2.png)

![dnf remove](../images/dnf_remove_3.png)




```Bash
~]$ sudo dnf group remove "KDE Plasma Workspaces"
~]$ sudo dnf group remove kde-desktop-environment
~]$ sudo dnf remove @kde-desktop-environment
```


## Dnf List

  Listing any package if you don't know whole name of the package by running this command:

  ```bash
  dnf list kernel*
  ```
  ![dnf listing](../images/dnf_list_1.png)

  Lists information on installed and available kernel tools and modules matching information with this command:

  ```bash
  dnf list kernel-tools\* kernel-modules\*
  ```

  ![dnf listing](../images/dnf_list_2.png)


  Lists all installed and available packages.

  ```Bash
  dnf list all
  ```

  ![dnf list all](../images/dnf_list_3.png)

  How many packages are there in Rocky Linux ?

  ```Bash
  dnf list all | wc -l
  ```

  ![dnf list all](../images/dnf_list_4.png)
  
  
  Lists all packages installed on your Rocky Linux System.

  ```Bash
  dnf list installed "krb?-*"
  ```

  ![dnf all installed](../images/dnf_list_5.png)


  Lists all available packages in all enabled repositories.

  ```Bash
  dnf list available "perl"
  ```

  ![dnf available](../images/dnf_list_6.png)


  Lists all package groups.

  ```Bash
  dnf group list 
  ```

  ![dnf group](../images/dnf_list_7.png)

  Lists the repository information of packages it provides for each enabled repository.

  ```Bash
  dnf repolist 
  ```

  ![dnf repolist](../images/dnf_list_8.png)

## Dnf List History
You can see dnf list history with this simple command;

```Bash
dnf history List
```

![dnf history list](../images/dnf_history_1.png)

<br>

One of the most advantageous aspects of DNF history is the ability to revert and repeat transactions.

```Bash
dnf history undo id
```

```Bash
dnf history redo id
```

![dnf history redo](../images/dnf_history_2.png)

The `sudo dnf history redo 9` command used to repeat the command with ID:9 from the DNF History List, and it attempted to reinstall `perl`. Naturally, since it had been installed before, the operation displayed 'already installed'.



### Searching Packages
Searching any package by running this command:

```bash
dnf search python
```

![dnf search](../images/dnf_search_1.png)

Searching more than one package in one search by running this command:

```bash
dnf search all yum vim
```
![dnf search all](../images/dnf_search_2.png)


### Dnf Package Information

To display information about packages, use this simple command as follows:


```bash
dnf info perl
```

![dnf info](../images/dnf_info_1.png)

To display information about all available packages, both installed and available from a repository, use this simple command as follows:

```bash
dnf repoquery perl --info
```

![dnf repoquery](../images/dnf_repoquery_1.png)


## Dnf Repository Configuration
The configuration file for DNF and its associated utilities can be found at `/etc/dnf/dnf.conf`. 
Within this file, there is a mandatory [main] section that allows the configuration of DNF options with global effects. Additionally, it may include one or more [repository] sections, providing the ability to set repository-specific options. 

Any values specified in the [repository] sections of the `/etc/dnf/dnf.conf` file will take precedence over values set in the [main] section.

![dnf conf](../images/dnf_conf_1.png)

Original text of Rocky Linux dnf.conf file;

>[ecamalan@localhost ~]$ cat /etc/dnf/dnf.conf 
[main]
gpgcheck=1
installonly_limit=3
clean_requirements_on_remove=True
best=True
skip_if_unavailable=False

### Dnf Config-manager
To retrieve a comprehensive list of configuration options along with their respective values and information about repositories, utilize the dnf config-manager command with the --dump option.

```Bash
dnf config-manager --dump
```

![dnf config manager](../images/dnf_confmanager_1.png)



## Conclusion
Rocky linux uses DNF, the next generation replacement for YUM.
We have provided examples of basic DNF usage that you might generally need on this page. For more information, you can refer to the official documentation of DNF: 
https://dnf.readthedocs.io/en/latest/index.html



