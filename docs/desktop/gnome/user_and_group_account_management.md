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
  
## Prerequisites
- Access to Rocky Linux 9 OS with GUI
- Administrative Privileges
- Cockpit package installed and enabled

## Cockpit

Cockpit is a web-based graphical interface administrative tool for Linux servers. While it has many use cases, we  will be using Cockpit for managing user and group accounts. The benefits of using Cockpit include ease of use, remote management, integration, real-time feedback and multi-server dashboards. 

### Log In to Cockpit

- Open your web browser and enter https://localhost:9090 in the address bar
    >**Note**: You can also enter the same address on the command line

    ```text 
    https://localhost:9090
    ``` 
- Enter your username and password and click the **Log In** button

    ![img](images/user_group_acctmgt_images/1.png)



- Click the **Limited access** button and enter your password to enable administrative access

    ![img](images/user_group_acctmgt_images/2.png)

## User and Group Management

### Managing User Accounts

- From the left menu, click **Accounts** tab and then click on the **Create new account** button

    ![img](images/user_group_acctmgt_images/5.png)


- Enter the user's name in the **Full name** text box
  >*Note that the username will be automatically populated based on the full name. However, you can also edit the User name and User ID fields if needed.*
- Enter a password for the new user
- Click the **Create** button


    ![img](images/user_group_acctmgt_images/8.png)


**CLI counterpart**

```text
sudo useradd username -md /home/username -u 1002 -s /bin/bash 
```

```text
sudo passwd username 
```

Observe the addition of the new user to the list of users displayed under the **Accounts** tab.

![img](images/user_group_acctmgt_images/9.png)

**CLI counterpart**

```text
cat /etc/passwd
```

#### Modify User Account

- Click the vertical ellipsis icon for the new user and then click **Edit user**

    ![img](images/user_group_acctmgt_images/13.png)

This is where you can modify the user account settings, such as:

- Full name
- Group membership
- Password settings
- Shell

    ![img](images/user_group_acctmgt_images/15.png)

To add a user to a group do the following:

- Click the vertical ellipsis icon next to the new user and click **Edit user**

- Click the **Groups** text box and begin typing the name of the group.  
  Alternatively, you can scroll down the dropdown menu and click the name of the group you wish to add 

    ![img](images/user_group_acctmgt_images/14.png)

**CLI counterpart**
```text
sudo usermod -aG groupname username
```

To remove a user from a group:

- Click the **x** next to the group name

    ![img](images/user_group_acctmgt_images/18.png)

**CLI counterpart**
```text
sudo gpasswd -d username groupname
```

#### Delete User Account

To delete a user account:

- Click the vertical ellipsis icon for the new user and click **Delete account**

    ![img](images/user_group_acctmgt_images/16.png)

Or 
- Click the username highlighted in blue and select **Delete** box

    ![img](images/user_group_acctmgt_images/17.png)

    ![img](images/user_group_acctmgt_images/22.png)

**CLI counterpart**
```text
sudo userdel -d username groupname
```

### Creating and Deleting and Managing Group Accounts

- From the the left menu column, click **Accounts** tab then, click the **Create new group** button

    ![img](images/user_group_acctmgt_images/7.png)

- Enter the group name in the text box
>*Note: You can accept the default group ID or change it to the numerical value you desire (e.g. 5001)*
- Click the **Select** button

    ![img](images/user_group_acctmgt_images/11.png)

**CLI counterpart**
```text
sudo groupadd groupname
```

To verify the group has been created:

- Enter the group name in the search box on the **Groups** table 

Or 

-  Click the dropdown menu next to **Groups**

    ![img](images/user_group_acctmgt_images/12.png)

**CLI counterpart**
```text
cat /etc/group | grep groupname
```

To delete a group:

- Click the vertical ellipsis for the new user and click **Delete group**

    ![img](images/user_group_acctmgt_images/21.png)
  
**CLI counterpart**
```text
sudo groupdel groupname
```

```text
getent group | grep groupname
```

## Conclusions

  Congratulations, you did it!

  In conclusion, this guide has equipped you with the knowledge needed to successfully manage user and group accounts on Rocky Linux 9.4 using Cockpit. Cockpit's easy-to-use web-based graphical interface, makes executing administrative tasks more accessible and efficient, allowing you to take full advantage of its user-friendly features for smooth system management.

---

## REFERENCES

To Install Cockpit: https://ciq.com/blog/how-to-administer-rocky-linux-with-cockpit/
