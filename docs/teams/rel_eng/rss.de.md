---
title: Rocky Linux RSS feeds
author: Release Engineering
contributors: Steven Spencer
---

Diese Seite behandelt die vom Rocky-Linux-Projekt bereitgestellten RSS-Feeds (Really Simple Syndication).

## Über RSS-Feeds

Rocky Linux stellt RSS-Feeds als alternative Möglichkeit bereit, Aktualisierungen der zahlreichen Repositorys für unterstützte Versionen von Rocky Linux zu verfolgen.

RSS-Feeds werden im öffentlichen Mirror angezeigt: [RSS-Feeds](https://dl.rockylinux.org/pub/feeds)

Release Engineering (SIG/Core) generiert diese Feeds [Toolkit](https://git.resf.org/sig_core/toolkit/src/branch/devel/mangle/generators/rss.py).

## Anmerkungen zu Aktualisierungszeiten

Die Feeds werden alle 30 Minuten aktualisiert. Wenn neue Pakete zu einem der Repositories hinzugefügt werden, erscheinen sie sofort beim nächsten Aktualisieren.

## Hinweise zu Paketen

Die Feeds zeigen die neuesten Pakete der letzten 30 Tage an. Wenn ein Paket älter als 30 Tage ist, wird es aus dem Feed entfernt.

## Hinweise zu Modulen

Einige Modulpakete werden möglicherweise nicht im Feed angezeigt. Dies gilt insbesondere für Rocky Linux 8. Das RSS-Feed-Skript ist derzeit nicht in der Lage, alle Module zu berücksichtigen. Nennenswerte Ausnahmen hiervon sind die Standard-Modul-Streams.
