---
title: Tracciamento e non tracciamento dei rami in Git
author: Wale Soyinka
contributors:
tags:
  - git
  - git branch
  - Tracking Branch
  - Non-Tracking Branch
---

## Introduzione

Questa Gemma approfondisce il tema del tracciamento e del non tracciamento dei rami in Git. Include anche i passaggi per verificare e convertire i tipi di ramo.

## Tracking Branch

Un ramo di monitoraggio è un ramo collegato a un ramo remoto.

1. Creare un nuovo ramo chiamato my-local-branch. Il nuovo ramo locale segue il ramo principale del repository remoto chiamato origin. Digitare:

   ```bash
   git checkout -b my-local-branch origin/main
   ```

2. Usare il comando `git branch -vv` per verificare che il ramo sia un ramo di tracciamento. Digitare:

   ```bash
   git branch -vv
   ```

   Cercare i rami con `[origin/main]` che indicano che stanno seguendo `origin/main`.

## Non-Tracking Branch

Un ramo non tracciante è un ramo che opera indipendentemente dai rami remoti.

1. Creare un nuovo ramo locale non tracciante chiamato my-feature-branch. Digitare:

   ```bash
   git checkout -b my-feature-branch
   ```

2. I rami non tracciati non mostreranno un ramo remoto accanto a loro output di git branch -vv. Controlla se my-feature-branch è un ramo non di tracciamento.

## Converting Non-Tracking in Tracking

1. Facoltativamente, assicurarsi prima che le ultime modifiche del ramo principale siano unite nel ramo di destinazione. Digitare:

   ```bash
   git checkout my-feature-branch
   git merge main
   ```

2. Impostare il monitoraggio di una ramo remoto:

   ```bash
   git branch --set-upstream-to=origin/main my-feature-branch
   ```

   Output: `Branch 'my-feature-branch' set up to track remote branch 'main' from 'origin'.`

3. Visualizzare le modifiche. Digitare:

   ```bash
   git branch -vv
   ```

   Ora, `my-feature-branch` dovrebbe mostrare `[origin/main]`, indicando che è in fase di tracciamento.

## Conclusione

Capire le sfumature tra rami tracciati e non tracciati è fondamentale in Git. Questa Gemma chiarisce questi concetti e dimostra anche come identificare e convertire tra questi tipi di ramo per una gestione ottimale del flusso di lavoro di git.
