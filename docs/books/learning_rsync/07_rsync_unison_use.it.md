---
title: Usare unison
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2021-12-26
---

# Breve

Come abbiamo accennato in precedenza, la sincronizzazione unidirezionale utilizza rsync + inotify-tools. In alcuni scenari di utilizzo speciali, può essere richiesta la sincronizzazione a due vie, che richiede inotify-tools + unison.

## Preparazione dell'ambiente

* Sia Rocky Linux 8 che Fedora 34 richiedono la compilazione del codice sorgente e l'installazione **inotify-tools**, che non è specificamente trattato qui.
* Entrambe le macchine devono essere autenticate senza password, qui usiamo il protocollo SSH
* [ocaml](https://github.com/ocaml/ocaml/) utilizza v4.12.0, [unison](https://github.com/bcpierce00/unison/) utilizza v2.51.4.

Dopo che l'ambiente è pronto, si può verificare:

```bash
[root@Rocky ~]# inotifywa
inotifywait inotifywatch
[root@Rocky ~]# ssh -p 22 testrsync@192.168.100.5
Last login: Thu Nov 4 13:13:42 2021 from 192.168.100.4
[testrsync@fedora ~]$
```

```bash
[root@fedora ~]# inotifywa
inotifywait inotifywatch
[root@fedora ~]# ssh -p 22 testrsync@192.168.100.4
Last login: Wed Nov 3 22:07:18 2021 from 192.168.100.5
[testrsync@Rocky ~]$
```

!!! tip "Suggerimento"

    I file di configurazione delle due macchine **/etc/ssh/sshd_config** dovrebbero essere aperti <font color=red>PubkeyAuthentication yes</font>

## Rocky Linux 8 installare unison

Ocaml è un linguaggio di programmazione, e lo strato inferiore di unison dipende da esso.

```bash
[root@Rocky ~]# wget -c https://github.com/ocaml/ocaml/archive/refs/tags/4.12.0.tar.gz
[root@Rocky ~]# tar -zvxf 4.12.0.tar.gz -C /usr/local/src/
[root@Rocky ~]# cd /usr/local/src/ocaml-4.12.0
[root@Rocky /usr/local/src/ocaml-4.12.0]# ./configure --prefix=/usr/local/ocaml && make world opt && make install
...
[root@Rocky ~]# ls /usr/local/ocaml/
bin lib man
[root@Rocky ~]# echo PATH=$PATH:/usr/local/ocaml/bin >> /etc/profile
[root@Rocky ~]# . /etc/profile
```

```bash
[root@Rocky ~]# wget -c https://github.com/bcpierce00/unison/archive/refs/tags/v2.51.4.tar.gz
[root@Rocky ~]# tar -zvxf v2.51.4.tar.gz -C /usr/local/src/
[root@Rocky ~]# cd /usr/local/src/unison-2.51.4/
[root@Rocky /usr/local/src/unison-2.51.4]# make UISTYLE=txt
...
[root@Rocky /usr/local/src/unison-2.51.4]# ls src/unison
src/unison
[root@Rocky /usr/local/src/unison-2.51.4] cp -p src/unison /usr/local/bin
```

## Fedora 34 installare unison

La stessa operazione.

```bash
[root@fedora ~]# wget -c https://github.com/ocaml/ocaml/archive/refs/tags/4.12.0.tar.gz
[root@feodora ~]# tar -zvxf 4.12.0.tar.gz -C /usr/local/src/
[root@fedora ~]# cd /usr/local/src/ocaml-4.12.0
[root@fedora /usr/local/src/ocaml-4.12.0]# ./configure --prefix=/usr/local/ocaml && make world opt && make install
...
[root@fedora ~]# ls /usr/local/ocaml/
bin lib man
[root@fedora ~]# echo PATH=$PATH:/usr/local/ocaml/bin >> /etc/profile
[root@fedora ~]#. /etc/profile
```

```bash
[root@fedora ~]# wget -c https://github.com/bcpierce00/unison/archive/refs/tags/v2.51.4.tar.gz
[root@fedora ~]# tar -zvxf v2.51.4.tar.gz -C /usr/local/src/
[root@fedora ~]# cd /usr/local/src/unison-2.51.4/
[root@fedora /usr/local/src/unison-2.51.4]# make UISTYLE=txt
...
[root@fedora /usr/local/src/unison-2.51.4]# ls src/unison
src/unison
[root@fedora /usr/local/src/unison-2.51.4]# cp -p src/unison /usr/local/bin
```


## Dimostrazione

**Il nostro requisito è la directory /dir1/ di Rocky Linux 8 che viene automaticamente sincronizzata nella directory /dir2/ di Fedora 34; allo stesso tempo, la directory /dir2/ di Fedora 34 viene automaticamente sincronizzata con la directory /dir1/ di Rocky Linux 8**

### Configurare Rocky Linux 8

```bash
[root@Rocky ~]# mkdir /dir1
[root@Rocky ~]# setfacl -m u:testrsync:rwx /dir1/
[root@Rocky ~]# vim /root/unison1.sh
#!/bin/bash
a="/usr/local/inotify-tools/bin/inotifywait -mrq -e create,delete,modify,move /dir1/"
b="/usr/local/bin/unison -batch /dir1/ ssh://testrsync@192.168.100.5//dir2"
$a | while read directory event file
do
    $b &>> /tmp/unison1.log
done
[root@Rocky ~]# chmod +x /root/unison1.sh
[root@Rocky ~]# bash /root/unison1.sh &
[root@Rocky ~]# jobs -l
```

### Configurare Fedora 34

```bash
[root@fedora ~]# mkdir /dir2
[root@fedora ~]# setfacl -m u:testrsync:rwx /dir2/
[root@fedora ~]# vim /root/unison2.sh
#!/bin/bash
a="/usr/local/inotify-tools/bin/inotifywait -mrq -e create,delete,modify,move /dir2/"
b="/usr/local/bin/unison -batch /dir2/ ssh://testrsync@192.168.100.4//dir1"
$a | while read directory event file
do
    $b &>> /tmp/unison2.log
done
[root@fedora ~]# chmod +x /root/unison2.sh
[root@fedora ~]# bash /root/unison2.sh &
[root@fedora ~]# jobs -l
```

!!! tip "Suggerimento!"

    Per la sincronizzazione bidirezionale, gli script di entrambe le macchine devono essere avviati, altrimenti verrà segnalato un errore.

!!! tip "Suggerimento!"

    Se vuoi avviare questo script all'avvio
    `[root@Rocky ~]# echo "bash /root/unison1. h &" >> /etc/rc.local`
    `[root@Rocky ~]# chmod +x /etc/rc.local`

!!! tip "Suggerimento!"

    Se vuoi interrompere il processo corrispondente di questo script, puoi trovarlo con il comando `htop` e quindi **kill**
