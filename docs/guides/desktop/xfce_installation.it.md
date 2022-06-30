# Ambiente desktop XFCE

L'ambiente desktop XFCE è stato creato come fork del Common Desktop Environment (CDE). Xfce incarna la tradizionale filosofia Unix di Modularità e Riutilizzabilità. XFCE può essere installato su quasi tutte le versioni di Linux, compresa Rocky Linux.

Questa procedura è stata ideata per farvi iniziare a lavorare con Rocky Linux utilizzando XFCE.

## Prerequisiti

* Una Workstation o un Server, preferibilmente con Rocky Linux già installato.
* Dovete essere nell'ambiente Root o digitare `sudo` prima di tutti i comandi che inserite.

## Installare Rocky Linux Minimal

Durante l'installazione di Rocky Linux, abbiamo utilizzato i seguenti pacchetti:

* Minimal
* Standard

## Esegui l'Aggiornamento del Sistema

Per prima cosa, eseguire il comando di aggiornamento del server per consentire al sistema di ricostruire la cache del repository, in modo da riconoscere i pacchetti disponibili.

`dnf update`

## Abilitazione dei repository

Abbiamo bisogno per funzionare sulle versioni Rocky 8.x, del repository non ufficiale per XFCE in EPEL.

Abilitare questo repository inserendo:

`dnf install epel-release`

E rispondere "Y" per installare EPEL.

Sono necessari anche i repository Powertools e lightdm. Procedere con l'abilitazione di questi elementi:

`dnf config-manager --set-enabled powertools`

`dnf copr enable stenstorp/lightdm`

!!! Warning "Attenzione"

    Il sistema di compilazione `copr` crea un repository che è noto per funzionare per l'installazione di `lightdm`, ma non è mantenuto dalla comunità Rocky Linux. Utilizzare a proprio rischio e pericolo!

Anche in questo caso, verrà presentato un messaggio di avvertimento sul repository. Rispondete pure a `Y` alla domanda.

## Controllare gli Ambienti Disponibili e gli Strumenti nel Gruppo

Ora che i repository sono abilitati, eseguire i seguenti comandi per verificare il tutto.

Per prima cosa, controllare l'elenco dei repository con:

`dnf repolist`

Si dovrebbe ottenere il seguente risultato che mostra tutti i repository abilitati:

```
appstream                                                        Rocky Linux 8 - AppStream
baseos                                                           Rocky Linux 8 - BaseOS
copr:copr.fedorainfracloud.org:stenstorp:lightdm                 Copr repo for lightdm owned by stenstorp
epel                                                             Extra Packages for Enterprise Linux 8 - x86_64
epel-modular                                                     Extra Packages for Enterprise Linux Modular 8 - x86_64
extras                                                           Rocky Linux 8 - Extras
powertools                                                       Rocky Linux 8 - PowerTools
```

Eseguire quindi il seguente comando per verificare la presenza di XFCE:

`dnf grouplist`

Dovreste vedere "Xfce" in fondo all'elenco.

Eseguire ancora una volta `dnf update` per assicurarsi che tutti i repository abilitati siano letti dal sistema.

## Installazione dei Pacchetti

Per installare XFCE, eseguire:

`dnf groupinstall "xfce"`

Installare anche lightdm:

`dnf install lightdm`

## Fasi finali

Dobbiamo disabilitare `gdm`, che viene aggiunto e abilitato durante *dnf groupinstall "xfce"*:

`systemctl disable gdm`

Ora possiamo abilitare *lightdm*:

`systemctl enable lightdm`

Dobbiamo dire al sistema, dopo l'avvio, di usare solo l'interfaccia grafica, quindi dobbiamo impostare il sistema di destinazione predefinito sull'interfaccia GUI:

`systemctl set-default graphical.target`

Quindi riavviare:

`reboot`

Dovrebbe apparire un prompt di login nella GUI di XFCE e, una volta effettuato il login, si avrà a disposizione tutto l'ambiente XFCE.

## Conclusione

XFCE è un ambiente leggero con un'interfaccia semplice per coloro che non amano gli effetti grafici e la pesantezza. Questa guida sarà presto aggiornata con immagini, che mostreranno schermate per dare un esempio visivo dell'installazione.
