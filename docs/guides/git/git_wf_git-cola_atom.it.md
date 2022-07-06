---
title: git Utilizzo di Git Cola e Atom
---

# flusso di Lavoro git per la Documentazione: git, Git Cola e Atom

Quindi, si vuole inviare della documentazione a questo repository. Beh, gli esperti di _git_ possono sempre darsi da fare e lavorare come fanno di solito, quindi inviarci le modifiche suggerite. Ma se siete più che altro dei principianti e state cercando un esempio di flusso di lavoro, questa guida può aiutarvi.

Va notato subito che non si tratta assolutamente di un documento definitivo. Ci sono molte opzioni per il flusso di lavoro di git; potreste non trovare questa di vostro gradimento, e va bene così. Potreste trovare parti di questo flusso di lavoro che vi piacciono e altre che non vanno bene per voi. Anche questo va bene.

Questo è un metodo, e l'autore spera che anche altri condividano i loro flussi di lavoro git, fornendo una ricchezza di opzioni per chiunque voglia contribuire alla documentazione di Rocky Linux.

## Prerequisiti e Presupposti

* Un desktop Rocky Linux (questa guida funziona anche su altre distro basate su RHEL e probabilmente anche su Fedora)
* Familiarità con la riga di comando
* Un account GitHub con accesso a chiave SSH

## I Componenti

Questo particolare flusso di lavoro utilizza i seguenti componenti:

