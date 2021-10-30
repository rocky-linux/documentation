# Guida al contributo

## Introduzione

Quindi vuoi contribuire alla documentazione di Rocky Linux ma non sei sicuro sul come farlo? Sei arrivato nel posto giusto. Siamo entusiasti di averti a bordo con noi.

Uno dei nostri grandi obiettivi per Rocky è non solo avere una buona, ma un'OTTIMA documentazione, e non possiamo farlo da soli. Questo documento ti introdurrà, e rimuoverà (si spera) qualsiasi preoccupazione che potresti avere sul fatto di farlo. Siamo sempre qui per aiutarti, quindi sentiti libero di fare domande e aderire alle conversazioni.

## Oggetto della documentazione

Se puoi sognarlo — o meglio ancora, l'hai già fatto prima — allora il tuo argomento è probabilmente importante per il progetto di documentazione Rocky Linux.
Ora che è disponibile un rilascio di Rocky Linux, ci aspettiamo che le richieste di documentazione aumentino.

È qui che entri in gioco — sia ora che in futuro! Se hai esperienza con qualsiasi cosa relativa a Linux, e puoi tradurla per Rocky Linux, allora vogliamo che inizi subito a scrivere!

## Da dove iniziare

Mentre è possibile creare documentazione in qualsiasi formato, il formato preferito è il Markdown. Puoi facilmente creare documenti in Markdown, in più il Markdown è super-facile da imparare. Il modo migliore per iniziare con il Markdown è avere un editor di Markdown installato e leggere il tutorial. È possibile creare file di Markdown con qualsiasi editor di testo, ma la maggior parte degli editor di Markdown ti consente di visualizzare in anteprima cosa hai già inserito, quindi possono essere molto utili.

### Editor di Markdown

Come abbiamo già detto, il modo migliore per creare file di Markdown, in particolare se non lo hai già fatto prima, è quello di prendere un editor per il sistema operativo che usi sul tuo PC o sul tuo laptop. Una semplice ricerca web per "Markdown editors" ti mostrerà molte opzioni tra le quali poter scegliere.

