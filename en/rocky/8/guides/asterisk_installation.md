# What's Asterisk
Asterisk is an open source framework for building communications applications. Asterisk turns an ordinary computer into a communications server. Asterisk powers IP PBX systems, VoIP gateways, conference servers and other custom solutions. It is used by small businesses, large businesses, call centers, carriers and government agencies, worldwide. Asterisk is free and open source. Asterisk is sponsored by Sangoma

# Prerequisite
## Update RockyLinux

    sudo dnf -y update

## Set Hostname
    sudo hostnamectl set-hostname asterisk.example.com

## Add EPEL Repository
    sudo dnf -y install epel-release
    sudo dnf config-manager --set-enabled powertools
    
## Install Development Tools
    sudo dnf group -y install "Development Tools"
    sudo dnf -y install git wget  


# Install Asterisk
## Compile Asterisk
    cd ~
    wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-18-current.tar.gz
    tar xvfz asterisk-18-current.tar.gz
    cd asterisk-18*/
    contrib/scripts/install_prereq install
    ./configure --libdir=/usr/lib64 --with-jansson-bundled=yes

## Set Asterisk menu options [For more options]
    make menuselect 

## Build and Install Asterisk
    make
    make install
    make basic-pbx 
    make config
    

## Configuration
### Create User & Group
    sudo groupadd asterisk
    sudo useradd -r -d /var/lib/asterisk -g asterisk asterisk
    sudo chown -R asterisk.asterisk /etc/asterisk /var/{lib,log,spool}/asterisk /usr/lib64/asterisk
    sudo restorecon -vr {/etc/asterisk,/var/lib/asterisk,/var/log/asterisk,/var/spool/asterisk}

### Set Default User & Group
    sudo vi /etc/sysconfig/asterisk
Un-comment below two lines and save

    AST_USER="asterisk"
    AST_GROUP="asterisk"

    sudo vi /etc/asterisk/asterisk.conf
Un-comment below two lines and save

    runuser = asterisk ; The user to run as.
    rungroup = asterisk ; The group to run as.

### Configure Asterisk Service
    sudo systemctl enable asterisk

### Configure Firewall
    firewall-cmd --zone=public --add-port=5060/udp --permanent
    firewall-cmd --zone=public --add-port=5060/tcp --permanent
    firewall-cmd --zone=public --add-port=5000-31000/udp --permanent

    reboot

## Test

    sudo asterisk -rvvvv

### Show Sample End-Point Authentications
    pjsip show auth 1101
    
Now you can use any sip client to connect using username and password.  