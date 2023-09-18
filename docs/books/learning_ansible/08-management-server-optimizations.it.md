---
title: Ottimizzazioni del server di gestione
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
update: 23-Dec-2021
---

# Ottimizzazioni del server di gestione

In questo capitolo, esamineremo le opzioni di configurazione che possono essere di interesse per ottimizzare il nostro server di gestione Ansible.

## Il file di configurazione `ansible.cfg`

Alcune interessanti opzioni di configurazione da commentare:

* `forks`: per impostazione predefinita a 5, è il numero di processi che Ansible avvierà in parallelo per comunicare con gli host remoti. Più alto è questo numero, più clienti Ansible sarà in grado di gestire allo stesso tempo, e quindi accelerare l'elaborazione. Il valore che puoi impostare dipende dai limiti CPU/RAM del tuo server di gestione. Nota che il valore predefinito, `5`, è molto piccolo, la documentazione Ansible afferma che molti utenti la impostano a 50, anche 500 o più.

* `gathering`: questa variabile cambia la politica per la raccolta dei fatti,. Per impostazione predefinita, il valore è `implicit`, il che implica che i fatti saranno raccolti sistematicamente. Il passaggio di questa variabile a `smart` consente di raccogliere i fatti solo quando non sono già stati acquisiti. Accoppiato con una cache di fatti (vedi sotto), questa opzione può aumentare notevolmente le prestazioni.

* `host_key_check`: Fai attenzione alla sicurezza del tuo server! Tuttavia, se si è in controllo del vostro ambiente, può essere interessante disattivare il controllo della chiave dei server remoti e risparmiare un po 'di tempo alla connessione. È inoltre possibile, sui server remoti, disabilitare l'utilizzo del DNS del server SSH (in `/etc/ssh/sshd_config`, opzione `UseDNS no`), questa opzione spreca tempo alla connessione ed è per la maggior parte del tempo, utilizzata solo nei registri di connessione.

* `ansible_managed`: Questa variabile, contenente `Ansible managed` per impostazione predefinita, è tipicamente utilizzata nei modelli di file che vengono distribuiti su server remoti. Consente di specificare ad un amministratore che il file viene gestito automaticamente e che qualsiasi modifica apportata ad esso verrà potenzialmente persa. Può essere interessante lasciare che gli amministratori abbiano dei messaggi più completi. Fai attenzione, però, la modifica di questa variabile, potrebbe causare il riavvio dei demoni (tramite i gestori associati ai modelli).

* `ssh_args = -C -o ControlMaster=auto -o ControlPersist=300s -o PreferredAuthentications=publickey`: specifica le opzioni di connessione ssh. Disabilitando tutti i metodi di autenticazione diversi dalla chiave pubblica, puoi risparmiare molto tempo. È inoltre possibile aumentare il `ControlPersist` per migliorare le prestazioni (la documentazione suggerisce che un valore equivalente a 30 minuti può essere appropriato). La connessione a un client rimarrà aperta più a lungo e potrà essere riutilizzata quando ci si riconnette allo stesso server, il che rappresenta un notevole risparmio di tempo.

* `control_path_dir`: Specifica il percorso dei socket di connessione. Se questo percorso è troppo lungo, può causare problemi. Considera di cambiarlo in qualcosa di breve, come `/tmp/.cp`.

* `pipelining`: Impostare questo valore a `True` aumenta le prestazioni riducendo il numero di connessioni SSH necessarie quando si eseguono moduli remoti. Devi prima assicurarti che l'opzione `requiretty` sia disabilitata nelle opzioni `sudoers` (vedi documentazione).

## Memorizzazione dei fatti

