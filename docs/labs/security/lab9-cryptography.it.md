- - -
title: Lab 9 - Crittografia author: Wale Soyinka contributors: Steven Spencer, Ganna Zhyrnova
- - -


# Laboratorio 9: Crittografia

## Obiettivi

Dopo aver completato questo laboratorio, sarete in grado di:

- applicare i concetti di crittografia per proteggere i dati e le comunicazioni

Tempo stimato per completare questo laboratorio: 120 minuti
> Tre possono mantenere un segreto, se due di loro sono morti...
> 
> -- Benjamin Franklin

## Termini e definizioni Comuni di Crittografia

### Crittografia

Nell'uso comune, la crittografia è l'atto o l'arte di scrivere in caratteri segreti. In gergo tecnico può essere definita come la scienza che utilizza la matematica per criptare e decriptare i dati.

### Crittoanalisi

La crittoanalisi è lo studio di come compromettere (superare) i meccanismi crittografici. È la scienza del cracking dei codici, della decodifica dei segreti, della violazione degli schemi di autenticazione e, in generale, della violazione dei protocolli crittografici.

### Crittologia

La criptologia è la disciplina che combina crittografia e crittoanalisi. La crittologia è la branca della matematica che studia i concetti matematici alla base dei metodi crittografici.

### Codifica

La cifratura trasforma i dati in una forma quasi impossibile da leggere senza le opportune conoscenze (ad esempio, una chiave). Il suo scopo è quello di garantire la privacy, tenendo nascoste le informazioni a chi non sono destinate.

### Decrittazione

La decrittazione è l'operazione inversa alla crittografia: trasforma i dati criptati in una forma comprensibile.

### Cifrario

Un metodo di crittografia e decrittografia è chiamato cifrario.

Funzioni di Hash (algoritmi di Digest)

Le funzioni hash crittografiche sono utilizzate in vari contesti, ad esempio per calcolare il digest del messaggio quando si effettua una firma digitale. Una funzione hash comprime i bit di un messaggio in un valore hash di dimensioni fisse per distribuire uniformemente i possibili messaggi tra i possibili valori hash. Una funzione hash crittografica esegue questa operazione in modo tale da rendere estremamente difficile la creazione di un messaggio che corrisponda a un determinato valore hash. Di seguito sono riportati alcuni esempi delle funzioni hash più note e utilizzate.

**a)** - **SHA-1 (Secure Hash Algorithm)** -È un algoritmo di hash crittografico pubblicato dal governo degli Stati Uniti. Produce un valore hash di 160 bit da una stringa di lunghezza arbitraria. Viene considerato come molto buono.

**b)**- **MD5 (Message Digest Algorithm 5)** - è un algoritmo di hash crittografico sviluppato dai Laboratori RSA. Può essere utilizzato per eseguire l'hash di una stringa di byte di lunghezza arbitraria in un valore di 128 bit.

### Algoritmo

Descrive una procedura di risoluzione di un problema passo dopo passo, in particolare una procedura computazionale ricorsiva consolidata per la risoluzione di un problema in un numero finito di passaggi. Tecnicamente, un algoritmo deve raggiungere un risultato dopo un numero definito di passaggi. L'efficienza di un algoritmo può essere misurata come il numero di passi elementari necessari per risolvere il problema. Esistono due classi di algoritmi basati sulle chiavi. Essi sono:

**a) **-- **Algoritmi di crittografia simmetrica (chiave segreta)**

Gli algoritmi simmetrici utilizzano la stessa chiave per la crittografia e la decrittografia (o la chiave di decrittografia è facilmente ricavabile dalla chiave di crittografia). Gli algoritmi a chiave segreta utilizzano la stessa chiave sia per la crittografia che per la decrittografia (o una è facilmente derivabile dall'altra). È l'approccio più semplice alla crittografia dei dati, in quanto è matematicamente meno complicato della crittografia a chiave pubblica. Gli algoritmi simmetrici possono esser suddivisi in cifrature di flusso e cifrature a blocchi. I cifrari a flusso possono criptare un singolo bit di testo in chiaro alla volta, mentre quelli a blocco prendono diversi bit (in genere 64 bit nei cifrari moderni) e li criptano come un'unica unità. Gli algoritmi simmetrici sono molto più veloci da eseguire su un computer rispetto a quelli asimmetrici.

Esempi di algoritmi simmetrici sono: AES, 3DES, Blowfish, CAST5, IDEA e Twofish.

**b) -- Algoritmi asimmetrici (algoritmi a chiave pubblica)**

Gli algoritmi asimmetrici, invece, utilizzano una chiave diversa per la crittografia e la decrittografia e la chiave di decrittazione non può essere derivata dalla chiave crittografica. I cifrari asimmetrici fanno sì che la chiave di cifratura sia pubblica, consentendo a chiunque di cifrare con la chiave, mentre solo il destinatario corretto (che conosce la chiave di decifrazione) può decifrare il messaggio. La chiave di crittografia è detta anche chiave pubblica, mentre la chiave di decrittografia è la chiave privata o segreta.

RSA è probabilmente l'algoritmo di crittografia asimmetrica più conosciuto.

### Firma Digitale

Una firma digitale lega un documento al proprietario di una determinata chiave.

La firma digitale di un documento è un'informazione basata sia sul documento stesso che sulla chiave privata del soggetto firmatario. E' di solito creata tramite una funzione di hash e funzione di firma privata (codificando con la chiave privata del firmatario). Una firma digitale è una piccola quantità di dati creata utilizzando una chiave segreta e una chiave pubblica che può essere utilizzata per verificare che la firma sia stata generata utilizzando la corrispondente chiave privata.

Sono disponibili diversi metodi per realizzare e verificare le firme digitali, ma l'algoritmo a chiave pubblica RSA è il più conosciuto.

### Protocolli Crittografici

La crittografia lavora su più livelli. Alla base ci sono gli algoritmi, come i cifrari a blocchi e i crittosistemi a chiave pubblica. A partire da questi, si ottengono i protocolli e, al di sopra di questi abbiamo le applicazioni (o altri protocolli). Di seguito è riportato un elenco di applicazioni quotidiane tipiche che utilizzano protocolli crittografici. Questi protocolli si basano su algoritmi crittografici di livello più basso.

