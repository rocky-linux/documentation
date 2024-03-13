---
title: Flusso di lavoro Feature Branch in Git
author: Wale Soyinka
contributors: null
tags:
  - git
  - Feature Branch Workflow
  - GitHub
  - gh
  - git fetch
  - git add
  - git pull
  - git checkout
---

## Flusso di lavoro Feature Branch

Questo popolare flusso di lavoro git prevede la creazione di nuovi rami per ogni nuova funzionalità o correzione direttamente nel repository principale.
Di solito viene utilizzato in progetti in cui i collaboratori hanno accesso diretto al repository in modalità push.

Questa Gemma illustra il processo di creazione di un repository locale per lavorare e contribuire al progetto `rocky-linux/documentation` usando il flusso di lavoro Git Feature Branch.

L'utente "rockstar" ha effettuato il fork di questo repository e useremo `https://github.com/rockstar/documentation` come origine.

## Prerequisiti

- Un account GitHub e un fork del progetto (ad esempio, `https://github.com/rockstar/documentation`).
- `git` e `GitHub CLI (gh)` installati.

## Procedura

1. Se non è stato ancora fatto, clonare il vostro fork:
   ```bash
   git clone https://github.com/rockstar/documentation.git
   cd documentation
   ```
2. Aggiungere l'upstream remoto:
   ```bash
   git remote add upstream https://github.com/rocky-linux/documentation.git
   ```
3. Recuperare le modifiche a monte:
   ```bash
   git fetch upstream
   ```
4. Creare una nuova Feature Branch:
   ```bash
   git checkout -b feature-branch-name
   ```
5. Apportare le modifiche, aggiungere nuovi file e fare il commit:

   ```bash
   git add .
   git commit -m "Implementing feature X"
   ```
6. Tenete aggiornata il vostro Ramo. Unire regolarmente le modifiche provenienti dall'upstream per evitare conflitti:
   ```bash
   git pull upstream main --rebase
   ```
7. Spingere verso il vostro fork, digitare:
   ```bash
   git push origin feature-branch-name
   ```
8. Creare una Pull Request:
   ```bash
   gh pr create --base main --head rockstar:feature-branch-name --title "New Feature X" --body "Long Description of the feature"
   ```

## Conclusione

Il flusso di lavoro Feature Branch è una tecnica di collaborazione comune, che consente ai team di lavorare contemporaneamente su vari aspetti di un progetto mantenendo stabile la base di codice principale.

Le fasi di alto livello coinvolte sono:

1. Clonare il repository principale: Clonare direttamente il repository principale del progetto sul computer locale.
2. Creare una Feature Branch: Per ogni nuova attività, creare un nuovo ramo dal ramo principale con un nome descrittivo.
3. Inviare le modifiche: Lavorare sulla funzionalità o sulla correzione nel proprio ramo e inviare le modifiche.
4. Mantenere il ramo aggiornato: Eseguire regolarmente il merge o il rebase con il ramo principale per rimanere aggiornati con le sue modifiche.
5. Aprire una Pull Request: Una volta che la vostra funzionalità è pronta, spingere il ramo nel repository principale e aprite un PR per la revisione.
6. Revisione e integrazione del codice: Dopo la revisione e l'approvazione, il ramo viene unito al ramo principale.

_Benefici_:

- Semplifica i contributi per i collaboratori regolari con accesso diretto al repository.
- Assicura che ogni risorsa venga esaminata prima di essere integrata nel codice principale.
- Aiuta a mantenere una cronologia dei progetti pulita e lineare.
