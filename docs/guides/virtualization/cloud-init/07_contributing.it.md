---
title: 7. Contribuire
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - cloud-init
  - open source
  - development
  - python
---

## Contribuire al progetto cloud-init

Congratulazioni! Abbiamo affrontato i concetti fondamentali di `cloud-init` fino alle tecniche avanzate di provisioning e risoluzione dei problemi. Ora siete un utente esperto di `cloud-init`. Questo capitolo finale apre le porte alla fase successiva del tuo percorso: passare dall'essere un utente di `cloud-init` a un potenziale collaboratore.

`cloud-init` è un progetto open source fondamentale che prospera grazie ai contributi della comunità. Che si tratti di correggere un errore tipografico nella documentazione, segnalare un bug o scrivere un modulo completamente nuovo, ogni contributo è utile. Questo capitolo fornisce una panoramica di alto livello per comprendere il codice sorgente, creare un modulo personalizzato e interagire con la comunità upstream. Non è una guida completa per sviluppatori, ma piuttosto un'introduzione amichevole per iniziare a partecipare.

## 1. Il panorama del codice sorgente di `cloud-init`

Prima di poter contribuire, devi conoscere bene il progetto. Esploriamo il codice sorgente e configuriamo un ambiente di sviluppo di base.

### Il linguaggio e la repository

Scritto quasi interamente in **Python**, Canonical ospita il repository del codice sorgente `cloud-init` su **Launchpad**, ma per facilitare la collaborazione e offrire un'interfaccia più familiare, la maggior parte dei contributori interagisce con il suo mirror ufficiale su **GitHub**.

