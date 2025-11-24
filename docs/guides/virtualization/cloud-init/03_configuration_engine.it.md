---
title: 3. Il motore di configurazione
author: Wale Soyinka
contributors: Steven Spencer
tags:
  - cloud-init
  - rocky linux
  - cloud-init modules
  - automation
---

## Approfondimento sui moduli cloud-init

Nell'ultimo capitolo, si è avviato con successo un'immagine cloud e si è eseguito una semplice personalizzazione. Sebbene efficace, il vero potere, la portabilità e l'idempotenza di `cloud-init` si sbloccano attraverso il suo sistema di moduli. Questi moduli sono strumenti specializzati del toolkit `cloud-init`, progettati per gestire attività di configurazione specifiche in modo dichiarativo e prevedibile.

Questo capitolo approfondisce il sistema dei moduli, spiegando cosa sono, come funzionano e come utilizzare quelli più essenziali per costruire un server ben configurato.

## 1. L'anatomia della configurazione

### Cosa sono i moduli cloud-init

Un modulo `cloud-init` è uno script Python specializzato progettato per gestire una singola attività di provisioning discreta. Considerarli come plugin per attività quali la gestione degli utenti, l'installazione di pacchetti o la scrittura di file.

Il vantaggio principale dell'utilizzo dei moduli rispetto ai semplici script (come `runcmd`) è l'**idempotenza**. Un'operazione idempotente produce lo stesso risultato sia che venga eseguita una volta o dieci volte. Quando dichiari che un utente dovrebbe esistere, il modulo garantisce che tale condizione sia soddisfatta: creerà l'utente se non esiste, ma non farà nulla se esiste già. Questo rende le tue configurazioni affidabili e ripetibili.

### Il formato `#cloud-config` rivisitato

Quando `cloud-init` rileva l'intestazione `#cloud-config`, interpreta il file come un insieme di istruzioni in formato YAML: le chiavi di primo livello in questo file YAML corrispondono direttamente ai moduli `cloud-init`.

### Esecuzione e ordine dei moduli

I moduli vengono eseguiti in fasi specifiche del processo di avvio in una sequenza definita in `/etc/cloud/cloud.cfg`. Una visione semplificata di questo flusso è la seguente:

```
System Boot
    |
    +--- Stage: Generator (Very early boot)
    |    `--- cloud_init_modules (e.g., migrator)
    |
    +--- Stage: Local (Pre-network)
    |    `--- (Modules for local device setup)
    |
    +--- Stage: Network (Network is up)
    |    `--- cloud_config_modules (e.g., users-groups, packages, write_files)
    |
    `--- Stage: Final (Late boot)
         `--- cloud_final_modules (e.g., runcmd, scripts-user)
