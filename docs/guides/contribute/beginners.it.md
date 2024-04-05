---
title: Guida al contributo per principianti
author: Krista Burdine
contributors: Ezequiel Bruni, Steven Spencer, Ganna Zhyrnova
tags:
  - contributing
  - documentation
  - beginners
  - howto
---

# Guida Iniziale del Contributore

*Tutti iniziano da qualche parte. Se questa è la prima volta che contribuite alla documentazione open source su GitHub, congratulazioni per aver fatto questo passo. Non vediamo l'ora di vedere cosa avete da dirci!*

## Git e GitHub

Tutte le nostre istruzioni per i collaboratori presuppongono che abbiate un account GitHub. Se non l'avete mai fatto, questo è il momento giusto. Se avete 12 minuti, imparate le basi di GitHub con la [Guida per principianti a Git e GitHub](https://www.udacity.com/blog/2015/06/a-beginners-git-github-tutorial.html) di Udemy.

Non è detto che si inizi a creare e gestire repository per Rocky Linux, ma questo [tutorial di Hello World](https://docs.github.com/en/get-started/quickstart/hello-world) vi guida nella creazione di un account GitHub, nell'apprendimento del gergo e nella comprensione del funzionamento dei repository. Si concentra sull'apprendimento di come effettuare un Commit per gli aggiornamenti dei documenti esistenti e su come creare una Richiesta di Pull.

## Markdown

Markdown è un linguaggio semplice che consente di includere formattazione, codice e testo normale nello stesso file. La prima volta che si aggiorna un documento, si segue il codice esistente. Non passerà molto tempo prima che siate pronti a esplorare altre funzioni. Quando arriva il momento, ecco le regole di base.

- [Markdown di base](https://www.markdownguide.org/basic-syntax#code)
- [Markdown Avanzato](https://www.markdownguide.org/extended-syntax/#fenced-code-blocks)
- Alcune delle opzioni [di formattazione](https://docs.rockylinux.org/guides/contribute/rockydocs_formatting/) più [avanzate](https://docs.rockylinux.org/guides/contribute/rockydocs_formatting/) che utilizziamo nel nostro repository

## Modifica del repository locale

Per creare un repository locale, occorre innanzitutto trovare e installare un editor Markdown che funzioni con il proprio computer e sistema operativo. Ecco alcune opzioni, ma ce ne sono altre. Utilizzate ciò che conoscete.

- [ReText](https://github.com/retext-project/retext) - Gratuito, multipiattaforma e open source
- [Zettlr](https://www.zettlr.com/) - Gratuito, multipiattaforma e open source
- [MarkText](https://github.com/marktext/marktext) - Gratuito, multipiattaforma e open source
- [Remarkable](https://remarkableapp.github.io/) - Linux e Windows, open source
- [NvChad](https://nvchad.com/) per l'utente vi/vim e il client nvim. Sono disponibili molti plugin per migliorare l'editor di markdown. Per un'esauriente serie di istruzioni per l'installazione, consultare [questo documento](https://docs.rockylinux.org/books/nvchad/).
- [VS Code](https://code.visualstudio.com/) - Parzialmente open source, di Microsoft. VS Code è un editor leggero e potente disponibile per Windows, Linux e MacOS. Per contribuire a questo progetto di documenti, è necessario ottenere le seguenti estensioni: Git Graph, HTML Preview, HTML Snippets, Markdown All in One, Markdown Preview Enhanced, Markdown Preview Mermaid Support e tutte le altre che vi interessano.

## Creare un repository locale

Una volta installato l'editor Markdown, seguire le istruzioni per collegarlo all'account GitHub e scaricare il repository sul computer locale. Ogni volta che ci si appresta ad aggiornare un documento, seguire questi passaggi per sincronizzare i fork locali e online con il ramo principale e assicurarsi di lavorare con la versione più recente:

1. Su GitHub, sincronizzare il fork del repository della documentazione con il ramo principale.
2. Seguire le istruzioni del proprio editor di Markdown per sincronizzare il fork corrente con la macchina locale.
3. Nell'editor Markdown, aprire il documento che si desidera modificare.
4. Modificare il documento.
5. Salvare.
6. Fare il Commit delle modifiche nell'editor, che dovrebbe sincronizzare il repository locale con il fork online.
7. Su GitHub, trovare il documento aggiornato nel proprio fork e creare una Richiesta di Pull per unirlo al documento principale.

## Inviare l'aggiornamento

*Aggiungete una parola mancante, correggete un errore o chiarire una parte di testo confusa.*

1. Iniziare dalla pagina che si desidera aggiornare.

    Fare clic sulla matita "Edit" nell'angolo superiore destro del documento che si desidera aggiornare. Si accede al documento originale su GitHub.

    La prima volta che si contribuisce al repository RL, comarirà un pulsante verde con la scritta "**Fork** this **repository** and propose changes" In questo modo si crea una copia duplicata del repository RL in cui si apportano le modifiche suggerite. È sufficiente fare clic sul pulsante verde e continuare.

2. Apportare le modifiche

    Seguire la formattazione Markdown. Forse manca una parola, o il link alla riga 21 deve essere sistemato, ad esempio. Apportare le modifiche necessarie.

3. Proporre modifiche

    In fondo alla pagina, scrivere una descrizione di una riga nel titolo del blocco intitolato "**Propose changes"**. È utile, ma non necessario, fare riferimento al nome del file che si trova all'inizio del documento.

    Quindi, se si aggiorna un collegamento nella riga 21 del testo markdown, si dovrebbe dire qualcosa come "Update README.md with correct links."

    **Nota: scrivere l'azione al presente.**

    Quindi fare clic su  Propose changes, per fare il **Commit** delle modifiche in un documento completo all'interno del repository biforcuto.

4. Modifiche alla revisione

    Ora è possibile esaminare ciò che si è fatto, riga per riga. Ti sei perso qualcosa? Tornate alla pagina precedente e correggetela di nuovo (dovrete ricominciare da capo), quindi fate di nuovo clic su Propose Changes.

    Una volta che il documento è come lo si desidera, fare clic sul pulsante verde Create Pull Request. In questo modo si ha un'ulteriore possibilità di ricontrollare le modifiche e confermare che il documento sia pronto.

5. Creare un Pull Request

    Tutto il lavoro svolto finora è stato fatto nel proprio repository, senza la possibilità di danneggiare il repository principale di RL. Successivamente, la si sottopone al team di documentazione per unire la propria versione a quella principale del documento.

    Fare clic sul pulsante verde grande che dice Create Pull Request. Buone notizie, non avete ancora rotto nulla, perché ora il tutto passa al team di documentazione di RL per la revisione.

6. Attendi

    Una volta ricevuta la richiesta, il team RL risponderà in uno dei tre modi seguenti.

    - Accettare e unire la vostra PR
    - Commentare con un feedback e chiedere modifiche
    - Negare il PR con una spiegazione

    L'ultima risposta è improbabile. Vogliamo davvero includere il vostro punto di vista! Se dovete apportare delle modifiche, capirete immediatamente perché avete bisogno di un repository locale. Il team potrà [spiegarvi](https://chat.rockylinux.org/rocky-linux/channels/documentation) cosa fare in seguito. La buona notizia è che il problema è ancora risolvibile. Seguite la sezione dei commenti di tale richiesta per vedere quali ulteriori informazioni sono richieste.

    In caso contrario, la richiesta verrà accettata e unita. Benvenuto nel team, ora sei ufficialmente un collaboratore! Tra qualche giorno il vostro nome apparirà nell'elenco dei collaboratori in fondo alla Guida dei collaboratori.
