---
title: Aggiungere un repository remoto usando git CLI
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - GitHub
  - git
  - git remote
  - git fetch
---

## Introduzione

Questa Gemma illustra come aggiungere uno specifico repository remoto a un clone locale esistente di un progetto FOSS utilizzando l'interfaccia a riga di comando Git.
Utilizzeremo il repository del progetto di documentazione Rocky Linux come esempio di progetto FOSS - <https://github.com/rocky-linux/documentation.git>

## Prerequisiti

- Un account Github.
- Installazione di `git` sul sistema.
- Un clone locale di un repository di un progetto FOSS.

## Procedura

1. Aprite un terminale e cambiate la vostra directory di lavoro nella cartella contenente il clone locale del progetto.
  Per esempio, se si è clonato il repo github in ~/path/to/your/rl-documentation-clone, digitare

  ```bash
  cd ~/path/to/your/rl-documentation-clone
  ```

2. Prima di apportare qualsiasi modifica, elencare i remotes configurati. Digita:

  ```bash
  git remote -vv
  ```

  Se si tratta di un repo appena clonato, è probabile che nell'output si veda un solo remote chiamato `origin`.

3. Aggiungere il Rocky Linux Documentation Repository (`https://github.com/rocky-linux/documentation.git`) come nuovo remote al proprio repository locale. Qui assegneremo upstream come nome per questo particolare remote. Digita:

  ```bash
  git remote add upstream https://github.com/rocky-linux/documentation.git
  ```

4. Per sottolineare ulteriormente che i nomi assegnati ai repository remoti sono arbitrari, creare un altro remoto chiamato rocky-docs che punta allo stesso repo eseguendo:

  ```bash
  git remote add rocky-docs https://github.com/rocky-linux/documentation.git
  ```

5. Confermare che il nuovo repository remoto è stato aggiunto con successo:

  ```bash
  git remote -v
  ```

  Si dovrebbe vedere `upstream` elencato insieme al suo URL.

6. Opzionalmente, prima di iniziare ad apportare modifiche al repo locale, è possibile recuperare i dati dal nuovo remote aggiunto.
  Recuperare i rami e i commit del nuovo remoto eseguendo:

  ```bash
  git fetch upstream
  ```

## Note Aggiuntive

- _Origin_: È il nome predefinito che Git dà al repository remoto da cui è stato clonato. È come un soprannome per l'URL del repository. Quando si clona un repository, questo repository remoto viene automaticamente impostato come "origine" nella configurazione Git locale. Il nome è arbitrario ma convenzionale.

- _Upstream_: Spesso si riferisce al repository originale quando si fa il fork di un progetto.
  Nei progetti open-source, se si effettua un fork di un repository per apportare modifiche, il repository biforcato è il proprio "origin", mentre il repository originale è tipicamente indicato come "upstream". Il nome è arbitrario ma convenzionale.

  Questa sottile distinzione tra gli usi/assegnazioni di origine e remote è fondamentale per contribuire al progetto originale attraverso le richieste di pull.

## Conclusione

L'utilità git CLI semplifica l'uso di un nome descrittivo e l'aggiunta di un repository remoto specifico a un clone locale di un progetto FOSS. Ciò consente di sincronizzarsi con vari repository e di contribuirvi in modo efficace.