```

L'ordine è fondamentale. Ad esempio, il modulo `users-groups` viene eseguito prima di `runcmd`, garantendo che uno script possa essere eseguito da un utente appena creato nella stessa configurazione.

!!! tip "Personalizzazione del comportamento di `cloud-init`"

    Sebbene il file `/etc/cloud/cloud.cfg` definisca il comportamento predefinito, non si dovrebbe mai modificarlo direttamente. Per personalizzazioni permanenti a livello di sistema, inserire i vostri file `.cfg` nella directory `/etc/cloud/cloud.cfg.d/`. Questa è la pratica standard per la creazione di immagini personalizzate, che approfondiremo in un capitolo successivo.

## 2. Moduli ad alta utilità: i drivers quotidiani

Mettiamoci all'opera con i moduli più comuni utilizzando il metodo di iniezione diretta con `virt-install`.

### Approfondimento sul modulo: `users` e `groups`

Una corretta gestione degli account utente è fondamentale per garantire la sicurezza di una nuova istanza server. Il modulo `users` è lo strumento principale per farlo, che ti permette di creare nuovi utenti, modificare quelli esistenti, gestire le appartenenze ai gruppi e, soprattutto, inserire chiavi SSH per facilitare accessi sicuri e senza password fin dal primo avvio.

**Esempio 1: Creazione di un nuovo utente amministratore**

In questo esempio, provvederemo a fornire un nuovo utente amministratore dedicato denominato `sysadmin`. Concederemo a questo utente funzionalità `sudo` senza password aggiungendolo al gruppo `wheel` e fornendo una regola `sudo` specifica. Inseriremo anche una chiave pubblica SSH per garantire un accesso sicuro.

1. **Creare `user-data.yml`:**

    ```bash
    cat <<EOF > user-data.yml
    #cloud-config
    users:
      - name: sysadmin
        groups: [ wheel ]
        sudo: [ "ALL=(ALL) NOPASSWD:ALL" ]
        shell: /bin/bash
        ssh_authorized_keys:
          - <YOUR_SSH_PUBLIC_KEY_HERE>
    EOF
    ```

2. **Spiegazione delle direttive chiave:**

   - `name`: Il nome utente per il nuovo account.
   - `gruppi`: un elenco di gruppi a cui aggiungere l'utente. Su Rocky Linux, l'appartenenza al gruppo `wheel` è comunemente utilizzata per concedere diritti amministrativi.
   - `sudo`: un elenco di regole `sudoers` da applicare. La regola `ALL=(ALL) NOPASSWD:ALL` consente all'utente di eseguire qualsiasi comando con `sudo` senza richiedere la password.
   - `ssh_authorized_keys`: un elenco di chiavi SSH pubbliche da aggiungere al file `~/.ssh/authorized_keys` dell'utente.

3. **Avvio e verifica:** avvia la VM con questi `user-data`. Si dovrebbe essere in grado di eseguire SSH come `sysadmin` ed eseguire comandi `sudo`.

**Esempio 2: Modifica dell'utente predefinito**

Un'operazione più comune consiste semplicemente nel proteggere l'utente predefinito fornito con l'immagine cloud (`rocky`). Qui modificheremo questo utente per aggiungere la nostra chiave SSH.

1. **Creare `user-data.yml`:**

    ```bash
    cat <<EOF > user-data.yml
    #cloud-config
    users:
      - default
      - name: rocky
        ssh_authorized_keys:
          - <YOUR_SSH_PUBLIC_KEY_HERE>
    EOF
    ```

2. **Spiegazione delle direttive chiave:**

   - `default`: questa voce speciale indica a `cloud-init` di eseguire prima la configurazione utente predefinita.
   - `name: rocky`: Specificando il nome di un utente esistente, il modulo modificherà quell'utente invece di crearne uno nuovo. Qui, unisce la chiave SSH fornita all'account dell'utente `rocky`.

3. **Avvio e verifica:** avviare la VM. Ora è possibile eseguire SSH come utente `rocky` senza password.

### Approfondimento sul modulo: `packages`

Il modulo `packages` offre un modo dichiarativo per gestire il software sulla vostra istanza, assicurando l'installazione di applicazioni specifiche all'avvio.

In questo esempio, provvederemo all'installazione di due strumenti utili, `nginx` (un server web ad alte prestazioni) e `htop` (un visualizzatore di processi interattivo). Inoltre, istruiremo `cloud-init` ad aggiornare prima i metadati del repository dei pacchetti per garantire che possa trovare le versioni più recenti.

1. **Creare `user-data.yml`:**

    ```bash
    cat <<EOF > user-data.yml
    #cloud-config
    package_update: true
    packages:
      - nginx
      - htop
    EOF
    ```

2. **Spiegazione delle direttive chiave:**

   - `package_update: true`: indica al gestore dei pacchetti di aggiornare i propri metadati locali. Su Rocky Linux, ciò equivale a eseguire `dnf check-update`.
   - `packages`: un elenco dei nomi dei pacchetti da installare.

3. **Avvio e verifica:** dopo l'avvio, eseguire l'accesso SSH e verificare l'installazione di `nginx` con `rpm -q nginx`.

!!! note "Idempotenza in azione"

    Se si dovesse riavviare questa VM con gli stessi `user-data`, il modulo `packages` vedrebbe che `nginx` e `htop` sono già installati e non farebbe nulla. Ciò garantisce lo stato desiderato (i pacchetti sono presenti) senza intraprendere azioni inutili. Questa è l'idempotenza.

### Approfondimento sul modulo: `write_files`

Questo modulo è incredibilmente versatile e consente di scrivere qualsiasi contenuto di testo su qualsiasi file presente nel sistema. È lo strumento perfetto per distribuire file di configurazione delle applicazioni, popolare contenuti web o creare script di supporto.

Per dimostrarne la potenza, useremo `write_files` per creare una homepage personalizzata per il server web `nginx` che installeremo nella stessa sessione.

1. **Creare `user-data.yml`:**

    ```bash
    cat <<EOF > user-data.yml
    #cloud-config
    packages: [nginx]
    write_files:
      - path: /usr/share/nginx/html/index.html
        content: '<h1>Hello from cloud-init!</h1>'
        owner: nginx:nginx
        permissions: '0644'
    runcmd:
      - [ systemctl, enable, --now, nginx ]
    EOF
    ```

2. **Spiegazione delle direttive chiave:**

   - `path`: Il percorso assoluto sul filesystem dove il file verrà scritto.
   - `content`: Il contenuto testuale da scrivere nel file.
   - `owner`: specifica l'utente e il gruppo che devono essere proprietari del file (ad esempio, `nginx:nginx`).
   - `permissions`: i permessi del file in formato ottale (ad esempio, `0644`).

3. **Avvio e verifica:** dopo l'avvio, accedi tramite SSH e utilizza `curl localhost` per visualizzare la nuova homepage.

!!! tip "Scrittura di file binari"

    Il modulo `write_files` non è limitato al testo. Specificando un `encoding`, è possibile distribuire file binari. Ad esempio, è possibile utilizzare `encoding: b64` per scrivere dati codificati in base64. Per casi d'uso avanzati, fare riferimento alla [documentazione ufficiale di `write_files`](https://cloudinit.readthedocs.io/en/latest/topics/modules.html#write-files).

## Prossimo passo

Ora si è appreso i tre moduli fondamentali di `cloud-init`. Combinandoli, è possibile eseguire una quantità significativa di configurazioni automatizzate del server. Nel prossimo capitolo affronteremo scenari più avanzati, tra cui la configurazione di rete e la combinazione di diversi formati di `dati utente` in un unico processo.