**i.)** Domain Name Server Security (DNSSEC)

Si tratta di un protocollo per servizi di nomi distribuiti sicuri. Attualmente è disponibile come bozza su Internet.

**ii.)** Secure Socket Layer (SSL)

SSL è uno dei due protocolli usati per le connessioni WWW sicure (l'altro è SHTTP). La sicurezza del WWW è diventata necessaria in quanto sempre più informazioni sensibili, come i numeri delle carte di credito, vengono trasmesse su Internet.

**iii.)** Secure Hypertext Transfer Protocol (SHTTP)

Questo è un altro protocollo per fornire una maggiore sicurezza per le transazioni WWW.

**iv.)** Sicurezza della posta elettronica e servizi correlati

**GnuPG** - GNU Privacy Guard - è conforme allo standard Internet OpenPGP descritto in RFC2440.

**v.)** Protocollo SSH2

Questo protocollo è versatile per le esigenze di Internet ed è attualmente utilizzato nel software SSH2. Il protocollo viene utilizzato per proteggere le sessioni di terminale e le connessioni TCP.

I seguenti esercizi esaminano due applicazioni che utilizzano protocolli crittografici: GnuPG e OpenSSH.

## Esercizio 1

### GnuPG

GnuPG (GNU Privacy Guard) è un insieme di programmi per la crittografia a chiave pubblica e la firma digitale. Gli strumenti possono essere utilizzati per criptare i dati e creare firme digitali. Include inoltre una funzione avanzata di gestione delle chiavi. GnuPG utilizza la crittografia a chiave pubblica per consentire agli utenti di comunicare in modo sicuro.

Eseguire i seguenti esercizi come utente regolare. ad esempio l'utente ying

#### Per creare una nuova coppia di chiavi

1. Accedere al sistema come utente "ying"

2. Assicurarsi che il pacchetto GnuPG sia installato sul sistema. Digitare:

    ```bash
    [ying@serverXY ying]$ rpm -q gnupg
    gnupg-*.*
    ```

    Se non lo fosse, si può richiedere al superutente di installarlo.

3. Elencate e annotate tutte le directory nascoste nella vostra home directory.

4. Elencate le chiavi che avete attualmente nel vostro portachiavi. Digitare:

    ```bash
    [ying@serverXY ying]$ gpg --list-keys
    ```

    !!! note "Nota"

     Non dovreste avere ancora nessuna chiave nel portachiavi. Ma il comando di cui sopra vi aiuterà anche a creare un ambiente predefinito che vi permetterà di creare una nuova coppia di chiavi con successo la prima volta.

    !!! domanda "Attività di laboratorio:"

     Elenca nuovamente le cartelle nascoste nella tua home directory. Qual è il nome della nuova cartella aggiunta?

5. Utilizzare il programma gpg per creare le nuove coppie di chiavi. Digitare:

    ```bash
    [ying@serverXY ying]$ gpg --gen-key

    ......................................

    gpg: keyring `/home/ying/.gnupg/secring.gpg' created

    gpg: keyring `/home/ying/.gnupg/pubring.gpg' created

    Please select what kind of key you want:

    (1) DSA and ElGamal (default)

    (2) DSA (sign only)

    (5) RSA (sign only)

    Your selection? 1
    ```

    Alla richiesta del tipo di chiave che si desidera creare, accettare quella predefinita, cioè (DSA e ElGamal). Digitate 1

    !!! warning "Attenzione"

     L'opzione (1) crea due coppie di chiavi. La coppia di chiavi DSA sarà la coppia di chiavi primaria - per la creazione di firme digitali e una coppia di chiavi ELGamel subordinata per la crittografia dei dati.

6. Si creerà una chiave ELG-E di dimensione 1024. Accettare nuovamente l'impostazione predefinita al prompt sottostante:

    ```bash
    DSA key pair will have 1024 bits.

    About to generate a new ELG-E key pair.

    minimum key size is 768 bits

    default key size is 1024 bits

    highest suggested key size is 2048 bits

    What key size do you want? (1024) 1024
    ```

7. Creare chiavi che scadono tra un anno. Digitare "1y" al prompt sottostante:

    Please specify how long the key should be valid.

    ++0++ = la chiave non scade

    ++"n"++ = la chiave scade tra n giorni

    ++"n"+"w"++ = la chiave scade tra n settimane

    ++"n"+"m"++> = la chiave scade tra n mesi

    ++"n"+"y"++ = la chiave scade tra n anni

    Key is valid for? (0) 1y

8. Digitare "y" per accettare la data di scadenza visualizzata:

    ```bash
    Is this correct (y/n)? y
    ```

9. Creare un ID utente con cui identificare la chiave:

    È necessario un ID utente per identificare la propria chiave; il software costruisce l'ID utente

    da Nome reale, Commento e Indirizzo e-mail in questo modulo:

    "Firstname Lastname (any comment) <yourname@serverXY&>"

    Real name: Ying Yang ++enter++

    Comment : my test ++enter++

    Email address: ying@serverXY ++enter++

    At the confirmation prompt type “o” (Okay) to accept the correct values.

    You selected this USER-ID:

    "Ying Yang (my test) <ying@serverXY>"

    Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O

10. Selezionate una passphrase che NON dimenticherete al prossimo prompt:

    ```bash
    Enter passphrase: **

    Repeat passphrase: **
    ```

## Esercizio 2

### Amministrazione della Chiave

Il programma gpg viene utilizzato anche per l'amministrazione delle chiavi.

#### Elencare le chiavi

1. Mentre si è ancora connessi al sistema come utente ying. Visualizzare le chiavi nel portachiavi. Digitare:

    ```bash
    [ying@serverXY ying]$  gpg --list-keys

    gpg: WARNING: using insecure memory!

    /home/ying/.gnupg/pubring.gpg

    -----------------------------

    pub 1024D/1D12E484 2003-10-16 Ying Yang (my test) <ying@serverXY>

    sub 1024g/1EDB00AC 2003-10-16 [expires: 2004-10-15]
    ```

