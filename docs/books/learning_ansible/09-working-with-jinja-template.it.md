---
title: Lavorare con i Modelli Jinja
author: Srinivas Nishant Viswanadha
contributors: Steven Spencer, Antoine Le Morvan, Ganna Zhyrnova
---

# Capitolo: Lavorare con i modelli Jinja in Ansible

## Introduzione

Ansible fornisce un modo potente e semplice per gestire le configurazioni utilizzando i modelli Jinja attraverso il modulo integrato `template`. Questo capitolo esplora due modi essenziali per utilizzare i modelli Jinja in Ansible:

- aggiungere variabili a un file di configurazione
- costruire file complessi con loop e strutture di dati intricate.

## Aggiunta di variabili a un file di configurazione

### Passo 1: creare un modello Jinja

Creare un file modello Jinja, ad esempio `sshd_config.j2`, con segnaposti per le variabili:

```jinja
# /path/to/sshd_config.j2

Port {{ ssh_port }}
PermitRootLogin {{ permit_root_login }}
# Add more variables as needed
```

### Passo 2: utilizzare il modulo template di Ansible

Nel playbook di Ansible, utilizzare il modulo `template` per rendere il template Jinja con valori specifici:

```yaml
---
- name: Generate sshd_config
  hosts: your_target_hosts
  tasks:
    - name: Template sshd_config
      template:
        src: /path/to/sshd_config.j2
        dest: /etc/ssh/sshd_config
      vars:
        ssh_port: 22
        permit_root_login: no
      # Add more variables as needed
```

### Passo 3: applicare le modifiche alla configurazione

Eseguire il playbook Ansible per applicare le modifiche agli host di destinazione:

```bash
ansible-playbook your_playbook.yml
```

Questa fase garantisce che le modifiche alla configurazione siano applicate in modo coerente a tutta l'infrastruttura.

## Costruire un file completo con loop e strutture dati complesse

### Passo 1: migliorare un modello Jinja

Estendere il modello Jinja per gestire loop e strutture di dati complesse. Ecco un esempio di configurazione di un'ipotetica applicazione con più componenti:

```jinja
# /path/to/app_config.j2

{% for component in components %}
[{{ component.name }}]
    Path = {{ component.path }}
    Port = {{ component.port }}
    # Aggiungi ulteriori configurazioni necessarie
{% endfor %}
```

### Passaggio 2: integrare il modulo template Ansible

Nel playbook di Ansible, integrare il modulo `template` per generare un file di configurazione completo:

```yaml
---
- name: Generate Application Configuration
  hosts: your_target_hosts
  vars:
    components:
      - name: web_server
        path: /var/www/html
        port: 80
      - name: database
        path: /var/lib/db
        port: 3306
      # Add more components as needed
  tasks:
    - name: Template Application Configuration
      template:
        src: /path/to/app_config.j2
        dest: /etc/app/config.ini
```

Eseguire il playbook Ansible per applicare le modifiche agli host di destinazione:

```bash
ansible-playbook your_playbook.yml
```

Questa fase garantisce che le modifiche alla configurazione siano applicate in modo coerente a tutta l'infrastruttura.

Il modulo `template` di Ansible può utilizzare i template Jinja per generare dinamicamente file di configurazione durante l'esecuzione del playbook. Questo modulo consente di separare la logica di configurazione e dati, rendendo i playbook Ansible più flessibili e facili da gestire.

### Caratteristiche principali

1. **Rendering del template:**
   - Il modulo esegue il rendering dei template Jinja per creare file di configurazione con contenuti dinamici.
   - Le variabili definite nel playbook o nell'inventario possono essere inserite nei modelli, consentendo configurazioni dinamiche.

2. **Utilizzo di Jinja2:**
   - Il modulo `template` sfrutta il motore di creazione di template Jinja2, offrendo potenti funzionalità come istruzioni condizionali, cicli e filtri per la manipolazione avanzata dei template.

3. **Percorsi di origine e destinazione:**
   - Specifica il file template Jinja di origine e il percorso di destinazione per il file di configurazione generato.

4. **Passare le variabili:**
   - Le variabili possono essere passate direttamente nel playbook o caricate da file esterni, consentendo la generazione di configurazioni flessibili e dinamiche.

5. **Esecuzione idempotente:**
   - Il modulo template supporta l'esecuzione idempotente, garantendo che il template venga applicato solo se vengono rilevate modifiche.

### Esempio di un playbook

```yaml
---
- name: Generate Configuration File
  hosts: your_target_hosts
  tasks:
    - name: Template Configuration File
      template:
        src: /path/to/template.j2
        dest: /etc/config/config_file
      vars:
        variable1: value1
        variable2: value2
```

### Casi d'uso

1. **Gestione della configurazione:**
   - Ideale per gestire le configurazioni di sistema generando dinamicamente file in base a parametri specifici.

2. **Setup Applicativi:**
   - Utile per creare file di configurazione per applicazioni specifiche con impostazioni diverse.

3. **Infrastruttura come codice:**
   - Facilita le pratiche di Infrastruttura come Codice consentendo adattamenti dinamici alle configurazioni in base alle variabili.

### Buone pratiche

1. **Separazione degli interessi:**
   - Mantenere la logica di configurazione effettiva nei modelli Jinja, separandola dalla struttura principale del playbook.

2. **Controllo Versione:**
   - Salvare i modelli Jinja in repository con controllo delle versioni per un miglior monitoraggio ed una migliore collaborazione.

3. **Testabilità:**
   - Testare i modelli in modo indipendente per assicurarsi che producano l'output di configurazione previsto.

Sfruttando il modulo `template`, gli utenti Ansible possono migliorare la gestibilità e la flessibilità delle attività di configurazione, promuovendo un approccio più snello ed efficiente alla configurazione del sistema e delle applicazioni.

### Riferimenti

[Ansible Template Module Documentation](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html).