* Un fork personale del repository della documentazione che si trova [qui](https://github.com/rocky-linux/documentation)
* Una copia clonata locale del repository su una workstation Linux
* Git Cola: un client visuale per il branching e lo staging di git (opzionale)
* L'editor Atom (opzionale)

---

!!! Note "Nota"

    Anche se Atom e Git Cola sono descritti come opzionali, per questo particolare flusso di lavoro è necessario almeno uno di essi. A questo autore piace usarli entrambi: uno per la parte GitHub (Git Cola) e uno per la parte di editing (Atom).

---

## Installazione dei Repository

Sono necessari solo un paio di repository. Il repository EPEL (Extra Packages for Enterprise Linux) e l'editor Atom.

Per installare EPEL, eseguire:

`sudo dnf install epel-release`

Poi, abbiamo bisogno della chiave GPG per Atom e per il repository:

`sudo rpm --import https://packagecloud.io/AtomEditor/atom/gpgkey`

E poi:

`sudo sh -c 'echo -e "[Atom]\nname=Atom Editor\nbaseurl=https://packagecloud.io/AtomEditor/atom/el/7/\$basearch\nenabled=1\ngpgcheck=0\nrepo_gpgcheck=1\ngpgkey=https://packagecloud.io/AtomEditor/atom/gpgkey" > /etc/yum.repos.d/atom.repo'`

Quindi aggiornare il sistema:

`sudo dnf update`

## Installazione dei Pacchetti

Eseguire il seguente comando per installare i pacchetti necessari con `dnf`:

`sudo dnf install git git-cola`

Ci saranno altri pacchetti installati come dipendenze, quindi è sufficiente rispondere "Y" per consentire l'installazione.

Quindi, installare l'editor Atom:

`sudo dnf install atom`

## Creazione di un Fork del Repository della Documentazione di Rocky Linux

Avrete bisogno di un vostro fork del repository. Questo diventerà uno dei vostri git remotes per questo flusso di lavoro.

Si presuppone che abbiate già creato il vostro account GitHub, che abbiate accesso alla chiave SSH e che abbiate effettuato l'accesso a [Documentation](https://github.com/rocky-linux/documentation).

Sul lato destro della pagina, fare clic su "Fork" (forchetta), come mostrato qui:

![Fork della Docementazione](../images/gw_fork.png)

Al termine, si dovrebbe avere un fork con un URL contenente il proprio nome utente. Se il nome utente di git fosse "alphaomega", l'URL sarebbe:

```
https://github.com/alphaomega/documentation
```

## Clonazione di una Copia Locale del Repository

Poi abbiamo bisogno di una copia locale del repository, cosa abbastanza facile da fare. Ancora una volta, nella [Documentazion](https://github.com/rocky-linux/documentation) di Rocky Linux, cercate il pulsante verde "Code" e fate clic su di esso:

![Documentation Code](../images/gw_greencode.png)

Una volta aperto, fare clic su SSH e copiare l'URL:

![Copia SSH Documentation](../images/gw_sshcopy.png)

Sulla vostra stazione di lavoro Linux, in una finestra di terminale, digitate il seguente comando dalla riga di comando:

`git clone`

Quindi incollare l'URL nella riga di comando, in modo da ottenere questo risultato:

`git clone git@github.com:rocky-linux/documentation.git`

Al termine di questo comando, si dovrebbe avere una copia locale del repository della documentazione. Questa operazione crea una directory chiamata "documentation" nella vostra home directory:

```
home:~/documentation
```

## Impostazione di Git Cola

Quindi, se si vuole configurare Git Cola, occorre aprire il repository "documentation" che abbiamo appena creato in locale e impostare i remotes. Questo è un passaggio facoltativo, ma a me piace farlo.

È possibile impostare i propri remotes con git anche tramite la riga di comando, ma trovo questo metodo più semplice, perché per me voglio che il remoto Rocky Linux si chiami in modo diverso da "origin", che è il nome predefinito.

Per me, penso al mio fork come a "origin" e alla documentazione di Rocky Linux come al repository "upstream". Si può non essere d'accordo.

Quando si apre Git Cola per la prima volta, viene chiesto di selezionare il repository. Potreste averne diversi sul vostro computer, ma quello che state cercando è quello chiamato "documentation." Fate quindi clic su questo e apritelo.

Una volta aperto il repository, configurare i remotes facendo clic su `File` e `Edit Remotes`.

Per impostazione predefinita, mostra già il vostro Rocky Linux remoto come "origin". Per modificarlo, è sufficiente fare clic nel campo, fare un backspace su "origin", sostituirlo con "upstream" e fare clic su "Save"

Poi, vogliamo creare un nuovo remotes che sia il vostro fork. Fare clic sul segno verde più (+) nell'angolo sinistro della parte inferiore dello schermo e si aprirà una nuova finestra di dialogo remota. Digitate "origin" per il nome e poi, supponendo che il nostro nome utente GitHub sia di nuovo "alphaomega", il vostro URL avrà questo aspetto:

```
git@github.com:alphaomega/documentation.git
```
Salvate e il gioco è fatto.

### Verificare che il flusso di lavoro funzioni effettivamente

Eseguite tutto questo dalla riga di comando. Passare alla directory della documentazione:

`cd documentation`

Quindi digitare:

`git pull upstream main`

In questo modo si verificherà che tutto sia configurato e funzionante per prelevare dall'upstream di  Rocky Linux.

Se non ci sono problemi, digitate quanto segue:

`git push origin main`

In questo modo si verificherà l'accesso al proprio fork della documentazione di Rocky Linux. Se non si verificano errori, questo comando può essere unito in futuro con:

`git pull upstream main && git push origin main`

Questo comando deve essere eseguito prima di creare qualsiasi ramo o di eseguire qualsiasi lavoro, per mantenere i rami sincronizzati.

## Una nota su Atom e Git Cola e sul perché l'autore li usa entrambi

L'editor Atom è integrato con git e GitHub. In effetti, è possibile utilizzare Atom senza bisogno di Git Cola. Detto questo, le visualizzazioni fornite da Git Cola sono più chiare dal punto di vista dell'autore. Le funzionalità dell'editor di Atom superano di gran lunga quelle degli editor di markdown (sempre secondo l'opinione dell'autore). Se lo si desidera, si può eliminare la necessità di Git Cola e utilizzare semplicemente Atom. È sempre possibile eliminare Atom e utilizzare un altro editor di markdown.

Uso Git Cola per impostare i remotes (come abbiamo già visto), per il branching e per il commit delle modifiche. Atom viene utilizzato solo come editor di testo e anteprima di markdown. Le operazioni di push e pull vengono eseguite dalla riga di comando.

## Branching con Git Cola

Si desidera sempre creare un ramo utilizzando il "main" come modello. Assicuratevi che "main" sia selezionato nell'elenco "Branches" sul lato destro di Git Cola, quindi fate clic sulla voce di menu superiore "Branch" e su "Create." Digitare un nome per il nuovo branch.

!!! Note "Nota"

    Quando si assegnano i nomi ai branches, si consiglia di utilizzare nomi descrittivi. Questi contribuiranno ad aggiungere chiarezza quando li spingerete a monte. Per esempio, l'autore usa il prefisso "rl_" quando crea un nuovo documento e poi aggiunge un nome breve descrittivo del documento stesso. Per le modifiche, l'autore usa "edit_" come prefisso, seguito da un breve nome che indica il motivo della modifica.

A titolo di esempio, qui sotto si può vedere l'elenco "Branches", che mostra "rl_git_workflow":

![git-cola Branches](../images/gw_gcbranches.png)

Quando si creano e si salvano le modifiche in Atom, si vedrà l'elenco "Unstaged Changes" nella vista git change:

![Atom Unstaged](../images/gw_atomunstaged.png)

Queste modifiche vengono visualizzate anche in Git Cola sotto la voce "Status" nella finestra di sinistra:

![git-cola Unstaged](../images/gw_gitcolaunstaged.png)

## Staging dei File con Git Cola

Una volta terminato il nostro documento siamo pronti a creare la richiesta di pull, la prima cosa da fare è scrivere una dichiarazione di commit. Nella maggior parte dei casi è più facile scrivere tutto prima di eseguire il commit dei file, perché non appena si mettono in scena i file, le modifiche scompaiono dalla vista.

La dichiarazione del commit deve essere il più chiara possibile. Il riepilogo del Commit deve indicare cosa si sta impegnando. Ad esempio: "Documento per Presentare un Flusso di Lavoro git" La descrizione estesa dovrebbe fornire i punti salienti del documento, ad esempio:

* flusso di lavoro git con Git Cola e Atom
* Include immagini corrispondenti

Una volta scritto il commit, ma prima di premere il pulsante "Commit", è necessario mettere in stage tutti i file ancora unstaged. A questo scopo, selezionare tutti i file, quindi fare clic con il pulsante destro del mouse e cliccare su "Stage Selected" Ora fate clic sul pulsante "Commit".

Prima di uscire da Git Cola, nella sezione "Branches" sulla destra, fare clic con il tasto destro del mouse su "main" e fare clic su "Checkout." Vogliamo essere controllati da main prima di inviare i nostri file.

## Pushing del Tuo Fork

Ora che tutto il lavoro di creazione dei documenti è stato fatto, è necessario fare il push del ramo al proprio fork. Se avete seguito la creazione dei remotes in precedenza, avete creato il vostro fork come "origin"

Dobbiamo entrare nella directory della documentazione nella finestra del terminale. In altre parole, nel clone del repository Rocky Documentation. Da una finestra di terminale, digitare:

`cd documentation`

Dovreste vedere la vostra home directory e il vostro cursore all'interno della documentazione:

`home:~/documentation$`

Ora dobbiamo fare il push delle nostre modifiche:

`git push origin rl_git_workflow`

Questo dice che stiamo facendo il push al nostro fork, il ramo che abbiamo appena creato e in cui abbiamo inserito un documento.

Quando inseriamo questo comando, riceviamo un messaggio da git che dice che è possibile creare una Pull Request. Avrà un aspetto simile a questo:

```
Enumerating objects: 16, done.
Counting objects: 100% (16/16), done.
Delta compression using up to 6 threads
Compressing objects: 100% (12/12), done.
Writing objects: 100% (12/12), 122.01 KiB | 2.22 MiB/s, done.
Total 12 (delta 4), reused 0 (delta 0)
remote: Resolving deltas: 100% (4/4), completed with 4 local objects.
remote:
remote: Create a pull request for 'rl_git_workflow' on GitHub by visiting:
remote:      https://github.com/alphaomega/documentation/pull/new/rl_git_workflow
remote:
To github.com:alphaomega/documentation.git
 * [new branch]      rl_git_workflow -> rl_git_workflow
```

## Aggiunta al Documento

Se improvvisamente ci si rende conto di avere altre cose da aggiungere al documento e non si vuole ancora fare il PR, non c'è problema.

Tornate a Git Cola, fate clic con il tasto destro del mouse sul vostro ramo (in questo caso "rl_git_workflow") e fate clic su "Checkout", quindi tornate a Atom, aprite di nuovo il documento e fate le modifiche necessarie. Qualsiasi modifica apportata al file o ai file dovrà essere nuovamente messa in stage e dovrà essere scritto un nuovo commit.

Al termine, è necessario fare clic con il tasto destro del mouse sul ramo "main" e cliccare di nuovo su "Checkout"; inoltre, è necessario eseguire nuovamente il push delle modifiche al proprio fork. La differenza è che, poiché l'URL per fare la richiesta di pull (PR) è già stato inviato, non lo si riceverà di nuovo. È necessario utilizzare il link originale che è stato inviato in precedenza.

## Attesa per il Merge del Vostro PR

Un redattore deve dare un'occhiata al vostro documento. Devono accertarsi che tutto ciò che avete fatto e scritto corrisponda alle linee guida, e magari apportare qualche modifica.

## Conclusione

Tutti coloro che utilizzano git hanno un flusso di lavoro leggermente diverso. Questo è quello dell'autore. Se avete un flusso di lavoro preferito, postatelo!
