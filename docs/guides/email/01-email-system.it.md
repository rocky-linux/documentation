---
title: Panoramica del sistema e-mail
author: tianci li
version: 1.0.0
---

# Panoramica del sistema di posta elettronica

La posta elettronica, uno dei tre servizi principali (FTP, Web ed e-mail) all'inizio di Internet, è ancora oggi utilizzata da molte persone. La posta elettronica è apparsa per la prima volta negli anni '60 e quella basata sulla trasmissione in rete nel 1971.

A differenza dei sistemi di posta elettronica delle aziende commerciali, la versione open-source del sistema di posta elettronica è composta da molte parti e non è un singolo servizio, il che porta anche a sistemi di posta elettronica più complessi in ambienti GNU/Linux.

## Il concetto di base del sistema di posta elettronica

Il sistema di posta elettronica si compone principalmente di quattro parti: **MUA**, **MTA**, **MRA** e **MDA**.

* **MUA (Mail User Agent)**: cioè i client di posta per gli utenti, come Outlook, Foxmail, ecc.
* **MTA (Mail Transfer Agent)**: Si riferisce a un programma di server di posta elettronica utilizzato per trasmettere la posta. L'MTA è l'implementazione di SMTP.
* **MDA (Mail Delivery Agent)**: Quando l'MTA riceve la posta, l'MDA è responsabile del salvataggio dell'e-mail nella posizione designata sul server di posta elettronica, eseguendo anche operazioni di filtraggio e antivirus.
* **MRA (Mail Retrieval Agent)**: l'MRA è un'implementazione di IMAP e POP3, utilizzata per interagire con MUA e trasmettere le e-mail ai client di posta elettronica tramite IMAP o POP3.

### Tre protocolli

* **SMTP (Simple Mail Transfer Protocol)**: il protocollo standard per l'invio di e-mail, con una porta predefinita "TCP 25". Quando è richiesta la funzione di crittografia, utilizzare la porta "TCP 465".
* **IMAP (Internet Mail Access Protocol)**: Utilizzata per ricevere le e-mail dal server di posta elettronica; la porta predefinita è la 143. Quando è richiesta la funzione di crittografia, utilizzare la porta 993.
* **POP3 (Post Office Protocol - Version 3)**: Utilizzata per ricevere le e-mail dal server di posta elettronica; la porta predefinita è la 110. Quando è richiesta la funzione di crittografia, utilizzare la porta 995.

La differenza tra IMAP e POP3 è la seguente:

| Posizione operativa |                                    Contenuti dell'operazione                                     |                                 IMAP                                  |            POP3             |
|:-------------------:|:------------------------------------------------------------------------------------------------:|:---------------------------------------------------------------------:|:---------------------------:|
|        Inbox        |              Lettura, etichettatura, trasferimento, eliminazione delle e-mail, ecc.              | Il client si sincronizza con gli aggiornamenti della cassetta postale | Solo all'interno del client |
|       Outbox        |                                   Salvare nella posta inviata                                    | Il client si sincronizza con gli aggiornamenti della cassetta postale | Solo all'interno del client |
|    create folder    |                             Creare una nuova cartella personalizzata                             | Il client si sincronizza con gli aggiornamenti della cassetta postale | Solo all'interno del client |
|        draft        |                                   Salvare la bozza dell'e-mail                                   | Il client si sincronizza con gli aggiornamenti della cassetta postale | Solo all'interno del client |
|     Junk folder     | Ricezione di e-mail che sono state erroneamente spostate nella cartella della posta indesiderata |                               supporto                                |       non supportato        |
|  Advertising email  |      Ricezione dei messaggi che sono stati spostati nella cartella della posta indesiderata      |                               supporto                                |       non supportato        |

### Realizzazione concreta

Come mostrato nell'immagine sottostante, si tratta di una semplice illustrazione dell'invio e della ricezione di un sistema di posta elettronica.

![Simple email system](./email-images/email-system01.jpg)

* **MTA**: In GNU/Linux, i principali e comuni MTA sono **postfix**,**qmail** and **sendmail**.
* **MDA**: In GNU/Linux, i principali e comuni MDA sono **procmail** e **maildrop**.
* **MRA**: In GNU/Linux, i principali e comuni MDA sono **dovecot**.

!!! question "Domanda"

    "Perché il DNS deve partecipare al lavoro del sistema di posta elettronica?"
    Nell'uso quotidiano, il formato standard per un utente di posta elettronica è "nomeutente@nomedominio". Un nome di dominio non può rappresentare un host specifico; è necessario puntare il nome di dominio a un nome di host specifico, quindi è necessario un record di risoluzione DNS MX.

## Postfix Il processo di invio e ricezione dei messaggi di posta elettronica

**Sendmail** è nato nel 1983 ed era installato di default nelle versioni precedenti a CentOS6. A causa di alcune ragioni storiche (come i complessi file di configurazione), lo sviluppo di sendmail è stato bloccato. Sebbene sendmail sia complesso, se si dispone di forti competenze tecniche o di una vasta esperienza, un sendmail ben regolato è eccellente in termini di efficienza e prestazioni.

**Postfix** è stato creato nel 1990 da Wietse Venema, un ricercatore olandese dell'IBM, per migliorare il server di posta sendmail.

![Wietse Venema](./email-images/Wietse%20Venema.png)

Per ulteriori informazioni su postfix, consultare questi due link:

* [GitHub repository](https://github.com/vdukhovni/postfix)
* [Sito web ufficiale](http://www.postfix.org/)

### Il processo di invio delle e-mail da parte del client

![legend01](./email-images/email-system02.jpg)

Postfix determina se un'e-mail inviata da un client appartiene al dominio locale o esterno. Se appartiene al dominio locale, l'e-mail verrà memorizzata nella casella di posta elettronica del dominio locale. Se l'e-mail inviata appartiene a un dominio esterno, viene inoltrata a un altro MTA (l'identità dell'utente deve essere verificata dal database prima dell'inoltro).

### Il processo di ricezione delle e-mail da parte del client

![legend02](./email-images/email-system03.jpg)

## Server e-mail open-source

Un sistema di posta elettronica completo è costituito da componenti decentralizzati e gestiti da persone o organizzazioni diverse, e le barriere all'uso per alcune persone sono elevate. Di conseguenza, alcuni server di posta elettronica open-source emergono man mano che i tempi lo richiedono; questi server di posta elettronica combinano questi componenti per creare un prodotto out-of-the-box, per gli utenti, tutti gli aspetti sono relativamente semplici e facili.

* [iredmail](https://www.iredmail.com/index.html)
* [Zimbra Email Server](https://www.zimbra.com/)
* [Extmail](https://www.extmail.cn/)
* [modoboa](https://modoboa.org/en/)
* [Mail-in-a-Box](https://mailinabox.email/)
* [Kolab Groupware](https://docs.kolab.org/installation-guide/index.html)
* [squirrelmail](https://www.squirrelmail.org/index.php)
* [hmailserve](https://www.hmailserver.com/)
* ...
