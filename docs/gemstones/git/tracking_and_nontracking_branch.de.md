---
title: Tracking- vs. Non-Tracking-Branch in Git
author: Wale Soyinka
contributors:
tags:
  - git
  - git branch
  - Tracking Branch
  - Non-Tracking Branch
---

## Einleitung

Dieses Gemstone befasst sich mit Tracking- und Non-Tracking-Zweigen in Git. Es enthält auch Schritte zum Überprüfen und Konvertieren zwischen den Zweigtypen.

## Tracking Branch

Ein Tracking-Branch ist ein Zweig, der mit einem Remote-Branch verknüpft ist.

1. Erstellen Sie einen neuen Branch mit dem Namen `my-local-branch`. Sorgen Sie dafür, dass der neue lokale Zweig den Hauptzweig des Remote-Repositorys mit dem Namen `origin` verfolgt. Geben Sie bitte Folgendes ein:

   ```bash
   git checkout -b my-local-branch origin/main
   ```

2. Verwenden Sie den Befehl `git branch -vv`, um zu überprüfen, ob es sich bei dem Zweig um einen Tracking-Zweig handelt. Geben Sie bitte Folgendes ein:

   ```bash
   git branch -vv
   ```

   Suchen Sie nach Zweigen mit `[origin/main]`, was darauf hinweist, dass sie `origin/main` verfolgen.

## Non-Tracking Branch

Ein `Non-Tracking-Branch` ist ein Zweig, der unabhängig von `Remote-Branch`es arbeitet.

1. Erstellen Sie einen neuen lokalen Zweig ohne Nachverfolgung mit dem Namen `my-feature-branch`. Geben Sie bitte Folgendes ein:

   ```bash
   git checkout -b my-feature-branch
   ```

2. `Non-Tracking-Branches` zeigen in der Ausgabe von `git branch -vv` keinen `Remote-Branch` daneben an. Überprüfen Sie, ob `my-feature-branch` ein `Non-Tracking-Branch` ist.

## Konvertierung von Non-Tracking in Tracking

1. Stellen Sie optional zunächst sicher, dass die neuesten Änderungen aus dem Hauptzweig in den Zielzweig integriert werden. Geben Sie bitte Folgendes ein:

   ```bash
   git checkout my-feature-branch
   git merge main
   ```

2. Richten Sie das Tracking für ein Remote-Branch ein:

   ```bash
   git branch --set-upstream-to=origin/main my-feature-branch
   ```

   Ergebnis: `Branch 'my-feature-branch' set up to track remote branch 'main' from 'origin'.`

3. Änderung prüfen. Geben Sie bitte Folgendes ein:

   ```bash
   git branch -vv
   ```

   Jetzt sollte `my-feature-branch` `[origin/main]` anzeigen, was darauf hinweist, dass es sich um ein Tracking handelt.

## Zusammenfassung

Das Verständnis der Nuancen zwischen Tracking- und Nicht-Tracking-Branches ist in Git von entscheidender Bedeutung. Dieses Gemstone verdeutlicht diese Konzepte und zeigt auch, wie diese Branch-Typen identifiziert und zwischen ihnen konvertiert werden, um ein optimales Git-Workflow-Management zu gewährleisten.
