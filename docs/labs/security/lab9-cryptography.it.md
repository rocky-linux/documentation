
# Laboratorio 9: Criptografia

## Obiettivi

Dopo aver completato questo lavoro di laboratorio, sarete in grado di:

- applicare i concetti crittografici alla protezione dei dati e alla comunicazione

Tempo stimato per completare questo laboratorio: 120 minuti

## Termini e definizioni Comuni di Crittografia

### Crittografia

Nell'uso quotidiano generale, la Crittografia è l'atto o l'arte di scrivere in caratteri segreti. In gergo tecnico potrebbe esser definita come la scienza di usare la matematica per crittografare e decrittografare i dati.

### Criptanalisi

La criptanalisi è lo studio di come compromettere (sconfiggere) i meccanismi crittografici. È la scienza di decifrare il codice, decodificare segreti, violare schemi d'autenticazione e, in generale, violare i protocolli crittografici.

### Criptologia

La criptologia è la disciplina di crittografia e criptanalisi combinate. La criptologia è la branca della matematica che studia i fondamenti matematici dei metodi crittografici.

### Cifratura

La crittografia trasforma i dati in una forma quasi impossibile da leggere senza le opportune conoscenze (ad esempio, una chiave). Il suo scopo è quello di garantire la privacy, tenendo nascoste le informazioni a chi non sono destinate.

### Decrittografia

La decrittazione è l'operazione inversa alla crittografia: trasforma i dati criptati in una forma intelligibile.

### Codifica

Un metodo di crittografia e decrittografia è detto codifica.

Funzioni di Hash (Algoritmi di Digest)

Le funzioni di hash crittografiche sono usate in vari contesti, ad esempio, per calcolare il digest del messaggio, creando una firma digitale. Una funzione hash comprime i bit di un messaggio in un valore hash di dimensioni fisse per distribuire uniformemente i possibili messaggi tra i possibili valori hash. Una funzione hash crittografica esegue questa operazione in modo tale da rendere estremamente difficile la creazione di un messaggio che corrisponda a un determinato valore hash. Di seguito sono riportati alcuni esempi delle funzioni hash più note e utilizzate.

**a)** - **SHA-1 (Secure Hash Algorithm)** -È un algoritmo di hash crittografico pubblicato dal governo degli Stati Uniti. Produce un valore di hash a 160 bit da una stringa di lunghezza arbitraria. È considerata molto buona.

**b)**- **MD5 (Message Digest Algorithm 5)** - è un algoritmo di hash crittografico sviluppato dai Laboratori RSA. È utilizzabile per eseguire l'hashing di una stringa di byte di lunghezza arbitraria in un valore a 128 bit.

### Algoritmo

Descrive una procedura di risoluzione di un problema passo dopo passo, in particolare una procedura computazionale ricorsiva consolidata per la risoluzione di un problema in un numero finito di passi. Tecnicamente, un algoritmo deve raggiungere un risultato dopo un numero finito di passaggi. L'efficienza di un algoritmo è misurabile dal numero di passaggi elementari che richiede per risolvere il problema. Esistono due classi di algoritmi basati sulle chiavi. Che sono:

**a) **-- **Algoritmi di crittografia simmetrica (chiave segreta)**

Gli algoritmi simmetrici utilizzano la stessa chiave per la crittografia e la decrittografia (o la chiave di decrittografia è facilmente ricavabile dalla chiave di crittografia). Gli algoritmi a chiave segreta usano la stessa chiave sia per la crittografia che per la decrittografia (o una che sia facilmente derivabile dall'altra). Questo è l'approccio più diretto alla crittografia dei dati, è matematicamente meno complesso della crittografia a chiave pubblica. Gli algoritmi simmetrici possono esser suddivisi in cifrature di flusso e cifrature a blocchi. Le cifrature di flusso possono crittografare un singolo bit di testo semplice per volta, mentre le cifrature a blocchi prendono un numero di bit (tipicamente 64 bit nelle cifrature moderne) e li crittografano come un'unità singola. Gli algoritmi simmetrici sono molto più veloci da eseguire su un computer rispetto a quelli asimmetrici.

Esempi di algoritmi simmetrici sono: AES, 3DES, Blowfish, CAST5, IDEA e Twofish.

**b) -- Algoritmi asimmetrici (Algoritmi a Chiave Pubblica)**

Gli algoritmi asimmetrici, d'altra parte, usano una chiave differente per la crittografia e la decrittografia e la chiave decrittografica non è derivabile dalla chiave crittografica. Le cifrature asimmetriche permettono alla chiave crittografica di essere pubblica, consentendo a chiunque di crittografarla, mentre solo il destinatario giusto (che conosce la chiave di decrittografia), può decriptare il messaggio. La chiave di crittografia è detta anche chiave pubblica, mentre la chiave di decrittografia è la chiave privata o segreta.

RSA è probabilmente l'algoritmo di crittografia asimmetrica più conosciuto.

### Firma Digitale

Una firma digitale lega un documento al proprietario di una determinata chiave.

