---
title: Aggiornamenti di versione supportati da Rocky
author: Steven Spencer
contributors: Ganna Zhyrnova
---

**OR** Come duplicare qualsiasi macchina Rocky.

## Introduzione

Fin dal primo giorno del progetto Rocky Linux, alcuni hanno chiesto: ==Come si fa ad aggiornare da CentOS 7 a Rocky 8, o da Rocky 8 a Rocky 9?== La risposta è sempre la stessa: **Il progetto non supporta gli aggiornamenti in-place di una major release a un'altra. È necessario reinstallare il sistema operativo per passare alla versione principale successiva.** Per essere chiari, questa **è** la risposta corretta. Questo documento consente agli utenti di passare da una major release alla successiva, utilizzando la procedura corretta supportata da Rocky per una nuova installazione. È possibile utilizzare questo metodo per ricostruire la stessa versione di Rocky Linux. Per esempio, installate 9.5 su una nuova 9.5 con tutti i pacchetti.

!!! note "Avvertenze"

```
Anche con questa procedura, molte cose possono andare storte quando si passa da una versione precedente di un sistema operativo (OS) a una versione più recente dello stesso o di un altro OS. I programmi diventano obsoleti e vengono sostituiti dai manutentori con nomi di pacchetti completamente diversi, oppure i nomi non corrispondono da un sistema operativo all'altro. Inoltre, è bene conoscere i repository software della propria macchina e verificare che siano ancora funzionanti per il nuovo sistema operativo. Se si passa da una versione più vecchia a una più recente, assicurarsi che la CPU e gli altri requisiti della macchina corrispondano a quelli della nuova versione. Per queste e molte altre ragioni, è necessario essere prudenti e annotare eventuali errori o problemi durante l'esecuzione di questa procedura. L'autore ha utilizzato Rocky Linux 8 come vecchia versione e Rocky Linux 9 come nuova versione principale. La formulazione di tutti gli esempi utilizza queste due versioni. Potete sempre procedere a vostro rischio e pericolo.
```

## Sintesi degli step

1. Ottenere un elenco di utenti dalla vecchia installazione (`userid.txt`).
2. Ottenere un elenco di repository dalla vecchia installazione (`repolist.txt`).
3. Ottenere un elenco dei pacchetti della vecchia installazione (`installed.txt`).
4. Eseguire il backup di tutti i dati, la configurazione, le utilità e gli script della vecchia installazione in una posizione non volatile, insieme ai file \`.txt' creati.
5. Verificare che l'hardware da installare supporti il sistema operativo che si sta installando. (CPU, memoria, spazio su disco e così via).
6. Eseguire una nuova installazione del sistema operativo utilizzato sull'hardware.
7. Eseguire un `dnf upgrade` per ottenere tutti i pacchetti che potrebbero essere stati aggiornati dopo la creazione del file ISO.
8. Creare gli utenti necessari esaminando il file `userid.txt`.
9. Installare tutti i repository mancanti che non sono legati a Rocky nel file `repolist.txt`. (Vedere le note per i repository EPEL e Code Ready Builder (CRB)).
10. Installare i pacchetti seguendo la procedura per il file `installed.txt`.

## Step dettagliati

!!! info “Aggiornamenti della stessa versione”

```
Come discusso in precedenza, questa procedura dovrebbe funzionare altrettanto bene per duplicare l'installazione di una macchina con la stessa release del sistema operativo, ad esempio da 8.10 a 8.10 o da 9.5 a 9.5. La differenza è che non dovrebbe essere necessario `-skip-broken' quando si installano i pacchetti dal file `installed.txt'. Se si verificano errori nei pacchetti durante l'installazione di una versione, probabilmente manca un repository. Fermare la procedura e riesaminare il file `repolist.txt`. Gli esempi qui riportati utilizzano la 8.10 come vecchia installazione e la 9.5 come nuova.
```

!!! warning "Rocky 10 non era stata rilasciata"

```
A causa dei numerosi cambiamenti tra la versione 9.5 e la prossima versione 10, questa procedura **potrebbe non funzionare** per passare dalla 9.5 alla 10. L'esplorazione di questo aspetto avverrà quando ci sarà una release della 10 da testare.
```

### Esempio di una vecchia macchina

La vecchia macchina utilizzata è Rocky Linux 8. L'installazione include diversi pacchetti del repository Extra Packages for Enterprise Linux (EPEL).

!!! info "Code Ready Builder"

````
Il repository Code Ready Builder (CRB) in Rocky Linux 9 sostituisce la funzionalità del repository PowerTools, ormai deprecato, che esisteva nella versione 8. Se si passa da una versione 8 alla 9 in cui è presente EPEL, è necessario abilitare il CRB sulla nuova macchina con la seguente procedura:

