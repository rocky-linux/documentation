---
title: Creazione Automatica di Template - Packer - Ansible - VMware vSphere
author: Antoine Le Morvan
contributors: Steven Spencer, Ryan Johnson, Franco Colussi
update: Feb-15-2022
---

# Creazione automatica di template con Packer e distribuzione con Ansible in un ambiente VMware vSphere

**Conoscenza**: :star: :star: :star   
**Complessità**: :star: :star: :star: :star:

**Tempo di lettura**: 30 minuti

## Prerequisiti, presupposti e note generali

* Un ambiente vSphere disponibile e un utente con accesso garantito
* Un server web interno per memorizzare i file
* Accesso web ai repository di Rocky Linux
* Un ambiente Ansible disponibile
* Si presume che tu abbia qualche conoscenza su ogni prodotto menzionato. In caso contrario, scava in quella documentazione prima di iniziare.
* Vagrant **non** è in uso qui. È stato fatto notare che con Vagrant sarebbe stata fornita una chiave SSH non autofirmata. Se volete approfondire questo aspetto potete farlo, ma non è trattato in questo documento.

## Introduzione

Questo documento copre la creazione di modelli di macchine virtuali vSphere con Packer e come distribuire l'artefatto come nuove macchine virtuali con Ansible.

## Possibili aggiustamenti

Naturalmente, potete adattare questo how-to per altri hypervisor.