La firma digitale di un documento è un pezzo d'informazioni basato sia sul documento che sulla chiave privata del firmatario. In genere viene creato attraverso una funzione di hash e una funzione di firma privata (crittografia con la chiave privata del firmatario). Una firma digitale è una piccola quantità di dati creata utilizzando una chiave segreta; esiste una chiave pubblica che può essere utilizzata per verificare che la firma sia stata generata utilizzando la corrispondente chiave privata.

Diversi metodi per creare e verificare le firme digitali sono liberamente disponibili, ma l'algoritmo più ampiamente noto è l'algoritmo a chiave pubblica di RSA.

### Protocolli Crittografici

La crittografia opera su molti livelli. Su un livello hai gli algoritmi, come le cifrature a blocchi e i criptosistemi a chiave pubblica. A partire da questi, si ottengono i protocolli e, a partire dai protocolli, si trovano le applicazioni (o altri protocolli). Di seguito è riportato un elenco di applicazioni quotidiane tipiche che utilizzano protocolli crittografici. Questi protocolli si basano sugli algoritmi crittografici di livello inferiore.

i.) Sicureza del Domain Name Server (DNSSEC)

Si tratta di un protocollo per servizi di nomi distribuiti sicuri. Attualmente, è disponibile come Bozza Internet.

ii.) Secure Socket Layer (SSL)

SSL è uno dei due protocolli usati per le connessioni WWW sicure (l'altro è SHTTP). La sicurezza del WWW è diventata necessaria in quanto sempre più informazioni sensibili, come i numeri delle carte di credito, vengono trasmesse su Internet.

iii.) Secure Hypertext Transfer Protocol (SHTTP)

Questo è un altro protocollo per fornire una maggiore sicurezza per le transazioni WWW.

iv) Sicurezza E-Mail e servizi correlati

**GNU Privacy Guard** - è conforme allo standard Internet OpenPGP proposto, come descritto in RFC2440.

v) Protocollo SSH2

Questo protocollo è versatile per le esigenze di Internet ed è attualmente utilizzato nel software SSH2. Il protocollo è usato per proteggere le sessioni del terminale e le connessioni TCP.

I seguenti esercizi esaminano due applicazioni che utilizzano protocolli crittografici: GnuPG e OpenSSH.

## Esercizio 1

### GnuPG

GnuPG (GNU Privacy Guard) è un insieme di programmi per la crittografia a chiave pubblica e la firma digitale. Gli strumenti sono utilizzabili per crittografare dati e creare firme digitali. Include anche una funzione avanzata di gestione delle chiavi. GnuPG utilizza la crittografia a chiave pubblica per consentire agli utenti di comunicare in modo sicuro.

Esegui i seguenti esercizi come un utente normale. es. utente ying

Per creare una nuova coppia di chiavi

1. Accedi al sistema come utente "ying"

2. Assicurati che il pacchetto GnuPG sia installato sul tuo sistema. Digita:

`[ying@serverXY ying]$ rpm -q gnupg`

gnupg-\*.\*

Se non lo è, chiedete al super-utente di installarlo.

3. Elenca e prendi nota di tutte le cartelle nascoste nella cartella della tua home.

4. Elencate le chiavi che avete attualmente nel vostro portachiavi. Digita:

`[ying@serverXY ying]$ gpg --list-keys`

!!! NOTE "Nota"

    Non dovrebbe esserci ancora nessuna chiave nel portachiavi. Ma il comando di cui sopra vi aiuterà anche a creare un ambiente predefinito che vi permetterà di creare una nuova coppia di chiavi con efficacia la prima volta.

Elenca nuovamente le cartelle nascoste nella tua cartella home. Qual è il nome della nuova cartella aggiunta?

5. Usa il programma gpg per creare le tue nuove coppie di chiavi. Digita:

```
[ying@serverXY ying\]$ gpg --gen-key

......................................

gpg: keyring \`/home/ying/.gnupg/secring.gpg' created

gpg: keyring \`/home/ying/.gnupg/pubring.gpg' created

Please select what kind of key you want:

 (1) DSA and ElGamal (default)

 (2) DSA (sign only)

 (5) RSA (sign only)

Your selection? 1
```

Alla richiesta del tipo di chiave che si desidera creare, accettare quella predefinita, cioè (DSA e ElGamal). Digitate 1

!!! WARNING "Attenzione"

    L'opzione (1) crea due coppie di chiavi. La coppia di chiavi DSA sarà la coppia di chiavi primaria - per la creazione di firme digitali e una coppia di chiavi ELGamel subordinata per la crittografia dei dati.

6. Si creerà una chiave ELG-E di dimensione 1024. Accettare nuovamente l'impostazione predefinita al prompt sottostante:

La coppia di chiavi DSA avrà 1024 bit.

In procinto di generare una nuova coppia di chiavi ELG-E.

 la dimensione minima della chiave è di 768 bit

 la dimensione della chiave predefinita è di 1024 bit

 la dimensione massima della chiave suggerita è di 2048 bit

Quale dimensione di chiave si desidera? (1024) 1024

7. Creare chiavi che scadranno tra un anno. Digitare "1y" al prompt sottostante:

Specificare per quanto tempo la chiave deve essere valida.

 0 = la chiave non scade

<n> = la chiave scade tra n giorni

