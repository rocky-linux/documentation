---
title: Samba Condivisione file di Windows
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.4
tags:
  - file transfer
  - windows
---

## Introduzione

Se si ha mai avuto a che fare con i sistemi Windows, probabilmente si è a conoscenza di SMB (Server Message Block) per la condivisione dei file. Se si è amministratori Linux esperti, è probabile che si abbia sentito parlare di Samba, ma se così non è, [Samba](https://www.samba.org/) è l'implementazione open-source de facto di SMB per consentire la condivisione di file e l'accesso ad Active Directory da macchine Linux a reti Windows.

## Installazione

È necessario installare Samba utilizzando `dnf`:

```bash
dnf install -y samba
```

## Impostazione una condivisione

Per prima cosa, creare una directory da condividere con i client Windows:

```bash
mkdir /var/store
```

Quindi, impostare le labels SELinux sulla directory `/var/store`:

```bash
semanage fcontext -a -t samba_share_t  "/var/store(/.*)?"
restorecon -Rv /var/store
```

Sostituire `/var/store` con la directory da condividere.

Ora configurare Samba:

```bash
vi /etc/samba/smb.conf
```

Nel file `smb.conf`, andare in fondo e inserire quanto segue:

```bash
[Share]
        path = /var/store
        browseable = yes
        writable = no
        read only = yes
        guest ok = yes
```

Se non siete a conoscenza delle opzioni di cui sopra, esse sono:

- `percorso' è la directory che si sta condividendo. Impostare la cartella corrispondente (`/var/store\` nel nostro caso).
- `browseable` è per consentire ai client di accedere alla navigazione. Se si vuole disabilitare la navigazione, impostare questo valore su `no`.
- `writable` è per consentire ai client l'accesso in scrittura. Se si desidera consentire l'accesso in scrittura, impostare questo valore su `yes`.
- `read only` contrassegna la condivisione come di sola lettura. Se si desidera consentire l'accesso in scrittura o in esecuzione, impostare questo valore su `no`.
- `guest ok` è per consentire agli utenti non autenticati di accedere alla nostra condivisione. Se si desidera negare l'accesso agli ospiti, impostare questo valore su `no`.

per testare la configurazione, si può eseguire quanto segue:

```bash
testparm
```

## Abilitare Samba

Una volta che la configurazione è stata verificata, aprire la porta Samba in `firewall-cmd`:

```bash
firewall-cmd --permanent --add-service=samba
firewall-cmd --reload
```

Successivamente, è possibile abilitare Samba:

```bash
systemctl enable --now smb nmb
```

## Accesso alla condivisione Samba

È possibile accedere alla condivisione Samba utilizzando il seguente URI (Nota: sostituire `SERVER_IP` con l'indirizzo IP o FQDN della macchina su cui è in esecuzione Samba):

- Windows: `\\SERVER_IP`
- Linux or Mac: `smb://SERVER_IP`

`SERVER_IP` sulla rete domestica dell'autore è `172.20.0.100`, quindi mentre le istruzioni variano a seconda del sistema operativo, l'autore accederà alla nuova condivisione dal suo notebook Fedora 40:

![Fedora 40 Nautilus che mostra il nostro Samba Share](../images/samba_nautilus.png)

Tutti i file accessibili sul server sono disponibili anche sui computer client.

## Conclusione

Sebbene SMB abbia la reputazione di essere incentrato su Microsoft, si tratta di uno standard di settore e la condivisione Samba può essere accessibile da Linux, Mac, BSD e persino da dispositivi mobili. Congratulazioni, ora si sta condividendo i file del vostro server!
