---
title: Management-Server Optimierung
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
update: 2021-12-06
---

# Management-Server Optimierung

In diesem Kapitel betrachten wir Konfigurationsoptionen, die für die Optimierung unseres Ansible-Verwaltungsservers von Interesse sein können.

## Die Konfigurationsdatei `ansible.cfg`

Einige interessante Konfigurationsoptionen, die wir kommentieren sollten:

* `forks`: Der Standardwert ist 5. Dies ist die Anzahl der Prozesse, die Ansible parallel startet, um mit Remote-Hosts zu kommunizieren. Je höher diese Zahl ist, desto mehr Clients kann Ansible gleichzeitig bearbeiten und desto schneller wird die Verteilung. Der Wert, den Sie festlegen können, hängt von den CPU-/RAM-Grenzwerten Ihres Managementservers ab. Beachten Sie, dass der Standardwert `5` sehr klein ist. In der Ansible-Dokumentation heißt es, dass ihn viele Benutzer auf 50, sogar 500 oder mehr setzen.

* `gathering`: Diese Variable ändert die Richtlinie für die Sammlung von Fakten. Standardmäßig ist der Wert `implicit`, was bedeutet, dass Fakten systematisch gesammelt werden. Durch das Setzen dieser Variablen mit dem Wert `smart` können Sie Fakten nur dann sammeln, wenn diese noch nicht gesammelt wurden. In Verbindung mit einem Fakten-Cache (siehe unten) kann diese Option die Leistung deutlich steigern.

* `host_key_check`: Achten Sie auf die Sicherheit Ihres Servers! Wenn Sie jedoch die Kontrolle über Ihre Umgebung haben, kann es interessant sein, die Schlüsselüberprüfung von Remote-Servern zu deaktivieren und so beim Herstellen der Verbindung Zeit zu sparen. Auf Remote-Servern ist es auch möglich, die Verwendung von DNS durch den SSH-Server zu deaktivieren (in `/etc/ssh/sshd_config`, Option `UseDNS no`), diese Option verschwendet Zeit beim Herstellen einer Verbindung und wird meist nur in Verbindungsprotokollen verwendet.

* `ansible_managed`: Diese Variable, die standardmäßig `Ansible managed` enthält, wird normalerweise in Dateivorlagen verwendet, die auf Remote-Servern bereitgestellt werden. Ermöglicht Ihnen, einem Administrator mitzuteilen, dass die Datei automatisch verwaltet wird und dass alle daran vorgenommenen Änderungen möglicherweise verloren gehen. Es könnte interessant sein, Administratoren eine umfassendere Nachricht zu übermitteln. Seien Sie jedoch vorsichtig, denn das Ändern dieser Variablen kann dazu führen, dass die Daemons neu gestartet werden (über die mit den Vorlagen verknüpften Manager).

* `ssh_args = -C -o ControlMaster=auto -o ControlPersist=300s -o PreferredAuthentications=publickey`: definiert die ssh-Verbindungseinstellungen. Indem Sie alle Authentifizierungsmethoden außer dem öffentlichen Schlüssel deaktivieren, können Sie viel Zeit sparen. Sie können auch den Wert von `ControlPersist` erhöhen, um die Leistung zu verbessern (die Dokumentation legt nahe, dass ein Wert von 30 Minuten angemessen sein könnte). Die Verbindung zu einem Client bleibt länger geöffnet und kann bei erneuter Verbindung mit demselben Server wiederverwendet werden, was eine erhebliche Zeitersparnis bedeutet.

* `control_path_dir`: Legt den Pfad der Verbindungssockets fest. Wenn dieser Pfad zu lang ist, kann es zu Problemen führen. Erwägen Sie, es in etwas Kurzes zu ändern, wie zum Beispiel `/tmp/.cp`.

* `pipelining`: Wenn Sie diesen Wert auf `True` setzen, erhöht sich die Performance, indem die Anzahl der erforderlichen SSH-Verbindungen beim Ausführen von Remote-Modulen reduziert wird. Sie müssen zunächst sicherstellen, dass die Option `requiretty` in den `sudoers`-Optionen deaktiviert ist (siehe Dokumentation).

## "Facts" im Cache speichern

Das Zusammentragen der "Facts" ist ein Prozess, der einige Zeit in Anspruch nehmen kann. Es kann interessant sein, diese Sammlung für Playbooks zu deaktivieren, die sie nicht benötigen (über die Option `collect_facts`) oder diese Fakten für einen bestimmten Zeitraum (z. B. 24 Stunden) in einem Cache zu speichern.

Diese Fakten können einfach in einer `redis`-Datenbank gespeichert werden:

```
sudo yum install redis
sudo systemctl start redis
sudo systemctl enable redis
sudo pip3 install redis
```