- **Canonical repository (Launchpad):** [https://git.launchpad.net/cloud-init](https://git.launchpad.net/cloud-init)

- **GitHub mirror:** [https://github.com/canonical/cloud-init](https://github.com/canonical/cloud-init)

Per ottenere il codice sorgente, è possibile clonare il repository GitHub:

```bash
# Clonare il codice sorgente sulla macchina locale
git clone https://github.com/canonical/cloud-init.git
cd cloud-init
```

### Configurare di un ambiente di sviluppo

Per lavorare sul codice senza influire sui pacchetti Python del sistema, è consigliabile utilizzare sempre un ambiente virtuale.

```bash
# Creare un ambiente virtuale Python
python3 -m venv .venv

# Attivare l'ambiente virtuale
source .venv/bin/activate

# Installare le dipendenze di sviluppo richieste
pip install -r requirements-dev.txt
```

### Una panoramica di alto livello sul codice sorgente

Navigare nel codice sorgente per la prima volta può essere scoraggiante. Ecco le directory più importanti:

- `cloudinit/`: questa è la directory principale dei sorgenti Python.
- `cloudinit/sources/`: questa directory contiene il codice per le **fonti dati** (ad esempio, `DataSourceNoCloud.py`). Ecco come `cloud-init` rileva e legge la configurazione da diverse piattaforme cloud.
- `cloudinit/config/`: qui risiedono i **moduli** (ad esempio, `cc_packages.py`, `cc_users_groups.py`). Il prefisso `cc_` è una convenzione per i moduli abilitati da `#cloud-config`. Questo è il percorso più comune per i contributi relativi alle nuove funzionalità.
- `doc/`: La documentazione ufficiale del progetto. Migliorare la documentazione è uno dei modi migliori per dare il tuo primo contributo.
- `tests/`: La suite di test completa per il progetto.

## 2. Scrivere un modulo personalizzato di base

Sebbene `runcmd` sia utile, scrivere un modulo personalizzato è il modo migliore per creare configurazioni riutilizzabili, portabili e idempotenti.

Creiamo il modulo più semplice possibile: uno che legga una chiave di configurazione da `user-data` e scriva un messaggio nel log `cloud-init`.

1. **Creare il file del modulo:** Creare un nuovo file denominato `cloudinit/config/cc_hello_world.py`.

    ```python
    # Nome file: cloudinit/config/cc_hello_world.py
    
    # Elenco delle frequenze e delle fasi di esecuzione di questo modulo
    frequency = “once-per-instance”
    distros = [“all”]
    
    def handle(name, cfg, cloud, log, args):
        # Ottieni una chiave “message” dalla configurazione dei dati utente.
        # Se non esiste, utilizzare un valore predefinito.
        message = cfg.get(“message”, “Ciao da un modulo personalizzato!”)
    
        # Scrivere il messaggio nel log principale di cloud-init.
        log.info(f“Il modulo Hello World dice: {message}”)
    ```

2. **Abilitare il modulo:** Creare il file non è sufficiente. È necessario indicare a `cloud-init` di eseguirlo. Creare un file in `/etc/cloud/cloud.cfg.d/99-my-modules.cfg` e aggiungere il nuovo modulo a uno degli elenchi di moduli:

    ```yaml
    # Aggiungere il nostro modulo personalizzato all'elenco dei moduli eseguiti durante la fase di configurazione
    cloud_config_modules:
      - hello_world
    ```

3. **Utilizzare il modulo:** Ora si può utilizzare il modulo personalizzato nel vostro `user-data`. La chiave di primo livello (`hello_world`) deve corrispondere al nome del modulo senza il prefisso `cc_`.

    ```yaml
    #cloud-config
    hello_world:
      message: "My first custom module is working!"
    ```

Dopo aver avviato una VM con questa configurazione, puoi controllare `/var/log/cloud-init.log` e troverai il tuo messaggio personalizzato, a dimostrazione che il tuo modulo ha funzionato.

## 3. Il workflow per contribuire

Il contributo a un progetto open source segue un workflow standard. Ecco una panoramica semplificata:

1. **Trova qualcosa su cui lavorare:** il punto di partenza migliore è l'issue tracker del progetto su Launchpad. Cerca bug o richieste di funzionalità. I nuovi arrivati sono incoraggiati a iniziare con correzioni alla documentazione o problemi contrassegnati come “low-hanging-fruit” (facili da risolvere) o “good first issue” (buoni primi problemi).

2. **Fork e branch:** creare una vostra copia (un “fork”) del repository `cloud-init` su GitHub. Quindi, creare un nuovo ramo per le vostre modifiche.

    ```bash
    git checkout -b my-documentation-fix
    ```

3. **Apportare le modifiche e conferma:** Apportare le modifiche al codice o alla documentazione. Quando si esegue il commit, si scriva un messaggio chiaro che descriva ciò che si è fatto. Il flag `-s` aggiunge una riga `Signed-off-by`, che certifica che si è scritto la patch o che si ha il diritto di contribuire ad essa.

    ```bash
    git commit -s -m “Doc: correzione di un errore tipografico nella documentazione del modulo utenti”
    ```

4. **Includere i test:** tutti i contributi significativi, in particolare le nuove funzionalità, devono includere i test. Esplorare la directory `tests/` per vedere come vengono testati i moduli esistenti.

5. **Invia una richiesta pull (PR):** invia il tuo ramo al tuo fork su GitHub e apri una richiesta pull al ramo `main` del repository `canonical/cloud-init`. Questa è la vostra richiesta formale per includere il vostro lavoro nel progetto.

6. **Partecipare alla revisione del codice:** i responsabili del progetto esamineranno la vostra richiesta di pull. Potrebbero porre domande o richiedere modifiche. Si tratta di un processo collaborativo. Interagire con il feedback è una parte fondamentale del contributo all'open source.

### Coinvolgimento della comunità

Per saperne di più, porre domande e interagire con la comunità, è possibile partecipare al canale `#cloud-init` sulla rete IRC OFTC o alla mailing list ufficiale.

## Un'ultima cosa

Congratulazioni per aver completato questa guida. Si è passati da utente principiante a utente esperto di `cloud-init` e ora avete una mappa che vi guiderà nel mondo del open source per contribuirvi. La comunità `cloud-init` è accogliente e apprezza i tuoi contributi, anche se piccoli. Happy building!
