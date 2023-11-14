---
author: Wale Soyinka 
contributors: Steven Spencer, Ganna Zhyrnova
tested on: All Versions
tags:
  - network file system
  - nfs
  - exportfs
  - rpc
  - nfs-server
---

# Lab 5: NFS  

## Objectives 

After completing this lab, you will be able to

- install and configure NFS
- share files and directories between Linux systems using NFS
- use common NFS utilities to query or troubleshoot NFS issues

Estimated time to complete this lab: 40 minutes

## NFS

NFS is an acronym for Network File System. It allows sharing of files and folders over a network with other systems. NFS provides a simple way for making the contents of the local file system available to multiple users (or systems) on a network.

This sharing is traditionally between UNIX/Linux like systems, but systems running Microsoft Windows operating systems can also access NFS shares if they have the proper software installed to do this. 

Support for NFS must be enabled or compiled into the kernel. 

As with most networking concepts, NFS has client and server sides. The server side consists of the system that exports (shares) file systems to other systems. The client side consists of the systems that need access to the file system exported by the server. 

NFSv4 requires the services of the following programs (daemons):

- portmap  - maps RPC programs to regular network ports
- mountd   -  handles incoming mount requests
- nfsd - this is the main NFS program that handles the actual file transfers

## /etc/exports

The `/etc/exports` configuration file serves as an access control list for specifying file systems that may be exported via NFS to authorized clients. It provides information to `mountd` and to the kernel-based NFS file server daemon `nfsd`. 

The directives in `/etc/exports` uses the following syntax:

```bash
shareable_directory  allowed_clients(options_affecting_allowed_clients) 
```

## Exercise 1 

### Managing NFS 

In this exercise you will share (export) a local directory to be shared with your partner system, but first you will learn how to manage the NFS service.

NFS is a Remote Procedure Call (RPC) based client and server application. It is therefore useful to have RPC utilities handy that can be used for querying, debugging, and making RPC calls to RPC servers (like NFS servers). `rpcinfo` is one such useful utility. Its usage syntax and options are shown here:

```bash
SYNOPSIS
     rpcinfo [-m | -s] [host]
     rpcinfo -p [host]
     rpcinfo -T transport host prognum [versnum]
     rpcinfo -l [-T transport] host prognum versnum
     rpcinfo [-n portnum] -u host prognum [versnum]
     rpcinfo [-n portnum] [-t] host prognum [versnum]
     rpcinfo -a serv_address -T transport prognum [versnum]
     rpcinfo -b [-T transport] prognum versnum
     rpcinfo -d [-T transport] prognum versnum
```

#### To start NFS 

1. Ensure you are logged on to your system as a user with Administrative privileges.
   
2. Start by installing the `nfs-utils` package. This package provides various utilities for use with NFS clients and servers. Type:

    ```bash
    dnf -y install nfs-utils
    ```

3. Amongst things, the newly installed nfs-utils package also provides the systemd service unit (`nfs-server.service`) needed for managing the NFS daemon on the system. Use `systemctl` to view some of the ancillary services that the nfs-server unit "Wants". Type:

    ```bash
     systemctl show  -p "Wants"  nfs-server
    ```
    **OUTPUT**
    ```bash
    Wants=nfs-idmapd.service nfsdcld.service rpcbind.socket rpc-statd-notify.service rpc-statd.service auth-rpcgss-module.service network-online.target
    ```
    
    Some important and notable services that nfs-server needs are `nfs-idmapd`,  `nfsdcld`, `rpcbind`, `rpc-statd-notify`, `rpc-statd`,  `auth-rpcgss-module`.

4. The `rpcinfo` command is used for making RPC calls to an RPC server and then reports on its findings. `rpcinfo` lists all the RPC services registered with `rpcbind`. Use `rpcinfo` to query your local server for a list of all registered RPC services. Type:

    ```bash
    rpcinfo -p localhost
    ```

    **OUTPUT**
    ```bash
    program vers proto   port  service
    100000    4   tcp    111  portmapper
    100000    3   tcp    111  portmapper
    100000    2   tcp    111  portmapper
    100000    4   udp    111  portmapper
    ```

    From the sample output above, we can tell a `portmapper` service is registered on the RPC server running localhost.

    !!! Question

        A) What is portmapper? 
        B) Find out the meaning of the different fields (column heading) of the `rpcinfo` command? (Program, Vers, proto, and service.)