<n>w = la chiave scade tra n settimane

<n>m = la chiave scade tra n mesi

<n>y = la chiave scade tra n anni

La chiave è valida per? (0) 1y

8. Digitare "y" per accettare la data di scadenza visualizzata:

È corretto (y/n)? y

9. Creare un ID utente con cui identificare la chiave:

È necessario un ID utente per identificare la propria chiave; il software costruisce l'id utente

da Nome reale, Commento e Indirizzo e-mail in questo modulo:

"Firstname Lastname (any comment) &lt;yourname@serverXY&gt;"

Real name: Ying Yang\[ENTER\]

Comment : my test\[ENTER\]

Email address: ying@serverXY \[ENTER\]

Alla richiesta di conferma, digitare "o" (Ok) per accettare i valori corretti.

È stato selezionato questo USER-ID:

"Ying Yang (my test) &lt;ying@serverXY&gt;"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O

10. Select a passphrase that you WILL NOT forget at the next prompt:

Enter passphrase: \*\*\*\*\*\*\*\*

Repeat passphrase: \*\*\*\*\*\*\*\*

## Esercizio 2

### Amministrazione della Chiave

Il programma gpg viene utilizzato anche per l'amministrazione delle chiavi.

Elenco delle chiavi

1. Mentre si è ancora connessi al sistema come utente ying. Visuaizzate le chiavi nel vostro portachiavi. Digita:

[ying@serverXY ying\]$  gpg --list-keys

gpg: WARNING: using insecure memory!

/home/ying/.gnupg/pubring.gpg

-----------------------------

pub 1024D/1D12E484 2003-10-16 Ying Yang (my test) &lt;ying@serverXY&gt;

sub 1024g/1EDB00AC 2003-10-16 \[expires: 2004-10-15\]

2. Per sopprimere il fastidioso "avviso" sulla "insecure memory", aggiungere la seguente opzione

 al vostro file di configurazione gpg personale. Digita:

[ying@serverXY ying\]$ echo "no-secmem-warning" &gt;&gt; ~/.gnupg/gpg.conf

3. Eseguire il comando per elencare nuovamente le chiavi. per assicurarsi che la modifica sia effettiva.

4. Elencare le chiavi con le relative firme. Digita:

[ying@serverXY ying\]$ gpg --list-sigs

/home/ying/.gnupg/pubring.gpg


5. Elencare solo le chiavi segrete. Digita:

[ying@serverXY ying\]$ gpg --list-secret-keys

/home/ying/.gnupg/secring.gpg

-----------------------------

sec 1024D/1D12E484 2003-10-16 Ying Yang (my test) &lt;ying@serverXY&gt;

ssb 1024g/1EDB00AC 2003-10-16

6. Visualizzare le impronte digitali delle chiavi. Digita:

\[ying@serverXY ying\]$ ***gpg --fingerprint***

/home/ying/.gnupg/pubring.gpg

-----------------------------

pub 1024D/1D12E484 2003-10-16 Ying Yang (my test) &lt;ying@serverXY&gt;

 Key fingerprint = D61E 1538 EA12 9049 4ED3 5590 3BC4 A3C1 1D12 E484

sub 1024g/1EDB00AC 2003-10-16 \[expires: 2004-10-15\]

<span id="anchor-2"></span>Certificati di revoca

I certificati di revoca vengono utilizzati per revocare le chiavi nel caso in cui qualcuno venga a conoscenza della chiave segreta o nel caso in cui ci si dimentichi la passphrase. Sono utili anche per altre funzioni.

Per creare un certificato di revoca

1. Mentre si è ancora connessi come utente ying. Creare un certificato di revoca. Verrà visualizzato sul vostro

 standard output. Digita:

[ying@serverXY ying\]$*** gpg --gen-revoke ying@serverXY***

Seguite le indicazioni e inserite la passphrase quando vi viene richiesto.

2. Ora si crea un certificato di revoca che verrà memorizzato in formato ASCII in un file chiamato -

 “revoke.asc”. Digita:

[ying@serverXY ying\]$*** gpg --output revoke.asc --gen-revoke ying@serverXY***

3. È opportuno conservare il certificato di revoca in un luogo sicuro e farne una copia cartacea.

Esportazione delle Chiavi Pubbliche

Lo scopo di tutte queste operazioni di crittografia, firma e decrittografia è che le persone desiderano comunicare tra loro, ma anche farlo nel modo più sicuro possibile.

Detto questo, va detto che forse non è così ovvio:

Per comunicare con altre persone utilizzando un sistema crittografico basato su chiavi pubbliche, è necessario scambiare chiavi pubbliche..

O almeno rendere disponibile la vostra chiave pubblica in qualsiasi luogo pubblicamente accessibile (tabelloni, pagine web, server di chiavi, radio, TV, SPAMMING via e-mail ... ecc)

Per esportare le chiavi pubbliche

1. Esportare la chiave pubblica in formato binario in un file chiamato "ying-pub.gpg". Digita:

[ying@serverXY ying\]$ ***gpg --output ying-pub.gpg --export &lt;your\_key’s\_user\_ID&gt;***

