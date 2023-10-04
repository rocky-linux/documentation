---
title: Pakete Signieren und Testen
---

# Pakete Signieren und Testen


Von uns erstellte RPMs sollten kryptografisch mit einem Rocky-Linux-Schlüssel signiert sein, der Benutzern garantiert, dass das Paket vom Rocky-Linux-Projekt kompiliert wurde.

Das Paket muss außerdem einigen Tests unterzogen werden – vorzugsweise automatisiert. Die Art der Tests muss noch festgelegt werden. aber wir werden zumindest einige Plausibilitätsprüfungen durchführen wollen, bevor wir es der Welt veröffentlichen. (Ist das Paket installierbar? Fehlen Dateien? Führt es zu Abhängigkeitskonflikten in dnf/yum? etc.)