5. Check the status of `nfs-server.service`. Type:

    ```bash
    systemctl status nfs-server
    ```
   **OUTPUT**
   ```bash
    ● nfs-server.service - NFS server and services
    Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; disabled; vendor preset: disabled)
    Active: inactive (dead)
    ```
    nfs-server.service is currently not running according to the output on our demo system.

6. Use systemctl to start the nfs-server daemon. Type:

    ```bash
    systemctl start nfs-server
    ```

7. Check the status of the nfs-server service again.
   
8. Run the `rpcinfo` command again to check if anything has changed. 

    !!! Question
    
        What new services do you see listed in the `rpcinfo` output after starting nfs-server?

9. Verify that `nfs-server.service` is set to automatically start every time the system reboots. Type:
    
    ```bash
    systemctl is-enabled nfs-server
    ```

10. If the nfs-server is disabled on your system, run the command to configure it for automatic starts with the system.

11. If the firewall sub-system is running on your server, you'll need to allow/permit NFS traffic through the firewall for remote NFS clients. This can be done by running:
     
    ```bash
    firewall-cmd --permanent --add-service nfs && firewall-cmd --reload
    ```

## Exercise 2

### Exporting Shares 

Creating a share is done by creating a directory or sharing an already existing directory on the local file system.

The `exportfs` utility is used for viewing and maintaining the table of exported NFS file systems. Its usage syntax and options are:

```bash
SYNOPSIS
       /usr/sbin/exportfs [-avi] [-o options,..] [client:/path ..]
       /usr/sbin/exportfs -r [-v]
       /usr/sbin/exportfs [-av] -u [client:/path ..]
       /usr/sbin/exportfs [-v]
       /usr/sbin/exportfs -f
       /usr/sbin/exportfs -s
```

!!! note

    Don't forget to replace all references to server<PR>  with your partners actual hostname. 

#### To create and export a share 

You will create and share a directory called `/mnt/nfs`. This directory will be the source file-system that exported from the NFS server.

1. Ensure you are logged on to your system as a user with administrative privileges.

2. Create a directory under `/mnt` called `nfs` and change to that directory.

    ```bash
    mkdir /mnt/nfs && cd /mnt/nfs
    ```

3. Create 5 sample files under the new directory you created. Type: 
   
    ```bash
     touch {1..5}nfs
    ```

4. Use the HEREDOC shell feature to create a new NFS export entry in `/etc/exports`. The single line entry you want is - `/mnt/nfs  foocentos2(rw)  localhost(rw)`. Type:

    ```bash
    cat << EOF > /etc/exports
    /mnt/nfs    172.16.99.0/24(rw)   localhost(rw)
    EOF
    ```
    You can also use any text editor you are comfortable with to create the entry.

5. Verify the contents of `/etc/exports` to ensure no mistakes.

6. After making any change to the `/etc/exports` file you should run the `exportfs` command. Type:
   
    ```bash
    exportfs -r
    ```

7. Use the `-s` flag with the `exportfs` command to display the current export list suitable for `/etc/exports`. For example, view the list of directories, allowed hosts, and options. Type: 

    ```bash
    exportfs -s
    ```

    List your output below.

## Exercise 3

### Mounting NFS shares  

This exercise deals with the client side of NFS. You'll try accessing the NFS server as a client.

`showmount` is a handy utility for querying and showing mount information on NFS servers. It can also show the state of the NFS server and list the clients that are mounting from the server. Its syntax and options are shown here:

```bash
SYNOPSIS
       showmount [ -adehv ] [ --all ] [ --directories ] [ --exports ] [ --help ] [ --version ] [ host ]

OPTIONS
       -a or --all
              List  both  the  client  hostname or IP address and mounted directory in host:dir format.
       -d or --directories
              List only the directories mounted by some client.
       -e or --exports
              Show the NFS server's export list.
       -h or --help
              Provide a short help summary.
       -v or --version
              Report the current version number of the program.
       --no-headers
              Suppress the descriptive headings from the output.
```

