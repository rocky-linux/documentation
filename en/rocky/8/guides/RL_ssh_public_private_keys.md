# Rocky Linux - SSH Public and Private Key

# Introduction

When you are working with multiple Rocky Linux servers in multiple locations, or if you are just trying to save some time accessing these servers, A good way to use an SSH public and private key pair. This document will guide you through the process of creating the keys and setting up your servers for access with the keys.

## Prerequisites

* A certain amount of comfort operating from the command line
* Rocky Linux servers and workstation with openssh installed

### Process For Generating Keys

The following commands are all executed from the command line on your Rocky Linux workstation:


`ssh-keygen -t rsa`

Which will display the following:

```
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
```

Hit Enter to accept the default location. Next the system will show:

`Enter passphrase (empty for no passphrase):`

So just hit Enter here. Finally, it will ask for you to re-enter the passphrase:

`Enter same passphrase again:`

So hit Enter a final time.

You now should have an RSA type public and private key pair in your .ssh directory:
see
```
ls -a .ssh/
.  ..  id_rsa  id_rsa.pub
```

Now we need to send the public key (id_rsa.pub) to every machine that we are going to be accessing, but before we do, we need to make sure that we can SSH into the servers that we will be sending the key to. For our example, we are going to be using just three servers. You can either ssh by DNS name or IP address, but for our example we are going to be using the DNS name. Our example servers are web, mail, and portal. For each server, we will attempt to SSH in and leave the terminal window opened on each machine:

`ssh -l root web.ourourdomain.com` 

Assuming that we can login OK for all three machines, then the next step is to send our public key over to each server:

`scp .ssh/id_rsa.pub root@web.ourourdomain.com:/root/` 

repeating this step with each of our three machines. 

On each of the open terminal windows on the three servers, you should now be able to see an id_rsa.pub when you enter the following command:

`ls -a | grep id_rsa.pub` 

If so, we are now ready to either create or append the authorized_keys file in each server's .ssh directory. On each of the servers, enter this command:

`ls -a .ssh` 

** Important! Make sure you read the below carefully. If you are not sure if you will break something, then make a backup copy of authorized_keys (if it exists) on each of the machines before continuing. **

If there is no authorized_keys file listed then we will create it by entering this from our /root directory:

`cat id_rsa.pub > .ssh/authorized_keys`

If authorized_keys does exist, then we simply want to append our new public key to the ones that are already there:

`cat id_rsa.pub >> .ssh/authorized_keys`

Once the key has been either added to authorized_keys, or the authorized_keys file has been created, try to SSH from your Rocky Linux workstation to the server again. You should not be prompted for a password. 

Once you have verified that you can SSH in without a password, remove the id_rsa.pub file from the /root directory on each machine. 

`rm id_rsa.pub`

### SSH Directory and authorized_keys Security

On each of your target machines, make sure that the following permissions are applied:

`chmod 700 .ssh/`
`chmod 600 .ssh/authorized_keys`



