---
title: dconf – Config Editor
author: Ezequiel Bruni
contributors: Steven Spencer, Ganna Zhyrnova
---

## Einleitung

GNOME verfolgt bei seiner Benutzeroberfläche und seinen Funktionen einen sehr einfachen Ansatz. Das ist gut, weil es leicht zu erlernen ist und Sie mit der typischen GNOME-Erfahrung sofort loslegen können.

Dieser Ansatz führt allerdings auch dazu, dass die Einrichtung nicht so schnell geht. Wenn Sie im Einstellungsfenster nicht finden, was Sie benötigen, können Sie GNOME Tweaks installieren, um Ihre Optionen zu erweitern. Sie können sogar GNOME-Erweiterungen installieren, um neue Funktionen und Möglichkeiten zu erhalten.

Aber was ist, wenn Sie all die kleinen Optionen, Features und Konfigurationen sehen möchten, die die GNOME-Entwickler versteckt halten? Sie können online nach Ihrem aktuellen Problem suchen und einen Befehl eingeben, um die unbekannte Variable zu ändern, oder Sie können `dconf Editor` installieren.

„dconf Editor“ ist im Wesentlichen eine GNOME-Einstellungsanwendung, die _alles_ kann. Es erinnert Sie vielleicht ein wenig an die Windows-Registrierung und _sieht_ auch so aus. Es ist jedoch besser lesbar und deckt nur die GNOME-Funktionalität und einige für GNOME entwickelte Software ab.

Sie können auch die Einstellungen von GNOME-Erweiterungen bearbeiten.

!!! warning "Warnhinweis"

```
Der Vergleich mit der Windows-Registrierung war völlig beabsichtigt. Wie fehlerhafte Registrierungsschlüssel können *einige* GNOME-Shell-Einstellungen Ihre GNOME-Installation beschädigen oder zumindest Probleme verursachen. Möglicherweise müssen Sie die alten Einstellungen über die Befehlszeile wiederherstellen.

Wenn Sie nicht sicher sind, was eine bestimmte Einstellung bewirkt, recherchieren Sie sie zunächst. Das Ändern der Einstellungen einer App ist in Ordnung, aber es ist viel einfacher, sie rückgängig zu machen.
```

## Voraussetzungen

Für diese Anleitung benötigen Sie Folgendes:

- Rocky Linux inklusiv GNOME.
- Berechtigung, Software auf Ihrem System zu installieren (`sudo`-Rechte).

## `dconf Editor` — Installation

Gehen Sie zu `Software Center`, suchen Sie nach `Dconf Editor` und klicken Sie auf die Schaltfläche `Installieren`. Dies ist als Default im Standard-Rocky-Linux-Repository verfügbar.

![the GNOME software center, featuring dconf Editor](images/dconf-01.png)

Um den `dconf-Editor` über die Befehlszeile zu installieren, führen Sie die folgenden Schritte aus:

```bash
sudo dnf install dconf-editor
```

## `dconf Editor` – Verwendung

Sobald Sie die App öffnen, sehen Sie drei wichtige Teile der Benutzeroberfläche. Oben wird der Pfad angezeigt. Alle GNOME-Einstellungen liegen in einer Pfad-/Ordnerstruktur vor.

In der oberen rechten Ecke sehen Sie einen Button mit einem kleinen Stern. Dabei handelt es sich um einen `Favorites`-Button, der es Ihnen ermöglicht, den Zustand in der App zu speichern und später schnell und einfach dorthin zurückzukehren. Darunter befindet sich ein zentrales Bedienfeld, in dem Sie Settings-Unterordner auswählen und die Einstellungen nach Bedarf ändern können.

![a screenshot of the dconf Editor window with arrows pointing at the aforementioned elements](images/dconf-02.png)

Links neben der Schaltfläche `Favorites` befindet sich eine Suchschaltfläche, die genau das tut, was man erwartet.

Was ist, wenn Sie einige Einstellungen im Dateimanager ändern möchten? Dem Autor gefällt zum Beispiel die Seitenleiste. Der Autor hält es für ein sehr praktisches Hilfsmittel. Aber vielleicht sind Sie anderer Meinung und Sie möchten etwas verändern. Für diesen Leitfaden muss das also verschwinden.

![a screenshot of the Nautilus file manager, with a threatening red X over the doomed sidebar](images/dconf-03.png)

Gehen Sie zu `/org/gnome/nautilus/window-state` und Sie werden eine Option namens `start-with-sidebar` sehen. Klicken Sie auf den Schalter und klicken Sie auf die Schaltfläche `Reload `, wenn sie wie im Screenshot unten angezeigt wird:

![a screenshot of dconf Editor, showing the toggle and reload button in question](images/dconf-04.png)

Wenn alles gut gelaufen ist, sollte das nächste Dateibrowser-Fenster, das Sie öffnen, wie folgt aussehen:

![a screenshot of the file manager, bereft of its sidebar](images/dconf-05.png)

Wenn dies nicht der Fall ist, schalten Sie es zurück, klicken Sie erneut auf `Reload` und öffnen Sie ein neues Dateibrowserfenster.

Schließlich können Sie im Fenster `dconf Editor` direkt auf eine beliebige Einstellung klicken, um weitere Informationen (und manchmal auch weitere Settings) anzuzeigen. Hier sehen Sie beispielsweise den Einstellungsbildschirm `initial-size` für den GNOME-Dateimanager.

![a screenshot of dconf Editor showing the initial-size settings for the file manager](images/dconf-06.png)

## Problembehandlung

Wenn Sie Änderungen an Ihren Einstellungen im `dconf Editor` vornehmen und sich nichts ändert, versuchen Sie eine der folgenden Korrekturen:

1. Starten Sie die Anwendung neu, an der Sie Änderungen vornehmen möchten.
2. Melden Sie sich ab und wieder an oder starten Sie das System neu, um die GNOME-Shell zu ändern.
3. Geben Sie auf, denn diese Option ist einfach nicht mehr funktionsfähig.

Was Letzteres betrifft: Ja, die GNOME-Entwickler deaktivieren manchmal die Möglichkeit, Einstellungen zu ändern, sogar mit dem `dconf-Editor`.

Der Autor hat zum Beispiel versucht, die Einstellungen für den Fensterumschalter zu ändern (die Liste der geöffneten Fenster, die angezeigt wird, wenn Sie ++alt+tab++ drücken), aber es ist nichts passiert. Ganz gleich, was der Autor versuchte, der `dconf Editor` hat keinen Einfluss auf einige seiner Funktionen.

Nun könnte es sich um einen Fehler handeln, aber es wäre nicht das erste Mal, dass eine im `dconf-Editor` angezeigte Einstellung tatsächlich deaktiviert und ausgeblendet wird. Wenn dieses Problem auftritt, durchsuchen Sie die `GNOME-Extensions`-Seite, um zu sehen, ob es eine Erweiterung gibt, die die gewünschte Funktion wieder zu GNOME hinzufügt.

## Zusammenfassung

Das ist alles, was Sie wissen müssen, um loszulegen. Denken Sie daran, den Überblick über alle Ihre Änderungen zu behalten, ändern Sie keine Einstellungen, ohne genau zu wissen, was sie bewirken, und haben Sie Spaß daran, die Optionen zu erkunden, die Ihnen (meistens) zur Verfügung stehen.
