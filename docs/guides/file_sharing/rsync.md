# rsync

## Introduction


Rsync (Remote Sync) is the most commonly used command for remotely and locally copying and synchronizing files and directories. It is well-known for its ability to copy only the differences in files rather than the entire file when it has been modified, reducing the required bandwidth significantly.


## Prerequisites and Assumptions
* we assume that you are either the root user or have used `sudo` to become so
* access to two or more different folders across same machine or network 
* familiarity with File and fodler permissions 


## rsync basics 
The syntax of rsync command is 
```
rsync <flags> <source_user_name@source> <destination_user_name@destination>
```

Various optional Flags
```
-n : Dry-Run to see what files wouold be transferred 
-r : to enable recursion, to transfer all sub folders
-v : list out all the files which are being transferred 
-vvv : to provide debug info while transferring files 
-o : to replicate the owenserhip of the files transfered
-z : to enable compression during the transfer 
```





