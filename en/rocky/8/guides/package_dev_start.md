## Rocky Package Development - Getting Started

Audience: You have at least some rpm development experience. 

You will need:

* An existing modern RPM based Linux system
* The Rocky build utility: srpmproc
* A few basic devel packages
* Mock templates to build Rocky Linux packages

Now, let's perform an example build of the curl pacakge.

## 1 - Install needed devel packages

* We will use the *sudo* command. It will ask for your password. This is normal and expected.
* This will install the development package on your system, that you will later use to build Rocky RPMs.
* Cut-n-paste this block to your terminal


```
sudo dnf -y install epel-release
sudo dnf --setopt=group_package_types=optional groupinstall "Development Tools"
sudo dnf -y install golang mock git nginx
```

The above may vary a bit for non RHEL/CentOS/Fedora distros.

## 2 - Download and Setup the Rocky build tool: srpmproc

* This will build and install the tool, key, and files needed to build.
* Cut-n-paste this block to your terminal
 
```
mkdir -p $HOME/src/rocky && cd $HOME/src/rocky
git clone https://git.rockylinux.org/release-engineering/public/srpmproc.git
cd srpmproc
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build ./cmd/srpmproc
sudo cp srpmproc /usr/local/bin/
mkdir -p /tmp/srpmproc-cache/
test -f $HOME/.ssh/id_rsa || ssh-keygen -q -t rsa -f $HOME/.ssh/id_rsa -N ""
mkdir /tmp/repo 2>/dev/null
```
 
## 3 - Setup mock and mock templates (mock configs)

* Mock is a tool that builds packages in the isolation of a *chroot* to ensure consistency.
* Cut-n-paste this block to your terminal

```
sudo usermod -a -G mock $USER
sudo curl -o /etc/mock/templates/rockybuild8.tpl https://rocky.lowend.ninja/RockyDevel/mock_configs/build_pass11/rockybuild8.tpl
sudo curl -o /etc/mock/templates/rockycentos-8.tpl https://rocky.lowend.ninja/RockyDevel/mock_configs/build_pass11/rockycentos-8.tpl
sudo curl -o /etc/mock/rocky8.cfg https://rocky.lowend.ninja/RockyDevel/mock_configs/build_pass11/rocky8.cfg
```

## 4 - Setup shortcuts for build commands

* The srpmproc, rpmbuild and mock build tools require a lot of  options, resulting in very long command lines. To make this practical for daily use, we abstract it into bash functions.
* Cut-n-paste this block to your terminal

```
cat << EOF >> ~/.bashrc

rockyget(){
    mkdir /tmp/srpmproc-cache 2>/dev/null
    srpmproc --version 8 --source-rpm "\$1" --upstream-prefix https://git.rockylinux.org/staging --storage-addr file:///tmp/srpmproc-cache --tmpfs-mode "\$1"
}

rockybuild() {
    createrepo /usr/share/nginx/html/repo
    rpmbuild -bs --nodeps --define "%_topdir \`pwd\`" --define "dist .el8" SPECS/*.spec && mock -r /etc/mock/rocky8.cfg --resultdir=/usr/share/nginx/html/repo SRPMS/*.src.rpm && createrepo /usr/share/nginx/html/repo
}

rockybuild-notest() {
    createrepo /usr/share/nginx/html/repo
    rpmbuild -bs --nodeps --define "%_topdir \`pwd\`" --define "dist .el8" SPECS/*.spec && mock --nocheck -r /etc/mock/rocky8.cfg --resultdir=/usr/share/nginx/html/repo SRPMS/*.src.rpm && createrepo /usr/share/nginx/html/repo
}

EOF
```

* Then pull them into your environment

```
source  ~/.bashrc
```

* Note, the above is design to be pasted to your terminal.
* If you paste directly into your .bashrc file, it will not work as expected due to the *backslash* (\\)

## 5 - Development build of the curl package, as an example

```
## fetch the packge, this is done once:
$ mkdir -p $HOME/src/rocky && cd $HOME/src/rocky
$ rockyget curl
$ cd curl/r8
## build the package, this may be repeated if needed:
$ rockybuild-notest
```

* This example is expected to complete successfully. 
* In daily practice, the build may fail with errors. In that case you would begin the *"fix, build, test, repeat"* devel cycle, until it builds without errors.
* Note: It is normal to see a number of errors such as `could not get commit object for ref refs/tags/imports/c7-beta/curl-7.29.0-56.el7: object not found` --this is normal and may be safely ignored.

## 6 - Final build of curl, as an example

* Once your package builds clean, it is time for one final build that includes all self-tests. 
* If this succeeds, you are ready to submit your fixes.
* Note it may take 30 minutes or longer to build because of the many self-tests that are peformed.

```
$ rockybuild
```

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