Puoi anche scegliere di non convertire la macchina virtuale in un modello, in questo caso userai Packer per distribuire ogni nuova VM, il che è ancora abbastanza fattibile (un'installazione partendo da 0 richiede meno di 10 minuti senza interazione umana).

## Packer

Packer è uno strumento di Hashicorp per automatizzare la creazione di una macchina virtuale.

Potete dare un'occhiata a queste risorse per ulteriori informazioni:

* Il [sito web di Packer](https://www.packer.io/)
* [Documentazione Packer](https://www.packer.io/docs)
* La [documentazione](https://www.packer.io/docs/builders/vsphere/vsphere-iso) del costruttore `vsphere-iso`

Puoi iniziare scaricando i binari per la tua piattaforma con i [download di Packer](https://www.packer.io/downloads).

Avrete anche bisogno di una copia iso di Rocky Linux. Anche se qui sto usando l'immagine ISO minima, potresti scegliere di usare l'immagine DVD (molto più grande e forse troppo grande) o l'immagine di avvio (molto più piccola e forse troppo piccola). Questa scelta dipende da voi. Influisce in particolare sulla larghezza di banda di cui avrete bisogno per l'installazione, e quindi sul tempo di fornitura. Discuteremo in seguito l'impatto della scelta di default e come porvi rimedio.

Si presume che siate su Linux per eseguire i seguenti compiti.

Poiché ci connetteremo a un VMware vCenter Server per inviare i nostri comandi tramite Packer, abbiamo bisogno di memorizzare le nostre credenziali al di fuori dei file di configurazione che creeremo successivamente.

Creiamo un file nascosto con le nostre credenziali nella nostra home directory. Questo è un file json:

```
$ vim .vsphere-secrets.json {
    "vcenter_username": "rockstar",
    "vcenter_password": "mysecurepassword"
  }
```

Queste credenziali hanno bisogno di qualche assegnazione di accesso al vostro ambiente vSphere.

Creiamo un file json (in futuro, il formato di questo file cambierà in quello dell'HCL):

```
{
  "variables": {
    "version": "0.0.X",
    "HTTP_IP": "fileserver.rockylinux.lan",
    "HTTP_PATH": "/packer/rockylinux/8/ks.cfg"
  },
  "sensitive-variables": ["vcenter_password"],
  "provisioners": [
    {
      "type": "shell",
      "expect_disconnect": true,
      "execute_command": "bash '{{.Path}}'",
      "script": "{{template_dir}}/scripts/requirements.sh"
    }
  ],
  "builders": [
    {
      "type": "vsphere-iso",
      "CPUs": 2,
      "CPU_hot_plug": true,
      "RAM": 2048,
      "RAM_hot_plug": true,
      "disk_controller_type": "pvscsi",
      "guest_os_type": "centos8_64Guest",
      "iso_paths": [
        "[datasyno-contentlibrary-mylib] contentlib-a86ad29a-a43b-4717-97e6-593b8358801b/3a381c78-b9df-45a6-82e1-3c07c8187dbe/Rocky-8.4-x86_64-minimal_72cc0cc6-9d0f-4c68-9bcd-06385a506a5d.iso"
      ],
      "network_adapters": [
        {
          "network_card": "vmxnet3",
          "network": "net_infra"
        }
      ],
      "storage": [
        {
          "disk_size": 40000,
          "disk_thin_provisioned": true
        }
      ],
      "boot_command": [
      "<up><tab> text ip=192.168.1.11::192.168.1.254:255.255.255.0:template:ens192:none nameserver=192.168.1.254 inst.ks=http://{{ user `HTTP_IP` }}/{{ user `HTTP_PATH` }}<enter><wait><enter>"
      ],
      "ssh_password": "mysecurepassword",
      "ssh_username": "root",
      "shutdown_command": "/sbin/halt -h -p",
      "insecure_connection": "true",
      "username": "{{ user `vcenter_username` }}",
      "password": "{{ user `vcenter_password` }}",
      "vcenter_server": "vsphere.rockylinux.lan",
      "datacenter": "DC_NAME",
      "datastore": "DS_NAME",
      "vm_name": "template-rockylinux8-{{ user `version` }}",
      "folder": "Templates/RockyLinux",
      "cluster": "CLUSTER_NAME",
      "host": "esx1.rockylinux.lan",
      "notes": "Template RockyLinux version {{ user `version` }}",
      "convert_to_template": true,
      "create_snapshot": false
    }
  ]
}
```
In seguito, descriveremo ogni sezione di questo file.

### Sezione variabili

In un primo passo, dichiariamo le variabili, principalmente per motivi di leggibilità:

```
"variables": {
  "version": "0.0.X",
  "HTTP_IP": "fileserver.rockylinux.lan",
  "HTTP_PATH": "/packer/rockylinux/8/ks.cfg"
},
```

Useremo la variabile `version` più tardi nel nome del modello che creeremo. Puoi facilmente incrementare questo valore in base alle tue esigenze.

Avremo anche bisogno che la nostra macchina virtuale di avvio acceda a un file ks.cfg (Kickstart).

Un file Kickstart contiene le risposte alle domande poste durante il processo di installazione. Questo file passa tutto il suo contenuto ad Anaconda (il processo di installazione), il che permette di automatizzare completamente la creazione del modello.

All'autore piace memorizzare il suo file ks.cfg in un server web interno accessibile dal suo modello, ma esistono altre possibilità che potresti invece scegliere di usare.

Per esempio, il file ks.cfg è accessibile dalla VM a questo url nel nostro laboratorio: http://fileserver.rockylinux.lan/packer/rockylinux/8/ks.cfg. Avrete bisogno di impostare qualcosa di simile per usare questo metodo.

Dato che vogliamo mantenere la nostra password privata, è dichiarata come una variabile sensibile. Esempio:

```
  "sensitive-variables": ["vcenter_password"],
```

### Sezione Provisioners

La prossima parte è interessante, e sarà coperta più tardi fornendovi lo script per `requirements.sh`:

```
"provisioners": [
  {
    "type": "shell",
    "expect_disconnect": true,
    "execute_command": "bash '{{.Path}}'",
    "script": "{{template_dir}}/scripts/requirements.sh"
  }
],
```

Al termine dell'installazione, la VM si riavvierà. Non appena Packer rileva un indirizzo IP (grazie ai VMware Tools), copierà il `requirements.sh` e lo eseguirà. È una bella funzione per pulire la VM dopo il processo di installazione (rimuovere le chiavi SSH, pulire la cronologia, ecc.) e installare qualche pacchetto extra.

### La sezione dei builders

Potete dichiarare uno o più builders per puntare a qualcosa di diverso dal vostro ambiente vSphere (forse un template Vagrant).

Ma qui stiamo usando il builder `vsphere-iso`:


```
"builders": [
  {
    "type": "vsphere-iso",
```

Questo builder ci permette di configurare l'hardware di cui abbiamo bisogno:

```
  "CPUs": 2,
  "CPU_hot_plug": true,
  "RAM": 2048,
  "RAM_hot_plug": true,
  "disk_controller_type": "pvscsi",
  "guest_os_type": "centos8_64Guest",
  "network_adapters": [
    {
      "network_card": "vmxnet3",
      "network": "net_infra"
    }
  ],
  "storage": [
    {
      "disk_size": 40000,
      "disk_thin_provisioned": true
    }
  ],
```

!!! Note "Nota"

    Non dimenticherete mai più di includere CPU_hot_plug perché ora è automatico!

Si possono fare cose più belle con il disco, la cpu, ecc. Si dovrebbe fare riferimento alla documentazione se si è interessati a fare altre regolazioni.

Per iniziare l'installazione, avete bisogno di un'immagine ISO di Rocky Linux. Ecco un esempio di come utilizzare un'immagine situata in una libreria di contenuti vSphere. Naturalmente è possibile memorizzare la ISO altrove, ma nel caso di una libreria di contenuti vSphere, è necessario ottenere il percorso completo del file ISO sul server che ospita la libreria di contenuti (in questo caso è un Synology, quindi direttamente sul DSM explorer).

```
  "iso_paths": [
    "[datasyno-contentlibrary-mylib] contentlib-a86ad29a-a43b-4717-97e6-593b8358801b/3a381c78-b9df-45a6-82e1-3c07c8187dbe/Rocky-8.4-x86_64-minimal_72cc0cc6-9d0f-4c68-9bcd-06385a506a5d.iso"
  ],
```

Poi devi fornire il comando completo da inserire durante il processo di installazione: configurazione dell'IP e trasmissione del percorso del file di risposta Kickstart.

!!! Note "Nota"

    Questo esempio prende il caso più complesso: usare un IP statico. Se avete un server DHCP disponibile, il processo sarà molto più facile.

Questa è la parte più divertente della procedura: Sono sicuro che andrete ad ammirare la console VMware durante la generazione, solo per vedere l'inserimento automatico dei comandi durante l'avvio.

```
"boot_command": [
"<up><tab> text ip=192.168.1.11::192.168.1.254:255.255.255.0:template:ens192:none nameserver=192.168.1.254 inst.ks=http://{{ user `HTTP_IP` }}/{{ user `HTTP_PATH` }}<enter><wait><enter>"
],
```

Dopo il primo riavvio, Packer si connetterà al tuo server tramite SSH. Puoi usare l'utente root o un altro utente con diritti sudo, ma in ogni caso, questo utente deve corrispondere all'utente definito nel tuo file ks.cfg.

```
"ssh_password": "mysecurepassword",
"ssh_username": "root",
```

Alla fine del processo, la VM deve essere fermata. È un po' più complicato con un utente non root, ma è ben documentato:

```
"shutdown_command": "/sbin/halt -h -p",
```

Successivamente, ci occupiamo della configurazione di vSphere. Le uniche cose degne di nota qui sono l'uso delle variabili definite all'inizio del documento nella nostra home directory, così come l'opzione `insecure_connection`, perché il nostro vSphere usa un certificato autofirmato (vedi nota in Presupposti all'inizio di questo documento):

```
"insecure_connection": "true",
"username": "{{ user `vcenter_username` }}",
"password": "{{ user `vcenter_password` }}",
"vcenter_server": "vsphere.rockylinux.lan",
"datacenter": "DC_NAME",
"datastore": "DS_NAME",
"vm_name": "template-rockylinux8-{{ user `version` }}",
"folder": "Templates/RockyLinux",
"cluster": "CLUSTER_NAME",
"host": "esx1.rockylinux.lan",
"notes": "Template RockyLinux version {{ user `version` }}"
```

E infine, chiederemo a vSphere di convertire la nostra VM arrestata in un template.

A questo punto, si potrebbe anche scegliere di utilizzare la VM così com'è (senza convertirla in un modello). In questo caso, si può decidere di fare un'istantanea:

```
"convert_to_template": true,
"create_snapshot": false,
```

## Il file ks.cfg

Come notato sopra, abbiamo bisogno di fornire un file di risposta Kicstart che sarà utilizzato da Anaconda.

Ecco un esempio di quel file:

```
# Use CDROM installation media
repo --name="AppStream" --baseurl="http://download.rockylinux.org/pub/rocky/8.4/AppStream/x86_64/os/"
cdrom
# Use text install
text
# Don't run the Setup Agent on first boot
firstboot --disabled
eula --agreed
ignoredisk --only-use=sda
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network --bootproto=static --device=ens192 --gateway=192.168.1.254 --ip=192.168.1.11 --nameserver=192.168.1.254,4.4.4.4 --netmask=255.255.255.0 --onboot=on --ipv6=auto --activate

# Root password
rootpw mysecurepassword

# System services
selinux --permissive
firewall --enabled
services --enabled="NetworkManager,sshd,chronyd"
# System timezone
timezone Europe/Paris --isUtc
# System booloader configuration
bootloader --location=mbr --boot-drive=sda
# Partition clearing information
clearpart --all --initlabel --drives=sda
# Disk partitionning information
part /boot --fstype="xfs" --ondisk=sda --size=512
part pv.01 --fstype="lvmpv" --ondisk=sda --grow
volgroup vg_root --pesize=4096 pv.01
logvol /home --fstype="xfs" --size=5120 --name=lv_home --vgname=vg_root
logvol /var --fstype="xfs" --size=10240 --name=lv_var --vgname=vg_root
logvol / --fstype="xfs" --size=10240 --name=lv_root --vgname=vg_root
logvol swap --fstype="swap" --size=4092 --name=lv_swap --vgname=vg_root

skipx

reboot

%packages --ignoremissing --excludedocs
openssh-clients
curl
dnf-utils
drpm
net-tools
open-vm-tools
perl
perl-File-Temp
sudo
vim
wget
python3

# unnecessary firmware
-aic94xx-firmware
-atmel-firmware
-b43-openfwwf
-bfa-firmware
-ipw2100-firmware
-ipw2200-firmware
-ivtv-firmware
-iwl*-firmware
-libertas-usb8388-firmware
-ql*-firmware
-rt61pci-firmware
-rt73usb-firmware
-xorg-x11-drv-ati-firmware
-zd1211-firmware
-cockpit
-quota
-alsa-*
-fprintd-pam
-intltool
-microcode_ctl
%end

%addon com_redhat_kdump --disable
%end

%post

# Manage Ansible access
groupadd -g 1001 ansible
useradd -m -g 1001 -u 1001 ansible
mkdir /home/ansible/.ssh
echo -e "<---- PAST YOUR PUBKEY HERE ---->" >  /home/ansible/.ssh/authorized_keys
chown -R ansible:ansible /home/ansible/.ssh
chmod 700 /home/ansible/.ssh
chmod 600 /home/ansible/.ssh/authorized_keys
echo "ansible ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible
chmod 440 /etc/sudoers.d/ansible

systemctl enable vmtoolsd
systemctl start vmtoolsd

%end
```

Poiché abbiamo scelto di usare la iso minima, invece del Boot o del DVD, non tutti i pacchetti di installazione richiesti saranno disponibili.

Poiché Packer si basa su VMware Tools per rilevare la fine dell'installazione, e il pacchetto `open-vm-tools` è disponibile solo nei repo di AppStream, dobbiamo specificare al processo di installazione che vogliamo usare come sorgente sia il cdrom che questo repo remoto:

!!! Note "Nota"

    Se non hai accesso ai repository esterni, puoi usare un mirror del repository, un proxy squid o il dvd.

```
# Use CDROM installation media
repo --name="AppStream" --baseurl="http://download.rockylinux.org/pub/rocky/8.4/AppStream/x86_64/os/"
cdrom
```

Passiamo alla configurazione della rete, poiché ancora una volta, in questo esempio non stiamo usando un server DHCP:

```
# Network information
network --bootproto=static --device=ens192 --gateway=192.168.1.254 --ip=192.168.1.11 --nameserver=192.168.1.254,4.4.4.4 --netmask=255.255.255.0 --onboot=on --ipv6=auto --activate
```

Ricorda che abbiamo specificato l'utente con cui connettersi via SSH a Packer alla fine dell'installazione. Questo utente e la password devono corrispondere:

```
# Root password
rootpw mysecurepassword
```

!!! Warning "Attenzione"

    Puoi usare una password insicura qui, a patto che ti assicuri che questa password sarà cambiata immediatamente dopo la distribuzione della tua VM, per esempio con Ansible.

Ecco lo schema di partizionamento selezionato. Si possono fare cose molto più complesse. Potete definire uno schema di partizione che si adatti alle vostre esigenze, adattandolo allo spazio su disco definito in Packer, e che rispetti le regole di sicurezza definite per il vostro ambiente (partizione dedicata a `/tmp`, ecc.):

```
# System booloader configuration
bootloader --location=mbr --boot-drive=sda
# Partition clearing information
clearpart --all --initlabel --drives=sda
# Disk partitionning information
part /boot --fstype="xfs" --ondisk=sda --size=512
part pv.01 --fstype="lvmpv" --ondisk=sda --grow
volgroup vg_root --pesize=4096 pv.01
logvol /home --fstype="xfs" --size=5120 --name=lv_home --vgname=vg_root
logvol /var --fstype="xfs" --size=10240 --name=lv_var --vgname=vg_root
logvol / --fstype="xfs" --size=10240 --name=lv_root --vgname=vg_root
logvol swap --fstype="swap" --size=4092 --name=lv_swap --vgname=vg_root
```

La prossima sezione riguarda i pacchetti che saranno installati. Una "best practice" è quella di limitare la quantità di pacchetti installati solo a quelli necessari, il che limita la superficie di attacco, soprattutto in un ambiente server.

!!! Note "Nota"

    All'autore piace limitare le azioni da fare nel processo di installazione e rimandare l'installazione di ciò che è necessario nello script post installazione di Packer. Quindi, in questo caso, installiamo solo i pacchetti minimi richiesti.

Il pacchetto `openssh-clients` sembra essere richiesto da Packer per copiare i suoi script nella VM.

L'`open-vm-tools` è anche necessario a Packer per rilevare la fine dell'installazione, questo spiega l'aggiunta del repository AppStream. `perl` e `perl-File-Temp` saranno anche richiesti da VMware Tools durante la parte di distribuzione. Questo è un peccato perché richiede un sacco di altri pacchetti dipendenti. `python3` (3.6) sarà anche richiesto in futuro perché Ansible funzioni (se non vuoi usare Ansible o python, rimuovili!).

```
%packages --ignoremissing --excludedocs
openssh-clients
open-vm-tools
python3
perl
perl-File-Temp
curl
dnf-utils
drpm
net-tools
sudo
vim
wget
```

Non solo si possono aggiungere pacchetti, ma anche rimuoverli. Dal momento che controlliamo l'ambiente in cui il nostro hardware funzionerà, possiamo rimuovere qualsiasi firmware che sarà inutile per noi:

```
# unnecessary firmware
-aic94xx-firmware
-atmel-firmware
...
```

La parte successiva aggiunge alcuni utenti. È interessante nel nostro caso creare un utente `ansible`, senza password ma con una pubkey. Questo permette a tutte le nostre nuove VM di essere accessibili dal nostro server Ansible per eseguire le azioni post-installazione:

```
# Manage Ansible access
groupadd -g 1001 ansible
useradd -m -g 1001 -u 1001 ansible
mkdir /home/ansible/.ssh
echo -e "<---- PAST YOUR PUBKEY HERE ---->" >  /home/ansible/.ssh/authorized_keys
chown -R ansible:ansible /home/ansible/.ssh
chmod 700 /home/ansible/.ssh
chmod 600 /home/ansible/.ssh/authorized_keys
echo "ansible ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible
chmod 440 /etc/sudoers.d/ansible
```

Ora dobbiamo abilitare e avviare `vmtoolsd` (il processo che gestisce open-vm-tools). vSphere rileverà l'indirizzo IP dopo il riavvio della VM.

```
systemctl enable vmtoolsd
systemctl start vmtoolsd
```

Il processo di installazione è finito e la VM si riavvierà.

## I provisioners

Ricordate, abbiamo dichiarato in Packer un provisioner, che nel nostro caso corrisponde a uno script `.sh`, da memorizzare in una sottodirectory accanto al nostro file json.

Ci sono diversi tipi di provisioner, avremmo anche potuto usare Ansible. Siete liberi di esplorare queste possibilità.

Questo file può essere completamente cambiato, ma questo fornisce un esempio di ciò che può essere fatto con uno script, in questo caso `requirements.sh:`

```
#!/bin/sh -eux

echo "Updating the system..."
dnf -y update

echo "Installing cloud-init..."
dnf -y install cloud-init

# see https://bugs.launchpad.net/cloud-init/+bug/1712680
# and https://kb.vmware.com/s/article/71264
# Virtual Machine customized with cloud-init is set to DHCP after reboot
echo "manual_cache_clean: True " > /etc/cloud/cloud.cfg.d/99-manual.cfg

echo "Disable NetworkManager-wait-online.service"
systemctl disable NetworkManager-wait-online.service

# cleanup current SSH keys so templated VMs get fresh key
rm -f /etc/ssh/ssh_host_*

# Avoid ~200 meg firmware package we don't need
# this cannot be done in the KS file so we do it here
echo "Removing extra firmware packages"
dnf -y remove linux-firmware
dnf -y autoremove

echo "Remove previous kernels that preserved for rollbacks"
dnf -y remove -y $(dnf repoquery --installonly --latest-limit=-1 -q)
dnf -y clean all  --enablerepo=\*;

echo "truncate any logs that have built up during the install"
find /var/log -type f -exec truncate --size=0 {} \;

echo "remove the install log"
rm -f /root/anaconda-ks.cfg /root/original-ks.cfg

echo "remove the contents of /tmp and /var/tmp"
rm -rf /tmp/* /var/tmp/*

echo "Force a new random seed to be generated"
rm -f /var/lib/systemd/random-seed

echo "Wipe netplan machine-id (DUID) so machines get unique ID generated on boot"
truncate -s 0 /etc/machine-id

echo "Clear the history so our install commands aren't there"
rm -f /root/.wget-hsts
export HISTSIZE=0

```

Alcune spiegazioni sono necessarie:

```
echo "Installing cloud-init..."
dnf -y install cloud-init

# see https://bugs.launchpad.net/cloud-init/+bug/1712680
# and https://kb.vmware.com/s/article/71264
# Virtual Machine customized with cloud-init is set to DHCP after reboot
echo "manual_cache_clean: True" > /etc/cloud/cloud.cfg.d/99-manual.cfg
```

Poiché vSphere ora usa cloud-init tramite i VMware Tools per configurare la rete di una macchina ospite centos8, deve essere installato. Tuttavia, se non fate nulla, la configurazione sarà applicata al primo riavvio e tutto andrà bene. Ma al prossimo riavvio, cloud-init non riceverà alcuna nuova informazione da vSphere. In questi casi, senza informazioni su cosa fare, cloud-init riconfigurerà l'interfaccia di rete della VM per usare DHCP, e si perderà la configurazione statica.

Poiché questo non è il comportamento che vogliamo, dobbiamo specificare a cloud-init di non cancellare automaticamente la sua cache, e quindi di riutilizzare le informazioni di configurazione che ha ricevuto durante il suo primo riavvio e ogni riavvio successivo.

Per questo, creiamo un file `/etc/cloud/cloud.cfg.d/99-manual.cfg` con la direttiva `manual_cache_clean: True`.

!!! Note "Nota"

    Questo implica che se avete bisogno di riapplicare una configurazione di rete tramite le personalizzazioni del guest vSphere (il che, nell'uso normale, dovrebbe essere abbastanza raro), dovrete cancellare voi stessi la cache di cloud-init.

Il resto dello script è commentato e non richiede ulteriori dettagli

Potete controllare il [progetto Bento](https://github.com/chef/bento/tree/master/packer_templates) per avere più idee su cosa si può fare in questa parte del processo di automazione.

## Creazione di Template

Ora è il momento di lanciare Packer e controllare che il processo di creazione, che è completamente automatico, funzioni bene.

Basta inserire questo nella riga di comando:

```
./packer build -var-file=~/.vsphere-secrets.json rockylinux8/template.json
```

Si può andare rapidamente su vSphere e ammirare il lavoro.

Vedrete la macchina creata, avviata e, se lanciate una console, vedrete l'inserimento automatico dei comandi e il processo di installazione.

Alla fine della creazione, troverete il vostro modello pronto all'uso in vSphere.

## Parte della distribuzione

Questa documentazione non sarebbe completa senza la parte della distribuzione automatica del modello.

Per questo, useremo un semplice playbook Ansible, che utilizza il modulo `vmware_guest`.

Questo playbook che vi forniamo, deve essere adattato alle vostre esigenze e al vostro modo di fare le cose.

```
---
- name: Deploy VM from template
  hosts: localhost
  gather_facts: no
  vars_files:
    - ./vars/credentials.yml

  tasks:

  - name: Clone the template
    vmware_guest:
      hostname: "{{ vmware_vcenter_hostname }}"
      username: "{{ vmware_username }}"
      password: "{{ vmware_password }}"
      validate_certs: False
      name: "{{ vm_name }}"
      template: "{{ template_name }}"
      datacenter: "{{ datacenter_name }}"
      folder: "{{ storage_folder }}"
      state: "{{ state }}"
      cluster: "{{ cluster_name | default(omit,true) }}"
      esxi_hostname: "{{ esxi_hostname | default(omit,true) }}"
      wait_for_ip_address: no
      annotation: "{{ comments | default('Deployed by Ansible') }}"
      datastore: "{{ datastore_name | default(omit,true) }}"
      networks:
      - name: "{{ network_name }}"
        ip: "{{ network_ip }}"
        netmask: "{{ network_mask }}"
        gateway: "{{ network_gateway }}"
        device_type: "vmxnet3"
        type: static
      hardware:
        memory_mb: "{{ memory_mb|int * 1024 }}"
        num_cpu: "{{ num_cpu }}"
        hotadd_cpu: True
        hotadd_memory: True
      customization:
        domain: "{{ domain }}"
        dns_servers: "{{ dns_servers.split(',') }}"
      guest_id: "{{ guest_id }}"
    register: deploy_vm
```

Potete memorizzare i dati sensibili nel file `./vars/credentials.yml`, che ovviamente avrete precedentemente criptato con `ansible-vault` (specialmente se usate git per il vostro lavoro). Poiché tutto utilizza una variabile, si può facilmente adattarlo alle proprie esigenze.

Se non usi qualcosa come Rundeck o Awx, puoi lanciare la distribuzione con una linea di comando simile a questa:

```
ansible-playbook -i ./inventory/hosts  -e '{"comments":"my comments","cluster_name":"CS_NAME","esxi_hostname":"ESX_NAME","state":"started","storage_folder":"PROD","datacenter_name":"DC_NAME}","datastore_name":"DS_NAME","template_name":"template-rockylinux8-0.0.1","vm_name":"test_vm","network_name":"net_prod","network_ip":"192.168.1.20","network_gateway":"192.168.1.254","network_mask":"255.255.255.0","memory_mb":"4","num_cpu":"2","domain":"rockylinux.lan","dns_servers":"192.168.1.254","guest_id":"centos8_64Guest"}' ./vmware/create_vm.yml --vault-password-file /etc/ansible/vault_pass.py
```

È a questo punto che potete lanciare la configurazione finale della vostra macchina virtuale utilizzando Ansible. Non dimenticate di cambiare la password di root, proteggere SSH, registrare la nuova VM nel vostro strumento di monitoraggio e nell'inventario IT, ecc.

## In sintesi

Come abbiamo visto, ci sono ora soluzioni DevOps completamente automatizzate per creare e distribuire le VM.

Allo stesso tempo, questo rappresenta un innegabile risparmio di tempo, soprattutto in ambienti cloud o data center. Facilita anche una conformità standard in tutti i computer dell'azienda (server e stazioni di lavoro), e una facile manutenzione / evoluzione dei modelli.

## Altri riferimenti

Per un progetto dettagliato che copre anche l'implementazione di Rocky Linux e altri sistemi operativi utilizzando le ultime novità di vSphere, Packer e il Packer Plugin per vSphere, visitate [questo progetto](https://github.com/vmware-samples/packer-examples-for-vsphere). 
