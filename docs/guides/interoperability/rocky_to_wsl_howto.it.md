---
title: Importare in WSL con WSL e rinse
---

# Importazione di Rocky Linux in WSL con WSL e rinse

## Prerequisiti
* Un PC Windows 10 con WSL 2 abilitato. (*vedi nota sotto).
* Ubuntu, o qualsiasi distribuzione basata su Debian, installata e funzionante su WSL. Questa guida è stata testata utilizzando Ubuntu 20.04 LTS dal negozio Microsoft.

## Introduzione
Questa guida è destinata agli utenti Windows che desiderano eseguire Rocky Linux (RL) nel sottosistema Windows per Linux (WSL). Si presuppone che il lettore abbia familiarità con la riga di comando e che WSL sia abilitato e in esecuzione nel proprio PC Windows 10.

Il processo utilizza `rinse`, uno script perl per creare immagini di distribuzioni che utilizzano il gestore di pacchetti YUM.

Tenete presente che WSL ha limitazioni e stranezze significative e che la distribuzione risultante può o non può funzionare come ci si aspetta. Potrebbe essere troppo lento o imprevedibile per alcune applicazioni. Con i computer, come nella vita, non ci sono garanzie.

## Passi

1. Avviate la vostra distribuzione Ubuntu in WSL, aggiornate il gestore dei pacchetti e installate `rinse`<br/>
```bash
$ sudo apt-get update
$ sudo apt-get install rinse
```
`rinse` non è a conoscenza di RL, quindi dobbiamo modificare la sua configurazione per aggiungere i repository dei pacchetti e così via.

2. Copiare il file dei pacchetti di CentOS 8 e prepararlo per RL
```bash
$ sudo cp -p /etc/rinse/centos-8.packages /etc/rinse/rocky-8.packages
```
3. Modificare il nuovo file e cambiare tutte le voci di 'centos' in 'rocky'. Quindi, aggiungere le seguenti righe. L'ordine nel file non è importante, le voci possono essere aggiunte ovunque. Qui è possibile aggiungere qualsiasi altro pacchetto che si voglia avere nell'immagine (server, utility come `which`, ecc.)
```bash
glibc-langpack-en
libmodulemd
libzstd
passwd
sudo
cracklib-dicts
openssh-clients
python3-dbus
dbus-glib
```
4. Modificare il file di configurazione di `rinse` in `/etc/rinse/rinse.conf` e aggiungere le seguenti righe, che sono la voce per i mirror RL. Al momento abbiamo un download diretto, ma sarà sostituito da un mirror non appena disponibile.
```bash
# Rocky Linux 8
[rocky-8]
mirror.amd64 = http://dl.rockylinux.org/pub/rocky/8/BaseOS/x86_64/os/Packages/
```
5. Copiare lo script post-installazione per CentOS in modo da poterlo modificare per RL
```bash
$ sudo cp -pR /usr/lib/rinse/centos-8 /usr/lib/rinse/rocky-8
```
6. Modificare `/usr/lib/rinse/rocky-8/post-install.sh` e aggiungere le seguenti linee alla riga 14. È necessario assicurarsi che TLS/SSL funzioni come previsto per *YUM* e *dnf*.
```bash
echo "  Extracting CA certs..."
$CH /usr/bin/update-ca-trust
```
7. Modificare lo script `rinse` in `/usr/sbin/rinse` e alla riga 1248 rimuovere il testo `--extract-over-symlinks`. Questa opzione è stata deprecata nel programma chiamato e interrompe lo script. Non chiudere ancora il file.
8. Nello stesso file, andare alla riga 1249 e sostituire "centos" con "rocky". Salvare e chiudere il file.
9. Creare una directory per il nuovo filesystem RL (qualsiasi nome va bene).
```bash
$ mkdir rocky_rc
```
10. Eseguire `rinse` con il seguente comando
```bash
$ sudo rinse --arch amd64 --directory ./rocky_rc --distribution rocky-8
```
11. Dopo che lo script ha completato il download e l'estrazione di tutti i pacchetti, si avrà un file system Rocky Linux completo nella directory creata. Ora è il momento di impacchettarlo per passarlo a Windows e importarlo in una nuova distro WSL. Usare questo comando, creando il file tar in una cartella di Windows (iniziando con `/mnt/c/` o simile per averlo a disposizione per il passaggio successivo).
```bash
$ sudo tar --numeric-owner -c -C ./rocky_rc . -f <path to new tar file>
```
12. Chiudere la sessione WSL con Ctrl+D o digitando `exit`.
13. Aprire un prompt di PowerShell (non è necessario essere amministratori) e creare una cartella per contenere la nuova distro RL.
14. Importare il file tar con questo comando:
```PowerShell
wsl --import rocky_rc <path to folder from step 9> <path to tar file>
```
Nota: il percorso predefinito di WSL è `%LOCALAPPDATA%`\Packages\`ad esempio per Ubuntu - C:\Users\tahder\AppData\Local\Packages\CanonicalGroupLimited.UbuntuonWindows_79rhks2fndhsd\LocalState\rootfs\home\txunil\rocky_rc``

15. Nel prompt di PowerShell, avviare la nuova distro con:
```PowerShell
wsl -d rocky_rc
```
16. Ora siete root nella vostra nuova distro RL. Eseguite questi comandi per completare la configurazione:
```bash
yum update
yum reinstall passwd sudo cracklib-dicts -y
newUsername=<your new username>
adduser -G wheel $newUsername
echo -e "[user]\ndefault=$newUsername" >> /etc/wsl.conf
passwd $newUsername
```
17. Uscire dal prompt di bash (Ctrl+D o digitare `exit`).
18. Tornando a PowerShell, spegnete WSL e rilanciate la nuova distro.
```PowerShell
wsl --shutdown
wsl -d rocky_rc
```
19. Provate e divertitevi!

## Pulizia
Tutti i pacchetti scaricati sono ancora memorizzati nella distro debian utilizzata all'inizio del processo. È possibile rimuovere i file da `/var/cache/rinse` e cancellare tutti i file dalla cartella `rocky_rc`. La prossima volta che si vuole creare un'immagine nuova, aggiornata o modificata, è sufficiente apportare le modifiche ed eseguire i comandi dal punto 10 in poi.

## Problemi noti
Ci sono alcune stranezze che derivano dall'estrazione dei pacchetti, anziché dalla loro installazione. L'esecuzione di `yum reinstall` in alcuni pacchetti risolve i problemi, come nel caso di `passwd`. Lo script `rinse` si limita a estrarre i pacchetti e non esegue comandi post-installazione (anche se è in grado di farlo). Se incontrate dei problemi e sapete come risolverli, lasciate dei commenti per gli altri utenti, in modo che altri possano trarre vantaggio dalla vostra esperienza.

## Note
La maggior parte dello script `rinse` funziona sotto WSL 1, ma l'ultima parte, quella in cui viene invocato `dnf`, ha problemi di memoria e corrompe il database `rpm`. Questo rovina la distro e i tentativi di riparazione falliscono, anche con WSL. Se sapete come far funzionare `dnf` sotto WSL 1, fatecelo sapere, ma ci sono molti problemi di BDB relativi a WSL 1 su diversi forum sul web. WSL 2 ha risolto questi problemi con il kernel Linux nativo.
