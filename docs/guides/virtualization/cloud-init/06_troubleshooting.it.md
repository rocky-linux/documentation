---
title: 6. Troubleshooting cloud-init
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - cloud-init
  - rocky linux
  - cloud
  - automation
  - troubleshooting
---

## Troubleshooting cloud-init

In qualsiasi sistema complesso e automatizzato, prima o poi qualcosa andrà storto. Quando una configurazione `cloud-init` fallisce, sapere come diagnosticare sistematicamente il problema è una competenza essenziale. Questo capitolo è una guida all'analisi forense di `cloud-init` e tratta sia le tecniche di risoluzione dei problemi in guest che quelle in host.

## 1. Toolkit per il troubleshooting in-guest

Quando è possibile accedere a un'istanza in esecuzione, `cloud-init` fornisce diversi comandi e registri per mostrare cosa è successo.

### Punto 1: Il comando status (`cloud-init status`)

Questo è il tuo primo punto di riferimento. Fornisce un riepilogo di alto livello dello stato di `cloud-init`.

- **Verifica il completamento di `cloud-init`:** `cloud-init status`
  (Se l'esecuzione ha avuto esito positivo, verrà visualizzato `status: done`)

- _Attendere il completamento di `cloud-init`:_\* `cloud-init status --wait`
  (Questo è utile negli script per mettere in pausa l'esecuzione fino al completamento di `cloud-init`)

### Punto 2: Il log principale (`/var/log/cloud-init.log`)

Questo file è la principale fonte di verità: una registrazione dettagliata e cronologica di ogni fase e modulo. Quando si ha bisogno di sapere _esattamente_ cosa è successo, guardare qui. Cercando in questo file `ERROR` o `WARNING` spesso si arriva direttamente al problema.

### Pilastro 3: Il log di output (`/var/log/cloud-init-output.log`)

Questo log registra l'intero `stdout` e `stderr` di tutti gli script eseguiti da `cloud-init` (ad esempio, da `runcmd`). Se un modulo è stato eseguito ma lo script al suo interno non ha funzionato, il messaggio di errore sarà presente in questo file.

**Hands-on: debug di un comando `runcmd` non funzionante**

1. Creare un file `user-data.yml` con un comando `runcmd` che contiene un errore nascosto:

    ```bash
    cat <<EOF > user-data.yml
    #cloud-config
    runcmd:
      - [ ls, /non-existent-dir ]
    EOF
    ```

2. Avviare una VM con questi dati. `cloud-init status` riporterà `status: done` perché il modulo `runcmd` stesso è stato eseguito correttamente.

3. Tuttavia, `/var/log/cloud-init-output.log` conterrà l'errore effettivo del comando `ls`, mostrando cosa non ha funzionato:

    ```
    ls: cannot access '/non-existent-dir': No such file or directory
    ```

## 2) Troubleshooting lato host con `libguestfs-tools`

A volte, una VM non riesce ad avviarsi completamente, rendendo inutili gli strumenti in-guest. In questi casi, è possibile diagnosticare i problemi ispezionando l'immagine del disco della VM direttamente dall'host utilizzando la potente suite `libguestfs-tools` (installabile con `sudo dnf install libguestfs-tools`).

### `virt-cat`: Lettura dei file da un disco guest

`virt-cat` consente la lettura dei file dall'interno dell'immagine disco di una VM senza montarla. Questo è perfetto per recuperare i file di log da un'istanza che non si avvia.

```bash
# Dal host, leggere il file cloud-init.log dal disco della VM.
sudo virt-cat -a /path/to/your-vm-disk.qcow2 /var/log/cloud-init.log
```

### `virt-inspector`: Ispezione approfondita del sistema

`virt-inspector` genera un report XML dettagliato del sistema operativo, delle applicazioni e della configurazione di una macchina virtuale. Questo è incredibilmente potente per l'analisi automatizzata.

- **Ottienere un rapporto completo:**

    ```bash
    sudo virt-inspector -a your-vm-disk.qcow2 > report.xml
    ```

- **Eseguire una query mirata:** È possibile convogliare il file XML a `xmllint` per estrarre informazioni specifiche. Questo esempio verifica la versione installata di `cloud-init` all'interno dell'immagine:

    ```bash
    sudo virt-inspector -a your-vm-disk.qcow2 | xmllint --xpath "//application[name='cloud-init']/version/text()" -
    ```

## 3. Errori comuni e come evitarli

### Errore 1: Errori YAML e di schema

I YAML non validi sono la causa più comune di errori. Un problema più complesso è rappresentato da un file YAML sintatticamente valido che viola la struttura prevista da `cloud-init` (ad esempio, un errore di battitura nel nome di un modulo).

- **Soluzione:** Utilizza il comando `cloud-init schema` per convalidare la configurazione _prima_ dell'avvio. Rileverà sia gli errori YAML che quelli strutturali.

    ```bash
    # Convalidate il vostro file di user-data rispetto allo schema ufficiale
    cloud-init schema --config-file user-data.yml
    ```

  Se il file è valido, verrà visualizzato il messaggio “Valid cloud-config: user-data.yml”. In caso contrario, fornirà errori dettagliati.

### Errore 2: moduli dipendenti dalla rete non funzionanti

Se non si riesce a connettere alla rete, moduli come `packages` non funzioneranno. Controllare la configurazione di rete e la fase `Network` in `/var/log/cloud-init.log`.

## 4. Controllo dell'esecuzione di `cloud-init`

- **Forzare una riesecuzione:** per testare le modifiche su una VM in esecuzione, eseguire `sudo cloud-init clean --logs` seguito da `sudo reboot`.
- **Disabilitazione di `cloud-init`:** per impedire l'esecuzione di `cloud-init` agli avvii successivi, creare un file sentinella: `sudo touch /etc/cloud/cloud-init.disabled`.
- **Eseguire ad ogni avvio (`bootcmd`):** Utilizzare il modulo `bootcmd` per gli script che devono essere eseguiti ad ogni singolo avvio. Questo è raro ma utile per alcune diagnosi.

## Il passo successivo

Ora si dispone di una potente serie di strumenti per la risoluzione dei problemi sia sul lato ospite che sul lato host. Nel capitolo finale esamineremo il progetto `cloud-init` stesso, preparandovi ad esplorarne il codice sorgente e a contribuire alla comunity.
