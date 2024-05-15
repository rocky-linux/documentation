---
author: Wale Soyinka 
contributors: 
tested on: All Versions
tags:
  - samba
  - cifs
  - smbd
  - nmbd
  - smb.conf
  - smbpasswd
  - network file system
---

## Objectives

After completing this lab, you will be able to

- install and configure Samba
- share files and directories between Linux systems using Samba
- use common Samba utilities 

Estimated time to complete this lab: 40 minutes


## Samba

Samba allows for file sharing and printing services between Unix/Linux and Windows systems. 

Samba is an open source implementation of the “Common Internet File System” (CIFS). CIFS is also referred to as the Server Message Block (SMB), Lan Manager or NETBIOS protocol. 
The Samba server comprises of two main daemons – smbd and nmbd. 

*smbd* :  This daemon provides the file and print services to SMB clients, such as machines running various Microsoft operating systems. 

*nmbd* : This daemon provides NETBIOS name serving and browsing support. 


The exercises in this lab focus on setting up Samba as both a server and a client on a Rocky Linux server.


## Exercise 1

### Install Samba and configure a basic shared directory

#### To Install the Samba server application

1. Use the dnf utility to install the Samba server and client package on your server 
   Type:   
    ```bash
    sudo dnf install -y samba
    ```

#### To configure the Samba Service

1. Create a directory to be shared named samba-share under the /tmp folder. Type:
   
    ```bash
    mkdir /tmp/samba-share
    ```
2. Let's create a basic Samba Configuration to share the /tmp/samba-share folder. Do
    this by creating a new share definition in the Samba configuration file:

    ```bash
    sudo tee -a /etc/samba/smb.conf << 'EOF'
    [Shared]
    path = /tmp/samba-share
    browsable = yes
    writable = yes
    EOF
    ```

#### To start and enable the Samba service

1. Start and Enable Samba Services:

    ```bash
    sudo systemctl start smb nmb
    sudo systemctl enable smb nmb
    ```
2. Verify the daemons used by the Samba service are running:

    ```bash
    sudo systemctl status smb nmb
    ```

## Exercise 2

### Samba users

An important and common administrative task for managing a Samba server is creating users, creating passwords for users that need to access the shared resources.

This exercise shows how to create Samba users and set up access credentials for the users.

#### To create a Samba user and samba password

1. First create a regular system user named sambarockstar. Type:

    ```bash
    sudo useradd sambarockstar
    ```

2. Verify that the user was properly created. Type:
    ```bash
    id sambarockstar
    ```
3. Add the new sambarockstar system user to the Samba user database and simultanously
   set a password for the Samba user:

    ```bash
    sudo smbpasswd -a sambarockstar
    ```
    When prompted, input the selected password and press ENTER after each entry.
4. Restart Samba Services:
    ```bash
    sudo systemctl restart smb nmb
    ```

## Exercise 3

### Accessing Samba Share (Local test)

In this exercise, we'll try accessing the new Samba share from the same system. This means that we'll be using the same host as both a server and client.

#### To install Samba client tools 

1. Install Client Utilities by running:

    ```bash
    sudo dnf -y install cifs-utils
    ```
#### To create a Samba mount point

1. Create the mount point:
    ```bash
    mkdir ~/samba-client
    ```

#### To mount an SMB file system locally

1. Mount Samba Share Locally:

```bash
sudo mount -t cifs //localhost/Shared ~/samba-client -o user=sambarockstar
```
2. Use the `mount` command to list all mounted CIFS type file systems. Type:
   ```bash
   mount -t cifs
   ```
   OUTPUT
   ```bash
   //localhost/Shared on ~/samba-client type cifs (rw,relatime,vers=3.1.1,cache=strict,username=sambarockstar....
   ...<SNIP>...
   ```
3. Similarly use the `df` command to verify that the mounted share is available. Type:

    ```bash
    df -t cifs
    ```

    OUTPUT:
    ```
    Filesystem         1K-blocks     Used Available Use% Mounted on
    //localhost/Shared  73364480 17524224  55840256  24% ~/samba-client
    ```
4. Next list the contents of the mounted share. Type:

    ```bash
    ls ~/samba-client
    ```
5. Create a test file in Share:

    ```bash
    touch ~/samba-client/testfile.txt
    ```

## Exercise 4

### Modifying Share Permissions

#### To adjust share permissions 

1. Make the "Shared" samba share definition read-only. This can be done by changing the value of the writable parameter from yes to no in the smb.con configuration file. Let's use a `sed` onliner to accomplish this by running: 

    ```bash
    sudo  sed -i'' -E \
     '/\[Shared\]/,+3 s/writable =.*$/writable = no/'  /etc/samba/smb.conf
    ```
2. Restart Samba services:
   
```bash
sudo systemctl restart smb nmb
```
3. Now, test writing to the share by trying to create a file on the mounted share:

    ```bash
    touch ~/samba-client/testfile2.txt
    ```

## Exercise 5

### Using Samba for Specific User Groups

This exercise will walk through how to restrict access to Samba shares via a user's local group membership. This provides a convenient mechanism for making shared resources accessible only to specific user groups.

#### To create a new group for Samba user 

1. Use the groupadd utility to create a new system group named rockstars. This is the group that we'll use in our example for housing system users that can access a given resource. Type: 
    ```bash
    sudo groupadd rockstars
    ```    
2. Add an existing system/Samba user to the group. Type:
    ```bash
    sudo usermod -aG rockstars sambarockstar
    ```
#### To configure valid users in Samba configuration

1. Use the sed utility to add a new valid users paranter to the share definition in the 
   Samba config file. Type:
    ```bash
    sudo sed -i '/\[Shared\]/a valid users = @sambagroup' /etc/samba/smb.conf
    ```
2. Restart Samba services:
    ```bash
    sudo systemctl restart smb nmb
    ```
3. Now test access to the share with sambarockstar and verify access.


## Exercise 6

This exercise simulates a real-world scenario where you'll act in the role of an Administrator of a client system, and then test accessing the Samba service on remote system (serverHQ) on which you do not have any Administrative access or privileges.  client as a student, will set up a Samba client on your machine (serverXY) to access a Samba service hosted on a different machine (serverHQ). This reflects common workplace setups.

Assumptions
- You do not have root access on serverHQ.
- The Samba share on serverHQ is already set up and accessible.

#### To Setting Up Samba Client on serverXY

Configure your machine (serverXY) as a Samba client to access a shared directory on a separate host (serverHQ).

1. Ensure that the necessary samba client utilities are installed on your local system.
    Install them if necessary by running: 

    ```bash
    sudo dnf install samba-client cifs-utils -y
    ```
2. Create a Mount Point on serverXY:

    ```bash
    mkdir ~/serverHQ-share
    ```

#### To mount the Samba Share from serverHQ

You will need the IP address or hostname of serverHQ, the share name, and your Samba credentials.

1. Replace serverHQ, sharedFolder, and yourUsername with the actual values.

    ```bash
    sudo mount -t cifs //serverHQ/sharedFolder ~/serverHQ-share -o user=yourUsername
    ```
#### To verify and access the mounted Share

1. Check if the shared directory from serverHQ is successfully mounted on your machine:

    ```bash
    ls ~/serverHQ-share
    ```
2. Try accessing and modifying files within the mounted share. For example, to create a new file:

    ```bash
    touch ~/serverHQ-share/newfile.txt
    ```

#### To unmount the remote share

1. Once done, unmount the share:

    ```bash
    sudo umount ~/serverHQ-share
    ```