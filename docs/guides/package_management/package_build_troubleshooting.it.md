---
title: Creazione del Pacchetto & Risoluzione dei Problemi
---

!!! danger "Pericolo"

Questo articolo è stato scritto all'inizio del 2021, durante l'avvio di Rocky Linux. Il contenuto di questa pagina è stato conservato per motivi storici, ma è stato leggermente modificato per correggere i collegamenti, fornire un contesto o rimuovere le istruzioni non più pertinenti per evitare confusione. Questo documento sarà archiviato.

# Per prima cosa, familiarizzare con lo strumento di costruzione Mock:

Una volta superata, la pagina tecnica e introduttiva più importante per il nostro sforzo di debug dei pacchetti è questa:

https://wiki.rockylinux.org/archive/legacy/mock_building_guide/

Stiamo usando il programma "mock" per eseguire le nostre build, proprio come farà la vera infrastruttura Rocky. Dovreste installarlo e abituarvi ad usarlo. Utilizzate questa guida per iniziare, spiega un po' cosa speriamo di ottenere e perché dobbiamo costruire tutti questi pacchetti in un ordine specifico.

Leggeteli con attenzione e magari iniziate alimentando il vostro mock con uno o due SRPM e compilando alcuni dati.

Mock è davvero ottimo, in quanto è un programma facile da chiamare che costruisce un intero sistema all'interno di una chroot per eseguire la compilazione, e poi lo pulisce in seguito.

Utilizzare le configurazioni mock per Rocky Linux fornite dal pacchetto `mock` di EPEL.


## Introduzione - Cosa bisogna fare

L'area in cui abbiamo più bisogno di aiuto in questo momento, e il modo più semplice per contribuire, è quello di aiutare a risolvere i problemi di compilazione dei pacchetti che falliscono.

Stiamo ricostruendo CentOS 8.3 come "pratica", in modo da poter risolvere in anticipo eventuali problemi che si presentano con la build ufficiale di Rocky. Stiamo documentando tutti gli errori riscontrati nei pacchetti e il modo in cui risolverli (per renderli compilabili). Questa documentazione aiuterà il nostro team di progettazione dei rilasci quando sarà il momento di realizzare le build ufficiali.

## Contribuire al lavoro di debug:

Una volta acquisita familiarità con Mock e soprattutto con il debug del suo output, si può iniziare a esaminare i pacchetti che falliscono. Alcune di queste informazioni si trovano anche nella pagina Mock HowTo collegata sopra.

Fate sapere agli altri debugger su cosa state lavorando! Non vogliamo duplicare gli sforzi. Andate su chat.rockylinux.org (canale #dev/packaging) e fateci sapere!

Impostate il vostro programma di simulazione con le configurazioni più recenti che stiamo usando (linkate sopra). Si può usare per tentare la compilazione nello stesso modo in cui la facciamo noi (con dipendenze esterne, repository extra, ecc.)

Esaminare l'errore o gli errori.

Capire cosa sta succedendo e come risolverlo. Può assumere la forma di impostazioni speciali di mock o di una patch aggiunta al programma + specfile. Segnalate le vostre scoperte al canale #Dev/Packaging e qualcuno le registrerà nella pagina Wiki Package_Error_Tracking linkata sopra.

L'idea è di ridurre la pagina Build Failures e di aumentare la pagina Package_Error_Tracking. Se necessario, verranno apportate delle correzioni di build al nostro repo di patch per i diversi pacchetti che si trova qui: https://git.rockylinux.org/staging/patch.