Vergessen Sie nicht, die Ansible-Konfiguration zu ändern:

```
fact_caching = redis
fact_caching_timeout = 86400
fact_caching_connection = localhost:6379:0
```

Um die korrekte Funktion zu überprüfen, fragen Sie einfach den `redis`-Server ab:

```
redis-cli
127.0.0.1:6379> keys *
127.0.0.1:6379> get ansible_facts_SERVERNAME
```

## Vault-Verwendung

Die verschiedenen Passwörter und Geheimnisse können nicht im Klartext zusammen mit dem Ansible-Quellcode oder lokal auf dem Verwaltungsserver oder einem möglichen Quellcode-Manager gespeichert werden.

Ansible empfiehlt die Verwendung eines Verschlüsselungsmanagers: `ansible-vault`.

Das Prinzip besteht darin, eine Variable oder eine ganze Datei mit dem Befehl `ansible-vault` zu verschlüsseln.

Ansible kann diese Datei zur Laufzeit entschlüsseln, indem es den Verschlüsselungsschlüssel aus der Datei abruft (z. B. `/etc/ansible/ansible.cfg`). Letzteres kann auch ein Python-Skript oder ähnliches sein.

Die Datei `/etc/ansible/ansible.cfg` editieren:

```
#vault_password_file = /path/to/vault_password_file
vault_password_file = /etc/ansible/vault_pass
```

Speichern Sie das Passwort in der Datei `/etc/ansible/vault_pass` und vergeben Sie die notwendigen restriktiven Rechte:

```
mysecretpassword
```

Sie können Ihre Dateien verschlüsseln, in dem Sie Folgendes eingeben:

```
ansible-vault encrypt myfile.yml
```

Eine mit `ansible-vault` verschlüsselte Datei, kann leicht an ihrem Header erkannt werden:

```
$ANSIBLE_VAULT;1.1;AES256
35376532343663353330613133663834626136316234323964333735363333396136613266383966
6664322261633261356566383438393738386165333966660a343032663233343762633936313630
34373230124561663766306134656235386233323964336239336661653433663036633334366661
6434656630306261650a313364636261393931313739363931336664386536333766326264633330
6334
```

Obwohl die Datei verschlüsselt ist, können Sie sie wie folgt editieren:

```
ansible-vault edit myfile.yml
```

Sie können Ihren Passwortspeicher auch auf einen beliebigen Passwortmanager übertragen.

Um beispielsweise ein Passwort abzurufen, das im Rundeck-Vault gespeichert ist:

```
#!/usr/bin/env python
# -*- coding: utf-8 -*-
import urllib.request
import io
import ssl

def get_password():
    '''
    :return: Vault password
    :return_type: str
    '''
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE

    url = 'https://rundeck.rockylinux.org/api/11/storage/keys/ansible/vault'
    req = urllib.request.Request(url, headers={
                          'Accept': '*/*',
                          'X-Rundeck-Auth-Token': '****token-rundeck****'
                          })
    response = urllib.request.urlopen(req, context=ctx)

    return response.read().decode('utf-8')

if __name__ == '__main__':
    print(get_password())
```

## Windows-Server

Es ist notwendig, mehrere Pakete auf dem Verwaltungsserver zu installieren:

* Via Paket-Manager:

```
sudo dnf install python38-devel krb5-devel krb5-libs krb5-workstation
```

und die Datei `/etc/krb5.conf` zu konfigurieren, um `realms` korrekt zu spezifizieren:

```
[realms]
ROCKYLINUX.ORG = {
    kdc = dc1.rockylinux.org
    kdc = dc2.rockylinux.org
}
[domain_realm]
  .rockylinux.org = ROCKYLINUX.ORG
```

* Via Python-Paket-Manager:

```
pip3 install pywinrm
pip3 install pywinrm[credssp]
pip3 install kerberos requests-kerberos
```

## IP-Module

Netzwerk-Module benötigen im allgemeinen das `netaddr` Python-Modul:

```
sudo pip3 install netaddr
```

## CMDB Generierung

Ein Tool, `ansible-cmdb`, wurde entwickelt, um eine CMDB aus Ansible zu generieren.

```
pip3 install ansible-cmdb
```

Die Fakten - facts - müssen von Ansible mit dem folgenden Befehl exportiert werden:

```
ansible --become --become-user=root -o -m setup --tree /var/www/ansible/cmdb/out/
```

Sie können nun eine globale `json` Datei wie folgt generieren:

```
ansible-cmdb -t json /var/www/ansible/cmdb/out/linux > /var/www/ansible/cmdb/cmdb-linux.json
```

Wenn ein Web-Interface Ihnen lieber ist:

```
ansible-cmdb -t html_fancy_split /var/www/ansible/cmdb/out/
```
