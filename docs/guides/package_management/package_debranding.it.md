---
title: Debranding dei Pacchetti
---

# Come fare il debranding del pacchetto Rocky

Questo spiega come eseguire il debrand di un pacchetto per la distribuzione Rocky Linux.


Istruzioni Generali

In primo luogo, identificare i file nel pacchetto che devono essere cambiati. Possono essere file di testo, file di immagine, o altri. È possibile identificare i file scavando in git.centos.org/rpms/PACKAGE/

Sviluppare dei sostituti per questi file, ma utilizzando invece il marchio Rocky. A seconda del contenuto da sostituire, per alcuni tipi di testo possono essere necessari file diff/patch.

I file di sostituzione si trovano in https://git.rockylinux.org/patch/PACKAGE/ROCKY/_supporting/ Il file di configurazione (che specifica come applicare le patch) in https://git.rockylinux.org/patch/PACKAGE/ROCKY/CFG/*.cfg

Nota: Usa spazi, non tabulazioni. Quando srpmproc importerà il pacchetto in Rocky, si vedrà il lavoro svolto in https://git.rockylinux.org/patch/PACKAGE e applicherà le patch di debranding memorizzate leggendo i file di configurazione sotto ROCKY/CFG/*.cfg


da [pagina wiki di debranding](https://wiki.rockylinux.org/team/release_engineering/debranding/)
