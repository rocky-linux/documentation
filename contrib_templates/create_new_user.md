---
title: How to Create New Users and Group Accounts
author: Sasheeny Hubbard
contributors: Sasheeny Hubbard
tested with: 9.4
tags:
  - desktop
  - gnome
  - cockpit
---

# How to Create New Users and Group Accounts

## Introduction

  This guide will teach you how to manage user and group accounts on Rocky Linux 9.4 using Cockpit, a web-based graphical interface administrative tool for Linux servers.
  
## Prerequsites
- Access to Rocky Linux 9 OS with GUI
- Administrative Priviledges
- Cockpit package installed and enabled

## Cockpit

Cockpit is a web-based graphical interface administrative tool for Linux servers. While it has many use cases, we  will be using Cockpit for managing user and group accounts. The benefits of using Cockpit include ease of use, remote management, integration, real-time feedback and multi-server dashboards. 

### Log In to Cockpit

- Open your web browser and enter https://localhost:9090 in the address bar
    >*Note: You can also enter the same address on the command line
    ```text 
    https://localhost:9090
    ``` 
- Enter your username and password and click the **Log In** button

    ![img](../rocky_linux_images/1.png)

- Click the **Limited access** button and enter your password to enable administrative access

    ![img](../rocky_linux_images/2.png)

## User and Group Manangement

### Managing User Accounts

- From the left menu, click **Accounts** tab and then click on the **Create new account** button

    ![img](../rocky_linux_images/5.png)


- Enter the user's name in the **Full name** text box
  >*Note that the username will be automatically populated based on the full name. However the username field is also editable.*
- Enter a password for the new user
- Click the **Create** button


    ![img](../rocky_linux_images/8.png)


**CLI counterpart**

```text
sudo useradd jdoe -md /home/jdoe -u 1002 -s /bin/bash 
```

```text
sudo passwd jdoe 
```

Observe the addition of the new user to the list of users displayed under the **Accounts** tab.

![img](../rocky_linux_images/9.png)

**CLI counterpart**

```text
cat /etc/passwd
```

#### Modify User Account

- Click the vertical ellipsis icon for our new user, jdoe, and click **Edit user**

    ![img](../rocky_linux_images/13.png)

This is where we can modify user account settings, such as:

- Full name
- Group membership
- Password settings
- Shell

    ![img](../rocky_linux_images/15.png)

To add a user to a group do the following:

- Click the vertical ellipsis icon next to the new user and click **Edit user**

- Click the **Groups** text box and begin typing the name of the group.  
  Alternatively, you can scroll down the dropdown menu and click the name of the group you wish to add 

    ![img](../rocky_linux_images/14.png)

**CLI counterpart**
```text
sudo usermod -aG groupname username
```

To remove the user from a group:

- Click the **x** next to the group name

    ![img](../rocky_linux_images/18.png)

**CLI counterpart**
```text
sudo gpasswd -d username groupname
```

#### Delete User Account

To delete a user account:

- Click the vertical ellipsis icon for our new user, jdoe, and click **Delete account**

    ![img](../rocky_linux_images/16.png)

Or 
- Click the username highlighted in blue and select **Delete** box

    ![img](../rocky_linux_images/17.png)

    ![img](../rocky_linux_images/22.png)

**CLI counterpart**
```text
sudo userdel -d username groupname
```

### Creating and Deleting and Managing Group Accounts

- From the the left menu column, click **Accounts** tab then, click the **Create new group** button

    ![img](../rocky_linux_images/7.png)

- Enter the group name in the text box
>*Note: You can accept the default group ID or change it to the numerical value you desire (e.g. 5001)*
- Click the **Select** button

    ![img](../rocky_linux_images/11.png)

**CLI counterpart**
```text
sudo groupadd groupname
```

To verify the group has been created:

- Enter the group name in the search box on the **Groups** table 

Or 

-  Click the dropdown menu next to **Groups**

    ![img](../rocky_linux_images/12.png)

**CLI counterpart**
```text
cat /etc/group | grep groupname
```

To delete a group:

- Click the vertical ellipsis for the new user and click **Delete group**

    ![img](../rocky_linux_images/21.png)
  
**CLI counterpart**

```text
sudo groupdel groupname
```

```text
getent group | grep groupname
```

## Conclusions

  It works great!

---

## REFERENCES

To Install Cockpit: https://ciq.com/blog/how-to-administer-rocky-linux-with-cockpit/
