---
title: Markdown Demo
author: Steven Spencer
contributors: Wale Soyinka, Tony Guntharp
tested_with: 8.5
tags:
  - Beispiel
  - crowdin
  - markdown
---

# Übersicht

## Hintergrund

- Verwendung von [Markdown](https://daringfireball.net/projects/markdown).
- 'markdown'-Kenntnisse.

Diese Anleitung demonstriert gängige Markdown-Auszeichnung-Elemente, die wir auf den Seiten [https://docs.rockylinux.org](https://docs.rockylinux.org) verwenden, sowie das `Admonition`-Element, das nicht im Standard-Markdown enthalten ist.

## Die Demo

> Dies ist ein Beispiel für ein Zitat. Hübsch formatiert.

Manchmal verwenden wir Dinge wie _dieses_.

Wie wäre es mit **bold face**

Meistens handelt es sich um normalen Text wie dieser.

Manchmal wird ein `Befehl` hervorgehoben

Oder mehrere Befehle:

```bash
dnf install my_stapler
dnf update my_pencil
dnf remove my_notepad
systemctl enable my_stapler
```

In manchen Fällen benötigen wir Aufzählungen oder nummerierte Listen:

- Kugelschreiber
- Kompass
- Bleistift
- Heft

1. Mathematik
2. Physik
3. Chemie

Sie werden auch das Admonition-Auszeichnungselement benötigen:

### Admonitions

Die ebenfalls erwähnten Admonitions eignen sich hervorragend zum Einfügen zusätzlicher Inhalte, ohne den Fluss des Dokuments wesentlich zu unterbrechen. Material für MkDocs bietet mehrere Arten von Admonitions und ermöglicht die Einbindung und Verschachtelung beliebiger Inhalte.

!!! tip "Tip"

    Pencils and staplers are old-school.

#### Verwendung

Admonitions folgen einer einfachen Syntax: Ein Block beginnt mit `!!!`, gefolgt von einem **Schlüsselwort**, das als Typ-Qualifizierend verwendet wird. Der Inhalt des Blocks folgt in der nächsten Zeile, mit vier Leerzeichen eingerückt:

!!! note "Notiz"

    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla et euismod
    nulla. Curabitur feugiat, tortor non consequat finibus, justo purus auctor
    massa, nec semper lorem quam in massa.

#### Den Titel ändern

Standardmäßig entspricht der Titel dem Typ-Qualifizierenden in der Titelschreibweise. Sie können dies jedoch ändern, indem Sie nach dem Typ-Qualifizierenden eine in Anführungszeichen gesetzte Zeichenfolge mit gültigem Markdown (einschließlich Links, Formatierung usw.) hinzufügen:

!!! note "Phasellus posuere in sem ut cursus"

    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla et euismod
    nulla. Curabitur feugiat, tortor non consequat finibus, justo purus auctor
    massa, nec semper lorem quam in massa.

Wenn ein Befehl mehrere Optionen hat oder Sie bestimmte Optionen auflisten müssen, können Sie zur Identifizierung häufig eine Tabelle verwenden:

| Tool           | Verwendung                                  | Zusätzliche Informationen                       |
| -------------- | ------------------------------------------- | ----------------------------------------------- |
| Stift          | Schreiben.                                  | kann durch einen Kugelschreiber ersetzt werden  |
| Kugelschreiber | Schreiben oder drucken                      | kann durch ein Bleistift ersetzt werden         |
| Stylus         | writing or printing on an electronic device | wird manchmal durch eine Tastatur ersetzt       |
| Tastatur       | writing or printing on an electronic device | never replaced - used until full of food crumbs |
| notepad        | Notizen verfassen                           | bei zunehmender Vergesslichkeit unverzichtbar.  |