Scegli uno che è compatibile con il tuo sistema operativo e inizia. Questo particolare documento How-To è stato creato con [ReText](https://github.com/retext-project/retext), un editor di Markdown multipiattaforma. Di nuovo, se preferisci creare i tuoi file di Markdown nel tuo editor di testo con il quale hai già familiarità, va benissimo lo stesso.

#### Editor di markdown alternativi

ReText è buono, ma se hai voglia di esplorare le altre opzioni, quì ce ne sono alcuni:

* [Zettlr](https://www.zettlr.com) - Gratuito, multipiattaforma e open source
* [Mark Text](https://marktext.app) - Gratuito, multipiattaforma e open source
* [ghostwriter](https://wereturtle.github.io/ghostwriter/) - Gratuito, Windows e Linux, open source
* [Remarkable](https://remarkableapp.github.io) - Solo Linux, open source
* [Typora](https://typora.io) - Gratis e cross-platform, ma *non* open source

### Tutorial sul markdown

Puoi avere una buona introduzione su come scrivere i file di Markdown, dando un'occhiata a [Mastering Markdown](https://guides.github.com/features/mastering-markdown/). Questa risorsa online ti farà fare pratica in pochissimo tempo.

## Usare Git

Rocky Linux, come molti altri progetti, utilizza "git" per gestire il suo codice e i suoi file, compresi i file di documentazione. Questo tutorial assume una conoscenza molto semplice di git, e di come funziona. Il secondo esempio presuppone anche familiarità con la riga di comando.

I passaggi elencati di seguito ti mostreranno come fare. Intanto (e fino a quando non sviluppiamo inevitabilmente la nostra guida), Puoi imparare Git in-profondità con questo [corso free Udacity](https://www.udacity.com/course/version-control-with-git--ud123). Se non hai il tempo necessario per farlo, ecco [una breve guida](https://blog.udacity.com/2015/06/a-beginners-git-github-tutorial.html).

Per inviare il tuo testo, ti chiediamo di creare un account GitHub. Quando sei pronto per inviare la tua documentazione scritta per l'approvazione, segui questi semplici passaggi:

### Con la GUI GitHub

La maggior parte dei compiti può essere completata dalla GUI Web su GitHub. Ecco un esempio su come aggiungere un file che hai creato sulla macchina locale alla repository GitHub della documentazione di Rocky Linux.

1. Accedi al tuo GitHub account.
2. Passa al repository di documentazione Rocky Linux su: [https://github.com/rocky-linux/documentation.git](https://github.com/rocky-linux/documentation.git)
3. Dovresti essere sul ramo "main", quindi controlla l'etichetta a discesa verso il basso nella sezione centrale, solo per essere sicuro di essere nel posto giusto. Il tuo documento alla fine potrebbe non finire nel ramo "main", gli amministratori lo posizioneranno dove si adatta logicamente più tardi.
   Sul lato destro della pagina, fare clic sul pulsante "Fork", che creerà la propria copia della documentazione.
4. Nel mezzo della pagina sul fork creato, giusto a sinistra del menù a tendina verde "Code", c'è il tasto "Add file". Fai clic su questo e scegli l'opzione "Upload files".
5. Questo ti darà modo di trascinare e rilasciare i file da caricare, o caricarli navigando sul tuo computer. Vai avanti e usa il metodo con cui ti trovi più a tuo agio.
6. Una volta caricato il file, la prossima cosa che devi fare è creare una richiesta di Pull. Questa richiesta consente agli amministratori dell'upstream di sapere che hai un nuovo file (o files) che vorresti fondere con il Master.
   Clicca su "Pull Request" nella parte superiore sinistra dello schermo.
7. Scrivi un breve messaggio nella sezione "Write" in modo da far sapere agli amministratori cosa hai fatto. (Nuovo documento, revisione, cambiamento suggerito, etc.,) quindi invia il tuo cambiamento.

### Dalla Git Command-Line

Se preferisci eseguire Git localmente sulla tua macchina, puoi clonare il repository di documentazione di Rocky Linux, fare i cambiamenti, e quindi fare un commit delle modifiche. Per rendere le cose super-facili, i passaggi 1-3 sono preferibilmente da fare dalla *Git Gui* come spiegato sopra poi:

1. Clona il repository Git: `git clone https://github.com/your_fork_name/documentation.git`
2. Ora, sulla tua macchina, aggiungi il file alla directory.
   Esempio: `mv /home/myname/help.md /home/myname/documentation/`
3. Quindi, esegui git add del file selezionato.
   Esempio:  `git add help.md`
4. Ora, esegui un git commit per le modifiche apportate.
   Esempio: `git commit -m "Added the help.md file"
5. Quindi, spingi (push) le modifiche al repository clonato: `git push https://github.com/your_fork_name/documentation main`
6. Quindi, ripetiamo il passaggio 6 e 7 sopra: ...crea un Pull Request. Questa richiesta consente agli amministratori upstream di sapere che hai un nuovo file (o files) che vorresti che si fondessero con il ramo principale. Clicca su "Pull Request" nella parte superiore sinistra dello schermo

Una volta fatto tutto ciò, attendi semplicemente la conferma che la tua richiesta venga inserita. (O no, a seconda dei casi.)

## Tieniti aggiornato con la Conversazione

Se non l'hai già fatto, unisciti alla conversazione sul [Rocky Linux Mattermost Server](https://chat.rockylinux.org/rocky-linux/) e rimani aggiornato su ciò che sta succedendo. Iscriviti su [~Documentation channel](https://chat.rockylinux.org/rocky-linux/channels/documentation), o qualsiasi altro canale a cui sei interessato. Saremo lieti di averti con noi!
