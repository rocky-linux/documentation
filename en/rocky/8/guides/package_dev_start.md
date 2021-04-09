## Rocky Package Development - Getting Started

Let's walk through building the curl package as a learning example. For this you'll need:

* An existing modern RPM based Linux system
* The Rocky build utility: srpmproc
* A few basic devel packages
* Mock templates for Building Rocky Linux packages


## 1 - Install needed devel packages

```
$ sudo dnf -y install epel-release
$ sudo dnf -y groupinstall "Development Tools"
$ sudo dnf -y install golang mock git
```
This may be a little different for non RHEL/CentOS/Fedora distros.

## 2 - Download and Setup the Rocky build tool: srpmproc
 
```
$ mkdir -p $HOME/src/rocky && cd $HOME/src/rocky
$ git clone https://git.rockylinux.org/release-engineering/public/srpmproc.git
$ cd srpmproc
$ CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build ./cmd/srpmproc
$ sudo cp srpmproc /usr/local/bin/
$ mkdir -p /tmp/srpmproc/
```
 
## 3 - Setup mock and mock templates (mock configs)

```
$ sudo usermod -a -G mock $USER
$ sudo curl -o /etc/mock/templates/rockybuild8.tpl https://rocky.lowend.ninja/RockyDevel/mock_configs/build_pass11/rockybuild8.tpl
$ sudo curl -o /etc/mock/templates/rockycentos-8.tpl https://rocky.lowend.ninja/RockyDevel/mock_configs/build_pass11/rockycentos-8.tpl
$ sudo curl -o /etc/mock/rocky8.cfg https://rocky.lowend.ninja/RockyDevel/mock_configs/build_pass11/rocky8.cfg
```


### Tip (optional)
The srpmproc, rpmbuild and mock programs requires a lot of  options and this results in very long command lines. To help reduce the amount of typing, you may abstract these into simpler bash functions.

For this, you may append the following helper functions to your ~/.bashrc file.

```
rockyget(){ srpmproc --version 8 --source-rpm $1 --upstream-prefix https://git.rockylinux.org/staging --storage-addr file:///tmp/srpmproc --tmpfs-mode $@; }
rockybuild() { rpmbuild -bs --nodeps --define "%_topdir `pwd`" --define "dist .el8" SPECS/*.spec && mock -r /etc/mock/rocky8.cfg SRPMS/*.src.rpm; }
rockybuild-notest() { rpmbuild -bs --nodeps --define "%_topdir `pwd`" --define "dist .el8" SPECS/*.spec &&  mock --nocheck -r /etc/mock/rocky8.cfg SRPMS/*.src.rpm; }
```

Once you're done, pull them into your environment:

```
$ source  ~/.bashrc
```

## 4a - Finally, let's build the curl package as an example

```
$ mkdir -p $HOME/src/rocky && cd $HOME/src/rocky
$ rockyget curl
$ cd curl/r8
$ rockybuild
```

* This build may take 30 minutes or longer because of the many self-tests that are peformed on the package.  
* Note: It is normal to see a number of errors such as `could not get commit object for ref refs/tags/imports/c7-beta/curl-7.29.0-56.el7: object not found` --this is normal and may be safely ignored.

## 4b - Alternative - build curl quickly by skipping the self-tests

```
$ mkdir -p $HOME/src/rocky && cd $HOME/src/rocky
$ rockyget curl
$ cd curl/r8
$ rockybuild-notest
```

* This will speed up the build/test/fix/build cycle. Once the package is building cleanly, it is best practice to build again with tests to verify accuracy.

## 5 -  References

After completing the above example build, you are ready to begin contributing!  
Here are some references to help you take the next steps:

1. More detail about building and contributing:
    - <https://wiki.rockylinux.org/en/team/development/Packaging_How_to_Help>  
2. How to connect with other developers for help:
    - <https://chat.rockylinux.org/rocky-linux/channels/dev-packaging>
    - <https://wiki.rockylinux.org/en/team/community>  

General:  
1. Rocky Forums: <https://forums.rockylinux.org/>  ## offline Q&A message board  
2. Rocky Chat:   <https://chat.rockylinux.org/>    ## live chat with developers  
3. Rocky Wiki:   <https://wiki.rockylinux.org/>    ## helpful articles  
4. Rocky Code:   <https://git.rockylinux.org/>     ## source code repository

