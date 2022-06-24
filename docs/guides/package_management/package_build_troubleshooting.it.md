---
title: Creazione del Pacchetto & Risoluzione dei Problemi
---

# Per prima cosa, familiarizzare con lo strumento di costruzione Mock:

Una volta superata, la pagina tecnica e introduttiva più importante per il nostro sforzo di debug dei pacchetti è questa:

https://wiki.rockylinux.org/en/team/development/Mock_Build_Howto

Stiamo usando il programma "mock" per eseguire le nostre build, proprio come farà la vera infrastruttura Rocky. Dovreste installarlo e abituarvi ad usarlo. Utilizzate questa guida per iniziare, e spiegare un po' cosa speriamo di ottenere e perché dobbiamo costruire tutti questi pacchetti in un ordine specifico.

Leggeteli con attenzione e magari immergetevi nell'argomento alimentando il vostro mock con uno o due SRPM e compilando alcune cose.

Mock è davvero ottimo, in quanto è un programma facile da richiamare che costruisce un intero sistema all'interno di una chroot per eseguire la compilazione, per poi ripulirlo in seguito.

Se si vuole un riferimento per i file di configurazione Mock da guardare o con cui giocare, ce ne sono alcuni pubblicati qui (che corrispondono ai "Build Passes" che vengono fatti per testare le build dei pacchetti): https://rocky.lowend.ninja/RockyDevel/mock_configs/

Una volta acquisita familiarità con Mock (e soprattutto con i suoi log di output), abbiamo un elenco di pacchetti che non funzionano e per i quali dobbiamo indagare e trovare spiegazioni e/o correzioni.



## Introduzione - Cosa occorre fare

L'area in cui abbiamo più bisogno di aiuto in questo momento, e il modo più semplice per contribuire, è quello di aiutare a risolvere i problemi di compilazione dei pacchetti che falliscono.

Stiamo ricostruendo CentOS 8.3 come "pratica", in modo da poter risolvere in anticipo eventuali problemi che si presentano con la build ufficiale di Rocky. Stiamo documentando tutti gli errori riscontrati nei pacchetti e come correggerli (per farli compilare). Questa documentazione aiuterà il nostro team di progettazione dei rilasci quando sarà il momento di realizzare le build ufficiali.

## Contribuire al lavoro di debug:

Una volta acquisita familiarità con Mock e soprattutto con il debug del suo output, si può iniziare a esaminare i pacchetti che falliscono. Alcune di queste informazioni sono anche nella pagina Mock HowTo mostrata sopra.

Trovate un pacchetto non funzionante nella pagina dei fallimenti del build pass più recente (attualmente il Build Pass 10: https://wiki.rockylinux.org/en/team/development/Build_Order/Build_Pass_10_Failure)

Assicurarsi che il pacchetto non sia già stato esaminato e/o corretto: https://wiki.rockylinux.org/en/team/development/Package_Error_Tracking

Fai sapere agli altri debugger a cosa stai lavorando! Non vogliamo duplicare gli sforzi. Salta su chat.rockylinux.org (canale #dev/packaging) e facci sapere!

Impostate il vostro programma di simulazione con le configurazioni più recenti che stiamo usando (linkate sopra). Si può usare per provare la compilazione nello stesso modo in cui la facciamo noi (con dipendenze esterne, repository extra, ecc.)

Indagare sugli errori: si può usare il proprio mock, così come i file di log di quando la compilazione non è andata a buon fine, che si trovano qui: https://rocky.lowend.ninja/RockyDevel/MOCK_RAW/

Capire cosa sta succedendo e come risolverlo. Può assumere la forma di impostazioni speciali di mock o di una patch aggiunta al programma + specfile. Segnalate le vostre scoperte al canale #Dev/Packaging e qualcuno le registrerà nella pagina Wiki Package_Error_Tracking linkata sopra.

L'idea è di ridurre la pagina Build Failures e di aumentare la pagina Package_Error_Tracking. Se necessario, verranno apportate delle correzioni di build al nostro repo di patch per i diversi pacchetti, che si trova qui: https://git.rockylinux.org/staging/patch.