```bash
sudo dnf config-manager --enable crb
````

#### Ottenere un elenco di utenti

È necessario creare manualmente tutti gli utenti sul nuovo computer, quindi è necessario sapere quali account utente creare. Gli account utente partono generalmente dall'id utente 1000 e aumentano in seguito.

```bash
sudo getent passwd > userid.txt
```

#### Ottenere un elenco di repository

È necessario un elenco dei repository esistenti sulla vecchia macchina:

```bash
sudo ls -al /etc/yum.repos.d/ > repolist.txt
```

#### Ottenere un elenco di pacchetti

Generare l'elenco dei pacchetti con quanto segue:

```bash
sudo dnf list installed | awk 'NR>1 {print $1}' | sort -u > installed.txt
```

In questo caso, `NR>1` elimina il record uno dalla colonna, che ha la dicitura “Installato”, ottenuta dal comando `dnf list installed`. Non è un pacchetto, quindi non se ne ha bisogno. L'opzione `{print $1}` significa che si usa solo la prima colonna. Nell'elenco non è necessario indicare la versione del pacchetto o il repository da cui proviene.

Non è necessario installare alcun pacchetto relativo al kernel. Se si tralascia questo passaggio, non fa niente installarli di nuovo. È possibile rimuovere le linee del kernel con:

```bash
sudo sed -i '/kernel/d' installed.txt
```

#### Backup di tutti i dati

Questo può comprendere molte cose. Assicuratevi di conoscere lo scopo della macchina che state sostituendo e tutti i suoi componenti software (database, server di posta, DNS e altro). Se si ha dei dubbi, si faccia un backup.

#### Copiare i file

Copiare i file di testo creati in una posizione non volatile e tutti i dati di backup.

### Esempio di nuova macchina

La nuova installazione di Rocky Linux 9 è completa. È necessario ottenere tutti gli aggiornamenti dei pacchetti dalla creazione dell'immagine ISO:

```bash
sudo dnf upgrade
```

Ora si è pronti per iniziare a copiare i file di testo e i backup da dove sono stati memorizzati nella procedura precedente.

#### Creare gli utenti

Esaminare il file `userid.txt` e creare gli utenti necessari sulla nuova macchina.

#### Installare i repository

Esaminare il file `repolist.txt` e installare manualmente i repository necessari. È possibile ignorare i repository legati a Rocky. Ricordate che si hanno pacchetti da EPEL, quindi si avrà bisogno del repository CRB piuttosto che di PowerTools:

```bash
sudo dnf config-manager --enable crb
```

Installare l'EPEL:

```bash
sudo dnf install epel-release
```

Installare qualsiasi altro repository dal file `repolist.txt` che non sia basato su Rocky o EPEL.

#### Installare i packages

Una volta completata l'installazione dei repository, si provi a installare i pacchetti da `installed.txt`:

```bash
sudo dnf -y install $(cat installed.txt)
```

Alcuni pacchetti non esistono tra Rocky Linux 8 e Rocky Linux 9, indipendentemente dai repository abilitati. L'esecuzione di questo comando dà un'idea di quali siano questi pacchetti.

Ecco cosa non si è installato sul computer di prova dell'autore (riorganizzato come una colonna anziché come una lunga stringa):

```text
Error: Unable to find a match: 
OpenEXR-libs.x86_64 
bind-export-libs.x86_64 
dhcp-libs.x86_64 
fontpackages-filesystem.noarch 
hardlink.x86_64 
ilmbase.x86_64 
libXxf86misc.x86_64 
libcroco.x86_64 
libmcpp.x86_64 
libreport-filesystem.x86_64 
mcpp.x86_64 
network-scripts.x86_64 
platform-python.x86_64 
platform-python-pip.noarch 
platform-python-setuptools.noarch 
xorg-x11-font-utils.x86_64
```

!!! note

````
Se si ha bisogno della funzionalità di questi pacchetti mancanti nella nuova installazione, salvarli in un file da usare in seguito. È possibile vedere lo stato di disponibilità dei pacchetti mancanti usando questo comando:

```bash
sudo dnf whatprovides [nome_pacchetto]
```
````

Eseguire nuovamente il comando, ma questa volta con l'aggiunta di \`-skip-broken':

```bash
sudo dnf -y install $(cat installed.txt) --skip-broken
```

Poiché sono state apportate molte modifiche, è necessario riavviare prima di continuare.

#### Ripristino dei backup

Una volta installati tutti i pacchetti, ripristinare i backup, i file di configurazione modificati, gli script e le altre utilità di cui si è fatto il backup prima del trasferimento sulla nuova macchina.

## Conclusione

Non esiste una routine magica (supportata da Rocky Linux) per passare da una versione principale all'altra. Gli sviluppatori di Rocky Linux supportano solo una nuova installazione. La routine qui fornita consente di passare da una versione principale all'altra seguendo le migliori pratiche del team Rocky.

Questa procedura presuppone un'installazione semplice. Tuttavia, se l'installazione è complessa, potrebbe essere necessario eseguire più passaggi. Questa procedura può essere utilizzata come guida.

## Dichiarazione di non responsabilità

Mentre il documento di base è dell'autore, due persone nel [Forum] (https://forums.rockylinux.org/t/boot-too-small-rebuild/17415) hanno suggerito un modo più pulito per generare il `installed.txt` e hanno eliminato i pacchetti del kernel. Grazie a tutti coloro che hanno fornito indicazioni su questa procedura.