2. Per sopprimere il fastidioso "avviso" sulla "memoria insicura", aggiungete la seguente opzione al vostro file di configurazione personale di gpg. Digitare:

    ```bash
    [ying@serverXY ying]$ echo "no-secmem-warning" >> ~/.gnupg/gpg.conf
    ```

3. Eseguire il comando per elencare nuovamente le chiavi per assicurarsi che la modifica sia effettiva.

4. Elencare le chiavi con le relative firme. Digitare:

    ```bash
    [ying@serverXY ying]$ gpg --list-sigs

    /home/ying/.gnupg/pubring.gpg
    ```

5. Elencare solo le proprie chiavi segrete. Digitare:

    ```bash
    [ying@serverXY ying]$ gpg --list-secret-keys

    /home/ying/.gnupg/secring.gpg

    -----------------------------

    sec 1024D/1D12E484 2003-10-16 Ying Yang (my test) <ying@serverXY>

    ssb 1024g/1EDB00AC 2003-10-16
    ```

6. Visualizzare le impronte digitali delle chiavi. Digitare:

    ```bash
    [ying@serverXY ying]$ gpg --fingerprint

    /home/ying/.gnupg/pubring.gpg

    -----------------------------

    pub 1024D/1D12E484 2003-10-16 Ying Yang (my test) <ying@serverXY>

    Key fingerprint = D61E 1538 EA12 9049 4ED3 5590 3BC4 A3C1 1D12 E484

    sub 1024g/1EDB00AC 2003-10-16 [expires: 2004-10-15]

    <span id="anchor-2"></span>Revocation certificates

    Revocation certificates are used to revoke keys in case someone gets knowledge of your secret key or in case you forget your passphrase. They are also useful for other various functions.
    ```

#### Per creare un certificato di revoca

1. Mentre si è ancora connessi come utente ying. Creare un certificato di revoca. Verrà visualizzato nell'output standard. Digitare:

    ```bash
    [ying@serverXY ying]$ gpg --gen-revoke ying@serverXY
    ```

    Seguite le indicazioni e inserite la passphrase quando vi viene richiesto.

2. Creare ora un certificato di revoca che verrà memorizzato in formato ASCII in un file denominato -

    “revoke.asc”. Digitare:

    ```bash
    [ying@serverXY ying]$ gpg --output revoke.asc --gen-revoke ying@serverXY
    ```

3. È opportuno conservare il certificato di revoca in un luogo sicuro e farne una copia cartacea.

### Esportazione delle chiavi pubbliche

Lo scopo di tutte queste operazioni di crittografia, firma e decrittografia è che le persone desiderano comunicare tra loro, ma anche farlo nel modo più sicuro possibile.

Detto questo, va detto che forse non è così ovvio:

È necessario scambiare chiavi pubbliche per comunicare con altre persone che utilizzano un crittosistema basato su chiavi pubbliche.

O almeno rendere disponibile la vostra chiave pubblica in qualsiasi luogo pubblicamente accessibile (cartelloni pubblicitari, pagine web, server di chiavi, radio, TV, SPAMMING via e-mail ... ecc)

#### Per esportare le vostre chiavi pubbliche

1. Esportare la chiave pubblica in formato binario in un file chiamato "ying-pub.gpg". Digitare:

    ```bash
    [ying@serverXY ying]$ gpg --output ying-pub.gpg --export <your_key’s_user_ID>
    ```

    !!! note "Nota"

     Sostituire <your_key's_user_ID> con qualsiasi stringa che identifichi correttamente le chiavi. Nel nostro sistema campione questo valore può essere uno dei seguenti:
    
     ying@serverXY, ying, yang
    
     O
    
     L'ID effettivo della chiave - 1D12E484

2. Esportare la chiave pubblica in un file chiamato "ying-pub.asc". Ma questa volta generarlo in

    formato ASCII-armored. Digitare:

    ```bash
    [ying@serverXY ying]$gpg --output ying-pub.asc --armor --export ying@serverXY 
    ```

3. Usare il comando cat per visualizzare la versione binaria della chiave pubblica di ying (ying-pub.gpg)

4. Per resettare il terminale, digitare: `reset`

5. Utilizzare il comando cat per visualizzare la versione ASCII della chiave pubblica di ying (ying-pub.asc)

6. Si noterà che la versione ASCII è più adatta per la pubblicazione su pagine web o per lo spamming, ecc.

## Esercizio 3

### Firme digitali

La creazione e la verifica delle firme utilizzano la coppia di chiavi pubbliche/private, che differisce dalla crittografia e dalla decrittografia. L'utilizzo della chiave privata del firmatario per creare una firma facilita la verifica tramite la corrispondente chiave pubblica.

#### Per firmare digitalmente un file

1. Creare un file chiamato "secret-file.txt" con il testo "Hello All". Digitare:

    ```bash
    [ying@serverXY ying]$ echo "Hello All" > secret1.txt
    ```

2. Utilizzare cat per visualizzare il contenuto del file. Utilizzare il comando file per vedere il tipo di file.

3. Ora firmare il file con la propria firma digitale. Digitare:

    ```bash
    [ying@serverXY ying]$ gpg -s secret1.txt
    ```

    Quando viene richiesto, inserire la passphrase.

    Il comando precedente creerà un altro file "secret1.txt.gpg", compresso e dotato di firma. Eseguire il comando "file" sul file per verificarlo. Visualizzare il file con cat

4. Controllare la firma sul file firmato "secret1.txt.gpg". Digitare:

    ```bash
    [ying@serverXY ying]$ gpg --verify secret1.txt.gpg

    gpg: Signature made Thu 16 Oct 2003 07:29:37 AM PDT using DSA key ID 1D12E484

    gpg: Good signature from "Ying Yang (my test) <ying@serverXY>"
    ```

5. Creare un altro file secret2.txt con il testo " Hello All".

6. Firmare il file secret2.txt, ma lasciare che questa volta il file sia in formato ASCII armored. Digitare:

    ```bash
    [ying@serverXY ying]$ gpg -sa secret2.txt
    ```

    Nella vostra pwd verrà creato un file ASCII armored chiamato "secret2.txt.asc".

7. Utilizzare il comando cat per visualizzare il contenuto del file ASCII armored creato in precedenza.

