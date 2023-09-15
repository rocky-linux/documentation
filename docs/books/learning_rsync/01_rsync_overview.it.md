---
title: rsync breve descrizione
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2022-Mar-14
---

# Backup in Sintesi

Che cos'è un backup?

Il backup si riferisce alla duplicazione dei dati nel file system o nel database. In caso di errore o disastro, i dati effettivi del sistema possono essere ripristinati in modo tempestivo per un normale funzionamento.

Quali sono i metodi di backup?

* Backup completo: si riferisce a una copia unica di tutti i file, le cartelle o i dati nel disco rigido o nel database. (Pro: il migliore, può recuperare i dati più velocemente. Svantaggi: occupa più spazio su disco rigido.)
* Backup incrementale: si riferisce al backup dei dati aggiornati dopo l'ultimo backup completo o incrementale. Il processo è come questo: un backup completo il primo giorno; un backup dei dati appena aggiunti il secondo giorno, al contrario di un backup completo; il terzo giorno, un backup dei dati appena aggiunti sulla base del secondo giorno, relativo al giorno successivo, e così via.
* Backup differenziale: Si riferisce al backup dei file modificati dopo il backup completo. Ad esempio, un backup completo il primo giorno; un backup dei nuovi dati il secondo giorno; un backup dei nuovi dati dal secondo giorno al terzo giorno del terzo giorno; e un backup di tutti i nuovi dati dal secondo giorno al quarto giorno il quarto giorno.
* Backup selettivo: Si riferisce al backup di una parte del sistema.
* Backup a freddo: si riferisce al backup quando il sistema è in stato di arresto o manutenzione. I dati di backup sono esattamente gli stessi dei dati nel sistema durante questo periodo.
* Hot backup: si riferisce al backup quando il sistema è in funzionamento normale. Poiché i dati nel sistema vengono aggiornati in qualsiasi momento, i dati di backup hanno un certo ritardo rispetto ai dati reali del sistema.
* Backup remoto: si riferisce al backup dei dati in un'altra posizione geografica per evitare la perdita di dati e l'interruzione del servizio causata da incendi, disastri naturali, furti, ecc.

## rsync in sintesi

Su un server, ho eseguito il backup della prima partizione nella seconda partizione, comunemente nota come "Backup locale." Gli strumenti di backup specifici da poter utilizzare sono `tar` , `dd` , `dump` , `cp`, ecc. Anche se i dati vengono salvati su questo server, se l'hardware non riesce ad avviarsi correttamente, i dati non verranno recuperati. Per risolvere questo problema con il backup locale, abbiamo introdotto un altro tipo di backup --- "backup remoto".

Alcune persone diranno, non posso usare il comando `tar` o `cp` sul primo server e inviarlo al secondo server tramite `scp` o `sftp`?

In un ambiente di produzione, la quantità di dati è relativamente elevata. Prima di tutto, `tar` o `cp` consumano molto tempo e occupano le prestazioni del sistema. La trasmissione tramite `scp` o `sftp` occupa anche un sacco di larghezza di banda di rete, che non è consentito nell'ambiente di produzione reale. In secondo luogo, questi comandi o strumenti devono essere inseriti manualmente dall'amministratore e devono essere combinati con il crontab dell'attività pianificata. Tuttavia, il tempo impostato da crontab non è facile da cogliere, e non è opportuno eseguire il backup dei dati se il tempo è troppo breve o troppo lungo.

Pertanto, è necessario un backup dei dati nell'ambiente di produzione che deve soddisfare i seguenti requisiti:

1. Backup trasmessi attraverso la rete
2. Sincronizzazione dei file dati in tempo reale
3. Meno occupazione delle risorse del sistema e maggiore efficienza

`rsync` sembrava soddisfare le esigenze di cui sopra. Utilizza l'accordo di licenza open source GNU. Si tratta di uno strumento di backup incrementale veloce. L'ultima versione è la 3.2.3 (2020-08-06). Puoi visitare il [Sito ufficiale](https://rsync.samba.org/) per maggiori informazioni.

In termini di supporto alle piattaforme, la maggior parte dei sistemi Unix-like sono supportati, sia che si tratti di GNU/Linux o BSD. Inoltre, ci sono i relativi `rsync` sotto la piattaforma Windows, come cwRsync.

L'originale `rsync` è stato mantenuto dal programmatore australiano <font color=red>Andrew Tridgell</font> (mostrato nella figura 1 qui sotto), ed ora è mantenuto da <font color=red>Wayne Davison</font> (mostrato nella figura 2 qui sotto) Per la manutenzione, puoi andare all'[indirizzo del progetto github ](https://github.com/WayneD/rsync) per ottenere le informazioni che vuoi.

![ Andrew Tridgell ](images/Andrew_Tridgell.jpg) ![ Wayne Davison ](images/Wayne_Davison.jpg)

!!! note "Nota"

    **rsync è solo uno strumento di backup incrementale e non ha la funzione di sincronizzazione dei dati in tempo reale (deve essere integrato da altri programmi). Inoltre, la sincronizzazione è unidirezionale. Se vuoi realizzare la sincronizzazione bidirezionale, devi collaborare con altri strumenti.**

### Principi e funzionalità di base

Come fa `rsync` a realizzare un efficiente backup di sincronizzazione dei dati unidirezionale?

Il core di `rsync` è il suo **algoritmo di Checksum**. Se sei interessato, puoi andare a \[Come funziona Rsync\](https://rsync.samba.org/how-rsync-works. html) e \[L'algoritmo rsync\](https://rsync.samba.org/tech_report/) per ulteriori informazioni. Questa sezione è al di là della competenza dell'autore e non sarà trattata troppo.

Le caratteristiche di `rsync` sono:

* L'intera directory può essere aggiornata ricorsivamente;
* Può mantenere selettivamente gli attributi di sincronizzazione dei file, come hard link, soft link, proprietario, gruppo, autorizzazioni corrispondenti, tempo di modifica, ecc. e può conservare alcuni degli attributi;
* Supporta due protocolli per la trasmissione, uno è il protocollo ssh, l'altro è il protocollo rsync
