---
title: KI-gestützte Beitragsrichtlinien
authors: Wale Soyinka, Steven Spencer, Documentation Team
contributors: Steven Spencer, Ganna Zhyrnova
---

!!! note

    Die Richtlinie für KI-gestützte Beiträge dieses Rocky Linux-Dokumentationsprojekts basiert auf der [Richtlinie für KI-gestützte Beiträge](https://docs.fedoraproject.org/en-US/council/policy/ai-contribution-policy/), die vom Fedora-Projekt entwickelt wurde, und erweitert diese. Änderungen und Überarbeitungen sind vorbehalten.

Sie _DÜRFEN_ KI-Unterstützung für Ihre Beiträge zum Rocky Linux Dokumentationsprojekt nutzen, solange Sie die unten beschriebenen Grundsätze einhalten.

## Verantwortlichkeit

- Sie _MÜSSEN_ die Verantwortung für Ihren Beitrag übernehmen.
- Wer zu Rocky Linux beiträgt, bürgt für die Qualität, die Einhaltung der Lizenzbestimmungen und den Nutzen seines Beitrags.
- Alle Beiträge, ob von einem menschlichen Autor oder mithilfe großer Sprachmodelle (LLMs) oder anderer generativer KI-Werkzeuge erstellt, müssen den Aufnahmekriterien des Projekts entsprechen.
- Der Beitragende ist stets der Autor und trägt die volle Verantwortung für den gesamten Inhalt seiner Beiträge.

## Transparenz

- Sie _MÜSSEN_ die Verwendung von KI-Tools offenlegen, wenn der wesentliche Teil des Beitrags unverändert aus einem Tool stammt.
- Sie _SOLLTEN_ die anderen Einsatzmöglichkeiten von KI-Tools offenlegen, bei denen diese nützlich sein könnten.
- Die routinemäßige Verwendung von Hilfsmitteln zur Korrektur von Grammatik und Rechtschreibung oder zur Verdeutlichung von Formulierungen erfordert keine Offenlegung. Informationen über den Einsatz von KI-Tools helfen uns, deren Auswirkungen zu bewerten, neue Best Practices zu entwickeln und bestehende Prozesse anzupassen. Offenlegungen erfolgen dort, wo üblicherweise eine Urheberschaft angegeben wird.
- Für Beiträge, die in Git verfolgt werden, empfiehlt sich die Verwendung eines Commit-Nachrichten-Trailers mit dem Präfix `Assisted-by:`.
- Bei Beiträgen von Drittanbietern muss ein entsprechender Hinweis in der Präambel des Dokuments oder in einem anderen Abschnitt der Dokumentmetadaten enthalten sein.

Beispiele:

  ```text
  ---
  title: 
  author: Steven Spencer
  contributors: Ganna Zhyrnova, Colussi Franco, tianci li, Wale Soyinka 
  ai-contributors: Claude (claude-sonnet-4-20250514), Gemini (gemini-2.5-pro)
  ---
  ```

## Beitrags- und Gemeinschaftsbewertung

- KI-Tools können zur Unterstützung menschlicher Reviewer eingesetzt werden, indem sie Analysen und Vorschläge liefern.
- Sie dürfen KI _NICHT_ als alleiniges oder endgültiges Entscheidungsinstrument bei der Beurteilung eines Beitrags verwenden, weder inhaltlich noch subjektiv, noch darf sie dazu verwendet werden, den Status einer Person innerhalb der Gemeinschaft zu bewerten (z. B. im Hinblick auf Finanzierung, Führungsrollen oder Fragen des Verhaltenskodex).
- Dies schließt den Einsatz automatisierter Werkzeuge zur objektiven technischen Validierung, wie z. B. CI/CD-Pipelines, automatisierte Tests oder Spamfilter, nicht aus.
- Die endgültige Verantwortung für die Annahme eines Beitrags, auch wenn dies von einem automatisierten System umgesetzt wird, liegt stets bei dem menschlichen Beitragenden, der die Aktion autorisiert.

## Groß angelegte Initiativen

Die Richtlinie deckt keine groß angelegten Initiativen ab, die die Arbeitsweise des Projekts erheblich verändern oder in einigen Teilen des Projekts zu einem exponentiellen Anstieg der Beiträge führen könnten. Solche Initiativen müssen gesondert mit der Projektleitung besprochen werden.

## Respekt für bestehende Beiträge

- Sie dürfen keine KI-generierten Beiträge einreichen, die hauptsächlich auf der Arbeit anderer Mitwirkender basieren oder im Wesentlichen eine Überarbeitung dieser Arbeit darstellen.
- KI-gestützte Bearbeitungen _SOLLTEN_ die ursprüngliche Intention, den Stil und die Struktur des Textes des Autors bewahren.

Bedenken hinsichtlich möglicher Richtlinienverstöße sollten als [Problem über diesen Link](https://github.com/rocky-linux/documentation/issues) gemeldet werden

Die Schlüsselwörter `MAY`, `MUST`, `MUST NOT` und `SHOULD` in diesem Dokument bzw. im Originaldokument sind gemäß der Beschreibung unter folgendem Link auszulegen: <https://datatracker.ietf.org/doc/html/rfc2119>[RFC 2119].
