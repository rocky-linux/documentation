---
Title: Introduzione
author: Spencer Steven
contributors: null
tags:
  - local docs
  - docs as code
  - linters
---

# Introduzione

L'uso di una copia locale della documentazione di Rocky Linux è utile per chi contribuisce spesso e ha bisogno di vedere esattamente come apparirà un documento nell'interfaccia web dopo la sua unione. I metodi qui inclusi rappresentano le preferenze dei collaboratori, ad oggi.

L'uso di una copia locale della documentazione è una fase del processo di sviluppo per coloro che aderiscono alla filosofia del "docs as code", un flusso di lavoro per la documentazione simile allo sviluppo del codice.

## Markdown linting

Oltre agli ambienti per l'archiviazione e la costruzione della documentazione, per alcuni scrittori potrebbe essere utile un linter per il markdown. I linters per Markdown sono utili per molti aspetti della scrittura dei documenti, tra cui i controlli di grammatica, ortografia, formattazione e altro ancora. A volte si tratta di strumenti o plugin separati per l'editor. Uno di questi strumenti è [markdownlint](https://github.com/DavidAnson/markdownlint), uno strumento Node.js. `markdownlint` è disponibile come plugin per molti editor popolari, tra cui Visual Studio Code e NVChad. Per questo motivo, nella radice della cartella della documentazione è incluso un file `.markdownlint.yml` che applicherà le regole disponibili e abilitate per il progetto. `markdownlint` è semplicemente un linter di formattazione. Controlla la presenza di spazi errati, elementi html in-line, doppie righe vuote, tabulazioni errate e altro ancora. Per la grammatica, l'ortografia, l'uso di un linguaggio inclusivo e altro ancora, installate altri strumenti.

!!! info "Avvertenza"

```
Nessuna delle sezioni di questa categoria ("Documentazione locale") è necessaria per scrivere documenti e sottoporli all'approvazione. Esistono per chi vuole seguire la filosofia [docs as code](https://www.writethedocs.org/guide/docs-as-code/), che prevede almeno una copia locale della documentazione.
```
