---
title: Versioni dei documenti utilizzando due remote
author: Steven Spencer
contributors: Ganna Zhyrnova
tags:
  - contributing
  - documentation
  - versioning
---

## Introduzione

All'inizio dell'autunno del 2025, il team di documentazione è passato da un'unica versione della documentazione che copriva tutte le versioni a una versione con un proprio ramo di documentazione. Ciò rende più facile distinguere le istruzioni da una versione all'altra. Tuttavia, ciò complica il processo di scrittura o correzione della documentazione, in particolare se si tratta di una delle versioni precedenti (Rocky Linux 8 o 9). Il presente documento delinea una strategia per affrontare questo processo utilizzando un approccio a doppio controllo remoto.

!!! info "Versioni di Rocky Linux"

    A partire da questa data, Ottobre 2025, le versioni sono le seguenti:
    
    | Ramo | Versione |
    |--------|---------|
    | main   | Rocky Linux 10 |
    | rocky-9 | Rocky Linux 9 |
    | rocky-8 | Rocky Linux 8 |

## Prerequisiti

- Un account GitHub personale con [chiavi SSH già in uso](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)
- Un fork esistente della documentazione di Rocky Linux
- Una conoscenza di base dell'uso di `git` dalla riga di comando o la volontà di imparare
- Avere installato l'utilità `git`

## Clonare la repository

La clonazione del repository Rocky Linux sposta una copia della documentazione Rocky Linux nella workstation dell'utente in una directory denominata `/documentation`. Potreste aver letto da qualche parte, o su altri progetti GitHub, di clonare sempre dal vostro fork personale del progetto. In questo caso, affinché il clone sia consapevole della versione, non è così. Si deve  clonare da Rocky Linux project. Questo documento vi spiegherà perché è così man mano che si procede. Inoltre, si dovrà rinominare i vostri remote git in modo che abbiano un senso logico (Rocky Linux “upstream” e il tuo GitHub “origin”).

1. Clonare la documentazione di Rocky Linux:

    ```bash
    git clone git@github.com:rocky-linux/documentation.git
    ```

2. Passare alla directory `/documentation`:

    ```bash
    cd documentation
    ```

3. Controllare il nome remoto:

    ```bash
    git remote -v
    ```

   Questo ci darà:

    ```bash
    origin git@github.com:rocky-linux/documentation.git (fetch)
    origin git@github.com:rocky-linux/documentation.git (push)
    ```

   Si vuole che questa risorsa sia “upstream” anziché “origin”.

4. Cambiare il nome remoto

    ```bash
    git remote rename origin upstream
    ```

   Eseguire nuovamente il comando `git remote -v` mostrerà il seguente risultato:

    ```bash
    upstream git@github.com:rocky-linux/documentation.git (fetch)
    upstream git@github.com:rocky-linux/documentation.git (push)
    ```

## Aggiungere il vostro fork come remoto

Dopo aver aggiunto il remote di Rocky Linux e averlo denominato correttamente, è necessario aggiungere il proprio fork GitHub personale come remote di origine.

1. Per questo passaggio, si dovrà conoscere il nome utente GitHub, che dovreste già sapere. Sostituire il campo “[nome utente]” con il nome corretto. Aggiungete il vostro remote:

    ```bash
    git remote add origin git@github.com:[username]/documentation.git
    ```

2. Controllate il vostro git remote:

    ```bash
    git remote -v
    ```

   Questo ci darà:

    ```bash
    origin git@github.com:[username]/documentation.git (fetch)
    origin git@github.com:[username]/documentation.git (push)
    upstream git@github.com:rocky-linux/documentation.git (fetch)
    upstream git@github.com:rocky-linux/documentation.git (push)
    ```

## Verifica degli aggiornamenti e aggiungere dei rami di versione al vostro fork

1. Una volta aggiunti i remote, iniziare a scaricare eventuali aggiornamenti dall'upstream e inviandoli all'origin. Se si è appena creato il vostro fork e i vostri remote, non ci saranno aggiornamenti da inviare, ma è una buona idea iniziare con questo:

    ```bash
    git pull upstream main && git push origin main
    ```

