---
title: Management server optimizations
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
update: 06-Dec-2021
---

# Management server optimizations

In this chapter, we will review the configuration options that may be of interest to optimize our Ansible management server.

## The `ansible.cfg` configuration file

Some interesting configuration options to comment on:

* `forks`: by default to 5, it is the number of processes that Ansible will launch in parallel to communicate with remote hosts. The higher this number is, the more clients Ansible will be able to manage at the same time, and thus speed up processing. The value you can set is dependent on the CPU/RAM limits of your management server. Note that the default value, `5`, is very small, the Ansible documentation states that many users set it to 50, even 500 or more.

* `gathering`: this variable changes the policy for collecting facts. By default, the value is `implicit`, which implies that facts will be collected systematically. Switching this variable to `smart` allows for collection facts only when they have not already been collected. Coupled with a facts cache (see below), this option can greatly increase performance.

* `host_key_checking`: Be careful with your server security! However, if you are in control of your environment, it can be interesting to disable the key control of remote servers and save some time at the connection. You can also, on remote servers, disable the use of the DNS of the SSH server (in `/etc/ssh/sshd_config`, option `UseDNS no`), this option wastes time at the connection and is, most of the time, only used in the connection logs.

* `ansible_managed`: This variable, containing `Ansible managed` by default, is typically used in file templates that are deployed on remote servers. It allows you to specify to an administrator that the file is managed automatically and that any changes they make to it will potentially be lost. It can be interesting to let the administrators have a more complete messages. Be careful though, if you change this variable, it may cause daemons to restart (via the handlers associated with the templates).

* `ssh_args = -C -o ControlMaster=auto -o ControlPersist=300s -o PreferredAuthentications=publickey`: specify the ssh connection options. By disabling all authentication methods other than public key, you can save a lot of time. You can also increase the `ControlPersist` to improve performance (the documentation suggests that a value equivalent to 30 minutes may be appropriate). The connection to a client will stay open longer and can be reused when reconnecting to the same server, which is a significant time saving.

* `control_path_dir`: Specify the path to the connection sockets. If this path is too long, it can cause problems. Consider changing it to something short, such as `/tmp/.cp`.

* `pipelining`: Setting this value to `True` increases performance by reducing the number of SSH connections needed when running remote modules. You must first make sure that the `requiretty` option is disabled in the `sudoers` options (see documentation).

## Caching the facts

Gathering facts is a process that can take some time. It can be interesting to disable this gathering for playbooks that don't need it (via `gather_facts` option) or to keep these facts in memory in a cache for a certain period of time (for example 24H).

These facts can be easily stored in a `redis` database:

```
sudo yum install redis
sudo systemctl start redis
sudo systemctl enable redis
sudo pip3 install redis
```

Don't forget to modify the ansible configuration:

```
fact_caching = redis
fact_caching_timeout = 86400
fact_caching_connection = localhost:6379:0
```

To check the correct operation, it is enough to request the `redis` server:

```
redis-cli
127.0.0.1:6379> keys *
127.0.0.1:6379> get ansible_facts_SERVERNAME
```

## Using Vault

The various passwords and secrets cannot be stored in clear text with the Ansible source code, either locally on the management server or on a possible source code manager.

Ansible proposes using an encryption manager: `ansible-vault`.

The principle is to encrypt a variable or a whole file with the `ansible-vault` command.

Ansible will be able to decrypt this file at runtime by retrieving the encryption key from the file (for example) `/etc/ansible/ansible.cfg`. The latter can also be a python script or other.

Edit the `/etc/ansible/ansible.cfg` file:

```
#vault_password_file = /path/to/vault_password_file
vault_password_file = /etc/ansible/vault_pass
```

Store the password in this file `/etc/ansible/vault_pass` and assign necessary restrictive rights:

```
mysecretpassword
```

You can then encrypt your files with the command:

```
ansible-vault encrypt myfile.yml
```

A file encrypted by `ansible-vault` can be easily recognized by its header:

```
$ANSIBLE_VAULT;1.1;AES256
35376532343663353330613133663834626136316234323964333735363333396136613266383966
6664322261633261356566383438393738386165333966660a343032663233343762633936313630
34373230124561663766306134656235386233323964336239336661653433663036633334366661
6434656630306261650a313364636261393931313739363931336664386536333766326264633330
6334
```

Once a file is encrypted, it can still be edited with the command:

```
ansible-vault edit myfile.yml
```

You can also deport your password storage to any password manager.

For example, to retrieve a password that would be stored in the rundeck vault:

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

## Working with Windows servers

It will be necessary to install on the management server several packages:

* Via the package manager:

```
sudo dnf install python38-devel krb5-devel krb5-libs krb5-workstation
```

and configure the `/etc/krb5.conf` file to specify the correct `realms`:

```
[realms]
ROCKYLINUX.ORG = {
    kdc = dc1.rockylinux.org
    kdc = dc2.rockylinux.org
}
[domain_realm]
  .rockylinux.org = ROCKYLINUX.ORG
```

* Via the python package manager:

```
pip3 install pywinrm
pip3 install pywinrm[credssp]
pip3 install kerberos requests-kerberos
```

## Working with IP modules

Network modules usually require the `netaddr` python module:

```
sudo pip3 install netaddr
```

## Generating a CMDB

A tool, `ansible-cmdb` has been developed to generate a CMDB from ansible.

```
pip3 install ansible-cmdb
```

The facts must be exported by ansible with the following command:

```
ansible --become --become-user=root -o -m setup --tree /var/www/ansible/cmdb/out/
```

You can then generate a global `json` file:

```
ansible-cmdb -t json /var/www/ansible/cmdb/out/linux > /var/www/ansible/cmdb/cmdb-linux.json
```

If you prefer a web interface:

```
ansible-cmdb -t html_fancy_split /var/www/ansible/cmdb/out/
```