Raccogliere fatti è un processo che può richiedere un certo tempo. Può essere interessante disabilitare questa raccolta per i playbook che non ne hanno bisogno (tramite l'opzione `collect_facts`) o per mantenere questi fatti in memoria in una cache per un certo periodo di tempo (ad esempio 24H).

Questi fatti possono essere facilmente memorizzati in un database `redis`:

```
sudo yum install redis
sudo systemctl start redis
sudo systemctl enable redis
sudo pip3 install redis
```

Non dimenticate di modificare la configurazione ansibile:

```
fact_caching = redis
fact_caching_timeout = 86400
fact_caching_connection = localhost:6379:0
```

Per controllare il corretto funzionamento, è sufficiente richiedere il server `redis`:

```
redis-cli
127.0.0.1:6379> keys *
127.0.0.1:6379> get ansible_facts_SERVERNAME
```

## Usare Vault

Le varie password e segreti non possono essere memorizzate in un testo in chiaro assieme al codice sorgente Ansible o localmente sul server di gestione o su un possibile gestore di codice sorgente.

Ansible propone di utilizzare un gestore di cifratura: `ansible-vault`.

Il principio è quello di crittografare una variabile o un intero file con il comando `ansible-vault`.

Ansible sarà in grado di decifrare questo file durante l'esecuzione recuperando la chiave di crittografia dal file (ad esempio) `/etc/ansible/ansible.cfg`. Quest'ultimo può anche essere uno script python o altro.

Modifica il file `/etc/ansible/ansible.cfg`:

```
#vault_password_file = /path/to/vault_password_file
vault_password_file = /etc/ansible/vault_pass
```

Memorizza la password in questo file `/etc/ansible/vault_pass` e assegna i diritti restrittivi necessari:

```
mysecretpassword
```

È quindi possibile crittografare i file con il comando:

```
ansible-vault encrypt myfile.yml
```

Un file crittografato `ansible-vault` può essere facilmente riconosciuto dall'intestazione:

```
$ANSIBLE_VAULT;1.1;AES256
35376532343663353330613133663834626136316234323964333735363333396136613266383966
6664322261633261356566383438393738386165333966660a343032663233343762633936313630
34373230124561663766306134656235386233323964336239336661653433663036633334366661
6434656630306261650a313364636261393931313739363931336664386536333766326264633330
6334
```

Una volta cifrato, un file, esso può ancora essere modificato con il comando:

```
ansible-vault edit myfile.yml
```

È inoltre possibile esportare la tua password di archiviazione in qualsiasi password manager.

Ad esempio, per recuperare una password che dovrebbe essere memorizzata nel rundeck vault:

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

## Lavorare con i server Windows

Sarà necessario installare sul server di gestione parecchi pacchetti:

* Attraverso il gestore dei pacchetti:

```
sudo dnf install python38-devel krb5-devel krb5-libs krb5-workstation
```

e configurare il file `/etc/krb5.conf` per specificare il corretto `realms`:

```
[realms]
ROCKYLINUX.ORG = {
    kdc = dc1.rockylinux.org
    kdc = dc2.rockylinux.org
}
[domain_realm]
  .rockylinux.org = ROCKYLINUX.ORG
```

* Tramite il gestore di pacchetti python:

```
pip3 install pywinrm
pip3 install pywinrm[credssp]
pip3 install kerberos requests-kerberos
```

## Lavorare con i moduli IP

I moduli di rete di solito richiedono il modulo python `netaddr`:

```
sudo pip3 install netaddr
```

## Generazione di un CMDB

Uno strumento, `ansible-cmdb` è stato sviluppato per generare un CMDB da ansibile.

```
pip3 install ansible-cmdb
```

I fatti devono essere esportati con il seguente comando:

```
ansible --become --become-user=root -o -m setup --tree /var/www/ansible/cmdb/out/
```

Puoi quindi generare un file globale `json`:

```
ansible-cmdb -t json /var/www/ansible/cmdb/out/linux > /var/www/ansible/cmdb/cmdb-linux.json
```

Se preferisci un'interfaccia web:

```
ansible-cmdb -t html_fancy_split /var/www/ansible/cmdb/out/
```
