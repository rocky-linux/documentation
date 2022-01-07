---
title: Gestione del software
---

# Gestione del software

## Generalità

Su un sistema Linux, è possibile installare il software in due modi:

* Utilizzando un pacchetto di installazione;
* Compilandolo da un file sorgente.

!!! Note "Nota"

    L'installazione da sorgente non è trattata qui. Di norma, è necessario utilizzare il metodo del pacchetto a meno che il software desiderato non sia disponibile tramite il gestore pacchetti. La ragione di ciò è che le dipendenze sono generalmente gestite dal sistema di pacchetti, mentre con il sorgente, è necessario gestire manualmente le dipendenze.

**Il pacchetto**: si tratta di un singolo file contenente tutti i dati necessari per installare il programma. Può essere eseguito direttamente sul sistema da un repository software.

**I file sorgente** : Alcuni software non sono forniti in pacchetti pronti per essere installati, ma tramite un archivio contenente i file sorgente. Spetta all'amministratore preparare questi file e compilarli per installare il programma.

## RPM : Gestione pacchetti RedHat

**RPM** (RedHat Package Manager) è un sistema di gestione software. È possibile installare, disinstallare, aggiornare o controllare il software contenuto nei pacchetti.

**RPM** è il formato utilizzato da tutte le distribuzioni basate su RedHat (RockyLinux, Fedora, CentOS, SuSe, Mandriva, ...). Il suo equivalente nel mondo Debian è DPKG (Debian Package).

Il nome di un pacchetto RPM segue una nomenclatura specifica:

![Illustration of a package name](images/software-001.png)

### comando `rpm`

Il comando rpm consente di installare un pacchetto.

```
rpm [-i][-U] package.rpm [-e] package
```

Esempio (per un pacchetto denominato 'package'):

```
[root]# rpm -ivh package.rpm
```

| Opzione          | Descrizione                                         |
| ---------------- | --------------------------------------------------- |
| `-i package.rpm` | Installa il pacchetto.                              |
| `-U package.rpm` | Aggiorna un pacchetto già installato.               |
| `-e package.rpm` | Disinstalla il pacchetto.                           |
| `-h`             | Visualizza una barra di avanzamento.                |
| `-v`             | Informa sullo stato di avanzamento dell'operazione. |
| `--test`         | Esegue il test del comando senza eseguirlo.         |

Il comando `rpm` consente inoltre di interrogare il database dei pacchetti sul sistema aggiungendo l'opzione `-q`.

È possibile eseguire diversi tipi di ricerche per ottenere informazioni sui pacchetti installati. Il database RPM si trova nella directory `/var/lib/rpm`.

Esempio:

```
[root]# rpm -qa
```

Questo comando esegue una ricerca su tutti i pacchetti installati nel sistema.

```
rpm -q [-a][-i][-l] package [-f] file
```

Esempio:

```
[root]# rpm -qil package
[root]# rpm -qf /path/to/file
```

| Opzione          | Descrizione                                                                                                                   |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `-a`             | Elenca tutti i pacchetti installati nel sistema.                                                                              |
| `-i __package__` | Visualizza le informazioni sul pacchetto.                                                                                     |
| `-l __package__` | Elenca i file contenuti nel pacchetto.                                                                                        |
| `-f`             | Mostra il nome del pacchetto contenente il file specificato.                                                                  |
| `--last`         | L'elenco dei pacchetti è indicato per data di installazione (gli ultimi pacchetti installati vengono visualizzati per primi). |

!!! Warning "Attenzione"

    Dopo l'opzione `-q`, il nome del pacchetto deve essere esatto. I metacaratteri (wildcards) non sono supportati.

!!! Tip "Suggerimento"

    Tuttavia, è possibile elencare tutti i pacchetti installati e filtrarli con il comando `grep`.

Esempio: elencare gli ultimi pacchetti installati:

```
sudo rpm -qa --last | head
NetworkManager-config-server-1.26.0-13.el8.noarch Mon 24 May 2021 02:34:00 PM CEST
iwl2030-firmware-18.168.6.1-101.el8.1.noarch  Mon 24 May 2021 02:34:00 PM CEST
iwl2000-firmware-18.168.6.1-101.el8.1.noarch  Mon 24 May 2021 02:34:00 PM CEST
iwl135-firmware-18.168.6.1-101.el8.1.noarch   Mon 24 May 2021 02:34:00 PM CEST
iwl105-firmware-18.168.6.1-101.el8.1.noarch   Mon 24 May 2021 02:34:00 PM CEST
iwl100-firmware-39.31.5.1-101.el8.1.noarch    Mon 24 May 2021 02:34:00 PM CEST
iwl1000-firmware-39.31.5.1-101.el8.1.noarch   Mon 24 May 2021 02:34:00 PM CEST
alsa-sof-firmware-1.5-2.el8.noarch            Mon 24 May 2021 02:34:00 PM CEST
iwl7260-firmware-25.30.13.0-101.el8.1.noarch  Mon 24 May 2021 02:33:59 PM CEST
iwl6050-firmware-41.28.5.1-101.el8.1.noarch   Mon 24 May 2021 02:33:59 PM CEST
```

