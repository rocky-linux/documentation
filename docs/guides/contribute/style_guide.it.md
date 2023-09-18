---
title: Guida allo Stile
author: Ezequiel Bruni, Krista Burdine
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - contribute
  - style guide
---

# Guida allo stile della documentazione Rocky Linux

*Rocky Linux è il Linux aziendale che sta crescendo più rapidamente al mondo e la sua documentazione sta crescendo in modo esponenziale grazie a collaboratori come voi. I vostri contenuti sono ben accetti in qualsiasi formato e i document stylist di RL vi aiuteranno ad allinearli agli standard qui indicati.*

## Introduzione

### A proposito

*Nuovi contributi sono benvenuti per far diventare questo sito il punto di riferimento definitivo sul web per le informazioni sull'uso di Rocky Linux. Potete creare documenti nel formato che ritenete più opportuno e il team di documentazione lavorerà con voi o vi aiuterà a formattarli in modo che sembrino parte della famiglia Rocky.*

Questa guida delinea gli standard di stile in lingua inglese per **migliorare la leggibilità, evidenziare casi particolari** e **migliorare il lavoro di traduzione** della documentazione Rocky Linux. Per le domande sullo stile non trattate in questa guida, si prega di fare riferimento a quanto segue:

* [Dizionario Merriam Webster](https://www.merriam-webster.com/)
* [Chicago Manual of Style (CMOS), 17a ed.](https://www.chicagomanualofstyle.org/home.html)

### Contribuire

Per una comprensione più completa della contribuzione, consultare le nostre guide correlate:

* [Rocky Linux Contribution Guide](https://docs.rockylinux.org/guides/contribute/) per i requisiti di sistema e software per iniziare.
* [Rocky Linux First Time Contributors Guide](../beginners/) per un orientamento su GitHub, la nostra base di documentazione.
* [Rocky Docs Formattazione](../rockydocs_formatting/) per la struttura Markdown.

## Linee guida di stile

*La documentazione di RL si propone di utilizzare un linguaggio chiaro e coerente, sia per garantire l'accessibilità che per aiutare gli sforzi di traduzione in corso.*

### Grammatica e Punteggiatura

Le **caratteristiche della scrittura tecnica** descritte nel Chicago Manual of Style sono le seguenti:

* Virgolette doppie ("stile Chicago") anziché singole (‘Oxford style’).
* I punti e le virgole vanno dentro le virgolette "così," anziché "così".
* Il trattino {shift}+{option}+{-} non ha spazi prima o dopo—come questo—ed è preferito per le frasi parentetiche.
* In un elenco di tre elementi, utilizzare una virgola prima di "e": "Piselli, senape, e carote"
* I titoli devono essere generalmente realizzati in stile titolo maiuscolo: La prima e l'ultima parola, così come tutti i nomi, i pronomi, i verbi e gli avverbi devono essere scritti in maiuscolo. Se il vostro documento funziona meglio con la capitalizzazione in stile frase, magari perché fate spesso riferimento ad acronimi, rendetela coerente all'interno dell'intero documento.
* I titoli non necessitano di un punto o di un punto e virgola alla fine, anche con una capitalizzazione di tipo frase, a meno che non terminino con un'abbreviazione.

### Voce e Tono

* **Linguaggio semplice.** Questo può essere descritto come uno stile *meno colloquiale*. La maggior parte della nostra documentazione rientra in questo standard.
    * Evitare metafore e modi di dire.
    * Dite quello che volete dire con il minor numero di parole possibile.
    * Identificare ed evitare termini inutilmente tecnici. Considerate che il vostro pubblico è costituito per lo più da persone che hanno una certa familiarità con l'argomento, ma che potrebbero non essere esperti della materia.
    * Eccezioni al linguaggio semplice:
        * Uno stile più colloquiale è appropriato per la documentazione rivolta ai neofiti o ai principianti o per la scrittura di contenuti come i post dei blog.
        * Uno stile di scrittura più formale o conciso è appropriato per la documentazione rivolta agli utenti avanzati o per la documentazione sulle API (Application Programming Interface).
* **Linguaggio inclusivo.**
    * L'uso della lingua si evolve nel tempo. Alcune parole si sono evolute assumendo una connotazione negativa, per cui la documentazione dovrebbe essere riscritta utilizzando parole nuove.
        * *Master/slave* diventa *primario/secondario* o uno standard organizzativo concordato.
        * La *blacklist/whitelist* diventa *blocklist/allowlist* o uno standard organizzativo concordato.
        * Si possono pensare altri esempi pertinenti durante la creazione della documentazione.
    * Quando si parla di una persona di genere *sconosciuto* o *non binario*, è ora considerato accettabile usare "loro" come pronome singolare.
    * Quando si parla delle proprie capacità, inquadrare le risposte come *abilità* piuttosto che come *limitazioni.* Ad esempio, se vi chiedete se abbiamo documentazione sull'esecuzione di Steam su Rocky Linux, la risposta non è semplicemente "no" Piuttosto, "Sembra che sia un ottimo posto per creare qualcosa da aggiungere al nostro albero!"
* **Evitare le contrazioni.** Questo facilita gli sforzi di traduzione. L'eccezione è rappresentata dalla scrittura di testi dal tono più colloquiale, come i post di un blog o le istruzioni di benvenuto per i nuovi membri della comunità.

## Formattazione

### Date

Se possibile, utilizzare il nome del mese nel formato {day} {Month} {year}. Tuttavia, {Month} {day}, {year} è accettabile anche per risolvere problemi di chiarezza o di aspetto. In ogni caso, per evitare confusione, scrivete i nomi dei mesi piuttosto che una serie di numeri. Ad esempio: 24 gennaio 2023, ma anche 24 gennaio 2023, entrambi preferibili a 1/24/2023 o 24/01/2023.

### Procedure a fase singola

Se si tratta di una procedura con una sola fase, utilizzare un punto piuttosto che un numero. Ad esempio:

* Implementate questa idea e andate avanti.

### Linguaggio di interfaccia grafica

* Istruzioni testuali relative a un'interfaccia utente: Quando si descrive un comando da inserire in un'interfaccia utente, utilizzare la parola "enter" piuttosto che "put" o "type" Utilizzate un blocco di codice per scrivere il comando (cioè, impostatelo con i backtick):

*Esempio di testo Markdown* `Nella casella **messaggio di commit**, inserire update_thisdoc.`

* Nomi di elementi dell'interfaccia utente: Nomi **in grassetto** di elementi dell'interfaccia utente come pulsanti, voci di menu, nomi di finestre di dialogo e altro, anche se la parola non sarà cliccabile:

*Esempio di testo Markdown* `Nel menu **Format**, fare clic su **Line Spacing**.`

## Struttura

### Contenuto iniziale di ogni guida o pagina/capitolo di un libro

* **Abstract.** Una breve dichiarazione di ciò che ci si aspetta da questa pagina
* **Obiettivi.** Un elenco puntato di ciò che questa pagina trasmetterà al lettore
* **Competenze** richieste/apprese.
* **Livello di difficoltà.** 1 stella per facile, 2 per intermedio, ecc.
* **Tempo di lettura.** Dividete il numero di parole del documento per una velocità di lettura di 75 parole al minuto per determinare questo numero.

### Ammonimenti

In Markdown, gli ammonimenti sono un modo per inserire le informazioni in un riquadro per evidenziarle. Non sono essenziali per la documentazione, ma sono uno strumento che può essere utile. Per saperne di più sugli ammonimenti, consultate il nostro [Rocky Formatting doc](../rockydocs_formatting/).

## Accessibilità

*I seguenti standard migliorano l'accessibilità per coloro che utilizzano dispositivi di ausilio, come gli screen reader, per accedere alla nostra documentazione.*

### Immagini

* Fornite descrizioni testuali in alt-text o didascalie per ogni elemento non testuale come diagrammi, immagini o icone.
* Se possibile, evitate le schermate di testo.
* Rendere l'alt-text significativo, non solo descrittivo. Per le icone di azione, ad esempio, inserire una descrizione della funzione piuttosto che una descrizione dell'aspetto.

### Link

* Rendete i link descrittivi, in modo che sia evidente la loro provenienza dal testo o dal contesto. Evitate i collegamenti ipertestuali con nomi come "clicca qui"
* Verificare che tutti i collegamenti funzionino come descritto.

### Tabelle

* Creare tabelle con un ordine logico da sinistra a destra, dall'alto in basso.
* Evitare le celle vuote nella parte superiore o sinistra della tabella.
* Evitare le celle unite che si estendono su più colonne.

### Colori

* Alcuni elementi di Markdown, come gli ammonimenti, hanno un colore assegnato per facilitare la comprensione visiva. In genere hanno anche un nome assegnato; per esempio, l'ammonimento "pericolo" visualizza un riquadro rosso, ma ha anche il descrittore "danger" incorporato nella descrizione. Quando si crea un'ammonimento personalizzato, però, bisogna tenere presente che il colore non può essere l'unico mezzo per comunicare un comando o un livello di avvertimento.
* Qualsiasi comando che includa una direzione sensoriale, come *sopra* o *sotto*, *colore*, *dimensione*, *posizione visiva* nella pagina, ecc. dovrebbe includere anche una direzione comunicabile con la sola descrizione testuale.
* Quando si crea un elemento grafico, assicurarsi che il contrasto tra i colori di primo piano e di sfondo sia sufficiente per facilitare l'interpretazione da parte di uno screen reader.

### Intestazioni

* Utilizzate tutti i livelli di intestazione senza saltare alcun livello.
* Annidate tutto il materiale con titoli che ne favoriscano la leggibilità.
* Ricordate che in Markdown è possibile utilizzare un solo titolo di primo livello.

## Sommario

Questo documento definisce i nostri standard di contribuzione, comprese le **linee guida di stile** le modalità di **strutturazione** del documento e i modi per incorporare l'**'inclusività** e l'**accessibilità** nel testo. Questi sono gli standard a cui aspiriamo. Per quanto possibile, tenete a mente questi standard quando create e modificate la documentazione.

Tuttavia - e non perdete questa avvertenza - trattate **questi standard come uno strumento, non come un ostacolo.** Nello spirito dell'inclusività e dell'accessibilità, vogliamo assicurarci che il vostro contributo entri senza problemi nell'albero genealogico di Rocky. Siamo un team amichevole e disponibile di documentaristi e stilisti e vi aiuteremo a portare il vostro documento alla sua forma finale.

Sei pronto? Cominciamo!
