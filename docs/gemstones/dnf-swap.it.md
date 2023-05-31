- - -
title: comando dnf - swap author: wale soyinka contributors: date: 2023-01-24 tags:
  - cloud images
  - containers
  - dnf
  - dnf swap
  - curl
  - curl-minimal
  - allowerasing
  - coreutils-single
- - -


# Introduzione

Per rendere le immagini dei container e di quelle cloud il più piccole possibile, i manutentori delle distribuzioni e i gestori dei pacchetti possono talvolta fornire versioni ridotte dei pacchetti più diffusi. Esempi di pacchetti ridotti in bundle con container o immagini cloud sono **vim-minimal, curl-minimal, coreutils-single** e così via.

Anche se alcuni dei pacchetti forniti sono versioni ridotte, spesso sono del tutto accettabili per la maggior parte dei casi d'uso.

Nei casi in cui il pacchetto ridotto non sia sufficiente, si può usare il comando `dnf swap` per sostituire rapidamente il pacchetto minimo con quello normale.

# Obiettivo

Questo Rocky Linux GEMstone mostra come usare **dnf** per _scambiare_ il pacchetto `curl-minimal` con il pacchetto `curl` normale.


## Controllare la variante di curl esistente

Quando si accede al container o all'ambiente della macchina virtuale come utente con privilegi amministrativi, verificare innanzitutto la variante del pacchetto `curl` installata. Digita:

```bash
# rpm -qa | grep  ^curl-minimal
curl-minimal-*
```

Abbiamo curl-minimal sul nostro sistema demo!


## Sostituire curl-minimal con curl

Usare `dnf` per scambiare il pacchetto `curl-minimal` installato con il pacchetto `curl` normale.

```bash
# dnf -y swap curl-minimal curl

```

## Controllare la nuova variante del pacchetto curl

Per confermare le modifiche, interrogare nuovamente il database rpm per i pacchetti curl installati eseguendo:

```bash
# rpm -qa | grep  ^curl
curl-*
```


Ed è una GEMMA!


## Note

Comando DNF Swap

**Sintassi**:

```bash
dnf [options] swap <package-to-be-removed> <replacement-package>
```

Sotto il cofano, `dnf swap` usa l'opzione `--allowerasing` di DNF per risolvere qualsiasi conflitto di pacchetti. Pertanto, l'esempio di curl minimale mostrato in questa GEMstone avrebbe potuto essere eseguito anche eseguendo:


```bash
dnf install -y --allowerasing curl
```