2. Controllare uno dei due rami della versione precedente:

    ```bash
    git checkout rocky-8
    ```

       !!! warning "Questo non funziona se il vostro clone proviene dal vostro fork"

        ```
         Questo è il motivo per cui il processo di clonazione viene eseguito da Rocky Linux anziché dal vostro fork. Il vostro fork non sarà a conoscenza dei rami più vecchi. Per ottenere il messaggio che segue, si deve *necessariamente* clonare il vostro repository di documentazione locale da Rocky Linux. 
        ```

   Se si è configurato correttamente i remote, ora si vedrà:

    ```bash
    branch 'rocky-8' set up to track 'upstream/rocky-8'.
    Switched to a new branch 'rocky-8'
    ```

   Questo crea effettivamente un ramo locale `rocky-8`. Il passo successivo è quello di recuperare tutte le modifiche da “rocky-8” e inviarle alla vostra origin. Non dovrebbero esserci modifiche a livello locale, ma il ramo non esiste sul vostro fork, quindi questo processo lo creerà:

    ```bash
    git pull upstream rocky-8 && git push origin rocky-8
    ```

   Probabilmente si riceverà un messaggio che vi informerà la possibilità di creare una richiesta pull dal push. Si può ignorare questo messaggio. Quello che è successo è che il tuo fork ora ha un ramo `rocky-8`.

3. Controllare il branch più vecchio rimanente. (`rocky-9`) e ripeti i passaggi appena eseguiti con quel ramo.

Una volta completato, si avrà ora i rami `main`, `rocky-8` e `rocky-9` sul vostro fork e clone locale e si potrà scrivere la documentazione su uno qualsiasi di questi rami.

## Scrivere un documento o aggiornare un documento esistente su una versione precedente

Se si ha familiarità con la scrittura di una richiesta pull (PR) sul ramo `main` della documentazione, questo processo funziona ancora come sempre. Ricordare solo che `main` è per la versione più recente (10 al momento della stesura di questo articolo). Per apportare una piccola modifica a una delle versioni precedenti, è necessario innanzitutto creare un ramo per la modifica locale basato su quel ramo. Per farlo, usare l'opzione `-b` con il comando `git checkout`. Questo comando crea un ramo chiamato `8_rkhunter_changes` e lo basa sul ramo `rocky-8`:

```bash
git checkout -b 8_rkhunter_changes rocky-8
```

Ora si può modificare il file che si desidera modificare e verrà utilizzata la versione di quel documento presente nel ramo `rocky-8`.

Una volta completata la modifica, salvarla, preparala e conferma le modifiche come di consueto, quindi inviare le modifiche al vostro remote `origin`:

```bash
git push origin 8_rkhunter_changes
```

Quando crei la PR, però, GitHub penserà automaticamente che stai creando una PR per modificare il ramo `main`, anche se hai specificatamente utilizzato il ramo `rocky-8` durante la modifica del documento. Fai attenzione a non creare troppo rapidamente il PR quando vedi questa schermata di confronto errata:

![Wrong comparison](../images/incorrect_comparison_branchb_blur.png)

Quello che si deve fare qui è cambiare il ramo di confronto con quello corretto (in questo caso `rocky-8`):

![Right comparison](../images/correct_comparison_branch_blur.png)

Dopo aver corretto il ramo di confronto, continua a creare la PR e poi attendere l'unione della vostra PR.

## Aggiornamento dei rami delle versioni precedenti dopo un merge

Proprio come per il ramo `main`, è buona norma mantenere aggiornati i rami delle versioni precedenti con eventuali modifiche. La seguente serie di comandi aggiornerà _tutte_ le vostre versioni in modo che corrispondano all'upstream:

```bash
git checkout rocky-8
git pull upstream rocky-8 && git push origin rocky-8
git checkout rocky-9
git pull upstream rocky-9 && git push origin rocky-9
git checkout main
git pull upstream main && git push origin main
```

Dopo aver completato questi comandi, tutti i vostri rami locali e il vostro fork saranno aggiornati.

## Conclusione

Questo documento illustra una strategia a doppio controllo remoto per gestire i nuovi documenti o le correzioni apportate dopo la creazione delle versioni dei documenti.
