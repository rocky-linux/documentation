---
title: Gestione File
---

# Ansible - Gestione dei file

In questo capitolo imparerai come gestire i file con Ansable.

****

**Obiettivi**: In questo capitolo imparerai come:

:heavy_check_mark: modificare il contenuto del file;  
:heavy_check_mark: caricare i file ai server di destinazione;  
:heavy_check_mark: recuperare i file dai server di destinazione.

:checkered_flag: **ansible**, **moduli**, **files**

**Conoscenza**: :star: :star:  
**Complessità**: :star:

**Tempo di lettura**: 20 minuti

****

A seconda delle vostre esigenze, dovrete utilizzare diversi moduli Ansible per modificare i file di configurazione del sistema.

## modulo `ini_file`

Quando si desidera modificare un file INI (sezione tra doppie `[]` e `key=value`), il modo più semplice è usare il modulo `ini_file`.

!!! Note "Nota"

    Ulteriori informazioni possono essere [trovate qui](https://docs.ansible.com/ansible/latest/collections/community/general/ini_file_module.html).

Il modulo richiede:

* Il valore della sezione
* Il nome dell'opzione
* Il nuovo valore

Esempio di utilizzo:

```bash
- name: change value on inifile
  community.general.ini_file:
    dest: /path/to/file.ini
    section: SECTIONNAME
    option: OPTIONNAME
    value: NEWVALUE
```

## modulo `lineinfile`

Per garantire che una riga sia presente in un file, o quando una singola riga in un file debba essere aggiunta o modificata, usa il modulo `linefile`.

!!! Note "Nota"

    Maggiori informazioni possono essere [trovate qui](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html).

In questo caso, la riga da modificare in un file verrà trovata usando un regexp.

Ad esempio, per garantire che la linea che inizia con `SELINUX=` nel file `/etc/selinux/config` contenga il valore `enforcing`:

```bash
- ansible.builtin.lineinfile:
    path: /etc/selinux/config
    regexp: '^SELINUX='
    line: 'SELINUX=enforcing'
```

## modulo `copy`

Quando un file deve essere copiato dal server Ansible in uno o più host, è meglio utilizzare il modulo `copy`.

!!! Note "Nota"

    Maggiori informazioni possono essere [trovate qui](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html).

Qui stiamo copiando `myflile.conf` da una posizione all'altra:

```bash
- ansible.builtin.copy:
    src: /data/ansible/sources/myfile.conf
    dest: /etc/myfile.conf
    owner: root
    group: root
    mode: 0644
```

## modulo `fetch`

Quando un file deve essere copiato da un server remoto al server locale, è meglio utilizzare il modulo `fetch`.

!!! Note "Nota"

    Ulteriori informazioni possono essere [trovate qui](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/fetch_module.html).

Questo modulo fa il contrario del modulo `copy`:

```bash
- ansible.builtin.fetch:
    src: /etc/myfile.conf
    dest: /data/ansible/backup/myfile-{{ inventory_hostname }}.conf
    flat: yes
```

## modulo `template`

Ansible e il suo modulo `template` utilizzano il sistema di template **Jinja2** (<http://jinja.pocoo.org/docs/>) per generare i file sugli host di destinazione.

!!! Note "Nota"

    Ulteriori informazioni possono essere [trovate qui](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html).

Per esempio:

```bash
- ansible.builtin.template:
    src: /data/ansible/templates/monfichier.j2
    dest: /etc/myfile.conf
    owner: root
    group: root
    mode: 0644
```

È possibile aggiungere una fase di convalida se il servizio di destinazione lo permette (ad esempio apache con il comando `apachectl -t`):

```bash
- template:
    src: /data/ansible/templates/vhost.j2
    dest: /etc/httpd/sites-available/vhost.conf
    owner: root
    group: root
    mode: 0644
    validate: '/usr/sbin/apachectl -t'
```

## modulo `get_url`

Per caricare file da un sito web o ftp a uno o più host, utilizzare il modulo `get_url`:

```bash
- get_url:
    url: http://site.com/archive.zip
    dest: /tmp/archive.zip
    mode: 0640
    checksum: sha256:f772bd36185515581aa9a2e4b38fb97940ff28764900ba708e68286121770e9a
```

Fornendo un checksum del file, il file non verrà nuovamente scaricato se è già presente nella posizione di destinazione e il suo checksum corrisponde al valore fornito.
