---
title: rsync - Kurzbeschreibung
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2022-03-08
---

# Backup

Was ist ein Backup?

Unter Backup versteht man das Kopieren von Daten in ein Dateisystem oder eine Datenbank, sodass im Fehler- oder Katastrophenfall die effektiven Daten des Systems zeitnah und bequem wiederhergestellt werden können und das System normal wieder funktionieren kann. Im Falle eines Fehlers oder einer Katastrophe können die effektiven Daten des Systems rechtzeitig und normal wiederhergestellt werden.

Was sind die Backup-Methoden?

* Vollständige Sicherung: bezieht sich auf eine einmalige Kopie aller Dateien, Ordner oder Daten auf der Festplatte oder Datenbank. (Pros: kann Daten schneller wiederherstellen. Nachteil: nimmt einen größeren Festplattenspeicher in Anspruch.)
* Inkrementelle Sicherung: bezieht sich auf die Sicherung der Daten, die nach dem letzten vollständigen Backup oder inkrementellen Backup aktualisiert wurden. Der Prozess ist so, wie zum Beispiel ein vollständiges Backup am ersten Tag; eine Sicherung der neu hinzugefügten Daten am zweiten Tag, im Gegensatz zu einer vollständigen Sicherung; am dritten Tag, eine Sicherung der neu hinzugefügten Daten auf Basis des zweiten Tages relativ zum nächsten Tag, und so weiter.
* Differentielle Sicherung: Bezieht sich auf die Sicherung der geänderten Dateien nach der vollständigen Sicherung. Zum Beispiel ein vollständiges Backup am ersten Tag; ein Backup der neuen Daten am zweiten Tag; eine Sicherung der neuen Daten vom zweiten Tag bis zum dritten Tag am dritten Tag; und eine Sicherung aller neuen Daten vom zweiten Tag bis zum vierten Tag am vierten Tag und so weiter.
* Selektives Backup: Verweist auf die Sicherung eines Teils des Systems.
* Cold Backup: bezieht sich auf die Sicherung, wenn das System im Stillstand oder Wartungszustand ist. Die gesicherten Daten sind genau die gleichen wie die Daten im System während dieses Zeitraums.
* Hot Backup: Bezieht sich auf die Sicherung, wenn das System im normalen Betrieb ist. Da die Daten im System jederzeit aktualisiert werden, haben die gesicherten Daten einen gewissen Rückstand gegenüber den realen Daten des Systems.
* Remote Backup: bezieht sich auf die Sicherung von Daten an einem anderen geografischen Ort, um Datenverluste und Unterbrechungen durch Feuer, Naturkatastrophen, Diebstahl usw. zu vermeiden.

## rsync in Kürze

Auf einem Server haben wir die erste Partition auf die zweite Partition gesichert, was allgemein "lokales Backup" genannt ist. Die spezifischen Sicherungswerkzeuge sind `tar` , `dd`, `dump`, `cp`, etc. Obwohl die Daten auf diesem Server gesichert sind, werden die Daten nicht abgerufen, wenn die Hardware nicht richtig bootet. Um dieses Problem mit dem lokalen Backup zu lösen, haben wir eine andere Art von Backup --- "remote backup" eingeführt.

Einige werden sagen, können wir nicht einfach den `tar` oder `cp` Befehl auf dem ersten Server verwenden und die Daten über `scp` oder `sftp` an den zweiten Server senden?

In einem Produktionsumfeld ist die Datenmenge relativ groß. Zuallererst verbraucht `tar` oder `cp` viel Zeit und belegt die Systemleistung. Transmission via `scp` or `sftp` also occupies a lot of network bandwidth, which is not allowed in the actual production environment. Zweitens müssen diese Befehle oder Werkzeuge manuell vom Administrator eingegeben werden und mit der Crontab der geplanten Aufgabe kombiniert werden. Die von crontab festgelegte Zeit ist jedoch nicht leicht zu begreifen, und es ist nicht angemessen, dass Daten gesichert werden, wenn die Zeit zu kurz oder zu lang ist.

Daher muss es eine Datensicherung im Produktionsumfeld geben, die folgende Anforderungen erfüllen muss:

1. Datensicherungen über das Netzwerk übertragen
2. Echtzeit-Daten-Synchronisation
3. Geringerer Verbrauch der Systemressourcen und höhere Effizienz

`rsync` scheint die oben genannten Anforderungen zu erfüllen. Es verwendet die GNU Open Source Lizenz. Es ist ein schnelles inkrementelles Backup-Tool. Die neueste Version war 3.2.3 (2020-08-06). Für weitere Informationen können Sie die [Offizielle Website](https://rsync.samba.org/) besuchen.

Im Hinblick auf die Plattformunterstützung werden die meisten Unix-ähnlichen Systeme unterstützt, egal ob es sich z.B. um GNU/Linux oder BSD handelt. Zusätzlich gibt es unter der Windows-Plattform `rsync` verwandte Programme, wie z.B. cwRsync.

Das ursprüngliche `rsync` wurde vom australischen Programmierer <font color=red>Andrew Tridgell</font> (siehe Abbildung 1 unten) gepflegt und wird jetzt von <font color=red>Wayne Davison</font> (siehe Abbildung 2 unten) gepflegt. Informationen zur Wartung finden Sie unter [GitHub-Projekt](https://github.com/WayneD/rsync).

![ Andrew Tridgell ](images/Andrew_Tridgell.jpg) ![ Wayne Davison ](images/Wayne_Davison.jpg)

!!! note "Bemerkung"

    **rsync selbst ist nur ein inkrementelles Sicherungswerkzeug und hat nicht die Funktion der Echtzeit-Datensynchronisierung (es muss durch andere Programme ergänzt werden). Darüber hinaus ist die Synchronisierung eine Einbahnstraße. Wenn Sie eine bidirektionale Synchronisation durchführen möchten, sollten Sie andere Tools erwägen.**

### Grundprinzipien und Funktionen

Wie erreicht `rsync` ein effizientes Backup durch Datensynchronisierung?

Der Kern von `rsync` ist sein **Prüfsummen-Algorithmus**. Wenn Sie interessiert sind, können Sie die Webseiten \[Wie Rsync funktioniert\](https://rsync.samba.org/how-rsync-works.html) und \[Der rsync-Algorithmus\](https://rsync.samba.org/tech_report/) für weitere Informationen besuchen. Das Thema wird hier nicht ausführlich behandelt.

Die Eigenschaften von `rsync` sind:

* Das gesamte Verzeichnis kann rekursiv aktualisiert werden;
* Kann selektiv Dateisynchronisierungseigenschaften beibehalten, wie z. B. hard Links, soft Links, Eigentümer, Gruppen, entsprechende Berechtigungen, Änderungszeit usw. und kann einige der Attribute beibehalten;
* Unterstützt zwei Protokolle für die Übertragung, eines ist das `ssh`-Protokoll, das andere ist das `rsync`-Protokoll
