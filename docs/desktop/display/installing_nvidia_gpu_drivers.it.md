---
title: Installazione drivers NVIDIA GPU
author: Brinkman Joseph
contributors: Steven Spencer, Ganna Zhyrnova
---

## Introduzione

NVIDIA^&reg;^ è uno dei produttori di GPU più popolari. È possibile installare i driver delle GPU NVIDIA in più di un modo.  Questa guida utilizza il repository ufficiale di NVIDIA per installare i suoi driver. Per questo motivo, [la guida all'installazione di NVIDIA](https://docs.nvidia.com/cuda/pdf/CUDA_Installation_Guide_Linux.pdf) è un riferimento importante.

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
sudo dnf install kernel-devel-matched kernel-headers -y
```

## Installare i driver NVIDIA

Dopo aver installato i prerequisiti necessari, è il momento di installare i driver NVIDIA.

Aggiungere il repository ufficiale di NVIDIA con il seguente comando:

```bash
sudo dnf config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/rhel10/$(uname -i)/cuda-rhel10.repo
```

Successivamente, pulire la cache del repository di DNF:

```bash
sudo dnf clean expire-cache
```

Infine, installare l'ultimo driver disponibile di Nvidia per il proprio sistema. Per i moduli kernel open, eseguire:

```bash
sudo dnf install nvidia-open -y
```

Mentre per i moduli kernel proprietari, eseguire:

```bash
sudo dnf install cuda-drivers -y
```

## Disabilitare Nouveau

Nouveau è un driver NVIDIA open-source che offre funzionalità limitate rispetto ai driver proprietari di NVIDIA. È meglio disabilitarla per evitare conflitti con i driver:

```bash
sudo grubby --args="nouveau.modeset=0 rd.driver.blacklist=nouveau" --update-kernel=ALL
```

!!! note "Nota"

````
Per i sistemi con secure boot abilitato è necessario eseguire questo passaggio:

```bash
sudo mokutil --import /var/lib/dkms/mok.pub
```

Il comando `mokutil` richiederà di creare una password, che verrà utilizzata durante il riavvio.

Dopo il riavvio, il sistema dovrebbe chiedere se si desidera registrare una chiave o qualcosa di simile, rispondere "sì" e verrà richiesta la password fornita nel comando `mokutil`.
````

Riavvio:

```bash
sudo reboot now
```

## Conclusione

I driver delle GPU NVIDIA sono stati installati con successo sul sistema utilizzando il repository ufficiale di NVIDIA. Sfruttate le capacità avanzate della vostra GPU NVIDIA che i driver Nouveau predefiniti non sono in grado di offrire.
