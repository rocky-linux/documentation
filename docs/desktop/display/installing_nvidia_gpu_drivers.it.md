---
title: Installazione drivers NVIDIA GPU
author: Brinkman Joseph
contributors: Steven Spencer, Ganna Zhyrnova
---

## Introduzione

NVIDIA^&reg;^ è uno dei produttori di GPU più popolari. È possibile installare i driver delle GPU NVIDIA in più di un modo.  Questa guida utilizza il repository ufficiale di NVIDIA per installare i suoi driver. Per questo motivo, [la guida all'installazione di NVIDIA](https://docs.nvidia.com/cuda/pdf/CUDA_Installation_Guide_Linux.pdf) è un riferimento importante.

!!! note "Nota"

```
Il link per le attività di pre-installazione nella guida ufficiale di NVIDIA è inutilizzabile. Per installare il driver NVIDIA, è necessario installare le utility e le dipendenze necessarie dal loro repository ufficiale.
```

Alcuni altri modi alternativi per installare i driver NVIDIA includono:

- L'installer `.run` di NVIDIA
- Repo RPMFusion di terze parti
- Driver ELRepo di terze parti

Nella maggior parte dei casi, è meglio installare i driver NVIDIA dalla fonte ufficiale. RPMFusion e ELRepo sono disponibili per chi preferisce un repository più comunity-based. Per l'hardware più vecchio, la soluzione migliore è RPMFusion. È consigliabile evitare di usare il programma di installazione `.run`. Sebbene sia comodo, l'uso del programma di installazione `.run` è noto per la sovrascrittura dei file di sistema e per i problemi di incompatibilità.

## Presupposti

Per questa guida sono necessari i seguenti elementi:

- Rocky Linux Workstation
- Privilegi `sudo`

## Installare le utility e le dependencies necessarie

Attivare il repository Extra Packages for Enterprise Linux (EPEL):

```bash
sudo dnf install epel-release -y
```

L'installazione dei 'Development Tools' assicura le necessarie dipendenze di compilazione:

```bash
sudo dnf groupinstall "Development Tools" -y
```

Il pacchetto `kernel-devel` fornisce gli header e gli strumenti necessari per costruire i moduli del kernel:

```bash
sudo dnf install kernel-devel -y
```

Dynamic Kernel Module Support (DKMS) è un programma utilizzato per il rebuild automatico dei moduli del kernel:

```bash
sudo dnf install dkms -y
```

## Installare i driver NVIDIA

Dopo aver installato i prerequisiti necessari, è il momento di installare i driver NVIDIA.

Aggiungere il repository ufficiale di NVIDIA con il seguente comando:

!!! note "Nota"

```
Se si utilizza Rocky 8, sostituire `rhel9` nel percorso del file con `rhel8`.
```

```bash
sudo dnf config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/rhel9/$(uname -i)/cuda-rhel9.repo
```

Successivamente, installare una serie di pacchetti necessari per la creazione e l'installazione dei moduli del kernel:

```bash
sudo dnf install kernel-headers-$(uname -r) kernel-devel-$(uname -r) tar bzip2 make automake gcc gcc-c++ pciutils elfutils-libelf-devel libglvnd-opengl libglvnd-glx libglvnd-devel acpid pkgconf dkms -y
```

Installare il driver NVIDIA più recente per il proprio sistema:

```bash
sudo dnf module install nvidia-driver:latest-dkms -y
```

## Disabilitare Nouveau

Nouveau è un driver NVIDIA open-source che offre funzionalità limitate rispetto ai driver proprietari di NVIDIA. È meglio disabilitarla per evitare conflitti con i driver:

```bash
sudo grubby --args="nouveau.modeset=0 rd.driver.blacklist=nouveau" --update-kernel=ALL
```

!!! Note "Nota"

````
Per i sistemi con l'avvio sicuro abilitato è necessario eseguire questo passaggio:

```bash
bash sudo mokutil --import /var/lib/dkms/mok.pub
```

Il comando `mokutil` vi chiederà di creare una password, che sarà usata durante il riavvio.

Dopo il riavvio, il sistema dovrebbe chiedervi se volete registrare una chiave o qualcosa di simile, rispondete "sì" e vi chiederà la password che avete dato nel comando `mokutil`.
````

Riavvio:

```bash
sudo reboot now
```

## Conclusione

I driver delle GPU NVIDIA sono stati installati con successo sul sistema utilizzando il repository ufficiale di NVIDIA. Sfruttate le capacità avanzate della vostra GPU NVIDIA che i driver Nouveau predefiniti non sono in grado di offrire.