!!! NOTE "Nota"

    Sostituire &lt;your\key's\_user\_ID&gt; con qualsiasi stringa che identifichi correttamente le chiavi. Nel nostro sistema campione questo valore può essere uno dei seguenti:
    
    ying@serverXY, ying, yang
    
    OPPURE
    
    L'attuale chiave ID - 1D12E484

2. Esportare la chiave pubblica in un file chiamato "ying-pub.asc". Ma questa volta generarlo in

 ASCII-armored format. Digita:

[ying@serverXY ying\]$***gpg --output ying-pub.asc --armor --export ying@serverXY ***

3. Usare il comando cat per visualizzare la versione binaria della chiave pubblica di ying (ying-pub.gpg)

4. (Per resettare il terminale digitare: "reset")

5. Usare il comando cat per visualizzare la versione ASCII della chiave pubblica di ying (ying-pub.asc)

6. Si noterà che la versione ASCII è più adatta per la pubblicazione su pagine web o per lo spamming, ecc.

## Esercizio 3

### Firme digitali

La creazione e la verifica delle firme utilizzano la coppia di chiavi pubbliche/private, che differisce dalla crittografia e dalla decrittografia. La firma viene creata utilizzando la chiave privata del firmatario. La firma può essere verificata utilizzando la chiave pubblica corrispondente.

Per firmare digitalmente un file

1. Creare un file chiamato "secret-file.txt" con il testo "Hello All". Digita:

\[ying@serverXY ying\]$ ***echo "Hello All" &gt; secret1.txt***

2. Utilizzare cat per visualizzare il contenuto del file. Usare il comando file per vedere il tipo di file.

3. Ora firmate il file con la vostra firma digitale. Digita:

\[ying@serverXY ying\]$ ***gpg -s secret1.txt***

Quando viene richiesto, inserire la passphrase.

Il comando precedente creerà un altro file "secret1.txt.gpg", compresso e dotato di firma. Eseguite il comando "file" sul file per verificarlo. Visualizzare il file con cat

4. Controllare la firma sul file firmato "secret1.txt.gpg". Digita:

\[ying@serverXY ying\]$ ***gpg --verify secret1.txt.gpg***

gpg: Signature made Thu 16 Oct 2003 07:29:37 AM PDT using DSA key ID 1D12E484

gpg: Good signature from "Ying Yang (my test) &lt;ying@serverXY&gt;"

5. Creare un altro file secret2.txt con il testo "Hello All".

6. Firmate il file secret2.txt, ma questa volta lasciate che il file sia blindato in ASCII. Digita:

\[ying@serverXY ying\]$ ***gpg -sa secret2.txt***

Nella vostra pwd verrà creato un file blindato ASCII chiamato "secret2.txt.asc".

7. Usate il comando cat per visualizzare il contenuto del file blindato ASCII creato in precedenza.

8. Creare un altro file chiamato "secret3.txt" con il testo "hello dude". Digita:

\[ying@serverXY ying\]$*** echo "hello dude" &gt; secret3.txt***

9. Aggiungete la vostra firma al corpo del file creato sopra. Digita:

\[ying@serverXY ying\]$ ***gpg --clearsign secret3.txt***

Questo creerà un file non compresso (secret3.txt.asc) con la vostra firma blindata ASCII.

Scrivete il comando per verificare la firma del file che è stato creato per voi.

10. Aprire il file per visualizzarne il contenuto con un qualsiasi pager. È possibile leggere il testo inserito nel file?

ASSICURATEVI CHE IL VOSTRO PARTNER ABBIA ESEGUITO L'INTERO

"ESERCIZI -1, 2, 3" PRIMA DI CONTINUARE CON L'"ESERCIZIO 4"

SE NON SI HA UN PARTNER. DISATTIVARE L'ACCOUNT DELL'UTENTE YING E ACCEDRE AL SISTEMA COME UTENTE "me".

RIPETERE L'INTERO ESERCIZIO -1,2,3 COME UTENTE "me".

È POSSIBILE ESEGUIRE IL SEGUENTE ESERCIZIO 4. SOSTITUIRE TUTTI I RIFERIMENTI ALL'UTENTE YING IN "serverPR" CON - L'UTENTE "me" IN serverXY (cioè il vostro localhost)

È POSSIBILE UTILIZZARE SIA L'UTENTE "me@serverXY" CHE L'UTENTE "ying@serverPR"

COME PARTNER NELL'ESERCIZIO SUCCESSIVO.

## Esercizio 4

 In questo esercizio, utilizzerete la cosiddetta "Rete della fiducia" per comunicare con un altro utente.

Importare le chiavi pubbliche

1. Accedere al sistema come utente ying./

2. Rendere disponibile al partner il file della propria chiave pubblica blindata ASCII (ying-pub.asc) (utilizzare

 o - me@serverXY o ying@serverPR)

NOTE "Nota:"

Esistono diversi modi per farlo, ad esempio e-mail, copia e incolla, scp, ftp, salvataggio su dischetto, ecc.

Scegliete il metodo più efficiente per voi.

3. Chiedete al vostro partner di mettere a vostra disposizione il file della sua chiave pubblica.