8. Creare un altro file chiamato "secret3.txt" con il testo "hello dude". Digitare:

    ```bash
    [ying@serverXY ying echo "hello dude" > secret3.txt
    ```

9. Aggiungete la vostra firma al contenuto del file creato in precedenza. Digitare:

    ```bash
    [ying@serverXY ying]$ gpg --clearsign secret3.txt
    ```

    Questo creerà un file non compresso (secret3.txt.asc) con la vostra firma ASCII-armored.

    Scrivete il comando per verificare la firma del file creato per voi.

10. Aprire il file per visualizzarne il contenuto con un qualunque paginatore.

    !!! question "Domanda"
    
         È possibile leggere il testo inserito nel file?

!!! warning "Leggere prima di proseguire"

    Assicurarsi che il vostro compagno abbia eseguito tutti gli "Esercizi 1, 2 e 3" di cui sopra prima di continuare con l'Esercizio 4 di seguito.
    
    Se non si dispone di un compagno, si può uscire dall'account dell'utente Ying e accedere al sistema come utente "me."
    
    Ripetere quindi l'intero "Esercizio 1, 2 e 3" come utente " me."
    
    A questo punto si può eseguire l'esercizio 4. Sostituire tutti i riferimenti all'utente Ying su "serverPR" con l'utente "me" su ServerXY (cioè il vostro localhost).
    
    È possibile utilizzare l'utente "me@serverXY" o l'utente "ying@serverPR" come partner nel prossimo esercizio.

## Esercizio 4

### Importazione delle chiavi pubbliche

In questo esercizio, utilizzerete la cosiddetta "Rete della fiducia" per comunicare con un altro utente.

1. Accedere al sistema come utente ying.

2. Rendere disponibile al partner il file della propria chiave pubblica ASCII-armored (ying-pub.asc) (utilizzare

    o - me@serverXY o ying@serverPR)

    !!! note "Nota"
   
        Esistono diversi modi per farlo, ad esempio e-mail, copia e incolla, scp, ftp, salvataggio su dischetto, ecc.
       
        Scegliete il metodo più efficiente per voi.

3. Chiedete al vostro partner di rendere disponibile il file della chiave pubblica.

4. Supponiamo che la chiave pubblica del compagno sia presente nel file "me-pub.asc" nella nostra attuale directory di lavoro;

    Importare la chiave nel portachiavi. Digitare:

    ```bash
    [ying@serverXY ying]$ gpg --import me-pub.asc

    gpg: key 1D0D7654: public key "Me Mao (my test) <me@serverXY>" imported

    gpg: Total number processed: 1

    gpg: imported: 1
    ```

5. Ora elencate le chiavi del vostro portachiavi. Digitare:

    ```bash
    [ying@serverXY ying]$ gpg --list-keys

    /home/ying/.gnupg/pubring.gpg

    -----------------------------

    pub 1024D/1D12E484 2003-10-16 Ying Yang (my test) <ying@serverXY>

    sub 1024g/1EDB00AC 2003-10-16 [expires: 2004-10-15]

    pub 1024D/1D0D7654 2003-10-16 Me Mao (my test) <me@serverXY>

    sub 1024g/FD20DBF1 2003-10-16 [expires: 2004-10-15]
    ```

6. In particolare, visualizzate la chiave associata all'ID utente me@serverXY. Digitare:

    ```bash
    [ying@serverXY ying]$ gpg --list-keys me@serverXY
    ```

7. Per mostrare l'impronta digitale della chiave per me@serverXY. Digitare:

    ```bash
    [ying@serverXY ying]$ gpg --fingerprint me@serverXY
    ```

    <span id="anchor-4"></span>Crittografia e decrittografia dei file

    La procedura di crittografia e decrittografia di file o documenti è molto semplice.

    Se si vuole criptare un messaggio all'utente ying, lo si farà utilizzando la chiave pubblica dell'utente ying.

    Al momento della ricezione, ying dovrà decifrare il messaggio con la chiave privata di ying.

    SOLO ying può decifrare il messaggio o il file crittografato con la sua chiave pubblica

#### Crittografare un file

1. Mentre si è connessi al sistema come utente ying, creare un file chiamato encrypt-sec.txt. Digitare:

    ```bash
    [ying@serverXY ying]$ echo "hello" > encrypt-sec.txt
    ```

    Assicurarsi di poter leggere il contenuto del file con cat.

2. Crittografare il file encrypt-sec.txt, in modo che solo l'utente "me" possa visualizzarlo. ad esempio, lo cripterete utilizzando la chiave pubblica di me@serverXY (che ora avete nel vostro portachiavi). Digitare:

    ```bash
    [ying@serverXY ying]$ gpg --encrypt --recipient me@serverXY encrypt-sec.txt
    ```

    Il comando creerà un file criptato chiamato "encrypt-sec.txt.gpg" nell'attuale directory di lavoro.

#### Decodificare un file

1. Il file che avete appena era destinato a me@serverXY.

    Provate a decifrare il file. Digitare:

    ```bash
    [ying@serverXY ying]$ gpg --decrypt encrypt-sec.txt.gpg

    gpg: encrypted with 1024-bit ELG-E key, ID FD20DBF1, created 2003-10-16

    "Me Mao (my test) <me@serverXY>"

    gpg: decryption failed: secret key not available
    ```

2. Abbiamo imparato una lezione preziosa?

3. Rendete disponibile il file crittografato creato per il proprietario corretto e fategli eseguire il comando di cui sopra per decifrare il file. La decodifica è avvenuta in una maniera piuttosto agevole.

    !!! nota
   
        Fate molta attenzione quando decrittate i file binari (ad esempio i programmi) perché dopo aver decrittato un file gpg, tenterà di inviare il contenuto del file allo standard output.

    Pertanto, per la fase di decodifica del file si suggerisce l'utilizzo del seguente comando:

    ```bash
    [ying@serverXY ying]$ gpg --output encrypt-sec --decrypt encrypt-sec.txt.gpg
    ```

    Questo forza l'invio dell'output a un file chiamato "encrypt-sec".

    Che può essere visualizzato (o eseguito) con qualunque programma adatto al tipo di file (o di contenuto).

    !!! tip "Consigli"

     La maggior parte dei comandi e delle opzioni utilizzati con il programma gpg hanno anche forme brevi che riducono la digitazione da parte dell'utente nella riga di comando. ad es.

            ```
            gpg --encrypt --recipient me@serverXY encrypt-sec.txt
            ```


         La forma abbreviata di questo comando è:

            ```
            gpg -e -r me@serverXY encrypt-sec.txt
            ```

