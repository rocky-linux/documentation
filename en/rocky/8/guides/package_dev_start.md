Let's walk through building the curl package for Rocky Linux. For this you'll need:

* An existing modern RPM based Linux system
* The srpmproc utility
* Some packages from the Extra Packages for Enterprise Linux (EPEL) repository
* Mock templates for Building Rocky Linux packages


## 1 - Enable the EPEL repository and install needed packages/tools

```
sudo dnf -y install epel-release
sudo dnf -y groupinstall "Development Tools"
sudo dnf -y install golang mock git
```

## 2 - Download and Setup srpmproc
 
 ```
git clone https://git.rockylinux.org/release-engineering/public/srpmproc.git
cd srpmproc
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build ./cmd/srpmproc
sudo cp srpmproc /usr/local/bin/
mkdir -p /tmp/srpmproc/
```
 
## 3 -  Setup mock and Download the latest Mock Build Templates (mock configs)

```
  sudo usermod -a -G mock $USER
  sudo curl -o /etc/mock/templates/rockybuild8.tpl https://rocky.lowend.ninja/RockyDevel/mock_configs/build_pass11/rockybuild8.tpl
  sudo curl -o /etc/mock/templates/rockycentos-8.tpl https://rocky.lowend.ninja/RockyDevel/mock_configs/build_pass11/rockycentos-8.tpl
  sudo curl -o /etc/mock/rocky8.cfg https://rocky.lowend.ninja/RockyDevel/mock_configs/build_pass11/rocky8.cfg
```


## Tip (optional)
The srpmproc, rpmbuild and mock programs accepts a lot of different options. To help reduce the amount of typing that you have to do, you can abstract these options into simpler bash functions.

For this, you can append the following helper functions to your .bashrc file.

```
rockyget(){ srpmproc --version 8 --source-rpm $1 --upstream-prefix https://git.rockylinux.org/staging --storage-addr file:///tmp/srpmproc --tmpfs-mode $@; }
rockybuild() { rpmbuild -bs --nodeps --define "%_topdir `pwd`" --define "dist .el8" SPECS/*.spec && mock -r /etc/mock/rocky8.cfg SRPMS/*.src.rpm; }
 ```
 Once you're done, type:

```
  source  ~/.bashrc
```

## 4 - Finally, let's build a sample curl package  (using the helper functions)

```
    mkdir $HOME/rocky
    cd $HOME/rocky
    rockyget curl
    cd curl/r8
    rockybuild
```
*Note: it is normal to see a number of errors such as `could not get commit object for ref refs/tags/imports/c7-beta/curl-7.29.0-56.el7: object not found`--this is normal and may be safely ignored.