4. Supponendo che la chiave pubblica del vostro partner sia memorizzata in un file chiamato "me-pub.asc" nella vostra pwd;

 Importare la chiave nel portachiavi. Digita:

\[ying@serverXY ying\]$ ***gpg --import me-pub.asc***

gpg: key 1D0D7654: public key "Me Mao (my test) &lt;me@serverXY&gt;" imported

gpg: Total number processed: 1

gpg: imported: 1

5. Ora elencate le chiavi del vostro portachiavi. Digita:

\[ying@serverXY ying\]$*** gpg --list-keys***

/home/ying/.gnupg/pubring.gpg

-----------------------------

pub 1024D/1D12E484 2003-10-16 Ying Yang (my test) &lt;ying@serverXY&gt;

sub 1024g/1EDB00AC 2003-10-16 \[expires: 2004-10-15\]

pub 1024D/1D0D7654 2003-10-16 Me Mao (my test) &lt;me@serverXY&gt;

sub 1024g/FD20DBF1 2003-10-16 \[expires: 2004-10-15\]

6. In particolare, elencare la chiave associata all'ID utente me@serverXY. Digita:

\[ying@serverXY ying\]$*** gpg --list-keys me@serverXY***

7. Visualizzare l'impronta digitale della chiave per me@serverXY. Digita:

\[ying@serverXY ying\]$*** gpg --fingerprint me@serverXY***

<span id="anchor-4"></span>Crittografare e decrittografare file

La procedura di crittografia e decrittografia di file o documenti è semplice.

Se si vuole criptare un messaggio all'utente ying, lo si cripterà utilizzando la chiave pubblica dell'utente ying.

Al momento della ricezione, ying dovrà decifrare il messaggio con la chiave privata di ying.

SOLO ying può decifrare il messaggio o il file crittografato con la chiave pubblica di ying

Per criptare un file

1. Mentre si accede al sistema come utente ying, creare un file chiamato encrypt-sec.txt. Digita:

\[ying@serverXY ying\]$ ***echo "hello" &gt; encrypt-sec.txt***

Assicuratevi di poter leggere il contenuto del file usando cat.

2. Crittografare il file encrypt-sec.txt, in modo che solo l'utente "me" possa visualizzarlo. cioè si cripterà

 utilizzando la chiave pubblica di me@serverXY (che ora avete nel vostro portachiavi). Digita:

\[ying@serverXY ying\]$ ***gpg --encrypt --recipient me@serverXY encrypt-sec.txt***

 Il comando precedente creerà un file criptato chiamato "encrypt-sec.txt.gpg" nella vostra pwd.

 Per decifrare un file

1. Il file che avete criptato sopra era destinato a me@serverXY.

 Provare a decifrare il file. Digita:

\[ying@serverXY ying\]$ ***gpg --decrypt encrypt-sec.txt.gpg***

gpg: encrypted with 1024-bit ELG-E key, ID FD20DBF1, created 2003-10-16

 "Me Mao (my test) &lt;me@serverXY&gt;"

gpg: decryption failed: secret key not available

2. Abbiamo imparato qualche lezione preziosa?

3. Rendete il file crittografato creato disponibile al proprietario corretto e fategli eseguire il procedimento sopra descritto

 per decifrare il file. Hanno avuto più successo nel decriptare il file.

!!! NOTE "Nota"

    Fate molta attenzione quando decriptate file binari (ad esempio programmi), perché dopo aver decriptato con successo un file gpg tenterà di inviare il contenuto del file allo standard output.

Per decifrare i file, invece, utilizzate abitualmente il comando riportato di seguito:

\[ying@serverXY ying\]$ ***gpg --output encrypt-sec --decrypt encrypt-sec.txt.gpg***

Questo forza l'invio dell'output a un file chiamato "encrypt-sec".

Che possono essere visualizzati (o eseguiti) con qualsiasi programma adatto al tipo di file (o di contenuto).

!!! TIPS "Consigli"

1. La maggior parte dei comandi e delle opzioni utilizzati con il programma gpg hanno anche forme brevi che risultano in meno

 digitazione per l'utente dalla riga di comando. ad es.

gpg --encrypt --recipient me@serverXY encrypt-sec.txt

La forma breve di questo comando è:

gpg -e -r me@serverXY encrypt-sec.txt

2. Per criptare la stringa "hello" e spedirla come messaggio blindato ASCII all'utente con l'indirizzo mail

 ying@serverXY; Utilizzare il comando seguente:

echo "hello" | gpg -ea -r ying@serverXY | mail ying@serverXY

3. Per criptare il file "tuo\_file" con la chiave pubblica di "me@serverXY" e scriverlo in "tuo\_file.gpg"

 dopo ***averlo firmato*** con il proprio ID utente (utilizzando la propria firma digitale); utilizzare il comando seguente:

gpg -se -r me@serverXY your\_file

4. Esiste un server di chiavi pubblicamente disponibile all'indirizzo wwwkeys.pgp.net. È possibile utilizzare gpg per caricare la chiave con:

gpg --send-keys &lt;your\_real\_email\_address&gt; --keyserver wwwkeys.pgp.net

OpenSSH (www.openssh.org)

OpenSSH è l'implementazione del protocollo SSH (Secure SHell) di OpenBSD.

