---
title: nmcli – `Autoconnect` setzen
author: Wale Soyinka
tags:
  - nmcli
---

# Änderung der Autoconnect-Eigenschaft des NetworkManager-Verbindungsprofils

Verwenden Sie zunächst `nmcli`, um den aktuellen Wert der `Autoconnect`-Eigenschaft für alle Netzwerkverbindungen auf einem Rocky Linux-System abzufragen und anzuzeigen. Geben Sie bitte Folgendes ein:

```bash
nmcli -f name,autoconnect connection 
```

Um den Wert einer Eigenschaft für eine Netzwerkverbindung zu ändern, verwenden Sie den Unterbefehl `modify` mit `nmcli connection`. Um beispielsweise den Wert der Eigenschaft `autoconnect` für das Verbindungsprofil `ens3` von `no` in `yes` zu ändern, geben Sie Folgendes ein:

```bash
sudo nmcli con mod ens3 connection.autoconnect yes
```

## Zu den Befehlen

```bash
connection (con)       : Netzwerk-Manager Connection-Objekt. 
modify (mod)            : Eine oder mehrere Eigenschaften eines bestimmten Verbindungsprofils ändern.
connection.autoconnect : Einstellung und Eigenschaften (<setting>.<property>)
-f, --fields           : gibt die auszugebenden Felder an.
```

## Anmerkungen

Dieser Hinweis zeigt, wie man ein bestehendes NetworkManager-Verbindungsprofil ändert. Dies ist nützlich, wenn die Netzwerkschnittstelle nach einer erneuten Rocky Linux Installation oder einem Systemupdate nicht automatisch aktiviert wird. Der Grund dafür liegt oft darin, dass der Wert der Eigenschaft autoconnect auf `o` gesetzt wird. Sie können den `nmcli`-Befehl verwenden, um den Wert schnell auf `yes` zu ändern.  