4. Per crittografare la stringa "hello" e inviarla come messaggio ASCII-armored all'utente con l'indirizzo di posta ying@serverXY; utilizzate il seguente comando:

    ```bash
    echo "hello" | gpg -ea -r ying@serverXY | mail ying@serverXY
    ```

5. Per crittografare il file "your_file" con la chiave pubblica di "me@serverXY" e scriverlo in "your_file.gpg"

    dopo averlo firmato con il proprio id utente (utilizzando la propria firma digitale); utilizzate il seguente comando:

    ```bash
    gpg -se -r me@serverXY your_file
    ```

6. C'è un server di chiavi disponibile pubblicamente all'indirizzo wwwkeys.pgp.net. Possiamo usare gpg per caricare la chiave con:

    gpg --send-keys <your_real_email_address> --keyserver wwwkeys.pgp.net

## [OpenSSH](https://www.openssh.org)

OpenSSH è l'implementazione del protocollo SSH (Secure SHell) di OpenBSD.

È una versione GRATUITA della suite di strumenti di connettività di rete del protocollo SSH. OpenSSH cripta tutto il traffico (comprese le password) per eliminare efficacemente le intercettazioni, il dirottamento delle connessioni e altri attacchi a livello di rete. Inoltre, OpenSSH offre una pletora di funzionalità di tunneling sicuro e una varietà di metodi di autenticazione.

Aiuta a fornire comunicazioni sicure e crittografate tra due host non affidabili su una rete non sicura (come Internet).

Include sia i componenti lato server che la suite di programmi lato client.

### sshd

Lato server abbiamo il demone secure shell (`sshd`). `sshd` è il demone che rimane in ascolto per le connessioni dai client.

Crea un nuovo demone per ogni connessione in entrata. I nuovi demoni creati gestiscono lo scambio di chiavi, la crittografia, l'autenticazione, l'esecuzione di comandi e lo scambio di dati. Secondo la pagina man di sshd, `sshd` funziona come segue:

Il demone SSH di OpenSSH supporta solamente la versione 2 del protocollo SSH. Ogni host ha una chiave specifica (RSA o DSA) utilizzata per identificare l'host. Ogni volta che un client si connette, il demone risponde con la sua chiave pubblica dell'host. Il client confronta la chiave host con il proprio database per verificare che non sia stata modificata. La sicurezza di inoltro è garantita da un accordo a chiave Diffie-Hellman. Questo accordo di chiave si traduce in una chiave di sessione condivisa. Il resto della sessione è codificato con l'utilizzo di una cifratura simmetrica.

Il client seleziona l'algoritmo di crittografia da utilizzare tra quelli proposti dal server. Inoltre, l'integrità della sessione è garantita da un codice crittografico di autenticazione dei messaggi (hmac-md5, hmac-sha1, umac-64, umac-128, hmac-sha2-256 o hmac-sha2-512).

Infine, sia il client che il server accedono ad una finestra di dialogo di autenticazione. Il client prova ad autenticarsi utilizzando l'autenticazione basata sul host, l'autenticazione con chiave pubblica, l'autenticazione GSSAPI, l'autenticazione challenge-response, o con password.

Il protocollo SSH2 implementato in OpenSSH è standardizzato dal gruppo di lavoro "IETF secsh"

### ssh

La suite di programmi del client include `ssh`. È un programma utilizzato per accedere a sistemi remoti e può essere utilizzato anche per eseguire comandi su sistemi remoti.

## Esercizio 5

### `sshd`

Alcuni esercizi riguardano il demone server `sshd`.

```bash
Utilizzo: sshd [options]

Opzioni:

 -f file File di configurazione (default /etc/ssh/sshd_config)
 -d Modalità di debug (multiple -d means more debugging)
 -i Avviato da inetd
 -D Non biforcare in modalità daemon
 -t Testa soltanto file e chiavi di configurazione
 -q Silenzioso (nessuna registrazione)
 -p port Ascolta alla porta specificata (predefinita: 22)
 -k seconds Rigenera la chiave del server ogni dato numero di secondi (predefiniti: 3600)
 -g seconds Periodo di grazia per l'autenticazione (predefinito: 600)
 -b bits Dimensioni della chiave RSA del server (predefinita: 768 bit)
 -h file File da cui leggere la chiave del host (predefinito: /etc/ssh/ssh_host_key)
 -u len Lunghezza massima del nome del host per la registrazione utmp
 -4 Utilizza soltanto IPv4
 -6 Utilizza soltanto IPv6
 -o option Elabora l'opzione come se fosse letta da un file di configurazione.
```

La maggior parte dei sistemi Linux ha già il server OpenSSH configurato e funzionante con alcune impostazioni predefinite. Il file di configurazione di `sshd` risiede tipicamente in `/etc/ssh/` e si chiama `sshd_config`.

### `sshd_config`