#### To access an NFS share locally 

You will test the NFS server's configuration from *Exercise 1* by trying to access the exported directory from your local machine, before testing it from a remote machine. 

1. While logged in as the superuser, create a directory called `/mnt/nfs-local`. This directory will serve as the test mount point for the NFS share. 

2. As a quick pre-flight check, run `showmount` as a client to show the available export list on the server. Type:

    ```bash
    showmount  -e localhost
    ```
    **OUTPUT**
    ```
    Export list for localhost:
    /mnt/nfs 172.16.99.0/24,localhost
    ```
    
    You should see whatever NFS exports that are configured on the server.

3. You are now ready to mount the NFS share at the test mount point. Type: 

    ```bash
    mount  -t  nfs  localhost:/mnt/nfs   /mnt/nfs-local
    ```

4. Change your PWD to the `/mnt/nfs-local` directory and list its contents.
   
5. While still in the `/mnt/nfs-local` directory, attempt to delete some files. Type: 

    ```bash
    rm -rf 1nfs  2nfs
    ```
    **OUTPUT**
    ```bash
    rm: cannot remove '1nfs': Permission denied
    rm: cannot remove '2nfs': Permission denied
    ```
    
    !!! Question

        Was your file deletion attempt successful?

7. Now try creating additional files (6nfs, 7nfs, 8nfs) on the NFS share. Type:

    ```bash
    touch {6..8}nfs
    ```

    !!! Question
        
        Was your file creation attempt successful? Why do you think this failed? 


PERFORM THIS EXERCISE FROM YOUR PARTNER-SYSTEM 

#### To access an NFS share remotely 

1. While logged into serverPR as the superuser, install the `nfs-utils` package if it isn't installed. 

2. Create a directory called  “`/mnt/nfs-remote`” that will serve as the mount point for the remote NFS share. Type:

    ```bash
    mkdir   /mnt/nfs-remote
    ```

3. Assuming the IP address for the remote serverXY is 172.16.99.100, mount the NFS share on serverXY by running:

    ```bash
    mount -t nfs  172.16.99.100:/mnt/nfs  /mnt/nfs-remote
    ```

4. Use the `mount` command to display some extra information about the NFS share that you just mounted. Type:
   
    ```bash
     mount -t nfs4
    ```
    **OUTPUT**
    ```bash
    172.16.99.100:/mnt/nfs on /mnt/nfs-remote type nfs4 (rw,relatime,vers=4.2,rsize=1048576,wsize=1048576,namlen=255
    ...<SNIP>...
    ```

5. `cd` to the NFS mount point and try to delete its contents. Type:

    ```bash
    cd /mnt/nfs-remote ; rm -f   
    ```
    
    Was your attempt successful? 

6. Logout of serverPR as the superuser and log back in as the unprivileged user “ying” 
   
7. While logged into serverPR as “ying” cd to the directory mounted in step 2. Type:

    ```bash
    cd /mnt/nfs-remote/
    ```

8. Make a note of the contents of the directory. If can see the expected files, you have successfully completed the NFS lab!

    !!! question "Questions"

        1. Configure the NFS setup on your local server (serverXY), such that the superuser at the H.Q. (hq.example.org) will be able to mount your nfs share (/mnt/nfsXY) for use on the hq machine.

        2. The superuser at HQ should be able to write (create) new files and delete the files on your NFS share. 

    !!! Tip
    
        You need to disable NFS’s special treatment of root-owned files. This is done by specifying a special option that will “un-squash” the   superuser in the “/etc/exports” file. The special option is called `no_root_squash`. Please note that it is considered bad practise and a security risk to use the `no_root_squash` option. A sample entry to accomplish this for any host that matches `localhost` in `/etc/exports` will look like:
 
        ```bash
        /mnt/nfs    172.16.99.0/24(rw)   localhost(rw,no_root_squash)
        ```

