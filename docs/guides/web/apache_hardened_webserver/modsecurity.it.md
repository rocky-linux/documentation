---
title: Application Firewall (WAF) basato sul Web
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.8, 9.2
tags:
  - web
  - security
  - apache
  - nginx
---
  
# Application Firewall (WAF) basato sul Web

## Prerequisiti

* Un server web Rocky Linux con Apache
* Conoscenza di un editor a riga di comando (in questo esempio si usa _vi_ )
* Un buon livello di confidenza con l'emissione di comandi dalla riga di comando, la visualizzazione dei log e altri compiti generali di amministratore di sistema
* La consapevolezza che l'installazione di questo strumento richiede anche il monitoraggio delle azioni e la messa a punto dell'ambiente
* L'utente root esegue tutti i comandi o un utente regolare con `sudo`

## Introduzione

`mod_security` è un firewall per applicazioni web-based (WAF) open source. È solo uno dei possibili elementi di una configurazione di server web Apache protetta. Utilizzatelo con o senza altri strumenti.

Se volete usare questo e altri strumenti di hardening, fate riferimento alla guida [Apache Hardened Web Server](index.md). Questo documento utilizza anche tutti i presupposti e le convenzioni delineati nel documento originale. È buona norma rivederlo prima di continuare.

Una cosa che manca a `mod_security` quando viene installato dai repository generici di Rocky Linux, è che le regole installate sono minime. Per ottenere un pacchetto più ampio di regole di `mod_security` a costo zero, questa procedura utilizza le regole [OWASP `mod_security` che si trovano qui](https://coreruleset.org/). OWASP è l'acronimo di Open Web Application Security Project. Per saperne [di più su OWASP, cliccate qui](https://owasp.org/).

!!! tip "Suggerimento"

    Come detto, questa procedura utilizza le regole OWASP `mod_security`. Ciò che non viene utilizzato è la configurazione fornita da quel sito. Questo sito fornisce anche ottimi tutorial sull'uso di `mod_security' e di altri strumenti legati alla sicurezza. Il documento che state elaborando con mow non fa altro che aiutarvi a installare gli strumenti e le regole necessarie per l'hardening con `mod_security' su un server web Rocky Linux. Netnea è un team di professionisti tecnici che offre corsi di sicurezza sul proprio sito web. La maggior parte di questi contenuti è disponibile gratuitamente, ma ci sono opzioni per la formazione interna o di gruppo.

## Installazione di `mod_security`

Per installare il pacchetto base, utilizzate questo comando. Installerà tutte le dipendenze mancanti. È necessario anche `wget`, se non è installato:

```bash
dnf install mod_security wget
```

## Installazione delle regole di `mod_security`

!!! note "Nota"

    È importante seguire attentamente questa procedura. La configurazione di Netnea è stata modificata per adattarla a Rocky Linux.

1. Per accedere alle regole attuali di OWASP, visitate [il sito GitHub](https://github.com/coreruleset/coreruleset).

2. Sul lato destro della pagina, cercate le release e fate clic sul tag dell'ultima release.

3. Nella sezione "Assets" della pagina successiva, fare clic con il tasto destro del mouse sul collegamento "Source Code (tar.gz)" e copiare il link.

4. Sul vostro server, andate nella directory di configurazione di Apache:

    ```bash
    cd /etc/httpd/conf
    ```

5. Inserite `wget` e incollate il vostro link. Esempio:

    ```bash
    wget https://github.com/coreruleset/coreruleset/archive/refs/tags/v3.3.5.tar.gz
    ```

6. Decomprimere il file:

    ```bash
    tar xzvf v3.3.5.tar.gz
    ```

    Questo crea una directory con le informazioni di rilascio nel nome. Esempio: "coreruleset-3.3.5"

7. Creare un collegamento simbolico chiamato "crs" che rimanda alla directory della release. Esempio:

    ```bash
    ln -s coreruleset-3.3.5/ /etc/httpd/conf/crs
    ```

8. Rimuovere il file `tar.gz`. Esempio:

    ```bash
    rm -f v3.3.5.tar.gz
    ```

9. Copiare la configurazione temporanea in modo che venga caricata all'avvio:

    ```bash
    cp crs/crs-setup.conf.example crs/crs-setup.conf
    ```

    Questo file è modificabile, ma probabilmente non sarà necessario apportare alcuna modifica.

Le regole di `mod_security` sono ora in vigore.

## Configurazione

Una volta definite le regole, il passo successivo consiste nel configurarle in modo che vengano caricate ed eseguite quando `httpd` e `mod_security` vengono eseguiti.

`mod_security` ha già un file di configurazione che si trova in `/etc/httpd/conf.d/mod_security.conf`. È necessario modificare questo file per includere le regole OWASP. Per farlo, modificare il file di configurazione:

```bash
vi /etc/httpd/conf.d/mod_security.conf
```

Aggiungere il seguente contenuto subito prima del tag finale`(</IfModule`):

```bash
    Include    /etc/httpd/conf/crs/crs-setup.conf

    SecAction "id:900110,phase:1,pass,nolog,\
        setvar:tx.inbound_anomaly_score_threshold=10000,\
        setvar:tx.outbound_anomaly_score_threshold=10000"

    SecAction "id:900000,phase:1,pass,nolog,\
         setvar:tx.paranoia_level=1"


    # === ModSec Core Rule Set: Runtime Exclusion Rules (ids: 10000-49999)

    # ...


    # === ModSecurity Core Rule Set Inclusion

    Include    /etc/httpd/conf/crs/rules/*.conf


    # === ModSec Core Rule Set: Startup Time Rules Exclusions

    # ...
```

Utilizzare ++esc++ per uscire dalla modalità di inserimento e ++shift+colon+"wq "++ per salvare le modifiche e uscire.

## Riavviare `httpd` e verificare `mod_security`

A questo punto è sufficiente riavviare `httpd`:

```bash
systemctl restart httpd
```

Verificare che il servizio sia stato avviato come previsto:

```bash
systemctl status httpd
```

Voci come questa in `/var/log/httpd/error_log` mostrano che `mod_security` si sta caricando correttamente:

```bash
[Thu Jun 08 20:31:50.259935 2023] [:notice] [pid 1971:tid 1971] ModSecurity: PCRE compiled version="8.44 "; loaded version="8.44 2020-02-12"
[Thu Jun 08 20:31:50.259936 2023] [:notice] [pid 1971:tid 1971] ModSecurity: LUA compiled version="Lua 5.4"
[Thu Jun 08 20:31:50.259937 2023] [:notice] [pid 1971:tid 1971] ModSecurity: YAJL compiled version="2.1.0"
[Thu Jun 08 20:31:50.259939 2023] [:notice] [pid 1971:tid 1971] ModSecurity: LIBXML compiled version="2.9.13"
```

Se si accede al sito web sul server, si dovrebbe ricevere una voce in `/var/log/httpd/modsec_audit.log` che mostra il caricamento delle regole OWASP:

```bash
Apache-Handler: proxy:unix:/run/php-fpm/www.sock|fcgi://localhost
Stopwatch: 1686249687051191 2023 (- - -)
Stopwatch2: 1686249687051191 2023; combined=697, p1=145, p2=458, p3=14, p4=45, p5=35, sr=22, sw=0, l=0, gc=0
Response-Body-Transformed: Dechunked
Producer: ModSecurity for Apache/2.9.6 (http://www.modsecurity.org/); OWASP_CRS/3.3.4.
Server: Apache/2.4.53 (Rocky Linux)
Engine-Mode: "ENABLED"
```

## Conclusione

`mod_security` con le regole OWASP è un altro strumento che aiuta a rendere più sicuro un server web Apache. Il controllo periodico del [sito GitHub per verificare la presenza di nuove regole](https://github.com/coreruleset/coreruleset) e dell'ultima release ufficiale è un'operazione di manutenzione continua da fare.

`mod_security`, come altri strumenti di hardening, ha un potenziale di risposte false positive, quindi bisogna prepararsi ad adattare questo strumento alla propria installazione.

Come altre soluzioni menzionate nella [guida Apache Hardened Web Server](index.md), esistono altre soluzioni gratuite e a pagamento per le regole di `mod_security` e per altre applicazioni WAF. È possibile esaminare uno di questi sul [sito `mod_security` di Atomicorp](https://atomicorp.com/atomic-modsecurity-rules/).