È una versione GRATUITA della suite di strumenti di connettività di rete del protocollo SSH. OpenSSH cripta tutto il traffico (comprese le password) per eliminare efficacemente le intercettazioni, il dirottamento delle connessioni e altri attacchi a livello di rete. Inoltre, OpenSSH offre una pletora di funzionalità di tunneling sicuro e una varietà di metodi di autenticazione.

Aiuta a fornire comunicazioni sicure e crittografate tra due host non affidabili su una rete non sicura (come Internet).

Include sia i componenti lato server che la suite di programmi lato client.

**sshd**

Il lato server include il demone secure shell (sshd). sshd è il demone che ascolta le connessioni dai client.

Crea un nuovo demone per ogni connessione in entrata. I demoni biforcati gestiscono lo scambio di chiavi e la crittografia,

autenticazione, esecuzione di comandi e scambio di dati. Secondo la pagina man di sshd, sshd funziona come segue:

Per il protocollo SSH versione 2:

Ogni host ha una chiave specifica (RSA o DSA) utilizzata per identificare l'host. Quando il demone si avvia, non genera una chiave del server (come avviene nel protocollo SSH versione 1). La sicurezza in avanti è garantita da un accordo a chiave Diffie-Hellman. Questo accordo di chiave si traduce in una chiave di sessione condivisa.

Il resto della sessione viene crittografato utilizzando un cifrario simmetrico, attualmente AES a 128 bit, Blowfish, 3DES, CAST128, Arcfour, AES a 192 bit o AES a 256 bit. Il client seleziona l'algoritmo di crittografia da utilizzare tra quelli proposti dal server. Inoltre, l'integrità della sessione è garantita da un codice crittografico di autenticazione dei messaggi (hmac-sha1 o hmac-md5).

Il protocollo versione 2 prevede un metodo di autenticazione dell'utente basato su chiave pubblica (PubkeyAuthentication) o dell'host client (HostbasedAuthentication), un'autenticazione convenzionale con password e metodi basati su challenge response.

Il protocollo SSH2 implementato in OpenSSH è standardizzato dal gruppo di lavoro "IETF secsh"

ssh

La suite di programmi del client include "ssh". È un programma utilizzato per accedere a sistemi remoti e può essere utilizzato anche per eseguire comandi su sistemi remoti.

## Esercizio 5

### sshd

Uso: sshd \[opzioni\]

Opzioni:

 -f file File di configurazione (predefinito /etc/ssh/sshd\_config)

 -d Modalità di debug (più -d significa più debug)

 -i Avviato da inetd

 -D Non eseguire il fork in modalità demone

 -t Solo file di configurazione e chiavi di prova

 -q Silenzioso (nessuna registrazione)

 -p port Ascolta sulla porta specificata (valore predefinito: 22)

 -k secondi Rigenera la chiave del server ogni quanti secondi (valore predefinito: 3600)

 -g secondi Periodo di tolleranza per l'autenticazione (valore predefinito: 600)

 -bits Dimensione della chiave RSA del server (valore predefinito: 768 bit)

 -h file File da cui leggere la chiave host (predefinito: /etc/ssh/ssh\_host\_key)

 -u len Lunghezza massima dell'hostname per la registrazione utmp

 -4 Utilizzare solo IPv4

 -6 Utilizzare solo IPv6

 -o opzione Elaborare l'opzione come se fosse letta da un file di configurazione.

La maggior parte dei sistemi Linux ha già il server OpenSSH configurato e funzionante con alcune impostazioni predefinite. Il file di configurazione di sshd risiede solitamente in - /etc/ssh/ - e si chiama sshd\_config.

sshd\_config

1. Aprite il file di configurazione del server ssh con un qualsiasi pager e studiatelo. Digita:

\[root@serverXY root\]\# less /etc/ssh/sshd\_config

NOTE "Nota:"

sshd\_config è un file di configurazione piuttosto strano.

