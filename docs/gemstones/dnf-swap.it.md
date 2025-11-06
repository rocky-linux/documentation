- - -
title: comando dnf - swap author: wale soyinka contributors: date: 2023-01-24 tags:
  - cloud images
  - containers
  - dnf
  - dnf swap
  - vim
  - vim-minimal
  - allowerasing
  - coreutils-single
- - -


# Introduzione

Per rendere le immagini dei container e di quelle cloud il più piccole possibile, i manutentori delle distribuzioni e i gestori dei pacchetti possono talvolta fornire versioni ridotte dei pacchetti più diffusi. Esempi di pacchetti ridotti in bundle con container o immagini cloud sono **vim-minimal, curl-minimal, coreutils-single** e così via.

Anche se alcuni dei pacchetti forniti sono versioni ridotte, spesso sono del tutto accettabili per la maggior parte dei casi d'uso.

Nei casi in cui il pacchetto ridotto non sia sufficiente, si può usare il comando `dnf swap` per sostituire rapidamente il pacchetto minimo con quello normale.

## Obiettivo

Questa Rocky Linux GEMstone mostra come utilizzare **dnf** per _scambiare_ il pacchetto `vim-minimal` in dotazione con il pacchetto `vim` standard.

## Controllare la variante `vim` esistente

Dopo aver effettuato l'accesso al proprio ambiente container o macchina virtuale come utente con privilegi amministrativi, verificare innanzitutto la variante del pacchetto `vim` installata. Digita:

```bash
# rpm -qa | grep  ^vim
vim-minimal-9.1.083-5.el10_0.1.x86_64
```

Sul nostro sistema è presente `vim-minimal`.

## Sostituire `vim-minimal` con `vim`

Utilizzare `dnf` per sostituire il pacchetto `vim-minimal` installato con il pacchetto standard `vim`.

```bash
# dnf -y swap vim-minimal vim
```

## Controllare la nuova variante del pacchetto `vim`

Per confermare le modifiche, interrogare nuovamente il database rpm per i pacchetti `vim` installati eseguendo:

```bash
# rpm -qa | grep  ^vim
vim-enhanced-9.1.083-5.el10_0.1.x86_64
```

Ed è una GEMMA!

## Note

Comando DNF Swap

**Sintassi**:

```bash
dnf [options] swap <package-to-be-removed> <replacement-package>
```

Sotto il cofano, `dnf swap` usa l'opzione `--allowerasing` di DNF per risolvere qualsiasi conflitto di pacchetti. Pertanto, l'esempio `vim-minimal` illustrato in questo GEMstone avrebbe potuto essere realizzato anche eseguendo:

```bash
dnf install -y --allowerasing vim
```