Esempio: elencare la cronologia di installazione del kernel:

```
sudo rpm -qa --last kernel
kernel-4.18.0-305.el8.x86_64                  Tue 25 May 2021 06:04:56 AM CEST
kernel-4.18.0-240.22.1.el8.x86_64             Mon 24 May 2021 02:33:35 PM CEST
```

Esempio: elencare tutti i pacchetti installati con un nome specifico utilizzando 'grep':

```
sudo dnf list installed | grep httpd
centos-logos-httpd.noarch           80.5-2.el8                              @baseos      
httpd.x86_64                        2.4.37-30.module_el8.3.0+561+97fdbbcc   @appstream   
httpd-filesystem.noarch             2.4.37-30.module_el8.3.0+561+97fdbbcc   @appstream   
httpd-tools.x86_64                  2.4.37-30.module_el8.3.0+561+97fdbbcc   @appstream
```

## DNF : Dandified Yum

**DNF** (**Dandified Yum**) è un gestore di pacchetti software, successore di **YUM** (**Y**ellow Dog **U**pdater **M**odified). Funziona con pacchetti **RPM** raggruppati in un repository locale o remoto (una directory per l'archiviazione dei pacchetti). Per i comandi più comuni, il suo utilizzo è identico a quello di `yum`.

Il comando `dnf` permette la gestione dei pacchetti confrontando quelli installati sul sistema con quelli nei repository definiti sul server. Installa inoltre automaticamente le dipendenze, se sono presenti anche nei repository.

`dnf` è il gestore utilizzato da molte distribuzioni basate su RedHat (RockyLinux, Fedora, CentOS, ...). Il suo equivalente nel mondo Debian è **APT** (**A**dvanced **P**ackaging **T**ool).

### comando `dnf`

Il comando dnf consente di installare un pacchetto specificando solo il nome breve.

```
dnf [install][remove][list all][search][info] package
```

Esempio:

```
[root]# dnf install tree
```

È richiesto solo il nome breve del pacchetto.

| Opzione                   | Descrizione                               |
| ------------------------- | ----------------------------------------- |
| `install`                 | Installa il pacchetto.                    |
| `remove`                  | Disinstalla il pacchetto.                 |
| `list all`                | Elenca i pacchetti già nel repository.    |
| `search`                  | Cerca un pacchetto nel repository.        |
| `provides */command_name` | Cerca un comando.                         |
| `info`                    | Visualizza le informazioni sul pacchetto. |

Il comando `dnf list` elenca tutti i pacchetti installati sul sistema e presenti nel repository. Accetta diversi parametri:

| Parametro   | Descrizione                                                               |
| ----------- | ------------------------------------------------------------------------- |
| `all`       | Elenca i pacchetti installati e quindi quelli disponibili nei repository. |
| `available` | Elenca solo i pacchetti disponibili per l'installazione.                  |
| `updates`   | Elenca i pacchetti che possono essere aggiornati.                         |
| `obsoletes` | Elenca i pacchetti resi obsoleti dalle versioni superiori disponibili.    |
| `recent`    | Elenca i pacchetti più recenti aggiunti al repository.                    |

Esempio di ricerca del comando `semanage`:

```
[root]# dnf provides */semanage
```

### Come funziona DNF

Il gestore DNF si basa su uno o più file di configurazione per indirizzare i repository contenenti i pacchetti RPM.

Questi file si trovano in `/etc/yum.repos.d/` e devono terminare con `.repo` per poter essere utilizzati da DNF.

Esempio:

```
/etc/yum.repos.d/Rocky-BaseOS.repo
```

Ogni file `.repo` è costituito da almeno le seguenti informazioni, una direttiva per riga.

Esempio:

```
[baseos] # Short name of the repository
name=Rocky Linux $releasever - BaseOS # Short name of the repository #Detailed name
mirrorlist=http://mirrors.rockylinux.org/mirrorlist?arch=$basearch&repo=BaseOS-$releasever # http address of a list or mirror
#baseurl=http://dl.rockylinux.org/$contentdir/$releasever/BaseOS/$basearch/os/ # http address for direct access
gpgcheck=1 # Repository requiring a signature
enabled=1 # Activated =1, or not activated =0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial # GPG public key path
```

Per impostazione predefinita, la direttiva `enabled` è assente, il che significa che il repository è abilitato. Per disabilitare un repository, è necessario specificare la direttiva `enabled=0`.

## Il repository EPEL

**EPEL** (**E**xtra **P**ackages for **E**nterprise **L**inux) è un repository contenente pacchetti software aggiuntivi per Enterprise Linux, che include RedHat Enterprise Linux (RHEL), RockyLinux, CentOS, ecc.

### Installazione

Scarica e installa l'rpm dal repository:

Se sei dietro un proxy internet:

```
[root]# export http_proxy=http://172.16.1.10:8080
```

Quindi:

```
[root]# dnf install epel-release
```