1. Apri il file di configurazione del server SSH con qualsiasi impaginatore e studialo. Digitare:

    ```bash
    [root@serverXY root]# less /etc/ssh/sshd_config
    ```

    !!! note "Nota"

     `sshd_config` è un file di configurazione piuttosto strano. A differenza di altri file di configurazione di Linux, i commenti (#) nel file `sshd_config' indicano i valori predefiniti delle opzioni. (cioè, i commenti rappresentano dei valori predefiniti già compilati.)

2. Consultare la pagina man di `sshd_config`.

    !!! question "Domanda"
   
        Cosa fanno le seguenti opzioni?
       
        - AuthorizedKeysFile
        - Ciphers
        - Port
        - Protocol
        - X11Forwarding
        - HostKey

3. Cambiate la vostra pwd nella directory /etc/ssh/.

4. Elenca tutti i file sotto `/etc/ssh/`

### Creazione di chiavi host

Il tuo server SSH dispone già delle chiavi host che utilizza. Queste chiavi sono state generate al momento della prima installazione del sistema. In questo esercizio imparerete a creare chiavi di tipo host per il vostro server. Ma non userete mai i tasti.

#### Per generare le chiavi host per il vostro server

1. Create una nuova directory sotto la vostra pwd. Chiamatela spare-keys. passare alla nuova directory. Digitare:

    ```bash
    [root@serverXY ssh]# mkdir spare-keys && cd spare-keys
    ```

2. Utilizzare il programma ssh-keygen per creare una chiave host con le seguenti caratteristiche:

    - Il tipo di chiave deve essere "rsa"
    - La chiave non dovrebbe avere commenti
    - Il file della chiave privata deve essere denominato - ssh_host_rsa_key
    - La chiave non deve utilizzare alcuna passphrase

    Digitare:

    ```bash
    [root@serverXY spare-keys]# ssh-keygen -q -t rsa -f ssh_host_rsa_key -C '' -N ''
    ```

    !!! question "Domanda"

        Cosa bisogna fare per far sì che il demone sshd utilizzi la chiave host appena generata?

3. Visualizzare l'impronta digitale della chiave creata in precedenza. Digitare:

    ```bash
    [root@serverXY spare-keys]# ssh-keygen -l -f ssh_host_rsa_key
    ```

4. Visualizzate l'impronta digitale della chiave creata, ma questa volta includete la rappresentazione visiva ASCII dell'impronta digitale della chiave. Digitare:

    ```bash
    [root@localhost spare-keys]# ssh-keygen -l -v -f ssh_host_rsa_key
    3072 SHA256:1kQS0Nz4NofWkgqU0y+DxmDoY6AmGsF40GwZkobD8DM ssh_host_rsa_key.pub (RSA)
    +---[RSA 3072]----+
    |X=.+  .*o+.      |
    |B*B o + =o.      |
    |oBE. + o o.+     |
    |+.+o  = ooX o    |
    |+o . . .S*.+     |
    |.      ..        |
    |                 |
    |                 |
    |                 |
    +----[SHA256]-----+
    ```

5. Scrivete il comando per creare una chiave di tipo ***dsa*** "ssh_host_dsa_key" senza commenti,

6. Controllare lo stato del servizio `sshd`. Digitare:

    ```bash
    [root@localhost ~]# systemctl -n 0 status sshd.service
    ● sshd.service - OpenSSH server daemon
    Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
    Active: active (running) since Thu 2023-10-05 23:56:34 EDT; 3 days ago
    ...<SNIP>...
    ```

7. Se si apportano modifiche al file di configurazione di `sshd`, è possibile riavviare il servizio `sshd` eseguendo:

    ```bash
    [root@localhost ~]# systemctl restart sshd.service
    ```

## Esercizio 6

### `ssh`

Questa sezione tratta gli esercizi relativi al programma client `ssh`.

```bash
usage: ssh [-46AaCfGgKkMNnqsTtVvXxYy] [-B bind_interface]
           [-b bind_address] [-c cipher_spec] [-D [bind_address:]port]
           [-E log_file] [-e escape_char] [-F configfile] [-I pkcs11]
           [-i identity_file] [-J [user@]host[:port]] [-L address]
           [-l login_name] [-m mac_spec] [-O ctl_cmd] [-o option] [-p port]
           [-Q query_option] [-R address] [-S ctl_path] [-W host:port]
           [-w local_tun[:remote_tun]] destination [command]
```

#### Per utilizzare `ssh`

1. Accedere al serverXY come utente me.

2. Utilizzare ssh per connettersi al serverPR. Digitare:

    ```bash
    [me@serverXY me]$ ssh serverPR
    ```

    Digitare la password di me quando richiesto. Se vengono visualizzati messaggi di avvertimento, digitare "yes" per continuare.

3. Dopo aver effettuato il login, creare una directory chiamata - myexport e creare un file vuoto chiamato foobar nella nuova directory. Digitare:

    ```bash
    [me@serverPR me]$ mkdir ~/myexport && touch myexport/foobar
    ```

4. Disconnettersi dal serverPR. Digitare:

    ```bash
    [me@serverPR me]$ exit
    ```

    Verrete riportati alla vostra shell locale sul serverXY.

5. Usare `ssh` per eseguire da remoto il comando "ls" per visualizzare ricorsivamente l'elenco dei file nella directory home di me sul serverPR. Digitare:

    ```bash
    [root@localhost ~]# ssh me@serverPR 'ls -lR /home/me/myexport'
    me@localhost's password:
    ...<SNIP>...
    /home/me/myexport:
    total 0
    -rw-rw-r-- 1 me me 0 Oct  9 16:48 foobar
    ```

    Digitare la password di me quando viene richiesto. Se vengono visualizzati messaggi di avvertimento, digitare "yes" per continuare.

6. Mentre si è ancora connessi al serverXY, provare a riavviare da remoto il serverPR come utente `ying`. Digitare:

    ```bash
    [me@localhost ~]# ssh -l ying localhost 'reboot'
    ying@localhost's password:
    ...<SNIP>...
    ```

    Digitare la password di ying quando richiesto.

    !!! question "Domande"

     L'utente ying è riuscito a riavviare il serverPR da remoto? Perché ying non può riavviare il serverPR da remoto?

7. Dal serverXY, provare a visualizzare da remoto lo stato del servizio `sshd` in esecuzione sul serverPR come utente `ying`. Digitare:

    ```bash
    [root@localhost ~]# ssh -l ying localhost 'systemctl status sshd.service'
    ying@localhost's password:
    ● sshd.service - OpenSSH server daemon
    ```

8. Dal serverXY, provare a riavviare da remoto il servizio `sshd` in esecuzione sul serverPR come utente `ying`. Digitare:

    ```bash
    [root@localhost ~]# ssh -l ying localhost 'systemctl restart sshd.service'
    ying@localhost's password:
    Failed to restart sshd.service: Interactive authentication required.
    See system logs and 'systemctl status sshd.service' for details.
    ```

    !!! question "Domande"

     - L'utente ying è stato in grado di visualizzare da remoto lo stato del servizio sshd sul serverPR? 
     - L'utente ying è riuscito a riavviare da remoto il servizio sshd sul serverPR?
     - Scrivete una breve spiegazione del comportamento che state osservando.

9. Digitare "exit" per disconnettersi dal serverPR e tornare al serverXY.

### `scp` - secure copy (programma di copia remota di file)

scp copia i file tra gli host di una rete. Utilizza ssh per il trasferimento dei dati e utilizza la stessa autenticazione e fornisce la stessa sicurezza di ssh.

```bash
usage: scp [-346BCpqrTv] [-c cipher] [-F ssh_config] [-i identity_file]
            [-J destination] [-l limit] [-o ssh_option] [-P port]
            [-S program] source ... target
```

#### Per utilizzare `scp`

1. Assicuratevi di essere ancora connessi come utente me sul serverXY.

2. Creare una directory sotto la propria home directory chiamata myimport e fare un cd nella directory.

3. Copiare tutti i file nella directory "/home/me/myexport/" sul serverPR. (il punto "." alla fine del comando è importante). Digitare:

    ```bash
    [me@localhost ~myimport]# scp serverPR:/home/me/myexport  .
    me@serverPR's password:
    scp: /home/me/myexport: not a regular file
    ```

    !!! question "Domanda"

     Scrivere una breve spiegazione del motivo per cui il comando precedente è fallito?

4. Eseguite nuovamente il comando precedente, ma questa volta aggiungendo l'opzione ricorsiva a `scp`. Digitare:

    ```bash
    [me@localhost ~myimport]# scp -r me@serverPR:/home/me/myexport  .
    me@localhost's password:
    foobar
    ```

    !!! question "Domanda"

     Qual è la differenza tra le variazioni di questi due comandi e in quali circostanze avranno lo stesso risultato?

        ```bash
        scp me@serverPR:/home/me/myexport .
        ```


     e

        ```bash
        scp serverPR:/home/me/myexport .
        ```

5. Qual è il comando per copiare tutto il contenuto di "/home/me/.gnugp/" sul serverPR?

6. Ora copiare la directory home di ying sul serverPR.  Digitare:

    ```bash
    [me@localhost ~myimport]# scp -r  ying@localhost:/home/ying/  ying_home_directory_on_serverPR
    ```

7. Anche in questo caso, eseguire una leggera variazione del comando precedente per copiare la directory home di ying sul serverPR.  Digitare:

    ```bash
    [me@localhost ~myimport]# scp -r  ying@localhost:/home/ying  ying_home_directory_on_serverPR
    ```

    !!! question "Domande"

     Qual è la leggera ma significativa differenza tra le variazioni dei due comandi precedenti? E qual è il risultato di ogni comando?

        ```bash
        scp -r  ying@localhost:/home/ying/  ying_home_directory_on_serverPR
        ```


     e

        ```bash
        scp -r  ying@localhost:/home/ying  ying_home_directory_on_serverPR
        ```

8. Utilizzare il comando `ls -alR` per visualizzare un elenco dei contenuti dei 2 passaggi precedenti. Digitare:

    ```bash
    [me@localhost ~myimport]# ls -al ying_home_directory_on_serverPR/
    ```

    !!! question "Domanda"

     Fornite una breve spiegazione dell'output del comando `ls -alR`? Spiega ad esempio perché sembra che ci siano dei duplicati dei file .bash_history, .bashrc ...

## Esercizio 7

### Creazione di chiavi pubbliche e private dell'utente per SSH

Ogni utente che vuole usare SSH con autenticazione RSA o DSA ha bisogno di una coppia di chiavi pubbliche e private. Il programma `ssh-keygen` può essere utilizzato per creare queste chiavi (proprio come è stato utilizzato in precedenza quando si sono create nuove chiavi host per il proprio sistema)

!!! tip "Suggerimento"

    La differenza principale tra chiavi host e chiavi utente è che si consiglia di proteggere le chiavi utente con una passphrase. La passphrase è una password utilizzata per criptare la chiave privata [testo semplice].

La chiave pubblica viene memorizzata in un file con lo stesso nome della chiave privata, ma con l'estensione ".pub". Non esiste un modo semplice per recuperare una passphrase persa. Se la passphrase viene persa o dimenticata, è necessario generare una nuova chiave.

#### Per creare le chiavi di autenticazione pubbliche/private degli utenti

1. Accedere al computer locale come utente ying.

2. Eseguire il programma `ssh-keygen` per creare una chiave di tipo "dsa" con la lunghezza predefinita. Digitare:

    ```bash
    [ying@serverXY ying]$ ssh-keygen -t dsa

    Generating public/private dsa key pair.
    ```

    Premere ++enter++ per accettare la posizione predefinita del file.

    ```bash
    Enter file in which to save the key (/home/ying/.ssh/id_dsa):
    Created directory '/home/ying/.ssh'.
    ```

    Verrà richiesto due volte di inserire una passphrase. Immettere una passphrase valida e ragionevolmente difficile da indovinare. Premere ++enter++ dopo ogni richiesta.

    ```bash
    Enter passphrase (empty for no passphrase):     *****
    Enter same passphrase again:                    *****
    Your identification has been saved in /home/ying/.ssh/id_dsa.
    Your public key has been saved in /home/ying/.ssh/id_dsa.pub.
    The key fingerprint is:
    SHA256:ne7bHHb65e50HJPchhbiSvEZ0AZoQCEnnFdBPedGrDQ ying@localhost.localdomain
    The key's randomart image is:
    +---[DSA 1024]----+
    |   .oo==++o+     |
    |    o+. o E.*    |
    ...<SNIP>...
    ```

    Dopo il completamento, verrà visualizzato un messaggio che indica che l'identificazione e le chiavi pubbliche sono state salvate nella directory `/home/ying/.ssh/`.

3. passare alla cartella `~/.ssh/`. Elenca i file della directory.

4. Qual è il comando `ssh-keygen` per visualizzare l'impronta digitale delle chiavi?

5. Usare il comando cat per visualizzare il contenuto del file della chiave pubblica (ad esempio `~/.ssh/id_dsa.pub`).

## Esercizio 8

### Autenticazione tramite chiave pubblica

Thus far, you have been using a password-based authentication to log into user accounts at serverPR.

Ciò significa che, per accedere con successo, è necessario conoscere la password dell'account corrispondente sul lato remoto.

In questo esercizio si configura l'autenticazione a chiave pubblica tra il proprio account utente sul serverXY e l'account utente di ying sul serverPR.

#### Per configurare l'autenticazione a chiave pubblica

1. Accedere al sistema locale come utente *ying*.

2. passare alla directory "~/.ssh".

3. Inserite i comandi sottostanti esattamente come mostrato. Verrà richiesta la password di ying sul serverPR. Digitare:

    ```bash
    [ying@serverXY .ssh]$ cat id_dsa.pub | ssh ying@serverPR \ 

    '(cd ~/.ssh && cat - >> authorized_keys && chmod 600 authorized_keys)'
    ```

    In parole povere, il comando di cui sopra si legge:

    a. catturare il contenuto del file della chiave pubblica dsa e inviare via pipe ( | ) l'output a `ssh ying@serverPR`

    b. eseguire il comando “cd ~/.ssh && cat - >> authorized_keys && chmod 600 authorized_keys” come utente ying sul serverPR.

    !!! NOTE "Nota"

     Lo scopo del precedente comando dall'aspetto complicato è quello di copiare e aggiungere il contenuto del file della chiave pubblica in "/home/ying/.ssh/authorized_keys" sul serverPR e dargli i permessi corretti.

    !!! tip "Suggerimento"

     È possibile utilizzare l'utilità `ssh-copy-id` per configurare in modo semplice e più elegante l'autenticazione con chiave pubblica/privata tra i sistemi. `ssh-copy-id` è uno script che utilizza `ssh` per accedere a una macchina remota (presumibilmente utilizzando inizialmente una password di accesso. 
     Assembla un elenco di una o più impronte digitali (come descritto di seguito) e cerca di accedere con ciascuna chiave, per vedere se qualcuna di esse è già installata. Quindi compila un elenco di quelli che non sono riusciti ad accedere e, utilizzando `ssh`, abilita gli accessi con quelle chiavi sul sistema remoto. Per impostazione predefinita, aggiunge le chiavi aggiungendole a ~/.ssh/authorized_keys dell'utente remoto (creando il file e la directory, se necessario).

4. Dopo aver aggiunto la propria chiave pubblica al file authorized_keys del sistema remoto. Tentare di accedere al serverPR come ying tramite ssh. Digitare:

    ```bash
    [ying@serverXY .ssh]$ ssh serverPR
    Enter passphrase for key '/home/ying/.ssh/id_dsa': **
    ```

    Si noti che questa volta viene richiesta la passphrase invece della password utente. Inserire la passphrase creata in precedenza al momento della creazione delle chiavi.

5. Dopo aver effettuato l'accesso al serverPR, effettuare il logout.

## Esercizio 9

### `ssh-agent`

According to the man page - `ssh-agent` is a program to hold private keys used for public key authentication (RSA, DSA, ECDSA, Ed25519). L'idea è che `ssh-agent` venga avviato all'inizio di una sessione utente o di accesso, e tutte le altre finestre o programmi vengano avviati come client del programma `ssh-agent`. Attraverso l'uso di variabili d'ambiente, l'agente può essere individuato e utilizzato automaticamente per l'autenticazione quando si accede ad altre macchine utilizzando `ssh`.

```bash
SYNOPSIS
     ssh-agent [-c | -s] [-Dd] [-a bind_address] [-E fingerprint_hash] [-P pkcs11_whitelist] [-t life] [command [arg ...]]
     ssh-agent [-c | -s] -k
```

In questo esercizio si apprenderà come configurare l'agente in modo da non dover digitare la passphrase ogni volta che ci si vuole connettere a un altro sistema utilizzando l'autenticazione a chiave pubblica.

1. Assicurarsi di aver effettuato l'accesso al sistema locale come utente *ying*.

2. Digitare il comando seguente:

    ```bash
    [ying@localhost ~]$ eval `ssh-agent`
    Agent pid 6354
    ```

    Prendere nota del valore dell'ID di processo (PID) dell'agente nell'output.

3. Eseguire il programma `ssh-add` per elencare le impronte digitali di tutte le identità [pubbliche/private] attualmente rappresentate dall'agente. Digitare:

    ```bash
    [ying@localhost ~]$ ssh-add -l
    The agent has no identities.
    ```

    Non dovrebbe esserci ancora nessuna identità elencata.

4. Utilizzare il programma `ssh-add` senza alcuna opzione per aggiungere le chiavi all'agente lanciato in precedenza. Digitare:

    ```bash
    [ying@localhost ~]$ ssh-add
    ```

    Quando viene richiesto, inserire la passphrase.

    ```bash
    Enter passphrase for /home/ying/.ssh/id_dsa:
    Identity added: /home/ying/.ssh/id_dsa (ying@localhost.localdomain)
    ```

5. Eseguire nuovamente il comando `ssh-add` per elencare le identità di impronte digitali conosciute. Digitare:

    ```bash
    [ying@localhost ~]$ ssh-add -l
    1024 SHA256:ne7bHHb65e50.......0AZoQCEnnFdBPedGrDQ ying@server (DSA)
    ```

6. Ora, come utente *ying*, provate a connettervi in remoto al serverPR ed eseguite un semplice comando di prova.

    Supponendo che sia stato fatto tutto correttamente fino a questo punto per quanto riguarda l'impostazione e la memorizzazione delle chiavi pertinenti, NON dovrebbe essere richiesta una password o una passphrase. Digitare:

    ```bash
    [ying@serverXY .ssh]$ ssh serverPR 'ls /tmp'
    ```

7. Se si è finito e non si ha più bisogno dei servizi di `ssh-agent` o semplicemente si vuole tornare all'autenticazione basata sulle chiavi, si possono cancellare tutte le identità [private/pubbliche] dall'agente. Digitare:

    ```bash
    [ying@localhost ~]$ ssh-add -D
    All identities removed.
    ```

8. Tutto fatto!
