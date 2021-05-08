# What's Asterisk
Asterisk is an open source framework for building communications applications. Asterisk turns an ordinary computer into a communications server. Asterisk powers IP PBX systems, VoIP gateways, conference servers and other custom solutions. It is used by small businesses, large businesses, call centers, carriers and government agencies, worldwide. Asterisk is free and open source. Asterisk is sponsored by Sangoma

# Pre-requist
## Update RockyLinux

    sudo yum -y update

## Set Hostname
    sudo hostnamectl set-hostname asterisk.example.com

## Configure Selinux
    sudo setenforce 0
    sudo sed -i 's/\(^SELINUX=\).*/\SELINUX=permissive/' /etc/selinux/config

## Add EBEL Repository
    sudo yum -y install epel-release
    sudo yum config-manager --set-enabled powertools
## Reboot System
    sudo systemctl reboot

## Install Development Tools
    sudo yum group -y install "Development Tools"
    sudo yum -y install git wget vim  net-tools sqlite-devel psmisc ncurses-devel libtermcap-devel newt-devel libxml2-devel libtiff-devel gtk2-devel libtool libuuid-devel subversion kernel-devel kernel-devel-$(uname -r) crontabs cronie-anacron libedit libedit-devel

# Aterisk Required Tools 
## Install Jansson
    git clone https://github.com/akheron/jansson.git
    cd jansson
    autoreconf -i
    ./configure --prefix=/usr/
    make
    sudo make install
## Install PJSIP
    cd ~
    git clone https://github.com/pjsip/pjproject.git
    cd pjproject
    ./configure CFLAGS="-DNDEBUG -DPJ_HAS_IPV6=1" --prefix=/usr --libdir=/usr/lib64 --enable-shared --disable-video --disable-sound --disable-opencore-amr
    make dep
    make
    sudo make install
    sudo ldconfig


# Install Asterisk
## Compile Asterisk
    cd ~
    wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-18-current.tar.gz
    tar xvfz asterisk-18-current.tar.gz
    cd asterisk-18*/
    ./configure --libdir=/usr/lib64

## Set Asterisk menu options
    make menuselect :: need photos 
## Build and Install Asterisk
    contrib/scripts/get_mp3_source.sh
    make
    sudo make install
    sudo make samples
    sudo make config
    sudo ldconfig

## Configuration
### Create User & Group
    sudo groupadd asterisk
    sudo useradd -r -d /var/lib/asterisk -g asterisk asterisk
    sudo usermod -aG audio,dialout asterisk
    sudo chown -R asterisk.asterisk /etc/asterisk /var/{lib,log,spool}/asterisk /usr/lib64/asterisk
### Set Default User & Group
    sudo vi /etc/sysconfig/asterisk
Add below lines

    AST_USER="asterisk"
    AST_GROUP="asterisk"

    sudo vim /etc/asterisk/asterisk.conf

Add below lines

    runuser = asterisk ; The user to run as.
    rungroup = asterisk ; The group to run as.

### Configure Asterisk Service
    sudo systemctl restart asterisk
    sudo systemctl enable asterisk

## Test
    sudo asterisk -rvv