Si noterà che, a differenza di altri file di configurazione di Linux, i commenti (\#) nel file sshd\_config indicano i valori predefiniti delle opzioni. cioè i commenti rappresentano i valori predefiniti già compilati.

2. Consultare la pagina man di sshd\_config e spiegare cosa fanno le opzioni sottostanti?

AuthorizedKeysFile

Ciphers

HostKey

Port

Protocol

X11Forwarding

HostKey

3. Cambiate la vostra pwd nella directory /etc/ssh/.

4. Elencare tutti i file presenti nella directory sottostante:

Creazione di chiavi host

Il server ssh dispone già di chiavi host che utilizza. Queste chiavi sono state generate al momento della prima installazione del sistema. In questo esercizio imparerete a creare chiavi di tipo host per il vostro server. Ma non userete mai i tasti.

Per generare le chiavi host per il vostro server

1. Create una nuova directory sotto la vostra pwd. Chiamatela spare-keys. passare alla nuova directory. Digita:

\[root@serverXY ssh\]\# mkdir spare-keys && cd spare-keys

2. Utilizzare il programma ssh-keygen per creare una chiave host con le seguenti caratteristiche:

a. il tipo di chiave deve essere "rsa"

b. La chiave non dovrebbe avere commenti

c. Il file della chiave privata deve essere denominato - ssh\_host\_rsa\_key

d. La chiave non deve utilizzare alcuna passphrase

 Digita:

\[root@serverXY spare-keys\]\# ssh-keygen -q -t rsa -f ssh\_host\_rsa\_key -C '' -N ''

3. Visualizzare l'impronta digitale della chiave creata in precedenza. Digita:

\[root@serverXY spare-keys\]\# ssh-keygen -l -f ssh\_host\_rsa\_key

4. Scrivete il comando per creare una chiave di tipo ***dsa*** "ssh_host_dsa_key" senza commenti,

 e senza passphrase?

## Esercizio 6

### ssh

```
Uso:- ssh \[-l login_nome\] hostname | user@hostname \[command\]

 ssh \[-afgknqstvxACNTX1246\] \[-b bind_address\] \[-c cipher\_spec]

 \[-e escape\_char\] \[-i identity\_file\] \[-l login\name\] \[-m mac\_spec]

 \[-o option\] \[-p port\] \[-F configfile\] \[-L port:host:hostport\]

\[-R port:host:hostport\] \[-D port\] hostname | user@hostname \[command\]
```

Per utilizzare ssh

1. Accedere al serverXY come utente me.

2. Utilizzare ssh per connettersi al serverPR. Digita:

\[me@serverXY me\]$ ***ssh serverPR***

 Digitare la password di me quando richiesto. Se vengono visualizzati messaggi di avvertimento, digitare "sì" per continuare.

3. Dopo aver effettuato l'accesso, creare una directory chiamata - myexport e creare un file vuoto. Digita:

\[me@serverPR me\]$ ***mkdir ~/myexport && touch myexport/$$***

Prendere nota del file casuale che è stato creato per voi, sotto ~/myexport ?

4. Disconnettersi dal serverPR. Digita:

\[me@serverPR me\]$ ***exit***

Verrete riportati alla vostra shell locale sul serverXY.

5. Usare ssh per eseguire da remoto il comando "ls" per visualizzare l'elenco dei file nella home directory di ying a

 serverPR. Digita:

\[me@serverXY me\]$ ***ssh ying@serverPR “ls /home/ying”***

Digitare la password di ying quando richiesto. Se vengono visualizzati messaggi di avvertimento, digitare "sì" per continuare.

6. Mentre sono ancora connesso come me sul serverXY, accedere al serverPR come utente ying. Digita:

\[me@serverXY me\]$ ***ssh -l ying serverPR ***

 **Digitare la password di ying quando richiesto.**

7. Digitare "exit" per disconnettersi dal serverPR e tornare al serverXY.

<span id="anchor-7"></span>scp

scp - secure copy (programma di copia remota di file)

scp copia i file tra gli host di una rete. Utilizza ssh per il trasferimento dei dati e utilizza la stessa autenticazione e fornisce la stessa sicurezza di ssh.

```
Uso:- scp \[-pqrvBC46\] \[-F ssh_config] \[-S program\] \[-P port\] \[-c cipher\]

 \[-i identity\_file\] \[-o ssh\_option\] \[\[user@\]host1:\] file1 \[...\]

 \[\[uteser@\]host2:\] file2
 ```

Per utilizzare scp

1. Assicuratevi di essere ancora connessi come utente me sul serverXY.

2. Creare una directory sotto la propria home directory chiamata myimport e fare un cd nella directory.

3. Copiare tutti i file nella directory "/home/me/myexport/" sul serverPR. Digita:

\[me@serverXY myimports\]$ ***scp serverPR:/home/me/myexport .***

4. Elencare il contenuto della propria pwd ?

 E' stato un vero e proprio colpo di fulmine o cosa?

5. Qual è il comando per copiare tutto il contenuto di "/home/me/.gnugp/" sul serverPR?

6. Ora copiare tutti i file nella directory home di ying sul serverPR. Digita:

\[me@serverXY myimports\]$ ***scp -r ying@serverPR:/home/ying/\* .***

## Esercizio 7

### Creazione di chiavi pubbliche e private dell'utente per SSH

Ogni utente che vuole usare SSH con autenticazione RSA o DSA ha bisogno di una serie di chiavi pubbliche e private. Il programma ssh-keygen può essere usato per creare queste chiavi (proprio come è stato usato in precedenza quando si sono create le chiavi di riserva per il proprio sistema)

L'unica differenza "consigliata" quando si creano chiavi utente è quella di creare anche una passphrase.

La passphrase è una password che viene utilizzata per crittografare la chiave privata prima che venga memorizzata sul file system.

La chiave pubblica viene memorizzata in un file con lo stesso nome della chiave privata, ma con l'estensione ".pub". Non c'è modo di recuperare una passphrase persa. Se la passphrase viene persa o dimenticata, è necessario generare una nuova chiave.

Per creare le chiavi di autenticazione di ying

1. Accedere al computer locale come utente ying.

2. Eseguire il programma "ssh-keygen" per creare una chiave di tipo "***dsa***" con la lunghezza predefinita. Digita:

\[ying@serverXY ying\]$ ***ssh-keygen -t dsa***

Generazione della coppia di chiavi pubbliche/private dsa.

Premere \[INVIO] per accettare la posizione predefinita del file.

Inserire il file in cui salvare la chiave (/home/ying/.ssh/id\_dsa): \[ENTER\]

Quando viene richiesto, inserire una buona passphrase, cioè difficile da indovinare.

Created directory '/home/ying/.ssh'.

Enter passphrase (empty for no passphrase): \*\*\*\*\*\*\*\*\*

Enter same passphrase again: \*\*\*\*\*\*\*\*\*

Your identification has been saved in /home/ying/.ssh/id\_dsa.

Your public key has been saved in /home/ying/.ssh/id\_dsa.pub.

The key fingerprint is:

61:68:aa:c2:0c:af:9b:49:4a:11:b8:aa:b5:84:18:10 ying@serverXY.example.org

3. passare alla directory "**~/.ssh/**". Elencare i file presenti nella directory?

4. Qual è il comando "ssh-keygen" per visualizzare l'impronta digitale delle chiavi?

5. Usare il comando cat per visualizzare il contenuto del file della chiave pubblica (ad esempio "**~/.ssh/id\_rsa.pub**").

## Esercizio 8

### Autenticazione tramite chiave pubblica

Finora si è utilizzato uno schema di autenticazione basato su password per accedere agli account utente del serverPR.

Ciò significa che, per poter accedere con successo, era necessario conoscere la password dell'account corrispondente sul lato remoto.

In questo esercizio si configura l'autenticazione a chiave pubblica tra il proprio account utente sul serverXY e l'account utente di ying sul serverPR.

Per configurare l'autenticazione a chiave pubblica

1. Accedere al sistema locale come utente ying.

2. passare alla directory "~/.ssh".

3. Digitate il comando orribile che segue:

\[ying@serverXY .ssh\]$ ***cat id\_dsa.pub | ssh ying@serverPR \\***

 '(cd ~/.ssh && cat - &gt;&gt; authorized\_keys && chmod 600 authorized\_keys)'

 Il comando di cui sopra si legge:

 a. cat il contenuto del file dsa public-key, ma inviando il contenuto alla pipe ( | ) invece che al file

 standard abituale.

 b. eseguire il comando "***cd ~/.ssh && cat - &gt;&gt; authorized\_keys && chmod 600 authorized\_keys"***

 come utente ying sul serverPR.

 c. Lo scopo del comando è semplicemente quello di copiare e aggiungere il contenuto della propria chiave pubblica

 nel file "/home/ying/.ssh/authorized\_keys" sul serverPR e dargli i permessi corretti.

 Se conoscete un altro modo manuale per ottenere lo stesso risultato, fatelo.

4. Dopo aver aggiunto la propria chiave pubblica al file authorized\_keys del sistema remoto. Tentativo di

 accedere al serverPR come ying tramite ssh. Digita:

\[ying@serverXY .ssh\]$ ***ssh serverPR***

Enter passphrase for key '/home/ying/.ssh/id\_dsa': \*\*\*\*\*\*\*\*\*\*

Si noti con molta attenzione che questa volta viene richiesta la passphrase anziché il nome del programma

password. Inserire la passphrase creata in precedenza al momento della creazione delle chiavi.

5. Dopo aver effettuato l'accesso al serverPR, effettuare il logout.

## Esercizio 9

### ssh-agent

Secondo la pagina man - ssh-agent è un programma per conservare le chiavi private utilizzate per l'autenticazione a chiave pubblica (RSA, DSA). L'idea è che ssh-agent venga avviato all'inizio di una sessione X o di una sessione di login e che tutte le altre finestre o programmi vengano avviati come client del programma ssh-agent. Tramite l'uso di variabili d'ambiente, l'agente può essere individuato e utilizzato automaticamente per l'autenticazione quando si accede ad altre macchine tramite ssh.

```
Uso ssh-agent \[-a bind_address\] \[-c | -s\] \[-d\] \[command \[args ...\]\]

 ssh-agent \[-c | -s\] -k
```

In questo esercizio si apprenderà come configurare l'agente in modo da non dover digitare la passphrase ogni volta che ci si vuole connettere a un altro sistema utilizzando l'autenticazione a chiave pubblica.

1. Assicuratevi di aver effettuato l'accesso al sistema locale come utente ying.

2. Digitare il comando seguente:

[ying@serverXY .ssh\]$ ***eval \`ssh-agent\`***

Agent pid 5623

Prendere nota del PID dell'agente:

3. Utilizzare il programma "***ssh-add***" per aggiungere le chiavi all'agente lanciato in precedenza. Digita:

[ying@serverXY .ssh\]$ ***ssh-add***

 Quando viene richiesto, inserire la passphrase.

Enter passphrase for /home/ying/.ssh/id\_dsa:

Identity added: /home/ying/.ssh/id\_dsa (/home/ying/.ssh/id\_dsa)

4. Ora collegarsi al serverPR come utente ying. NON vi verrà richiesta una password o un'autorizzazione

passphrase (cioè se tutto è stato fatto correttamente). Digita:

[ying@serverXY .ssh\]$ ***ssh serverPR***

5. Divertitevi.
