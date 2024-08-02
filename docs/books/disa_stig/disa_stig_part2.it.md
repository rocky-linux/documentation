---
title: Verifica della conformità DISA STIG con OpenSCAP - Parte 2
author: Scott Shinn
contributors: Steven Spencer, Franco Colussi
tested_with: 8.6
tags:
  - DISA
  - STIG
  - security
  - enterprise
---

# Introduzione

Nell'ultimo articolo abbiamo configurato un nuovo sistema rocky linux 8 con lo stig DISA applicato utilizzando [OpenSCAP](https://www.openscap.org). Ora ci occuperemo di come testare il sistema usando gli stessi strumenti e di quali tipi di rapporti possiamo generare usando gli strumenti oscap e la sua controparte UI SCAP Workbench.

Rocky Linux 8 (e 9!) include una suite di contenuti [SCAP](https://csrc.nist.gov/projects/security-content-automation-protocol) per verificare e correggere la conformità a vari standard. Se avete costruito un sistema STIG nella prima parte, lo avete già visto in azione. Il programma di installazione di anaconda ha sfruttato questo contenuto per modificare la configurazione di rocky 8 per implementare vari controlli, installare/rimuovere pacchetti e cambiare il modo in cui funzionano i punti di mount a livello di sistema operativo.

Nel corso del tempo, questi aspetti potrebbero cambiare e sarà opportuno tenerli sotto controllo. Spesso utilizzo questi rapporti anche per dimostrare che un determinato controllo è stato implementato correttamente. In ogni caso, Rocky ne è dotato. Inizieremo con alcune nozioni di base.

## Elenco dei Profili di Sicurezza

Per elencare i profili di sicurezza disponibili, è necessario utilizzare il comando `oscap info` fornito dal pacchetto `openscap-scanner`. Questo dovrebbe essere già installato nel vostro sistema, se avete seguito la procedura dalla prima parte.  Per ottenere i profili di sicurezza disponibili:

```bash
oscap info /usr/share/xml/scap/ssg/content/ssg-rl8-ds.xml
```

!!! note "Nota"

    Il contenuto di Rocky linux 8 utilizzerà il tag "rl8" nel nome del file. In Rocky 9, sarà "rl9".

Se tutto va bene, si dovrebbe ricevere una schermata simile a questa:

![Profili di Sicurezza](images/disa_stig_pt2_img1.jpg)

DISA è solo uno dei tanti profili di sicurezza supportati dalle definizioni SCAP di Rocky Linux. Abbiamo anche profili per:

* [ANSSI](https://cyber.gouv.fr/en)
* [CIS](https://cisecurity.org)
* [Australian Cyber Security Center](https://cyber.gov.au)
* [NIST-800-171](https://csrc.nist.gov/publications/detail/sp/800-171/rev-2/final)
* [HIPAA](https://www.hhs.gov/hipaa/for-professionals/security/laws-regulations/index.html)
* [PCI-DSS](https://www.pcisecuritystandards.org/)

## Verifica della conformità DISA STIG

Qui è possibile scegliere tra due tipi:

* stig - Senza interfaccia grafica
* stig_gui - Con una GUI

Eseguire una scansione e creare un rapporto HTML per il DISA STIG:

```bash
sudo oscap xccdf eval --report unit-test-disa-scan.html --profile stig /usr/share/xml/scap/ssg/content/ssg-rl8-ds.xml
```

Il risultato sarà un rapporto come questo:

![Risultati della scansione](images/disa_stig_pt2_img2.jpg)

E produrrà un rapporto HTML:

![Rapporto HTML](images/disa_stig_pt2_img3.jpg)

## Generazione di script Bash di Riparazione

Successivamente, genereremo una scansione e useremo i risultati della scansione per generare uno script bash per rimediare al sistema in base al profilo DISA stig. Non consiglio di utilizzare la riparazione automatica, è sempre necessario rivedere le modifiche prima di eseguirle.

1) Generare una scansione del sistema:

    ```bash
    sudo oscap xccdf eval --results disa-stig-scan.xml --profile stig /usr/share/xml/scap/ssg/content/ssg-rl8-ds.xml
    ```

2) Utilizzare l'output della scansione per generare lo script:

    ```bash
    sudo oscap xccdf generate fix --output draft-disa-remediate.sh --profile stig disa-stig-scan.xml
    ```

Lo script risultante includerà tutte le modifiche da apportare al sistema.

!!! warning "Attenzione"

    Esaminate questo documento prima di eseguirlo! Apporterà modifiche significative al sistema.

![Contenuto dello Script](images/disa_stig_pt2_img4.jpg)

## Generazione dei Playbook Ansible di Riparazione

È anche possibile generare azioni di rimedio in formato playbook ansible. Ripetiamo la sezione precedente, ma questa volta con l'output di Ansible:

1) Generare una scansione del sistema:

    ```bash
    sudo oscap xccdf eval --results disa-stig-scan.xml --profile stig /usr/share/xml/scap/ssg/content/ssg-rl8-ds.xml
    ```

2) Utilizzare l'output della scansione per generare lo script:

    ```bash
    sudo oscap xccdf generate fix --fix-type ansible --output draft-disa-remediate.yml --profile stig disa-stig-scan.xml
    ```

!!! warning "Attenzione"

    Anche in questo caso, rivedetelo prima di eseguirlo! Percepite uno schema? Questa fase di verifica di tutte le procedure è molto importante!

![Playbook Ansible](images/disa_stig_pt2_img5.jpg)

## Informazioni sull'Autore

Scott Shinn è il CTO di Atomicorp e fa parte del team Rocky Linux Security. Dal 1995 si occupa di sistemi informativi federali presso casa Bianca, del Dipartimento della Difesa e dell'Intelligence Community dal 1995. Parte di questo è stata la creazione degli STIG e l'obbligo di usarli e mi dispiace molto per questo.
